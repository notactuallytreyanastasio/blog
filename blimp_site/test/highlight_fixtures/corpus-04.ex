  def render(assigns) do
    ~H"""
    <.head_tags meta_attrs={@meta_attrs} page_title={@page_title} />
    <div class="mt-4 text-gray-500">
      Cursor position: <%= @cursor %>
    </div>
    <div class="p-4" phx-window-keydown="keydown">
      <div class="space-y-4">
        <%= for {tweet, index} <- Enum.with_index(@visible_tweets) do %>
          <div class={"p-4 border rounded #{if index == 2, do: 'bg-blue-100'}"}>
            <%= tweet %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end