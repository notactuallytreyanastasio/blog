# defmodule BlogWeb.FakeTweetsLive do
#   use Phoenix.LiveView
#   import Blog.Social
#
#   @update_interval 90_000
#
#   def render(assigns) do
#     ~L"""
#     <h1>Fake Tweets</h1>
#     <div>
#       <div>
#         <%= for tweet <- @tweets do %>
#           <div><%= tweet %></div>
#           <br/>
#         <% end %>
#       </div>
#     </div>
#     """
#   end
#
#   def mount(_params, _session, socket) do
#     {:ok, schedule_tweet_generation(socket)}
#   end
#
#   def handle_info(:generate, socket) do
#     tweets = Enum.map(1..5, fn _ -> generate_markov_tweet() end)
#     {:noreply, assign(socket, :tweets, tweets)}
#   end
#
#   defp schedule_tweet_generation(socket) do
#     Process.send_after(self(), :generate, @update_interval)
#     assign(socket, :tweets, Enum.map(1..5, fn _ -> generate_markov_tweet() end))
#   end
# end
#
