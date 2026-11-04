import fs from "fs";
import path from "path";
import type { StepResult } from "./runner";
import type { LoadedWorkflow } from "./workflow";

/** Writes report.json and a readable report.md into the run directory. */
export function writeReport(
  runDir: string,
  workflow: LoadedWorkflow,
  results: StepResult[],
): string {
  const passed = results.filter((r) => r.status === "passed").length;
  const failed = results.filter((r) => r.status === "failed").length;
  const skipped = results.filter((r) => r.status === "skipped").length;
  const withErrors = results.filter((r) => r.pageErrors.length > 0).length;

  fs.writeFileSync(
    path.join(runDir, "report.json"),
    JSON.stringify(
      {
        workflow: workflow.name,
        file: workflow.file,
        passed,
        failed,
        skipped,
        results,
      },
      null,
      2,
    ),
  );

  const lines = [
    `# Walkthrough: ${workflow.name}`,
    "",
    workflow.description ?? "",
    "",
    `Workflow: \`${workflow.file}\``,
    "",
    `**${passed} passed, ${failed} failed, ${skipped} skipped** · ${withErrors} step(s) with page errors`,
    "",
    "| # | Step | Result | Notes | Screenshots |",
    "|---|------|--------|-------|-------------|",
    ...results.map((r) => {
      const notes = [...r.failures, ...r.pageErrors].map(cell).join("<br>");
      const shot = r.screenshots
        .map((file) => `[${path.basename(file, ".png")}](${encodeURI(file)})`)
        .join("<br>");
      return `| ${r.index} | ${cell(r.do)} | ${r.status} | ${notes} | ${shot} |`;
    }),
    "",
  ];

  const reportPath = path.join(runDir, "report.md");
  fs.writeFileSync(reportPath, lines.join("\n"));
  return reportPath;
}

function cell(text: string): string {
  return text.replace(/\|/g, "\\|").replace(/\n/g, " ");
}
