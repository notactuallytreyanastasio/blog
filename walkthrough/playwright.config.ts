import { defineConfig, devices } from "@playwright/test";
import { adapter } from "./adapter";

/**
 * One project, one spec, one worker. A walkthrough is watched, so nothing
 * runs in parallel and nothing is retried; a failed step stays on screen.
 */
export default defineConfig({
  testDir: ".",
  testMatch: ["**/*.walk.ts"],
  testIgnore: ["**/node_modules/**", "**/runs/**"],
  workers: 1,
  retries: 0,
  timeout: 0,
  reporter: [["list"]],
  use: {
    ...devices["Desktop Chrome"],
    baseURL: adapter.baseURL,
    headless: process.env.WALKTHROUGH_HEADLESS === "1",
    viewport: { width: 1440, height: 900 },
    launchOptions: {
      slowMo: Number(process.env.WALKTHROUGH_SLOWMO ?? 150),
    },
    trace: "off",
    screenshot: "off",
  },
});
