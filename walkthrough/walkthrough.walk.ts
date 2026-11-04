/**
 * Runs one workflow file in a visible browser, at human pace, for someone to
 * watch. Skips itself unless WALKTHROUGH_FILE is set.
 *
 *   WALKTHROUGH_FILE=workflows/read_a_post.json npm run walk
 *
 * The app it drives, and how to get it ready, is described in ./adapter.ts.
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { expect, test } from "@playwright/test";
import { adapter } from "./adapter";
import { enforceLocalGuardrail } from "./src/environment";
import { installOverlay } from "./src/overlay";
import { writeReport } from "./src/report";
import { slug, WalkthroughRunner } from "./src/runner";
import { applyVars, loadWorkflow, resolvePace } from "./src/workflow";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const workflowFile = process.env.WALKTHROUGH_FILE;

test.describe.configure({ mode: "serial", retries: 0 });

test.skip(
  !workflowFile,
  "Set WALKTHROUGH_FILE to a workflow JSON file to run a walkthrough",
);

test("walkthrough", async ({ page, request }) => {
  test.setTimeout(0);
  enforceLocalGuardrail(adapter.baseURL);

  const workflow = loadWorkflow(workflowFile as string);
  const pace = resolvePace(workflow, process.env.WALKTHROUGH_PACE);
  const runDir = path.join(
    process.env.WALKTHROUGH_OUT ?? path.join(__dirname, "runs"),
    `${new Date().toISOString().replace(/[:.]/g, "-")}-${slug(workflow.name)}`,
  );
  fs.mkdirSync(runDir, { recursive: true });

  const ctx = { page, request, workflow, runDir };
  await installOverlay(page);
  const runner = new WalkthroughRunner(page, workflow, {
    pace,
    runDir,
    holdOnFailureMs: Number(process.env.WALKTHROUGH_HOLD_MS ?? 15_000),
    adapter,
  });

  const prepared = adapter.prepare ? await adapter.prepare(ctx) : {};
  const steps = applyVars(workflow.steps, { ...workflow.vars, ...prepared });

  let results;
  try {
    results = await runner.run(steps);
  } finally {
    if (adapter.cleanup) await adapter.cleanup(ctx);
  }

  const reportPath = writeReport(runDir, workflow, results);
  process.stdout.write(`\nReport: ${reportPath}\n`);

  const failed = results.filter((r) => r.status === "failed");
  await runner.banner(
    "Done",
    failed.length === 0
      ? `All ${results.length} steps passed`
      : `${failed.length} of ${results.length} steps failed`,
    failed.length === 0 ? "passed" : "failed",
  );
  // Leave the final screen up long enough to read before the browser closes.
  await page.waitForTimeout(
    Number(process.env.WALKTHROUGH_END_HOLD_MS ?? 4000),
  );

  expect(
    failed.map((r) => `${r.index}. ${r.do}: ${r.failures.join("; ")}`),
    `walkthrough failed; see ${reportPath}`,
  ).toEqual([]);
});
