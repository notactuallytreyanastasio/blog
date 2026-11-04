/**
 * Workflow file format for the walkthrough runner.
 *
 * A workflow is a JSON file: an ordered list of steps, each one human-sized
 * action ("Click Save") followed by the outcomes a person watching would
 * check ("the flash says Saved"). See README.md for the full reference.
 */
import fs from "fs";
import path from "path";

/**
 * How to find an element. Either an object, or a shorthand string:
 * "testid:foo", "id:foo", "role:button:Save", "label:Email",
 * "placeholder:Search", "text:Save", "css:.x". A bare string is text.
 */
export type Target = string | TargetSpec;

export type TargetSpec = {
  testid?: string;
  id?: string;
  role?: string;
  name?: string;
  label?: string;
  placeholder?: string;
  text?: string;
  /** Last resort; prefer testid/id/role/text. */
  css?: string;
  exact?: boolean;
  /** Narrow to elements whose text contains this. */
  hasText?: string;
  /** Resolve inside another element. */
  within?: Target;
  /** Pick the nth match (0-based) when several match. */
  nth?: number;
};

export type Action =
  | { type: "goto"; url: string }
  | { type: "click"; target: Target }
  | { type: "dblclick"; target: Target }
  | { type: "fill"; target: Target; value: string }
  | { type: "clear"; target: Target }
  | { type: "select"; target: Target; option: string }
  | { type: "check"; target: Target }
  | { type: "uncheck"; target: Target }
  | { type: "press"; key: string; target?: Target }
  | { type: "hover"; target: Target }
  | { type: "scroll"; target: Target }
  | { type: "download"; target: Target }
  | { type: "wait"; ms: number }
  | { type: "waitFor"; target: Target; timeoutMs?: number }
  | { type: "screenshot"; name: string }
  /** Shows the message in the banner and holds for `ms` (default 4s). */
  | { type: "narrate"; message: string; ms?: number }
  /** Hands control to the watcher via the Playwright inspector; resume there. */
  | { type: "handoff"; message?: string };

export type Expectation =
  | { type: "visible"; target: Target }
  | { type: "hidden"; target: Target }
  | { type: "text"; target: Target; contains?: string; equals?: string }
  | { type: "value"; target: Target; equals: string }
  | { type: "count"; target: Target; equals: number }
  | { type: "enabled"; target: Target }
  | { type: "disabled"; target: Target }
  | { type: "checked"; target: Target }
  | { type: "url"; contains?: string; matches?: string }
  | { type: "title"; contains: string }
  | { type: "flash"; contains: string }
  /** Applies to the file saved by the most recent `download` action. */
  | { type: "download"; filenameMatches?: string; contains?: string };

export type Step = {
  /** What a person would say they are doing: "Open the post list". */
  do: string;
  action?: Action;
  expect?: Expectation[];
  /** Per-step override of the workflow's step timeout. */
  timeoutMs?: number;
};

export type Pace = {
  /** Pause after each step so the watcher can take it in. */
  stepDelayMs: number;
  /** Delay between keystrokes when filling. */
  typeDelayMs: number;
  /** How long the target is highlighted before it is acted on. */
  highlightMs: number;
};

export type Workflow = {
  name: string;
  description?: string;
  /**
   * Values for {{var.<name>}} in steps. The adapter's `prepare` can add to or
   * override these (ids it created, a logged-in user's name, ...).
   */
  vars?: Record<string, unknown>;
  /** "stop" (default) halts at the first failing step; "continue" runs on. */
  onFailure?: "stop" | "continue";
  /** Default wait for a step's action and each expectation. */
  timeoutMs?: number;
  pace?: Partial<Pace>;
  steps: Step[];
};

export type LoadedWorkflow = Workflow & { file: string };

export const PACES: Record<string, Pace> = {
  slow: { stepDelayMs: 2500, typeDelayMs: 120, highlightMs: 1200 },
  normal: { stepDelayMs: 1200, typeDelayMs: 70, highlightMs: 700 },
  fast: { stepDelayMs: 300, typeDelayMs: 20, highlightMs: 200 },
};

/**
 * Picks the pace: WALKTHROUGH_PACE (slow/normal/fast) sets the base, the
 * workflow's own `pace` overrides individual fields.
 */
export function resolvePace(workflow: Workflow, envPace?: string): Pace {
  const base = PACES[envPace ?? "normal"] ?? PACES.normal;
  return { ...base, ...workflow.pace };
}

export function loadWorkflow(file: string): LoadedWorkflow {
  const absolute = path.resolve(file);
  const parsed: unknown = JSON.parse(fs.readFileSync(absolute, "utf-8"));
  const problems = validate(parsed);

  if (problems.length > 0) {
    throw new Error(
      `Invalid workflow ${absolute}:\n${problems.map((p) => `  - ${p}`).join("\n")}`,
    );
  }

  return { ...(parsed as Workflow), file: absolute };
}

/**
 * Replaces {{var.<path>}} and {{env.<NAME>}} in every string of the steps.
 * `path` may be dotted to reach into nested values ({{var.post.slug}}). A
 * reference with no value fails the run before the browser opens.
 */
export function applyVars(steps: Step[], vars: Record<string, unknown>): Step[] {
  const missing = new Set<string>();
  const text = JSON.stringify(steps).replace(
    /\{\{\s*(var|env)\.([\w.-]+)\s*\}\}/g,
    (match, kind: string, key: string) => {
      const value = kind === "env" ? process.env[key] : dig(vars, key);
      if (value === undefined || value === null) {
        missing.add(`${kind}.${key}`);
        return match;
      }
      // Inside a JSON string, so the value has to be escaped as one.
      return JSON.stringify(String(value)).slice(1, -1);
    },
  );

  if (missing.size > 0) {
    throw new Error(
      `Workflow references values that are not set: ${[...missing].join(", ")}. ` +
        `Known vars: ${Object.keys(vars).join(", ") || "none"}`,
    );
  }

  return JSON.parse(text) as Step[];
}

function dig(value: unknown, dotted: string): unknown {
  return dotted.split(".").reduce<unknown>((acc, part) => {
    if (acc === null || typeof acc !== "object") return undefined;
    return (acc as Record<string, unknown>)[part];
  }, value);
}

const ACTION_TYPES = new Set([
  "goto",
  "click",
  "dblclick",
  "fill",
  "clear",
  "select",
  "check",
  "uncheck",
  "press",
  "hover",
  "scroll",
  "download",
  "wait",
  "waitFor",
  "screenshot",
  "narrate",
  "handoff",
]);

const EXPECT_TYPES = new Set([
  "visible",
  "hidden",
  "text",
  "value",
  "count",
  "enabled",
  "disabled",
  "checked",
  "url",
  "title",
  "flash",
  "download",
]);

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

// Checks structure only, so a typo in a hand-written workflow fails before the
// browser opens rather than halfway through a run someone is watching.
function validate(value: unknown): string[] {
  if (!isRecord(value)) return ["workflow must be a JSON object"];

  const problems: string[] = [];
  if (typeof value.name !== "string") problems.push("`name` must be a string");
  if (value.vars !== undefined && !isRecord(value.vars)) {
    problems.push("`vars` must be an object");
  }
  if (!Array.isArray(value.steps) || value.steps.length === 0) {
    problems.push("`steps` must be a non-empty array");
    return problems;
  }

  value.steps.forEach((step: unknown, i: number) => {
    const at = `steps[${i}]`;
    if (!isRecord(step)) {
      problems.push(`${at} must be an object`);
      return;
    }
    if (typeof step.do !== "string") problems.push(`${at}.do must be a string`);
    if (step.action === undefined && step.expect === undefined) {
      problems.push(`${at} needs an action, an expect, or both`);
    }
    if (step.action !== undefined) {
      if (
        !isRecord(step.action) ||
        !ACTION_TYPES.has(String(step.action.type))
      ) {
        problems.push(
          `${at}.action.type must be one of ${[...ACTION_TYPES].join(", ")}`,
        );
      }
    }
    if (step.expect !== undefined) {
      if (!Array.isArray(step.expect)) {
        problems.push(`${at}.expect must be an array`);
      } else {
        step.expect.forEach((e: unknown, j: number) => {
          if (!isRecord(e) || !EXPECT_TYPES.has(String(e.type))) {
            problems.push(
              `${at}.expect[${j}].type must be one of ${[...EXPECT_TYPES].join(", ")}`,
            );
          }
        });
      }
    }
  });

  return problems;
}
