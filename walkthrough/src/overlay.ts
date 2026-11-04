/**
 * On-screen narration for a watched run: a banner saying which step is running
 * and how it went, and an outline on the element about to be acted on.
 *
 * The banner state lives in sessionStorage and an init script re-draws it on
 * every document, so it survives full page loads as well as in-place DOM
 * patches (LiveView, htmx, a SPA router). It is attached to <html>, outside
 * any app container, and ignores pointer events so it can never intercept a
 * click.
 */
import type { Locator, Page } from "@playwright/test";

export type BannerStatus = "running" | "passed" | "failed" | "info";

export type BannerState = {
  title: string;
  step: string;
  detail?: string;
  status: BannerStatus;
};

const STORAGE_KEY = "__walkthrough_banner";

// Runs in the browser. Kept self-contained: it is serialised into the page.
function installBanner(storageKey: string) {
  const colours: Record<string, string> = {
    running: "#2563eb",
    passed: "#16a34a",
    failed: "#dc2626",
    info: "#7c3aed",
  };

  const draw = () => {
    const raw = window.sessionStorage.getItem(storageKey);
    let banner = document.getElementById("__walkthrough-banner");
    if (!raw) {
      banner?.remove();
      return;
    }
    const state = JSON.parse(raw) as {
      title: string;
      step: string;
      detail?: string;
      status: string;
    };
    if (!banner) {
      banner = document.createElement("div");
      banner.id = "__walkthrough-banner";
      document.documentElement.appendChild(banner);
    }
    Object.assign(banner.style, {
      position: "fixed",
      left: "16px",
      bottom: "16px",
      zIndex: "2147483647",
      maxWidth: "560px",
      padding: "12px 16px",
      borderRadius: "8px",
      borderLeft: `6px solid ${colours[state.status] ?? colours.info}`,
      background: "rgba(17, 24, 39, 0.92)",
      color: "#fff",
      font: "14px/1.4 system-ui, sans-serif",
      boxShadow: "0 4px 16px rgba(0,0,0,0.3)",
      pointerEvents: "none",
      whiteSpace: "pre-wrap",
    });
    banner.textContent = "";
    const title = document.createElement("div");
    title.style.cssText = "font-size:11px;opacity:0.7;text-transform:uppercase";
    title.textContent = state.title;
    const step = document.createElement("div");
    step.style.cssText = "font-weight:600;margin-top:2px";
    step.textContent = state.step;
    banner.append(title, step);
    if (state.detail) {
      const detail = document.createElement("div");
      detail.style.cssText = "margin-top:4px;opacity:0.85";
      detail.textContent = state.detail;
      banner.append(detail);
    }
  };

  (window as unknown as Record<string, unknown>).__walkthroughDraw = draw;
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", draw);
  } else {
    draw();
  }
}

export async function installOverlay(page: Page): Promise<void> {
  await page.addInitScript(installBanner, STORAGE_KEY);
}

export async function showBanner(
  page: Page,
  state: BannerState,
): Promise<void> {
  // A navigation can be in flight; the init script draws it on the next page.
  await page
    .evaluate(
      ([key, value]) => {
        window.sessionStorage.setItem(key, value);
        const draw = (window as unknown as Record<string, unknown>)
          .__walkthroughDraw;
        if (typeof draw === "function") draw();
      },
      [STORAGE_KEY, JSON.stringify(state)] as const,
    )
    .catch(() => undefined);
}

/** Outlines the element the next action will touch, then removes the outline. */
export async function highlight(locator: Locator, ms: number): Promise<void> {
  if (ms <= 0) return;
  await locator.scrollIntoViewIfNeeded().catch(() => undefined);
  const applied = await locator
    .evaluate((el) => {
      const html = el as HTMLElement;
      const previous = [html.style.outline, html.style.outlineOffset];
      html.style.outline = "3px solid #f59e0b";
      html.style.outlineOffset = "2px";
      return previous;
    })
    .catch(() => null);
  if (!applied) return;
  await locator.page().waitForTimeout(ms);
  await locator
    .evaluate((el, [outline, offset]) => {
      const html = el as HTMLElement;
      html.style.outline = outline;
      html.style.outlineOffset = offset;
    }, applied)
    .catch(() => undefined);
}
