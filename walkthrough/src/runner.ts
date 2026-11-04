/**
 * Drives a workflow through the browser one step at a time, at a pace a person
 * can follow, and records what happened at each step.
 *
 * Workflows are data, so locators are built here from each step's target.
 * This is the one place selectors are interpreted, the way a page object
 * would be in a test suite.
 */
import fs from "fs";
import path from "path";
import { expect, type Locator, type Page } from "@playwright/test";
import type { Adapter } from "./adapter";
import { highlight, showBanner, type BannerStatus } from "./overlay";
import { liveViewCrashed, settleLiveView } from "./phoenix";
import type {
  Action,
  Expectation,
  LoadedWorkflow,
  Pace,
  Step,
  Target,
  TargetSpec,
} from "./workflow";

export type StepResult = {
  index: number;
  do: string;
  status: "passed" | "failed" | "skipped";
  durationMs: number;
  failures: string[];
  /** Console errors, page errors, 5xx responses and app crashes seen during the step. */
  pageErrors: string[];
  /** This step's folder, relative to the run folder. */
  folder?: string;
  /** Screenshots taken during the step, relative to the run folder. */
  screenshots: string[];
  url?: string;
};

type RunnerOptions = {
  pace: Pace;
  runDir: string;
  /** How long to leave the browser on a failed step before moving on or stopping. */
  holdOnFailureMs: number;
  adapter: Adapter;
};

const DEFAULT_TIMEOUT_MS = 15_000;

export class WalkthroughRunner {
  private readonly page: Page;
  private readonly workflow: LoadedWorkflow;
  private readonly options: RunnerOptions;
  private readonly pageErrors: string[] = [];
  private lastDownload?: { path: string; filename: string };
  // The folder the current step's screenshots and downloads go in.
  private stepDir = "";
  private stepShots: string[] = [];

  constructor(page: Page, workflow: LoadedWorkflow, options: RunnerOptions) {
    this.page = page;
    this.workflow = workflow;
    this.options = options;
    this.watchForErrors();
  }

  async run(steps: Step[]): Promise<StepResult[]> {
    const results: StepResult[] = [];
    let stopped = false;

    for (const [i, step] of steps.entries()) {
      if (stopped) {
        results.push({
          index: i + 1,
          do: step.do,
          status: "skipped",
          durationMs: 0,
          failures: [],
          pageErrors: [],
          screenshots: [],
        });
        continue;
      }

      const result = await this.runStep(step, i, steps.length);
      results.push(result);
      log(`${statusIcon(result.status)} ${i + 1}/${steps.length} ${step.do}`);
      for (const failure of result.failures) log(`     ✗ ${failure}`);
      for (const error of result.pageErrors) log(`     ! ${error}`);

      if (result.status === "failed") {
        await this.page.waitForTimeout(this.options.holdOnFailureMs);
        stopped = (this.workflow.onFailure ?? "stop") === "stop";
      } else {
        await this.page.waitForTimeout(this.options.pace.stepDelayMs);
      }
    }

    return results;
  }

  private async runStep(
    step: Step,
    i: number,
    total: number,
  ): Promise<StepResult> {
    const started = Date.now();
    const timeout =
      step.timeoutMs ?? this.workflow.timeoutMs ?? DEFAULT_TIMEOUT_MS;
    const failures: string[] = [];
    const errorsBefore = this.pageErrors.length;
    const label = `Step ${i + 1}/${total}`;
    const folder = `${String(i + 1).padStart(2, "0")}-${slug(step.do)}`;
    this.stepDir = path.join(this.options.runDir, folder);
    this.stepShots = [];
    fs.mkdirSync(this.stepDir, { recursive: true });

    await this.banner(label, step.do, "running");

    if (step.action) {
      try {
        await this.perform(step.action, timeout);
        await (this.options.adapter.settle ?? settleLiveView)(
          this.page,
          timeout,
        );
      } catch (error) {
        failures.push(`action ${step.action.type}: ${firstLine(error)}`);
      }
      await this.screenshot(
        failures.length > 0 ? "action-failed" : "after-action",
      );
    }

    if (failures.length === 0) {
      for (const expectation of step.expect ?? []) {
        try {
          await this.check(expectation, timeout);
        } catch (error) {
          failures.push(
            `expect ${describeExpectation(expectation)}: ${firstLine(error)}`,
          );
        }
      }
    }

    const crashed = await (this.options.adapter.crashed ?? liveViewCrashed)(
      this.page,
    );
    if (crashed) this.pageErrors.push(crashed);

    const pageErrors = this.pageErrors.slice(errorsBefore);
    const status = failures.length === 0 ? "passed" : "failed";

    await this.banner(
      label,
      step.do,
      status,
      status === "failed"
        ? failures.join("\n")
        : pageErrors.length > 0
          ? pageErrors.join("\n")
          : undefined,
    );
    // Taken with the result banner up, so each shot says what it shows.
    if (step.expect?.length || status === "failed") {
      await this.screenshot(status === "failed" ? "failed" : "after-checks");
    }

    return {
      index: i + 1,
      do: step.do,
      status,
      durationMs: Date.now() - started,
      failures,
      pageErrors,
      folder,
      screenshots: this.stepShots,
      url: this.page.url(),
    };
  }

  async banner(
    title: string,
    step: string,
    status: BannerStatus,
    detail?: string,
  ) {
    await showBanner(this.page, {
      title: `${this.workflow.name} · ${title}`,
      step,
      detail,
      status,
    });
  }

  private async perform(action: Action, timeout: number): Promise<void> {
    const { pace } = this.options;

    switch (action.type) {
      case "goto":
        await this.page.goto(action.url, { timeout });
        return;
      case "click":
        await this.act(action.target, timeout, (l) => l.click({ timeout }));
        return;
      case "dblclick":
        await this.act(action.target, timeout, (l) => l.dblclick({ timeout }));
        return;
      case "fill":
        await this.act(action.target, timeout, async (l) => {
          await l.fill("", { timeout });
          await l.pressSequentially(action.value, {
            delay: pace.typeDelayMs,
            timeout,
          });
        });
        return;
      case "clear":
        await this.act(action.target, timeout, (l) => l.fill("", { timeout }));
        return;
      case "select":
        await this.act(action.target, timeout, async (l) => {
          await l.selectOption(action.option, { timeout });
        });
        return;
      case "check":
        await this.act(action.target, timeout, (l) => l.check({ timeout }));
        return;
      case "uncheck":
        await this.act(action.target, timeout, (l) => l.uncheck({ timeout }));
        return;
      case "press":
        if (action.target) {
          await this.act(action.target, timeout, (l) =>
            l.press(action.key, { timeout }),
          );
        } else {
          await this.page.keyboard.press(action.key);
        }
        return;
      case "hover":
        await this.act(action.target, timeout, (l) => l.hover({ timeout }));
        return;
      case "scroll":
        await this.act(action.target, timeout, (l) =>
          l.scrollIntoViewIfNeeded({ timeout }),
        );
        return;
      case "download":
        await this.act(action.target, timeout, async (l) => {
          const [download] = await Promise.all([
            this.page.waitForEvent("download", { timeout }),
            l.click({ timeout }),
          ]);
          const filename = download.suggestedFilename();
          const saved = path.join(this.stepDir, filename);
          await download.saveAs(saved);
          this.lastDownload = { path: saved, filename };
        });
        return;
      case "wait":
        await this.page.waitForTimeout(action.ms);
        return;
      case "waitFor":
        await this.locate(action.target).waitFor({
          state: "visible",
          timeout: action.timeoutMs ?? timeout,
        });
        return;
      case "screenshot":
        await this.screenshot(action.name);
        return;
      case "narrate":
        await this.banner("Note", action.message, "info");
        await this.page.waitForTimeout(action.ms ?? 4000);
        return;
      case "handoff":
        await this.banner(
          "Your turn",
          action.message ?? "Resume from the Playwright inspector",
          "info",
        );
        await this.page.pause();
        return;
    }
  }

  private async act(
    target: Target,
    timeout: number,
    fn: (l: Locator) => Promise<void>,
  ) {
    const locator = this.locate(target);
    await locator.waitFor({ state: "visible", timeout });
    await highlight(locator, this.options.pace.highlightMs);
    await fn(locator);
  }

  private async check(
    expectation: Expectation,
    timeout: number,
  ): Promise<void> {
    const opts = { timeout };

    switch (expectation.type) {
      case "visible":
        await expect(this.locate(expectation.target)).toBeVisible(opts);
        return;
      case "hidden":
        await expect(this.locate(expectation.target)).toBeHidden(opts);
        return;
      case "text": {
        const locator = this.locate(expectation.target);
        if (expectation.equals !== undefined) {
          await expect(locator).toHaveText(expectation.equals, opts);
        } else {
          await expect(locator).toContainText(expectation.contains ?? "", opts);
        }
        return;
      }
      case "value":
        await expect(this.locate(expectation.target)).toHaveValue(
          expectation.equals,
          opts,
        );
        return;
      case "count":
        // `locate` narrows to one element; a count needs all of them.
        await expect(this.locate(expectation.target, { all: true })).toHaveCount(
          expectation.equals,
          opts,
        );
        return;
      case "enabled":
        await expect(this.locate(expectation.target)).toBeEnabled(opts);
        return;
      case "disabled":
        await expect(this.locate(expectation.target)).toBeDisabled(opts);
        return;
      case "checked":
        await expect(this.locate(expectation.target)).toBeChecked(opts);
        return;
      case "url":
        if (expectation.matches !== undefined) {
          await expect(this.page).toHaveURL(
            new RegExp(expectation.matches),
            opts,
          );
        } else {
          await expect(this.page).toHaveURL(
            new RegExp(escapeRegExp(expectation.contains ?? "")),
            opts,
          );
        }
        return;
      case "title":
        await expect(this.page).toHaveTitle(
          new RegExp(escapeRegExp(expectation.contains)),
          opts,
        );
        return;
      case "flash":
        await expect(
          this.page
            .getByRole("alert")
            .filter({ hasText: expectation.contains })
            .first(),
        ).toBeVisible(opts);
        return;
      case "download": {
        if (!this.lastDownload) throw new Error("no download has happened yet");
        const { filename } = this.lastDownload;
        if (
          expectation.filenameMatches &&
          !new RegExp(expectation.filenameMatches).test(filename)
        ) {
          throw new Error(
            `downloaded "${filename}", expected to match /${expectation.filenameMatches}/`,
          );
        }
        if (expectation.contains !== undefined) {
          const body = fs.readFileSync(this.lastDownload.path, "utf-8");
          if (!body.includes(expectation.contains)) {
            throw new Error(
              `"${filename}" does not contain "${expectation.contains}"`,
            );
          }
        }
        return;
      }
    }
  }

  locate(target: Target, options: { all?: boolean } = {}): Locator {
    const spec = typeof target === "string" ? parseTarget(target) : target;
    const root = spec.within ? this.locate(spec.within) : this.page;
    let locator = baseLocator(root, spec);
    if (spec.hasText !== undefined)
      locator = locator.filter({ hasText: spec.hasText });
    if (spec.nth !== undefined) return locator.nth(spec.nth);
    return options.all ? locator : locator.first();
  }

  private async screenshot(name: string): Promise<void> {
    const n = String(this.stepShots.length + 1);
    const file = path.join(this.stepDir, `${n}-${slug(name)}.png`);
    await this.page
      .screenshot({ path: file })
      .then(() => {
        this.stepShots.push(path.relative(this.options.runDir, file));
      })
      .catch(() => undefined);
  }

  private watchForErrors() {
    this.page.on("console", (message) => {
      if (message.type() === "error")
        this.pageErrors.push(`console: ${message.text()}`);
    });
    this.page.on("pageerror", (error) => {
      this.pageErrors.push(`page error: ${error.message}`);
    });
    this.page.on("response", (response) => {
      if (response.status() >= 500) {
        this.pageErrors.push(
          `HTTP ${response.status()} ${response.request().method()} ${response.url()}`,
        );
      }
    });
  }
}

function baseLocator(root: Page | Locator, spec: TargetSpec): Locator {
  const exact = spec.exact;
  if (spec.testid !== undefined) return root.getByTestId(spec.testid);
  if (spec.id !== undefined) return root.locator(`[id="${spec.id}"]`);
  if (spec.role !== undefined) {
    return root.getByRole(spec.role as Parameters<Page["getByRole"]>[0], {
      name: spec.name,
      exact,
    });
  }
  if (spec.label !== undefined) return root.getByLabel(spec.label, { exact });
  if (spec.placeholder !== undefined)
    return root.getByPlaceholder(spec.placeholder, { exact });
  if (spec.text !== undefined) return root.getByText(spec.text, { exact });
  if (spec.css !== undefined) return root.locator(spec.css);
  throw new Error(`target has no selector: ${JSON.stringify(spec)}`);
}

export function parseTarget(target: string): TargetSpec {
  const [kind, ...rest] = target.split(":");
  const value = rest.join(":");

  switch (kind) {
    case "testid":
      return { testid: value };
    case "id":
      return { id: value };
    case "role": {
      const [role, ...name] = value.split(":");
      return name.length > 0 ? { role, name: name.join(":") } : { role };
    }
    case "label":
      return { label: value };
    case "placeholder":
      return { placeholder: value };
    case "text":
      return { text: value };
    case "css":
      return { css: value };
    default:
      return { text: target };
  }
}

function describeExpectation(e: Expectation): string {
  const { type, ...rest } = e;
  return `${type} ${JSON.stringify(rest)}`;
}

function firstLine(error: unknown): string {
  const message = error instanceof Error ? error.message : String(error);
  // Playwright errors carry ANSI colour codes and a long call log. The first
  // line says what timed out; the reason ("<div> intercepts pointer events",
  // "element is not visible") is near the end of the log, so keep both ends.
  const lines = message
    .replace(/\u001b\[[0-9;]*m/g, "")
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line && !/^(Call log:|- waiting for|\d+ × )/.test(line));
  const head = lines.slice(0, 2);
  const reason = lines.find((line) =>
    /intercepts pointer events|not visible|not enabled|not attached|outside of the viewport|element was detached/.test(
      line,
    ),
  );
  const tail = (reason ? [reason] : lines.slice(-2)).filter(
    (line) => !head.includes(line),
  );
  return [...head, ...tail].join(" | ");
}

function escapeRegExp(text: string): string {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

export function slug(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 40);
}

function statusIcon(status: StepResult["status"]): string {
  return status === "passed" ? "✓" : status === "failed" ? "✗" : "-";
}

function log(line: string) {
  process.stdout.write(`${line}\n`);
}
