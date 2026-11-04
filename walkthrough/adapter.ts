/**
 * This app's adapter. The runner reads only this file about the app.
 *
 * bobbby.online is a Phoenix LiveView app with no login on its public pages,
 * so the defaults do: LiveView-aware settle, LiveView crash detection, no
 * prepare step. Pages under /admin take a password; put it in the environment
 * and refer to it from a workflow as {{env.FINDER_ADMIN_PASSWORD}} rather than
 * writing it into a file.
 */
import type { Adapter } from "./src/adapter";
import { baseURL } from "./src/environment";

export const adapter: Adapter = {
  baseURL: baseURL("http://localhost:4000"),
};
