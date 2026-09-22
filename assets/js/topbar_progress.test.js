import { test } from "node:test";
import assert from "node:assert/strict";
import { wireTopbarProgress } from "./topbar_progress.js";

function fakeTopbar() {
  const calls = [];
  return {
    calls,
    show: (delay) => calls.push(["show", delay]),
    hide: () => calls.push(["hide"])
  };
}

test("phx:page-loading-start shows the topbar with a 300ms delay", () => {
  const target = new EventTarget();
  const topbar = fakeTopbar();
  wireTopbarProgress(target, topbar);

  target.dispatchEvent(new Event("phx:page-loading-start"));

  assert.deepEqual(topbar.calls, [["show", 300]]);
});

test("phx:page-loading-stop hides the topbar even when gtag isn't present", () => {
  const target = new EventTarget();
  const topbar = fakeTopbar();
  wireTopbarProgress(target, topbar, { getGtag: () => undefined });

  target.dispatchEvent(new Event("phx:page-loading-stop"));

  assert.deepEqual(topbar.calls, [["hide"]]);
});

test("phx:page-loading-stop reports a GA4 page_view when gtag is present", () => {
  const target = new EventTarget();
  const topbar = fakeTopbar();
  const gtagCalls = [];

  wireTopbarProgress(target, topbar, {
    getGtag: () => (...args) => gtagCalls.push(args),
    getPath: () => "/post/hello",
    getTitle: () => "Hello — Bobby's Blog"
  });

  target.dispatchEvent(new Event("phx:page-loading-stop"));

  assert.deepEqual(gtagCalls, [
    ["event", "page_view", { page_path: "/post/hello", page_title: "Hello — Bobby's Blog" }]
  ]);
});

test("gtag is read at event time, not wiring time, so a late-loading GA snippet still gets used", () => {
  const target = new EventTarget();
  const topbar = fakeTopbar();
  const calls = [];
  let gtagRef; // undefined when wireTopbarProgress runs, "loads" afterward

  wireTopbarProgress(target, topbar, {
    getGtag: () => gtagRef,
    getPath: () => "/",
    getTitle: () => "t"
  });

  gtagRef = (...args) => calls.push(args);
  target.dispatchEvent(new Event("phx:page-loading-stop"));

  assert.equal(calls.length, 1);
});
