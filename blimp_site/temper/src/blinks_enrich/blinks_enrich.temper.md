# Blinks, what the enricher reads

`Blog.Blinks.Enricher` fetches a saved link's page and keeps four things
from it: `og:image` (or `twitter:image`), `og:site_name`, a favicon, and
`og:description` (or the plain `description`) when the link has none of
its own. Phoenix gets them with Floki, and absolutizes the two urls with
`URI.merge/2`. This module is the string half of that: the tags Floki would
find, what `URI.merge/2` and `URI.to_string/1` would make of them, and the
Bluesky post a url names. The HTTP, the JSON walk of a Bluesky thread and
the database are `src/99_blinksenrich.blimp`'s.

Floki's default parser is a copy of mochiweb's (`floki_mochi_html.erl`), a
tokenizer with its own ideas: a `<script>`, `<style>`, `<title>` or
`<textarea>` swallows everything up to its closing tag, a comment up to
`-->`, a quoted attribute value up to its quote, whatever it contains. A
meta tag inside any of those is not a meta tag. So this is not a search for
`<meta`: it walks the page token by token as that tokenizer does and looks
at the attributes of the `meta` and `link` elements it meets. It jumps with
`indexOf` wherever the tokenizer only looks for an end (text, comments, raw
text, quoted values), because a Temper character step is several
interpreter calls and pages run to megabytes.

No classes; every name starts `bke_`.

    let { blkw_trim } = import("../blinks_write");

## Characters

The code point at `i`, or -1 past the end.

    let bke_at(s: String, i: StringIndex): Int {
      if (i < s.end) { s[i] } else { -1 }
    }

mochiweb's `?IS_WHITESPACE`: space, tab, CR and LF. Not form feed.

    let bke_ws(c: Int): Boolean { c == 32 || c == 9 || c == 13 || c == 10 }

    let bke_letter(c: Int): Boolean { (c >= 65 && c <= 90) || (c >= 97 && c <= 122) }

    let bke_skip_ws(s: String, i: StringIndex): StringIndex {
      if (i < s.end && bke_ws(s[i])) { bke_skip_ws(s, s.next(i)) } else { i }
    }

Whether `s` has `lit` at `i`, byte for byte.

    let bke_looking_at(s: String, i: StringIndex, lit: String, n: Int): Boolean {
      let e = s.step(i, n);
      s.slice(i, e) == lit
    }

## Character references

`tokenize_charref`: from the `&` at `i`, everything up to the next `;` is
the reference, unless whitespace, a quote, `/` or `>` comes first, or the
text ends. Then `Floki.Entities.decode/1` decides whether it is one: a name
in the HTML5 table that stands for a single code point, or `#` and a
number. Anything else is a plain `&`, and reading goes on right after it.
The end of the reference at `i`, or none when it is not one.

    export let bke_ref_end(s: String, i: StringIndex): StringIndexOption {
      let from = s.next(i);
      let semi = bke_ref_semi(s, from);
      if (semi is StringIndex) {
        if (bke_ref_code(s.slice(from, semi)) >= 0) { s.next(semi) } else { StringIndex.none }
      } else {
        StringIndex.none
      }
    }

    let bke_ref_semi(s: String, j: StringIndex): StringIndexOption {
      if (j >= s.end) {
        StringIndex.none
      } else {
        let c = s[j];
        if (c == 59) {
          j
        } else if (bke_ws(c) || c == 39 || c == 34 || c == 47 || c == 62) {
          StringIndex.none
        } else {
          bke_ref_semi(s, s.next(j))
        }
      }
    }

The code point a reference's text (between `&` and `;`) stands for, or -1.

    export let bke_ref_code(raw: String): Int {
      if (raw.isEmpty) {
        -1
      } else if (raw[String.begin] == 35) {
        bke_num_code(raw.slice(raw.next(String.begin), raw.end))
      } else if (bke_alnum_all(raw, String.begin)) {
        bke_entity(raw)
      } else {
        -1
      }
    }

    let bke_alnum_all(s: String, i: StringIndex): Boolean {
      if (i >= s.end) {
        true
      } else {
        let c = s[i];
        if (bke_letter(c) || (c >= 48 && c <= 57)) { bke_alnum_all(s, s.next(i)) } else { false }
      }
    }

A numeric reference is `Integer.parse/2` of what follows `#` (base 16
after an `x` or `X`): an optional sign, then as many digits as there are,
and whatever follows them is ignored, so `&#65abc;` is `A`, and so is
`&#+65;`. No digits at all is not a reference. A negative number is not
one either, except `-0`. Then `Floki.HTML.NumericCharref`: 0 is U+FFFD,
0x80 to 0x9F are read as Windows-1252 where that has a character,
surrogates and anything past U+10FFFF are U+FFFD.

    let bke_num_code(t: String): Int {
      let c = bke_at(t, String.begin);
      if (c == 120 || c == 88) {
        bke_num_signed(t, t.next(String.begin), 16)
      } else {
        bke_num_signed(t, String.begin, 10)
      }
    }

    let bke_num_signed(t: String, i: StringIndex, base: Int): Int {
      let c = bke_at(t, i);
      let neg = c == 45;
      let j = if (c == 43 || c == 45) { t.next(i) } else { i };
      if (bke_digit(bke_at(t, j), base) < 0) {
        -1
      } else {
        let n = bke_digits(t, j, base, 0);
        if (neg && n > 0) { -1 } else { bke_unicode(n) }
      }
    }

    let bke_digit(c: Int, base: Int): Int {
      if (c >= 48 && c <= 57) {
        c - 48
      } else if (base == 16 && c >= 97 && c <= 102) {
        c - 87
      } else if (base == 16 && c >= 65 && c <= 70) {
        c - 55
      } else {
        -1
      }
    }

Past U+10FFFF the value stops growing, so a long run of digits cannot
overflow; it only has to stay past the end.

    let bke_digits(t: String, i: StringIndex, base: Int, n: Int): Int {
      let d = bke_digit(bke_at(t, i), base);
      if (d < 0) {
        n
      } else {
        let m = n * base + d;
        bke_digits(t, t.next(i), base, if (m > 0x10FFFF) { 0x110000 } else { m })
      }
    }

    let bke_unicode(n: Int): Int {
      if (n == 0) {
        0xFFFD
      } else if (n >= 0x80 && n <= 0x9F) {
        bke_cp1252(n)
      } else if ((n >= 0xD800 && n <= 0xDFFF) || n > 0x10FFFF) {
        0xFFFD
      } else {
        n
      }
    }

    let bke_cp1252(n: Int): Int {
      if (n == 0x80) {
        0x20AC
      } else if (n == 0x82) {
        0x201A
      } else if (n == 0x83) {
        0x0192
      } else if (n == 0x84) {
        0x201E
      } else if (n == 0x85) {
        0x2026
      } else if (n == 0x86) {
        0x2020
      } else if (n == 0x87) {
        0x2021
      } else if (n == 0x88) {
        0x02C6
      } else if (n == 0x89) {
        0x2030
      } else if (n == 0x8A) {
        0x0160
      } else if (n == 0x8B) {
        0x2039
      } else if (n == 0x8C) {
        0x0152
      } else if (n == 0x8E) {
        0x017D
      } else if (n == 0x91) {
        0x2018
      } else if (n == 0x92) {
        0x2019
      } else if (n == 0x93) {
        0x201C
      } else if (n == 0x94) {
        0x201D
      } else if (n == 0x95) {
        0x2022
      } else if (n == 0x96) {
        0x2013
      } else if (n == 0x97) {
        0x2014
      } else if (n == 0x98) {
        0x02DC
      } else if (n == 0x99) {
        0x2122
      } else if (n == 0x9A) {
        0x0161
      } else if (n == 0x9B) {
        0x203A
      } else if (n == 0x9C) {
        0x0153
      } else if (n == 0x9E) {
        0x017E
      } else if (n == 0x9F) {
        0x0178
      } else {
        n
      }
    }

The named references, from `Floki.Entities.Codepoints` (Floki 0.37.0):
the 2,032 that end in `;` and stand for one code point. The other 93 stand
for two code points, and mochiweb's tokenizer only accepts a reference that
decodes to exactly one, so to it they are plain text. Looked up as
`|name;` in one string: a name is letters and digits, so it cannot match
across two entries.

    let bke_entity(name: String): Int {
      let at = bke_entities.indexOf("|${name};");
      if (at is StringIndex) {
        let semi = bke_entities.indexOf(";", at);
        if (semi is StringIndex) { bke_digits(bke_entities, bke_entities.next(semi), 10, 0) } else { -1 }
      } else {
        -1
      }
    }

    let bke_entities = "|AElig;198|AMP;38|Aacute;193|Abreve;258|Acirc;194|Acy;1040|Afr;120068|Agrave;192|Alpha;913|Amacr;256|And;10835|Aogon;260|Aopf;120120|ApplyFunction;8289|Aring;197|Ascr;119964|Assign;8788|Atilde;195|Auml;196|Backslash;8726|Barv;10983|Barwed;8966|Bcy;1041|Because;8757|Bernoullis;8492|Beta;914|Bfr;120069|Bopf;120121|Breve;728|Bscr;8492|Bumpeq;8782|CHcy;1063|COPY;169|Cacute;262|Cap;8914|CapitalDifferentialD;8517|Cayleys;8493|Ccaron;268|Ccedil;199|Ccirc;264|Cconint;8752|Cdot;266|Cedilla;184|CenterDot;183|Cfr;8493|Chi;935|CircleDot;8857|CircleMinus;8854|CirclePlus;8853|CircleTimes;8855|ClockwiseContourIntegral;8754|CloseCurlyDoubleQuote;8221|CloseCurlyQuote;8217|Colon;8759|Colone;10868|Congruent;8801|Conint;8751|ContourIntegral;8750|Copf;8450|Coproduct;8720|CounterClockwiseContourIntegral;8755|Cross;10799|Cscr;119966|Cup;8915|CupCap;8781|DD;8517|DDotrahd;10513|DJcy;1026|DScy;1029|DZcy;1039|Dagger;8225|Darr;8609|Dashv;10980|Dcaron;270|Dcy;1044|Del;8711|Delta;916|Dfr;120071|DiacriticalAcute;180|DiacriticalDot;729|DiacriticalDoubleAcute;733|DiacriticalGrave;96|DiacriticalTilde;732|Diamond;8900|DifferentialD;8518|Dopf;120123|Dot;168|DotDot;8412|DotEqual;8784|DoubleContourIntegral;8751|DoubleDot;168|DoubleDownArrow;8659|DoubleLeftArrow;8656|DoubleLeftRightArrow;8660|DoubleLeftTee;10980|DoubleLongLeftArrow;10232|DoubleLongLeftRightArrow;10234|DoubleLongRightArrow;10233|DoubleRightArrow;8658|DoubleRightTee;8872|DoubleUpArrow;8657|DoubleUpDownArrow;8661|DoubleVerticalBar;8741|DownArrow;8595|DownArrowBar;10515|DownArrowUpArrow;8693|DownBreve;785|DownLeftRightVector;10576|DownLeftTeeVector;10590|DownLeftVector;8637|DownLeftVectorBar;10582|DownRightTeeVector;10591|DownRightVector;8641|DownRightVectorBar;10583|DownTee;8868|DownTeeArrow;8615|Downarrow;8659|Dscr;119967|Dstrok;272|ENG;330|ETH;208|Eacute;201|Ecaron;282|Ecirc;202|Ecy;1069|Edot;278|Efr;120072|Egrave;200|Element;8712|Emacr;274|EmptySmallSquare;9723|EmptyVerySmallSquare;9643|Eogon;280|Eopf;120124|Epsilon;917|Equal;10869|EqualTilde;8770|Equilibrium;8652|Escr;8496|Esim;10867|Eta;919|Euml;203|Exists;8707|ExponentialE;8519|Fcy;1060|Ffr;120073|FilledSmallSquare;9724|FilledVerySmallSquare;9642|Fopf;120125|ForAll;8704|Fouriertrf;8497|Fscr;8497|GJcy;1027|GT;62|Gamma;915|Gammad;988|Gbreve;286|Gcedil;290|Gcirc;284|Gcy;1043|Gdot;288|Gfr;120074|Gg;8921|Gopf;120126|GreaterEqual;8805|GreaterEqualLess;8923|GreaterFullEqual;8807|GreaterGreater;10914|GreaterLess;8823|GreaterSlantEqual;10878|GreaterTilde;8819|Gscr;119970|Gt;8811|HARDcy;1066|Hacek;711|Hat;94|Hcirc;292|Hfr;8460|HilbertSpace;8459|Hopf;8461|HorizontalLine;9472|Hscr;8459|Hstrok;294|HumpDownHump;8782|HumpEqual;8783|IEcy;1045|IJlig;306|IOcy;1025|Iacute;205|Icirc;206|Icy;1048|Idot;304|Ifr;8465|Igrave;204|Im;8465|Imacr;298|ImaginaryI;8520|Implies;8658|Int;8748|Integral;8747|Intersection;8898|InvisibleComma;8291|InvisibleTimes;8290|Iogon;302|Iopf;120128|Iota;921|Iscr;8464|Itilde;296|Iukcy;1030|Iuml;207|Jcirc;308|Jcy;1049|Jfr;120077|Jopf;120129|Jscr;119973|Jsercy;1032|Jukcy;1028|KHcy;1061|KJcy;1036|Kappa;922|Kcedil;310|Kcy;1050|Kfr;120078|Kopf;120130|Kscr;119974|LJcy;1033|LT;60|Lacute;313|Lambda;923|Lang;10218|Laplacetrf;8466|Larr;8606|Lcaron;317|Lcedil;315|Lcy;1051|LeftAngleBracket;10216|LeftArrow;8592|LeftArrowBar;8676|LeftArrowRightArrow;8646|LeftCeiling;8968|LeftDoubleBracket;10214|LeftDownTeeVector;10593|LeftDownVector;8643|LeftDownVectorBar;10585|LeftFloor;8970|LeftRightArrow;8596|LeftRightVector;10574|LeftTee;8867|LeftTeeArrow;8612|LeftTeeVector;10586|LeftTriangle;8882|LeftTriangleBar;10703|LeftTriangleEqual;8884|LeftUpDownVector;10577|LeftUpTeeVector;10592|LeftUpVector;8639|LeftUpVectorBar;10584|LeftVector;8636|LeftVectorBar;10578|Leftarrow;8656|Leftrightarrow;8660|LessEqualGreater;8922|LessFullEqual;8806|LessGreater;8822|LessLess;10913|LessSlantEqual;10877|LessTilde;8818|Lfr;120079|Ll;8920|Lleftarrow;8666|Lmidot;319|LongLeftArrow;10229|LongLeftRightArrow;10231|LongRightArrow;10230|Longleftarrow;10232|Longleftrightarrow;10234|Longrightarrow;10233|Lopf;120131|LowerLeftArrow;8601|LowerRightArrow;8600|Lscr;8466|Lsh;8624|Lstrok;321|Lt;8810|Map;10501|Mcy;1052|MediumSpace;8287|Mellintrf;8499|Mfr;120080|MinusPlus;8723|Mopf;120132|Mscr;8499|Mu;924|NJcy;1034|Nacute;323|Ncaron;327|Ncedil;325|Ncy;1053|NegativeMediumSpace;8203|NegativeThickSpace;8203|NegativeThinSpace;8203|NegativeVeryThinSpace;8203|NestedGreaterGreater;8811|NestedLessLess;8810|NewLine;10|Nfr;120081|NoBreak;8288|NonBreakingSpace;160|Nopf;8469|Not;10988|NotCongruent;8802|NotCupCap;8813|NotDoubleVerticalBar;8742|NotElement;8713|NotEqual;8800|NotExists;8708|NotGreater;8815|NotGreaterEqual;8817|NotGreaterLess;8825|NotGreaterTilde;8821|NotLeftTriangle;8938|NotLeftTriangleEqual;8940|NotLess;8814|NotLessEqual;8816|NotLessGreater;8824|NotLessTilde;8820|NotPrecedes;8832|NotPrecedesSlantEqual;8928|NotReverseElement;8716|NotRightTriangle;8939|NotRightTriangleEqual;8941|NotSquareSubsetEqual;8930|NotSquareSupersetEqual;8931|NotSubsetEqual;8840|NotSucceeds;8833|NotSucceedsSlantEqual;8929|NotSupersetEqual;8841|NotTilde;8769|NotTildeEqual;8772|NotTildeFullEqual;8775|NotTildeTilde;8777|NotVerticalBar;8740|Nscr;119977|Ntilde;209|Nu;925|OElig;338|Oacute;211|Ocirc;212|Ocy;1054|Odblac;336|Ofr;120082|Ograve;210|Omacr;332|Omega;937|Omicron;927|Oopf;120134|OpenCurlyDoubleQuote;8220|OpenCurlyQuote;8216|Or;10836|Oscr;119978|Oslash;216|Otilde;213|Otimes;10807|Ouml;214|OverBar;8254|OverBrace;9182|OverBracket;9140|OverParenthesis;9180|PartialD;8706|Pcy;1055|Pfr;120083|Phi;934|Pi;928|PlusMinus;177|Poincareplane;8460|Popf;8473|Pr;10939|Precedes;8826|PrecedesEqual;10927|PrecedesSlantEqual;8828|PrecedesTilde;8830|Prime;8243|Product;8719|Proportion;8759|Proportional;8733|Pscr;119979|Psi;936|QUOT;34|Qfr;120084|Qopf;8474|Qscr;119980|RBarr;10512|REG;174|Racute;340|Rang;10219|Rarr;8608|Rarrtl;10518|Rcaron;344|Rcedil;342|Rcy;1056|Re;8476|ReverseElement;8715|ReverseEquilibrium;8651|ReverseUpEquilibrium;10607|Rfr;8476|Rho;929|RightAngleBracket;10217|RightArrow;8594|RightArrowBar;8677|RightArrowLeftArrow;8644|RightCeiling;8969|RightDoubleBracket;10215|RightDownTeeVector;10589|RightDownVector;8642|RightDownVectorBar;10581|RightFloor;8971|RightTee;8866|RightTeeArrow;8614|RightTeeVector;10587|RightTriangle;8883|RightTriangleBar;10704|RightTriangleEqual;8885|RightUpDownVector;10575|RightUpTeeVector;10588|RightUpVector;8638|RightUpVectorBar;10580|RightVector;8640|RightVectorBar;10579|Rightarrow;8658|Ropf;8477|RoundImplies;10608|Rrightarrow;8667|Rscr;8475|Rsh;8625|RuleDelayed;10740|SHCHcy;1065|SHcy;1064|SOFTcy;1068|Sacute;346|Sc;10940|Scaron;352|Scedil;350|Scirc;348|Scy;1057|Sfr;120086|ShortDownArrow;8595|ShortLeftArrow;8592|ShortRightArrow;8594|ShortUpArrow;8593|Sigma;931|SmallCircle;8728|Sopf;120138|Sqrt;8730|Square;9633|SquareIntersection;8851|SquareSubset;8847|SquareSubsetEqual;8849|SquareSuperset;8848|SquareSupersetEqual;8850|SquareUnion;8852|Sscr;119982|Star;8902|Sub;8912|Subset;8912|SubsetEqual;8838|Succeeds;8827|SucceedsEqual;10928|SucceedsSlantEqual;8829|SucceedsTilde;8831|SuchThat;8715|Sum;8721|Sup;8913|Superset;8835|SupersetEqual;8839|Supset;8913|THORN;222|TRADE;8482|TSHcy;1035|TScy;1062|Tab;9|Tau;932|Tcaron;356|Tcedil;354|Tcy;1058|Tfr;120087|Therefore;8756|Theta;920|ThinSpace;8201|Tilde;8764|TildeEqual;8771|TildeFullEqual;8773|TildeTilde;8776|Topf;120139|TripleDot;8411|Tscr;119983|Tstrok;358|Uacute;218|Uarr;8607|Uarrocir;10569|Ubrcy;1038|Ubreve;364|Ucirc;219|Ucy;1059|Udblac;368|Ufr;120088|Ugrave;217|Umacr;362|UnderBar;95|UnderBrace;9183|UnderBracket;9141|UnderParenthesis;9181|Union;8899|UnionPlus;8846|Uogon;370|Uopf;120140|UpArrow;8593|UpArrowBar;10514|UpArrowDownArrow;8645|UpDownArrow;8597|UpEquilibrium;10606|UpTee;8869|UpTeeArrow;8613|Uparrow;8657|Updownarrow;8661|UpperLeftArrow;8598|UpperRightArrow;8599|Upsi;978|Upsilon;933|Uring;366|Uscr;119984|Utilde;360|Uuml;220|VDash;8875|Vbar;10987|Vcy;1042|Vdash;8873|Vdashl;10982|Vee;8897|Verbar;8214|Vert;8214|VerticalBar;8739|VerticalLine;124|VerticalSeparator;10072|VerticalTilde;8768|VeryThinSpace;8202|Vfr;120089|Vopf;120141|Vscr;119985|Vvdash;8874|Wcirc;372|Wedge;8896|Wfr;120090|Wopf;120142|Wscr;119986|Xfr;120091|Xi;926|Xopf;120143|Xscr;119987|YAcy;1071|YIcy;1031|YUcy;1070|Yacute;221|Ycirc;374|Ycy;1067|Yfr;120092|Yopf;120144|Yscr;119988|Yuml;376|ZHcy;1046|Zacute;377|Zcaron;381|Zcy;1047|Zdot;379|ZeroWidthSpace;8203|Zeta;918|Zfr;8488|Zopf;8484|Zscr;119989|aacute;225|abreve;259|ac;8766|acd;8767|acirc;226|acute;180|acy;1072|aelig;230|af;8289|afr;120094|agrave;224|alefsym;8501|aleph;8501|alpha;945|amacr;257|amalg;10815|amp;38|and;8743|andand;10837|andd;10844|andslope;10840|andv;10842|ang;8736|ange;10660|angle;8736|angmsd;8737|angmsdaa;10664|angmsdab;10665|angmsdac;10666|angmsdad;10667|angmsdae;10668|angmsdaf;10669|angmsdag;10670|angmsdah;10671|angrt;8735|angrtvb;8894|angrtvbd;10653|angsph;8738|angst;197|angzarr;9084|aogon;261|aopf;120146|ap;8776|apE;10864|apacir;10863|ape;8778|apid;8779|apos;39|approx;8776|approxeq;8778|aring;229|ascr;119990|ast;42|asymp;8776|asympeq;8781|atilde;227|auml;228|awconint;8755|awint;10769|bNot;10989|backcong;8780|backepsilon;1014|backprime;8245|backsim;8765|backsimeq;8909|barvee;8893|barwed;8965|barwedge;8965|bbrk;9141|bbrktbrk;9142|bcong;8780|bcy;1073|bdquo;8222|becaus;8757|because;8757|bemptyv;10672|bepsi;1014|bernou;8492|beta;946|beth;8502|between;8812|bfr;120095|bigcap;8898|bigcirc;9711|bigcup;8899|bigodot;10752|bigoplus;10753|bigotimes;10754|bigsqcup;10758|bigstar;9733|bigtriangledown;9661|bigtriangleup;9651|biguplus;10756|bigvee;8897|bigwedge;8896|bkarow;10509|blacklozenge;10731|blacksquare;9642|blacktriangle;9652|blacktriangledown;9662|blacktriangleleft;9666|blacktriangleright;9656|blank;9251|blk12;9618|blk14;9617|blk34;9619|block;9608|bnot;8976|bopf;120147|bot;8869|bottom;8869|bowtie;8904|boxDL;9559|boxDR;9556|boxDl;9558|boxDr;9555|boxH;9552|boxHD;9574|boxHU;9577|boxHd;9572|boxHu;9575|boxUL;9565|boxUR;9562|boxUl;9564|boxUr;9561|boxV;9553|boxVH;9580|boxVL;9571|boxVR;9568|boxVh;9579|boxVl;9570|boxVr;9567|boxbox;10697|boxdL;9557|boxdR;9554|boxdl;9488|boxdr;9484|boxh;9472|boxhD;9573|boxhU;9576|boxhd;9516|boxhu;9524|boxminus;8863|boxplus;8862|boxtimes;8864|boxuL;9563|boxuR;9560|boxul;9496|boxur;9492|boxv;9474|boxvH;9578|boxvL;9569|boxvR;9566|boxvh;9532|boxvl;9508|boxvr;9500|bprime;8245|breve;728|brvbar;166|bscr;119991|bsemi;8271|bsim;8765|bsime;8909|bsol;92|bsolb;10693|bsolhsub;10184|bull;8226|bullet;8226|bump;8782|bumpE;10926|bumpe;8783|bumpeq;8783|cacute;263|cap;8745|capand;10820|capbrcup;10825|capcap;10827|capcup;10823|capdot;10816|caret;8257|caron;711|ccaps;10829|ccaron;269|ccedil;231|ccirc;265|ccups;10828|ccupssm;10832|cdot;267|cedil;184|cemptyv;10674|cent;162|centerdot;183|cfr;120096|chcy;1095|check;10003|checkmark;10003|chi;967|cir;9675|cirE;10691|circ;710|circeq;8791|circlearrowleft;8634|circlearrowright;8635|circledR;174|circledS;9416|circledast;8859|circledcirc;8858|circleddash;8861|cire;8791|cirfnint;10768|cirmid;10991|cirscir;10690|clubs;9827|clubsuit;9827|colon;58|colone;8788|coloneq;8788|comma;44|commat;64|comp;8705|compfn;8728|complement;8705|complexes;8450|cong;8773|congdot;10861|conint;8750|copf;120148|coprod;8720|copy;169|copysr;8471|crarr;8629|cross;10007|cscr;119992|csub;10959|csube;10961|csup;10960|csupe;10962|ctdot;8943|cudarrl;10552|cudarrr;10549|cuepr;8926|cuesc;8927|cularr;8630|cularrp;10557|cup;8746|cupbrcap;10824|cupcap;10822|cupcup;10826|cupdot;8845|cupor;10821|curarr;8631|curarrm;10556|curlyeqprec;8926|curlyeqsucc;8927|curlyvee;8910|curlywedge;8911|curren;164|curvearrowleft;8630|curvearrowright;8631|cuvee;8910|cuwed;8911|cwconint;8754|cwint;8753|cylcty;9005|dArr;8659|dHar;10597|dagger;8224|daleth;8504|darr;8595|dash;8208|dashv;8867|dbkarow;10511|dblac;733|dcaron;271|dcy;1076|dd;8518|ddagger;8225|ddarr;8650|ddotseq;10871|deg;176|delta;948|demptyv;10673|dfisht;10623|dfr;120097|dharl;8643|dharr;8642|diam;8900|diamond;8900|diamondsuit;9830|diams;9830|die;168|digamma;989|disin;8946|div;247|divide;247|divideontimes;8903|divonx;8903|djcy;1106|dlcorn;8990|dlcrop;8973|dollar;36|dopf;120149|dot;729|doteq;8784|doteqdot;8785|dotminus;8760|dotplus;8724|dotsquare;8865|doublebarwedge;8966|downarrow;8595|downdownarrows;8650|downharpoonleft;8643|downharpoonright;8642|drbkarow;10512|drcorn;8991|drcrop;8972|dscr;119993|dscy;1109|dsol;10742|dstrok;273|dtdot;8945|dtri;9663|dtrif;9662|duarr;8693|duhar;10607|dwangle;10662|dzcy;1119|dzigrarr;10239|eDDot;10871|eDot;8785|eacute;233|easter;10862|ecaron;283|ecir;8790|ecirc;234|ecolon;8789|ecy;1101|edot;279|ee;8519|efDot;8786|efr;120098|eg;10906|egrave;232|egs;10902|egsdot;10904|el;10905|elinters;9191|ell;8467|els;10901|elsdot;10903|emacr;275|empty;8709|emptyset;8709|emptyv;8709|emsp13;8196|emsp14;8197|emsp;8195|eng;331|ensp;8194|eogon;281|eopf;120150|epar;8917|eparsl;10723|eplus;10865|epsi;949|epsilon;949|epsiv;1013|eqcirc;8790|eqcolon;8789|eqsim;8770|eqslantgtr;10902|eqslantless;10901|equals;61|equest;8799|equiv;8801|equivDD;10872|eqvparsl;10725|erDot;8787|erarr;10609|escr;8495|esdot;8784|esim;8770|eta;951|eth;240|euml;235|euro;8364|excl;33|exist;8707|expectation;8496|exponentiale;8519|fallingdotseq;8786|fcy;1092|female;9792|ffilig;64259|fflig;64256|ffllig;64260|ffr;120099|filig;64257|flat;9837|fllig;64258|fltns;9649|fnof;402|fopf;120151|forall;8704|fork;8916|forkv;10969|fpartint;10765|frac12;189|frac13;8531|frac14;188|frac15;8533|frac16;8537|frac18;8539|frac23;8532|frac25;8534|frac34;190|frac35;8535|frac38;8540|frac45;8536|frac56;8538|frac58;8541|frac78;8542|frasl;8260|frown;8994|fscr;119995|gE;8807|gEl;10892|gacute;501|gamma;947|gammad;989|gap;10886|gbreve;287|gcirc;285|gcy;1075|gdot;289|ge;8805|gel;8923|geq;8805|geqq;8807|geqslant;10878|ges;10878|gescc;10921|gesdot;10880|gesdoto;10882|gesdotol;10884|gesles;10900|gfr;120100|gg;8811|ggg;8921|gimel;8503|gjcy;1107|gl;8823|glE;10898|gla;10917|glj;10916|gnE;8809|gnap;10890|gnapprox;10890|gne;10888|gneq;10888|gneqq;8809|gnsim;8935|gopf;120152|grave;96|gscr;8458|gsim;8819|gsime;10894|gsiml;10896|gt;62|gtcc;10919|gtcir;10874|gtdot;8919|gtlPar;10645|gtquest;10876|gtrapprox;10886|gtrarr;10616|gtrdot;8919|gtreqless;8923|gtreqqless;10892|gtrless;8823|gtrsim;8819|hArr;8660|hairsp;8202|half;189|hamilt;8459|hardcy;1098|harr;8596|harrcir;10568|harrw;8621|hbar;8463|hcirc;293|hearts;9829|heartsuit;9829|hellip;8230|hercon;8889|hfr;120101|hksearow;10533|hkswarow;10534|hoarr;8703|homtht;8763|hookleftarrow;8617|hookrightarrow;8618|hopf;120153|horbar;8213|hscr;119997|hslash;8463|hstrok;295|hybull;8259|hyphen;8208|iacute;237|ic;8291|icirc;238|icy;1080|iecy;1077|iexcl;161|iff;8660|ifr;120102|igrave;236|ii;8520|iiiint;10764|iiint;8749|iinfin;10716|iiota;8489|ijlig;307|imacr;299|image;8465|imagline;8464|imagpart;8465|imath;305|imof;8887|imped;437|in;8712|incare;8453|infin;8734|infintie;10717|inodot;305|int;8747|intcal;8890|integers;8484|intercal;8890|intlarhk;10775|intprod;10812|iocy;1105|iogon;303|iopf;120154|iota;953|iprod;10812|iquest;191|iscr;119998|isin;8712|isinE;8953|isindot;8949|isins;8948|isinsv;8947|isinv;8712|it;8290|itilde;297|iukcy;1110|iuml;239|jcirc;309|jcy;1081|jfr;120103|jmath;567|jopf;120155|jscr;119999|jsercy;1112|jukcy;1108|kappa;954|kappav;1008|kcedil;311|kcy;1082|kfr;120104|kgreen;312|khcy;1093|kjcy;1116|kopf;120156|kscr;120000|lAarr;8666|lArr;8656|lAtail;10523|lBarr;10510|lE;8806|lEg;10891|lHar;10594|lacute;314|laemptyv;10676|lagran;8466|lambda;955|lang;10216|langd;10641|langle;10216|lap;10885|laquo;171|larr;8592|larrb;8676|larrbfs;10527|larrfs;10525|larrhk;8617|larrlp;8619|larrpl;10553|larrsim;10611|larrtl;8610|lat;10923|latail;10521|late;10925|lbarr;10508|lbbrk;10098|lbrace;123|lbrack;91|lbrke;10635|lbrksld;10639|lbrkslu;10637|lcaron;318|lcedil;316|lceil;8968|lcub;123|lcy;1083|ldca;10550|ldquo;8220|ldquor;8222|ldrdhar;10599|ldrushar;10571|ldsh;8626|le;8804|leftarrow;8592|leftarrowtail;8610|leftharpoondown;8637|leftharpoonup;8636|leftleftarrows;8647|leftrightarrow;8596|leftrightarrows;8646|leftrightharpoons;8651|leftrightsquigarrow;8621|leftthreetimes;8907|leg;8922|leq;8804|leqq;8806|leqslant;10877|les;10877|lescc;10920|lesdot;10879|lesdoto;10881|lesdotor;10883|lesges;10899|lessapprox;10885|lessdot;8918|lesseqgtr;8922|lesseqqgtr;10891|lessgtr;8822|lesssim;8818|lfisht;10620|lfloor;8970|lfr;120105|lg;8822|lgE;10897|lhard;8637|lharu;8636|lharul;10602|lhblk;9604|ljcy;1113|ll;8810|llarr;8647|llcorner;8990|llhard;10603|lltri;9722|lmidot;320|lmoust;9136|lmoustache;9136|lnE;8808|lnap;10889|lnapprox;10889|lne;10887|lneq;10887|lneqq;8808|lnsim;8934|loang;10220|loarr;8701|lobrk;10214|longleftarrow;10229|longleftrightarrow;10231|longmapsto;10236|longrightarrow;10230|looparrowleft;8619|looparrowright;8620|lopar;10629|lopf;120157|loplus;10797|lotimes;10804|lowast;8727|lowbar;95|loz;9674|lozenge;9674|lozf;10731|lpar;40|lparlt;10643|lrarr;8646|lrcorner;8991|lrhar;8651|lrhard;10605|lrm;8206|lrtri;8895|lsaquo;8249|lscr;120001|lsh;8624|lsim;8818|lsime;10893|lsimg;10895|lsqb;91|lsquo;8216|lsquor;8218|lstrok;322|lt;60|ltcc;10918|ltcir;10873|ltdot;8918|lthree;8907|ltimes;8905|ltlarr;10614|ltquest;10875|ltrPar;10646|ltri;9667|ltrie;8884|ltrif;9666|lurdshar;10570|luruhar;10598|mDDot;8762|macr;175|male;9794|malt;10016|maltese;10016|map;8614|mapsto;8614|mapstodown;8615|mapstoleft;8612|mapstoup;8613|marker;9646|mcomma;10793|mcy;1084|mdash;8212|measuredangle;8737|mfr;120106|mho;8487|micro;181|mid;8739|midast;42|midcir;10992|middot;183|minus;8722|minusb;8863|minusd;8760|minusdu;10794|mlcp;10971|mldr;8230|mnplus;8723|models;8871|mopf;120158|mp;8723|mscr;120002|mstpos;8766|mu;956|multimap;8888|mumap;8888|nLeftarrow;8653|nLeftrightarrow;8654|nRightarrow;8655|nVDash;8879|nVdash;8878|nabla;8711|nacute;324|nap;8777|napos;329|napprox;8777|natur;9838|natural;9838|naturals;8469|nbsp;160|ncap;10819|ncaron;328|ncedil;326|ncong;8775|ncup;10818|ncy;1085|ndash;8211|ne;8800|neArr;8663|nearhk;10532|nearr;8599|nearrow;8599|nequiv;8802|nesear;10536|nexist;8708|nexists;8708|nfr;120107|nge;8817|ngeq;8817|ngsim;8821|ngt;8815|ngtr;8815|nhArr;8654|nharr;8622|nhpar;10994|ni;8715|nis;8956|nisd;8954|niv;8715|njcy;1114|nlArr;8653|nlarr;8602|nldr;8229|nle;8816|nleftarrow;8602|nleftrightarrow;8622|nleq;8816|nless;8814|nlsim;8820|nlt;8814|nltri;8938|nltrie;8940|nmid;8740|nopf;120159|not;172|notin;8713|notinva;8713|notinvb;8951|notinvc;8950|notni;8716|notniva;8716|notnivb;8958|notnivc;8957|npar;8742|nparallel;8742|npolint;10772|npr;8832|nprcue;8928|nprec;8832|nrArr;8655|nrarr;8603|nrightarrow;8603|nrtri;8939|nrtrie;8941|nsc;8833|nsccue;8929|nscr;120003|nshortmid;8740|nshortparallel;8742|nsim;8769|nsime;8772|nsimeq;8772|nsmid;8740|nspar;8742|nsqsube;8930|nsqsupe;8931|nsub;8836|nsube;8840|nsubseteq;8840|nsucc;8833|nsup;8837|nsupe;8841|nsupseteq;8841|ntgl;8825|ntilde;241|ntlg;8824|ntriangleleft;8938|ntrianglelefteq;8940|ntriangleright;8939|ntrianglerighteq;8941|nu;957|num;35|numero;8470|numsp;8199|nvDash;8877|nvHarr;10500|nvdash;8876|nvinfin;10718|nvlArr;10498|nvrArr;10499|nwArr;8662|nwarhk;10531|nwarr;8598|nwarrow;8598|nwnear;10535|oS;9416|oacute;243|oast;8859|ocir;8858|ocirc;244|ocy;1086|odash;8861|odblac;337|odiv;10808|odot;8857|odsold;10684|oelig;339|ofcir;10687|ofr;120108|ogon;731|ograve;242|ogt;10689|ohbar;10677|ohm;937|oint;8750|olarr;8634|olcir;10686|olcross;10683|oline;8254|olt;10688|omacr;333|omega;969|omicron;959|omid;10678|ominus;8854|oopf;120160|opar;10679|operp;10681|oplus;8853|or;8744|orarr;8635|ord;10845|order;8500|orderof;8500|ordf;170|ordm;186|origof;8886|oror;10838|orslope;10839|orv;10843|oscr;8500|oslash;248|osol;8856|otilde;245|otimes;8855|otimesas;10806|ouml;246|ovbar;9021|par;8741|para;182|parallel;8741|parsim;10995|parsl;11005|part;8706|pcy;1087|percnt;37|period;46|permil;8240|perp;8869|pertenk;8241|pfr;120109|phi;966|phiv;981|phmmat;8499|phone;9742|pi;960|pitchfork;8916|piv;982|planck;8463|planckh;8462|plankv;8463|plus;43|plusacir;10787|plusb;8862|pluscir;10786|plusdo;8724|plusdu;10789|pluse;10866|plusmn;177|plussim;10790|plustwo;10791|pm;177|pointint;10773|popf;120161|pound;163|pr;8826|prE;10931|prap;10935|prcue;8828|pre;10927|prec;8826|precapprox;10935|preccurlyeq;8828|preceq;10927|precnapprox;10937|precneqq;10933|precnsim;8936|precsim;8830|prime;8242|primes;8473|prnE;10933|prnap;10937|prnsim;8936|prod;8719|profalar;9006|profline;8978|profsurf;8979|prop;8733|propto;8733|prsim;8830|prurel;8880|pscr;120005|psi;968|puncsp;8200|qfr;120110|qint;10764|qopf;120162|qprime;8279|qscr;120006|quaternions;8461|quatint;10774|quest;63|questeq;8799|quot;34|rAarr;8667|rArr;8658|rAtail;10524|rBarr;10511|rHar;10596|racute;341|radic;8730|raemptyv;10675|rang;10217|rangd;10642|range;10661|rangle;10217|raquo;187|rarr;8594|rarrap;10613|rarrb;8677|rarrbfs;10528|rarrc;10547|rarrfs;10526|rarrhk;8618|rarrlp;8620|rarrpl;10565|rarrsim;10612|rarrtl;8611|rarrw;8605|ratail;10522|ratio;8758|rationals;8474|rbarr;10509|rbbrk;10099|rbrace;125|rbrack;93|rbrke;10636|rbrksld;10638|rbrkslu;10640|rcaron;345|rcedil;343|rceil;8969|rcub;125|rcy;1088|rdca;10551|rdldhar;10601|rdquo;8221|rdquor;8221|rdsh;8627|real;8476|realine;8475|realpart;8476|reals;8477|rect;9645|reg;174|rfisht;10621|rfloor;8971|rfr;120111|rhard;8641|rharu;8640|rharul;10604|rho;961|rhov;1009|rightarrow;8594|rightarrowtail;8611|rightharpoondown;8641|rightharpoonup;8640|rightleftarrows;8644|rightleftharpoons;8652|rightrightarrows;8649|rightsquigarrow;8605|rightthreetimes;8908|ring;730|risingdotseq;8787|rlarr;8644|rlhar;8652|rlm;8207|rmoust;9137|rmoustache;9137|rnmid;10990|roang;10221|roarr;8702|robrk;10215|ropar;10630|ropf;120163|roplus;10798|rotimes;10805|rpar;41|rpargt;10644|rppolint;10770|rrarr;8649|rsaquo;8250|rscr;120007|rsh;8625|rsqb;93|rsquo;8217|rsquor;8217|rthree;8908|rtimes;8906|rtri;9657|rtrie;8885|rtrif;9656|rtriltri;10702|ruluhar;10600|rx;8478|sacute;347|sbquo;8218|sc;8827|scE;10932|scap;10936|scaron;353|sccue;8829|sce;10928|scedil;351|scirc;349|scnE;10934|scnap;10938|scnsim;8937|scpolint;10771|scsim;8831|scy;1089|sdot;8901|sdotb;8865|sdote;10854|seArr;8664|searhk;10533|searr;8600|searrow;8600|sect;167|semi;59|seswar;10537|setminus;8726|setmn;8726|sext;10038|sfr;120112|sfrown;8994|sharp;9839|shchcy;1097|shcy;1096|shortmid;8739|shortparallel;8741|shy;173|sigma;963|sigmaf;962|sigmav;962|sim;8764|simdot;10858|sime;8771|simeq;8771|simg;10910|simgE;10912|siml;10909|simlE;10911|simne;8774|simplus;10788|simrarr;10610|slarr;8592|smallsetminus;8726|smashp;10803|smeparsl;10724|smid;8739|smile;8995|smt;10922|smte;10924|softcy;1100|sol;47|solb;10692|solbar;9023|sopf;120164|spades;9824|spadesuit;9824|spar;8741|sqcap;8851|sqcup;8852|sqsub;8847|sqsube;8849|sqsubset;8847|sqsubseteq;8849|sqsup;8848|sqsupe;8850|sqsupset;8848|sqsupseteq;8850|squ;9633|square;9633|squarf;9642|squf;9642|srarr;8594|sscr;120008|ssetmn;8726|ssmile;8995|sstarf;8902|star;9734|starf;9733|straightepsilon;1013|straightphi;981|strns;175|sub;8834|subE;10949|subdot;10941|sube;8838|subedot;10947|submult;10945|subnE;10955|subne;8842|subplus;10943|subrarr;10617|subset;8834|subseteq;8838|subseteqq;10949|subsetneq;8842|subsetneqq;10955|subsim;10951|subsub;10965|subsup;10963|succ;8827|succapprox;10936|succcurlyeq;8829|succeq;10928|succnapprox;10938|succneqq;10934|succnsim;8937|succsim;8831|sum;8721|sung;9834|sup1;185|sup2;178|sup3;179|sup;8835|supE;10950|supdot;10942|supdsub;10968|supe;8839|supedot;10948|suphsol;10185|suphsub;10967|suplarr;10619|supmult;10946|supnE;10956|supne;8843|supplus;10944|supset;8835|supseteq;8839|supseteqq;10950|supsetneq;8843|supsetneqq;10956|supsim;10952|supsub;10964|supsup;10966|swArr;8665|swarhk;10534|swarr;8601|swarrow;8601|swnwar;10538|szlig;223|target;8982|tau;964|tbrk;9140|tcaron;357|tcedil;355|tcy;1090|tdot;8411|telrec;8981|tfr;120113|there4;8756|therefore;8756|theta;952|thetasym;977|thetav;977|thickapprox;8776|thicksim;8764|thinsp;8201|thkap;8776|thksim;8764|thorn;254|tilde;732|times;215|timesb;8864|timesbar;10801|timesd;10800|tint;8749|toea;10536|top;8868|topbot;9014|topcir;10993|topf;120165|topfork;10970|tosa;10537|tprime;8244|trade;8482|triangle;9653|triangledown;9663|triangleleft;9667|trianglelefteq;8884|triangleq;8796|triangleright;9657|trianglerighteq;8885|tridot;9708|trie;8796|triminus;10810|triplus;10809|trisb;10701|tritime;10811|trpezium;9186|tscr;120009|tscy;1094|tshcy;1115|tstrok;359|twixt;8812|twoheadleftarrow;8606|twoheadrightarrow;8608|uArr;8657|uHar;10595|uacute;250|uarr;8593|ubrcy;1118|ubreve;365|ucirc;251|ucy;1091|udarr;8645|udblac;369|udhar;10606|ufisht;10622|ufr;120114|ugrave;249|uharl;8639|uharr;8638|uhblk;9600|ulcorn;8988|ulcorner;8988|ulcrop;8975|ultri;9720|umacr;363|uml;168|uogon;371|uopf;120166|uparrow;8593|updownarrow;8597|upharpoonleft;8639|upharpoonright;8638|uplus;8846|upsi;965|upsih;978|upsilon;965|upuparrows;8648|urcorn;8989|urcorner;8989|urcrop;8974|uring;367|urtri;9721|uscr;120010|utdot;8944|utilde;361|utri;9653|utrif;9652|uuarr;8648|uuml;252|uwangle;10663|vArr;8661|vBar;10984|vBarv;10985|vDash;8872|vangrt;10652|varepsilon;1013|varkappa;1008|varnothing;8709|varphi;981|varpi;982|varpropto;8733|varr;8597|varrho;1009|varsigma;962|vartheta;977|vartriangleleft;8882|vartriangleright;8883|vcy;1074|vdash;8866|vee;8744|veebar;8891|veeeq;8794|vellip;8942|verbar;124|vert;124|vfr;120115|vltri;8882|vopf;120167|vprop;8733|vrtri;8883|vscr;120011|vzigzag;10650|wcirc;373|wedbar;10847|wedge;8743|wedgeq;8793|weierp;8472|wfr;120116|wopf;120168|wp;8472|wr;8768|wreath;8768|wscr;120012|xcap;8898|xcirc;9711|xcup;8899|xdtri;9661|xfr;120117|xhArr;10234|xharr;10231|xi;958|xlArr;10232|xlarr;10229|xmap;10236|xnis;8955|xodot;10752|xopf;120169|xoplus;10753|xotime;10754|xrArr;10233|xrarr;10230|xscr;120013|xsqcup;10758|xuplus;10756|xutri;9651|xvee;8897|xwedge;8896|yacute;253|yacy;1103|ycirc;375|ycy;1099|yen;165|yfr;120118|yicy;1111|yopf;120170|yscr;120014|yucy;1102|yuml;255|zacute;378|zcaron;382|zcy;1079|zdot;380|zeetrf;8488|zeta;950|zfr;120119|zhcy;1078|zigrarr;8669|zopf;120171|zscr;120015|zwj;8205|zwnj;8204|";

What a stretch of the page reads as once its references are decoded. The
stretch is always one the tokenizer read as a unit (an attribute value, a
name), so a reference cannot run past its end. With `lower`, the letters
are lower-cased as mochiweb does a tag or attribute name: the old
`string:to_lower/1` over what it collected, which lower-cases the raw bytes
one by one (so no byte of a multi-byte character becomes ASCII) and leaves
the decoded references alone, since they are binaries in that list. So
`<M&#69;TA>` is an element called `mEta`, not a meta tag.

    export let bke_decode(t: String, lower: Boolean): String {
      bke_decode_from(t, String.begin, lower, "")
    }

    let bke_decode_from(t: String, i: StringIndex, lower: Boolean, acc: String): String {
      let amp = t.indexOf("&", i);
      if (amp is StringIndex) {
        let before = bke_fold(t.slice(i, amp), lower);
        let e = bke_ref_end(t, amp);
        if (e is StringIndex) {
          let code = bke_ref_code(t.slice(t.next(amp), t.prev(e)));
          bke_decode_from(t, e, lower, "${acc}${before}${String.fromCodePoint(code) orelse panic()}")
        } else {
          bke_decode_from(t, t.next(amp), lower, "${acc}${before}&")
        }
      } else {
        "${acc}${bke_fold(t.slice(i, t.end), lower)}"
      }
    }

ASCII letters only; see above.

    let bke_fold(s: String, lower: Boolean): String {
      if (lower) { bke_fold_from(s, String.begin, String.begin, "") } else { s }
    }

    let bke_fold_from(s: String, i: StringIndex, run: StringIndex, acc: String): String {
      if (i >= s.end) {
        "${acc}${s.slice(run, i)}"
      } else {
        let c = s[i];
        if (c >= 65 && c <= 90) {
          let low = String.fromCodePoint(c + 32) orelse panic();
          bke_fold_from(s, s.next(i), s.next(i), "${acc}${s.slice(run, i)}${low}")
        } else {
          bke_fold_from(s, s.next(i), run, acc)
        }
      }
    }

## Names and attributes

`tokenize_literal`: a name runs to whitespace, `>`, `/` or `=`, and takes
a whole reference with it, even one whose number is followed by an `=`
before its `;`. The end of the name that starts at `i`.

    let bke_lit_end(s: String, i: StringIndex): StringIndex {
      if (i >= s.end) {
        i
      } else {
        let c = s[i];
        if (c == 38) {
          let e = bke_ref_end(s, i);
          if (e is StringIndex) { bke_lit_end(s, e) } else { bke_lit_end(s, s.next(i)) }
        } else if (bke_ws(c) || c == 62 || c == 47 || c == 61) {
          i
        } else {
          bke_lit_end(s, s.next(i))
        }
      }
    }

A name that would be empty because it starts on `>`, `/` or `=` is that
one character instead ("http://github.com/mochi/mochiweb/pull/13", says
the source).

    let bke_name_end(s: String, i: StringIndex): StringIndex {
      let c = bke_at(s, i);
      if (c == 62 || c == 47 || c == 61) { s.next(i) } else { bke_lit_end(s, i) }
    }

`tokenize_attributes` ends at `>`, `/` or `?>`, or at the end of the page.
Each attribute is a name, then optionally whitespace, `=`, whitespace and a
value. Where the list ends:

    let bke_attrs_end(s: String, i: StringIndex): StringIndex {
      if (i >= s.end) {
        i
      } else {
        let c = s[i];
        if (c == 62 || c == 47 || (c == 63 && bke_at(s, s.next(i)) == 62)) {
          i
        } else if (bke_ws(c)) {
          bke_attrs_end(s, s.next(i))
        } else {
          let j = bke_skip_ws(s, bke_name_end(s, i));
          if (bke_at(s, j) == 61) {
            bke_attrs_end(s, bke_value_end(s, bke_skip_ws(s, s.next(j))))
          } else {
            bke_attrs_end(s, j)
          }
        }
      }
    }

A value in quotes runs to the same quote, `>` and all (a reference cannot
contain a quote, so it cannot hide one). Without quotes, it runs to
whitespace, `>`, or a `/` right before a `>`: `href=/a/b>` is `/a/b`.

    let bke_value_end(s: String, k: StringIndex): StringIndex {
      let c = bke_at(s, k);
      if (c == 34 || c == 39) {
        let close = s.indexOf(if (c == 34) { "\"" } else { "'" }, s.next(k));
        if (close is StringIndex) { s.next(close) } else { s.end }
      } else {
        bke_unquoted_end(s, k)
      }
    }

    let bke_unquoted_end(s: String, k: StringIndex): StringIndex {
      if (k >= s.end) {
        k
      } else {
        let c = s[k];
        if (c == 38) {
          let e = bke_ref_end(s, k);
          if (e is StringIndex) { bke_unquoted_end(s, e) } else { bke_unquoted_end(s, s.next(k)) }
        } else if (bke_ws(c) || c == 62 || (c == 47 && bke_at(s, s.next(k)) == 62)) {
          k
        } else {
          bke_unquoted_end(s, s.next(k))
        }
      }
    }

    let bke_value(s: String, k: StringIndex, ve: StringIndex): String {
      let c = bke_at(s, k);
      if (k >= ve) {
        ""
      } else if (c == 34 || c == 39) {
        let from = s.next(k);
        let close = s.indexOf(if (c == 34) { "\"" } else { "'" }, from);
        bke_decode(s.slice(from, if (close is StringIndex) { close } else { s.end }), false)
      } else {
        bke_decode(s.slice(k, ve), false)
      }
    }

The first attribute called `want` in the list that starts at `i`: `[value]`,
or `[]` when there is none. An attribute with no `=` has its own name as
its value. When a name comes twice, Floki reads the first.

    let bke_attr(s: String, i: StringIndex, want: String): List<String> {
      if (i >= s.end) {
        []
      } else {
        let c = s[i];
        if (c == 62 || c == 47 || (c == 63 && bke_at(s, s.next(i)) == 62)) {
          []
        } else if (bke_ws(c)) {
          bke_attr(s, s.next(i), want)
        } else {
          let ne = bke_name_end(s, i);
          let name = bke_decode(s.slice(i, ne), true);
          let j = bke_skip_ws(s, ne);
          if (bke_at(s, j) == 61) {
            let k = bke_skip_ws(s, s.next(j));
            let ve = bke_value_end(s, k);
            if (name == want) { [bke_value(s, k, ve)] } else { bke_attr(s, ve, want) }
          } else if (name == want) {
            [name]
          } else {
            bke_attr(s, j, want)
          }
        }
      }
    }

    let bke_attr_or(s: String, i: StringIndex, want: String): String {
      let v = bke_attr(s, i, want);
      if (v.isEmpty) { "" } else { v[0] }
    }

`link[rel~="icon"]`: `icon` is one of the words of `rel`, split on space,
tab and newline only, case and all.

    export let bke_has_word(v: String, word: String): Boolean {
      !v.split(" ").filter { (a): Boolean =>
        !a.split("\t").filter { (b): Boolean =>
          !b.split("\n").filter { (w): Boolean => w == word }.isEmpty
        }.isEmpty
      }.isEmpty
    }

## Walking the page

What the enricher wants, in this order, each the first of its kind in the
document: `meta[property="og:image"]`, `meta[name="twitter:image"]`,
`meta[property="og:site_name"]`, `meta[property="og:description"]`,
`meta[name="description"]` (their `content`) and `link[rel~="icon"]` (its
`href`). An element counts only if it has the attribute Floki is asked
for: a `meta property="og:image"` with no `content` is passed over, one
with `content=""` is found and empty. Each value is already cut as
`presence/1` cuts it; `""` is both "none" and "empty", which `presence/1`
makes the same thing.

    export let bke_scan(html: String): List<String> {
      bke_scan_values(bke_loop(bke_scan_start(html)))
    }

The same, a piece at a time, for a caller that must not stop for the
whole of a long page (the enricher runs inside the site's one process):
start, run `n` steps (each up to 64 tokens), until done.

    export let bke_scan_start(html: String): List<String> {
      ["${html}</floki>", "", "", "", "", "", "", "0", "0", "0", "0", "0", "0", "", ""]
    }

    export let bke_scan_run(st: List<String>, n: Int): List<String> { bke_steps(st, n) }

    export let bke_scan_done(st: List<String>): Boolean { st[14] == "end" }

    export let bke_scan_values(st: List<String>): List<String> { st.slice(1, 7) }

The walk's state is one list of strings: the rest of the page (0), the six
values (1 to 6), whether each was seen (7 to 12, `"1"` or `"0"`), how many
`<floki>` elements the page has open (13, as that many `x`s), and `"end"`
at 14 once there is nothing more to read.

`Floki.parse_document/1` wraps the page in `<floki>` and `</floki>`, and
that matters in two places: an unclosed quote at the end of the page runs
on into `</floki>`, and a `</floki>` in the page itself closes the
document, so nothing after it is in the tree, unless the page opened a
`<floki>` of its own first, which that closes instead. (Any other end tag
that closes an open `<floki>` on its way is not modelled: a page would
have to have a `<floki>` in it to find out.)

The walk stops as soon as nothing later could change the answer: the
image once `og:image` is non-empty or both image tags were seen, the
description likewise, the site name and icon once seen.

    let bke_done(st: List<String>): Boolean {
      let image = st[7] == "1" && (st[1] != "" || st[8] == "1");
      let desc = st[10] == "1" && (st[4] != "" || st[11] == "1");
      image && desc && st[9] == "1" && st[12] == "1"
    }

### Why the loop is shaped like this

The first version was one tail-recursive walk that went from token to
token through a handful of functions, and it was quadratic: 10KB of page
took 0.3s, 40KB 5s, 80KB 18s. The interpreter runs a tail call as a loop,
but a Blimp closure sees its caller's locals, so a tail call keeps the
caller's bindings and puts the callee's on top of them
(`callClosureWithValues`: "the frame and any case scopes left above it are
collapsed into one scope"). Over thousands of tokens that one scope grows
to thousands of bindings, and a lookup of any name that is not local
(every function call) falls through to it; once its 64-bit name filter
matches, the lookup compares against every binding. `sample` on the
process showed `mem.eqlBytes` under `Environment.lookup` and little else.

So no loop here makes more than a few dozen tail calls before it returns.
`bke_skim` goes up to 64 tokens, each one a plain call (`bke_next`) whose
frame goes when it returns; `bke_steps` makes up to 16 of those skims,
each also a plain call; `bke_loop` repeats `bke_steps`, a few times for
even a large page. Carrying the state across those returns is why it is
one list. The per-character loops inside a tag stay tail calls: they are
as long as a tag.

The second version was linear and still too slow: 3.1s for an 800KB
Wikipedia article, most of it stepping through attribute names a
character at a time, in the one process that answers every request.
Temper's `indexOf` is the interpreter's own search, but an index it finds
in a slice is only good in a string that starts where the slice does. So
the walk carries the rest of the page as a string (a slice, which the
interpreter does not copy) rather than a position in it, and every search
that must stop at a tag's `>` searches a prefix of that rest.

    let bke_loop(st: List<String>): List<String> {
      let next = bke_steps(st, 16);
      if (next[14] == "end") { next } else { bke_loop(next) }
    }

    let bke_steps(st: List<String>, n: Int): List<String> {
      if (n <= 0 || st[14] == "end") {
        st
      } else {
        let next = bke_step(st);
        bke_steps(next, n - 1)
      }
    }

One step: to the next token worth looking at (or 64 tokens on), and that
token.

    let bke_step(st: List<String>): List<String> {
      let got = if (bke_done(st)) { ["", ""] } else { bke_skim(st[0], 64) };
      if (got[0] == "1") {
        bke_at_tag(st, got[1])
      } else if (got[0] == "0") {
        bke_set(st, 0, got[1])
      } else {
        bke_set(st, 14, "end")
      }
    }

    let bke_set(st: List<String>, k: Int, x: String): List<String> {
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14].map { (i): String => if (i == k) { x } else { st[i] } }
    }

At a token the walk looks at: `c` starts with its `<`.

    let bke_at_tag(st: List<String>, c: String): List<String> {
      let ne = bke_lit_end(c, c.next(String.begin));
      let name = bke_tag_name(c, ne);
      if (name == "meta" || name == "link") {
        let got = bke_tag_values(c, ne, name);
        let st1 = bke_found(bke_found(st, bke_slot(got[0]), got[2]), bke_slot(got[1]), got[2]);
        bke_set(st1, 0, bke_start_rest(c, ne, name))
      } else if (name == "floki") {
        bke_set(bke_set(st, 13, "${st[13]}x"), 0, bke_start_rest(c, ne, name))
      } else if (st[13] == "") {
        bke_set(st, 14, "end")
      } else {
        let open = st[13];
        bke_set(bke_set(st, 13, open.slice(open.next(String.begin), open.end)), 0, bke_after_gt(c, c.step(String.begin, 2)))
      }
    }

    let bke_slot(k: String): Int {
      if (k == "") { -1 } else if (k == "0") { 0 } else if (k == "1") { 1 } else if (k == "2") { 2 } else if (k == "3") { 3 } else if (k == "4") { 4 } else { 5 }
    }

The state with `x` as value `slot`, unless that one was already seen.

    let bke_found(st: List<String>, slot: Int, x: String): List<String> {
      if (slot < 0 || st[7 + slot] == "1") {
        st
      } else {
        bke_set(bke_set(st, 1 + slot, x), 7 + slot, "1")
      }
    }

From a token boundary, token by token, to the next token the walk must
look at: `["1", the page from its <]`. After `n` tokens it stops anyway,
`["0", the rest]`; at the end of the page, `["", ""]`.

    let bke_skim(r: String, n: Int): List<String> {
      if (n <= 0) {
        ["0", r]
      } else {
        let x = bke_next(r);
        if (x[0] == "0") { bke_skim(x[1], n - 1) } else { x }
      }
    }

One token on, as `bke_skim` answers.

    let bke_next(r: String): List<String> {
      let lt = r.indexOf("<");
      if (lt is StringIndex) {
        let swallowed = bke_swallowed(r, lt);
        if (swallowed > lt) {
          ["0", r.slice(swallowed, r.end)]
        } else {
          let c = r.slice(lt, r.end);
          let rest = bke_rest(c);
          if (rest.end == c.end) { ["1", c] } else { ["0", rest] }
        }
      } else {
        ["", ""]
      }
    }

The page after the token that starts at the `<` that starts `c`, in
`tokenize/2`'s order; or `c` itself for the tokens the walk looks at: a
`meta` or `link` start tag, a `<floki>` that stays open, and `</floki>`.

    let bke_rest(c: String): String {
      let b = String.begin;
      let c1 = bke_at(c, c.next(b));
      if (c1 == 33) {
        if (bke_looking_at(c, b, "<!--", 4)) {
          let e = c.indexOf("-->", c.step(b, 4));
          if (e is StringIndex) { c.slice(c.step(e, 3), c.end) } else { "" }
        } else if (bke_looking_at(c, b, "<!doctype", 9) || bke_looking_at(c, b, "<!DOCTYPE", 9)) {
          c.slice(bke_doctype_end(c, c.step(b, 10)), c.end)
        } else if (bke_looking_at(c, b, "<![CDATA[", 9)) {
          let e = c.indexOf("]]>", c.step(b, 9));
          if (e is StringIndex) { c.slice(c.step(e, 3), c.end) } else { "" }
        } else {
          c.slice(c.next(b), c.end)
        }
      } else if (c1 == 63) {
        if (bke_looking_at(c, b, "<?php", 5)) {
          let e = c.indexOf("?>", c.step(b, 2));
          if (e is StringIndex) { c.slice(c.step(e, 2), c.end) } else { "" }
        } else {
          bke_after_gt(c, bke_attrs_end(c, bke_name_end(c, c.step(b, 2))))
        }
      } else if (c1 == 47) {
        let from = c.step(b, 2);
        if (bke_decode(c.slice(from, bke_name_end(c, from)), true) == "floki") {
          c
        } else {
          bke_after_gt(c, if (bke_at(c, from) == 62) { c.next(from) } else { from })
        }
      } else if (c1 >= 0 && (bke_ws(c1) || !bke_letter(c1))) {
        c.slice(c.next(b), c.end)
      } else {
        let ne = bke_lit_end(c, c.next(b));
        let name = bke_tag_name(c, ne);
        if (name == "meta" || name == "link" || (name == "floki" && !bke_start_closed(c, ne))) {
          c
        } else {
          bke_start_rest(c, ne, name)
        }
      }
    }

The rest of `c` after the next `>` at or after `i` (`find_gt/2`), or `""`.

    let bke_after_gt(c: String, i: StringIndex): String {
      let gt = c.indexOf(">", i);
      if (gt is StringIndex) { c.slice(c.next(gt), c.end) } else { "" }
    }

`<!DOCTYPE` moves on 10 characters, one more than it has, and then reads
words and quoted strings up to a `>` outside quotes. So `<!DOCTYPE>` eats
the next tag too.

    let bke_doctype_end(s: String, i: StringIndex): StringIndex {
      if (i >= s.end) {
        s.end
      } else {
        let c = s[i];
        if (c == 62) {
          s.next(i)
        } else if (bke_ws(c)) {
          bke_doctype_end(s, s.next(i))
        } else if (c == 34 || c == 39) {
          bke_doctype_end(s, bke_value_end(s, i))
        } else {
          bke_doctype_end(s, bke_name_end(s, i))
        }
      }
    }

Text between tags is skipped to the next `<`, but text can hold a
reference, and a numeric reference ends at the next `;` however much
follows its digits: `&#1<meta;` is one character, and the `<meta` in it is
not a tag. Such a reference must start in the run of text just before the
`<` that has no whitespace, quote, `/`, `<` or `>` in it; the first `&` of
that run is where the tokenizer would try it. `r` starts where the token
before ended, so the run cannot reach back into it. Where reading goes on
if a reference swallows the `<` at `lt`; otherwise `lt` itself.

    let bke_swallowed(r: String, lt: StringIndex): StringIndex {
      if (r.slice(String.begin, lt).indexOf("&") is StringIndex) {
        let amp = bke_run_amp(r, lt, StringIndex.none);
        if (amp is StringIndex) { bke_data_to(r, amp, lt) } else { lt }
      } else {
        lt
      }
    }

    let bke_run_amp(s: String, i: StringIndex, amp: StringIndexOption): StringIndexOption {
      if (i <= String.begin) {
        amp
      } else {
        let p = s.prev(i);
        let c = s[p];
        if (bke_ws(c) || c == 39 || c == 34 || c == 47 || c == 62 || c == 60) {
          amp
        } else if (c == 38) {
          bke_run_amp(s, p, p)
        } else {
          bke_run_amp(s, p, amp)
        }
      }
    }

    let bke_data_to(s: String, i: StringIndex, lt: StringIndex): StringIndex {
      if (i >= lt) {
        lt
      } else if (s[i] == 38) {
        let e = bke_ref_end(s, i);
        if (e is StringIndex) {
          if (e > lt) { e } else { bke_data_to(s, e, lt) }
        } else {
          bke_data_to(s, s.next(i), lt)
        }
      } else {
        bke_data_to(s, s.next(i), lt)
      }
    }

A start tag: its name, its attributes, then everything up to the next `>`
whatever it is. A `/` anywhere in that last stretch makes the tag
self-closing, and a self-closing `<script/>` has no raw text after it.
Each of these takes the page from the tag's `<` on, and `ne`, where its
name ends.

The name, when it is one of the seven that matter here, else `""`. Most
tags are none of them, and a name that does not start with one of their
first letters (or with a reference, which could spell one) is not worth
decoding.

    let bke_tag_name(c: String, ne: StringIndex): String {
      let from = c.next(String.begin);
      let f = bke_at(c, from);
      if (f == 109 || f == 77 || f == 108 || f == 76 || f == 102 || f == 70 || f == 115 || f == 83 || f == 116 || f == 84 || f == 38) {
        let n = bke_decode(c.slice(from, ne), true);
        if (n == "meta" || n == "link" || n == "floki" || n == "script" || n == "style" || n == "title" || n == "textarea") { n } else { "" }
      } else {
        ""
      }
    }

    let bke_start_closed(c: String, ne: StringIndex): Boolean {
      let a = c.slice(ne, c.end);
      let ae = bke_fast_attrs_end(a, String.begin);
      let gt = a.indexOf(">", ae);
      a.slice(ae, if (gt is StringIndex) { gt } else { a.end }).indexOf("/") is StringIndex
    }

    let bke_start_rest(c: String, ne: StringIndex, name: String): String {
      let a = c.slice(ne, c.end);
      let ae = bke_fast_attrs_end(a, String.begin);
      let gt = a.indexOf(">", ae);
      let closed = a.slice(ae, if (gt is StringIndex) { gt } else { a.end }).indexOf("/") is StringIndex;
      let rest = if (gt is StringIndex) { a.slice(a.next(gt), a.end) } else { "" };
      if ((name == "script" || name == "style" || name == "title" || name == "textarea") && !closed) {
        rest.slice(bke_raw_end(rest, String.begin, name), rest.end)
      } else {
        rest
      }
    }

`bke_attrs_end`, a jump at a time: to the next `=`, and over the value
after it. `a` is the attribute list and what follows it. Between
attributes (names and whitespace) only `/`, `>` and `=` matter; a quote
there is part of a name. The only thing that could hide one of them is a
reference in a name, a numeric one that runs through an `=` to its `;`,
so a name with an `&` in it is left to the careful version, and so is an
`=` where a name should start, which is a name itself. (`?>` also
ends the list, one character before the `>`; nothing here is different
for it.)

    let bke_fast_attrs_end(a: String, i: StringIndex): StringIndex {
      let gt = a.indexOf(">", i);
      if (gt is StringIndex) {
        let head = a.slice(String.begin, gt);
        let eq = head.indexOf("=", i);
        let sl = head.indexOf("/", i);
        let slash = if (sl is StringIndex) { sl } else { gt };
        if (eq is StringIndex) {
          let amp = head.indexOf("&", i);
          let amp_at = if (amp is StringIndex) { amp } else { gt };
          if (slash < eq) {
            slash
          } else if (amp_at < eq || bke_skip_ws(a, i) == eq) {
            bke_attrs_end(a, i)
          } else {
            bke_fast_attrs_end(a, bke_value_end(a, bke_skip_ws(a, a.next(eq))))
          }
        } else {
          slash
        }
      } else {
        bke_attrs_end(a, i)
      }
    }

What a `meta` or `link` tag offers: `[slot, slot, value]`, a slot being
`""` or the index of what it is. A meta tag can be two things at once
(`property="og:image" name="twitter:image"`); a link is only ever the
icon. An element without the attribute Floki reads is nothing.

    let bke_tag_values(s: String, ne: StringIndex, name: String): List<String> {
      if (name == "meta") {
        let content = bke_attr(s, ne, "content");
        if (content.isEmpty) {
          ["", "", ""]
        } else {
          let p = bke_attr_or(s, ne, "property");
          let n = bke_attr_or(s, ne, "name");
          let slot = if (p == "og:image") { "0" } else if (p == "og:site_name") { "2" } else if (p == "og:description") { "3" } else { "" };
          let slot2 = if (n == "twitter:image") { "1" } else if (n == "description") { "4" } else { "" };
          [slot, slot2, bke_presence(content[0])]
        }
      } else {
        let href = bke_attr(s, ne, "href");
        if (!href.isEmpty && bke_has_word(bke_attr_or(s, ne, "rel"), "icon")) {
          ["5", "", bke_presence(href[0])]
        } else {
          ["", "", ""]
        }
      }
    }

Raw text ends at `</` and the tag's name in any case, followed by
whitespace or `>`. There must be a character there: `</script` at the very
end does not end it.

    let bke_raw_end(s: String, i: StringIndex, name: String): StringIndex {
      let p = s.indexOf("</", i);
      if (p is StringIndex) {
        let from = s.step(p, 2);
        let e = s.step(from, if (name == "textarea") { 8 } else if (name == "script") { 6 } else { 5 });
        let c = bke_at(s, e);
        if (e < s.end && bke_fold(s.slice(from, e), true) == name && (bke_ws(c) || c == 62)) {
          p
        } else {
          bke_raw_end(s, s.next(p), name)
        }
      } else {
        s.end
      }
    }

`presence/1`: `String.slice(s, 0, 2048)`. That counts graphemes; this
counts code points, so a value longer than 2,048 characters that has
combining marks or emoji sequences before the cut is cut a little sooner
here.

    export let bke_presence(s: String): String {
      s.slice(String.begin, bke_upto(s, String.begin, 2048))
    }

    let bke_upto(s: String, i: StringIndex, n: Int): StringIndex {
      if (n <= 0 || i >= s.end) { i } else { bke_upto(s, s.next(i), n - 1) }
    }

## URI.merge/2

`absolutize/2` is `base |> URI.merge(url) |> URI.to_string()`, rescued to
nil. Both functions are copied here as Elixir 1.19 has them, quirks
included, because the stored url is their output: `URI.parse/1` is a
regex, not a validator, it lower-cases the scheme and fills in a default
port that `to_string/1` then drops again, so `https://a.com:443/x` comes
out as `https://a.com/x`.

A parsed url is a list of eight slots: scheme, authority, userinfo, host,
port, path, query, fragment. `""` is nil, and anything present is written
with a `=` in front, because an empty query (`a?`) is not the same as
none.

    let bke_some(s: String): String { "=${s}" }

    let bke_val(slot: String): String { slot.slice(slot.next(String.begin), slot.end) }

`URI.parse/1`'s regex is
`^(([a-z][a-z0-9\+\-\.]*):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?`,
case-insensitive. The fragment's `.*` stops at a newline.

    export let bke_parse(s: String): List<String> {
      let se = bke_scheme_end(s);
      let scheme = if (se is StringIndex) { bke_some(bke_fold(s.slice(String.begin, se), true)) } else { "" };
      let a0 = if (se is StringIndex) { s.next(se) } else { String.begin };
      let has_auth = bke_looking_at(s, a0, "//", 2);
      let ae = if (has_auth) { bke_stop_at(s, s.step(a0, 2), false) } else { a0 };
      let pe = bke_stop_at(s, ae, true);
      let path = s.slice(ae, pe);
      let query = if (bke_at(s, pe) == 63) {
        let qe = s.indexOf("#", pe);
        bke_some(s.slice(s.next(pe), if (qe is StringIndex) { qe } else { s.end }))
      } else {
        ""
      };
      let hash = s.indexOf("#", pe);
      let fragment = if (hash is StringIndex) {
        let nl = s.indexOf("\n", hash);
        bke_some(s.slice(s.next(hash), if (nl is StringIndex) { nl } else { s.end }))
      } else {
        ""
      };
      let auth = bke_authority(if (has_auth) { s.slice(s.step(a0, 2), ae) } else { "" }, has_auth);
      let port = if (auth[3] != "") { auth[3] } else { bke_default_port(scheme) };
      [scheme, auth[0], auth[1], auth[2], port, if (path == "") { "" } else { bke_some(path) }, query, fragment]
    }

    let bke_scheme_end(s: String): StringIndexOption {
      if (bke_letter(bke_at(s, String.begin))) {
        let e = bke_scheme_run(s, s.next(String.begin));
        if (bke_at(s, e) == 58) { e } else { StringIndex.none }
      } else {
        StringIndex.none
      }
    }

    let bke_scheme_run(s: String, i: StringIndex): StringIndex {
      let c = bke_at(s, i);
      if (bke_letter(c) || (c >= 48 && c <= 57) || c == 43 || c == 45 || c == 46) { bke_scheme_run(s, s.next(i)) } else { i }
    }

The first `/`, `?` or `#` (with `path_only`, the first `?` or `#`).

    let bke_stop_at(s: String, i: StringIndex, path_only: Boolean): StringIndex {
      if (i >= s.end) {
        i
      } else {
        let c = s[i];
        if (c == 63 || c == 35 || (!path_only && c == 47)) { i } else { bke_stop_at(s, s.next(i), path_only) }
      }
    }

`split_authority/1`: authority, userinfo, host, port. `//` alone is an
empty host; otherwise an empty host is nil. The userinfo runs to the last
`@` (before any newline). The host is `[...]` of letters, digits, `:` and
`.`, or else everything up to a `:`, and it loses its brackets. The port
is the digits after that `:`, as few as there are (`:8x` is 8, `:x` none),
written as `Integer.to_string/1` would write it.

    let bke_authority(a: String, has: Boolean): List<String> {
      if (!has) {
        ["", "", "", ""]
      } else if (a == "") {
        ["=", "", "=", ""]
      } else {
        let at = bke_last_at(a, String.begin, StringIndex.none);
        let userinfo = if (at is StringIndex) { a.slice(String.begin, at) } else { "" };
        let h0 = if (at is StringIndex) { a.next(at) } else { String.begin };
        let he = bke_host_end(a, h0);
        let host = a.slice(h0, he);
        let port = if (bke_at(a, he) == 58) { bke_port(a, a.next(he), a.next(he)) } else { "" };
        [bke_some(a), if (userinfo == "") { "" } else { bke_some(userinfo) }, if (host == "") { "" } else { bke_some(bke_unbracket(host)) }, port]
      }
    }

    let bke_last_at(a: String, i: StringIndex, found: StringIndexOption): StringIndexOption {
      if (i >= a.end || a[i] == 10) {
        found
      } else if (a[i] == 64) {
        bke_last_at(a, a.next(i), i)
      } else {
        bke_last_at(a, a.next(i), found)
      }
    }

    let bke_host_end(a: String, i: StringIndex): StringIndex {
      if (bke_at(a, i) == 91) {
        let close = bke_bracket_end(a, a.next(i));
        if (close is StringIndex) { a.next(close) } else { bke_colon(a, i) }
      } else {
        bke_colon(a, i)
      }
    }

    let bke_bracket_end(a: String, i: StringIndex): StringIndexOption {
      let c = bke_at(a, i);
      if (c == 93) {
        i
      } else if (bke_letter(c) || (c >= 48 && c <= 57) || c == 58 || c == 46) {
        bke_bracket_end(a, a.next(i))
      } else {
        StringIndex.none
      }
    }

    let bke_colon(a: String, i: StringIndex): StringIndex {
      if (i >= a.end || a[i] == 58) { i } else { bke_colon(a, a.next(i)) }
    }

    let bke_port(a: String, from: StringIndex, i: StringIndex): String {
      let c = bke_at(a, i);
      if (c >= 48 && c <= 57) {
        bke_port(a, from, a.next(i))
      } else if (i == from) {
        ""
      } else {
        bke_some(bke_no_zeros(a.slice(from, i)))
      }
    }

    let bke_no_zeros(d: String): String {
      if (d.end > d.next(String.begin) && d[String.begin] == 48) {
        bke_no_zeros(d.slice(d.next(String.begin), d.end))
      } else {
        d
      }
    }

`String.trim_leading(host, "[")` and `trim_trailing(host, "]")`: every
bracket at either end, not just one.

    let bke_unbracket(h: String): String {
      if (!h.isEmpty && h[String.begin] == 91) {
        bke_unbracket(h.slice(h.next(String.begin), h.end))
      } else if (!h.isEmpty && h[h.prev(h.end)] == 93) {
        bke_unbracket(h.slice(String.begin, h.prev(h.end)))
      } else {
        h
      }
    }

`URI.default_port/1`, as Elixir registers them.

    let bke_default_port(scheme: String): String {
      if (scheme == "=http" || scheme == "=ws") {
        "=80"
      } else if (scheme == "=https" || scheme == "=wss") {
        "=443"
      } else if (scheme == "=ftp") {
        "=21"
      } else if (scheme == "=sftp") {
        "=22"
      } else if (scheme == "=tftp") {
        "=69"
      } else if (scheme == "=ldap") {
        "=389"
      } else {
        ""
      }
    }

`URI.merge/2`, clause for clause. A base without a scheme raises, which
`absolutize/2` rescues to nil: `""` here.

    export let bke_merge(base: String, rel: String): String {
      let b = bke_parse(base);
      let r = bke_parse(rel);
      if (b[0] == "") {
        ""
      } else if (r[0] != "") {
        bke_to_string([r[0], r[1], r[2], r[3], r[4], bke_rds_path(r[5]), r[6], r[7]])
      } else if (r[3] != "") {
        bke_to_string([b[0], r[1], r[2], r[3], r[4], bke_rds_path(r[5]), r[6], r[7]])
      } else if (r[5] == "") {
        bke_to_string([b[0], b[1], b[2], b[3], b[4], b[5], if (r[6] != "") { r[6] } else { b[6] }, r[7]])
      } else if (b[3] == "" && b[5] == "") {
        bke_to_string([b[0], b[1], b[2], b[3], b[4], bke_rds_path(r[5]), r[6], r[7]])
      } else {
        bke_to_string([b[0], b[1], b[2], b[3], b[4], bke_some(bke_merge_paths(b[5], bke_val(r[5]))), r[6], r[7]])
      }
    }

`String.Chars.URI.to_string/1`. A host with a path that does not start
with `/` raises (`""`); the default port is left out; a host with a colon
in it gets its brackets back.

    export let bke_to_string(u: List<String>): String {
      let path = bke_val(u[5]);
      if (u[3] != "" && u[5] != "" && path != "" && path[String.begin] != 47) {
        ""
      } else {
        let port = if (u[0] != "" && bke_default_port(u[0]) == u[4]) { "" } else { u[4] };
        let host = bke_val(u[3]);
        let authority = if (u[3] == "") {
          u[1]
        } else {
          let ui = if (u[2] == "") { "" } else { "${bke_val(u[2])}@" };
          let h = if (host.indexOf(":") is StringIndex) { "[${host}]" } else { host };
          let pt = if (port == "") { "" } else { ":${bke_val(port)}" };
          bke_some("${ui}${h}${pt}")
        };
        let scheme = if (u[0] == "") { "" } else { "${bke_val(u[0])}:" };
        let auth = if (authority == "") { "" } else { "//${bke_val(authority)}" };
        let query = if (u[6] == "") { "" } else { "?${bke_val(u[6])}" };
        let frag = if (u[7] == "") { "" } else { "#${bke_val(u[7])}" };
        "${scheme}${auth}${path}${query}${frag}"
      }
    }

### remove_dot_segments

`URI` splits a path on `/` and marks a leading empty segment as the root
(`:/`); merging puts a marker (`:+`) between the base's segments and the
reference's, and the clause `[_, :+ | tail]` drops the base's last segment.
Here the segments are read by position from the two lists, the root is
`"/"` and the marker `"/+"` (a segment has no `/` in it, so neither can be
one). The stack is a string, bottom first, each entry `R` (root) or `S`
and the segment, joined by `/`.

A path slot (`""` for nil) with its dot segments removed, still a slot.

    let bke_rds_path(slot: String): String {
      if (slot == "") {
        ""
      } else {
        let segs = bke_val(slot).split("/");
        bke_some(bke_join(bke_rds(segs, [], 0, "")))
      }
    }

    let bke_merge_paths(base_slot: String, rel: String): String {
      let base = if (base_slot == "") { "/" } else { bke_val(base_slot) };
      if (!rel.isEmpty && rel[String.begin] == 47) {
        bke_join(bke_rds(rel.split("/"), [], 0, ""))
      } else {
        bke_join(bke_rds(base.split("/"), rel.split("/"), 0, ""))
      }
    }

Item `k` of: `a`'s segments, then (if `b` has any) the marker, then `b`'s.
The first segment of either list is the root when it is empty.

    let bke_item(a: List<String>, b: List<String>, k: Int): String {
      if (k < a.length) {
        if (k == 0 && a[0] == "") { "/" } else { a[k] }
      } else if (k == a.length) {
        "/+"
      } else {
        let j = k - a.length - 1;
        if (j == 0 && b[0] == "") { "/" } else { b[j] }
      }
    }

    let bke_count(a: List<String>, b: List<String>): Int {
      if (b.isEmpty) { a.length } else { a.length + 1 + b.length }
    }

    let bke_push(acc: String, e: String): String {
      if (acc == "") { e } else { "${acc}/${e}" }
    }

    let bke_pop(acc: String): String {
      bke_pop_at(acc, acc.end)
    }

    let bke_pop_at(acc: String, i: StringIndex): String {
      if (i <= String.begin) {
        ""
      } else {
        let p = acc.prev(i);
        if (acc[p] == 47) { acc.slice(String.begin, p) } else { bke_pop_at(acc, p) }
      }
    }

    let bke_rds(a: List<String>, b: List<String>, k: Int, acc: String): String {
      let n = bke_count(a, b);
      if (k >= n) {
        acc
      } else {
        let item = bke_item(a, b, k);
        let last = k + 1 >= n;
        if (item == "/") {
          bke_rds(a, b, k + 1, bke_push(acc, "R"))
        } else if (!last && bke_item(a, b, k + 1) == "/+") {
          bke_rds(a, b, k + 2, acc)
        } else if (item == "." && last) {
          bke_push(acc, "S")
        } else if (item == ".") {
          bke_rds(a, b, k + 1, acc)
        } else if (item == ".." && acc == "R") {
          bke_rds(a, b, k + 1, acc)
        } else if (item == ".." && last && acc != "") {
          bke_push(bke_pop(acc), "S")
        } else if (item == ".." && acc != "") {
          bke_rds(a, b, k + 1, bke_pop(acc))
        } else {
          bke_rds(a, b, k + 1, bke_push(acc, "S${item}"))
        }
      }
    }

`join_reversed_segments/1`: the root alone is `/`; otherwise the root is an
empty first segment.

    let bke_join(acc: String): String {
      if (acc == "R") {
        "/"
      } else {
        acc.split("/").map { (e): String => e.slice(e.next(String.begin), e.end) }.join("/") { (e): String => e }
      }
    }

## The fields

`favicon/2`: the icon's href made absolute, or else
`scheme://host/favicon.ico` from the page's own url when it has a host (an
empty host counts; a missing scheme is written as nothing), or nil.

    export let bke_favicon(href: String, page_url: String): String {
      let abs = if (href == "") { "" } else { bke_merge(page_url, href) };
      if (abs != "") {
        abs
      } else {
        let u = bke_parse(page_url);
        if (u[3] == "") { "" } else { "${bke_val(u[0])}://${bke_val(u[3])}/favicon.ico" }
      }
    }

Everything `enrich/1` takes from a page, as the UPDATE's parameters:
`[image_url, site_name, clear_site_name, favicon_url, description]`, `""`
for nil. What Ecto's `cast/3` does to a value that is only whitespace
matters here: it becomes nil. For `og:site_name` that means the column is
cleared (`clear_site_name` is `"1"`). For the description it means nothing
changes, since it is only offered when the link has none; and a blank
`og:description` still beats a real `description`, because `presence/1`
keeps whitespace.

    export let bke_fields(html: String, page_url: String): List<String> {
      bke_page_fields(bke_scan(html), page_url)
    }

    export let bke_page_fields(m: List<String>, page_url: String): List<String> {
      let img = if (m[0] != "") { m[0] } else { m[1] };
      let image = if (img == "") { "" } else { bke_merge(page_url, img) };
      let site_blank = m[2] != "" && blkw_trim(m[2]) == "";
      let desc = if (m[3] != "") { m[3] } else { m[4] };
      [image, if (site_blank) { "" } else { m[2] }, if (site_blank) { "1" } else { "" }, bke_favicon(m[5], page_url), if (blkw_trim(desc) == "") { "" } else { desc }]
    }

## Bluesky

`~r{bsky\.app/profile/([^/]+)/post/([^/?#]+)}`, anywhere in the url, the
leftmost match: `[handle, rkey]`, or `[]`.

    export let bke_bsky(url: String): List<String> {
      bke_bsky_from(url, String.begin)
    }

    let bke_bsky_from(url: String, i: StringIndex): List<String> {
      let p = url.indexOf("bsky.app/profile/", i);
      if (p is StringIndex) {
        let h0 = url.step(p, 17);
        let he = url.indexOf("/", h0);
        if (he is StringIndex) {
          let r0 = url.step(he, 6);
          let re = bke_stop_at(url, r0, false);
          if (he > h0 && bke_looking_at(url, he, "/post/", 6) && re > r0) {
            [url.slice(h0, he), url.slice(r0, re)]
          } else {
            bke_bsky_from(url, url.next(p))
          }
        } else {
          []
        }
      } else {
        []
      }
    }

Req's `params:` go through `URI.encode_query/1`, which is
`encode_www_form/1` for each key and value: letters, digits and `-._~`
as they are, a space as `+`, every other byte as `%XX`.

    export let bke_form(s: String): String {
      bke_form_from(s, String.begin, String.begin, "")
    }

    let bke_form_from(s: String, i: StringIndex, run: StringIndex, acc: String): String {
      if (i >= s.end) {
        "${acc}${s.slice(run, i)}"
      } else {
        let c = s[i];
        if (bke_letter(c) || (c >= 48 && c <= 57) || c == 45 || c == 46 || c == 95 || c == 126) {
          bke_form_from(s, s.next(i), run, acc)
        } else {
          let enc = if (c == 32) { "+" } else { bke_pct_all(s.slice(i, s.next(i))) };
          bke_form_from(s, s.next(i), s.next(i), "${acc}${s.slice(run, i)}${enc}")
        }
      }
    }

Every byte of one character, as `%XX` with capital hex digits. Temper sees
code points, so the bytes are worked out from the code point.

    let bke_pct_all(ch: String): String {
      let c = ch[String.begin];
      if (c < 0x80) {
        bke_pct(c)
      } else if (c < 0x800) {
        "${bke_pct(192 + c / 64)}${bke_pct(128 + c % 64)}"
      } else if (c < 0x10000) {
        "${bke_pct(224 + c / 4096)}${bke_pct(128 + (c / 64) % 64)}${bke_pct(128 + c % 64)}"
      } else {
        "${bke_pct(240 + c / 262144)}${bke_pct(128 + (c / 4096) % 64)}${bke_pct(128 + (c / 64) % 64)}${bke_pct(128 + c % 64)}"
      }
    }

    let bke_pct(b: Int): String {
      let hex = "0123456789ABCDEF";
      let hi = hex.step(String.begin, b / 16);
      let lo = hex.step(String.begin, b % 16);
      "%${hex.slice(hi, hex.next(hi))}${hex.slice(lo, hex.next(lo))}"
    }
