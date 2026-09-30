// node --max-old-space-size=4096 test/fixtures/sky_hook_layout.mjs  (from blimp_site/)
//
// The answer sky_test.blimp holds the Temper to: SkyLive's SkyMap hook
// (assets/js/hooks/sky_map.js), its own functions run as they are over the
// two data files, for each of the three views. Written to
// test/fixtures/sky_hook_layout.json as every disc's community, place,
// radius and colour, in the order the hook placed them.
import fs from "node:fs"
const D = "../priv/static/data/"
const rawP = JSON.parse(fs.readFileSync(D + "sky_points.json"))
const rawC = JSON.parse(fs.readFileSync(D + "sky_communities.json"))
const src = fs.readFileSync("../assets/js/hooks/sky_map.js", "utf8")
const H = eval("(()=>{" + src.replace(/^import.*$/mg, "").replace("export default SkyMap", "return {SkyMap, generateCommunityColors}") + "})()")
const all = rawC.map((c) => ({community_index: c.i, label: c.l, member_count: c.m, centroid_x: c.cx, centroid_y: c.cy}))
const pts = rawP.map((p) => ({x: p.x, y: p.y, community_index: p.c, handle: p.h, followers_count: p.f}))
const out = {}
for (const mode of ["big", "niche", "all"]) {
  let cs = all
  if (mode === "big") cs = cs.filter((c) => (c.member_count || 0) >= 500)
  else if (mode === "niche") cs = cs.filter((c) => (c.member_count || 0) < 500)
  cs = H.SkyMap.recomputeCentroids(cs, pts)
  const vis = new Set(cs.map((c) => c.community_index))
  const {placed} = H.SkyMap.clusterByCommunity(pts.filter((p) => vis.has(p.community_index)), cs)
  const colors = H.generateCommunityColors(cs)
  out[mode] = placed.map((p) => ({i: p.community_index, x: p.x, y: p.y, r: p.r, rgb: colors[p.community_index]}))
}
fs.writeFileSync("test/fixtures/sky_hook_layout.json", JSON.stringify(out))
