/**
 * Where the walkthrough points, and the one rule about it.
 *
 * A walkthrough clicks real buttons and fills real forms, so by default it
 * only ever talks to a server on this machine. Pointing it anywhere else needs
 * WALKTHROUGH_ALLOW_REMOTE=1 as an explicit, per-run decision.
 */
const LOCAL_HOSTS = new Set(["localhost", "127.0.0.1", "[::1]", "0.0.0.0"]);

export function baseURL(defaultURL: string): string {
  return process.env.WALKTHROUGH_BASE_URL ?? defaultURL;
}

export function enforceLocalGuardrail(url: string): void {
  const host = new URL(url).hostname;
  if (LOCAL_HOSTS.has(host)) return;
  if (process.env.WALKTHROUGH_ALLOW_REMOTE === "1") {
    process.stderr.write(
      `walkthrough: running against ${url}; everything it does there is real\n`,
    );
    return;
  }
  throw new Error(
    `Refusing to run against ${url}: walkthroughs only run against localhost. ` +
      "Set WALKTHROUGH_ALLOW_REMOTE=1 if you really mean it.",
  );
}
