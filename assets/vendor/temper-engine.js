const INT32_MAX = 2 ** 31 - 1;
const INT32_MIN = -2147483648;
const cmpFloat = (a, b) => {
  if (Object.is(a, b)) {
    return 0;
  }
  if (a === b) {
    return Object.is(a, 0) - Object.is(b, 0);
  }
  if (isNaN(a) || isNaN(b)) {
    return isNaN(a) - isNaN(b);
  }
  return a - b;
};
const bubble = () => {
  throw Error();
};
Object.freeze(
  // Prototype for empty
  Object.create(
    Object.freeze(
      Object.create(
        null,
        {
          toString: {
            value: function toString() {
              return "(empty)";
            }
          }
        }
      )
    )
  )
);
const float64ToInt32 = (n) => {
  const i = float64ToInt32Unsafe(n);
  if (Math.abs(n - i) < 1) {
    return i;
  } else {
    bubble();
  }
};
const float64ToInt32Unsafe = (n) => {
  return isNaN(n) ? 0 : Math.max(
    INT32_MIN,
    Math.min(Math.trunc(n), INT32_MAX)
  );
};
const float64ToString = (n) => {
  if (n === 0) {
    return Object.is(n, -0) ? "-0.0" : "0.0";
  } else {
    let result = n.toString();
    const groups = /(-?[0-9]+)(\.[0-9]+)?(.+)?/.exec(result);
    if (groups === null) {
      return result;
    } else {
      return `${groups[1]}${groups[2] || ".0"}${groups[3] || ""}`;
    }
  }
};
const bitwiseShrUnsigned32 = (a, b) => {
  b &= 31;
  return b ? a >>> b : a;
};
const type = (...superTypes) => {
  const key = Symbol();
  class Union {
    static [Symbol.hasInstance] = (instance) => {
      return typeof instance === "object" && instance !== null && key in instance;
    };
  }
  Union.prototype[key] = null;
  for (const superType of superTypes.reverse()) {
    let proto = Object.getPrototypeOf(superType.prototype);
    for (const sym of Object.getOwnPropertySymbols(proto)) {
      Union.prototype[sym] = null;
    }
    Object.defineProperties(Union.prototype, Object.getOwnPropertyDescriptors(proto));
    Object.defineProperties(Union.prototype, Object.getOwnPropertyDescriptors(superType.prototype));
  }
  return Union;
};
const listBuilderAdd = (ls, newItem, at) => {
  {
    ls.push(newItem);
  }
};
const listedGet = (ls, i) => {
  let { length } = ls;
  if (0 <= i && i < length) {
    return ls[i];
  }
  bubble();
};
const listedJoin = (ls, separator, elementStringifier) => {
  let joined = "";
  let { length } = ls;
  for (let i = 0; i < length; ++i) {
    if (i) {
      joined += separator;
    }
    let element = ls[i];
    let stringifiedElement = elementStringifier(element);
    joined += stringifiedElement;
  }
  return joined;
};
const listBuilderToList = (ls) => {
  return Object.freeze(ls.slice());
};
const {
  PI: PI__232,
  cos: cos__231,
  floor: floor__28,
  imul: imul__10,
  min: min__197,
  sin: sin__230
} = globalThis.Math;
class Rng_3 extends type() {
  /** @type {number} */
  #s_4;
  /** @returns {number} */
  next() {
    const t_6 = this.#s_4 + -1640531527 | 0;
    this.#s_4 = t_6;
    let z_7 = this.#s_4;
    let t_8 = bitwiseShrUnsigned32(z_7, 16);
    z_7 = imul__10(z_7 ^ t_8, -2048144789);
    let t_11 = bitwiseShrUnsigned32(z_7, 13);
    z_7 = imul__10(z_7 ^ t_11, -1028477387);
    let t_12 = bitwiseShrUnsigned32(z_7, 16);
    return z_7 ^ t_12;
  }
  /** @returns {number} */
  unit() {
    let return_14;
    let t_15;
    try {
      t_15 = (this.next() & 2147483647) / 2147483648;
      return_14 = t_15;
    } catch {
      return_14 = 0;
    }
    return return_14;
  }
  /**
   * @param {number} lo_17
   * @param {number} hi_18
   * @returns {number}
   */
  between(lo_17, hi_18) {
    let t_19 = hi_18 - lo_17;
    let t_20 = this.unit();
    return lo_17 + t_19 * t_20;
  }
  /**
   * @param {number} lo_22
   * @param {number} hi_23
   * @returns {number}
   */
  intBetween(lo_22, hi_23) {
    let t_24;
    let t_25;
    const span_26 = hi_23 - lo_22 | 0;
    try {
      t_24 = float64ToInt32(floor__28(this.unit() * span_26));
      t_25 = t_24;
    } catch {
      t_25 = 0;
    }
    return lo_22 + t_25 | 0;
  }
  /**
   * @param {number} p_30
   * @returns {boolean}
   */
  chance(p_30) {
    return cmpFloat(this.unit(), p_30) < 0;
  }
  /** @param {number} s_32 */
  constructor(s_32) {
    super();
    this.#s_4 = s_32;
    return;
  }
  /** @returns {number} */
  get s() {
    return this.#s_4;
  }
  /** @param {number} newS_35 */
  set s(newS_35) {
    this.#s_4 = newS_35;
    return;
  }
}
class Rgb_37 extends type() {
  /** @type {number} */
  #r_38;
  /** @type {number} */
  #g_39;
  /** @type {number} */
  #b_40;
  /** @returns {string} */
  hex() {
    return "#" + hex2_42(this.#r_38) + hex2_42(this.#g_39) + hex2_42(this.#b_40);
  }
  /**
   * @param {{
   *   r: number, g: number, b: number
   * }}
   * props
   * @returns {Rgb_37}
   */
  static ["new"](props) {
    return new Rgb_37(props.r, props.g, props.b);
  }
  /**
   * @param {number} r_43
   * @param {number} g_44
   * @param {number} b_45
   */
  constructor(r_43, g_44, b_45) {
    super();
    this.#r_38 = r_43;
    this.#g_39 = g_44;
    this.#b_40 = b_45;
    return;
  }
  /** @returns {number} */
  get r() {
    return this.#r_38;
  }
  /** @returns {number} */
  get g() {
    return this.#g_39;
  }
  /** @returns {number} */
  get b() {
    return this.#b_40;
  }
}
class Shape_49 extends type() {
  /** @returns {string} */
  toJson() {
  }
}
class Circle_51 extends type(Shape_49) {
  /** @type {number} */
  #cx_52;
  /** @type {number} */
  #cy_53;
  /** @type {number} */
  #rad_54;
  /** @type {string} */
  #fill_55;
  /** @type {number} */
  #alpha_56;
  /** @returns {string} */
  toJson() {
    return '{"t":"circle","cx":' + float64ToString(this.#cx_52) + ',"cy":' + float64ToString(this.#cy_53) + ',"r":' + float64ToString(this.#rad_54) + ',"fill":"' + this.#fill_55 + '","a":' + float64ToString(this.#alpha_56) + "}";
  }
  /**
   * @param {{
   *   cx: number, cy: number, rad: number, fill: string, alpha: number
   * }}
   * props
   * @returns {Circle_51}
   */
  static ["new"](props) {
    return new Circle_51(props.cx, props.cy, props.rad, props.fill, props.alpha);
  }
  /**
   * @param {number} cx_59
   * @param {number} cy_60
   * @param {number} rad_61
   * @param {string} fill_62
   * @param {number} alpha_63
   */
  constructor(cx_59, cy_60, rad_61, fill_62, alpha_63) {
    super();
    this.#cx_52 = cx_59;
    this.#cy_53 = cy_60;
    this.#rad_54 = rad_61;
    this.#fill_55 = fill_62;
    this.#alpha_56 = alpha_63;
    return;
  }
  /** @returns {number} */
  get cx() {
    return this.#cx_52;
  }
  /** @returns {number} */
  get cy() {
    return this.#cy_53;
  }
  /** @returns {number} */
  get rad() {
    return this.#rad_54;
  }
  /** @returns {string} */
  get fill() {
    return this.#fill_55;
  }
  /** @returns {number} */
  get alpha() {
    return this.#alpha_56;
  }
}
class Rect_69 extends type(Shape_49) {
  /** @type {number} */
  #x_70;
  /** @type {number} */
  #y_71;
  /** @type {number} */
  #w_72;
  /** @type {number} */
  #h_73;
  /** @type {number} */
  #rot_74;
  /** @type {string} */
  #fill_75;
  /** @type {number} */
  #alpha_76;
  /** @returns {string} */
  toJson() {
    return '{"t":"rect","x":' + float64ToString(this.#x_70) + ',"y":' + float64ToString(this.#y_71) + ',"w":' + float64ToString(this.#w_72) + ',"h":' + float64ToString(this.#h_73) + ',"rot":' + float64ToString(this.#rot_74) + ',"fill":"' + this.#fill_75 + '","a":' + float64ToString(this.#alpha_76) + "}";
  }
  /**
   * @param {{
   *   x: number, y: number, w: number, h: number, rot: number, fill: string, alpha: number
   * }}
   * props
   * @returns {Rect_69}
   */
  static ["new"](props) {
    return new Rect_69(props.x, props.y, props.w, props.h, props.rot, props.fill, props.alpha);
  }
  /**
   * @param {number} x_78
   * @param {number} y_79
   * @param {number} w_80
   * @param {number} h_81
   * @param {number} rot_82
   * @param {string} fill_83
   * @param {number} alpha_84
   */
  constructor(x_78, y_79, w_80, h_81, rot_82, fill_83, alpha_84) {
    super();
    this.#x_70 = x_78;
    this.#y_71 = y_79;
    this.#w_72 = w_80;
    this.#h_73 = h_81;
    this.#rot_74 = rot_82;
    this.#fill_75 = fill_83;
    this.#alpha_76 = alpha_84;
    return;
  }
  /** @returns {number} */
  get x() {
    return this.#x_70;
  }
  /** @returns {number} */
  get y() {
    return this.#y_71;
  }
  /** @returns {number} */
  get w() {
    return this.#w_72;
  }
  /** @returns {number} */
  get h() {
    return this.#h_73;
  }
  /** @returns {number} */
  get rot() {
    return this.#rot_74;
  }
  /** @returns {string} */
  get fill() {
    return this.#fill_75;
  }
  /** @returns {number} */
  get alpha() {
    return this.#alpha_76;
  }
}
class Line_92 extends type(Shape_49) {
  /** @type {number} */
  #x1_93;
  /** @type {number} */
  #y1_94;
  /** @type {number} */
  #x2_95;
  /** @type {number} */
  #y2_96;
  /** @type {string} */
  #stroke_97;
  /** @type {number} */
  #width_98;
  /** @type {number} */
  #alpha_99;
  /** @returns {string} */
  toJson() {
    return '{"t":"line","x1":' + float64ToString(this.#x1_93) + ',"y1":' + float64ToString(this.#y1_94) + ',"x2":' + float64ToString(this.#x2_95) + ',"y2":' + float64ToString(this.#y2_96) + ',"stroke":"' + this.#stroke_97 + '","w":' + float64ToString(this.#width_98) + ',"a":' + float64ToString(this.#alpha_99) + "}";
  }
  /**
   * @param {{
   *   x1: number, y1: number, x2: number, y2: number, stroke: string, width: number, alpha: number
   * }}
   * props
   * @returns {Line_92}
   */
  static ["new"](props) {
    return new Line_92(props.x1, props.y1, props.x2, props.y2, props.stroke, props.width, props.alpha);
  }
  /**
   * @param {number} x1_101
   * @param {number} y1_102
   * @param {number} x2_103
   * @param {number} y2_104
   * @param {string} stroke_105
   * @param {number} width_106
   * @param {number} alpha_107
   */
  constructor(x1_101, y1_102, x2_103, y2_104, stroke_105, width_106, alpha_107) {
    super();
    this.#x1_93 = x1_101;
    this.#y1_94 = y1_102;
    this.#x2_95 = x2_103;
    this.#y2_96 = y2_104;
    this.#stroke_97 = stroke_105;
    this.#width_98 = width_106;
    this.#alpha_99 = alpha_107;
    return;
  }
  /** @returns {number} */
  get x1() {
    return this.#x1_93;
  }
  /** @returns {number} */
  get y1() {
    return this.#y1_94;
  }
  /** @returns {number} */
  get x2() {
    return this.#x2_95;
  }
  /** @returns {number} */
  get y2() {
    return this.#y2_96;
  }
  /** @returns {string} */
  get stroke() {
    return this.#stroke_97;
  }
  /** @returns {number} */
  get width() {
    return this.#width_98;
  }
  /** @returns {number} */
  get alpha() {
    return this.#alpha_99;
  }
}
class Poly_115 extends type(Shape_49) {
  /** @type {Array<number>} */
  #pts_116;
  /** @type {string} */
  #fill_117;
  /** @type {number} */
  #alpha_118;
  /** @returns {string} */
  toJson() {
    function fn_120(v_121) {
      return float64ToString(v_121);
    }
    const body_122 = listedJoin(this.#pts_116, ",", fn_120);
    return '{"t":"poly","pts":[' + body_122 + '],"fill":"' + this.#fill_117 + '","a":' + float64ToString(this.#alpha_118) + "}";
  }
  /**
   * @param {{
   *   pts: Array<number>, fill: string, alpha: number
   * }}
   * props
   * @returns {Poly_115}
   */
  static ["new"](props) {
    return new Poly_115(props.pts, props.fill, props.alpha);
  }
  /**
   * @param {Array<number>} pts_124
   * @param {string} fill_125
   * @param {number} alpha_126
   */
  constructor(pts_124, fill_125, alpha_126) {
    super();
    this.#pts_116 = pts_124;
    this.#fill_117 = fill_125;
    this.#alpha_118 = alpha_126;
    return;
  }
  /** @returns {Array<number>} */
  get pts() {
    return this.#pts_116;
  }
  /** @returns {string} */
  get fill() {
    return this.#fill_117;
  }
  /** @returns {number} */
  get alpha() {
    return this.#alpha_118;
  }
}
class Scene_130 extends type() {
  /** @type {number} */
  #seed_131;
  /** @type {string} */
  #generator_132;
  /** @type {number} */
  #width_133;
  /** @type {number} */
  #height_134;
  /** @type {string} */
  #background_135;
  /** @type {Array<Shape_49>} */
  #shapes_136;
  /** @returns {string} */
  toJson() {
    function fn_138(sh_139) {
      return sh_139.toJson();
    }
    const body_140 = listedJoin(this.#shapes_136, ",", fn_138);
    return '{"seed":' + this.#seed_131.toString() + ',"generator":"' + this.#generator_132 + '","width":' + this.#width_133.toString() + ',"height":' + this.#height_134.toString() + ',"background":"' + this.#background_135 + '","shapes":[' + body_140 + "]}";
  }
  /**
   * @param {{
   *   seed: number, generator: string, width: number, height: number, background: string, shapes: Array<Shape_49>
   * }}
   * props
   * @returns {Scene_130}
   */
  static ["new"](props) {
    return new Scene_130(props.seed, props.generator, props.width, props.height, props.background, props.shapes);
  }
  /**
   * @param {number} seed_141
   * @param {string} generator_142
   * @param {number} width_143
   * @param {number} height_144
   * @param {string} background_145
   * @param {Array<Shape_49>} shapes_146
   */
  constructor(seed_141, generator_142, width_143, height_144, background_145, shapes_146) {
    super();
    this.#seed_131 = seed_141;
    this.#generator_132 = generator_142;
    this.#width_133 = width_143;
    this.#height_134 = height_144;
    this.#background_135 = background_145;
    this.#shapes_136 = shapes_146;
    return;
  }
  /** @returns {number} */
  get seed() {
    return this.#seed_131;
  }
  /** @returns {string} */
  get generator() {
    return this.#generator_132;
  }
  /** @returns {number} */
  get width() {
    return this.#width_133;
  }
  /** @returns {number} */
  get height() {
    return this.#height_134;
  }
  /** @returns {string} */
  get background() {
    return this.#background_135;
  }
  /** @returns {Array<Shape_49>} */
  get shapes() {
    return this.#shapes_136;
  }
}
function mkRng_153(seed_154) {
  let s_155;
  if (seed_154 === 0) {
    s_155 = -559038737;
  } else {
    s_155 = seed_154;
  }
  return new Rng_3(s_155);
}
function clamp255_156(n_157) {
  let return_158;
  if (n_157 < 0) {
    return_158 = 0;
  } else if (n_157 > 255) {
    return_158 = 255;
  } else {
    return_158 = n_157;
  }
  return return_158;
}
function hex2_42(n_159) {
  let return_160;
  const v_161 = clamp255_156(n_159);
  const h_162 = v_161.toString(16);
  if (v_161 < 16) {
    return_160 = "0" + h_162;
  } else {
    return_160 = h_162;
  }
  return return_160;
}
function palettes_163() {
  return Object.freeze([Object.freeze([new Rgb_37(244, 240, 225), new Rgb_37(214, 40, 40), new Rgb_37(0, 48, 73), new Rgb_37(247, 183, 49), new Rgb_37(20, 20, 20)]), Object.freeze([new Rgb_37(245, 245, 240), new Rgb_37(255, 72, 176), new Rgb_37(0, 169, 157), new Rgb_37(255, 209, 0), new Rgb_37(40, 40, 60)]), Object.freeze([new Rgb_37(28, 24, 46), new Rgb_37(255, 110, 90), new Rgb_37(255, 196, 110), new Rgb_37(120, 200, 220), new Rgb_37(245, 235, 220)]), Object.freeze([new Rgb_37(238, 240, 230), new Rgb_37(34, 87, 60), new Rgb_37(122, 160, 90), new Rgb_37(214, 159, 64), new Rgb_37(40, 50, 40)]), Object.freeze([new Rgb_37(240, 240, 243), new Rgb_37(35, 41, 55), new Rgb_37(99, 110, 130), new Rgb_37(170, 178, 194), new Rgb_37(214, 69, 65)])]);
}
function ink_164(rng_165, pal_166) {
  let t_167 = pal_166.length;
  let t_168 = rng_165.intBetween(1, t_167);
  return listedGet(pal_166, t_168).hex();
}
function genBauhaus_170(rng_171, w_172, h_173, pal_174) {
  let t_175;
  let t_176;
  let t_177;
  let t_178;
  let t_179;
  let t_180;
  let t_181;
  const out_182 = [];
  const cols_183 = rng_171.intBetween(4, 8);
  const rows_184 = rng_171.intBetween(4, 8);
  let cw_185;
  try {
    t_179 = w_172 / cols_183;
    cw_185 = t_179;
  } catch {
    cw_185 = 100;
  }
  let ch_186;
  try {
    t_180 = h_173 / rows_184;
    ch_186 = t_180;
  } catch {
    ch_186 = 100;
  }
  let gy_187 = 0;
  while (gy_187 < rows_184) {
    let gx_188 = 0;
    while (gx_188 < cols_183) {
      continue_189: {
        if (rng_171.chance(0.32)) {
          break continue_189;
        }
        const x_190 = gx_188 * cw_185;
        const y_191 = gy_187 * ch_186;
        const kind_192 = rng_171.intBetween(0, 4);
        const col_193 = ink_164(rng_171, pal_174);
        const a_194 = rng_171.between(0.78, 1);
        if (kind_192 === 0) {
          listBuilderAdd(out_182, new Rect_69(x_190, y_191, cw_185, ch_186, 0, col_193, a_194));
        } else if (kind_192 === 1) {
          const r_196 = min__197(cw_185, ch_186) * 0.5 * rng_171.between(0.55, 0.95);
          listBuilderAdd(out_182, new Circle_51(x_190 + cw_185 * 0.5, y_191 + ch_186 * 0.5, r_196, col_193, a_194));
        } else if (kind_192 === 2) {
          listBuilderAdd(out_182, new Poly_115(Object.freeze([x_190, y_191 + ch_186, x_190 + cw_185, y_191 + ch_186, x_190 + cw_185 * 0.5, y_191]), col_193, a_194));
        } else {
          listBuilderAdd(out_182, new Line_92(x_190, y_191, x_190 + cw_185, y_191 + ch_186, col_193, ch_186 * 0.18, a_194));
        }
      }
      gx_188 = gx_188 + 1 | 0;
    }
    gy_187 = gy_187 + 1 | 0;
  }
  const accents_198 = rng_171.intBetween(2, 5);
  let i_199 = 0;
  while (i_199 < accents_198) {
    t_181 = w_172 * 0.04;
    t_175 = w_172;
    const r_200 = rng_171.between(t_181, t_175 * 0.13);
    t_176 = w_172;
    t_177 = rng_171.between(0, t_176);
    t_178 = h_173;
    listBuilderAdd(out_182, new Circle_51(t_177, rng_171.between(0, t_178), r_200, ink_164(rng_171, pal_174), rng_171.between(0.5, 0.9)));
    i_199 = i_199 + 1 | 0;
  }
  return listBuilderToList(out_182);
}
function genFlow_202(rng_203, w_204, h_205, pal_206) {
  let t_207;
  let t_208;
  let t_209;
  let t_210;
  let t_211;
  let t_212;
  let t_213;
  const out_214 = [];
  const wf_215 = w_204;
  const hf_216 = h_205;
  const particles_217 = rng_203.intBetween(150, 280);
  const steps_218 = rng_203.intBetween(26, 50);
  const step_219 = min__197(wf_215, hf_216) * 0.012;
  const scale_220 = rng_203.between(4e-3, 0.011);
  const swirl_221 = rng_203.between(1.5, 3.5);
  let p_222 = 0;
  while (p_222 < particles_217) {
    t_207 = rng_203.between(0, wf_215);
    let x_223 = t_207;
    t_208 = rng_203.between(0, hf_216);
    let y_224 = t_208;
    const col_225 = ink_164(rng_203, pal_206);
    const a_226 = rng_203.between(0.16, 0.5);
    const lw_227 = rng_203.between(1, 3.2);
    let st_228 = 0;
    while (st_228 < steps_218) {
      const ang_229 = (sin__230(x_223 * scale_220) + cos__231(y_224 * scale_220)) * swirl_221 * PI__232;
      t_209 = cos__231(ang_229);
      const nx_233 = x_223 + t_209 * step_219;
      t_210 = sin__230(ang_229);
      const ny_234 = y_224 + t_210 * step_219;
      listBuilderAdd(out_214, new Line_92(x_223, y_224, nx_233, ny_234, col_225, lw_227, a_226));
      x_223 = nx_233;
      y_224 = ny_234;
      if (cmpFloat(x_223, 0) < 0) {
        t_213 = true;
      } else {
        if (cmpFloat(x_223, wf_215) > 0) {
          t_212 = true;
        } else {
          if (cmpFloat(y_224, 0) < 0) {
            t_211 = true;
          } else {
            t_211 = cmpFloat(y_224, hf_216) > 0;
          }
          t_212 = t_211;
        }
        t_213 = t_212;
      }
      if (t_213) {
        break;
      }
      st_228 = st_228 + 1 | 0;
    }
    p_222 = p_222 + 1 | 0;
  }
  return listBuilderToList(out_214);
}
function subdivide_235(rng_236, out_237, pal_238, x_239, y_240, w_241, h_242, depth_243) {
  let t_244;
  let t_245;
  let t_246;
  let t_247;
  let t_248;
  let t_249;
  let t_250;
  let t_251;
  let t_252;
  let t_253;
  let t_254;
  let canSplit_256;
  if (depth_243 > 0) {
    if (cmpFloat(w_241, 40) > 0) {
      t_253 = true;
    } else {
      t_253 = cmpFloat(h_242, 40) > 0;
    }
    canSplit_256 = t_253;
  } else {
    canSplit_256 = false;
  }
  let shouldSplit_257;
  if (canSplit_256) {
    if (depth_243 > 5) {
      t_254 = true;
    } else {
      t_244 = rng_236.chance(0.88);
      t_254 = t_244;
    }
    shouldSplit_257 = t_254;
  } else {
    shouldSplit_257 = false;
  }
  if (shouldSplit_257) {
    let splitVert_258;
    if (cmpFloat(w_241, h_242) > 0) {
      splitVert_258 = true;
    } else if (cmpFloat(h_242, w_241) > 0) {
      splitVert_258 = false;
    } else {
      t_245 = rng_236.chance(0.5);
      splitVert_258 = t_245;
    }
    const t_259 = rng_236.between(0.32, 0.68);
    if (splitVert_258) {
      const ww_260 = w_241 * t_259;
      subdivide_235(rng_236, out_237, pal_238, x_239, y_240, ww_260, h_242, depth_243 - 1 | 0);
      subdivide_235(rng_236, out_237, pal_238, x_239 + ww_260, y_240, w_241 - ww_260, h_242, depth_243 - 1 | 0);
    } else {
      const hh_261 = h_242 * t_259;
      subdivide_235(rng_236, out_237, pal_238, x_239, y_240, w_241, hh_261, depth_243 - 1 | 0);
      subdivide_235(rng_236, out_237, pal_238, x_239, y_240 + hh_261, w_241, h_242 - hh_261, depth_243 - 1 | 0);
    }
  } else {
    let fillCol_262;
    if (rng_236.chance(0.15)) {
      t_246 = listedGet(pal_238, 0).hex();
      fillCol_262 = t_246;
    } else {
      t_247 = ink_164(rng_236, pal_238);
      fillCol_262 = t_247;
    }
    t_248 = new Rect_69(x_239, y_240, w_241, h_242, 0, fillCol_262, 1);
    listBuilderAdd(out_237, t_248);
    t_249 = new Line_92(x_239, y_240, x_239 + w_241, y_240, "#141414", 6, 1);
    listBuilderAdd(out_237, t_249);
    t_250 = new Line_92(x_239 + w_241, y_240, x_239 + w_241, y_240 + h_242, "#141414", 6, 1);
    listBuilderAdd(out_237, t_250);
    t_251 = new Line_92(x_239 + w_241, y_240 + h_242, x_239, y_240 + h_242, "#141414", 6, 1);
    listBuilderAdd(out_237, t_251);
    t_252 = new Line_92(x_239, y_240 + h_242, x_239, y_240, "#141414", 6, 1);
    listBuilderAdd(out_237, t_252);
  }
  return;
}
function genSubdivision_265(rng_266, w_267, h_268, pal_269) {
  const out_270 = [];
  let t_271 = w_267;
  let t_272 = h_268;
  subdivide_235(rng_266, out_270, pal_269, 0, 0, t_271, t_272, 7);
  return listBuilderToList(out_270);
}
function generatorIds() {
  return Object.freeze(["bauhaus", "flow", "subdivision"]);
}
function generate$1(seed_273, generator_274, width_275, height_276) {
  let t_277;
  let t_278;
  let t_279;
  const rng_280 = mkRng_153(seed_273);
  const ps_281 = palettes_163();
  const pal_282 = listedGet(ps_281, rng_280.intBetween(0, ps_281.length));
  const bg_283 = listedGet(pal_282, 0).hex();
  let shapes_284;
  if (generator_274 === "flow") {
    t_277 = genFlow_202(rng_280, width_275, height_276, pal_282);
    shapes_284 = t_277;
  } else if (generator_274 === "subdivision") {
    t_278 = genSubdivision_265(rng_280, width_275, height_276, pal_282);
    shapes_284 = t_278;
  } else {
    t_279 = genBauhaus_170(rng_280, width_275, height_276, pal_282);
    shapes_284 = t_279;
  }
  return new Scene_130(seed_273, generator_274, width_275, height_276, bg_283, shapes_284).toJson();
}
const GENERATORS = generatorIds();
function generate(seed, generator, width, height) {
  const json = generate$1(seed, generator, width, height);
  return JSON.parse(json);
}
function render(ctx, scene) {
  const { width, height } = ctx.canvas;
  ctx.clearRect(0, 0, width, height);
  ctx.fillStyle = scene.background;
  ctx.fillRect(0, 0, width, height);
  for (const sh of scene.shapes) {
    ctx.save();
    ctx.globalAlpha = sh.a ?? 1;
    if (sh.t === "circle") {
      ctx.fillStyle = sh.fill;
      ctx.beginPath();
      ctx.arc(sh.cx, sh.cy, sh.r, 0, Math.PI * 2);
      ctx.fill();
    } else if (sh.t === "rect") {
      ctx.fillStyle = sh.fill;
      if (sh.rot) {
        ctx.translate(sh.x + sh.w / 2, sh.y + sh.h / 2);
        ctx.rotate(sh.rot);
        ctx.fillRect(-sh.w / 2, -sh.h / 2, sh.w, sh.h);
      } else {
        ctx.fillRect(sh.x, sh.y, sh.w, sh.h);
      }
    } else if (sh.t === "line") {
      ctx.strokeStyle = sh.stroke;
      ctx.lineWidth = sh.w;
      ctx.lineCap = "round";
      ctx.beginPath();
      ctx.moveTo(sh.x1, sh.y1);
      ctx.lineTo(sh.x2, sh.y2);
      ctx.stroke();
    } else if (sh.t === "poly") {
      const pts = sh.pts;
      if (pts.length >= 4) {
        ctx.fillStyle = sh.fill;
        ctx.beginPath();
        ctx.moveTo(pts[0], pts[1]);
        for (let i = 2; i < pts.length; i += 2) ctx.lineTo(pts[i], pts[i + 1]);
        ctx.closePath();
        ctx.fill();
      }
    }
    ctx.restore();
  }
}
export {
  GENERATORS,
  generate,
  render
};
