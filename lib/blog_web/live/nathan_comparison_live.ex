defmodule BlogWeb.NathanComparisonLive do
  use BlogWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    available_articles = [
      %{id: "original", name: "Original", url: "/nathan"},
      %{id: "harpers", name: "Harper's", url: "/nathan_harpers"},
      %{id: "teen_vogue", name: "Teen Vogue", url: "/nathan_teen_vogue"},
      %{id: "usenet", name: "Linus Reaction", url: "/nathan_usenet"},
      %{id: "content_farm", name: "Content Farm", url: "/nathan_content_farm"}
    ]

    # Default selection: original, harpers, teen vogue
    default_selected_ids = ["original", "harpers", "teen_vogue"]
    selected_articles = Enum.filter(available_articles, &(&1.id in default_selected_ids))

    socket = 
      socket
      |> assign(:available_articles, available_articles)
      |> assign(:selected_articles, selected_articles)
      |> assign(:selected_ids, default_selected_ids)
      |> assign(:page_title, "Nathan Fielder Article Comparison")

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_article", %{"article_id" => article_id}, socket) do
    current_selected = socket.assigns.selected_ids
    
    updated_selected_ids = if article_id in current_selected do
      List.delete(current_selected, article_id)
    else
      # Limit to maximum of 3 selections
      if length(current_selected) >= 3 do
        # Replace the first selected item with the new one
        [article_id | Enum.drop(current_selected, -1)]
      else
        [article_id | current_selected]
      end
    end
    
    # Get the actual article objects for the selected IDs
    selected_articles = 
      updated_selected_ids
      |> Enum.map(fn id -> 
        Enum.find(socket.assigns.available_articles, &(&1.id == id))
      end)
      |> Enum.filter(& &1)  # Remove any nils
    
    socket = 
      socket
      |> assign(:selected_articles, selected_articles)
      |> assign(:selected_ids, updated_selected_ids)
    
    {:noreply, socket}
  end
end