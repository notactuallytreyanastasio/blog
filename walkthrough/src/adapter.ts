/**
 * What an app has to tell the runner about itself. Everything is optional
 * except the URL; the defaults suit a Phoenix LiveView app with no login.
 *
 * The runner never imports app code and never touches a database. If a
 * workflow needs data or a session, the adapter's `prepare` makes it (through
 * the app's own HTTP endpoints, a shell command, a login form) and hands back
 * the values the steps refer to as {{var.<name>}}.
 */
import type { APIRequestContext, Page } from "@playwright/test";
import type { LoadedWorkflow } from "./workflow";

export type PrepareContext = {
  page: Page;
  request: APIRequestContext;
  workflow: LoadedWorkflow;
  /** The run's output folder, for anything worth keeping. */
  runDir: string;
};

export type Adapter = {
  /** Where the app is. Overridden by WALKTHROUGH_BASE_URL. */
  baseURL: string;
  /**
   * Runs once, before the first step. Returns values for {{var.*}}; they win
   * over the workflow's own `vars` on a clash.
   */
  prepare?: (ctx: PrepareContext) => Promise<Record<string, unknown>>;
  /** Runs once after the last step, pass or fail. */
  cleanup?: (ctx: PrepareContext) => Promise<void>;
  /** Waits for the app to finish rendering after an action. */
  settle?: (page: Page, timeoutMs: number) => Promise<void>;
  /**
   * Checked after every step. Return a message if the app is in a broken
   * state the watcher might not notice (a crashed view, a lost socket).
   */
  crashed?: (page: Page) => Promise<string | null>;
};
