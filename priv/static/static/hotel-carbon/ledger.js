/* The Waldorf Ledger: every facet of the hotel carbon programme on one linked instrument.
   One state object drives every view. The model is the Storylines slice model and its
   intervention library (ledger.json is generated from the Storylines and Evidence Map pages). */
(function(){
'use strict';
const d3 = window.d3;
const esc = s => String(s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const fmt = (n, d) => { if (!isFinite(n)) return '–'; if (d === undefined) d = Math.abs(n) >= 100 ? 0 : Math.abs(n) >= 10 ? 1 : 2; return n.toLocaleString('en-US', {minimumFractionDigits:d, maximumFractionDigits:d}); };
const reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const DUR = reduced ? 0 : 550;
const css = v => `var(${v})`;

/* ------------------------------------------------------------------ model */
const Y0 = 2025, Y1 = 2040, YEARS = d3.range(Y0, Y1 + 1);
const KEYS = 375, OCC = 0.76, GFA = 375 * 90, GUESTS = 1.6;
const SLICES = [
  {k:'heat', name:'Space heating', short:'Heating', grp:'building', elec:0, fuel:1668.6, fixed:0.7},
  {k:'cool', name:'Space cooling', short:'Cooling', grp:'building', elec:639.9, fuel:0, fixed:0.6},
  {k:'vent', name:'Ventilation', short:'Ventilation', grp:'building', elec:1328.4, fuel:0, fixed:0.8},
  {k:'dhw', name:'Water heating', short:'Hot water', grp:'building', elec:0, fuel:1757.7, fixed:0.3},
  {k:'light', name:'Lighting', short:'Lighting', grp:'building', elec:769.5, fuel:0, fixed:0.7},
  {k:'bother', name:'Refrigeration, plug and other', short:'Plug & refrigeration', grp:'building', elec:1275.7, fuel:660.2, fixed:0.8},
  {k:'elev', name:'Elevators', short:'Elevators', grp:'building', elec:49, fuel:0, fixed:0.5},
  {k:'pool', name:'Pool', short:'Pool', grp:'wellness', elec:75, fuel:175, fixed:1},
  {k:'sauna', name:'Sauna and steam room', short:'Sauna & steam', grp:'wellness', elec:61.7, fuel:0, fixed:1},
  {k:'gym', name:'Fitness centre', short:'Fitness', grp:'wellness', elec:22.4, fuel:9.6, fixed:1},
  {k:'spa', name:'Spa', short:'Spa', grp:'wellness', elec:300, fuel:200, fixed:1},
  {k:'kitchen', name:'Kitchen and bar energy', short:'Kitchen energy', grp:'fnb', elec:266, fuel:347, fixed:0.3},
  {k:'food', name:'Purchased food and drink', short:'Food & drink', grp:'fnb', t3:936, fixed:0},
  {k:'foodwaste', name:'Food waste disposal', short:'Food waste', grp:'fnb', t3:47, fixed:0},
  {k:'laundry', name:'Laundry (outsourced)', short:'Laundry', grp:'services', elec:219, fuel:658, fixed:0, s3:true},
  {k:'minibar', name:'Minibars', short:'Minibars', grp:'services', elec:84.4, fuel:0, fixed:1},
  {k:'waste', name:'Other solid waste', short:'Other waste', grp:'services', t3:307, fixed:0},
  {k:'transfers', name:'Chauffeured guest transfers', short:'Transfers', grp:'services', t3:KEYS * 365 * OCC * 20 * 0.319 / 1000, fixed:0}
];
const SL = Object.fromEntries(SLICES.map(s => [s.k, s]));
const GRPS = {building:['Base building', '--c7'], wellness:['Pool and wellness', '--c3'], fnb:['Food and kitchen', '--c4'], services:['Laundry, waste, minibars, transfers', '--c6']};
const CARR = {elec:['Grid electricity', '--c1'], fuel:['Gas or steam for heat', '--c2'], goods:['Things the hotel buys', '--c5']};
const SCOPE = {s1:['Scope 1', '--c2', 'burned on site'], s2:['Scope 2', '--c1', 'bought electricity'], s3:['Scope 3', '--c5', 'supply chain']};
const EF_TH = {gas:0.183, steam:0.170}, LL_TH = {gas:0.181, steam:0.147};
const GRIDS = {
  clcpa:{name:'CLCPA as legislated (0.15 in 2030, 0.02 in 2040)', pts:[[2025,0.392],[2030,0.15],[2040,0.02]]},
  ll97:{name:'LL97 coefficients as written', pts:[[2025,0.289],[2029,0.289],[2030,0.145],[2040,0.145]]},
  delayed:{name:'Delayed: 0.30 in 2030, 0.10 in 2040', pts:[[2025,0.392],[2030,0.30],[2040,0.10]]},
  stalled:{name:'Stalled grid: 0.35 flat', pts:[[2025,0.392],[2028,0.35],[2040,0.35]]},
  egrid:{name:'eGRID 2023 held flat (0.392)', pts:[[2025,0.392],[2040,0.392]]}
};
function gridEF(key, y){ const p = GRIDS[key].pts; if (y <= p[0][0]) return p[0][1]; for (let i = 1; i < p.length; i++){ if (y <= p[i][0]){ const a = p[i-1], b = p[i]; return a[1] + (b[1]-a[1]) * (y-a[0]) / (b[0]-a[0]); } } return p[p.length-1][1]; }
const ll97coefE = y => y <= 2029 ? 0.289 : 0.145;
const capOf = y => y <= 2029 ? 106.2 : y <= 2034 ? 56.6 : y <= 2039 ? 28.4 : 15.8;
const BENCH = [
  {l:'Puig 2017, Spain 4★', v:12, t:1}, {l:'CHSB CY2023, NYC luxury', v:28.4, t:1}, {l:'Brighter Planet, upscale', v:32, t:1}, {l:'CHSB CY2023, US luxury', v:32.1, t:1}, {l:'Huang 2015, Taiwan luxury', v:50, t:1},
  {l:'Attari 2026, Ireland 3★ full', v:15.87, t:2}, {l:'Dolder Grand incl. F&B', v:38.5, t:2}, {l:'Attari 2026, Ireland 5★ full', v:56.14, t:2}
];
const STORIES = [
  {name:'Doing nothing', plan:[]},
  {name:'Efficiency first', plan:[['guestroom_occupancy_hvac_controls',2026],['bathroom_lighting_sensors',2026],['led_lighting_retrofit',2026],['food_waste_measurement_programme',2026],['pool_cover_and_heat_recovery',2027],['low_carbon_menu_design',2027],['laundry_outsourcing_central_plant',2027],['organics_diversion_composting',2027]]},
  {name:'Electrify by 2030', plan:[['guestroom_occupancy_hvac_controls',2026],['bathroom_lighting_sensors',2026],['led_lighting_retrofit',2026],['food_waste_measurement_programme',2026],['pool_cover_and_heat_recovery',2027],['low_carbon_menu_design',2027],['laundry_outsourcing_central_plant',2027],['organics_diversion_composting',2027],['heat_pump_space_heating',2029],['heat_pump_dhw',2030],['kitchen_elec',2031]]},
  {name:'Electrify + Zone J RECs', plan:[['guestroom_occupancy_hvac_controls',2026],['led_lighting_retrofit',2026],['food_waste_measurement_programme',2026],['low_carbon_menu_design',2027],['heat_pump_space_heating',2028],['heat_pump_dhw',2029],['kitchen_elec',2030],['tier4_recs_zone_j',2030]]}
];
const KW = {
  heat:/\bheat(ing)?\b|boiler|hvac|steam|heat pump|electrif/i, cool:/cool|hvac|chill/i, vent:/ventilat|exhaust/i, dhw:/hot water|water heat|dhw|boiler/i,
  light:/light|led\b/i, bother:/plug|refrig/i, elev:/elevator|lift/i, pool:/pool/i, sauna:/sauna|steam room|thermal suite|hydrotherap/i, gym:/gym|fitness|cardio/i,
  spa:/\bspa\b|massage|wellness/i, kitchen:/kitchen|cooking|induction/i, food:/food|menu|beef|meal|f&b|restaurant|buffet|diet|plate/i,
  foodwaste:/food waste|plate waste|organics|compost/i, laundry:/laundry|linen|towel|housekeep/i, minibar:/minibar/i, waste:/waste|recycl|landfill/i, transfers:/transfer|transport|vehicle|fleet|chauffeur/i
};

let LIB = [], LIBMAP = {}, RULES = [], EVID = null;
/* site EUI of the slice hotel: on-site electricity + fuel of the non-outsourced slices over the floor area, kBtu/ft² */
const EUI0 = d3.sum(SLICES.filter(s => !s.s3), s => (s.elec || 0) + (s.fuel || 0)) * 3412.14 / (GFA * 10.7639);
const BLDG = {median:{name:'CHSB NYC luxury median', eui:EUI0}, peers:{name:'Manhattan luxury peers', eui:135}};
const st = {year:Y0, boundary:'full', denom:'room', grid:'clcpa', heat:'gas', bldg:'median', plan:[], focus:null, lever:null, levMetric:'night', q:'', story:0};

function inB(s){ const b = st.boundary; if (b === 'full') return true; if (s.k === 'transfers' || s.k === 'waste' || s.k === 'foodwaste') return false; if (b === 'food') return true; if (s.k === 'food') return false; if (b === 'hcmi') return true; return !s.s3; }
function divisor(rn){ return st.denom === 'room' ? rn : st.denom === 'guest' ? rn * GUESTS : GFA; }
const BNAME = {s12:'energy only (Scope 1+2)', hcmi:'energy + outsourced laundry (HCMI)', food:'+ purchased food and drink', full:'full: + waste and transfers'};
const UNIT = {room:['per occupied room-night','kg / room-night'], guest:['per guest-night','kg / guest-night'], m2:['per m² of floor per year','kg / m²·yr']};

/* simulate one plan. draw[i] scales event i's effect (1 = the library's mid), gridMult scales the grid factor, occJ jitters occupancy.
   Port of Storylines' simulate(); the one change is that Tier-4 Zone J RECs are deducted on the LL97 electricity line,
   as LL97 allows (1 RCNY 103-14), while leaving the location-based footprint alone. */
function simulate(plan, draw, gridMult, occJ, until){
  const evs = plan.map((e, i) => { const l = LIBMAP[e.lib]; return l ? {l, year:+e.year, scale:draw ? draw[i] : 1} : null; }).filter(Boolean);
  const efTh = EF_TH[st.heat], llTh = LL_TH[st.heat];
  const out = {years:[], cumT:0, cumPen:0, firstOk:null, overYears:0};
  for (const y of YEARS){
    if (until && y > until) break;
    let occMult = 1, capMult = 1, recFrac = 0, elecCut = 0; const red = {}, electrify = {};
    for (const ev of evs){
      const l = ev.l, e = l.effect, dy = y - ev.year; if (dy < 0) continue;
      const ramp = Math.min(1, (dy + 1) / Math.max(1, l.ramp || 1));
      const val = (e.type === 'occupancy_multiplier' || e.type === 'cap_multiplier') ? (e.mid + (ev.scale - 1) * (e.high - e.low) / 2) : e.mid * ev.scale;
      if (e.type === 'occupancy_multiplier'){ if (dy < (l.duration || 1)) occMult *= Math.max(0, val); continue; }
      if (e.type === 'cap_multiplier'){ capMult *= val; continue; }
      if (e.type === 'ef_multiplier'){ if (l.id === 'tier4_recs_zone_j') recFrac = 1 - (1 - recFrac) * (1 - Math.min(1, val * ramp)); continue; }
      if (e.type === 'none') continue;
      if (e.type === 'fraction_reduction'){ const f = Math.min(0.99, val * ramp); if (l.targets[0] === '*elec'){ elecCut = 1 - (1 - elecCut) * (1 - f); continue; } for (const t of l.targets){ const ft = f * ((l.shares && l.shares[t]) || 1); red[t] = 1 - (1 - (red[t] || 0)) * (1 - ft); } continue; }
      if (e.type === 'electrify'){ for (const t of l.targets){ const sh = Math.min(1, val * ramp); if (!electrify[t] || sh > electrify[t].share) electrify[t] = {share:sh, cop:e.cop || 1}; } }
    }
    const occ = Math.min(1, OCC * occMult * (occJ || 1)), rn = KEYS * 365 * occ, v = occ / OCC;
    const efE = gridEF(st.grid, y) * (gridMult || 1), llE = ll97coefE(y), bf = BLDG[st.bldg].eui / EUI0;
    const yr = {y, rn, t:0, slices:{}, llElec:0, llFuel:0, s1:0, s2:0, s3:0};
    for (const s of SLICES){
      const act = s.fixed + (1 - s.fixed) * v;
      const k = s.s3 ? 1 : bf; let el = (s.elec || 0) * act * k, fu = (s.fuel || 0) * act * k, t3 = (s.t3 || 0) * v;
      const r = red[s.k] || 0; el *= 1 - r; fu *= 1 - r; t3 *= 1 - r;
      if (electrify[s.k]){ const mv = fu * electrify[s.k].share; fu -= mv; el += mv / electrify[s.k].cop; }
      el *= 1 - elecCut;
      const kgE = el * 1000 * efE, kgF = fu * 1000 * efTh, kgG = t3 * 1000;
      const b = inB(s);
      yr.slices[s.k] = {kgE, kgF, kgG, kg:kgE + kgF + kgG, inB:b};
      if (!s.s3){ yr.llElec += el; yr.llFuel += fu; }
      if (!b) continue;
      if (s.s3) yr.s3 += kgE + kgF; else { yr.s1 += kgF; yr.s2 += kgE; yr.s3 += kgG; }
      yr.t += (kgE + kgF + kgG) / 1000;
    }
    yr.kgm2 = (yr.llElec * 1000 * llE * (1 - recFrac) + yr.llFuel * 1000 * llTh) / GFA;
    yr.cap = capOf(y) * capMult;
    yr.pen = Math.max(0, yr.kgm2 - yr.cap) * GFA / 1000 * 268;
    yr.per = yr.t * 1000 / divisor(rn);
    out.cumT += yr.t; out.cumPen += yr.pen; if (yr.kgm2 > yr.cap) out.overYears++; if (y >= 2030 && out.firstOk === null && yr.kgm2 <= yr.cap) out.firstOk = y;
    out.years.push(yr);
  }
  return out;
}
function tri(lo, mid, hi, u){ if (hi <= lo) return mid; const c = (mid - lo) / (hi - lo); return u < c ? lo + Math.sqrt(u * (hi - lo) * (mid - lo)) : hi - Math.sqrt((1 - u) * (hi - lo) * (hi - mid)); }
function rng(seed){ let s = seed >>> 0 || 1; return () => { s = (s * 1664525 + 1013904223) >>> 0; return s / 4294967296; }; }
function pct(a, p){ const b = a.slice().sort((x, y) => x - y); const i = (b.length - 1) * p, lo = Math.floor(i), hi = Math.ceil(i); return b[lo] + (b[hi] - b[lo]) * (i - lo); }
function monteCarlo(plan, n){
  const r = rng(7), runs = [];
  for (let i = 0; i < n; i++){
    const draw = plan.map(e => { const l = LIBMAP[e.lib]; if (!l || !l.effect.mid) return 1; const ef = l.effect; return tri(ef.low, ef.mid, ef.high, r()) / ef.mid; });
    runs.push(simulate(plan, draw, tri(0.85, 1, 1.2, r()), tri(0.95, 1, 1.05, r())));
  }
  const res = {per:[], kgm2:[], pen:[]};
  YEARS.forEach((y, yi) => { for (const m of ['per', 'kgm2', 'pen']){ const vals = runs.map(rr => rr.years[yi][m]); res[m].push({y, p10:pct(vals, .1), p50:pct(vals, .5), p90:pct(vals, .9)}); } });
  const cum = runs.map(rr => rr.cumT); res.cumT = pct(cum, .5); res.cumT10 = pct(cum, .1); res.cumT90 = pct(cum, .9);
  res.cumPen = pct(runs.map(rr => rr.cumPen), .5);
  return res;
}

/* ------------------------------------------------------------------ state <-> URL */
function toHash(){
  const p = st.plan.map(e => LIB.findIndex(l => l.id === e.lib) + '.' + e.year).join('_');
  const q = new URLSearchParams({y:st.year, b:st.boundary, d:st.denom, g:st.grid, h:st.heat, e:st.bldg, p});
  if (st.focus) q.set('f', st.focus);
  history.replaceState(null, '', '#' + q.toString());
}
function fromHash(){
  const q = new URLSearchParams(location.hash.slice(1)); if (!q.has('y')) return false;
  const y = +q.get('y'); if (y >= Y0 && y <= Y1) st.year = y;
  if (['s12','hcmi','food','full'].includes(q.get('b'))) st.boundary = q.get('b');
  if (UNIT[q.get('d')]) st.denom = q.get('d');
  if (GRIDS[q.get('g')]) st.grid = q.get('g');
  if (EF_TH[q.get('h')]) st.heat = q.get('h');
  if (BLDG[q.get('e')]) st.bldg = q.get('e');
  if (SL[q.get('f')]) st.focus = q.get('f');
  st.plan = (q.get('p') || '').split('_').filter(Boolean).map(s => { const [i, yr] = s.split('.'); const l = LIB[+i]; return l ? {lib:l.id, year:Math.max(Y0, Math.min(Y1, +yr || Y0))} : null; }).filter(Boolean);
  return true;
}

/* ------------------------------------------------------------------ shared chrome */
const tip = d3.select('body').append('div').attr('class', 'tip').attr('hidden', true);
function showTip(ev, html){ tip.html(html).attr('hidden', null); const w = tip.node().offsetWidth; let x = ev.pageX + 14; if (x + w > window.scrollX + document.documentElement.clientWidth - 8) x = ev.pageX - w - 14; tip.style('left', x + 'px').style('top', (ev.pageY + 14) + 'px'); }
function hideTip(){ tip.attr('hidden', true); }
function tween(node, to, d){ const from = +node.dataset.v || 0; node.dataset.v = to; if (!DUR){ node.textContent = fmt(to, d); return; } d3.select(node).transition().duration(DUR).tween('t', () => { const i = d3.interpolateNumber(from, to); return t => { node.textContent = fmt(i(t), d); }; }); }

let R = null; /* cached results for the current settings + plan: det, bau, mc */
function compute(runs){ R = {det:simulate(st.plan), bau:simulate([]), mc:monteCarlo(st.plan, runs || 200)}; }

/* ------------------------------------------------------------------ KPIs */
function renderKpis(){
  const yi = st.year - Y0, d = R.det.years[yi], m = R.mc.per[yi], b = R.bau.years[yi];
  const over = d.kgm2 > d.cap, dCum = R.det.cumT - R.bau.cumT;
  const html = `
  <div class="kpi big"><div class="l">One night in ${st.year}</div><div class="v"><span data-k="per"></span><small>kg CO₂e ${UNIT[st.denom][0]}</small></div>
    <div class="s">p10–p90 ${fmt(m.p10, 1)}–${fmt(m.p90, 1)} · doing nothing ${fmt(b.per, 1)} · ${BNAME[st.boundary]} · ${BLDG[st.bldg].name}, EUI ${fmt(BLDG[st.bldg].eui, 0)}</div></div>
  <div class="kpi"><div class="l">LL97 in ${st.year}</div><div class="v ${over ? 'bad' : 'good'}"><span data-k="ll"></span><small>/ ${fmt(d.cap, 1)} kg/m²</small></div>
    <div class="s">${over ? `<span class="bad">${fmt((d.kgm2 / d.cap - 1) * 100, 0)}% over</span> · $${fmt(d.pen / 1e6, 2)}M penalty` : '<span class="good">under the cap</span>'}</div></div>
  <div class="kpi"><div class="l">Penalties 2025–2040</div><div class="v ${R.mc.cumPen > 0 ? 'bad' : 'good'}">$<span data-k="pen"></span><small>M</small></div>
    <div class="s">${R.det.overYears} of 16 years over · ${R.det.firstOk ? 'compliant from ' + R.det.firstOk : 'never under the 2030+ cap'}</div></div>
  <div class="kpi"><div class="l">Emitted 2025–2040</div><div class="v"><span data-k="cum"></span><small>kt CO₂e</small></div>
    <div class="s">${Math.abs(dCum) < 50 ? 'same as doing nothing' : (dCum < 0 ? '−' : '+') + fmt(Math.abs(dCum) / 1000, 1) + ' kt against doing nothing'}</div></div>
  <div class="kpi"><div class="l">Grid in ${st.year}</div><div class="v"><span data-k="ef"></span><small>kg/kWh</small></div>
    <div class="s">${esc(GRIDS[st.grid].name)}</div></div>`;
  const box = document.getElementById('kpis'), prev = {};
  box.querySelectorAll('[data-k]').forEach(n => prev[n.dataset.k] = n.dataset.v);
  box.innerHTML = html;
  const vals = {per:[d.per, 1], ll:[d.kgm2, 1], pen:[R.mc.cumPen / 1e6, 2], cum:[R.mc.cumT / 1000, 1], ef:[gridEF(st.grid, st.year), 3]};
  box.querySelectorAll('[data-k]').forEach(n => { n.dataset.v = prev[n.dataset.k] || 0; tween(n, vals[n.dataset.k][0], vals[n.dataset.k][1]); });
}

/* ------------------------------------------------------------------ I. the fan (rose) */
const rose = d3.select('#rose'), RCX = 320, RCY = 392, RIN = 72, ROUT = 232;
const roseG = rose.append('g').attr('transform', `translate(${RCX},${RCY})`);
const ringG = roseG.append('g'), wedgeG = roseG.append('g'), labG = roseG.append('g');
const roseNum = roseG.append('text').attr('text-anchor', 'middle').attr('y', -22).style('font-family', 'var(--serif)').style('font-size', '42px').style('font-weight', 600).style('fill', 'var(--ink)');
const roseUnit = roseG.append('text').attr('text-anchor', 'middle').attr('y', -5).attr('class', 'mono').style('font-size', '9.5px').style('fill', 'var(--ink-3)');
roseG.append('line').attr('x1', -ROUT - 30).attr('x2', ROUT + 30).attr('y1', 8).attr('y2', 8).attr('stroke', 'var(--brass)');
const angle = d3.scaleBand().domain(SLICES.map(s => s.k)).range([-Math.PI / 2, Math.PI / 2]).paddingInner(0.08);
const roseArc = d3.arc().innerRadius(RIN).outerRadius(d => d.r).startAngle(d => angle(d.k)).endAngle(d => angle(d.k) + angle.bandwidth()).cornerRadius(2);
function renderRose(){
  const yr = R.det.years[st.year - Y0], div = divisor(yr.rn);
  const base = R.bau.years[0]; const maxKg = d3.max(SLICES, s => base.slices[s.k].kg / divisor(base.rn));
  const rs = d3.scaleSqrt().domain([0, maxKg]).range([RIN, ROUT]);
  const data = SLICES.map(s => { const x = yr.slices[s.k]; return {k:s.k, s, v:x.kg / div, inB:x.inB, r:Math.max(RIN + 1.5, rs(x.kg / div))}; });
  const total = d3.sum(data, d => d.inB ? d.v : 0);
  const ticks = rs.ticks(4).filter(v => v > 0 && rs(v) < ROUT + 1);
  const rg = ringG.selectAll('g').data(ticks, v => v);
  const rge = rg.enter().append('g');
  rge.append('path'); rge.append('text').attr('class', 'mono').attr('text-anchor', 'middle').attr('y', 22);
  rg.exit().remove();
  rge.merge(rg).select('path').attr('d', v => d3.arc()({innerRadius:rs(v), outerRadius:rs(v), startAngle:-Math.PI / 2, endAngle:Math.PI / 2})).attr('fill', 'none').attr('stroke', 'var(--rule)').attr('stroke-dasharray', '1 3');
  rge.merge(rg).select('text').attr('x', v => -rs(v)).text(v => fmt(v, v < 1 ? 1 : 0)).style('fill', 'var(--ink-3)');
  const w = wedgeG.selectAll('path').data(data, d => d.k);
  w.enter().append('path').attr('class', 'clickable').each(function(d){ this._r = RIN + 1.5; })
    .on('mousemove', (ev, d) => showTip(ev, `<b>${esc(d.s.name)}</b><br>${d.inB ? fmt(d.v, 2) + ' kg CO₂e ' + UNIT[st.denom][0] + ' · ' + fmt(d.v / total * 100, 1) + '%' : 'outside the chosen boundary'}<br><span class="m">${esc(GRPS[d.s.grp][0])}</span>`))
    .on('mouseleave', hideTip).on('click', (ev, d) => setFocus(st.focus === d.k ? null : d.k))
    .merge(w)
    .attr('fill', d => d.inB ? (st.focus === d.k ? 'var(--brass)' : css(GRPS[d.s.grp][1])) : 'transparent')
    .attr('fill-opacity', d => st.focus && st.focus !== d.k ? 0.28 : 0.9)
    .attr('stroke', d => d.inB ? 'var(--paper)' : 'var(--ink-3)').attr('stroke-dasharray', d => d.inB ? null : '2 3')
    .transition().duration(DUR).attrTween('d', function(d){ const i = d3.interpolateNumber(this._r, d.r); this._r = d.r; return t => roseArc({k:d.k, r:i(t)}); });
  const lab = labG.selectAll('text').data(data, d => d.k);
  lab.enter().append('text').style('font-size', '11px').merge(lab)
    .text(d => d.s.short).style('fill', d => d.inB ? 'var(--ink)' : 'var(--ink-3)').style('font-weight', d => st.focus === d.k ? 700 : 400)
    .transition().duration(DUR)
    .attr('transform', d => { const a = angle(d.k) + angle.bandwidth() / 2, r = d.r + 7, deg = a * 180 / Math.PI; return `translate(${Math.sin(a) * r},${-Math.cos(a) * r}) rotate(${a >= 0 ? deg - 90 : deg + 90})`; })
    .attr('text-anchor', d => angle(d.k) + angle.bandwidth() / 2 >= 0 ? 'start' : 'end').attr('dy', '0.35em');
  tween(roseNum.node(), total, 1);
  roseUnit.text(UNIT[st.denom][1]);
  d3.select('#roseCap').text(`${st.year} · one ray per slice, area ∝ kg CO₂e · dotted: outside the boundary`);
}

/* ------------------------------------------------------------------ I. sankey */
const sk = d3.select('#sankey'), SW = 860, SH = 560, ST = 30, SB = 10, NW = 12;
const COLX = {carrier:150, slice:430, scope:700};
sk.selectAll('text.colhead').data([['Carrier', COLX.carrier], ['Slice of the building', COLX.slice], ['Scope', COLX.scope]]).enter().append('text').attr('class', 'colhead').attr('x', d => d[1] + NW / 2).attr('y', 12).attr('text-anchor', 'middle').text(d => d[0]);
const linkG = sk.append('g'), nodeG = sk.append('g');
function ribbon(p){ const xm = (p.x0 + p.x1) / 2; return `M${p.x0},${p.y0}C${xm},${p.y0} ${xm},${p.y1} ${p.x1},${p.y1}L${p.x1},${p.y1 + p.w}C${xm},${p.y1 + p.w} ${xm},${p.y0 + p.w} ${p.x0},${p.y0 + p.w}Z`; }
function renderSankey(){
  const yr = R.det.years[st.year - Y0], div = divisor(yr.rn);
  const nodes = [], links = [];
  const add = (id, col, label, color, order) => { const n = {id, col, label, color, order, v:0, inL:[], outL:[]}; nodes.push(n); return n; };
  const C = {elec:add('c:elec', 'carrier', CARR.elec[0], CARR.elec[1], 0), fuel:add('c:fuel', 'carrier', CARR.fuel[0], CARR.fuel[1], 1), goods:add('c:goods', 'carrier', CARR.goods[0], CARR.goods[1], 2)};
  const S = {s1:add('s:s1', 'scope', SCOPE.s1[0], SCOPE.s1[1], 0), s2:add('s:s2', 'scope', SCOPE.s2[0], SCOPE.s2[1], 1), s3:add('s:s3', 'scope', SCOPE.s3[0], SCOPE.s3[1], 2)};
  for (const k in S) S[k].sub = SCOPE[k][2];
  SLICES.forEach((s, i) => {
    const x = yr.slices[s.k]; if (!x.inB || x.kg <= 0) return;
    const n = add('m:' + s.k, 'slice', s.short, GRPS[s.grp][1], i); n.k = s.k;
    const parts = [['elec', x.kgE], ['fuel', x.kgF], ['goods', x.kgG]];
    for (const [c, kg] of parts){ if (kg <= 0) continue; const v = kg / div; links.push({src:C[c], dst:n, v, color:CARR[c][1], k:s.k}); links.push({src:n, dst:s.s3 ? S.s3 : S[c === 'elec' ? 's2' : c === 'fuel' ? 's1' : 's3'], v, color:CARR[c][1], k:s.k}); }
  });
  links.forEach(l => { l.src.outL.push(l); l.dst.inL.push(l); });
  nodes.forEach(n => n.v = Math.max(d3.sum(n.inL, l => l.v), d3.sum(n.outL, l => l.v)));
  const live = nodes.filter(n => n.v > 0);
  const cols = d3.group(live, n => n.col);
  const pad = 7, maxN = d3.max([...cols.values()], c => c.length), total = d3.sum(cols.get('slice') || [], n => n.v) || 1;
  const ky = (SH - ST - SB - pad * (maxN - 1)) / total;
  for (const [col, ns] of cols){
    ns.sort((a, b) => a.order - b.order);
    const h = d3.sum(ns, n => Math.max(1.5, n.v * ky)) + pad * (ns.length - 1) * (col === 'slice' ? 1 : 3.5);
    let y = ST + (SH - ST - SB - h) / 2;
    for (const n of ns){ n.x = COLX[col]; n.y = y; n.h = Math.max(1.5, n.v * ky); y += n.h + pad * (col === 'slice' ? 1 : 3.5); }
  }
  live.forEach(n => {
    n.outL.sort((a, b) => a.dst.y - b.dst.y); let o = 0; n.outL.forEach(l => { l.y0 = n.y + o; o += l.v * ky; });
    n.inL.sort((a, b) => a.src.y - b.src.y); let i = 0; n.inL.forEach(l => { l.y1 = n.y + i; i += l.v * ky; });
  });
  links.forEach(l => { l.p = {x0:l.src.x + NW, x1:l.dst.x, y0:l.y0, y1:l.y1, w:Math.max(0.6, l.v * ky)}; l.id = l.src.id + '>' + l.dst.id; });
  sk.classed('dim', !!st.focus);
  const L = linkG.selectAll('path').data(links, l => l.id);
  L.exit().transition().duration(DUR).attrTween('d', function(){ const p0 = this._p, p1 = Object.assign({}, p0, {w:0}); const i = d3.interpolateObject(p0, p1); return t => ribbon(i(t)); }).remove();
  L.enter().append('path').attr('class', 'link').each(function(l){ this._p = Object.assign({}, l.p, {w:0}); })
    .on('mousemove', (ev, l) => showTip(ev, `<b>${esc(l.src.label)} → ${esc(l.dst.label)}</b><br>${fmt(l.v, 2)} kg CO₂e ${UNIT[st.denom][0]}`)).on('mouseleave', hideTip)
    .on('click', (ev, l) => setFocus(st.focus === l.k ? null : l.k))
    .merge(L).attr('fill', l => css(l.color)).classed('hot', l => st.focus === l.k).classed('clickable', true)
    .transition().duration(DUR).attrTween('d', function(l){ const i = d3.interpolateObject(this._p, l.p); this._p = l.p; return t => ribbon(i(t)); });
  const N = nodeG.selectAll('g.node').data(live, n => n.id);
  N.exit().transition().duration(DUR).style('opacity', 0).remove();
  const Ne = N.enter().append('g').attr('class', 'node').style('opacity', 0).attr('transform', n => `translate(${n.x},${n.y})`);
  Ne.append('rect').attr('width', NW);
  Ne.append('text').attr('class', 'nlabel').style('paint-order', 'stroke').style('stroke', 'var(--paper)').style('stroke-width', '3px');
  Ne.append('text').attr('class', 'nval').style('paint-order', 'stroke').style('stroke', 'var(--paper)').style('stroke-width', '3px');
  const Nm = Ne.merge(N).classed('clickable', n => !!n.k)
    .on('click', (ev, n) => { if (n.k) setFocus(st.focus === n.k ? null : n.k); })
    .on('mousemove', (ev, n) => showTip(ev, `<b>${esc(n.label)}</b><br>${fmt(n.v, 2)} kg CO₂e ${UNIT[st.denom][0]} · ${fmt(n.v / total * 100, 1)}%`)).on('mouseleave', hideTip);
  Nm.transition().duration(DUR).style('opacity', 1).attr('transform', n => `translate(${n.x},${n.y})`);
  Nm.select('rect').transition().duration(DUR).attr('height', n => n.h).attr('fill', n => n.k && st.focus === n.k ? 'var(--brass)' : css(n.color));
  /* end columns: name above, value below; middle: name and value on one line, nudged apart so small slices stay legible */
  const mid = live.filter(n => n.col === 'slice').sort((a, b) => a.y - b.y);
  let prev = -Infinity; mid.forEach(n => { n.ly = Math.max(n.y + n.h / 2, prev + 12.5); prev = n.ly; });
  const over = prev - (SH - 4); if (over > 0) mid.forEach(n => n.ly -= over * (n.ly - mid[0].ly) / Math.max(1, prev - mid[0].ly));
  const left = n => n.col === 'carrier';
  Nm.select('text.nlabel').text(n => n.label).attr('text-anchor', n => left(n) ? 'end' : 'start').attr('x', n => left(n) ? -10 : NW + 8)
    .style('font-weight', n => n.k && st.focus === n.k ? 700 : n.col !== 'slice' ? 600 : 400).style('font-size', n => n.col === 'slice' ? '12px' : '13px')
    .transition().duration(DUR).attr('y', n => n.col === 'slice' ? n.ly - n.y : n.h / 2 - 8).attr('dy', '0.35em');
  Nm.select('text.nval').each(function(n){ const t = d3.select(this); t.selectAll('tspan').remove(); t.text(null);
      t.append('tspan').text(fmt(n.v, n.v < 1 ? 2 : 1) + (n.col !== 'slice' ? ' · ' + fmt(n.v / total * 100, 0) + '%' : ''));
      if (n.sub) t.append('tspan').attr('x', NW + 8).attr('dy', '1.3em').text(n.sub); })
    .attr('text-anchor', n => left(n) ? 'end' : 'start')
    .transition().duration(DUR).attr('x', n => n.col === 'slice' ? NW + 8 + n.label.length * 6.3 + 6 : left(n) ? -10 : NW + 8).attr('y', n => n.col === 'slice' ? n.ly - n.y : n.h / 2 + 8).attr('dy', '0.35em');
}

/* ------------------------------------------------------------------ I. benchmarks */
const bench = d3.select('#bench'), BW = 320, BT = 26, BROW = 33;
function renderBench(){
  const d = R.det.years[st.year - Y0];
  const per = d.t * 1000 / d.rn;
  let hc = 0; for (const s of SLICES){ if (s.k === 'food' || s.k === 'foodwaste' || s.k === 'waste' || s.k === 'transfers') continue; hc += d.slices[s.k].kg; }
  hc /= d.rn;
  const rows = BENCH.slice().sort((a, b) => a.v - b.v);
  const x = d3.scaleLinear().domain([0, Math.max(60, per * 1.08)]).range([4, BW - 8]).nice();
  const yB = BT + rows.length * BROW;
  bench.selectAll('*').remove();
  bench.append('g').attr('class', 'axis').attr('transform', `translate(0,${yB})`).call(d3.axisBottom(x).ticks(6).tickSize(3).tickFormat(v => v + ' kg'));
  rows.forEach((r, i) => {
    const g = bench.append('g').attr('transform', `translate(0,${BT + i * BROW})`);
    g.append('text').attr('x', 4).attr('y', 10).style('fill', 'var(--ink-2)').text(r.l);
    g.append('line').attr('x1', x(0)).attr('x2', BW - 8).attr('y1', 21).attr('y2', 21).attr('stroke', 'var(--rule-2)');
    g.append('line').attr('x1', x(0)).attr('x2', x(r.v)).attr('y1', 21).attr('y2', 21).attr('stroke', 'var(--rule)').attr('stroke-width', 2);
    if (r.t === 1) g.append('circle').attr('cx', x(r.v)).attr('cy', 21).attr('r', 4.5).attr('fill', 'var(--ink-2)');
    else g.append('rect').attr('x', x(r.v) - 4).attr('y', 17).attr('width', 8).attr('height', 8).attr('transform', `rotate(45 ${x(r.v)} 21)`).attr('fill', 'var(--c5)');
    g.append('text').attr('class', 'mono').attr('x', BW - 8).attr('y', 10).attr('text-anchor', 'end').style('fill', 'var(--ink-3)').text(fmt(r.v, r.v % 1 ? 1 : 0));
  });
  const mark = (v, solid, label, top) => {
    bench.append('line').attr('x1', x(v)).attr('x2', x(v)).attr('y1', BT - 4).attr('y2', yB).attr('stroke', 'var(--brass)').attr('stroke-width', solid ? 2.5 : 1.5).attr('stroke-dasharray', solid ? null : '4 3').attr('opacity', 0.9);
    const right = x(v) > BW * 0.6;
    bench.append('text').attr('x', x(v) + (right ? -5 : 5)).attr('text-anchor', right ? 'end' : 'start').attr('y', top ? 12 : yB + 30).style('fill', 'var(--brass)').style('font-weight', 700).text(label + ' ' + fmt(v, 1));
  };
  mark(per, true, 'this night', true); mark(hc, false, 'HCMI basis', false);
}

/* ------------------------------------------------------------------ focus */
function setFocus(k){ st.focus = k; toHash(); renderYear(); renderArea(); renderEvidence(); }
function renderFocusPanel(){
  const p = d3.select('#focusPanel'), yr = R.det.years[st.year - Y0], div = divisor(yr.rn);
  d3.select('#focusChip').classed('on', !!st.focus); d3.select('#focusName').text(st.focus ? 'Following: ' + SL[st.focus].short : '');
  if (!st.focus){
    const top = SLICES.filter(s => yr.slices[s.k].inB).map(s => ({s, v:yr.slices[s.k].kg / div})).sort((a, b) => b.v - a.v).slice(0, 5);
    p.html(`<h3>The five largest slices in ${st.year}</h3>` + top.map(t => `<p class="clickable" data-k="${t.s.k}"><b>${esc(t.s.name)}</b> · ${fmt(t.v, 2)} ${UNIT[st.denom][1]}</p>`).join('') + '<p class="fine">Click a slice here, in the fan or in the flow to follow it through every chart, the levers, the evidence and the rules.</p>');
  } else {
    const s = SL[st.focus], x = yr.slices[s.k], tot = yr.t * 1000 / div;
    const levs = LIB.filter(l => l.targets.includes(s.k));
    const nEv = EVID ? EVID.nodes.filter(n => KW[s.k].test(n.t)).length : 0;
    p.html(`<h3>${esc(s.name)}</h3>
      <p>${x.inB ? `<b>${fmt(x.kg / div, 2)}</b> ${UNIT[st.denom][1]} in ${st.year}, ${fmt(x.kg / div / tot * 100, 1)}% of the night.` : 'Outside the boundary you chose; widen it to count this slice.'}</p>
      <p class="fine">Electricity ${fmt(x.kgE / div, 2)} · heat fuel ${fmt(x.kgF / div, 2)} · purchased ${fmt(x.kgG / div, 2)} ${UNIT[st.denom][1]}${s.s3 ? ' · counted as Scope 3 because the laundry is outsourced' : ''}</p>
      <h4>Levers in the library (${levs.length})</h4>${levs.length ? levs.map(l => { const on = st.plan.some(e => e.lib === l.id); return `<p class="clickable" data-lib="${l.id}">${on ? '● ' : '○ '}${esc(l.name)} <span class="fine">${effText(l)}</span></p>`; }).join('') : '<p class="fine">None recorded.</p>'}
      <h4>Evidence</h4><p><a href="#evidence">${nEv} graph nodes</a> mention it.</p>`);
  }
}
d3.select('#focusPanel').on('click', ev => { const a = ev.target.closest('[data-k]'); if (a) return setFocus(a.dataset.k); const l = ev.target.closest('[data-lib]'); if (l) togglePlan(l.dataset.lib); });
d3.select('#focusX').on('click', () => setFocus(null));
function effText(l){ const e = l.effect; if (e.type === 'none') return 'not quantified'; if (e.type === 'fraction_reduction') return `−${Math.round(e.mid * 100)}% (${Math.round(e.low * 100)}–${Math.round(e.high * 100)}%)${l.shares ? ' of a sub-share' : ''}`; if (e.type === 'electrify') return `${Math.round(e.mid * 100)}% electrified at COP ${e.cop}`; if (e.type === 'ef_multiplier') return l.id === 'tier4_recs_zone_j' ? `${Math.round(e.mid * 100)}% of electricity covered on the LL97 line` : 'market-based factor only'; if (e.type === 'occupancy_multiplier') return `occupancy ×${e.mid} for ${l.duration || 1} yr`; if (e.type === 'cap_multiplier') return `cap ×${e.mid}`; return ''; }

/* ------------------------------------------------------------------ II. road: fan, penalties, area, lanes */
const RW = 1240, RL = 70, RR = 30;
const rx = d3.scaleLinear().domain([Y0, Y1]).range([RL, RW - RR]);
function yearFromX(px){ return Math.max(Y0, Math.min(Y1, Math.round(rx.invert(px)))); }
function cursorDrag(svg){ svg.on('click', ev => { const [px] = d3.pointer(ev, svg.node()); if (px >= RL - 10) setYear(yearFromX(px)); }); }

const fan = d3.select('#fan'), FH = 320, FT = 18, FB = 28;
const fy = d3.scaleLinear().range([FH - FB, FT]);
const fanGrid = fan.append('g').attr('class', 'gridl'), fanOver = fan.append('g');
const fanBand = fan.append('path').attr('fill', 'var(--c1)').attr('opacity', 0.16);
const fanBau = fan.append('path').attr('fill', 'none').attr('stroke', 'var(--ink-3)').attr('stroke-width', 1.5).attr('stroke-dasharray', '6 5');
const fanCap = fan.append('path').attr('fill', 'none').attr('stroke', 'var(--ink)').attr('stroke-width', 2);
const fanMed = fan.append('path').attr('fill', 'none').attr('stroke', 'var(--c1)').attr('stroke-width', 3).attr('stroke-linejoin', 'round');
const fanX = fan.append('g').attr('class', 'axis').attr('transform', `translate(0,${FH - FB})`);
const fanY = fan.append('g').attr('class', 'axis').attr('transform', `translate(${RL},0)`);
const fanLab = fan.append('g');
fan.append('text').attr('class', 'mono').attr('x', RL).attr('y', 10).style('fill', 'var(--ink-3)').text('LL97 intensity, kg CO₂e per m² per year');
const fanCur = fan.append('g'); fanCur.append('line').attr('class', 'cursor-line').attr('y1', FT - 6).attr('y2', FH - FB);
fanCur.append('circle').attr('class', 'cursor-knob').attr('r', 7).attr('cy', FT - 6);
const fanDot = fan.append('circle').attr('r', 6).attr('fill', 'var(--c1)').attr('stroke', 'var(--paper)').attr('stroke-width', 2);
const fanTxt = fan.append('text').style('font-weight', 700).style('fill', 'var(--ink)');
fanCur.select('circle').call(d3.drag().on('drag', ev => setYear(yearFromX(ev.x))));
cursorDrag(fan);
function stepPath(vals){ const w = (rx(Y0 + 1) - rx(Y0)) / 2; const pts = []; vals.forEach((v, i) => { const y = YEARS[i]; pts.push([rx(y) - (i ? w : 0), fy(v)]); pts.push([rx(y) + (i < vals.length - 1 ? w : 0), fy(v)]); }); return d3.line()(pts); }
function renderFan(){
  const mc = R.mc.kgm2, caps = R.det.years.map(y => y.cap), bau = R.bau.years.map(y => y.kgm2);
  fy.domain([0, Math.max(120, d3.max(mc, d => d.p90) * 1.06, d3.max(bau) * 1.06)]).nice();
  fanGrid.call(d3.axisLeft(fy).ticks(6).tickSize(-(RW - RL - RR)).tickFormat('')).attr('transform', `translate(${RL},0)`);
  fanY.transition().duration(DUR).call(d3.axisLeft(fy).ticks(6).tickSize(3));
  fanX.call(d3.axisBottom(rx).ticks(16).tickFormat(d3.format('d')).tickSize(3));
  const area = d3.area().x(d => rx(d.y)).y0(d => fy(d.p10)).y1(d => fy(d.p90)).curve(d3.curveMonotoneX);
  const line = d3.line().x((d, i) => rx(YEARS[i])).y(d => fy(d)).curve(d3.curveMonotoneX);
  fanBand.transition().duration(DUR).attr('d', area(mc));
  fanMed.transition().duration(DUR).attr('d', line(mc.map(d => d.p50)));
  fanBau.transition().duration(DUR).attr('d', line(bau));
  fanCap.transition().duration(DUR).attr('d', stepPath(caps));
  const w = (rx(Y0 + 1) - rx(Y0)) * 0.7;
  const ov = fanOver.selectAll('rect').data(mc.map((d, i) => ({y:d.y, v:d.p50, c:caps[i]})).filter(d => d.v > d.c), d => d.y);
  ov.exit().remove();
  ov.enter().append('rect').attr('fill', 'var(--bad)').attr('opacity', 0.15).attr('x', d => rx(d.y) - w / 2).attr('width', w).attr('y', d => fy(d.c)).attr('height', 0)
    .merge(ov).transition().duration(DUR).attr('y', d => fy(d.v)).attr('height', d => Math.max(0, fy(d.c) - fy(d.v)));
  const labs = [{t:'LL97 cap', x:rx(2037.5), y:fy(caps[12]) - 8, c:'var(--ink)'}, {t:'doing nothing', x:rx(Y1) - 4, y:fy(bau[15]) - 8, c:'var(--ink-3)', a:'end'}, {t:'your plan: median and p10–p90', x:rx(2030.6), y:fy(mc[6].p10) + 18, c:'var(--c1)'}];
  const lt = fanLab.selectAll('text').data(labs); lt.enter().append('text').style('font-weight', 600).merge(lt).transition().duration(DUR).attr('x', d => d.x).attr('y', d => d.y).attr('text-anchor', d => d.a || 'start').style('fill', d => d.c).text(d => d.t);
}
function renderFanCursor(){
  const yi = st.year - Y0, m = R.mc.kgm2[yi], c = R.det.years[yi].cap, X = rx(st.year);
  fanCur.transition().duration(reduced ? 0 : 200).attr('transform', `translate(${X},0)`);
  fanDot.transition().duration(reduced ? 0 : 200).attr('cx', X).attr('cy', fy(m.p50));
  fanTxt.attr('x', st.year > 2035 ? X - 12 : X + 12).attr('text-anchor', st.year > 2035 ? 'end' : 'start').attr('y', Math.max(FT + 14, fy(m.p50) - 14)).text(`${fmt(m.p50, 1)} vs cap ${fmt(c, 1)}`);
}

const pen = d3.select('#pen'), PH = 74, py = d3.scaleLinear().range([PH - 18, 8]);
const penX = pen.append('g'), penBars = pen.append('g'), penCur = pen.append('line').attr('class', 'cursor-line').attr('y1', 0).attr('y2', PH - 18);
pen.append('text').attr('class', 'mono').attr('x', RL - 8).attr('y', 22).attr('text-anchor', 'end').style('fill', 'var(--bad)').text('penalty');
const penMax = pen.append('text').attr('class', 'mono').attr('x', RL - 8).attr('y', 36).attr('text-anchor', 'end');
cursorDrag(pen);
function renderPen(){
  const data = R.mc.pen; const mx = Math.max(0.5e6, d3.max(R.bau.years, y => y.pen)); py.domain([0, mx]);
  penMax.text('$' + fmt(mx / 1e6, 1) + 'M max').style('fill', 'var(--ink-3)');
  const w = (rx(Y0 + 1) - rx(Y0)) * 0.62;
  const b = penBars.selectAll('g').data(data, d => d.y);
  const be = b.enter().append('g'); be.append('rect').attr('fill', 'var(--bad)').attr('opacity', 0.85).attr('x', d => rx(d.y) - w / 2).attr('width', w).attr('y', PH - 18).attr('height', 0);
  be.append('text').attr('class', 'mono').attr('text-anchor', 'middle').attr('x', d => rx(d.y));
  const bm = be.merge(b);
  bm.select('rect').on('mousemove', (ev, d) => showTip(ev, `<b>${d.y}</b> LL97 penalty, median $${fmt(d.p50 / 1e6, 2)}M<br><span class="m">p10–p90 $${fmt(d.p10 / 1e6, 2)}–${fmt(d.p90 / 1e6, 2)}M</span>`)).on('mouseleave', hideTip)
    .transition().duration(DUR).attr('y', d => py(d.p50)).attr('height', d => PH - 18 - py(d.p50));
  bm.select('text').transition().duration(DUR).attr('y', d => py(d.p50) - 3).text(d => d.p50 >= 0.05e6 ? fmt(d.p50 / 1e6, 1) : '').style('fill', 'var(--ink-3)');
  penX.selectAll('line').data([0]).enter().append('line').attr('x1', RL).attr('x2', RW - RR).attr('y1', PH - 18).attr('y2', PH - 18).attr('stroke', 'var(--rule)');
}

const ar = d3.select('#area'), AH = 250, AT = 22, AB = 26, ay = d3.scaleLinear().range([AH - AB, AT]);
const arGrid = ar.append('g').attr('class', 'gridl'), arLayers = ar.append('g');
const arBau = ar.append('path').attr('fill', 'none').attr('stroke', 'var(--ink-3)').attr('stroke-width', 1.5).attr('stroke-dasharray', '6 5');
const arX = ar.append('g').attr('class', 'axis').attr('transform', `translate(0,${AH - AB})`), arY = ar.append('g').attr('class', 'axis').attr('transform', `translate(${RL},0)`);
const arTitle = ar.append('text').attr('class', 'mono').attr('x', RL).attr('y', 12).style('fill', 'var(--ink-3)');
const arCur = ar.append('line').attr('class', 'cursor-line').attr('y1', AT - 6).attr('y2', AH - AB);
cursorDrag(ar);
function renderArea(){
  const rows = R.det.years.map(yr => { const o = {y:yr.y}; const div = divisor(yr.rn); for (const s of SLICES) o[s.k] = yr.slices[s.k].inB ? yr.slices[s.k].kg / div : 0; return o; });
  const keys = SLICES.map(s => s.k), series = d3.stack().keys(keys)(rows);
  const bau = R.bau.years.map(y => y.per);
  ay.domain([0, Math.max(d3.max(bau), d3.max(rows, r => d3.sum(keys, k => r[k]))) * 1.08]).nice();
  arGrid.attr('transform', `translate(${RL},0)`).call(d3.axisLeft(ay).ticks(5).tickSize(-(RW - RL - RR)).tickFormat(''));
  arY.transition().duration(DUR).call(d3.axisLeft(ay).ticks(5).tickSize(3));
  arX.call(d3.axisBottom(rx).ticks(16).tickFormat(d3.format('d')).tickSize(3));
  arTitle.text(`What the night is made of: kg CO₂e ${UNIT[st.denom][0]}, stacked by slice, your plan`);
  const area = d3.area().x(d => rx(d.data.y)).y0(d => ay(d[0])).y1(d => ay(d[1])).curve(d3.curveMonotoneX);
  const p = arLayers.selectAll('path').data(series, s => s.key);
  p.enter().append('path').attr('class', 'clickable').attr('stroke', 'var(--paper)').attr('stroke-width', 0.6)
    .on('mousemove', function(ev, s){ const yr = yearFromX(d3.pointer(ev, ar.node())[0]); const d = s[yr - Y0]; showTip(ev, `<b>${esc(SL[s.key].name)}</b> · ${yr}<br>${fmt(d[1] - d[0], 2)} ${UNIT[st.denom][1]}`); }).on('mouseleave', hideTip)
    .on('click', (ev, s) => { ev.stopPropagation(); setFocus(st.focus === s.key ? null : s.key); })
    .merge(p).attr('fill', s => st.focus === s.key ? 'var(--brass)' : css(GRPS[SL[s.key].grp][1])).attr('fill-opacity', s => st.focus && st.focus !== s.key ? 0.25 : 0.85)
    .transition().duration(DUR).attr('d', area);
  arBau.transition().duration(DUR).attr('d', d3.line().x((d, i) => rx(YEARS[i])).y(d => ay(d)).curve(d3.curveMonotoneX)(bau));
  d3.select('#areaLegend').html(Object.values(GRPS).map(g => `<span><i style="background:${css(g[1])}"></i>${esc(g[0])}</span>`).join('') + '<span><span class="ln"></span>doing nothing</span><span><i style="background:var(--brass)"></i>followed slice</span>');
}

const lanes = d3.select('#lanes'), LROW = 24, LTOP = 10;
const CATC = {building:'--c7', wellness:'--c3', fnb:'--c4', laundry:'--c6', guest:'--c6', energy_supply:'--c1', policy:'--c8', shock:'--c2'};
function renderLanes(){
  const plan = st.plan.map((e, i) => ({e, i, l:LIBMAP[e.lib]})).filter(d => d.l);
  const H = Math.max(56, LTOP + plan.length * LROW + 26);
  lanes.attr('viewBox', `0 0 ${RW} ${H}`);
  lanes.selectAll('g.ax').data([0]).join('g').attr('class', 'axis ax').attr('transform', `translate(0,${H - 22})`).call(d3.axisBottom(rx).ticks(16).tickFormat(d3.format('d')).tickSize(3));
  lanes.selectAll('text.ttl').data([0]).join('text').attr('class', 'mono ttl').attr('x', RL - 8).attr('y', LTOP + 6).attr('text-anchor', 'end').style('fill', 'var(--ink-3)').text(plan.length ? 'the plan' : '');
  lanes.selectAll('text.emp').data(plan.length ? [] : [0]).join('text').attr('class', 'emp').attr('x', RL).attr('y', 20).style('fill', 'var(--ink-3)').text('No measures yet. Start from a story below, or click levers in chapter III; they appear here as dots you can drag through time.');
  const g = lanes.selectAll('g.lane-row').data(plan, d => d.e.lib + ':' + d.i);
  g.exit().remove();
  const ge = g.enter().append('g').attr('class', 'lane-row');
  ge.append('line').attr('x1', RL).attr('x2', RW - RR).attr('stroke', 'var(--rule-2)');
  ge.append('rect').attr('class', 'ramp').attr('height', 8).attr('rx', 4);
  ge.append('line').attr('class', 'tail').attr('stroke-width', 2);
  ge.append('text').attr('class', 'lname').attr('dy', '0.35em');
  ge.append('text').attr('class', 'x').attr('x', 20).attr('dy', '0.35em').text('×').on('click', (ev, d) => { st.plan.splice(d.i, 1); planChanged(); });
  ge.append('circle').attr('class', 'dot').attr('r', 7).call(d3.drag()
    .on('drag', function(ev, d){ const y = yearFromX(ev.x); if (y !== d.e.year){ d.e.year = y; planChanged(true); } })
    .on('end', () => planChanged()));
  const gm = ge.merge(g).attr('transform', (d, k) => `translate(0,${LTOP + 8 + k * LROW})`).classed('hot', d => st.focus && d.l.targets.includes(st.focus));
  gm.select('line').attr('y1', 0).attr('y2', 0);
  gm.select('rect.ramp').attr('x', d => rx(d.e.year)).attr('y', -4).attr('width', d => Math.max(0, rx(Math.min(Y1, d.e.year + (d.l.ramp || 1) - 1)) - rx(d.e.year))).attr('fill', d => css(CATC[d.l.cat] || '--c1'));
  gm.select('line.tail').attr('x1', d => rx(d.e.year)).attr('x2', RW - RR).attr('y1', 0).attr('y2', 0).attr('stroke', d => css(CATC[d.l.cat] || '--c1')).attr('stroke-opacity', 0.35);
  gm.select('circle.dot').attr('cx', d => rx(d.e.year)).attr('fill', d => css(CATC[d.l.cat] || '--c1'))
    .on('mousemove', (ev, d) => showTip(ev, `<b>${esc(d.l.name)}</b> from ${d.e.year}<br>${esc(effText(d.l))}<br><span class="m">drag to move in time</span>`)).on('mouseleave', hideTip);
  gm.select('text.lname').attr('x', d => d.e.year > 2034 ? rx(d.e.year) - 14 : rx(d.e.year) + 14).attr('text-anchor', d => d.e.year > 2034 ? 'end' : 'start').text(d => d.l.name + ' · ' + d.e.year).style('paint-order', 'stroke').style('stroke', 'var(--paper)').style('stroke-width', '4px');
  lanes.selectAll('line.lcur').data([0]).join('line').attr('class', 'cursor-line lcur').attr('y1', 0).attr('y2', H - 22).attr('x1', rx(st.year)).attr('x2', rx(st.year)).lower();
  d3.selectAll('#presets .pill').attr('aria-pressed', function(){ return String(+this.dataset.i === matchStory()); });
}
function matchStory(){ const key = p => p.map(e => e.lib + '@' + e.year).sort().join(); const cur = key(st.plan); return STORIES.findIndex(s => key(s.plan.map(([lib, year]) => ({lib, year}))) === cur); }
function renderRoadCursor(){ const X = rx(st.year); penCur.attr('x1', X).attr('x2', X); arCur.attr('x1', X).attr('x2', X); lanes.select('line.lcur').attr('x1', X).attr('x2', X); renderFanCursor(); }

/* ------------------------------------------------------------------ III. levers */
const lv = d3.select('#lever'), LVL = 300, LVR = 840, LVT = 30, LVROW = 19;
function quantified(l){ const t = l.effect.type; return (t === 'fraction_reduction' || t === 'electrify' || t === 'ef_multiplier') && l.cat !== 'shock'; }
function leverSavings(){
  const y = st.year, pick = r => st.levMetric === 'll97' ? r.years[y - Y0].kgm2 : r.years[y - Y0].per;
  const base = pick(simulate(st.plan, null, 1, 1, y));
  return LIB.filter(quantified).map(l => {
    const idx = st.plan.findIndex(e => e.lib === l.id), inPlan = idx >= 0;
    let plan, draws;
    if (inPlan){ const without = st.plan.filter(e => e.lib !== l.id); const w = pick(simulate(without, null, 1, 1, y)); plan = st.plan; draws = s => plan.map((e, i) => i === idx ? s : 1);
      const at = s => w - pick(simulate(plan, draws(s), 1, 1, y)); const e = l.effect; return {l, inPlan, mid:at(1), lo:at(e.low / e.mid), hi:at(e.high / e.mid), year:st.plan[idx].year}; }
    plan = st.plan.concat([{lib:l.id, year:Y0}]); const n = plan.length - 1;
    const at = s => base - pick(simulate(plan, plan.map((e, i) => i === n ? s : 1), 1, 1, y)); const e = l.effect;
    return {l, inPlan, mid:at(1), lo:at(e.low / e.mid), hi:at(e.high / e.mid)};
  }).sort((a, b) => b.mid - a.mid);
}
function renderLevers(){
  const data = leverSavings();
  const H = LVT + data.length * LVROW + 30; lv.attr('viewBox', `0 0 860 ${H}`);
  const xmax = Math.max(0.5, d3.max(data, d => Math.max(d.hi, d.mid))) * 1.06, xmin = Math.min(0, d3.min(data, d => Math.min(d.lo, d.mid)));
  const x = d3.scaleLinear().domain([xmin, xmax]).range([LVL, LVR]).nice();
  const unit = st.levMetric === 'll97' ? 'kg/m² on the LL97 line' : UNIT[st.denom][1];
  lv.selectAll('g.ax').data([0]).join('g').attr('class', 'axis ax').attr('transform', `translate(0,${LVT - 8})`).transition().duration(DUR).call(d3.axisTop(x).ticks(7).tickSize(3));
  lv.selectAll('line.zero').data([0]).join('line').attr('class', 'zero').attr('y1', LVT - 8).transition().duration(DUR).attr('x1', x(0)).attr('x2', x(0)).attr('y2', H - 24);
  lv.selectAll('text.cap').data([0]).join('text').attr('class', 'mono cap').attr('x', LVR).attr('y', H - 6).attr('text-anchor', 'end').style('fill', 'var(--ink-3)').text(`saved in ${st.year}, ${unit}, on top of the plan · levers not in the plan start in 2025`);
  const r = lv.selectAll('g.row').data(data, d => d.l.id);
  const re = r.enter().append('g').attr('class', 'row').attr('transform', (d, i) => `translate(0,${LVT + i * LVROW + LVROW / 2})`);
  re.append('rect').attr('x', 0).attr('y', -LVROW / 2).attr('width', 860).attr('height', LVROW).attr('fill', 'transparent');
  re.append('text').attr('class', 'lab').attr('x', LVL - 12).attr('text-anchor', 'end').attr('dy', '0.35em');
  re.append('line').attr('class', 'wh');
  re.append('circle').attr('class', 'pt').attr('r', 5.5);
  re.append('text').attr('class', 'mono val').attr('dy', '0.35em').style('fill', 'var(--ink-3)');
  const rm = re.merge(r).classed('in', d => d.inPlan).classed('dimmed', d => st.focus && !d.l.targets.includes(st.focus))
    .style('cursor', 'pointer')
    .on('click', (ev, d) => togglePlan(d.l.id))
    .on('mousemove', (ev, d) => { showTip(ev, `<b>${esc(d.l.name)}</b><br>${fmt(d.mid, 2)} (${fmt(d.lo, 2)}–${fmt(d.hi, 2)}) ${esc(unit)}<br><span class="m">${esc(effText(d.l))} · ${d.l.conf} confidence</span>`); renderLevDetail(d); }).on('mouseleave', hideTip);
  rm.transition().duration(DUR).attr('transform', (d, i) => `translate(0,${LVT + i * LVROW + LVROW / 2})`);
  rm.select('text.lab').text(d => (d.l.name.length > 42 ? d.l.name.slice(0, 40) + '…' : d.l.name));
  rm.select('line.wh').attr('stroke', d => css(CATC[d.l.cat] || '--c1')).attr('stroke-opacity', 0.5).transition().duration(DUR).attr('x1', d => x(Math.min(d.lo, d.hi))).attr('x2', d => x(Math.max(d.lo, d.hi)));
  rm.select('circle.pt').attr('stroke', d => css(CATC[d.l.cat] || '--c1')).attr('fill', d => d.inPlan ? css(CATC[d.l.cat] || '--c1') : 'var(--paper)').transition().duration(DUR).attr('cx', d => x(d.mid));
  rm.select('text.val').transition().duration(DUR).attr('x', d => x(Math.max(d.hi, d.mid, d.lo)) + 9).text(d => fmt(d.mid, 2) + (d.inPlan ? ' · in plan from ' + d.year : ''));
  r.exit().remove();
  renderH11();
}
function renderLevDetail(d){ d3.select('#levDetail').html(`<p><b>${esc(d.l.name)}</b></p><p class="fine">${esc(effText(d.l))} · ${d.l.conf} confidence · targets ${d.l.targets.map(t => SL[t] ? SL[t].short : t).join(', ')}</p><p class="fine">${esc(d.l.src)}${d.l.src.length >= 420 ? '…' : ''}</p>`); }
let h11Cache = null;
function renderH11(){
  const key = [st.grid, st.heat, st.bldg].join();
  if (!h11Cache || h11Cache.key !== key){
    const levs = LIB.filter(quantified); let n30 = 0, nAll = 0;
    const bau = simulate([]);
    for (const l of levs){ const r = simulate([{lib:l.id, year:Y0}]); if (r.years[5].kgm2 <= r.years[5].cap) n30++; if (r.overYears === 0) nAll++; }
    h11Cache = {key, n30, nAll, of:levs.length, bau30:bau.years[5]};
  }
  const d = R.det.years[5], h = h11Cache, b = BLDG[st.bldg];
  const bauOk = h.bau30.kgm2 <= h.bau30.cap;
  d3.select('#h11').html(`<b>H11, run live.</b> On the ${esc(b.name)} building (EUI ${fmt(b.eui, 0)} kBtu/ft²), doing nothing is ${bauOk ? 'already under' : 'over'} the 2030 cap (${fmt(h.bau30.kgm2, 1)} vs ${fmt(h.bau30.cap, 1)}). ${h.n30} of ${h.of} single levers, started in 2025, are under it in 2030; ${h.nAll} stay under every cap to 2040. ${st.bldg === 'median' ? 'H11 was written for the peer EUI of 135; switch the building in the console to test it as stated.' : ''} Your plan: 2030 at <b>${fmt(d.kgm2, 1)}</b>, ${d.kgm2 <= d.cap ? '<span style="color:var(--good)">compliant</span>' : '<span style="color:var(--bad)">over</span>'}.`);
}
function renderPolicy(){
  const pol = LIB.filter(l => l.cat === 'shock' || l.effect.type === 'cap_multiplier');
  d3.select('#policy').html(pol.map(l => `<button type="button" class="pill" data-lib="${l.id}" aria-pressed="${st.plan.some(e => e.lib === l.id)}" title="${esc(effText(l))}">${esc(l.name)}</button>`).join(''));
  d3.select('#unq').html(LIB.filter(l => l.effect.type === 'none').map(l => `<li>${esc(l.name)}</li>`).join('') + LIB.filter(l => l.effect.type === 'ef_multiplier' && l.id !== 'tier4_recs_zone_j').map(l => `<li>${esc(l.name)} (market-based only)</li>`).join(''));
}
d3.select('#policy').on('click', ev => { const b = ev.target.closest('[data-lib]'); if (b) togglePlan(b.dataset.lib); });

/* ------------------------------------------------------------------ IV. evidence constellation */
const cs = d3.select('#const'); const TYPEC = {observation:'--c1', option:'--c4', decision:'--c8', outcome:'--c3', revisit:'--c7', action:'--c6', goal:'--ink'};
const TYPER = {observation:5, option:6.5, decision:10, outcome:8.5, revisit:8, action:7, goal:9};
let evSel = null;
function buildEvidence(){
  const groups = [[0], [1], [2], [3], [4], [5], [9], [6, 7, 8, 10]];
  const names = EVID.facets.map(f => f.name); names[6] = 'Building the tools';
  const nodes = []; groups.forEach((g, gi) => g.forEach(fi => EVID.facets[fi].nodes.forEach(n => nodes.push(Object.assign({g:gi, facet:gi === 7 ? 'Building the tools' : names[fi]}, n)))));
  const cx = gi => 115 + (gi % 4) * 223, cy = gi => 172 + Math.floor(gi / 4) * 318;
  const rnd = d3.randomLcg(42);
  nodes.forEach(n => { n.x = cx(n.g) + (rnd() - 0.5) * 20; n.y = cy(n.g) + (rnd() - 0.5) * 20; n.r = TYPER[n.k] || 3; });
  const sim = d3.forceSimulation(nodes).force('x', d3.forceX(n => cx(n.g)).strength(0.09)).force('y', d3.forceY(n => cy(n.g)).strength(0.09)).force('c', d3.forceCollide(n => n.r + 1.6)).force('q', d3.forceManyBody().strength(-1.2)).randomSource(d3.randomLcg(7)).stop();
  for (let i = 0; i < 320; i++) sim.tick();
  EVID.nodes = nodes;
  const gl = groups.map((g, gi) => { const ns = nodes.filter(n => n.g === gi); return {gi, name:gi === 7 ? 'Building the tools' : names[g[0]], n:ns.length, x:cx(gi), top:d3.min(ns, n => n.y - n.r), r:d3.max(ns, n => Math.hypot(n.x - cx(gi), n.y - cy(gi)) + n.r)}; });
  cs.append('g').selectAll('circle').data(gl).enter().append('circle').attr('class', 'halo').attr('cx', d => d.x).attr('cy', d => cy(d.gi)).attr('r', d => d.r + 6);
  const lab = cs.append('g').selectAll('g').data(gl).enter().append('g').attr('transform', d => `translate(${d.x},${cy(d.gi) - d.r - 26})`);
  lab.append('text').attr('class', 'clab').attr('text-anchor', 'middle').text(d => d.name);
  lab.append('text').attr('class', 'ccount').attr('text-anchor', 'middle').attr('y', 13).attr('data-gi', d => d.gi);
  cs.append('g').selectAll('circle').data(nodes).enter().append('circle').attr('class', 'n').attr('cx', n => n.x).attr('cy', n => n.y).attr('r', n => n.r).attr('fill', n => css(TYPEC[n.k] || '--ink-3'))
    .on('mousemove', (ev, n) => showTip(ev, `<span class="m">${n.k} · ${esc(n.facet)}</span><br>${esc(n.t.length > 220 ? n.t.slice(0, 218) + '…' : n.t)}`)).on('mouseleave', hideTip)
    .on('click', (ev, n) => { evSel = n; renderEvDetail(); cs.selectAll('circle.n').classed('sel', m => m === evSel); });
  d3.select('#constLegend').html(Object.entries(TYPEC).filter(([k]) => nodes.some(n => n.k === k)).map(([k, c]) => `<span><i style="background:${css(c)};border-radius:50%"></i>${k}s (${nodes.filter(n => n.k === k).length})</span>`).join(''));
  d3.select('#evDeck').text(`The programme's decision graph: ${EVID.nodes.length} nodes and ${EVID.edges} edges, exported ${EVID.exported.slice(0, 10)}. Observations read from primary sources, the options weighed, the decisions taken and what they beat, gathered by research facet. Focus a slice or search a word and the nodes that speak to it light up; so do the rules derived from them.`);
}
function evMatcher(){ if (st.q) { const q = st.q.toLowerCase(); return {re:{test:s => s.toLowerCase().includes(q)}, label:`“${st.q}”`}; } if (st.focus) return {re:KW[st.focus], label:SL[st.focus].short.toLowerCase()}; return null; }
function renderEvidence(){
  if (!EVID || !EVID.nodes) return;
  const m = evMatcher();
  cs.classed('filtered', !!m);
  cs.selectAll('circle.n').classed('m', n => !!m && m.re.test(n.t));
  cs.selectAll('text.ccount').text(function(){ const gi = +this.dataset.gi; const ns = EVID.nodes.filter(n => n.g === gi); return m ? `${ns.filter(n => m.re.test(n.t)).length} of ${ns.length} mention ${m.label}` : `${ns.length} nodes`; });
  const rs = RULES.map(r => ({r, hit:!!m && m.re.test(r.stmt + ' ' + r.ev.join(' '))}));
  if (m) rs.sort((a, b) => (b.hit - a.hit) || (a.r.n - b.r.n));
  d3.select('#rulesNote').text(m ? `${rs.filter(x => x.hit).length} of ${RULES.length} rules speak to ${m.label}; they are listed first.` : `${RULES.length} rules, ten high confidence and ten medium. Click one for its evidence.`);
  d3.select('#rules').html(rs.map(({r, hit}) => `<li class="${hit ? 'm' : ''}"><span class="rn">${r.n}</span>${esc(r.stmt)}<span class="cf">${r.conf}</span><ul class="ev">${r.ev.map(e => `<li>${esc(e)}</li>`).join('')}</ul></li>`).join(''));
}
function renderEvDetail(){
  const n = evSel; if (!n) return;
  let h = `<span class="tag" style="background:${css(TYPEC[n.k] || '--ink-3')}">${n.k}</span> <span class="fine">${esc(n.facet)}</span><div class="t">${esc(n.t)}</div>`;
  if (n.ch || n.rj) h += '<ul>' + (n.ch || []).map(c => `<li class="ch">${esc(c)}</li>`).join('') + (n.rj || []).map(c => `<li class="rj">${esc(c)}</li>`).join('') + '</ul>';
  d3.select('#evDetail').html(h);
}
d3.select('#rules').on('click', ev => { const li = ev.target.closest('#rules > li'); if (li) li.classList.toggle('open'); });
let qTimer = null;
d3.select('#evq').on('input', function(){ clearTimeout(qTimer); const v = this.value.trim(); qTimer = setTimeout(() => { st.q = v; renderEvidence(); }, 120); });

/* ------------------------------------------------------------------ V. claims */
const CLAIMS = [
  {q:'“Your stay is carbon neutral.”', basis:'Offsets bought from avoidance credits (REDD+, IFM).', before:'cond', after:'no', why:'Already found misleading by courts (KLM, Eurowings, the BGH klimaneutral ruling) where the basis is not explained. From 27 Sep 2026 banned per se in the EU: Directive 2024/825 prohibits neutral, reduced or positive impact claims based on offsetting outside the value chain. West et al. 2023: 6.1% of REDD+ credits additional.'},
  {q:'“We offset every night you stay.”', basis:'Same credits, described as offsetting rather than neutrality.', before:'cond', after:'cond', why:'A factual statement that credits were bought stays lawful if the credits, project and quantity are named and no neutrality is implied. ICVCM excluded legacy REDD+ methodologies in Nov 2024.'},
  {q:'“Book our climate-positive rate.”', basis:'A rate that funds removals or credits beyond the stay’s emissions.', before:'cond', after:'no', why:'“Positive impact” claims based on offsetting outside the value chain fall under the same per se ban from 27 Sep 2026. Durable removals at $180–650/t are a contribution, not a claim basis.'},
  {q:'“We measure every stay and publish it. We do not neutralise.”', basis:'Disclosure of Scope 1, 2 and food, laundry and waste per room-night.', before:'ok', after:'ok', why:'The posture the programme chose. A guest-facing per-stay figure should include food, laundry and waste or be labelled partial; chapter I shows why the label matters.'},
  {q:'“Scope 1 and 2 emissions down 46% since 2019.”', basis:'Absolute reduction against a validated science-based target.', before:'ok', after:'ok', why:'Hilton’s validated SBTs are absolute (−46.2% Scope 1+2 by 2030 vs 2019). Lawful if true, measured consistently (location vs market stated) and not implying neutrality.'},
  {q:'“100% renewable electricity.”', basis:'Market-based RECs or a PPA.', before:'cond', after:'cond', why:'A procurement statement if the instrument is named. LL97 counts only Tier-4 Zone J RECs delivered in the same year; chapter III shows them moving compliance while the location-based footprint stays put. Saying the hotel’s emissions are therefore zero is the claim that fails.'},
  {q:'“Reuse your towel and save the planet.”', basis:'Behavioural nudge on the bathroom card.', before:'ok', after:'ok', why:'Not an environmental claim about the product. Goldstein 2008: descriptive norms lift reuse from 35% to 44–49%; the carbon effect is a few hundredths of a kilogram per night.'}
];
const STL = {ok:'stands', cond:'only if explained', no:'banned in the EU'};
function renderClaims(){
  const y = st.year;
  d3.select('#claimsHead').text(y < 2026 ? `What the hotel may say in ${y}.` : y === 2026 ? 'What the hotel may say in 2026, before and after 27 September.' : `What the hotel may say in ${y}, under the EU claims ban.`);
  const open = new Set(); document.querySelectorAll('#claimList .claim.open').forEach(c => open.add(c.dataset.i));
  d3.select('#claimList').html(CLAIMS.map((c, i) => { const s = y < 2026 ? c.before : c.after; const both = y === 2026 && c.before !== c.after;
    return `<div class="claim ${s === 'no' ? 'no' : ''} ${open.has(String(i)) ? 'open' : ''}" data-i="${i}"><div class="q">${esc(c.q)}</div><div class="b">${esc(c.basis)}</div>${both ? `<span class="st ${c.before}">${STL[c.before]} until 27 Sep</span><span class="st ${c.after}">then ${STL[c.after]}</span>` : `<span class="st ${s}">${STL[s]}</span>`}<div class="w">${esc(c.why)}</div><button type="button">${open.has(String(i)) ? 'Hide' : 'Why'}</button></div>`; }).join(''));
}
d3.select('#claimList').on('click', ev => { const b = ev.target.closest('button'); if (!b) return; const c = b.closest('.claim'); c.classList.toggle('open'); b.textContent = c.classList.contains('open') ? 'Hide' : 'Why'; });

/* ------------------------------------------------------------------ orchestration */
function renderYear(){ renderKpis(); renderRose(); renderSankey(); renderBench(); renderFocusPanel(); renderRoadCursor(); renderLevers(); renderClaims(); renderLanes(); }
function renderAllRoad(){ renderFan(); renderPen(); renderArea(); renderLanes(); renderRoadCursor(); }
function setYear(y){ if (y === st.year) return; st.year = y; d3.select('#year').property('value', y); d3.select('#yearv').text(y); toHash(); renderYear(); }
let fastTimer = null;
function planChanged(fast){
  compute(fast ? 40 : 200); toHash();
  renderAllRoad(); renderKpis(); renderRose(); renderSankey(); renderBench(); renderFocusPanel(); renderPolicy();
  clearTimeout(fastTimer);
  if (fast) return;
  renderLevers();
}
function settingsChanged(){ h11Cache = null; planChanged(); renderEvidence(); }
function togglePlan(id){ const i = st.plan.findIndex(e => e.lib === id); if (i >= 0) st.plan.splice(i, 1); else st.plan.push({lib:id, year:st.year}); planChanged(); }
function syncControls(){
  d3.select('#year').property('value', st.year); d3.select('#yearv').text(st.year);
  [['#boundSeg', 'boundary'], ['#denomSeg', 'denom'], ['#heatSeg', 'heat'], ['#levMetric', 'levMetric']].forEach(([sel, k]) => d3.selectAll(sel + ' button').attr('aria-pressed', function(){ return String(this.dataset.v === st[k]); }));
  d3.select('#gridSel').property('value', st.grid); d3.select('#bldgSel').property('value', st.bldg);
}
function bindSeg(sel, k, after){ d3.select(sel).on('click', ev => { const b = ev.target.closest('button[data-v]'); if (!b || st[k] === b.dataset.v) return; st[k] = b.dataset.v; syncControls(); after(); }); }

let playing = null;
function stopPlay(){ clearInterval(playing); playing = null; d3.select('#playIcon').attr('d', 'M2 1 L11 6 L2 11 Z'); }
d3.select('#play').on('click', () => {
  if (playing) return stopPlay();
  if (st.year >= Y1) setYear(Y0);
  d3.select('#playIcon').attr('d', 'M2 1 H5 V11 H2 Z M7 1 H10 V11 H7 Z');
  playing = setInterval(() => { if (st.year >= Y1) return stopPlay(); setYear(st.year + 1); }, reduced ? 900 : 700);
});

Promise.all([d3.json('/static/hotel-carbon/ledger.json'), d3.json('/static/hotel-carbon/data.json')]).then(([a, b]) => {
  LIB = a.lib; LIBMAP = Object.fromEntries(LIB.map(l => [l.id, l])); EVID = a.evidence; RULES = b.rules;
  const missing = STORIES.flatMap(s => s.plan.map(p => p[0])).filter(id => !LIBMAP[id]);
  if (missing.length) throw new Error('Story references unknown levers: ' + missing.join(', '));
  if (!fromHash()) st.plan = [];
  d3.select('#bldgSel').html(Object.entries(BLDG).map(([k, b]) => `<option value="${k}">${esc(b.name)} · EUI ${fmt(b.eui, 0)}</option>`).join(''));
  d3.select('#gridSel').html(Object.entries(GRIDS).map(([k, g]) => `<option value="${k}">${esc(g.name)}</option>`).join(''));
  syncControls();
  d3.select('#presets').selectAll('button').data(STORIES).enter().append('button').attr('type', 'button').attr('class', 'pill').attr('data-i', (d, i) => i).text(d => d.name)
    .on('click', (ev, d) => { st.plan = d.plan.map(([lib, year]) => ({lib, year})); planChanged(); });
  bindSeg('#boundSeg', 'boundary', settingsChanged); bindSeg('#denomSeg', 'denom', settingsChanged); bindSeg('#heatSeg', 'heat', settingsChanged);
  bindSeg('#levMetric', 'levMetric', renderLevers);
  d3.select('#gridSel').on('change', function(){ st.grid = this.value; settingsChanged(); });
  d3.select('#bldgSel').on('change', function(){ st.bldg = this.value; settingsChanged(); });
  d3.select('#year').on('input', function(){ stopPlay(); setYear(+this.value); });
  buildEvidence();
  compute(200); renderAllRoad(); renderYear(); renderPolicy(); renderEvidence(); toHash();
}).catch(err => {
  d3.select('main').insert('div', ':first-child').attr('class', 'panel').style('margin-top', '20px').style('border-color', 'var(--bad)').html('<b>The ledger could not start.</b> <span class="mono">' + esc(err && err.message || err) + '</span>');
  throw err;
});
})();
