/* One Night at the Waldorf — scenes drawn with D3 v7 (window.d3 from /static/d3.v7.min.js). */
(function(){
  'use strict';
  var esc = function(s){ return String(s).replace(/[&<>"]/g, function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]; }); };
  var fmt = function(n,d){ if(!isFinite(n)) return '–'; return n.toLocaleString('en-US',{minimumFractionDigits:d,maximumFractionDigits:d}); };
  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var DUR = reduced ? 0 : 500;
  var COLORS = ['var(--c1)','var(--c2)','var(--c3)','var(--c4)','var(--c5)','var(--c6)','var(--c7)','var(--c8)'];
  function tweenText(sel, to, d){ var node = sel.node ? sel.node() : sel; var from = parseFloat((node.textContent||'0').replace(/,/g,''))||0; if (!DUR){ node.textContent = fmt(to,d); return; } d3.select(node).transition().duration(DUR).tween('t', function(){ var i = d3.interpolateNumber(from,to); return function(t){ node.textContent = fmt(i(t), d); }; }); }
  var tip = d3.select('body').append('div').attr('class','tip').attr('hidden',true);
  function showTip(ev, html){ tip.html(html).attr('hidden',null); var x = ev.pageX+14, y = ev.pageY+14; if (x+310 > window.scrollX+document.documentElement.clientWidth) x = ev.pageX-320; tip.style('left',x+'px').style('top',y+'px'); }
  function hideTip(){ tip.attr('hidden',true); }

  /* ---------- model: eighteen slices of a 375-key NYC luxury hotel ---------- */
  var RN0 = 104025, GFA = 33750;
  var S = [
    {k:'heat',name:'Space heating',grp:'Base building',elec:0,fuel:1668.6},
    {k:'cool',name:'Space cooling',grp:'Base building',elec:639.9,fuel:0},
    {k:'vent',name:'Ventilation',grp:'Base building',elec:1328.4,fuel:0},
    {k:'dhw',name:'Water heating',grp:'Base building',elec:0,fuel:1757.7},
    {k:'light',name:'Lighting',grp:'Base building',elec:769.5,fuel:0},
    {k:'bother',name:'Refrigeration, plug, other',grp:'Base building',elec:1275.7,fuel:660.2},
    {k:'elev',name:'Elevators',grp:'Base building',elec:49,fuel:0},
    {k:'pool',name:'Pool',grp:'Wellness',elec:75,fuel:175},
    {k:'sauna',name:'Sauna and steam',grp:'Wellness',elec:61.7,fuel:0},
    {k:'gym',name:'Fitness centre',grp:'Wellness',elec:22.4,fuel:9.6},
    {k:'spa',name:'Spa',grp:'Wellness',elec:300,fuel:200},
    {k:'laundry',name:'Laundry (outsourced)',grp:'Laundry',elec:219,fuel:658,s3:true},
    {k:'kitchen',name:'Kitchen and bar energy',grp:'Kitchen',elec:266,fuel:347},
    {k:'minibar',name:'Minibars',grp:'Base building',elec:84.4,fuel:0},
    {k:'food',name:'Purchased food and drink',grp:'Food',t3:936},
    {k:'foodwaste',name:'Food waste disposal',grp:'Waste',t3:47},
    {k:'waste',name:'Other solid waste',grp:'Waste',t3:307},
    {k:'transfers',name:'Guest ground transfers',grp:'Transfers',t3:RN0*20*0.319/1000}
  ];
  var GROUPS = ['Base building','Wellness','Laundry','Kitchen','Food','Waste','Transfers'];
  var GCOL = d3.scaleOrdinal().domain(GROUPS).range(COLORS);
  var EF_GAS = 0.183;
  function kgPerNight(o){ var tot=0, by={}; S.forEach(function(s){ if(!o.inB(s)) return; var r=(o.red&&o.red[s.k])||0; var el=(s.elec||0)*(1-r), fu=(s.fuel||0)*(1-r), t3=(s.t3||0)*(1-r); if (o.electrify&&o.electrify[s.k]){ el += fu/o.electrify[s.k]; fu=0; } var kg=(el*1000*o.ef + fu*1000*EF_GAS + t3*1000)/RN0; by[s.k]=kg; tot+=kg; }); return {tot:tot, by:by}; }
  var B = { s12:function(s){ return !s.t3 && !s.s3; }, hcmi:function(s){ return !s.t3; }, food:function(s){ return !s.t3 || s.k==='food'; }, waste:function(s){ return s.k!=='transfers'; }, all:function(){ return true; } };

  /* ---------- hero ---------- */
  var CH = [['s12','Fuel burned + electricity bought'],['hcmi','+ outsourced laundry'],['food','+ food and drink purchased'],['waste','+ food waste and bins'],['all','+ chauffeured transfers']];
  var heroLevel = 0;
  var heroSvg = d3.select('#heroStack').attr('viewBox','0 0 720 140');
  function renderHero(){
    var r = kgPerNight({ef:0.392, inB:B[CH[heroLevel][0]]});
    var chips = d3.select('#chips').selectAll('button').data(CH); chips.enter().append('button').attr('class','chip').attr('type','button').on('click', function(e,d){ heroLevel = CH.indexOf(d); renderHero(); }).merge(chips).attr('aria-pressed', function(d,i){ return String(i<=heroLevel); }).html(function(d){ return esc(d[1])+'<span class="d">'+fmt(kgPerNight({ef:0.392, inB:B[d[0]]}).tot,1)+'</span>'; });
    tweenText(d3.select('#heroNum'), r.tot, 1);
    var groups = GROUPS.map(function(g){ return {g:g, v: S.filter(function(s){ return s.grp===g; }).reduce(function(a,s){ return a+(r.by[s.k]||0); },0)}; }).filter(function(d){ return d.v>0; });
    var x = d3.scaleLinear().domain([0, Math.max(45, kgPerNight({ef:0.392, inB:B.all}).tot)]).range([0,720]);
    var stack = []; var acc=0; groups.forEach(function(g){ stack.push({g:g.g, x0:acc, x1:acc+g.v, v:g.v}); acc+=g.v; });
    var bars = heroSvg.selectAll('rect.seg').data(stack, function(d){ return d.g; });
    bars.enter().append('rect').attr('class','seg').attr('y',20).attr('height',56).attr('x', function(d){ return x(d.x0); }).attr('width',0).attr('fill', function(d){ return GCOL(d.g); }).on('mousemove', function(e,d){ showTip(e, '<b>'+esc(d.g)+'</b><br>'+fmt(d.v,1)+' kg CO₂e per room-night'); }).on('mouseleave', hideTip)
      .merge(bars).transition().duration(DUR).attr('x', function(d){ return x(d.x0)+ (d.x0?1:0); }).attr('width', function(d){ return Math.max(0, x(d.x1)-x(d.x0)-(d.x0?1:0)); });
    bars.exit().transition().duration(DUR).attr('width',0).remove();
    var ticks = heroSvg.selectAll('g.axis').data([0]); var ax = ticks.enter().append('g').attr('class','axis').attr('transform','translate(0,84)').merge(ticks); ax.call(d3.axisBottom(x).ticks(9).tickSize(4).tickFormat(function(v){ return v+' kg'; })); ax.select('.domain').attr('stroke','var(--rule)');
    var labels = heroSvg.selectAll('text.lbl').data(stack, function(d){ return d.g; });
    labels.enter().append('text').attr('class','lbl mono').attr('y',14).merge(labels).transition().duration(DUR).attr('x', function(d){ return x(d.x0)+4; }).text(function(d){ return (x(d.x1)-x(d.x0) > 54) ? fmt(d.v,1) : ''; });
    labels.exit().remove();
    d3.select('#heroLegend').html(groups.map(function(g){ return '<span><i style="background:'+GCOL(g.g)+'"></i>'+esc(g.g)+'</span>'; }).join(''));
  }
  renderHero();

  /* ---------- scene 1: ranking ---------- */
  var ARCH = [
    {name:'Two-star · 60 rooms · one bar',occ:30,fixedKWh:38,varKWh:22,m2:35,guests:1.9,color:COLORS[2]},
    {name:'Four-star · 150 rooms · restaurant',occ:95,fixedKWh:55,varKWh:38,m2:60,guests:1.8,color:COLORS[0]},
    {name:'Five-star · 375 rooms · spa, pool, ballroom',occ:50,fixedKWh:150,varKWh:50,m2:90,guests:1.6,color:COLORS[1]}
  ];
  var denom='room';
  function archVal(a){ var occ=a.occ/100; var kwh = a.fixedKWh/Math.max(occ,0.05)+a.varKWh; var kg = kwh*0.28; if (denom==='room') return kg; if (denom==='guest') return kg/a.guests; return kg*365*occ/a.m2; }
  var rankSvg = d3.select('#rank').attr('viewBox','0 0 720 220');
  function renderRank(){
    var data = ARCH.map(function(a,i){ return {i:i,a:a,v:archVal(a)}; }).sort(function(p,q){ return q.v-p.v; });
    var y = d3.scaleBand().domain(data.map(function(d){ return d.i; })).range([10,200]).padding(0.28);
    var x = d3.scaleLinear().domain([0, d3.max(data, function(d){ return d.v; })*1.15]).range([250,700]);
    var g = rankSvg.selectAll('g.row').data(data, function(d){ return d.i; });
    var ge = g.enter().append('g').attr('class','row');
    ge.append('rect').attr('class','bar').attr('x',250).attr('height',y.bandwidth()).attr('width',0).attr('fill', function(d){ return d.a.color; });
    ge.append('text').attr('class','name').attr('x',240).attr('text-anchor','end').attr('dy','0.35em').style('font-weight',600).style('fill','var(--ink)');
    ge.append('text').attr('class','meta mono').attr('x',240).attr('text-anchor','end').attr('dy','1.6em');
    ge.append('text').attr('class','val mono').attr('dy','0.35em').style('fill','var(--ink)').style('font-size','13px');
    ge.append('text').attr('class','pos').attr('x',6).attr('dy','0.35em').style('font-weight',800).style('font-size','22px').style('fill','var(--ink-3)');
    var m = ge.merge(g); var t = m.transition().duration(DUR*1.2).ease(d3.easeCubicOut);
    t.attr('transform', function(d){ return 'translate(0,'+y(d.i)+')'; });
    t.select('rect.bar').attr('height',y.bandwidth()).attr('width', function(d){ return Math.max(2, x(d.v)-250); });
    m.select('text.name').attr('y', y.bandwidth()/2 - 8).text(function(d){ return d.a.name.split(' · ')[0]; });
    m.select('text.meta').attr('y', y.bandwidth()/2 - 8).text(function(d){ return d.a.name.split(' · ').slice(1).join(', ')+' · '+d.a.occ+'% occupied'; });
    t.select('text.val').attr('x', function(d){ return x(d.v)+8; }).attr('y', y.bandwidth()/2).text(function(d){ return fmt(d.v, denom==='m2'?0:1)+(denom==='m2'?' kg/m²':' kg'); });
    m.select('text.pos').attr('y', y.bandwidth()/2).text(function(d,i){ return i+1; });
    d3.select('#rankNote').text(denom==='room' ? 'Per occupied room-night: the half-empty two-star out-emits the busy five-star.' : denom==='guest' ? 'Per guest-night: couples and spa groups halve the five-star’s figure.' : 'Per square metre per year: small rooms and big rooms swap places. This is the denominator LL97 uses.');
  }
  d3.select('#rankCtl').html(ARCH.map(function(a,i){ return '<label class="rctl"><i style="background:'+a.color+'"></i><input type="range" min="20" max="100" step="1" value="'+a.occ+'" data-i="'+i+'" aria-label="Occupancy of '+esc(a.name)+'"><span class="v" id="rv'+i+'">'+a.occ+'%</span></label>'; }).join(''));
  d3.select('#rankCtl').on('input', function(ev){ var inp = ev.target.closest('input[data-i]'); if(!inp) return; var i=+inp.getAttribute('data-i'); ARCH[i].occ=+inp.value; document.getElementById('rv'+i).textContent = inp.value+'%'; renderRank(); });
  d3.select('#denomSeg').on('click', function(ev){ var b=ev.target.closest('button[data-d]'); if(!b) return; denom=b.getAttribute('data-d'); d3.select(this).selectAll('button').attr('aria-pressed', function(){ return String(this===b); }); renderRank(); });
  renderRank();

  /* ---------- scene 2: dial ---------- */
  var NOTCH = [[0.02,'CLCPA 2040'],[0.145,'LL97 2030–34'],[0.226,'Ireland'],[0.276,'EU average'],[0.289,'LL97 2024–29'],[0.392,'eGRID NYCW'],[0.58,'UK 2008']];
  var dial = d3.select('#dial').attr('viewBox','0 0 480 320'); var efr = document.getElementById('efr');
  var A0 = Math.PI*1.15, A1 = -Math.PI*0.15, CX=240, CY=200, R=150;
  var angOf = function(v){ return A0 + (A1-A0)*(v-0.02)/(0.6-0.02); };
  var arc = d3.arc().innerRadius(R-9).outerRadius(R+9).cornerRadius(9);
  var toD3 = function(a){ return Math.PI/2 - a; }; /* math angle -> d3 clockwise-from-12 */
  var baseEnergyOnly = kgPerNight({ef:0.392, inB:B.hcmi}).tot;
  dial.append('path').attr('class','track').attr('d', arc({startAngle:toD3(A0), endAngle:toD3(A1)})).attr('transform','translate('+CX+','+CY+')').attr('fill','var(--rule)');
  var valPath = dial.append('path').attr('transform','translate('+CX+','+CY+')').attr('fill','var(--ink)');
  NOTCH.forEach(function(n){ var a=angOf(n[0]); var p=[CX+Math.cos(a)*(R+16), CY-Math.sin(a)*(R+16)], q=[CX+Math.cos(a)*(R+24), CY-Math.sin(a)*(R+24)], t=[CX+Math.cos(a)*(R+44), CY-Math.sin(a)*(R+44)]; dial.append('line').attr('x1',p[0]).attr('y1',p[1]).attr('x2',q[0]).attr('y2',q[1]).attr('stroke','var(--ink-3)'); dial.append('text').attr('class','mono').attr('x',t[0]).attr('y',t[1]).attr('text-anchor','middle').attr('dy','0.35em').text(n[1]); });
  var knob = dial.append('circle').attr('r',12).attr('fill','var(--paper)').attr('stroke','var(--ink)').attr('stroke-width',3).style('cursor','grab');
  var bigT = dial.append('text').attr('x',CX).attr('y',CY-4).attr('text-anchor','middle').style('font-size','56px').style('font-weight',800).style('letter-spacing','-0.04em').style('fill','var(--ink)');
  dial.append('text').attr('x',CX).attr('y',CY+22).attr('text-anchor','middle').text('kg CO₂e per room-night, energy only');
  var efT = dial.append('text').attr('class','mono').attr('x',CX).attr('y',CY+42).attr('text-anchor','middle');
  var lever = d3.select('#leverSvg').attr('viewBox','0 0 400 44');
  var lx = d3.scaleLinear().domain([0,12]).range([0,400]);
  lever.append('rect').attr('x',0).attr('y',14).attr('width',400).attr('height',16).attr('fill','var(--rule-2)');
  lever.append('rect').attr('x',lx(0.3)).attr('y',14).attr('width',lx(1.0)-lx(0.3)).attr('height',16).attr('fill','var(--c1)');
  var leverBar = lever.append('rect').attr('x',0).attr('y',14).attr('height',16).attr('width',0).attr('fill','var(--ink)').attr('opacity',.85);
  var leverTxt = lever.append('text').attr('class','mono').attr('x',0).attr('y',10).style('fill','var(--ink)');
  lever.append('text').attr('class','mono').attr('x',400).attr('y',42).attr('text-anchor','end').text('12 kg');
  function renderDial(){ var ef=+efr.value; var a=angOf(ef); valPath.transition().duration(reduced?0:120).attr('d', arc({startAngle:toD3(A0), endAngle:toD3(a)})); knob.attr('cx', CX+Math.cos(a)*R).attr('cy', CY-Math.sin(a)*R); var v=kgPerNight({ef:ef, inB:B.hcmi}).tot; bigT.text(fmt(v,1)); efT.text(ef.toFixed(3)+' kg CO₂e per kWh'); d3.select('#efv').text(ef.toFixed(3)); var delta=Math.abs(v-baseEnergyOnly); leverBar.transition().duration(reduced?0:120).attr('width', Math.min(400, lx(delta))); leverTxt.attr('x', Math.min(340, lx(delta))).text((v>=baseEnergyOnly?'+':'−')+fmt(delta,1)+' kg'); }
  efr.addEventListener('input', renderDial);
  d3.select('#presets').html(NOTCH.map(function(n){ return '<button type="button" data-v="'+n[0]+'">'+esc(n[1])+' '+n[0]+'</button>'; }).join('')).on('click', function(ev){ var b=ev.target.closest('button[data-v]'); if(!b) return; efr.value=b.getAttribute('data-v'); renderDial(); });
  knob.call(d3.drag().on('drag', function(ev){ var x=ev.x-CX, y=CY-ev.y; var a=Math.atan2(y,x); if (a<-Math.PI*0.5) a+=2*Math.PI; var k=(A0-a)/(A0-A1); k=Math.max(0,Math.min(1,k)); efr.value=(0.02+k*0.58).toFixed(3); renderDial(); }));
  dial.on('click', function(ev){ if (ev.target===knob.node()) return; var p=d3.pointer(ev, dial.node()); var x=p[0]-CX, y=CY-p[1]; if (Math.hypot(x,y) < R-40) return; var a=Math.atan2(y,x); if (a<-Math.PI*0.5) a+=2*Math.PI; var k=(A0-a)/(A0-A1); k=Math.max(0,Math.min(1,k)); efr.value=(0.02+k*0.58).toFixed(3); renderDial(); });
  renderDial();

  /* ---------- scene 3: building ---------- */
  var LEV = {
    heat:[{n:'Occupancy-based guestroom controls',f:0.11,r:'6–16%',s:'DOE/PNNL 2012: 18.4% of guestroom HVAC × 60% guestroom share'},{n:'Heat pumps replace gas boilers (COP 3)',f:0.70,r:'60–75%',s:'Electrify at COP 3 on the eGRID factor; assumption'}],
    cool:[{n:'Occupancy-based guestroom controls',f:0.11,r:'6–16%',s:'DOE/PNNL 2012'}],
    vent:[{n:'Occupancy-based guestroom controls',f:0.11,r:'6–16%',s:'DOE/PNNL 2012'},{n:'Kitchen demand-controlled ventilation',f:0.075,r:'~8%',s:'50% of kitchen exhaust energy; kitchen share of ventilation assumed 15%'}],
    dhw:[{n:'Heat-pump water heating (COP 3)',f:0.70,r:'60–75%',s:'CBECS: water heating is the largest lodging end use; COP assumption'},{n:'Opt-out housekeeping',f:0.04,r:'2–6%',s:'Sheraton Boston: 25,000 BTU gas per skipped night'}],
    light:[{n:'LED retrofit',f:0.33,r:'7–60%',s:'HES 2011 potential; low confidence'},{n:'Bathroom occupancy sensors',f:0.056,r:'4–7%',s:'PG&E ET 0609: 76–154 kWh/room/yr'}],
    bother:[{n:'Minibar compressor swap',f:0.05,r:'~5%',s:'Dometic absorption 236–265 kWh/yr → compressor 1/3'}],
    elev:[{n:'Regenerative drives and standby',f:0.35,r:'30–40%',s:'Sachs 2005; low confidence'}],
    pool:[{n:'Cover, heat recovery, setpoint',f:0.31,r:'28–33%',s:'Kampel 2013/2016: 28% national potential'}],
    sauna:[{n:'Scheduling and duty',f:0.33,r:'33–42%',s:'Hours cut; low confidence'}],
    gym:[{n:'Energy-generating cardio',f:0.005,r:'<1%',s:'SportsArt ECO-POWR; negligible'}],
    spa:[{n:'Setpoint management',f:0,r:'unquantified',s:'No measured spa benchmark in the evidence base'}],
    laundry:[{n:'Central laundry plant',f:0.5,r:'38–60%',s:'UK trade 1.6–1.7 → 0.8–1.0 kWh/kg; TRSA 1.57'},{n:'Towel-reuse norm cards',f:0.03,r:'2–4%',s:'Goldstein 2008: 35.1 → 44.1–49.3% reuse; towels 35% of linen'}],
    kitchen:[{n:'High-efficiency equipment',f:0.3,r:'20–40%',s:'ENERGY STAR commercial kitchen'},{n:'Hot-holding elimination',f:0.16,r:'16%',s:'Audit figure'}],
    minibar:[{n:'Remove minibars',f:1.0,r:'100%',s:'~70% of guests never use one'}],
    food:[{n:'Low-carbon menu design',f:0.21,r:'16–31%',s:'Cool Food pledge; Clune medians'},{n:'Carbon labels on menus',f:0.036,r:'0–5%',s:'Brunner 2018: −3.6%'},{n:'Food-waste programme (purchases)',f:0.021,r:'~2%',s:'Champions 12.3'}],
    foodwaste:[{n:'Organics to composting',f:0.986,r:'99%',s:'DEFRA 0.627 → 0.009 kg/kg'},{n:'Buffet → plated service',f:0.46,r:'42–50%',s:'Camilleri-Fenech 2020'}],
    waste:[{n:'Recycling diversion to 45%',f:0.2,r:'~20%',s:'Attari 2026: 22–45% diversion'}],
    transfers:[{n:'Electric fleet',f:0.88,r:'62–100%',s:'DEFRA 2024 BEV tailpipe 0'}]
  };
  var ZONES = [
    {id:'roof',label:'Roof plant',x:150,y:14,w:260,h:28,slices:['vent','cool']},
    {id:'rooms',label:'Guest floors ×22',x:150,y:44,w:260,h:210,slices:['heat','light','bother','minibar','elev']},
    {id:'spaz',label:'Spa, thermal suite',x:150,y:256,w:130,h:52,slices:['spa','sauna']},
    {id:'gymz',label:'Fitness',x:282,y:256,w:128,h:52,slices:['gym']},
    {id:'lobby',label:'Lobby, ballroom, restaurants',x:110,y:310,w:340,h:62,slices:['food','kitchen']},
    {id:'poolz',label:'Pool',x:110,y:374,w:120,h:56,slices:['pool']},
    {id:'laund',label:'Laundry (outsourced)',x:232,y:374,w:110,h:56,slices:['laundry']},
    {id:'boiler',label:'Boilers, DHW, CHP',x:344,y:374,w:106,h:56,slices:['dhw']},
    {id:'bins',label:'Dock, bins, transfers',x:110,y:432,w:340,h:46,slices:['waste','foodwaste','transfers']}
  ];
  var on = {}, selZone = null;
  function levState(){ var red={}; S.forEach(function(s){ var r=0; (LEV[s.k]||[]).forEach(function(l,i){ if(on[s.k+':'+i]) r=1-(1-r)*(1-l.f); }); red[s.k]=r; }); return red; }
  var house = d3.select('#house').attr('viewBox','0 0 560 520');
  house.append('rect').attr('x',100).attr('y',8).attr('width',360).attr('height',480).attr('fill','none').attr('stroke','var(--ink)').attr('stroke-width',1.5);
  var zg = house.selectAll('g.zone').data(ZONES).enter().append('g').attr('class','zone').style('cursor','pointer').on('click', function(e,d){ selZone=d.id; renderBuilding(); }).on('mousemove', function(e,d){ showTip(e,'<b>'+esc(d.label)+'</b><br>'+fmt(zoneKg(d, lastR),1)+' kg per room-night'); }).on('mouseleave', hideTip);
  zg.append('rect').attr('class','zr').attr('x',function(d){return d.x;}).attr('y',function(d){return d.y;}).attr('width',function(d){return d.w;}).attr('height',function(d){return d.h;}).attr('fill','var(--rule-2)').attr('stroke','var(--rule)');
  zg.filter(function(d){ return d.id==='rooms'; }).each(function(d){ var g=d3.select(this); for (var fy=0; fy<7; fy++) for (var fx=0; fx<8; fx++) g.append('rect').attr('class','win').attr('x',d.x+14+fx*31).attr('y',d.y+12+fy*28).attr('width',14).attr('height',12).attr('fill','var(--c4)').attr('opacity',.7); });
  zg.append('text').attr('x',function(d){return d.x+8;}).attr('y',function(d){return d.y+14;}).style('fill','var(--ink)').text(function(d){ return d.label; });
  zg.append('text').attr('class','kg mono').attr('x',function(d){return d.x+d.w-8;}).attr('y',function(d){return d.y+d.h-8;}).attr('text-anchor','end').style('fill','var(--ink)');
  house.append('text').attr('class','mono').attr('x',280).attr('y',505).attr('text-anchor','middle').text('375 keys · 33,750 m² · 76% occupancy · gas heat · eGRID 0.392');
  var zbars = d3.select('#zonebars').attr('viewBox','0 0 420 300');
  var lastR = kgPerNight({ef:0.392, inB:B.waste});
  function zoneKg(z, r){ return z.slices.reduce(function(a,k){ return a+(r.by[k]||0); },0); }
  function renderBuilding(){
    var red=levState(); var r=kgPerNight({ef:0.392, inB:B.waste, red:red}); var base=kgPerNight({ef:0.392, inB:B.waste}); lastR=r;
    tweenText(d3.select('#bldgNum'), r.tot, 1);
    zg.classed('sel', function(d){ return d.id===selZone; });
    zg.select('rect.zr').transition().duration(DUR).attr('fill', function(d){ var k=zoneKg(d,r), k0=zoneKg(d,base); return d.id===selZone ? 'var(--hl)' : (k < k0-0.05 ? 'var(--paper)' : 'var(--rule-2)'); }).attr('stroke', function(d){ return d.id===selZone ? 'var(--ink)' : 'var(--rule)'; }).attr('stroke-dasharray', function(d){ return zoneKg(d,r) < zoneKg(d,base)-0.05 ? '3 3' : null; });
    zg.selectAll('rect.win').transition().duration(DUR).attr('opacity', function(){ var z=ZONES[1]; return 0.15 + 0.55*zoneKg(z,r)/Math.max(zoneKg(z,base),0.001); });
    zg.select('text.kg').text(function(d){ var k=zoneKg(d,r), k0=zoneKg(d,base); return fmt(k,1)+' kg'+(k<k0-0.05?' ↓'+fmt(k0-k,1):''); });
    var data = ZONES.map(function(z){ return {z:z, v:zoneKg(z,r), v0:zoneKg(z,base)}; });
    var y = d3.scaleBand().domain(ZONES.map(function(z){return z.id;})).range([6,290]).padding(0.3); var x = d3.scaleLinear().domain([0, d3.max(data,function(d){return d.v0;})*1.1]).range([150,410]);
    var rows = zbars.selectAll('g.r').data(data, function(d){return d.z.id;}); var re = rows.enter().append('g').attr('class','r').attr('transform', function(d){ return 'translate(0,'+y(d.z.id)+')'; }).style('cursor','pointer').on('click', function(e,d){ selZone=d.z.id; renderBuilding(); });
    re.append('text').attr('x',142).attr('text-anchor','end').attr('dy', y.bandwidth()/2+4).style('fill','var(--ink-2)').text(function(d){ return d.z.label; });
    re.append('rect').attr('class','ghost').attr('x',150).attr('height',y.bandwidth()).attr('fill','var(--rule-2)');
    re.append('rect').attr('class','b').attr('x',150).attr('height',y.bandwidth()).attr('fill','var(--ink)');
    re.append('text').attr('class','v mono').attr('dy', y.bandwidth()/2+4).style('fill','var(--ink)');
    var m=re.merge(rows); m.select('rect.ghost').attr('width', function(d){ return x(d.v0)-150; }); m.select('rect.b').transition().duration(DUR).attr('width', function(d){ return Math.max(0,x(d.v)-150); }).attr('fill', function(d){ return d.z.id===selZone?'var(--c2)':'var(--ink)'; }); m.select('text.v').transition().duration(DUR).attr('x', function(d){ return x(d.v0)+6; }).text(function(d){ return fmt(d.v,1); });
    renderPanel(r);
  }
  function renderPanel(r){ var p=d3.select('#panel'); var z=ZONES.filter(function(z){return z.id===selZone;})[0]; if(!z){ p.html('<h4>Click a zone</h4><div class="kgline">The number above is the whole night. Zones show their kg per room-night; levers come from the intervention library with their measured ranges.</div>'); return; } var h='<h4>'+esc(z.label)+'</h4>'; z.slices.forEach(function(k){ var s=S.filter(function(x){return x.k===k;})[0]; h+='<div class="kgline">'+esc(s.name)+': <b>'+fmt(r.by[k]||0,2)+'</b> kg</div>'; (LEV[k]||[]).forEach(function(l,i){ var id=k+':'+i; h+='<label class="sw"><input type="checkbox" data-id="'+id+'"'+(on[id]?' checked':'')+(l.f===0?' disabled':'')+'> <span>'+esc(l.n)+'</span><span class="e" title="'+esc(l.s)+'">'+esc(l.r)+'</span></label>'; }); }); p.html(h); }
  d3.select('#panel').on('change', function(ev){ var c=ev.target.closest('input[data-id]'); if(!c) return; on[c.getAttribute('data-id')]=c.checked; renderBuilding(); });
  d3.select('#allLevers').on('click', function(){ Object.keys(LEV).forEach(function(k){ LEV[k].forEach(function(l,i){ if(l.f>0) on[k+':'+i]=true; }); }); renderBuilding(); });
  d3.select('#noLevers').on('click', function(){ on={}; renderBuilding(); });
  renderBuilding();

  /* ---------- scene 4: cliff ---------- */
  var YEARS = d3.range(2025,2041);
  function cap(series,y){ if(y<=2029) return 106.2; if(y<=2034) return series==='espm'?41.4:56.6; if(y<=2039) return 28.4; return 15.8; }
  var cliff = d3.select('#cliff').attr('viewBox','0 0 760 340'); var CL=50, CR=20, CT=20, CB=40, CW=760, CHh=340;
  var cx = d3.scaleLinear().domain([2025,2040]).range([CL,CW-CR]); var cy = d3.scaleLinear().range([CHh-CB, CT]);
  var gridG = cliff.append('g').attr('class','grid'); var overG = cliff.append('g'); var capPath = cliff.append('path').attr('fill','none').attr('stroke','var(--ink)').attr('stroke-width',1.5).attr('stroke-dasharray','5 4'); var linePath = cliff.append('path').attr('fill','none').attr('stroke','var(--c2)').attr('stroke-width',3).attr('stroke-linejoin','round'); var xAx = cliff.append('g').attr('class','axis').attr('transform','translate(0,'+(CHh-CB)+')'); var yAx = cliff.append('g').attr('class','axis').attr('transform','translate('+CL+',0)'); var yrLine = cliff.append('line').attr('stroke','var(--ink-2)').attr('stroke-dasharray','2 3'); var dot = cliff.append('circle').attr('r',6).attr('fill','var(--c2)').attr('stroke','var(--paper)').attr('stroke-width',2); var dotT = cliff.append('text').attr('class','mono').style('fill','var(--ink)'); cliff.append('text').attr('class','mono').attr('x',CW-CR).attr('y',CT+10).attr('text-anchor','end').text('kg CO₂e per m² (LL97 coefficients)'); var capT = cliff.append('text').attr('x',CW-CR).attr('text-anchor','end').style('fill','var(--ink)').text('LL97 cap');
  function cliffCalc(){ var hpy=+d3.select('#hpy').property('value'), dhwy=+d3.select('#dhwy').property('value'), cut=+d3.select('#cut').property('value')/100, recs=+d3.select('#recs').property('value')/100, series=d3.select('#capsel').property('value'); return YEARS.map(function(y){ var coefE=y<=2029?0.289:0.145; var el=0,fu=0; S.forEach(function(s){ if(s.t3||s.s3) return; var e=(s.elec||0)*(1-cut), f=(s.fuel||0)*(1-cut); if((s.k==='heat'&&y>=hpy)||(s.k==='dhw'&&y>=dhwy)){ e+=f/3; f=0; } el+=e; fu+=f; }); var kgm2=(el*1000*coefE*(1-recs)+fu*1000*0.181)/GFA; var c=cap(series,y); return {y:y,kgm2:kgm2,cap:c,pen:Math.max(0,kgm2-c)*GFA/1000*268}; }); }
  function renderCliff(){
    var rows=cliffCalc(), yr=+d3.select('#yr').property('value');
    ['hpy','dhwy'].forEach(function(id){ var v=+d3.select('#'+id).property('value'); d3.select('#'+id+'v').text(v>2040?'never':String(v)); }); d3.select('#cutv').text(d3.select('#cut').property('value')+'%'); d3.select('#recsv').text(d3.select('#recs').property('value')+'%'); d3.select('#yrv').text(yr);
    var ymax = Math.max(120, d3.max(rows,function(r){return r.kgm2;})*1.08); cy.domain([0,ymax]);
    yAx.transition().duration(DUR).call(d3.axisLeft(cy).ticks(6).tickSize(-(CW-CL-CR))); yAx.selectAll('.tick line').attr('stroke','var(--rule-2)'); yAx.select('.domain').remove();
    xAx.call(d3.axisBottom(cx).ticks(16).tickFormat(d3.format('d')).tickSize(4)); xAx.select('.domain').attr('stroke','var(--rule)');
    var w=(CW-CL-CR)/15;
    var over = overG.selectAll('rect').data(rows.filter(function(r){return r.kgm2>r.cap;}), function(r){return r.y;}); over.enter().append('rect').attr('fill','var(--bad)').attr('opacity',.18).attr('x',function(r){return cx(r.y)-w/2;}).attr('width',w).merge(over).transition().duration(DUR).attr('y',function(r){return cy(r.kgm2);}).attr('height',function(r){return Math.max(0,cy(r.cap)-cy(r.kgm2));}); over.exit().remove();
    var capLine = d3.line().x(function(d){return d[0];}).y(function(d){return d[1];}); var capPts=[]; rows.forEach(function(r){ capPts.push([cx(r.y)-w/2, cy(r.cap)]); capPts.push([cx(r.y)+w/2, cy(r.cap)]); }); capPath.transition().duration(DUR).attr('d', capLine(capPts));
    linePath.transition().duration(DUR).attr('d', d3.line().x(function(r){return cx(r.y);}).y(function(r){return cy(r.kgm2);}).curve(d3.curveMonotoneX)(rows));
    var cur=rows[yr-2025]; yrLine.attr('x1',cx(yr)).attr('x2',cx(yr)).attr('y1',CT).attr('y2',CHh-CB); dot.transition().duration(DUR).attr('cx',cx(yr)).attr('cy',cy(cur.kgm2)); dotT.attr('x', yr>2036?cx(yr)-10:cx(yr)+10).attr('text-anchor', yr>2036?'end':'start').attr('y',cy(cur.kgm2)-12).text(fmt(cur.kgm2,1)+' vs cap '+fmt(cur.cap,1)); capT.attr('y', cy(rows[15].cap)-6);
    var over_n=rows.filter(function(r){return r.kgm2>r.cap;}).length, pen=d3.sum(rows,function(r){return r.pen;});
    d3.select('#cliffK').html('<div class="kpi '+(cur.kgm2<=cur.cap?'good':'bad')+'"><div class="v">'+fmt(cur.kgm2,1)+'</div><div class="l">kg/m² in '+yr+'</div></div><div class="kpi"><div class="v">'+fmt(cur.cap,1)+'</div><div class="l">cap in '+yr+'</div></div><div class="kpi '+(cur.pen>0?'bad':'good')+'"><div class="v">$'+fmt(cur.pen,0)+'</div><div class="l">penalty in '+yr+'</div></div><div class="kpi '+(over_n?'bad':'good')+'"><div class="v">'+over_n+'/16</div><div class="l">years over the cap</div></div><div class="kpi"><div class="v">$'+fmt(pen/1e6,2)+'M</div><div class="l">penalties 2025–2040</div></div>');
  }
  ['yr','hpy','dhwy','cut','recs','capsel'].forEach(function(id){ d3.select('#'+id).on('input change', renderCliff); });
  renderCliff();

  /* ---------- scene 5: plate ---------- */
  var FS = { clune:{beef:28.7,lamb:27.9,pork:5.9,chicken:4.1,fish:3.5,cheese:8.9,eggs:3.4,veg:0.47,grain:1.4}, poore:{beef:99.5,lamb:39.7,pork:12.3,chicken:9.9,fish:13.6,cheese:23.9,eggs:4.7,veg:0.5,grain:1.6} };
  var DISH = [['beef','Beef tenderloin'],['lamb','Rack of lamb'],['pork','Pork loin'],['chicken','Roast chicken'],['fish','Seared fish'],['cheese','Cheese course'],['eggs','Eggs Benedict'],['veg','Vegetable plate'],['grain','Risotto']];
  var fset='clune', svc='plated', main='beef';
  var mealSvg = d3.select('#mealBar').attr('viewBox','0 0 720 90'); var mx = d3.scaleLinear().domain([0,24]).range([0,720]);
  mealSvg.append('g').attr('class','axis').attr('transform','translate(0,62)').call(d3.axisBottom(mx).ticks(12).tickSize(4).tickFormat(function(v){ return v+' kg'; })).select('.domain').attr('stroke','var(--rule)');
  function renderPlate(){ var f=FS[fset], port=+d3.select('#portion').property('value')/1000; d3.select('#portionv').text((port*1000)+' g');
    var dishes=d3.select('#plate').selectAll('button').data(DISH); dishes.enter().append('button').attr('class','dish').attr('type','button').on('click', function(e,d){ main=d[0]; renderPlate(); }).merge(dishes).attr('aria-pressed', function(d){ return String(main===d[0]); }).html(function(d){ return '<b>'+d[1]+'</b><small>'+f[d[0]]+' kg CO₂e / kg</small>'; });
    var mainKg=f[main]*port, sides=f.veg*0.15+f.grain*0.1, dairy=0.05*f.cheese, wasteKg=(svc==='buffet'?0.48:0.16), wasteCO2=wasteKg*0.627 + wasteKg*(mainKg+sides)/(port+0.25)*0.5; var total=mainKg+sides+dairy+wasteCO2;
    tweenText(d3.select('#mealNum'), total, 2);
    var parts=[{k:'main',v:mainKg,c:'var(--c2)'},{k:'sides and dairy',v:sides+dairy,c:'var(--c3)'},{k:'plate waste',v:wasteCO2,c:'var(--c6)'}]; var acc=0; parts.forEach(function(p){ p.x0=acc; acc+=p.v; p.x1=acc; });
    var segs=mealSvg.selectAll('rect.seg').data(parts, function(p){return p.k;}); segs.enter().append('rect').attr('class','seg').attr('y',20).attr('height',36).attr('fill',function(p){return p.c;}).attr('x',0).attr('width',0).on('mousemove', function(e,p){ showTip(e, esc(p.k)+': '+fmt(p.v,2)+' kg CO₂e'); }).on('mouseleave', hideTip).merge(segs).transition().duration(DUR).attr('x',function(p){return mx(p.x0)+(p.x0?1:0);}).attr('width',function(p){return Math.max(0,mx(p.x1)-mx(p.x0)-(p.x0?1:0));});
    var labs=mealSvg.selectAll('text.lbl').data(parts, function(p){return p.k;}); labs.enter().append('text').attr('class','lbl mono').attr('y',14).merge(labs).transition().duration(DUR).attr('x',function(p){return mx(p.x0)+2;}).text(function(p){ return (mx(p.x1)-mx(p.x0)>70) ? p.k+' '+fmt(p.v,2) : ''; });
    var night=kgPerNight({ef:0.392, inB:B.waste}).tot; var alt = main==='beef'?'chicken':'beef';
    d3.select('#mealNote').text('Two such dinners a night would be '+fmt(2*total/night*100,0)+'% of a '+fmt(night,1)+' kg full-scope room-night. Swap to '+alt+': '+fmt(f[alt]*port+sides+dairy+wasteCO2,2)+' kg.');
  }
  d3.select('#fsetSeg').on('click', function(ev){ var b=ev.target.closest('button[data-f]'); if(!b) return; fset=b.getAttribute('data-f'); d3.select(this).selectAll('button').attr('aria-pressed', function(){ return String(this===b); }); renderPlate(); });
  d3.select('#svcSeg').on('click', function(ev){ var b=ev.target.closest('button[data-s]'); if(!b) return; svc=b.getAttribute('data-s'); d3.select(this).selectAll('button').attr('aria-pressed', function(){ return String(this===b); }); renderPlate(); });
  d3.select('#portion').on('input', renderPlate);
  renderPlate();

  /* ---------- scene 6: claims ---------- */
  var CL = [
    {q:'"Your stay is carbon neutral."', basis:'Offsets bought from avoidance credits (REDD+, IFM).', before:'cond', after:'no', why:'Before 27 Sep 2026 already found misleading by courts (KLM, Eurowings, the BGH klimaneutral ruling) where the basis is not explained. From 27 Sep 2026 banned per se in the EU: Directive 2024/825 prohibits claims of neutral, reduced or positive impact based on offsetting outside the value chain. West et al. 2023: 6.1% of REDD+ credits additional.'},
    {q:'"We offset every night you stay."', basis:'Same credits, described as offsetting rather than neutrality.', before:'cond', after:'cond', why:'A factual statement that credits were bought stays lawful if the credits, project and quantity are named and no neutrality is implied. ICVCM excluded legacy REDD+ methodologies in Nov 2024; VCMI tiers require 20–100% coverage with a validated target.'},
    {q:'"Book our climate-positive rate."', basis:'A rate that funds removals or credits beyond the stay’s emissions.', before:'cond', after:'no', why:'"Positive impact" claims based on offsetting outside the value chain fall under the same per se ban from 27 Sep 2026. Durable removals at $180–650/t are a contribution, not a claim basis; SBTi requires removals only from 2035 for residuals.'},
    {q:'"We measure every stay and publish it. We do not neutralise."', basis:'Disclosure of Scope 1, 2 and food, laundry and waste per room-night.', before:'ok', after:'ok', why:'The posture the programme chose. Oxford Principles 2024 call "carbon neutral" a less rigorous interim claim; disclosure with the boundary stated is what the guidelines require, and a guest-facing per-stay figure should include food, laundry and waste or be labelled partial.'},
    {q:'"Scope 1 and 2 emissions down 46% since 2019."', basis:'Absolute reduction against a validated science-based target.', before:'ok', after:'ok', why:'Hilton’s validated SBTs are absolute (−46.2% Scope 1+2, −27.5% franchise Scope 3 by 2030 vs 2019). Lawful if true, measured consistently (location vs market stated) and not implying neutrality. The 75%/56% per-m² goals are intensity targets, not the validated ones.'},
    {q:'"100% renewable electricity."', basis:'Market-based RECs or a PPA.', before:'cond', after:'cond', why:'Permitted as a procurement statement if the instrument is named. SBTi V2.0 limits recognition (plants ≤15 years, same region, hourly matching 50→90%); LL97 counts only Tier-4 Zone J RECs delivered in the same year. Saying the hotel’s emissions are therefore zero is the claim that fails.'},
    {q:'"Reuse your towel and save the planet."', basis:'Behavioural nudge on the bathroom card.', before:'ok', after:'ok', why:'Not an environmental claim about the product. Goldstein 2008: descriptive norms lift reuse from 35% to 44–49%; the carbon effect is 0.02–0.04 kg per night, which the card should not overstate.'}
  ];
  function renderClaims(){ var d=+d3.select('#date').property('value'); var yr=Math.floor(d), q=Math.round((d-yr)*4)+1; var after=d>=2026.72; d3.select('#datev').text(yr+' Q'+q+(after?' · after 27 Sep 2026, EU 2024/825 in force':' · before the EU claims ban')); d3.select('#claims').html(CL.map(function(c,i){ var st=after?c.after:c.before; return '<div class="claim" data-i="'+i+'"><div><div class="q">'+esc(c.q)+'</div><div class="basis">'+esc(c.basis)+'</div></div><span class="pill '+st+'">'+(st==='ok'?'stands':st==='no'?'banned':'only if explained')+'</span><div class="why">'+esc(c.why)+'</div></div>'; }).join('')); }
  d3.select('#date').on('input', renderClaims); d3.select('#claims').on('click', function(ev){ var c=ev.target.closest('.claim'); if(c) c.classList.toggle('open'); }); renderClaims();

  /* ---------- scenes 7–8: rules and hypotheses (data fetched) ---------- */
  var sortK='n', D={rules:[],hyps:[]};
  function renderRules(){ var q=(d3.select('#ruleq').property('value')||'').trim().toLowerCase(); var rs=D.rules.slice(); if(sortK==='conf') rs.sort(function(a,b){ var o={high:0,medium:1,low:2}; return (o[a.conf]-o[b.conf])||(a.n-b.n); }); var shown=rs.filter(function(r){ return !q || (r.stmt+' '+r.ev.join(' ')).toLowerCase().indexOf(q)!==-1; }); d3.select('#rulen').text(shown.length+' of '+rs.length); d3.select('#wall').html(shown.map(function(r){ return '<div class="card" data-n="'+r.n+'"><div class="in"><div class="face"><div class="rn">Rule '+r.n+'</div><span class="pill cf '+(r.conf==='high'?'ok':'cond')+'">'+r.conf+'</span><div class="st">'+esc(r.stmt)+'</div></div><div class="face back"><div class="rn">Rule '+r.n+' · evidence</div><ul>'+r.ev.map(function(e){ return '<li>'+esc(e)+'</li>'; }).join('')+'</ul></div></div></div>'; }).join('')); }
  d3.select('#ruleq').on('input', renderRules); d3.select('#ruleSort').on('click', function(ev){ var b=ev.target.closest('button[data-k]'); if(!b) return; sortK=b.getAttribute('data-k'); d3.select(this).selectAll('button').attr('aria-pressed', function(){ return String(this===b); }); renderRules(); }); d3.select('#wall').on('click', function(ev){ var c=ev.target.closest('.card'); if(c) c.classList.toggle('flip'); });
  var marks={}; try{ marks=JSON.parse(localStorage.getItem('onw-marks')||'{}'); }catch(e){}
  function renderHyps(){ d3.select('#hyps').html(D.hyps.map(function(h){ var m=marks[h.id]||''; return '<div class="hyp" data-id="'+h.id+'"><div class="h"><span class="id">'+h.id+'</span><span class="t">'+esc(h.title)+'</span></div><div class="test">'+(h.test?'<b>Test.</b> '+esc(h.test)+'<br>':'')+(h.expected?'<b>Expected.</b> '+esc(h.expected):'')+'</div><div class="acts"><button type="button" data-act="toggle">Show the test</button><button type="button" data-act="believe" aria-pressed="'+(m==='believe')+'">I believe this</button><button type="button" data-act="doubt" aria-pressed="'+(m==='doubt')+'">I doubt this</button><a href="https://claude.ai/artifact/VW5TK7TWFjSZKpchiLe1XL">Run in Storylines →</a></div></div>'; }).join('')); }
  d3.select('#hyps').on('click', function(ev){ var b=ev.target.closest('button[data-act]'); if(!b) return; var h=b.closest('.hyp'), id=h.getAttribute('data-id'), act=b.getAttribute('data-act'); if(act==='toggle'){ h.classList.toggle('open'); return; } marks[id]=marks[id]===act?'':act; try{ localStorage.setItem('onw-marks', JSON.stringify(marks)); }catch(e){} renderHyps(); });
  d3.json('/static/hotel-carbon/data.json').then(function(j){ D=j; renderRules(); renderHyps(); }).catch(function(){ d3.select('#wall').html('<p class="fine">The rules could not be loaded.</p>'); d3.select('#hyps').html('<p class="fine">The hypotheses could not be loaded.</p>'); });

  /* ---------- chrome ---------- */
  var ids=['s0','s1','s2','s3','s4','s5','s6','s7','s8','s9'], names=['Top','Denominator','Dial','Building','Cliff','Plate','Claims','Rules','Tests','Tools'];
  d3.select('#scenenav').html(ids.map(function(id,i){ return '<a href="#'+id+'" data-id="'+id+'">'+names[i]+'</a>'; }).join(''));
  function onScroll(){ var h=document.documentElement; var p=h.scrollTop/Math.max(1,h.scrollHeight-h.clientHeight); d3.select('#progress').style('width',(p*100)+'%'); var cur=ids[0]; ids.forEach(function(id){ var el=document.getElementById(id); if(el && el.getBoundingClientRect().top < window.innerHeight*0.45) cur=id; }); d3.selectAll('#scenenav a').classed('on', function(){ return this.getAttribute('data-id')===cur; }); }
  window.addEventListener('scroll', onScroll, {passive:true}); onScroll();
})();
