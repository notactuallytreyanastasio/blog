defmodule BlogWeb.TermsLive do
  use BlogWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Terms & Conditions")
     |> assign(:page_description, "Terms and conditions for using Very Direct Messages and other services on this site.")}
  end

  def render(assigns) do
    ~H"""
    <div class="os-desktop-osx">
      <div class="os-window os-window-osx" style="width: 100%; max-width: none;">
        <div class="os-titlebar">
          <div class="os-titlebar-buttons">
            <a href="/" class="os-btn-close"></a>
            <span class="os-btn-min"></span>
            <span class="os-btn-max"></span>
          </div>
          <span class="os-titlebar-title">Terms & Conditions</span>
          <div class="os-titlebar-spacer"></div>
        </div>
        <div class="os-content" style="overflow-y: auto; background: #1a1a2e;">
          <div class="p-8 max-w-3xl mx-auto text-gray-200">
            <h1 class="text-3xl font-bold mb-2 text-white">Terms & Conditions</h1>
            <p class="text-sm text-gray-400 mb-8">Last updated: February 12, 2026</p>

            <h2 class="text-xl font-bold mt-8 mb-3 text-white">Very Direct Messages</h2>
            <p class="mb-4">
              By using the Very Direct Message service, you agree to the following:
            </p>
            <ul class="list-disc list-inside mb-4 space-y-2">
              <li>You will not send anything hurtful, offensive, threatening, or mean.</li>
              <li>You will not send illegal content, spam, or anything you wouldn't want printed on a receipt and left on someone's desk.</li>
              <li>You understand that your message will be physically printed on a receipt printer on Bobby's desk in New York City.</li>
              <li>You understand that your IP address is collected for abuse prevention purposes.</li>
            </ul>

            <h2 class="text-xl font-bold mt-8 mb-3 text-white">Consequences</h2>
            <p class="mb-4">
              If anyone sends anything that violates the above, the entire service will be shut off for everyone. Please don't ruin it.
            </p>

            <h2 class="text-xl font-bold mt-8 mb-3 text-white">No Guarantees</h2>
            <p class="mb-4">
              This is a fun personal project. There is no guarantee that your message will be printed, that the printer will be on, or that the service will be available at any given time. Bobby might be asleep, the printer might be out of paper, or the internet might be having a bad day.
            </p>

            <h2 class="text-xl font-bold mt-8 mb-3 text-white">Everything Else</h2>
            <p class="mb-4">
              This is a personal blog and collection of weird projects. Nothing on this site constitutes professional advice. Use everything at your own risk and have fun.
            </p>

            <div class="mt-8 pt-6 border-t border-gray-700 flex gap-6">
              <a href="/very_direct_message" class="text-blue-400 hover:text-blue-300 underline">
                &larr; Back to Very Direct Messages
              </a>
              <a href="/privacy" class="text-blue-400 hover:text-blue-300 underline">
                Privacy Policy
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
