defmodule BlogWeb.FinderAdminLive do
  use BlogWeb, :live_view
  alias Blog.Finder

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       authenticated: false,
       sections: [],
       editing_section: nil,
       editing_item: nil,
       adding_section: false,
       adding_item_to: nil
     )}
  end

  # === Event Handlers ===

  def handle_event("check_password", %{"password" => password}, socket) do
    expected = Application.get_env(:blog, :finder_admin_password)

    if password == expected do
      {:noreply, socket |> assign(authenticated: true) |> reload_sections()}
    else
      {:noreply, put_flash(socket, :error, "Wrong password")}
    end
  end

  # -- Sections --

  def handle_event("toggle_add_section", _, socket) do
    {:noreply, assign(socket, adding_section: !socket.assigns.adding_section)}
  end

  def handle_event("save_new_section", %{"name" => name, "label" => label}, socket) do
    max_order =
      socket.assigns.sections
      |> Enum.map(& &1.sort_order)
      |> Enum.max(fn -> -1 end)

    case Finder.create_section(%{name: name, label: nilify(label), sort_order: max_order + 1}) do
      {:ok, _} -> {:noreply, socket |> assign(adding_section: false) |> reload_sections()}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Failed to create section")}
    end
  end

  def handle_event("edit_section", %{"id" => id}, socket) do
    section = Finder.get_section!(String.to_integer(id))
    {:noreply, assign(socket, editing_section: section)}
  end

  def handle_event("cancel_edit_section", _, socket) do
    {:noreply, assign(socket, editing_section: nil)}
  end

  def handle_event("update_section", params, socket) do
    section = socket.assigns.editing_section

    attrs = %{
      name: params["name"],
      label: nilify(params["label"]),
      joyride_target: nilify(params["joyride_target"]),
      visible: params["visible"] == "true"
    }

    case Finder.update_section(section, attrs) do
      {:ok, _} -> {:noreply, socket |> assign(editing_section: nil) |> reload_sections()}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Failed to update section")}
    end
  end

  def handle_event("delete_section", %{"id" => id}, socket) do
    section = Finder.get_section!(String.to_integer(id))
    Finder.delete_section(section)
    {:noreply, reload_sections(socket)}
  end

  def handle_event("move_section", %{"id" => id, "dir" => dir}, socket) do
    direction = String.to_existing_atom(dir)
    Finder.reorder_section(String.to_integer(id), direction)
    {:noreply, reload_sections(socket)}
  end

  def handle_event("toggle_section_visibility", %{"id" => id}, socket) do
    section = Finder.get_section!(String.to_integer(id))
    Finder.update_section(section, %{visible: !section.visible})
    {:noreply, reload_sections(socket)}
  end

  # -- Items --

  def handle_event("toggle_add_item", %{"section-id" => section_id}, socket) do
    sid = String.to_integer(section_id)
    current = socket.assigns.adding_item_to

    {:noreply,
     assign(socket, adding_item_to: if(current == sid, do: nil, else: sid))}
  end

  def handle_event("save_new_item", params, socket) do
    section_id = String.to_integer(params["section_id"])
    section = Finder.get_section!(section_id)

    max_order =
      section.items
      |> Enum.map(& &1.sort_order)
      |> Enum.max(fn -> -1 end)

    attrs = %{
      name: params["name"],
      icon: params["icon"],
      path: nilify(params["path"]),
      action: nilify(params["action"]),
      description: nilify(params["description"]),
      sort_order: max_order + 1,
      section_id: section_id
    }

    case Finder.create_item(attrs) do
      {:ok, _} -> {:noreply, socket |> assign(adding_item_to: nil) |> reload_sections()}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Failed to create item")}
    end
  end

  def handle_event("edit_item", %{"id" => id}, socket) do
    item = Finder.get_item!(String.to_integer(id))
    {:noreply, assign(socket, editing_item: item)}
  end

  def handle_event("cancel_edit_item", _, socket) do
    {:noreply, assign(socket, editing_item: nil)}
  end

  def handle_event("update_item", params, socket) do
    item = socket.assigns.editing_item

    attrs = %{
      name: params["name"],
      icon: params["icon"],
      path: nilify(params["path"]),
      action: nilify(params["action"]),
      description: nilify(params["description"]),
      joyride_target: nilify(params["joyride_target"]),
      visible: params["visible"] == "true"
    }

    case Finder.update_item(item, attrs) do
      {:ok, _} -> {:noreply, socket |> assign(editing_item: nil) |> reload_sections()}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Failed to update item")}
    end
  end

  def handle_event("delete_item", %{"id" => id}, socket) do
    item = Finder.get_item!(String.to_integer(id))
    Finder.delete_item(item)
    {:noreply, reload_sections(socket)}
  end

  def handle_event("move_item", %{"id" => id, "dir" => dir}, socket) do
    direction = String.to_existing_atom(dir)
    Finder.reorder_item(String.to_integer(id), direction)
    {:noreply, reload_sections(socket)}
  end

  def handle_event("toggle_item_visibility", %{"id" => id}, socket) do
    item = Finder.get_item!(String.to_integer(id))
    Finder.update_item(item, %{visible: !item.visible})
    {:noreply, reload_sections(socket)}
  end

  # === Helpers ===

  defp reload_sections(socket) do
    assign(socket, sections: Finder.list_sections())
  end

  defp nilify(""), do: nil
  defp nilify(val), do: val

  # === Render ===

  def render(assigns) do
    ~H"""
    <style>
      .admin-container {
        max-width: 900px;
        margin: 40px auto;
        font-family: "Geneva", "Chicago", "Helvetica Neue", sans-serif;
        padding: 0 20px;
      }
      .admin-container h1 {
        font-size: 24px;
        margin-bottom: 20px;
      }
      .password-form {
        max-width: 300px;
        margin: 100px auto;
        text-align: center;
      }
      .password-form input {
        padding: 8px 12px;
        border: 1px solid #000;
        font-size: 14px;
        width: 200px;
        margin-bottom: 10px;
        display: block;
        margin-left: auto;
        margin-right: auto;
      }
      .password-form button {
        padding: 6px 20px;
        background: #000;
        color: #fff;
        border: none;
        cursor: pointer;
        font-size: 14px;
      }
      .section-card {
        border: 1px solid #000;
        margin-bottom: 16px;
        background: #fff;
      }
      .section-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 8px 12px;
        background: #eee;
        border-bottom: 1px solid #000;
      }
      .section-header .section-name {
        font-weight: bold;
        font-size: 14px;
      }
      .section-header .section-meta {
        font-size: 11px;
        color: #666;
        margin-left: 8px;
      }
      .section-actions {
        display: flex;
        gap: 6px;
        align-items: center;
      }
      .btn {
        padding: 3px 8px;
        border: 1px solid #000;
        background: #fff;
        cursor: pointer;
        font-size: 11px;
        font-family: inherit;
      }
      .btn:hover { background: #f0f0f0; }
      .btn-danger { color: #c00; border-color: #c00; }
      .btn-danger:hover { background: #fee; }
      .btn-primary { background: #000; color: #fff; }
      .btn-primary:hover { background: #333; }
      .hidden-indicator { opacity: 0.4; }
      .item-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 6px 12px;
        border-bottom: 1px solid #eee;
        font-size: 13px;
      }
      .item-row:last-child { border-bottom: none; }
      .item-info {
        display: flex;
        align-items: center;
        gap: 8px;
      }
      .item-icon { font-size: 18px; }
      .item-path { color: #666; font-size: 11px; }
      .item-action-tag {
        background: #ffe0b2;
        padding: 1px 6px;
        border-radius: 3px;
        font-size: 10px;
      }
      .item-actions {
        display: flex;
        gap: 4px;
        align-items: center;
      }
      .add-form {
        padding: 12px;
        background: #fafafa;
        border-top: 1px solid #ddd;
      }
      .add-form input {
        padding: 4px 8px;
        border: 1px solid #ccc;
        font-size: 12px;
        margin-right: 6px;
        margin-bottom: 6px;
      }
      .edit-modal {
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(0,0,0,0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
      }
      .edit-modal-content {
        background: #fff;
        border: 1px solid #000;
        padding: 20px;
        min-width: 350px;
        max-width: 500px;
      }
      .edit-modal-content h3 {
        margin-top: 0;
        margin-bottom: 16px;
      }
      .edit-modal-content label {
        display: block;
        font-size: 12px;
        margin-bottom: 2px;
        font-weight: bold;
      }
      .edit-modal-content input, .edit-modal-content select {
        display: block;
        width: 100%;
        padding: 4px 8px;
        border: 1px solid #ccc;
        font-size: 13px;
        margin-bottom: 10px;
        box-sizing: border-box;
      }
      .edit-modal-content .modal-actions {
        display: flex;
        gap: 8px;
        justify-content: flex-end;
        margin-top: 16px;
      }
      .add-section-form {
        border: 1px solid #000;
        padding: 12px;
        margin-bottom: 16px;
        background: #fafafa;
      }
    </style>

    <%= if !@authenticated do %>
      <div class="password-form">
        <h2>Finder Admin</h2>
        <form phx-submit="check_password">
          <input type="password" name="password" placeholder="Password" autofocus />
          <button type="submit">Enter</button>
        </form>
      </div>
    <% else %>
      <div class="admin-container">
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px;">
          <h1 style="margin: 0;">Finder Admin</h1>
          <div style="display: flex; gap: 8px;">
            <a href="/" class="btn">Back to Site</a>
            <button class="btn btn-primary" phx-click="toggle_add_section">+ Section</button>
          </div>
        </div>

        <%!-- Add section form --%>
        <%= if @adding_section do %>
          <div class="add-section-form">
            <form phx-submit="save_new_section">
              <input type="text" name="name" placeholder="Section name (e.g. games)" required />
              <input type="text" name="label" placeholder="Display label (optional)" />
              <button type="submit" class="btn btn-primary">Create</button>
              <button type="button" class="btn" phx-click="toggle_add_section">Cancel</button>
            </form>
          </div>
        <% end %>

        <%!-- Sections list --%>
        <%= for section <- @sections do %>
          <div class={"section-card #{if !section.visible, do: "hidden-indicator"}"}>
            <div class="section-header">
              <div>
                <span class="section-name"><%= section.name %></span>
                <span class="section-meta">
                  <%= if section.label, do: "(#{section.label})" %>
                  &middot; <%= length(section.items) %> items
                  &middot; order: <%= section.sort_order %>
                  <%= if !section.visible, do: " [hidden]" %>
                </span>
              </div>
              <div class="section-actions">
                <button class="btn" phx-click="move_section" phx-value-id={section.id} phx-value-dir="up">&#9650;</button>
                <button class="btn" phx-click="move_section" phx-value-id={section.id} phx-value-dir="down">&#9660;</button>
                <button class="btn" phx-click="toggle_section_visibility" phx-value-id={section.id}>
                  <%= if section.visible, do: "Hide", else: "Show" %>
                </button>
                <button class="btn" phx-click="edit_section" phx-value-id={section.id}>Edit</button>
                <button class="btn btn-danger" phx-click="delete_section" phx-value-id={section.id} data-confirm="Delete this section and all its items?">Del</button>
              </div>
            </div>

            <%!-- Items in this section --%>
            <div>
              <%= for item <- section.items do %>
                <div class={"item-row #{if !item.visible, do: "hidden-indicator"}"}>
                  <div class="item-info">
                    <span class="item-icon"><%= item.icon %></span>
                    <span><%= item.name %></span>
                    <%= if item.path do %>
                      <span class="item-path"><%= item.path %></span>
                    <% end %>
                    <%= if item.action do %>
                      <span class="item-action-tag"><%= item.action %></span>
                    <% end %>
                    <%= if !item.visible do %>
                      <span class="item-path">[hidden]</span>
                    <% end %>
                  </div>
                  <div class="item-actions">
                    <button class="btn" phx-click="move_item" phx-value-id={item.id} phx-value-dir="up">&#9650;</button>
                    <button class="btn" phx-click="move_item" phx-value-id={item.id} phx-value-dir="down">&#9660;</button>
                    <button class="btn" phx-click="toggle_item_visibility" phx-value-id={item.id}>
                      <%= if item.visible, do: "Hide", else: "Show" %>
                    </button>
                    <button class="btn" phx-click="edit_item" phx-value-id={item.id}>Edit</button>
                    <button class="btn btn-danger" phx-click="delete_item" phx-value-id={item.id} data-confirm="Delete this item?">Del</button>
                  </div>
                </div>
              <% end %>
            </div>

            <%!-- Add item --%>
            <%= if @adding_item_to == section.id do %>
              <div class="add-form">
                <form phx-submit="save_new_item">
                  <input type="hidden" name="section_id" value={section.id} />
                  <input type="text" name="name" placeholder="Name" required />
                  <input type="text" name="icon" placeholder="Emoji icon" required />
                  <input type="text" name="path" placeholder="Path (e.g. /pong)" />
                  <input type="text" name="action" placeholder="Action (e.g. toggle_phish)" />
                  <input type="text" name="description" placeholder="Tooltip description" />
                  <button type="submit" class="btn btn-primary">Add</button>
                  <button type="button" class="btn" phx-click="toggle_add_item" phx-value-section-id={section.id}>Cancel</button>
                </form>
              </div>
            <% else %>
              <div style="padding: 6px 12px; border-top: 1px solid #eee;">
                <button class="btn" phx-click="toggle_add_item" phx-value-section-id={section.id}>+ Item</button>
              </div>
            <% end %>
          </div>
        <% end %>

        <%!-- Edit Section Modal --%>
        <%= if @editing_section do %>
          <div class="edit-modal">
            <div class="edit-modal-content">
              <h3>Edit Section</h3>
              <form phx-submit="update_section">
                <label>Name</label>
                <input type="text" name="name" value={@editing_section.name} required />
                <label>Label (display)</label>
                <input type="text" name="label" value={@editing_section.label || ""} />
                <label>Joyride Target</label>
                <input type="text" name="joyride_target" value={@editing_section.joyride_target || ""} />
                <label>Visible</label>
                <select name="visible">
                  <option value="true" selected={@editing_section.visible}>Yes</option>
                  <option value="false" selected={!@editing_section.visible}>No</option>
                </select>
                <div class="modal-actions">
                  <button type="button" class="btn" phx-click="cancel_edit_section">Cancel</button>
                  <button type="submit" class="btn btn-primary">Save</button>
                </div>
              </form>
            </div>
          </div>
        <% end %>

        <%!-- Edit Item Modal --%>
        <%= if @editing_item do %>
          <div class="edit-modal">
            <div class="edit-modal-content">
              <h3>Edit Item</h3>
              <form phx-submit="update_item">
                <label>Name</label>
                <input type="text" name="name" value={@editing_item.name} required />
                <label>Icon (emoji)</label>
                <input type="text" name="icon" value={@editing_item.icon} required />
                <label>Path</label>
                <input type="text" name="path" value={@editing_item.path || ""} />
                <label>Action</label>
                <input type="text" name="action" value={@editing_item.action || ""} />
                <label>Description (tooltip)</label>
                <input type="text" name="description" value={@editing_item.description || ""} />
                <label>Joyride Target</label>
                <input type="text" name="joyride_target" value={@editing_item.joyride_target || ""} />
                <label>Visible</label>
                <select name="visible">
                  <option value="true" selected={@editing_item.visible}>Yes</option>
                  <option value="false" selected={!@editing_item.visible}>No</option>
                </select>
                <div class="modal-actions">
                  <button type="button" class="btn" phx-click="cancel_edit_item">Cancel</button>
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
