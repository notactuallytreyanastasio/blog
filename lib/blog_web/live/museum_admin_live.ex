defmodule BlogWeb.MuseumAdminLive do
  use BlogWeb, :live_view
  alias Blog.Museum.Projects

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       authenticated: false,
       projects: [],
       editing_project: nil,
       adding_project: false
     )}
  end

  # === Event Handlers ===

  def handle_event("check_password", %{"password" => password}, socket) do
    expected = Application.get_env(:blog, :finder_admin_password)

    if password == expected do
      {:noreply, socket |> assign(authenticated: true) |> reload_projects()}
    else
      {:noreply, put_flash(socket, :error, "Wrong password")}
    end
  end

  def handle_event("toggle_add_project", _, socket) do
    {:noreply, assign(socket, adding_project: !socket.assigns.adding_project)}
  end

  def handle_event("save_new_project", params, socket) do
    max_order =
      socket.assigns.projects
      |> Enum.map(& &1.sort_order)
      |> Enum.max(fn -> 0 end)

    attrs = %{
      slug: params["slug"],
      title: params["title"],
      tagline: nilify(params["tagline"]),
      description: nilify(params["description"]),
      category: params["category"] || "tools",
      tech_stack: parse_comma_list(params["tech_stack"]),
      github_repos: parse_repos(params["github_repos"]),
      internal_path: nilify(params["internal_path"]),
      external_url: nilify(params["external_url"]),
      sort_order: max_order + 1,
      visible: true
    }

    case Projects.create_project(attrs) do
      {:ok, _} -> {:noreply, socket |> assign(adding_project: false) |> reload_projects()}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Failed to create project")}
    end
  end

  def handle_event("edit_project", %{"id" => id}, socket) do
    project = Projects.get_project!(String.to_integer(id))
    {:noreply, assign(socket, editing_project: project)}
  end

  def handle_event("cancel_edit", _, socket) do
    {:noreply, assign(socket, editing_project: nil)}
  end

  def handle_event("update_project", params, socket) do
    project = socket.assigns.editing_project

    attrs = %{
      slug: params["slug"],
      title: params["title"],
      tagline: nilify(params["tagline"]),
      description: nilify(params["description"]),
      category: params["category"],
      tech_stack: parse_comma_list(params["tech_stack"]),
      github_repos: parse_repos(params["github_repos"]),
      internal_path: nilify(params["internal_path"]),
      external_url: nilify(params["external_url"]),
      visible: params["visible"] == "true"
    }

    case Projects.update_project(project, attrs) do
      {:ok, _} -> {:noreply, socket |> assign(editing_project: nil) |> reload_projects()}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Failed to update project")}
    end
  end

  def handle_event("delete_project", %{"id" => id}, socket) do
    project = Projects.get_project!(String.to_integer(id))
    Projects.delete_project(project)
    {:noreply, reload_projects(socket)}
  end

  def handle_event("move_project", %{"id" => id, "dir" => dir}, socket) do
    direction = String.to_existing_atom(dir)
    Projects.reorder_project(String.to_integer(id), direction)
    {:noreply, reload_projects(socket)}
  end

  def handle_event("reorder_projects", %{"ids" => ids}, socket) do
    Projects.bulk_reorder(ids)
    {:noreply, reload_projects(socket)}
  end

  def handle_event("toggle_visibility", %{"id" => id}, socket) do
    project = Projects.get_project!(String.to_integer(id))
    Projects.update_project(project, %{visible: !project.visible})
    {:noreply, reload_projects(socket)}
  end

  # === Helpers ===

  defp reload_projects(socket) do
    assign(socket, projects: Projects.list_projects())
  end

  defp nilify(""), do: nil
  defp nilify(val), do: val

  defp parse_comma_list(nil), do: []
  defp parse_comma_list(""), do: []
  defp parse_comma_list(str) do
    str |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
  end

  defp parse_repos(nil), do: []
  defp parse_repos(""), do: []
  defp parse_repos(str) do
    str
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn line ->
      case String.split(line, ":", parts: 2) do
        [name, full_name] -> %{"name" => String.trim(name), "full_name" => String.trim(full_name)}
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp format_repos(repos) when is_list(repos) do
    repos
    |> Enum.map(fn
      %{"name" => name, "full_name" => full_name} -> "#{name}:#{full_name}"
      _ -> ""
    end)
    |> Enum.join("\n")
  end
  defp format_repos(_), do: ""

  defp format_tech_stack(stack) when is_list(stack), do: Enum.join(stack, ", ")
  defp format_tech_stack(_), do: ""

  # === Render ===

  def render(assigns) do
    ~H"""
    <style>
      .admin-container {
        max-width: 1000px;
        margin: 40px auto;
        font-family: "Geneva", "Chicago", "Helvetica Neue", sans-serif;
        padding: 0 20px;
      }
      .admin-container h1 { font-size: 24px; margin-bottom: 20px; }
      .password-form {
        max-width: 300px; margin: 100px auto; text-align: center;
      }
      .password-form input {
        padding: 8px 12px; border: 1px solid #000; font-size: 14px;
        width: 200px; margin-bottom: 10px; display: block;
        margin-left: auto; margin-right: auto;
      }
      .password-form button {
        padding: 6px 20px; background: #000; color: #fff;
        border: none; cursor: pointer; font-size: 14px;
      }
      .project-row {
        display: flex; align-items: center; justify-content: space-between;
        padding: 8px 12px; border-bottom: 1px solid #eee; font-size: 13px;
        cursor: grab; user-select: none;
      }
      .project-row:hover { background: #f9f9f9; }
      .project-row:active { cursor: grabbing; }
      .project-row.dragging { opacity: 0.4; }
      .project-info { display: flex; align-items: center; gap: 10px; flex: 1; min-width: 0; }
      .drag-handle { color: #bbb; font-size: 16px; margin-right: 4px; }
      .project-order { width: 30px; text-align: center; color: #999; font-size: 11px; }
      .project-title { font-weight: bold; }
      .project-category {
        background: #e8e8e8; padding: 1px 6px; font-size: 10px; border-radius: 2px;
      }
      .project-path { color: #666; font-size: 11px; }
      .project-actions { display: flex; gap: 4px; align-items: center; flex-shrink: 0; }
      .btn {
        padding: 3px 8px; border: 1px solid #000; background: #fff;
        cursor: pointer; font-size: 11px; font-family: inherit;
      }
      .btn:hover { background: #f0f0f0; }
      .btn-danger { color: #c00; border-color: #c00; }
      .btn-danger:hover { background: #fee; }
      .btn-primary { background: #000; color: #fff; }
      .btn-primary:hover { background: #333; }
      .hidden-indicator { opacity: 0.4; }
      .project-list {
        border: 1px solid #000; background: #fff; margin-bottom: 20px;
      }
      .project-list-header {
        padding: 8px 12px; background: #eee; border-bottom: 1px solid #000;
        font-weight: bold; font-size: 14px;
        display: flex; justify-content: space-between; align-items: center;
      }
      .add-form {
        border: 1px solid #000; padding: 16px; margin-bottom: 16px; background: #fafafa;
      }
      .add-form label { display: block; font-size: 12px; font-weight: bold; margin-bottom: 2px; }
      .add-form input, .add-form textarea, .add-form select {
        display: block; width: 100%; padding: 4px 8px; border: 1px solid #ccc;
        font-size: 13px; margin-bottom: 10px; box-sizing: border-box; font-family: inherit;
      }
      .add-form textarea { min-height: 80px; resize: vertical; }
      .form-row { display: flex; gap: 12px; }
      .form-row > div { flex: 1; }
      .edit-modal {
        position: fixed; top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(0,0,0,0.4); display: flex;
        align-items: center; justify-content: center; z-index: 1000;
      }
      .edit-modal-content {
        background: #fff; border: 1px solid #000; padding: 20px;
        min-width: 500px; max-width: 650px; max-height: 90vh; overflow-y: auto;
      }
      .edit-modal-content h3 { margin-top: 0; margin-bottom: 16px; }
      .edit-modal-content label {
        display: block; font-size: 12px; margin-bottom: 2px; font-weight: bold;
      }
      .edit-modal-content input, .edit-modal-content textarea, .edit-modal-content select {
        display: block; width: 100%; padding: 4px 8px; border: 1px solid #ccc;
        font-size: 13px; margin-bottom: 10px; box-sizing: border-box; font-family: inherit;
      }
      .edit-modal-content textarea { min-height: 80px; resize: vertical; }
      .modal-actions {
        display: flex; gap: 8px; justify-content: flex-end; margin-top: 16px;
      }
    </style>

    <%= if !@authenticated do %>
      <div class="password-form">
        <h2>Museum Admin</h2>
        <form phx-submit="check_password">
          <input type="password" name="password" placeholder="Password" autofocus />
          <button type="submit">Enter</button>
        </form>
      </div>
    <% else %>
      <div class="admin-container">
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px;">
          <h1 style="margin: 0;">Museum Admin</h1>
          <div style="display: flex; gap: 8px;">
            <a href="/" class="btn">Back to Site</a>
            <a href="/admin/finder" class="btn">Finder Admin</a>
            <button class="btn btn-primary" phx-click="toggle_add_project">+ Project</button>
          </div>
        </div>

        <%!-- Add project form --%>
        <%= if @adding_project do %>
          <div class="add-form">
            <h3 style="margin-top: 0;">New Project</h3>
            <form phx-submit="save_new_project">
              <div class="form-row">
                <div>
                  <label>Slug</label>
                  <input type="text" name="slug" placeholder="my-project" required />
                </div>
                <div>
                  <label>Title</label>
                  <input type="text" name="title" placeholder="My Project" required />
                </div>
                <div>
                  <label>Category</label>
                  <select name="category">
                    <option value="tools">Tools</option>
                    <option value="ml">ML & AI</option>
                    <option value="music">Music</option>
                    <option value="social">Social</option>
                    <option value="maps">Maps</option>
                    <option value="writing">Writing</option>
                    <option value="hardware">Hardware</option>
                  </select>
                </div>
              </div>
              <label>Tagline</label>
              <input type="text" name="tagline" placeholder="Short description" />
              <label>Description</label>
              <textarea name="description" placeholder="Full description"></textarea>
              <div class="form-row">
                <div>
                  <label>Tech Stack (comma-separated)</label>
                  <input type="text" name="tech_stack" placeholder="Elixir, Rust, Python" />
                </div>
                <div>
                  <label>Internal Path</label>
                  <input type="text" name="internal_path" placeholder="/my-project" />
                </div>
                <div>
                  <label>External URL</label>
                  <input type="text" name="external_url" placeholder="https://..." />
                </div>
              </div>
              <label>GitHub Repos (one per line, format: name:owner/repo)</label>
              <textarea name="github_repos" placeholder="my_repo:username/my_repo"></textarea>
              <div style="display: flex; gap: 8px; margin-top: 8px;">
                <button type="submit" class="btn btn-primary">Create</button>
                <button type="button" class="btn" phx-click="toggle_add_project">Cancel</button>
              </div>
            </form>
          </div>
        <% end %>

        <%!-- Project list --%>
        <div class="project-list">
          <div class="project-list-header">
            <span><%= length(@projects) %> Projects</span>
            <span style="font-size: 11px; font-weight: normal; color: #888;">Drag rows to reorder</span>
          </div>
          <div id="sortable-projects" phx-hook="Sortable">
          <%= for project <- @projects do %>
            <div class={"project-row #{if !project.visible, do: "hidden-indicator"}"} draggable="true" data-sort-id={project.id}>
              <div class="project-info">
                <span class="drag-handle">&#9776;</span>
                <span class="project-order"><%= project.sort_order %></span>
                <span class="project-title"><%= project.title %></span>
                <span class="project-category"><%= project.category %></span>
                <%= if project.internal_path do %>
                  <span class="project-path"><%= project.internal_path %></span>
                <% end %>
                <%= if project.external_url do %>
                  <span class="project-path"><%= project.external_url %></span>
                <% end %>
                <%= if !project.visible do %>
                  <span class="project-path">[hidden]</span>
                <% end %>
              </div>
              <div class="project-actions">
                <button class="btn" phx-click="move_project" phx-value-id={project.id} phx-value-dir="up">&#9650;</button>
                <button class="btn" phx-click="move_project" phx-value-id={project.id} phx-value-dir="down">&#9660;</button>
                <button class="btn" phx-click="toggle_visibility" phx-value-id={project.id}>
                  <%= if project.visible, do: "Hide", else: "Show" %>
                </button>
                <button class="btn" phx-click="edit_project" phx-value-id={project.id}>Edit</button>
                <button class="btn btn-danger" phx-click="delete_project" phx-value-id={project.id} data-confirm="Delete this project?">Del</button>
              </div>
            </div>
          <% end %>
          </div>
        </div>

        <%!-- Edit Project Modal --%>
        <%= if @editing_project do %>
          <div class="edit-modal">
            <div class="edit-modal-content">
              <h3>Edit: <%= @editing_project.title %></h3>
              <form phx-submit="update_project">
                <div class="form-row">
                  <div>
                    <label>Slug</label>
                    <input type="text" name="slug" value={@editing_project.slug} required />
                  </div>
                  <div>
                    <label>Title</label>
                    <input type="text" name="title" value={@editing_project.title} required />
                  </div>
                </div>
                <div class="form-row">
                  <div>
                    <label>Category</label>
                    <select name="category">
                      <%= for cat <- ["tools", "ml", "music", "social", "maps", "writing", "hardware"] do %>
                        <option value={cat} selected={@editing_project.category == cat}><%= cat %></option>
                      <% end %>
                    </select>
                  </div>
                  <div>
                    <label>Visible</label>
                    <select name="visible">
                      <option value="true" selected={@editing_project.visible}>Yes</option>
                      <option value="false" selected={!@editing_project.visible}>No</option>
                    </select>
                  </div>
                </div>
                <label>Tagline</label>
                <input type="text" name="tagline" value={@editing_project.tagline || ""} />
                <label>Description</label>
                <textarea name="description"><%= @editing_project.description || "" %></textarea>
                <div class="form-row">
                  <div>
                    <label>Tech Stack (comma-separated)</label>
                    <input type="text" name="tech_stack" value={format_tech_stack(@editing_project.tech_stack)} />
                  </div>
                </div>
                <div class="form-row">
                  <div>
                    <label>Internal Path</label>
                    <input type="text" name="internal_path" value={@editing_project.internal_path || ""} />
                  </div>
                  <div>
                    <label>External URL</label>
                    <input type="text" name="external_url" value={@editing_project.external_url || ""} />
                  </div>
                </div>
                <label>GitHub Repos (one per line, format: name:owner/repo)</label>
                <textarea name="github_repos"><%= format_repos(@editing_project.github_repos) %></textarea>
                <div class="modal-actions">
                  <button type="button" class="btn" phx-click="cancel_edit">Cancel</button>
                  <button type="submit" class="btn btn-primary">Save</button>
                </div>
              </form>
            </div>
          </div>
        <% end %>
      </div>
    <% end %>
    """
  end
end
