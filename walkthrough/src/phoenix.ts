/**
 * Default `settle` and `crashed` hooks, written for Phoenix LiveView but
 * harmless anywhere else: a page with no LiveView passes straight through.
 *
 * LiveView round-trips are asynchronous. After an action, wait until the
 * socket is connected and no phx-*-loading class is left, so the watcher sees
 * each result land before the next step starts.
 */
import type { Page } from "@playwright/test";

export async function settleLiveView(
  page: Page,
  timeout: number,
): Promise<void> {
  await page
    .waitForLoadState("domcontentloaded", { timeout })
    .catch(() => undefined);
  await page
    .waitForFunction(
      () => {
        const main = document.querySelector("[data-phx-main]");
        if (main && !main.classList.contains("phx-connected")) return false;
        return !document.querySelector(
          ".phx-click-loading, .phx-submit-loading, .phx-change-loading",
        );
      },
      null,
      { timeout },
    )
    .catch(() => undefined);
}

/** A LiveView that crashed or lost its socket wears `phx-error`. */
export async function liveViewCrashed(page: Page): Promise<string | null> {
  const crashed = await page
    .evaluate(
      () => document.querySelector("[data-phx-main].phx-error") !== null,
    )
    .catch(() => false);
  return crashed ? "LiveView is in an error state (crashed or disconnected)" : null;
}
