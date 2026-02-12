defmodule BlogWeb.PrivacyLive do
  use BlogWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Privacy Policy")
     |> assign(:page_description, "Privacy policy for Very Direct Messages and other services on this site.")}
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
          <span class="os-titlebar-title">Privacy Policy</span>
          <div class="os-titlebar-spacer"></div>
        </div>
        <div class="os-content" style="overflow-y: auto; background: #1a1a2e;">
          <div class="p-8 max-w-3xl mx-auto text-gray-200">
            <h1 class="text-3xl font-bold mb-2 text-white">Privacy Policy</h1>
            <p class="text-sm text-gray-400 mb-8">Last updated: February 12, 2026</p>

            <h2 class="text-xl font-bold mt-8 mb-3 text-white">Very Direct Messages</h2>
            <p class="mb-4">
              When you send a Very Direct Message through this site, the following happens:
            </p>
            <ul class="list-disc list-inside mb-4 space-y-2">
              <li>Your message text and any attached image are sent directly to a receipt printer on Bobby's desk in New York City.</li>
              <li>Your IP address is collected solely to identify the source of messages in case of abuse.</li>
              <li><strong class="text-white">No information is retained.</strong> Messages are printed and then gone. They are not stored, logged, analyzed, sold, or shared with anyone.</li>
              <li>No cookies, tracking pixels, or analytics are used in connection with the messaging service.</li>
            </ul>

            <h2 class="text-xl font-bold mt-8 mb-3 text-white">Abuse Prevention</h2>
            <p class="mb-4">
              If someone sends something hurtful, offensive, or mean, the service will be shut off entirely. IP addresses may be reviewed in the event of abuse, but are not monitored or stored beyond what is necessary for the message to be delivered.
            </p>

            <h2 class="text-xl font-bold mt-8 mb-3 text-white">General Site Usage</h2>
            <p class="mb-4">
              This site does not use third-party analytics, advertising, or tracking services. No personal data is collected from general browsing.
            </p>

            <h2 class="text-xl font-bold mt-8 mb-3 text-white">Contact</h2>
            <p class="mb-4">
              If you have questions about this policy, you can send a Very Direct Message. It will print on the receipt printer.
            </p>

            <div class="mt-8 pt-6 border-t border-gray-700">
              <a href="/very_direct_message" class="text-blue-400 hover:text-blue-300 underline">
                &larr; Back to Very Direct Messages
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
