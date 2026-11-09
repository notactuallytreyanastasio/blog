import { march_deep_eq, march_float_round, march_float_to_string, march_int_and, march_int_div, march_int_div_euclid, march_int_div_floor, march_int_mod, march_int_mod_euclid, march_int_mod_floor, march_int_not, march_int_or, march_int_ovf, march_int_popcount, march_int_shl, march_int_shr, march_int_wrapping_add, march_int_wrapping_mul, march_int_wrapping_sub, march_int_xor, march_string_byte_length, march_string_concat3, march_string_concat_n, march_string_contains, march_string_pad_left, march_string_to_float, march_unix_time, march_unix_time_ms } from "./march_runtime.mjs";

import { glue_mark, glue_save_best, glue_start_stage, glue_load_best, glue_seed_limbs, glue_sound, glue_paint, glue_fit, glue_launch_button, glue_touch, glue_input, glue_listen, glue_request_frame, glue_cell_get, glue_cell_put } from "./spin_glue.mjs";
import { march_dom_get_element_by_id as dom_get_element_by_id } from "./march_dom.mjs";
import { march_canvas_get_context as canvas_get_context } from "./march_canvas.mjs";


const int_to_string   = { _0: ($_, x) => String(x) };
const bool_to_string  = { _0: ($_, x) => String(x) };
const int_to_float    = { _0: ($_, x) => x };
const float_to_int    = { _0: ($_, x) => Math.trunc(x) };
const float_truncate  = { _0: ($_, x) => Math.trunc(x) };
const string_is_empty = { _0: ($_, x) => x === "" };
const not_bool        = { _0: ($_, x) => !x };
const negate_int      = { _0: ($_, x) => march_int_ovf(-x, 3) };
const negate_float    = { _0: ($_, x) => -x };
const float_abs       = { _0: ($_, x) => Math.abs(x) };
const float_floor     = { _0: ($_, x) => Math.floor(x) };
const float_ceil      = { _0: ($_, x) => Math.ceil(x) };
const float_to_string    = { _0: ($_, x) => march_float_to_string(x) };
const string_length      = { _0: ($_, x) => march_string_byte_length(x) };
const string_byte_length = { _0: ($_, x) => march_string_byte_length(x) };
const int_and = { _0: ($_, a, b) => march_int_and(a, b) };
const int_or = { _0: ($_, a, b) => march_int_or(a, b) };
const int_xor = { _0: ($_, a, b) => march_int_xor(a, b) };
const int_shl = { _0: ($_, a, b) => march_int_shl(a, b) };
const int_shr = { _0: ($_, a, b) => march_int_shr(a, b) };
const int_mod = { _0: ($_, a, b) => march_int_mod(a, b) };
const int_div = { _0: ($_, a, b) => march_int_div(a, b) };
const int_mod_euclid = { _0: ($_, a, b) => march_int_mod_euclid(a, b) };
const int_div_euclid = { _0: ($_, a, b) => march_int_div_euclid(a, b) };
const int_mod_floor = { _0: ($_, a, b) => march_int_mod_floor(a, b) };
const int_div_floor = { _0: ($_, a, b) => march_int_div_floor(a, b) };
const int_wrapping_add = { _0: ($_, a, b) => march_int_wrapping_add(a, b) };
const int_wrapping_sub = { _0: ($_, a, b) => march_int_wrapping_sub(a, b) };
const int_wrapping_mul = { _0: ($_, a, b) => march_int_wrapping_mul(a, b) };
const int_not = { _0: ($_, a) => march_int_not(a) };
const int_popcount = { _0: ($_, a) => march_int_popcount(a) };
const int_abs     = { _0: ($_, a) => Math.abs(a) };
const unix_time   = { _0: ($_) => march_unix_time() };
const unix_time_ms = { _0: ($_) => march_unix_time_ms() };
const float_round = { _0: ($_, a) => march_float_round(a) };
const dom_get_element_by_id$clo = { _0: ($_, p0) => dom_get_element_by_id(p0) };
const canvas_get_context$clo = { _0: ($_, p0) => canvas_get_context(p0) };
const glue_cell_put$clo = { _0: ($_, p0) => glue_cell_put(p0) };
const glue_cell_get$clo = { _0: ($_, ) => glue_cell_get() };
const glue_request_frame$clo = { _0: ($_, p0) => glue_request_frame(p0) };
const glue_listen$clo = { _0: ($_, p0) => glue_listen(p0) };
const glue_input$clo = { _0: ($_, ) => glue_input() };
const glue_touch$clo = { _0: ($_, ) => glue_touch() };
const glue_launch_button$clo = { _0: ($_, p0, p1, p2, p3) => glue_launch_button(p0, p1, p2, p3) };
const glue_fit$clo = { _0: ($_, p0, p1, p2, p3, p4) => glue_fit(p0, p1, p2, p3, p4) };
const glue_paint$clo = { _0: ($_, p0, p1) => glue_paint(p0, p1) };
const glue_sound$clo = { _0: ($_, p0, p1) => glue_sound(p0, p1) };
const glue_seed_limbs$clo = { _0: ($_, ) => glue_seed_limbs() };
const glue_load_best$clo = { _0: ($_, ) => glue_load_best() };
const glue_start_stage$clo = { _0: ($_, ) => glue_start_stage() };
const glue_save_best$clo = { _0: ($_, p0) => glue_save_best(p0) };
const glue_mark$clo = { _0: ($_, p0, p1) => glue_mark(p0, p1) };

function __eq_Option(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "None": {
      return true;
    }
    case "Some": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Result(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Ok": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Err": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_List(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Nil": {
      return true;
    }
    case "Cons": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Hamt$HEntry(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HEmpty": {
      return true;
    }
    case "HLeaf": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "HBranch": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "HCollision": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Map$Map(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HamtMap": {
      if (!__eq_HEntry(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Map$HEntry(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HEmpty": {
      return true;
    }
    case "HLeaf": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "HBranch": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "HCollision": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_LinearMap$LinearMap(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LinearMapRep": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Map(a._2, b._2)) return false;
      return true;
    }
  }
  return true;
}

function __eq_LinearMap$LinearSlot(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LinearSlotRep": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_Map(a._3, b._3)) return false;
      return true;
    }
  }
  return true;
}

function __eq_IOList$IOList(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Empty": {
      return true;
    }
    case "Str": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Segments": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Deque$Deque(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Deque": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      if (!__eq_List(a._2, b._2)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Html$Safe(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Safe": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Html$TrustedHtml(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TrustedHtml": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Html$TrustedAttr(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TrustedAttr": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Html$TrustedUrl(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TrustedUrl": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Html$TrustedCss(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TrustedCss": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Html$TrustedJs(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TrustedJs": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Http$Method(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Get": {
      return true;
    }
    case "Post": {
      return true;
    }
    case "Put": {
      return true;
    }
    case "Patch": {
      return true;
    }
    case "Delete": {
      return true;
    }
    case "Head": {
      return true;
    }
    case "Options": {
      return true;
    }
    case "Trace": {
      return true;
    }
    case "Connect": {
      return true;
    }
    case "Other": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Http$Scheme(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SchemeHttp": {
      return true;
    }
    case "SchemeHttps": {
      return true;
    }
  }
  return true;
}

function __eq_Http$Status(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Status": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Http$Header(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Header": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Http$UrlError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "InvalidScheme": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "MissingHost": {
      return true;
    }
    case "InvalidPort": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "MalformedUrl": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Http$Request(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Request": {
      if (!__eq_Method(a._0, b._0)) return false;
      if (!__eq_Scheme(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_Option(a._3, b._3)) return false;
      if (a._4 !== b._4) return false;
      if (!__eq_Option(a._5, b._5)) return false;
      if (!__eq_List(a._6, b._6)) return false;
      if (a._7 !== b._7) return false;
      return true;
    }
  }
  return true;
}

function __eq_Http$Response(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Response": {
      if (!__eq_Status(a._0, b._0)) return false;
      if (!__eq_List(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_HttpTransport$TransportError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ConnectionRefused": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ConnTimeout": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SendError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "RecvError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ConnParseError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Closed": {
      return true;
    }
    case "SchemeNotSupported": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_HttpClient$TransportError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ConnectionRefused": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ConnTimeout": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SendError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "RecvError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ConnParseError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Closed": {
      return true;
    }
  }
  return true;
}

function __eq_HttpClient$HttpError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HttpTransportError": {
      if (!__eq_TransportError(a._0, b._0)) return false;
      return true;
    }
    case "StepError": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "TooManyRedirects": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_HttpClient$RequestStepEntry(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "RequestStepEntry": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_HttpClient$ResponseStepEntry(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ResponseStepEntry": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_HttpClient$ErrorRecovery(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Recover": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Fail": {
      if (!__eq_HttpError(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_HttpClient$ErrorStepEntry(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ErrorStepEntry": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_HttpClient$Client(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Client": {
      if (!__eq_List(a._0, b._0)) return false;
      if (!__eq_List(a._1, b._1)) return false;
      if (!__eq_List(a._2, b._2)) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (a._5 !== b._5) return false;
      return true;
    }
  }
  return true;
}

function __eq_Seq$Step(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Continue": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Halt": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Seq$Seq(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Seq": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_File$FileError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NotFound": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Permission": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "IsDirectory": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "NotEmpty": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "IoError": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_File$FileKind(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "RegularFile": {
      return true;
    }
    case "Directory": {
      return true;
    }
    case "Symlink": {
      return true;
    }
    case "OtherKind": {
      return true;
    }
  }
  return true;
}

function __eq_File$FileStat(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "FileStat": {
      if (a._0 !== b._0) return false;
      if (!__eq_FileKind(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
  }
  return true;
}

function __eq_File$Seq(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Seq": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Sort$Heap(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HLeaf": {
      return true;
    }
    case "HNode": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Heap(a._2, b._2)) return false;
      if (!__eq_Heap(a._3, b._3)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Csv$CsvError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "FileError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CsvParseError": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Csv$CsvRow(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "CsvEof": {
      return true;
    }
    case "Row": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_WebSocket$WsFrame(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TextFrame": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "BinaryFrame": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Ping": {
      return true;
    }
    case "Pong": {
      return true;
    }
    case "Close": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_WebSocket$WsSocket(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "WsSocket": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_WebSocket$SelectResult(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "WsData": {
      if (!__eq_WsFrame(a._0, b._0)) return false;
      return true;
    }
    case "ActorMsg": {
      return true;
    }
    case "Timeout": {
      return true;
    }
  }
  return true;
}

function __eq_HttpServer$Upgrade(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NoUpgrade": {
      return true;
    }
    case "WebSocketUpgrade": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_HttpServer$Conn(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Conn": {
      if (a._0 !== b._0) return false;
      if (!__eq_Atom(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_List(a._3, b._3)) return false;
      if (a._4 !== b._4) return false;
      if (!__eq_List(a._5, b._5)) return false;
      if (a._6 !== b._6) return false;
      if (a._7 !== b._7) return false;
      if (!__eq_List(a._8, b._8)) return false;
      if (a._9 !== b._9) return false;
      if (a._10 !== b._10) return false;
      if (!__eq_List(a._11, b._11)) return false;
      if (!__eq_Upgrade(a._12, b._12)) return false;
      return true;
    }
  }
  return true;
}

function __eq_HttpServer$Server(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Server": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
  }
  return true;
}

function __eq_Set$SEntry(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SEmpty": {
      return true;
    }
    case "SLeaf": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "SBranch": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "SCollision": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Set$Set(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HamtSet": {
      if (a._0 !== b._0) return false;
      if (!__eq_SEntry(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_HashMap$HEntry(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HEmpty": {
      return true;
    }
    case "HLeaf": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "HBranch": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "HCollision": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_HashMap$HashMap(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HamtHashMap": {
      if (!__eq_HEntry(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Array$TrieNode(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TrieEmpty": {
      return true;
    }
    case "TrieLeaf": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "TrieBranch": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Array$PVec(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PVec": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_TrieNode(a._2, b._2)) return false;
      if (!__eq_List(a._3, b._3)) return false;
      return true;
    }
  }
  return true;
}

function __eq_BigInt$BigInt(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "BigInt": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Decimal$Decimal(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Decimal": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Duration$Duration(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Duration": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Bytes$Bytes(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Bytes": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Msgpack$Value(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Null": {
      return true;
    }
    case "Bool": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Int": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Str": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Bin": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "Array": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "Map": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Compress$Error(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "InvalidInput": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "InsufficientOutput": {
      return true;
    }
    case "Io": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Compress$Gzip$Level(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "BestSpeed": {
      return true;
    }
    case "Default": {
      return true;
    }
    case "BestCompression": {
      return true;
    }
    case "Custom": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Compress$Zstd$Level(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Fast": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Default": {
      return true;
    }
    case "Best": {
      return true;
    }
  }
  return true;
}

function __eq_Compress$Brotli$Mode(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Generic": {
      return true;
    }
    case "Text": {
      return true;
    }
    case "Font": {
      return true;
    }
  }
  return true;
}

function __eq_Compress$Brotli$Level(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Level": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Parser$Expected(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ExpLit": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ExpLabel": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ExpEof": {
      return true;
    }
  }
  return true;
}

function __eq_Parser$ParseErr(a, b) {
  if (a.pos !== b.pos) return false;
  if (!__eq_List(a.expected, b.expected)) return false;
  if (!__eq_List(a.context, b.context)) return false;
  return true;
}

function __eq_Parser$ParseReply(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ROk": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "RFail": {
      if (!__eq_ParseErr(a._0, b._0)) return false;
      return true;
    }
    case "RCut": {
      if (!__eq_ParseErr(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Parser$Parser(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Parser": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Toml$TomlValue(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TStr": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TInt": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TFloat": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TBool": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TNull": {
      return true;
    }
    case "TDatetime": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TArray": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "TTable": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Toml$TomlError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TomlError": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Xml$XmlNode(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Element": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      if (!__eq_List(a._2, b._2)) return false;
      return true;
    }
    case "Text": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CData": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Comment": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ProcessingInstruction": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Xml$XmlDoc(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "XmlDoc": {
      if (!__eq_Option(a._0, b._0)) return false;
      if (!__eq_XmlNode(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Xml$XmlError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "XmlError": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Xml$XmlFrame(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "XmlFrame": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      if (!__eq_List(a._2, b._2)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Yaml$YamlValue(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "YStr": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "YInt": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "YFloat": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "YBool": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "YNull": {
      return true;
    }
    case "YSeq": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "YMap": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Yaml$YamlError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "YamlError": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Socket$SocketError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ConnectionFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "WriteFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "RecvFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "RecvTimeout": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SocketOptionFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Dns$DnsError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NotFound": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ResolveError": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Udp$UdpError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "OpenFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ResolveFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ConnectFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SendFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "RecvFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Udp$UdpSocket(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "UdpSocket": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Udp$UdpAddr(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "UdpAddr": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Udp$UdpOptions(a, b) {
  if (a.reuse_addr !== b.reuse_addr) return false;
  if (a.reuse_port !== b.reuse_port) return false;
  if (a.broadcast !== b.broadcast) return false;
  if (a.gso !== b.gso) return false;
  if (a.gro !== b.gro) return false;
  if (a.recv_buffer !== b.recv_buffer) return false;
  if (a.send_buffer !== b.send_buffer) return false;
  return true;
}

function __eq_Udp$UdpStats(a, b) {
  if (a.rx_dropped !== b.rx_dropped) return false;
  if (a.tx_stalls !== b.tx_stalls) return false;
  return true;
}

function __eq_Process$ProcessResult(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ProcessResult": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Process$LiveProcess(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LiveProcess": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Cluster$NodeAddr(a, b) {
  if (a.host !== b.host) return false;
  if (a.port !== b.port) return false;
  return true;
}

function __eq_ClusterLoad$NodeLoad(a, b) {
  if (a.node_id !== b.node_id) return false;
  if (a.cpu_count !== b.cpu_count) return false;
  if (a.cpu_load_milli !== b.cpu_load_milli) return false;
  if (a.mem_total_mb !== b.mem_total_mb) return false;
  if (a.mem_avail_mb !== b.mem_avail_mb) return false;
  if (a.sampled_at !== b.sampled_at) return false;
  return true;
}

function __eq_ConsistentHash$HashRing(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HashRing": {
      if (!__eq_List(a._0, b._0)) return false;
      if (!__eq_Map(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Logger$Level(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Debug": {
      return true;
    }
    case "Info": {
      return true;
    }
    case "Warn": {
      return true;
    }
    case "Error": {
      return true;
    }
  }
  return true;
}

function __eq_Logger$LogValue(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LStr": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LInt": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LFloat": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LBool": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LAtom": {
      if (!__eq_Atom(a._0, b._0)) return false;
      return true;
    }
    case "LNull": {
      return true;
    }
  }
  return true;
}

function __eq_Logger$LogField(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LogField": {
      if (a._0 !== b._0) return false;
      if (!__eq_LogValue(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Logger$LogEntry(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LogEntry": {
      if (!__eq_Level(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (!__eq_List(a._4, b._4)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Logger$Appender(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Appender": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Logger$AppenderCall(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "AppenderCall": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (!__eq_List(a._4, b._4)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Diagnostics$CrashKind(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Panic": {
      return true;
    }
    case "ActorCrashed": {
      return true;
    }
    case "TaskFailed": {
      return true;
    }
  }
  return true;
}

function __eq_Diagnostics$DiagnosticValue(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DStr": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "DInt": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "DFloat": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "DBool": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "DNull": {
      return true;
    }
  }
  return true;
}

function __eq_Diagnostics$SourceLocation(a, b) {
  if (a.file !== b.file) return false;
  if (a.line !== b.line) return false;
  return true;
}

function __eq_Diagnostics$StackFrame(a, b) {
  if (a.name !== b.name) return false;
  if (a.file !== b.file) return false;
  if (a.line !== b.line) return false;
  return true;
}

function __eq_Diagnostics$ProcessInfo(a, b) {
  if (a.pid !== b.pid) return false;
  if (a.supervised !== b.supervised) return false;
  return true;
}

function __eq_Diagnostics$CrashReport(a, b) {
  if (!__eq_CrashKind(a.kind, b.kind)) return false;
  if (a.message !== b.message) return false;
  if (!__eq_Option(a.location, b.location)) return false;
  if (!__eq_List(a.backtrace, b.backtrace)) return false;
  if (!__eq_ProcessInfo(a.process, b.process)) return false;
  if (!__eq_List(a.context, b.context)) return false;
  return true;
}

function __eq_Diagnostics$ObserverHandle(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ObserverHandle": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Diagnostics$DiagFrame(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DiagFrame": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Diagnostics$DiagCrash(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DiagCrash": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_List(a._2, b._2)) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (!__eq_List(a._5, b._5)) return false;
      if (a._6 !== b._6) return false;
      if (a._7 !== b._7) return false;
      return true;
    }
  }
  return true;
}

function __eq_Actor$InspectError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "InspectTimeout": {
      return true;
    }
    case "InspectDead": {
      return true;
    }
    case "InspectSelf": {
      return true;
    }
    case "InspectFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Flow$Stage(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Stage": {
      if (!__eq_Seq(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Json$JsonValue(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Null": {
      return true;
    }
    case "Bool": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Number": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Str": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Array": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "Object": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Json$JsonPathStep(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "JPathField": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "JPathIndex": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Json$DecodeError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DecodeError": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Json$JsonPath(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Key": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Index": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_JsonStream$Event(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "EvObjStart": {
      return true;
    }
    case "EvObjEnd": {
      return true;
    }
    case "EvArrStart": {
      return true;
    }
    case "EvArrEnd": {
      return true;
    }
    case "EvKey": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "EvStr": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "EvNum": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "EvNumRaw": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "EvBool": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "EvNull": {
      return true;
    }
  }
  return true;
}

function __eq_JsonStream$JsonStreamError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "EMalformed": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "EDepthLimit": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ETokenLimit": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ETruncated": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_JsonStream$JsonLimits(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "JsonLimits": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_JsonStream$JsMode(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "MTop": {
      return true;
    }
    case "MDone": {
      return true;
    }
    case "MArrFirst": {
      return true;
    }
    case "MArrValue": {
      return true;
    }
    case "MArrNext": {
      return true;
    }
    case "MObjFirst": {
      return true;
    }
    case "MObjKey": {
      return true;
    }
    case "MObjColon": {
      return true;
    }
    case "MObjValue": {
      return true;
    }
    case "MObjNext": {
      return true;
    }
  }
  return true;
}

function __eq_JsonStream$JsEsc(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SPlain": {
      return true;
    }
    case "SEsc": {
      return true;
    }
    case "SHex": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_JsonStream$JsPartial(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PNone": {
      return true;
    }
    case "PLit": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "PStr": {
      if (!__eq_List(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_JsEsc(a._2, b._2)) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      return true;
    }
    case "PNum": {
      if (!__eq_List(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_JsonStream$JsCfg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "JsCfg": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
  }
  return true;
}

function __eq_JsonStream$JsState(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "StOk": {
      if (!__eq_JsCfg(a._0, b._0)) return false;
      if (!__eq_JsMode(a._1, b._1)) return false;
      if (!__eq_List(a._2, b._2)) return false;
      if (a._3 !== b._3) return false;
      if (!__eq_JsPartial(a._4, b._4)) return false;
      if (a._5 !== b._5) return false;
      return true;
    }
  }
  return true;
}

function __eq_JsonStream$JsFrame(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "FArr": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "FObjK": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "FObjV": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Recon$ActorInfo(a, b) {
  if (a.pid !== b.pid) return false;
  if (a.type_name !== b.type_name) return false;
  if (!__eq_List(a.names, b.names)) return false;
  if (a.status !== b.status) return false;
  if (a.mbox !== b.mbox) return false;
  if (a.held !== b.held) return false;
  if (!__eq_Option(a.parent, b.parent)) return false;
  if (a.children !== b.children) return false;
  if (a.slices !== b.slices) return false;
  if (a.msgs_in !== b.msgs_in) return false;
  if (a.msgs_out !== b.msgs_out) return false;
  if (a.crashes !== b.crashes) return false;
  if (a.child_crashes !== b.child_crashes) return false;
  return true;
}

function __eq_Recon$Supervision(a, b) {
  if (a.policy !== b.policy) return false;
  if (a.limit !== b.limit) return false;
  if (a.window_secs !== b.window_secs) return false;
  if (a.held !== b.held) return false;
  return true;
}

function __eq_Recon$TopRow(a, b) {
  if (a.pid !== b.pid) return false;
  if (a.type_name !== b.type_name) return false;
  if (!__eq_List(a.names, b.names)) return false;
  if (a.status !== b.status) return false;
  if (a.value !== b.value) return false;
  if (a.mbox !== b.mbox) return false;
  if (a.stack_bytes !== b.stack_bytes) return false;
  if (a.link !== b.link) return false;
  if (!__eq_Option(a.parent, b.parent)) return false;
  if (a.parent_type !== b.parent_type) return false;
  if (!__eq_Option(a.spawned_by, b.spawned_by)) return false;
  if (a.children !== b.children) return false;
  if (a.crashes !== b.crashes) return false;
  if (a.child_crashes !== b.child_crashes) return false;
  if (!__eq_Option(a.supervision, b.supervision)) return false;
  return true;
}

function __eq_Recon$SupNode(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SupNode": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_List(a._2, b._2)) return false;
      if (!__eq_List(a._3, b._3)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Recon$NodeStats(a, b) {
  if (a.actors !== b.actors) return false;
  if (a.queued !== b.queued) return false;
  if (!__eq_Option(a.rss_bytes, b.rss_bytes)) return false;
  if (!__eq_Option(a.live_objects, b.live_objects)) return false;
  if (a.schedulers !== b.schedulers) return false;
  if (a.crashes_total !== b.crashes_total) return false;
  return true;
}

function __eq_Recon$CrashReport(a, b) {
  if (a.seq !== b.seq) return false;
  if (a.kind !== b.kind) return false;
  if (!__eq_Option(a.pid, b.pid)) return false;
  if (a.type_name !== b.type_name) return false;
  if (!__eq_Option(a.supervisor, b.supervisor)) return false;
  if (a.restart !== b.restart) return false;
  if (a.at_ms !== b.at_ms) return false;
  return true;
}

function __eq_Recon$EpochReport(a, b) {
  if (a.current !== b.current) return false;
  if (!__eq_List(a.pins, b.pins)) return false;
  return true;
}

function __eq_Recon$FnVersion(a, b) {
  if (a.name !== b.name) return false;
  if (a.impl_hash !== b.impl_hash) return false;
  if (!__eq_Option(a.baseline_hash, b.baseline_hash)) return false;
  if (a.patched !== b.patched) return false;
  if (a.epoch !== b.epoch) return false;
  if (a.activated_at_ms !== b.activated_at_ms) return false;
  return true;
}

function __eq_Diagnose$Finding(a, b) {
  if (a.id !== b.id) return false;
  if (a.severity !== b.severity) return false;
  if (!__eq_List(a.rows, b.rows)) return false;
  if (a.next !== b.next) return false;
  return true;
}

function __eq_Trace$Limit(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "MaxEvents": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Rate": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Trace$EventKind(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Sent": {
      return true;
    }
    case "Received": {
      return true;
    }
    case "Spawned": {
      return true;
    }
    case "Exited": {
      return true;
    }
    case "Dropped": {
      return true;
    }
  }
  return true;
}

function __eq_Trace$Options(a, b) {
  if (!__eq_List(a.fns, b.fns)) return false;
  if (!__eq_List(a.events, b.events)) return false;
  if (!__eq_List(a.pids, b.pids)) return false;
  return true;
}

function __eq_Trace$ActorEvent(a, b) {
  if (!__eq_EventKind(a.kind, b.kind)) return false;
  if (a.pid !== b.pid) return false;
  if (!__eq_Option(a.peer, b.peer)) return false;
  if (!__eq_Option(a.msg_tag, b.msg_tag)) return false;
  if (!__eq_Option(a.reason, b.reason)) return false;
  if (a.epoch !== b.epoch) return false;
  if (a.at_ns !== b.at_ns) return false;
  return true;
}

function __eq_Trace$TraceId(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TraceId": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Trace$CallEvent(a, b) {
  if (a.caller !== b.caller) return false;
  if (a.fn_name !== b.fn_name) return false;
  if (a.epoch !== b.epoch) return false;
  if (a.at_ns !== b.at_ns) return false;
  return true;
}

function __eq_Trace$Batch(a, b) {
  if (!__eq_List(a.events, b.events)) return false;
  if (!__eq_List(a.actor_events, b.actor_events)) return false;
  if (a.recorded !== b.recorded) return false;
  if (a.dropped !== b.dropped) return false;
  if (a.rate_dropped !== b.rate_dropped) return false;
  if (a.queued !== b.queued) return false;
  if (a.done !== b.done) return false;
  if (!__eq_Option(a.why, b.why)) return false;
  return true;
}

function __eq_Trace$TraceError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LimitOutOfRange": {
      return true;
    }
    case "UnknownFunction": {
      return true;
    }
    case "TooManySessions": {
      return true;
    }
    case "NoSuchSession": {
      return true;
    }
    case "BadRequest": {
      return true;
    }
    case "PidsRequired": {
      return true;
    }
    case "UnknownPid": {
      return true;
    }
    case "Unavailable": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Regex$RegexAtom(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "RALit": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "RAAny": {
      return true;
    }
    case "RAClass": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "RADigit": {
      return true;
    }
    case "RAWord": {
      return true;
    }
    case "RASpace": {
      return true;
    }
    case "RANotDigit": {
      return true;
    }
    case "RANotWord": {
      return true;
    }
    case "RANotSpace": {
      return true;
    }
  }
  return true;
}

function __eq_Regex$RegexQuant(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "QOne": {
      return true;
    }
    case "QZeroOrMore": {
      return true;
    }
    case "QOneOrMore": {
      return true;
    }
    case "QOptional": {
      return true;
    }
  }
  return true;
}

function __eq_Regex$RegexItem(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "RegexItem": {
      if (!__eq_RegexAtom(a._0, b._0)) return false;
      if (!__eq_RegexQuant(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Regex$RegexPattern(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "RegexPattern": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Regex$RegexOpts(a, b) {
  if (a.case_insensitive !== b.case_insensitive) return false;
  if (a.multiline !== b.multiline) return false;
  return true;
}

function __eq_DateTime$Date(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Date": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_DateTime$Time(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Time": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_DateTime$DateTime(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DateTime": {
      if (!__eq_Date(a._0, b._0)) return false;
      if (!__eq_Time(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DateTime$Tz(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Tz": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_DateTime$LocalDateTime(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LocalDateTime": {
      if (!__eq_DateTime(a._0, b._0)) return false;
      if (!__eq_Tz(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Queue$Queue(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Queue": {
      if (!__eq_List(a._0, b._0)) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_AhoCorasick$AcNode(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "AcNode": {
      if (!__eq_List(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_List(a._2, b._2)) return false;
      return true;
    }
  }
  return true;
}

function __eq_AhoCorasick$Automaton(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Automaton": {
      if (!__eq_Array$PVec(a._0, b._0)) return false;
      if (!__eq_Array$PVec(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_AhoCorasick$Match(a, b) {
  if (a.start !== b.start) return false;
  if (a.stop !== b.stop) return false;
  if (a.pattern_index !== b.pattern_index) return false;
  if (a.pattern !== b.pattern) return false;
  return true;
}

function __eq_Random$Rng(a, b) {
  if (a.s0 !== b.s0) return false;
  if (a.s1 !== b.s1) return false;
  if (a.s2 !== b.s2) return false;
  if (a.s3 !== b.s3) return false;
  return true;
}

function __eq_Gen$Thunk(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Thunk": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Gen$GenTree(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "GenTree": {
      if (a._0 !== b._0) return false;
      if (!__eq_Thunk(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Gen$GenRng(a, b) {
  if (a.s0 !== b.s0) return false;
  if (a.s1 !== b.s1) return false;
  if (a.s2 !== b.s2) return false;
  if (a.s3 !== b.s3) return false;
  return true;
}

function __eq_Gen$Generator(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Generator": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Check$CheckConfig(a, b) {
  if (a.num_runs !== b.num_runs) return false;
  if (!__eq_Option(a.seed, b.seed)) return false;
  if (a.max_shrink_steps !== b.max_shrink_steps) return false;
  if (a.max_size !== b.max_size) return false;
  return true;
}

function __eq_Stats$QuantileMethod(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "InvertedCdf": {
      return true;
    }
    case "AveragedInvertedCdf": {
      return true;
    }
    case "ClosestObservation": {
      return true;
    }
    case "InterpolatedInvertedCdf": {
      return true;
    }
    case "Hazen": {
      return true;
    }
    case "Weibull": {
      return true;
    }
    case "Linear": {
      return true;
    }
    case "MedianUnbiased": {
      return true;
    }
    case "NormalUnbiased": {
      return true;
    }
  }
  return true;
}

function __eq_Plot$Color(a, b) {
  if (a.r !== b.r) return false;
  if (a.g !== b.g) return false;
  if (a.b !== b.b) return false;
  return true;
}

function __eq_Plot$Style(a, b) {
  if (!__eq_Color(a.line_color, b.line_color)) return false;
  if (!__eq_Color(a.fill_color, b.fill_color)) return false;
  if (a.line_width !== b.line_width) return false;
  if (a.point_radius !== b.point_radius) return false;
  if (a.font_size !== b.font_size) return false;
  if (a.opacity !== b.opacity) return false;
  return true;
}

function __eq_Plot$SeriesKind(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Line": {
      return true;
    }
    case "Scatter": {
      return true;
    }
    case "Bar": {
      return true;
    }
    case "HistogramSeries": {
      return true;
    }
  }
  return true;
}

function __eq_Plot$Series(a, b) {
  if (!__eq_SeriesKind(a.kind, b.kind)) return false;
  if (!__eq_List(a.xs, b.xs)) return false;
  if (!__eq_List(a.ys, b.ys)) return false;
  if (!__eq_Option(a.label, b.label)) return false;
  if (!__eq_Style(a.style, b.style)) return false;
  return true;
}

function __eq_Plot$Axis(a, b) {
  if (!__eq_Option(a.label, b.label)) return false;
  if (!__eq_Option(a.data_min, b.data_min)) return false;
  if (!__eq_Option(a.data_max, b.data_max)) return false;
  if (a.tick_count !== b.tick_count) return false;
  return true;
}

function __eq_Plot$Plot(a, b) {
  if (!__eq_Option(a.title, b.title)) return false;
  if (!__eq_List(a.series, b.series)) return false;
  if (!__eq_Axis(a.x_axis, b.x_axis)) return false;
  if (!__eq_Axis(a.y_axis, b.y_axis)) return false;
  if (a.width !== b.width) return false;
  if (a.height !== b.height) return false;
  if (a.margin !== b.margin) return false;
  if (a.show_legend !== b.show_legend) return false;
  if (a.show_grid !== b.show_grid) return false;
  return true;
}

function __eq_DataFrame$Value(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "IntVal": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "FloatVal": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "StrVal": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "BoolVal": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "NullVal": {
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$Column(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "IntCol": {
      if (a._0 !== b._0) return false;
      if (!__eq_NativeIntArr(a._1, b._1)) return false;
      return true;
    }
    case "FloatCol": {
      if (a._0 !== b._0) return false;
      if (!__eq_NativeFloatArr(a._1, b._1)) return false;
      return true;
    }
    case "StrCol": {
      if (a._0 !== b._0) return false;
      if (!__eq_TypedArray(a._1, b._1)) return false;
      return true;
    }
    case "BoolCol": {
      if (a._0 !== b._0) return false;
      if (!__eq_TypedArray(a._1, b._1)) return false;
      return true;
    }
    case "NullableIntCol": {
      if (a._0 !== b._0) return false;
      if (!__eq_NativeIntArr(a._1, b._1)) return false;
      if (!__eq_TypedArray(a._2, b._2)) return false;
      return true;
    }
    case "NullableFloatCol": {
      if (a._0 !== b._0) return false;
      if (!__eq_NativeFloatArr(a._1, b._1)) return false;
      if (!__eq_TypedArray(a._2, b._2)) return false;
      return true;
    }
    case "NullableStrCol": {
      if (a._0 !== b._0) return false;
      if (!__eq_TypedArray(a._1, b._1)) return false;
      if (!__eq_TypedArray(a._2, b._2)) return false;
      return true;
    }
    case "NullableBoolCol": {
      if (a._0 !== b._0) return false;
      if (!__eq_TypedArray(a._1, b._1)) return false;
      if (!__eq_TypedArray(a._2, b._2)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$Row(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Row": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$DataFrame(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DataFrame": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$ColumnBuilder(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "IntBuilder": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "FloatBuilder": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "StrBuilder": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "BoolBuilder": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "NullBuilder": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$ColExpr(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Col": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LitInt": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LitFloat": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LitStr": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LitBool": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Eq": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "Neq": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "Lt": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "Lte": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "Gt": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "Gte": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "And": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "Or": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "Not": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      return true;
    }
    case "Add": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "Sub": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "Mul": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "Div": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "StrContains": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "StrStartsWith": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "StrEndsWith": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "IsNull": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      return true;
    }
    case "IsNotNull": {
      if (!__eq_ColExpr(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$SortDir(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Asc": {
      return true;
    }
    case "Desc": {
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$JoinKind(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Inner": {
      return true;
    }
    case "Left": {
      return true;
    }
    case "Right": {
      return true;
    }
    case "Outer": {
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$Plan(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Source": {
      if (!__eq_DataFrame(a._0, b._0)) return false;
      return true;
    }
    case "Select": {
      if (!__eq_Plan(a._0, b._0)) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "Filter": {
      if (!__eq_Plan(a._0, b._0)) return false;
      if (!__eq_ColExpr(a._1, b._1)) return false;
      return true;
    }
    case "WithColumn": {
      if (!__eq_Plan(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "SortBy": {
      if (!__eq_Plan(a._0, b._0)) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "Limit": {
      if (!__eq_Plan(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Offset": {
      if (!__eq_Plan(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Rename": {
      if (!__eq_Plan(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "DropCols": {
      if (!__eq_Plan(a._0, b._0)) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "Join": {
      if (!__eq_Plan(a._0, b._0)) return false;
      if (!__eq_Plan(a._1, b._1)) return false;
      if (!__eq_List(a._2, b._2)) return false;
      if (!__eq_JoinKind(a._3, b._3)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$LazyFrame(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LazyFrame": {
      if (!__eq_Plan(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$CsvWriteOpts(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "CsvWriteOpts": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$AggExpr(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Sum": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Mean": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Min": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Max": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Count": {
      return true;
    }
    case "CountDistinct": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Std": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Variance": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "First": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Last": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Median": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "AggAs": {
      if (!__eq_AggExpr(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$GroupKey(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "GroupKey": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$GroupedFrame(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "GroupedFrame": {
      if (!__eq_DataFrame(a._0, b._0)) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$ColStats(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ColStats": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_Option(a._3, b._3)) return false;
      if (!__eq_Option(a._4, b._4)) return false;
      if (!__eq_Option(a._5, b._5)) return false;
      if (!__eq_Option(a._6, b._6)) return false;
      if (!__eq_Option(a._7, b._7)) return false;
      if (!__eq_Option(a._8, b._8)) return false;
      if (!__eq_Option(a._9, b._9)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DataFrame$WindowExpr(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "RowNum": {
      return true;
    }
    case "Rank": {
      if (a._0 !== b._0) return false;
      if (!__eq_SortDir(a._1, b._1)) return false;
      return true;
    }
    case "DenseRank": {
      if (a._0 !== b._0) return false;
      if (!__eq_SortDir(a._1, b._1)) return false;
      return true;
    }
    case "RunningSum": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "RunningMean": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Lag": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Value(a._2, b._2)) return false;
      return true;
    }
    case "Lead": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Value(a._2, b._2)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Tls$TlsVersion(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Tls12": {
      return true;
    }
    case "Tls13": {
      return true;
    }
  }
  return true;
}

function __eq_Tls$TlsError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TlsHandshakeFailed": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TlsCertError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TlsReadError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TlsWriteError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TlsContextError": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TlsReadTimeout": {
      return true;
    }
  }
  return true;
}

function __eq_Tls$TlsConfig(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TlsConfig": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_List(a._3, b._3)) return false;
      if (!__eq_TlsVersion(a._4, b._4)) return false;
      if (a._5 !== b._5) return false;
      return true;
    }
  }
  return true;
}

function __eq_Tls$TlsCtx(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TlsCtx": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Tls$TlsConn(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TlsConn": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_UUID$UUID(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "UUID": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Channel$Socket(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Socket": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_List(a._3, b._3)) return false;
      if (a._4 !== b._4) return false;
      return true;
    }
  }
  return true;
}

function __eq_Channel$HandleResult(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Reply": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "NoReply": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Stop": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Channel$ChannelMailbox(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ChannelIn": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "ChannelBroadcast": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "ChannelBroadcastFrom": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
    case "ChannelPush": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "ChannelLeave": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ChannelStop": {
      return true;
    }
  }
  return true;
}

function __eq_Channel$PubSubMsg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PubSubSubscribe": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "PubSubUnsubscribe": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "PubSubBroadcast": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
  }
  return true;
}

function __eq_Channel$BroadcastMsg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "BroadcastMsg": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Channel$LeaveReason(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NormalLeave": {
      return true;
    }
    case "Disconnect": {
      return true;
    }
    case "Kicked": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Channel$ChannelRoute(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ChannelRoute": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Channel$ChannelMsg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ChannelMsg": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      return true;
    }
  }
  return true;
}

function __eq_PubSub$PubSubState(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PubSubState": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_ChannelServer$JoinResult(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "JoinOk": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "JoinErr": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_ChannelServer$ChannelConfig(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ChannelConfig": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (a._5 !== b._5) return false;
      return true;
    }
  }
  return true;
}

function __eq_ChannelSocket$SocketConfig(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SocketConfig": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_List(a._3, b._3)) return false;
      return true;
    }
  }
  return true;
}

function __eq_ChannelSocket$ActiveChannels(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ActiveChannels": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Presence$PresenceMeta(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PresenceMeta": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Presence$PresenceEntry(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PresenceEntry": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Presence$PresenceState(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PresenceState": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Config$Value(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "CfgInt": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CfgFloat": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CfgString": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CfgBool": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CfgAtom": {
      if (!__eq_Atom(a._0, b._0)) return false;
      return true;
    }
    case "CfgList": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Config$Codec(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Codec": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Config$Key(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Key": {
      if (a._0 !== b._0) return false;
      if (!__eq_Codec(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Config$Error(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "KeyMissing": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "KeyWrongType": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Cli$FlagArity(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "BoolFlag": {
      return true;
    }
    case "ValueFlag": {
      return true;
    }
  }
  return true;
}

function __eq_Cli$FlagSpec(a, b) {
  if (a.long !== b.long) return false;
  if (!__eq_Option(a.short, b.short)) return false;
  if (!__eq_FlagArity(a.arity, b.arity)) return false;
  if (!__eq_Option(a.default, b.default)) return false;
  if (a.required !== b.required) return false;
  if (a.help !== b.help) return false;
  return true;
}

function __eq_Cli$CliError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "UnknownFlag": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "MissingValue": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "MissingRequired": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Cli$ParsedArgs(a, b) {
  if (!__eq_List(a.values, b.values)) return false;
  if (!__eq_List(a.positional, b.positional)) return false;
  return true;
}

function __eq_OrderedMap$Tree(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Leaf": {
      return true;
    }
    case "Node": {
      if (!__eq_Tree(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_Tree(a._3, b._3)) return false;
      if (a._4 !== b._4) return false;
      return true;
    }
  }
  return true;
}

function __eq_SortedSet$AvlTree(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "AvlLeaf": {
      return true;
    }
    case "AvlNode": {
      if (!__eq_AvlTree(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_AvlTree(a._2, b._2)) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
  }
  return true;
}

function __eq_Range$IntRange(a, b) {
  if (a.start !== b.start) return false;
  if (a.stop !== b.stop) return false;
  if (a.step !== b.step) return false;
  return true;
}

function __eq_MlKem$KeyPair(a, b) {
  if (!__eq_Bytes(a.public_key, b.public_key)) return false;
  if (!__eq_Bytes(a.secret_key, b.secret_key)) return false;
  return true;
}

function __eq_MlDsa$KeyPair(a, b) {
  if (!__eq_Bytes(a.public_key, b.public_key)) return false;
  if (!__eq_Bytes(a.secret_key, b.secret_key)) return false;
  return true;
}

function __eq_Signal$Sig(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Term": {
      return true;
    }
    case "Int": {
      return true;
    }
    case "Hup": {
      return true;
    }
    case "Usr1": {
      return true;
    }
    case "Usr2": {
      return true;
    }
  }
  return true;
}

function __eq_RRB$Vec(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Vec": {
      if (!__eq_Array$PVec(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_RRB$Slice(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Slice": {
      if (!__eq_Array$PVec(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Uri$URI(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "URI": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Option(a._2, b._2)) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (a._5 !== b._5) return false;
      return true;
    }
  }
  return true;
}

function __eq_Handle$Handle(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Handle": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_VectorClock$VectorClock(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "VectorClock": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_VectorClock$ClockOrder(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Before": {
      return true;
    }
    case "After": {
      return true;
    }
    case "Concurrent": {
      return true;
    }
    case "Equal": {
      return true;
    }
  }
  return true;
}

function __eq_CRDT$GCounter$T(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "GCounter": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_CRDT$PNCounter$T(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PNCounter": {
      if (!__eq_Map(a._0, b._0)) return false;
      if (!__eq_Map(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_CRDT$LWWRegister$T(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LWWRegister": {
      if (a._0 !== b._0) return false;
      if (!__eq_VectorClock(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_CRDT$ORSet$T(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ORSet": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Merkle$MerkleTree(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "MLeaf": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "MBranch": {
      if (a._0 !== b._0) return false;
      if (!__eq_MerkleTree(a._1, b._1)) return false;
      if (!__eq_MerkleTree(a._2, b._2)) return false;
      return true;
    }
  }
  return true;
}

function __eq_NodeCert$Cert(a, b) {
  if (a.node !== b.node) return false;
  if (!__eq_List(a.roles, b.roles)) return false;
  if (!__eq_List(a.flags, b.flags)) return false;
  if (a.not_after !== b.not_after) return false;
  if (a.issuer !== b.issuer) return false;
  if (a.pubkey !== b.pubkey) return false;
  if (a.serial !== b.serial) return false;
  return true;
}

function __eq_NodeCert$Signed(a, b) {
  if (!__eq_Cert(a.cert, b.cert)) return false;
  if (!__eq_List(a.body, b.body)) return false;
  if (!__eq_Bytes(a.signature, b.signature)) return false;
  return true;
}

function __eq_NodeCert$Revocation(a, b) {
  if (a.node !== b.node) return false;
  if (a.serial !== b.serial) return false;
  if (a.issued_at !== b.issued_at) return false;
  return true;
}

function __eq_NodeCert$SignedRevocation(a, b) {
  if (!__eq_Revocation(a.rev, b.rev)) return false;
  if (!__eq_List(a.body, b.body)) return false;
  if (!__eq_Bytes(a.signature, b.signature)) return false;
  return true;
}

function __eq_NodeCert$Credentials(a, b) {
  if (!__eq_Signed(a.signed, b.signed)) return false;
  if (!__eq_Bytes(a.secret_key, b.secret_key)) return false;
  if (!__eq_Bytes(a.operator_pubkey, b.operator_pubkey)) return false;
  if (a.revoked !== b.revoked) return false;
  return true;
}

function __eq_ClusterAuth$Auth(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Secret": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Certified": {
      if (!__eq_NodeCert$Credentials(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_ClusterAuth$FrameKeys(a, b) {
  if (!__eq_Bytes(a.tx_key, b.tx_key)) return false;
  if (!__eq_Bytes(a.rx_key, b.rx_key)) return false;
  return true;
}

function __eq_NodeIdentity$Identity(a, b) {
  if (a.name !== b.name) return false;
  if (a.node_id !== b.node_id) return false;
  if (a.incarnation !== b.incarnation) return false;
  return true;
}

function __eq_Handshake$HelloCert(a, b) {
  if (!__eq_List(a.cert, b.cert)) return false;
  if (!__eq_List(a.eph, b.eph)) return false;
  return true;
}

function __eq_Handshake$Hello(a, b) {
  if (!__eq_NodeIdentity$Identity(a.identity, b.identity)) return false;
  if (a.nonce !== b.nonce) return false;
  if (a.role !== b.role) return false;
  if (a.addr !== b.addr) return false;
  if (!__eq_Option(a.cert, b.cert)) return false;
  return true;
}

function __eq_GlobalPid$Pid(a, b) {
  if (a.node_id !== b.node_id) return false;
  if (a.local_pid !== b.local_pid) return false;
  if (a.creation !== b.creation) return false;
  return true;
}

function __eq_RemoteCall$RemoteRef(a, b) {
  if (a.module_name !== b.module_name) return false;
  if (a.fn_name !== b.fn_name) return false;
  if (a.sig_hash !== b.sig_hash) return false;
  if (a.impl_hash !== b.impl_hash) return false;
  return true;
}

function __eq_RemoteCall$CallError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DeadlineExceeded": {
      return true;
    }
    case "NoConnection": {
      return true;
    }
    case "RemoteExit": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TypeMismatch": {
      return true;
    }
    case "VersionSkew": {
      return true;
    }
    case "NoTarget": {
      return true;
    }
    case "Forbidden": {
      return true;
    }
  }
  return true;
}

function __eq_RemoteCall$Verdict(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Accept": {
      return true;
    }
    case "Reject": {
      if (!__eq_CallError(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_RemoteCall$ReplyResult(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Returned": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "Failed": {
      if (!__eq_CallError(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_RemoteCall$CallRequest(a, b) {
  if (!__eq_RemoteRef(a.fref, b.fref)) return false;
  if (!__eq_List(a.args, b.args)) return false;
  if (!__eq_Pid(a.reply_to, b.reply_to)) return false;
  if (a.deadline !== b.deadline) return false;
  if (a.correlation !== b.correlation) return false;
  return true;
}

function __eq_RemoteCall$CallReply(a, b) {
  if (a.correlation !== b.correlation) return false;
  if (!__eq_ReplyResult(a.result, b.result)) return false;
  return true;
}

function __eq_NodeRpc$Target(a, b) {
  if (a.sig_hash !== b.sig_hash) return false;
  if (a.impl_hash !== b.impl_hash) return false;
  if (a.invoke !== b.invoke) return false;
  return true;
}

function __eq_NodeRpc$Targets(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Targets": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_PeerRegistry$Peer(a, b) {
  if (a.node_id !== b.node_id) return false;
  if (!__eq_NodeIdentity$Identity(a.identity, b.identity)) return false;
  if (a.fd !== b.fd) return false;
  if (a.data_fd !== b.data_fd) return false;
  return true;
}

function __eq_PeerRegistry$Registry(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Registry": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_NetKernel$MacKeys(a, b) {
  if (!__eq_Bytes(a.tx_key, b.tx_key)) return false;
  if (!__eq_Bytes(a.rx_key, b.rx_key)) return false;
  return true;
}

function __eq_NetKernel$Authed(a, b) {
  if (!__eq_NodeIdentity$Identity(a.identity, b.identity)) return false;
  if (a.role !== b.role) return false;
  if (a.addr !== b.addr) return false;
  if (!__eq_Option(a.cert, b.cert)) return false;
  if (a.mac !== b.mac) return false;
  return true;
}

function __eq_Membership$MemberStatus(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Alive": {
      return true;
    }
    case "Suspect": {
      return true;
    }
    case "Dead": {
      return true;
    }
  }
  return true;
}

function __eq_Membership$Member(a, b) {
  if (a.node_id !== b.node_id) return false;
  if (!__eq_MemberStatus(a.status, b.status)) return false;
  if (a.incarnation !== b.incarnation) return false;
  if (a.creation !== b.creation) return false;
  if (a.name !== b.name) return false;
  if (a.addr !== b.addr) return false;
  return true;
}

function __eq_Membership$Members(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Members": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Swim$Config(a, b) {
  if (a.ack_timeout_ms !== b.ack_timeout_ms) return false;
  if (a.suspect_timeout_ms !== b.suspect_timeout_ms) return false;
  if (a.indirect_k !== b.indirect_k) return false;
  return true;
}

function __eq_Swim$Probe(a, b) {
  if (a.target !== b.target) return false;
  if (a.sent_at !== b.sent_at) return false;
  if (a.indirect_sent !== b.indirect_sent) return false;
  if (a.acked !== b.acked) return false;
  return true;
}

function __eq_Swim$State(a, b) {
  if (a.me !== b.me) return false;
  if (a.incarnation !== b.incarnation) return false;
  if (!__eq_Members(a.members, b.members)) return false;
  if (!__eq_Config(a.config, b.config)) return false;
  if (!__eq_Option(a.probe, b.probe)) return false;
  if (!__eq_Map(a.suspect_deadlines, b.suspect_deadlines)) return false;
  return true;
}

function __eq_Swim$Action(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SendPing": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SendPingReq": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Gossip": {
      if (!__eq_Member(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_SwimDriver$State(a, b) {
  if (!__eq_Swim$State(a.swim, b.swim)) return false;
  if (!__eq_Random$Rng(a.rng, b.rng)) return false;
  if (a.period_ms !== b.period_ms) return false;
  if (a.period_end !== b.period_end) return false;
  if (!__eq_Map(a.peer_loads, b.peer_loads)) return false;
  if (a.anti_entropy_next !== b.anti_entropy_next) return false;
  return true;
}

function __eq_SwimDriver$Event(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PingAck": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "GossipFrame": {
      if (!__eq_Member(a._0, b._0)) return false;
      return true;
    }
    case "GossipWithLoad": {
      if (!__eq_Member(a._0, b._0)) return false;
      if (!__eq_NodeLoad(a._1, b._1)) return false;
      return true;
    }
    case "PeerDown": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ConnLost": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_SwimDriver$WireMsg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SwimPing": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SwimPingAck": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SwimPingReq": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "SwimGossip": {
      if (a._0 !== b._0) return false;
      if (!__eq_MemberStatus(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "SwimGossipLoad": {
      if (a._0 !== b._0) return false;
      if (!__eq_MemberStatus(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_NodeLoad(a._3, b._3)) return false;
      return true;
    }
  }
  return true;
}

function __eq_GlobalRegistry$Entry(a, b) {
  if (a.node_id !== b.node_id) return false;
  if (a.pid !== b.pid) return false;
  if (!__eq_VectorClock(a.clock, b.clock)) return false;
  if (a.present !== b.present) return false;
  if (a.creation !== b.creation) return false;
  if (a.registrant !== b.registrant) return false;
  if (a.retired_at !== b.retired_at) return false;
  return true;
}

function __eq_GlobalRegistry$Names(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Names": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_NodeSend$SendError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NoConnection": {
      return true;
    }
    case "Refused": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_NodeSend$Delivery(a, b) {
  if (a.seq !== b.seq) return false;
  if (a.to_local_pid !== b.to_local_pid) return false;
  if (a.to_creation !== b.to_creation) return false;
  if (a.type_tag !== b.type_tag) return false;
  if (!__eq_List(a.payload, b.payload)) return false;
  if (a.schema !== b.schema) return false;
  if (a.from_node !== b.from_node) return false;
  return true;
}

function __eq_NodeQueue$Policy(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DropNew": {
      return true;
    }
    case "DropOld": {
      return true;
    }
    case "BlockSender": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Unbounded": {
      return true;
    }
  }
  return true;
}

function __eq_NodeQueue$EnqueueError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Backpressure": {
      return true;
    }
    case "NoConnection": {
      return true;
    }
    case "NotAuthorized": {
      return true;
    }
  }
  return true;
}

function __eq_NodeQueue$WriterState(a, b) {
  if (a.fd !== b.fd) return false;
  if (a.granted !== b.granted) return false;
  if (a.sent !== b.sent) return false;
  if (!__eq_Deque$Deque(a.pending, b.pending)) return false;
  if (!__eq_List(a.evicted, b.evicted)) return false;
  if (a.budget !== b.budget) return false;
  if (a.dead !== b.dead) return false;
  if (!__eq_Deque$Deque(a.waiting, b.waiting)) return false;
  if (!__eq_Deque$Deque(a.waiters, b.waiters)) return false;
  return true;
}

function __eq_NodeQueue__Writer_State(a, b) {
  if (a.budget !== b.budget) return false;
  if (a.dead !== b.dead) return false;
  if (!__eq_List(a.evicted, b.evicted)) return false;
  if (a.fd !== b.fd) return false;
  if (a.granted !== b.granted) return false;
  if (!__eq_Deque$Deque(a.pending, b.pending)) return false;
  if (a.sent !== b.sent) return false;
  if (!__eq_Deque$Deque(a.waiters, b.waiters)) return false;
  if (!__eq_Deque$Deque(a.waiting, b.waiting)) return false;
  return true;
}

function __eq_NodeQueue__Writer_Msg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TakeEvicted": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Wait": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Configure": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Enqueue": {
      if (a._0 !== b._0) return false;
      if (!__eq_Bytes(a._1, b._1)) return false;
      return true;
    }
    case "EnqueueEvicting": {
      if (a._0 !== b._0) return false;
      if (!__eq_Bytes(a._1, b._1)) return false;
      return true;
    }
    case "Credit": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Waiting": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Bytes(a._2, b._2)) return false;
      return true;
    }
    case "Withdraw": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Close": {
      return true;
    }
    case "CloseFd": {
      return true;
    }
  }
  return true;
}

function __eq_NodeQueue__Writer_Actor(a, b) {
  if (a.$d_dispatch !== b.$d_dispatch) return false;
  if (a.$e_alive !== b.$e_alive) return false;
  if (a.budget !== b.budget) return false;
  if (a.dead !== b.dead) return false;
  if (!__eq_List(a.evicted, b.evicted)) return false;
  if (a.fd !== b.fd) return false;
  if (a.granted !== b.granted) return false;
  if (!__eq_Deque$Deque(a.pending, b.pending)) return false;
  if (a.sent !== b.sent) return false;
  if (!__eq_Deque$Deque(a.waiters, b.waiters)) return false;
  if (!__eq_Deque$Deque(a.waiting, b.waiting)) return false;
  return true;
}

function __eq_NodeQueue$WriterReq(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "EvictedReq": {
      return true;
    }
    case "WaitReq": {
      return true;
    }
  }
  return true;
}

function __eq_DistLink$DownReason(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Normal": {
      return true;
    }
    case "Killed": {
      return true;
    }
    case "Crash": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "NodeDown": {
      return true;
    }
  }
  return true;
}

function __eq_DistLink$MonitorRef(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "MonitorRef": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_DistLink$PendingMonitor(a, b) {
  if (!__eq_MonitorRef(a.ref, b.ref)) return false;
  if (a.target_node !== b.target_node) return false;
  if (a.target_pid !== b.target_pid) return false;
  if (!__eq_GlobalPid$Pid(a.watcher_pid, b.watcher_pid)) return false;
  return true;
}

function __eq_DistLink$MonitorTable(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "MonitorTable": {
      if (!__eq_Map(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_DistSupervisor$RestartStrategy(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Permanent": {
      return true;
    }
    case "Transient": {
      return true;
    }
    case "Temporary": {
      return true;
    }
  }
  return true;
}

function __eq_DistSupervisor$SupervisionStrategy(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "OneForOne": {
      return true;
    }
    case "OneForAll": {
      return true;
    }
    case "RestForOne": {
      return true;
    }
  }
  return true;
}

function __eq_DistSupervisor$RemoteChild(a, b) {
  if (!__eq_RemoteRef(a.fn_ref, b.fn_ref)) return false;
  if (a.node_id !== b.node_id) return false;
  if (!__eq_RestartStrategy(a.restart, b.restart)) return false;
  return true;
}

function __eq_DistSupervisor$ChildState(a, b) {
  if (!__eq_RemoteChild(a.spec, b.spec)) return false;
  if (!__eq_GlobalPid$Pid(a.global_pid, b.global_pid)) return false;
  if (!__eq_DistLink$MonitorRef(a.ref, b.ref)) return false;
  return true;
}

function __eq_DistSupervisor$State(a, b) {
  if (!__eq_SupervisionStrategy(a.sup_strategy, b.sup_strategy)) return false;
  if (!__eq_List(a.children, b.children)) return false;
  return true;
}

function __eq_Session$Ops(a, b) {
  if (a.register !== b.register) return false;
  if (a.emit !== b.emit) return false;
  if (a.suspend !== b.suspend) return false;
  if (a.close !== b.close) return false;
  if (a.fail !== b.fail) return false;
  if (a.on_cancel !== b.on_cancel) return false;
  if (a.leave !== b.leave) return false;
  if (a.on_crash !== b.on_crash) return false;
  if (a.suspend_at_boundary !== b.suspend_at_boundary) return false;
  if (a.on_drain !== b.on_drain) return false;
  return true;
}

function __eq_Session$Outcome(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Finished": {
      return true;
    }
    case "Drained": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Session$InProcess(a, b) {
  if (!__eq_Ops(a.ops, b.ops)) return false;
  if (a.drain !== b.drain) return false;
  if (a.take !== b.take) return false;
  if (a.crash !== b.crash) return false;
  if (a.queued !== b.queued) return false;
  if (a.step !== b.step) return false;
  if (a.drain_role !== b.drain_role) return false;
  if (a.undelivered !== b.undelivered) return false;
  if (a.drained !== b.drained) return false;
  if (a.sent !== b.sent) return false;
  if (a.consumed !== b.consumed) return false;
  if (a.returned !== b.returned) return false;
  if (a.close !== b.close) return false;
  return true;
}

function __eq_Session$InProcessState(a, b) {
  if (!__eq_Vault(a.handlers, b.handlers)) return false;
  if (!__eq_Vault(a.waiting, b.waiting)) return false;
  if (!__eq_Vault(a.cancel_hs, b.cancel_hs)) return false;
  if (!__eq_Vault(a.crash_hs, b.crash_hs)) return false;
  if (!__eq_Vault(a.drain_hs, b.drain_hs)) return false;
  if (!__eq_Vault(a.boundary, b.boundary)) return false;
  if (!__eq_Vault(a.draining, b.draining)) return false;
  if (!__eq_Vault(a.undeliv, b.undeliv)) return false;
  if (!__eq_Vault(a.gone, b.gone)) return false;
  if (!__eq_Vault(a.meta, b.meta)) return false;
  if (!__eq_Vault(a.roles, b.roles)) return false;
  if (!__eq_Vault(a.queue, b.queue)) return false;
  if (a.trace !== b.trace) return false;
  return true;
}

function __eq_Session$Theory$SessionGlobal(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "GEnd": {
      return true;
    }
    case "GMsg": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_SessionGlobal(a._3, b._3)) return false;
      return true;
    }
    case "GChoice": {
      if (a._0 !== b._0) return false;
      if (!__eq_SessionGBranches(a._1, b._1)) return false;
      return true;
    }
    case "GLoop": {
      if (!__eq_SessionGlobal(a._0, b._0)) return false;
      if (!__eq_SessionGlobal(a._1, b._1)) return false;
      return true;
    }
    case "GVar": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Session$Theory$SessionGBranches(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "GBNil": {
      return true;
    }
    case "GBCons": {
      if (a._0 !== b._0) return false;
      if (!__eq_SessionGlobal(a._1, b._1)) return false;
      if (!__eq_SessionGBranches(a._2, b._2)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Session$Theory$SessionLocal(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LEnd": {
      return true;
    }
    case "LSend": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_SessionLocal(a._2, b._2)) return false;
      return true;
    }
    case "LRecv": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_SessionLocal(a._2, b._2)) return false;
      return true;
    }
    case "LChoose": {
      if (!__eq_SessionLBranches(a._0, b._0)) return false;
      return true;
    }
    case "LOffer": {
      if (!__eq_SessionLBranches(a._0, b._0)) return false;
      return true;
    }
    case "LRec": {
      if (!__eq_SessionLocal(a._0, b._0)) return false;
      return true;
    }
    case "LVar": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Session$Theory$SessionLBranches(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LBNil": {
      return true;
    }
    case "LBCons": {
      if (a._0 !== b._0) return false;
      if (!__eq_SessionLocal(a._1, b._1)) return false;
      if (!__eq_SessionLBranches(a._2, b._2)) return false;
      return true;
    }
  }
  return true;
}

function __eq_ClusterNode$CnConfig(a, b) {
  if (a.name !== b.name) return false;
  if (a.listen_port !== b.listen_port) return false;
  if (a.advertise !== b.advertise) return false;
  if (!__eq_List(a.seeds, b.seeds)) return false;
  if (a.secret !== b.secret) return false;
  if (a.creation !== b.creation) return false;
  if (!__eq_Swim$Config(a.swim, b.swim)) return false;
  if (a.period_ms !== b.period_ms) return false;
  if (a.tick_ms !== b.tick_ms) return false;
  if (a.redial_min_ms !== b.redial_min_ms) return false;
  if (a.redial_max_ms !== b.redial_max_ms) return false;
  if (a.dial_timeout_ms !== b.dial_timeout_ms) return false;
  if (a.handshake_timeout_ms !== b.handshake_timeout_ms) return false;
  if (!__eq_ClusterAuth$Auth(a.auth, b.auth)) return false;
  if (!__eq_List(a.revocations, b.revocations)) return false;
  if (!__eq_Option(a.cert_files, b.cert_files)) return false;
  if (a.tombstone_grace_ms !== b.tombstone_grace_ms) return false;
  return true;
}

function __eq_ClusterNode$CertFiles(a, b) {
  if (a.cert !== b.cert) return false;
  if (a.key !== b.key) return false;
  if (a.poll_ms !== b.poll_ms) return false;
  return true;
}

function __eq_ClusterNode$NodeInfo(a, b) {
  if (a.node_id !== b.node_id) return false;
  if (a.name !== b.name) return false;
  if (a.addr !== b.addr) return false;
  if (a.creation !== b.creation) return false;
  if (a.incarnation !== b.incarnation) return false;
  return true;
}

function __eq_ClusterNode$NodeEvent(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NodeUp": {
      if (!__eq_NodeInfo(a._0, b._0)) return false;
      return true;
    }
    case "NodeSuspect": {
      if (!__eq_NodeInfo(a._0, b._0)) return false;
      return true;
    }
    case "NodeDead": {
      if (!__eq_NodeInfo(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "NodeRejoined": {
      if (!__eq_NodeInfo(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_ClusterNode$SecurityEvent(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HandshakeRejected": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "FrameRejected": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "RawSendRefused": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "CertReplaced": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "CertRefused": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_ClusterNode$CnLink(a, b) {
  if (a.node_id !== b.node_id) return false;
  if (a.gen !== b.gen) return false;
  if (a.cfd !== b.cfd) return false;
  if (a.dfd !== b.dfd) return false;
  if (a.dialer !== b.dialer) return false;
  if (a.cw !== b.cw) return false;
  if (a.creation !== b.creation) return false;
  if (!__eq_Bytes(a.binding, b.binding)) return false;
  if (a.cu_sent !== b.cu_sent) return false;
  if (a.cu_seen !== b.cu_seen) return false;
  return true;
}

function __eq_ClusterNode$CnHalf(a, b) {
  if (a.cfd !== b.cfd) return false;
  if (a.dfd !== b.dfd) return false;
  if (a.name !== b.name) return false;
  if (a.addr !== b.addr) return false;
  if (a.creation !== b.creation) return false;
  return true;
}

function __eq_ClusterNode$CnState(a, b) {
  if (!__eq_CnConfig(a.cfg, b.cfg)) return false;
  if (a.me !== b.me) return false;
  if (!__eq_SwimDriver$State(a.driver, b.driver)) return false;
  if (!__eq_Map(a.links, b.links)) return false;
  if (!__eq_Map(a.halves, b.halves)) return false;
  if (a.gen !== b.gen) return false;
  if (!__eq_Map(a.dialing, b.dialing)) return false;
  if (!__eq_Map(a.backoff, b.backoff)) return false;
  if (!__eq_List(a.pending, b.pending)) return false;
  if (!__eq_Map(a.relays, b.relays)) return false;
  if (!__eq_List(a.refused, b.refused)) return false;
  if (!__eq_Map(a.seed_ids, b.seed_ids)) return false;
  if (!__eq_List(a.rejoining, b.rejoining)) return false;
  if (a.stopped !== b.stopped) return false;
  if (!__eq_GlobalRegistry$Names(a.reg, b.reg)) return false;
  if (!__eq_Map(a.regs, b.regs)) return false;
  if (!__eq_Map(a.vis, b.vis)) return false;
  if (!__eq_Map(a.certs, b.certs)) return false;
  if (!__eq_List(a.revs, b.revs)) return false;
  if (!__eq_Map(a.cert_dead, b.cert_dead)) return false;
  if (a.rotated !== b.rotated) return false;
  if (a.reg_swept_at !== b.reg_swept_at) return false;
  if (a.remembered !== b.remembered) return false;
  if (a.reg_synced !== b.reg_synced) return false;
  return true;
}

function __eq_ClusterNode$NameEvent(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Bound": {
      if (a._0 !== b._0) return false;
      if (!__eq_GlobalPid$Pid(a._1, b._1)) return false;
      return true;
    }
    case "Unbound": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Lost": {
      if (a._0 !== b._0) return false;
      if (!__eq_GlobalPid$Pid(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_ClusterNode$RegisterError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Taken": {
      if (!__eq_GlobalPid$Pid(a._0, b._0)) return false;
      return true;
    }
    case "Stopped": {
      return true;
    }
  }
  return true;
}

function __eq_ClusterNode$CnEffect(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Send": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "Dial": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Install": {
      if (!__eq_CnLink(a._0, b._0)) return false;
      return true;
    }
    case "Drop": {
      if (!__eq_CnLink(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Discard": {
      if (!__eq_CnLink(a._0, b._0)) return false;
      return true;
    }
    case "Emit": {
      if (!__eq_NodeEvent(a._0, b._0)) return false;
      return true;
    }
    case "Named": {
      if (a._0 !== b._0) return false;
      if (!__eq_NameEvent(a._1, b._1)) return false;
      return true;
    }
    case "Unwatch": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_ClusterNode__CtlWriter_State(a, b) {
  if (a.dead !== b.dead) return false;
  if (a.fd !== b.fd) return false;
  return true;
}

function __eq_ClusterNode__CtlWriter_Msg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "CtlUse": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CtlWrite": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "CtlStop": {
      return true;
    }
    case "CtlClose": {
      return true;
    }
  }
  return true;
}

function __eq_ClusterNode__CtlWriter_Actor(a, b) {
  if (a.$d_dispatch !== b.$d_dispatch) return false;
  if (a.$e_alive !== b.$e_alive) return false;
  if (a.dead !== b.dead) return false;
  if (a.fd !== b.fd) return false;
  return true;
}

function __eq_ClusterNode$CnHandle(a, b) {
  if (a.pid !== b.pid) return false;
  if (a.name !== b.name) return false;
  if (a.node_id !== b.node_id) return false;
  if (a.advertise !== b.advertise) return false;
  if (!__eq_Vault(a.members, b.members)) return false;
  if (!__eq_Vault(a.subs, b.subs)) return false;
  if (!__eq_Vault(a.meta, b.meta)) return false;
  if (!__eq_Vault(a.names, b.names)) return false;
  if (!__eq_Vault(a.claims, b.claims)) return false;
  if (!__eq_Vault(a.watches, b.watches)) return false;
  if (!__eq_Vault(a.links, b.links)) return false;
  if (!__eq_Vault(a.qs, b.qs)) return false;
  if (!__eq_Vault(a.causes, b.causes)) return false;
  if (!__eq_Vault(a.routes, b.routes)) return false;
  if (!__eq_Vault(a.closes, b.closes)) return false;
  if (!__eq_Vault(a.downs, b.downs)) return false;
  if (!__eq_Vault(a.fired, b.fired)) return false;
  if (!__eq_Vault(a.failed, b.failed)) return false;
  if (!__eq_Vault(a.sfailed, b.sfailed)) return false;
  if (!__eq_Vault(a.certs, b.certs)) return false;
  if (!__eq_Vault(a.sec, b.sec)) return false;
  if (!__eq_Vault(a.revs, b.revs)) return false;
  if (!__eq_Bytes(a.op_pub, b.op_pub)) return false;
  if (!__eq_Vault(a.auth, b.auth)) return false;
  if (!__eq_Vault(a.strs, b.strs)) return false;
  if (!__eq_Vault(a.registrants, b.registrants)) return false;
  return true;
}

function __eq_ClusterNode__RegWatch_State(a, b) {
  if (a.n !== b.n) return false;
  return true;
}

function __eq_ClusterNode__RegWatch_Msg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "WatchPid": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_ClusterNode__RegWatch_Actor(a, b) {
  if (a.$d_dispatch !== b.$d_dispatch) return false;
  if (a.$e_alive !== b.$e_alive) return false;
  if (a.n !== b.n) return false;
  return true;
}

function __eq_ClusterNode__ClusterNodeActor_State(a, b) {
  if (!__eq_CnHandle(a.h, b.h)) return false;
  if (!__eq_CnState(a.st, b.st)) return false;
  if (a.started !== b.started) return false;
  return true;
}

function __eq_ClusterNode__ClusterNodeActor_Msg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Boot": {
      if (!__eq_CnState(a._0, b._0)) return false;
      if (!__eq_CnHandle(a._1, b._1)) return false;
      return true;
    }
    case "Tick": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Accepted": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (a._5 !== b._5) return false;
      if (!__eq_Option(a._6, b._6)) return false;
      return true;
    }
    case "Dialed": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (a._5 !== b._5) return false;
      if (a._6 !== b._6) return false;
      if (!__eq_Option(a._7, b._7)) return false;
      return true;
    }
    case "SeedIsSelf": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "DialFailed": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "CtlFrame": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_List(a._3, b._3)) return false;
      return true;
    }
    case "ReplaceCert": {
      if (!__eq_NodeCert$Signed(a._0, b._0)) return false;
      if (!__eq_Bytes(a._1, b._1)) return false;
      return true;
    }
    case "LinkClosed": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Register": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "Revoke": {
      if (!__eq_NodeCert$SignedRevocation(a._0, b._0)) return false;
      return true;
    }
    case "Unregister": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LocalDown": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "MoveReader": {
      if (a._0 !== b._0) return false;
      if (!__eq_CnLink(a._1, b._1)) return false;
      if (!__eq_List(a._2, b._2)) return false;
      if (!__eq_List(a._3, b._3)) return false;
      return true;
    }
    case "MoveTicker": {
      return true;
    }
    case "MoveAcceptor": {
      return true;
    }
    case "Shutdown": {
      return true;
    }
  }
  return true;
}

function __eq_ClusterNode__ClusterNodeActor_Actor(a, b) {
  if (a.$d_dispatch !== b.$d_dispatch) return false;
  if (a.$e_alive !== b.$e_alive) return false;
  if (!__eq_CnHandle(a.h, b.h)) return false;
  if (!__eq_CnState(a.st, b.st)) return false;
  if (a.started !== b.started) return false;
  return true;
}

function __eq_ClusterNode$NodeActorState(a, b) {
  if (!__eq_CnState(a.st, b.st)) return false;
  if (!__eq_CnHandle(a.h, b.h)) return false;
  if (a.started !== b.started) return false;
  return true;
}

function __eq_ClusterNode$ClusterOps(a, b) {
  if (a.node_id !== b.node_id) return false;
  if (a.stop !== b.stop) return false;
  if (a.subscribe !== b.subscribe) return false;
  if (a.unsubscribe !== b.unsubscribe) return false;
  if (a.members !== b.members) return false;
  if (a.all_members !== b.all_members) return false;
  if (a.addr_of !== b.addr_of) return false;
  if (a.name_of !== b.name_of) return false;
  if (a.link_count !== b.link_count) return false;
  if (a.register !== b.register) return false;
  if (a.unregister !== b.unregister) return false;
  if (a.lookup !== b.lookup) return false;
  if (a.registrant !== b.registrant) return false;
  if (a.names !== b.names) return false;
  if (a.watch !== b.watch) return false;
  if (a.unwatch !== b.unwatch) return false;
  if (a.stale_bindings !== b.stale_bindings) return false;
  if (a.creation !== b.creation) return false;
  if (a.next_id !== b.next_id) return false;
  if (a.queue_for !== b.queue_for) return false;
  if (a.session_queue_for !== b.session_queue_for) return false;
  if (a.send_msg !== b.send_msg) return false;
  if (a.route !== b.route) return false;
  if (a.route_type !== b.route_type) return false;
  if (a.route_session !== b.route_session) return false;
  if (a.unroute !== b.unroute) return false;
  if (a.on_peer_closed !== b.on_peer_closed) return false;
  if (a.off_peer_closed !== b.off_peer_closed) return false;
  if (a.on_delivery_failed !== b.on_delivery_failed) return false;
  if (a.on_session_failed !== b.on_session_failed) return false;
  if (a.off_session_failed !== b.off_session_failed) return false;
  if (a.monitor_remote !== b.monitor_remote) return false;
  if (a.demonitor_remote !== b.demonitor_remote) return false;
  if (a.peer_cert !== b.peer_cert) return false;
  if (a.own_cert !== b.own_cert) return false;
  if (a.frames_rejected !== b.frames_rejected) return false;
  if (a.raw_refused !== b.raw_refused) return false;
  if (a.revoke !== b.revoke) return false;
  if (a.revocations !== b.revocations) return false;
  if (a.replace_cert !== b.replace_cert) return false;
  if (a.on_security_event !== b.on_security_event) return false;
  if (a.off_security_event !== b.off_security_event) return false;
  if (a.registry_synced !== b.registry_synced) return false;
  if (a.rejoined_at !== b.rejoined_at) return false;
  if (a.attach_session !== b.attach_session) return false;
  if (a.handshake !== b.handshake) return false;
  return true;
}

function __eq_SessionNode$Link(a, b) {
  if (a.role !== b.role) return false;
  if (a.data_fd !== b.data_fd) return false;
  if (a.control_fd !== b.control_fd) return false;
  if (!__eq_GlobalPid$Pid(a.peer, b.peer)) return false;
  if (a.q !== b.q) return false;
  if (!__eq_Task(a.control, b.control)) return false;
  return true;
}

function __eq_SessionNode$EndpointState(a, b) {
  if (a.n !== b.n) return false;
  if (a.links !== b.links) return false;
  if (a.ended !== b.ended) return false;
  if (!__eq_List(a.failed, b.failed)) return false;
  if (!__eq_List(a.waiters, b.waiters)) return false;
  return true;
}

function __eq_SessionNode$Party(a, b) {
  if (a.my_role !== b.my_role) return false;
  if (a.node_id !== b.node_id) return false;
  if (!__eq_Vault(a.handlers, b.handlers)) return false;
  if (!__eq_Vault(a.waiting, b.waiting)) return false;
  if (!__eq_Vault(a.pending, b.pending)) return false;
  if (!__eq_Vault(a.meta, b.meta)) return false;
  if (!__eq_Vault(a.forward, b.forward)) return false;
  if (!__eq_Vault(a.why, b.why)) return false;
  if (!__eq_Vault(a.gone, b.gone)) return false;
  if (!__eq_Vault(a.cancel_hs, b.cancel_hs)) return false;
  if (!__eq_Vault(a.crash_hs, b.crash_hs)) return false;
  if (!__eq_Vault(a.forward_cancel, b.forward_cancel)) return false;
  if (!__eq_Vault(a.forward_crash, b.forward_crash)) return false;
  if (!__eq_Vault(a.heard, b.heard)) return false;
  if (!__eq_Vault(a.drain_hs, b.drain_hs)) return false;
  if (!__eq_Pid(a.ep, b.ep)) return false;
  if (!__eq_List(a.links, b.links)) return false;
  if (a.on_close !== b.on_close) return false;
  return true;
}

function __eq_SessionNode__HostWatch_State(a, b) {
  if (a.n !== b.n) return false;
  return true;
}

function __eq_SessionNode__HostWatch_Msg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Watch": {
      if (!__eq_Party(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_SessionNode__HostWatch_Actor(a, b) {
  if (a.$d_dispatch !== b.$d_dispatch) return false;
  if (a.$e_alive !== b.$e_alive) return false;
  if (a.n !== b.n) return false;
  return true;
}

function __eq_SessionNode__Endpoint_State(a, b) {
  if (a.ended !== b.ended) return false;
  if (!__eq_List(a.failed, b.failed)) return false;
  if (a.links !== b.links) return false;
  if (a.n !== b.n) return false;
  if (!__eq_List(a.waiters, b.waiters)) return false;
  return true;
}

function __eq_SessionNode__Endpoint_Msg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Deliver": {
      if (!__eq_Party(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_Bytes(a._3, b._3)) return false;
      return true;
    }
    case "AwaitOutcome": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Expect": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LinkEnded": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Drain": {
      if (!__eq_Party(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "PeerGone": {
      if (!__eq_Party(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "HostDown": {
      if (!__eq_Party(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "ReleaseEpoch": {
      return true;
    }
    case "Leave": {
      if (!__eq_Party(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "Early": {
      if (!__eq_Vault(a._0, b._0)) return false;
      if (!__eq_Party(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_Bytes(a._3, b._3)) return false;
      return true;
    }
    case "Ready": {
      if (!__eq_Party(a._0, b._0)) return false;
      return true;
    }
    case "DeliverDraining": {
      if (!__eq_Party(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_Bytes(a._3, b._3)) return false;
      return true;
    }
    case "Returned": {
      if (!__eq_Party(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Bytes(a._2, b._2)) return false;
      return true;
    }
  }
  return true;
}

function __eq_SessionNode__Endpoint_Actor(a, b) {
  if (a.$d_dispatch !== b.$d_dispatch) return false;
  if (a.$e_alive !== b.$e_alive) return false;
  if (a.ended !== b.ended) return false;
  if (!__eq_List(a.failed, b.failed)) return false;
  if (a.links !== b.links) return false;
  if (a.n !== b.n) return false;
  if (!__eq_List(a.waiters, b.waiters)) return false;
  return true;
}

function __eq_SessionNode$EndpointReq(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DeliverReq": {
      return true;
    }
    case "OutcomeReq": {
      return true;
    }
  }
  return true;
}

function __eq_SessionNode$Addr(a, b) {
  if (a.role !== b.role) return false;
  if (a.host !== b.host) return false;
  if (a.port !== b.port) return false;
  return true;
}

function __eq_SessionNode$Addrs(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "List": {
      if (!__eq_Addr(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_SessionNode$RunError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Cancelled": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Protocol": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "HostGone": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Left": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Listen": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Accept": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Connect": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "NoOffer": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "AlreadyOffered": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Unauthorized": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_SessionNode$OfferCount(a, b) {
  if (a.active !== b.active) return false;
  return true;
}

function __eq_SessionNode$Offer(a, b) {
  if (!__eq_Cap(a.node, b.node)) return false;
  if (a.proto !== b.proto) return false;
  if (a.fingerprint !== b.fingerprint) return false;
  if (!__eq_List(a.roles, b.roles)) return false;
  if (!__eq_List(a.compat, b.compat)) return false;
  if (a.my_role !== b.my_role) return false;
  if (a.capacity !== b.capacity) return false;
  if (a.name !== b.name) return false;
  if (a.id !== b.id) return false;
  if (!__eq_Vault(a.flags, b.flags)) return false;
  if (!__eq_Vault(a.strs, b.strs)) return false;
  if (a.start !== b.start) return false;
  if (!__eq_Pid(a.worker, b.worker)) return false;
  return true;
}

function __eq_SessionNode__OfferActor_State(a, b) {
  if (a.active !== b.active) return false;
  return true;
}

function __eq_SessionNode__OfferActor_Msg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Invite": {
      if (!__eq_Offer(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_List(a._3, b._3)) return false;
      if (!__eq_GlobalPid$Pid(a._4, b._4)) return false;
      if (a._5 !== b._5) return false;
      if (a._6 !== b._6) return false;
      return true;
    }
    case "Withdraw": {
      if (!__eq_Offer(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Ended": {
      if (!__eq_Offer(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Close": {
      if (!__eq_Offer(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_SessionNode__OfferActor_Actor(a, b) {
  if (a.$d_dispatch !== b.$d_dispatch) return false;
  if (a.$e_alive !== b.$e_alive) return false;
  if (a.active !== b.active) return false;
  return true;
}

function __eq_SessionNode__ApInbox_State(a, b) {
  if (a.n !== b.n) return false;
  return true;
}

function __eq_SessionNode__ApInbox_Msg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Nop": {
      return true;
    }
  }
  return true;
}

function __eq_SessionNode__ApInbox_Actor(a, b) {
  if (a.$d_dispatch !== b.$d_dispatch) return false;
  if (a.$e_alive !== b.$e_alive) return false;
  if (a.n !== b.n) return false;
  return true;
}

function __eq_SessionNode$ApWait(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Answered": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "OfferGone": {
      return true;
    }
    case "NoAnswer": {
      return true;
    }
  }
  return true;
}

function __eq_SessionNode$ApMix(a, b) {
  if (a.fp !== b.fp) return false;
  if (!__eq_List(a.rows, b.rows)) return false;
  if (a.me !== b.me) return false;
  if (a.other !== b.other) return false;
  if (a.older !== b.older) return false;
  if (!__eq_List(a.filled, b.filled)) return false;
  return true;
}

function __eq_Topology$TopoPlacement(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PlaceEverywhere": {
      return true;
    }
    case "PlaceOn": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "PlaceCount": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "PlaceCountOn": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "PlaceNowhere": {
      return true;
    }
  }
  return true;
}

function __eq_Topology$TopoOpened(a, b) {
  if (!__eq_SessionNode$Offer(a.ap, b.ap)) return false;
  if (a.alive !== b.alive) return false;
  if (a.capacity !== b.capacity) return false;
  if (a.stop !== b.stop) return false;
  return true;
}

function __eq_Topology$TopoRole(a, b) {
  if (a.name !== b.name) return false;
  if (!__eq_TopoPlacement(a.place, b.place)) return false;
  if (a.capacity !== b.capacity) return false;
  if (a.pinned !== b.pinned) return false;
  if (a.open !== b.open) return false;
  return true;
}

function __eq_Topology$TopoAnchorState(a, b) {
  if (a.topology_anchor_marks !== b.topology_anchor_marks) return false;
  return true;
}

function __eq_Topology__Anchor_State(a, b) {
  if (a.topology_anchor_marks !== b.topology_anchor_marks) return false;
  return true;
}

function __eq_Topology__Anchor_Msg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Nop": {
      return true;
    }
    case "Respawn": {
      if (!__eq_Cap(a._0, b._0)) return false;
      if (!__eq_TopoState(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Topology__Anchor_Actor(a, b) {
  if (a.$d_dispatch !== b.$d_dispatch) return false;
  if (a.$e_alive !== b.$e_alive) return false;
  if (a.topology_anchor_marks !== b.topology_anchor_marks) return false;
  return true;
}

function __eq_Topology$TopoState(a, b) {
  if (!__eq_Vault(a.meta, b.meta)) return false;
  if (!__eq_Vault(a.strs, b.strs)) return false;
  if (!__eq_Vault(a.offers, b.offers)) return false;
  if (!__eq_Vault(a.draining, b.draining)) return false;
  if (!__eq_Vault(a.roles, b.roles)) return false;
  if (!__eq_Vault(a.anchor, b.anchor)) return false;
  return true;
}

function __eq_Topology$TopoDesired(a, b) {
  if (a.d_name !== b.d_name) return false;
  if (!__eq_TopoPlacement(a.d_place, b.d_place)) return false;
  if (a.d_capacity !== b.d_capacity) return false;
  return true;
}

function __eq_Control$CtlHosts(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HostsCanary": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "HostsRest": {
      return true;
    }
    case "HostsAll": {
      return true;
    }
  }
  return true;
}

function __eq_Control$CtlAction(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DoActivate": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "DoTopology": {
      return true;
    }
    case "DoDrain": {
      return true;
    }
    case "DoCerts": {
      return true;
    }
  }
  return true;
}

function __eq_Control$CtlGate(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "GateNone": {
      return true;
    }
    case "GateHealthy": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Control$CtlStep(a, b) {
  if (a.id !== b.id) return false;
  if (!__eq_List(a.pools, b.pools)) return false;
  if (!__eq_CtlHosts(a.hosts, b.hosts)) return false;
  if (!__eq_CtlAction(a.action, b.action)) return false;
  if (!__eq_CtlGate(a.gate, b.gate)) return false;
  if (a.batch !== b.batch) return false;
  return true;
}

function __eq_Control$CtlBuild(a, b) {
  if (a.name !== b.name) return false;
  if (a.base !== b.base) return false;
  if (a.manifest !== b.manifest) return false;
  return true;
}

function __eq_Control$CtlDrain(a, b) {
  if (a.epoch !== b.epoch) return false;
  if (a.soft_ms !== b.soft_ms) return false;
  if (a.hard_ms !== b.hard_ms) return false;
  return true;
}

function __eq_Control$CtlLine(a, b) {
  if (a.step !== b.step) return false;
  if (a.text !== b.text) return false;
  return true;
}

function __eq_Control$CtlCert(a, b) {
  if (a.node !== b.node) return false;
  if (a.cert !== b.cert) return false;
  return true;
}

function __eq_Control$CtlRelease(a, b) {
  if (a.seq !== b.seq) return false;
  if (a.parent !== b.parent) return false;
  if (a.env !== b.env) return false;
  if (a.topology !== b.topology) return false;
  if (!__eq_List(a.builds, b.builds)) return false;
  if (!__eq_List(a.steps, b.steps)) return false;
  if (!__eq_List(a.lines, b.lines)) return false;
  if (!__eq_List(a.certs, b.certs)) return false;
  if (!__eq_List(a.revokes, b.revokes)) return false;
  if (!__eq_Option(a.drain, b.drain)) return false;
  if (a.signature !== b.signature) return false;
  return true;
}

function __eq_Control$CtlMember(a, b) {
  if (a.node !== b.node) return false;
  if (!__eq_List(a.pools, b.pools)) return false;
  return true;
}

function __eq_Control$CtlVersion(a, b) {
  if (a.build !== b.build) return false;
  if (a.manifest !== b.manifest) return false;
  return true;
}

function __eq_Control$CtlFailure(a, b) {
  if (a.seq !== b.seq) return false;
  if (a.step !== b.step) return false;
  if (a.why !== b.why) return false;
  return true;
}

function __eq_Control$AgentReport(a, b) {
  if (a.node !== b.node) return false;
  if (a.seq !== b.seq) return false;
  if (a.versions !== b.versions) return false;
  if (a.topology !== b.topology) return false;
  if (a.drained !== b.drained) return false;
  if (a.healthy !== b.healthy) return false;
  if (a.failed_seq !== b.failed_seq) return false;
  if (a.failed_step !== b.failed_step) return false;
  if (a.failed_why !== b.failed_why) return false;
  if (a.detail !== b.detail) return false;
  if (a.pools !== b.pools) return false;
  if (a.certs !== b.certs) return false;
  return true;
}

function __eq_Control$StepOrder(a, b) {
  if (a.seq !== b.seq) return false;
  if (a.release !== b.release) return false;
  if (a.step !== b.step) return false;
  if (a.node !== b.node) return false;
  if (a.action !== b.action) return false;
  if (a.want !== b.want) return false;
  if (a.artifacts !== b.artifacts) return false;
  if (a.lines !== b.lines) return false;
  return true;
}

function __eq_Control$StepResult(a, b) {
  if (a.seq !== b.seq) return false;
  if (a.step !== b.step) return false;
  if (a.node !== b.node) return false;
  if (a.ok !== b.ok) return false;
  if (a.detail !== b.detail) return false;
  return true;
}

function __eq_Control$CtlObs(a, b) {
  if (!__eq_AgentReport(a.report, b.report)) return false;
  if (!__eq_Option(a.healthy_since, b.healthy_since)) return false;
  return true;
}

function __eq_Control$CtlDecision(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "RolloutApply": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "RolloutWait": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "RolloutHalted": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "RolloutComplete": {
      return true;
    }
    case "RolloutBehind": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Control$CtlLeader(a, b) {
  if (!__eq_Option(a.release, b.release)) return false;
  if (!__eq_List(a.obs, b.obs)) return false;
  if (!__eq_List(a.inflight, b.inflight)) return false;
  if (!__eq_Option(a.halted, b.halted)) return false;
  return true;
}

function __eq_Control$AgentOps(a, b) {
  if (a.report !== b.report) return false;
  if (a.has !== b.has) return false;
  if (a.request !== b.request) return false;
  return true;
}

function __eq_Control$CertOps(a, b) {
  if (a.name !== b.name) return false;
  if (!__eq_Bytes(a.deploy_key, b.deploy_key)) return false;
  if (a.serial !== b.serial) return false;
  if (a.replace !== b.replace) return false;
  if (a.revoke !== b.revoke) return false;
  if (a.floor !== b.floor) return false;
  return true;
}

function __eq_Control$CtlChunk(a, b) {
  if (a.offset !== b.offset) return false;
  if (a.data !== b.data) return false;
  if (a.last !== b.last) return false;
  return true;
}

function __eq_Control$CtlNext(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NextOrder": {
      if (!__eq_StepOrder(a._0, b._0)) return false;
      return true;
    }
    case "NextPoll": {
      return true;
    }
    case "NextBye": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Control$ControlOps(a, b) {
  if (a.report !== b.report) return false;
  if (a.stepped !== b.stepped) return false;
  if (a.next !== b.next) return false;
  if (a.head !== b.head) return false;
  return true;
}

function __eq_Js$Dom$Node(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
  }
  return true;
}

function __eq_Js$Dom$Event(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
  }
  return true;
}

function __eq_Js$Canvas$Context(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
  }
  return true;
}

function __eq_Js$Canvas$Image(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
  }
  return true;
}

function __eq_Js$Audio$Ctx(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
  }
  return true;
}

function __eq_Arcade$Numerics$Numerics(a, b) {
  if (a.pi !== b.pi) return false;
  if (a.tau !== b.tau) return false;
  if (a.unit53 !== b.unit53) return false;
  if (a.floor_u1 !== b.floor_u1) return false;
  if (a.infinity !== b.infinity) return false;
  if (a.nan !== b.nan) return false;
  return true;
}

function __eq_Arcade$U64$U64(a, b) {
  if (a.hi !== b.hi) return false;
  if (a.lo !== b.lo) return false;
  return true;
}

function __eq_Arcade$Rng$Rng(a, b) {
  if (!__eq_U64(a.word, b.word)) return false;
  return true;
}

function __eq_Arcade$Vec2$Vec2(a, b) {
  if (a.x !== b.x) return false;
  if (a.y !== b.y) return false;
  return true;
}

function __eq_Arcade$Vec3$Vec3(a, b) {
  if (a.x !== b.x) return false;
  if (a.y !== b.y) return false;
  if (a.z !== b.z) return false;
  return true;
}

function __eq_Spin$Draw$Op(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Clear": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Disc": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
    case "Ring": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      return true;
    }
    case "Line": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (a._5 !== b._5) return false;
      return true;
    }
    case "Poly": {
      if (!__eq_List(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Box": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      return true;
    }
    case "Glow": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
    case "Label": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      return true;
    }
    case "ClipBox": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
    case "Unclip": {
      return true;
    }
    case "Fade": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Spin$Game$Mode(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Attract": {
      return true;
    }
    case "Playing": {
      return true;
    }
    case "Busted": {
      return true;
    }
  }
  return true;
}

function __eq_Spin$Game$Input(a, b) {
  if (a.left !== b.left) return false;
  if (a.right !== b.right) return false;
  if (a.launch !== b.launch) return false;
  if (a.start !== b.start) return false;
  return true;
}

function __eq_Spin$Game$Cue(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "CueFlip": {
      return true;
    }
    case "CueBumper": {
      return true;
    }
    case "CueSling": {
      return true;
    }
    case "CueLoad": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueLane": {
      return true;
    }
    case "CueSpinner": {
      return true;
    }
    case "CueReelStop": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueReelStart": {
      return true;
    }
    case "CueWin": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueJackpot": {
      return true;
    }
    case "CueMiss": {
      return true;
    }
    case "CueNudge": {
      return true;
    }
    case "CueDrain": {
      return true;
    }
    case "CueSaved": {
      return true;
    }
    case "CueLaunch": {
      return true;
    }
    case "CueBurn": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueBust": {
      return true;
    }
    case "CueStart": {
      return true;
    }
    case "CueThud": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueStore": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueStage": {
      return true;
    }
    case "CueBuff": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Spin$Game$Buff(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SaveBuff": {
      return true;
    }
    case "FreezeBuff": {
      return true;
    }
    case "SlowBuff": {
      return true;
    }
    case "DoubleBuff": {
      return true;
    }
  }
  return true;
}

function __eq_Spin$Game$Spark(a, b) {
  if (!__eq_Vec2(a.pos, b.pos)) return false;
  if (!__eq_Vec2(a.vel, b.vel)) return false;
  if (a.life !== b.life) return false;
  if (a.colour !== b.colour) return false;
  return true;
}

function __eq_Spin$Game$Pop(a, b) {
  if (a.text !== b.text) return false;
  if (!__eq_Vec2(a.pos, b.pos)) return false;
  if (a.life !== b.life) return false;
  if (a.colour !== b.colour) return false;
  return true;
}

function __eq_Spin$Game$Banner(a, b) {
  if (a.text !== b.text) return false;
  if (a.sub !== b.sub) return false;
  if (a.left !== b.left) return false;
  if (a.hot !== b.hot) return false;
  return true;
}

function __eq_Spin$Game$Model(a, b) {
  if (!__eq_Arcade$Numerics$Numerics(a.num, b.num)) return false;
  if (!__eq_Spin$Table$Layout(a.table, b.table)) return false;
  if (!__eq_Mode(a.mode, b.mode)) return false;
  if (!__eq_List(a.balls, b.balls)) return false;
  if (!__eq_Spin$Physics$Flipper(a.left, b.left)) return false;
  if (!__eq_Spin$Physics$Flipper(a.right, b.right)) return false;
  if (!__eq_Spin$Reels$Bank(a.bank, b.bank)) return false;
  if (!__eq_Arcade$Rng$Rng(a.rng, b.rng)) return false;
  if (a.credits !== b.credits) return false;
  if (a.paid !== b.paid) return false;
  if (a.best !== b.best) return false;
  if (a.burn_clock !== b.burn_clock) return false;
  if (a.alive !== b.alive) return false;
  if (a.pull !== b.pull) return false;
  if (a.save_left !== b.save_left) return false;
  if (a.owed_balls !== b.owed_balls) return false;
  if (a.carry !== b.carry) return false;
  if (!__eq_Banner(a.banner, b.banner)) return false;
  if (!__eq_List(a.lights, b.lights)) return false;
  if (a.spinner_turn !== b.spinner_turn) return false;
  if (a.spinner_rate !== b.spinner_rate) return false;
  if (!__eq_Input(a.last, b.last)) return false;
  if (a.clock !== b.clock) return false;
  if (a.stage !== b.stage) return false;
  if (!__eq_Spin$Style$Style(a.style, b.style)) return false;
  if (!__eq_List(a.buffs, b.buffs)) return false;
  if (!__eq_List(a.wins_at, b.wins_at)) return false;
  if (!__eq_List(a.sparks, b.sparks)) return false;
  if (!__eq_List(a.pops, b.pops)) return false;
  if (a.flash !== b.flash) return false;
  if (a.flash_tint !== b.flash_tint) return false;
  if (a.win_glow !== b.win_glow) return false;
  if (a.start_stage !== b.start_stage) return false;
  return true;
}

function __eq_Spin$Physics$Ball(a, b) {
  if (!__eq_Vec2(a.pos, b.pos)) return false;
  if (!__eq_Vec2(a.vel, b.vel)) return false;
  return true;
}

function __eq_Spin$Physics$Flipper(a, b) {
  if (a.angle !== b.angle) return false;
  if (a.omega !== b.omega) return false;
  return true;
}

function __eq_Spin$Physics$Hit(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Touched": {
      if (!__eq_Spin$Table$Feature(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Vec2(a._2, b._2)) return false;
      return true;
    }
    case "Flipped": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Spin$Physics$World(a, b) {
  if (a.bounce !== b.bounce) return false;
  if (a.clock !== b.clock) return false;
  if (!__eq_Arcade$Numerics$Numerics(a.num, b.num)) return false;
  return true;
}

function __eq_Spin$Reels$Symbol(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Blank": {
      return true;
    }
    case "Cherry": {
      return true;
    }
    case "Lemon": {
      return true;
    }
    case "Bell": {
      return true;
    }
    case "Bars": {
      return true;
    }
    case "Seven": {
      return true;
    }
  }
  return true;
}

function __eq_Spin$Reels$Phase(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Idle": {
      return true;
    }
    case "Spinning": {
      return true;
    }
    case "Nudging": {
      return true;
    }
    case "Building": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Spin$Reels$Reel(a, b) {
  if (!__eq_List(a.stops, b.stops)) return false;
  if (a.pos !== b.pos) return false;
  if (a.from !== b.from) return false;
  if (a.travel !== b.travel) return false;
  if (a.elapsed !== b.elapsed) return false;
  if (a.duration !== b.duration) return false;
  if (a.held !== b.held) return false;
  if (a.fresh !== b.fresh) return false;
  if (a.glow !== b.glow) return false;
  return true;
}

function __eq_Spin$Reels$Bank(a, b) {
  if (!__eq_List(a.reels, b.reels)) return false;
  if (a.armed !== b.armed) return false;
  if (a.banked !== b.banked) return false;
  if (!__eq_Phase(a.phase, b.phase)) return false;
  if (a.nudge_left !== b.nudge_left) return false;
  if (a.boost !== b.boost) return false;
  if (a.last_line !== b.last_line) return false;
  if (a.last_pay !== b.last_pay) return false;
  return true;
}

function __eq_Spin$Reels$ReelEvent(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Loaded": {
      if (!__eq_Symbol(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Banked": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Started": {
      return true;
    }
    case "Landed": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Paid": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Missed": {
      return true;
    }
    case "Nudged": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Held": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Doubled": {
      return true;
    }
  }
  return true;
}

function __eq_Spin$Style$Style(a, b) {
  if (a.name !== b.name) return false;
  if (a.sub !== b.sub) return false;
  if (a.gravity !== b.gravity) return false;
  if (a.bounce !== b.bounce) return false;
  if (a.drag !== b.drag) return false;
  if (a.wind !== b.wind) return false;
  if (a.magnet !== b.magnet) return false;
  if (a.tint !== b.tint) return false;
  return true;
}

function __eq_Spin$Table$Feature(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Plain": {
      return true;
    }
    case "Loader": {
      if (!__eq_Spin$Reels$Symbol(a._0, b._0)) return false;
      return true;
    }
    case "Bumper": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Sling": {
      return true;
    }
    case "Spinner": {
      return true;
    }
    case "HoldLane": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Spin$Table$Part(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Wall": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (!__eq_Vec2(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "Peg": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "Kicker": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Feature(a._2, b._2)) return false;
      return true;
    }
    case "Face": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (!__eq_Vec2(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_Feature(a._3, b._3)) return false;
      return true;
    }
    case "Gate": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (!__eq_Vec2(a._1, b._1)) return false;
      return true;
    }
    case "Sensor": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Feature(a._2, b._2)) return false;
      return true;
    }
    case "Tripwire": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (!__eq_Vec2(a._1, b._1)) return false;
      if (!__eq_Feature(a._2, b._2)) return false;
      return true;
    }
    case "Mover": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (!__eq_Vec2(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (!__eq_Feature(a._4, b._4)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Spin$Table$FlipperSpec(a, b) {
  if (!__eq_Vec2(a.pivot, b.pivot)) return false;
  if (a.length !== b.length) return false;
  if (a.radius !== b.radius) return false;
  if (a.rest !== b.rest) return false;
  if (a.up !== b.up) return false;
  return true;
}

function __eq_Spin$Table$Layout(a, b) {
  if (!__eq_List(a.parts, b.parts)) return false;
  if (!__eq_FlipperSpec(a.left, b.left)) return false;
  if (!__eq_FlipperSpec(a.right, b.right)) return false;
  if (a.ball_radius !== b.ball_radius) return false;
  if (!__eq_Vec2(a.plunger_rest, b.plunger_rest)) return false;
  if (a.drain_y !== b.drain_y) return false;
  if (a.width !== b.width) return false;
  if (a.height !== b.height) return false;
  if (a.reel_window !== b.reel_window) return false;
  return true;
}

function __eq_ShellState(a, b) {
  if (!__eq_Spin$Game$Model(a.model, b.model)) return false;
  if (!__eq_Js$Canvas$Context(a.ctx, b.ctx)) return false;
  if (!__eq_Js$Dom$Node(a.canvas, b.canvas)) return false;
  if (a.last_t !== b.last_t) return false;
  if (a.flips !== b.flips) return false;
  return true;
}

function Arcade$Numerics$float_of_text(text) {
  {
    const $t45815 = march_string_to_float(text);
    switch ($t45815.$) {
      case "Some": {
        const $f45816 = $t45815._0;
        {
          const x = $f45816;
          return x;
        }
        break;
      }
      case "None": {
        undefined;
        return (() => { throw new Error("panic"); })();
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
  }
}
const Arcade$Numerics$float_of_text$clo = { _0: ($_, text) => Arcade$Numerics$float_of_text(text) };

function Arcade$U64$add(a, b) {
  {
    let low;
    {
      const $t45892 = a.lo;
      {
        const $t45893 = b.lo;
        low = (($t45892 + $t45893) < 4611686018427387904 && ($t45892 + $t45893) >= -4611686018427387904 ? ($t45892 + $t45893) : march_int_ovf(($t45892 + $t45893), 0));
      }
    }
    {
      let $t45900;
      {
        let $t45899;
        {
          let $t45896;
          {
            const $t45894 = a.hi;
            {
              const $t45895 = b.hi;
              $t45896 = (($t45894 + $t45895) < 4611686018427387904 && ($t45894 + $t45895) >= -4611686018427387904 ? ($t45894 + $t45895) : march_int_ovf(($t45894 + $t45895), 0));
            }
          }
          {
            let $t45898;
            {
              const $t45897 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
              $t45898 = ((low - low % $t45897) / $t45897);
            }
            $t45899 = (($t45896 + $t45898) < 4611686018427387904 && ($t45896 + $t45898) >= -4611686018427387904 ? ($t45896 + $t45898) : march_int_ovf(($t45896 + $t45898), 0));
          }
        }
        {
          let $t45825_i5222;
          {
            const $t45824_i5221 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
            $t45825_i5222 = (($t45824_i5221 - 1) < 4611686018427387904 && ($t45824_i5221 - 1) >= -4611686018427387904 ? ($t45824_i5221 - 1) : march_int_ovf(($t45824_i5221 - 1), 1));
          }
          $t45900 = (($t45899 | 0) === $t45899 && ($t45825_i5222 | 0) === $t45825_i5222 ? ($t45899 & $t45825_i5222) : march_int_and($t45899, $t45825_i5222));
        }
      }
      {
        let $t45901;
        {
          let $t45825_i5219;
          {
            const $t45824_i5218 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
            $t45825_i5219 = (($t45824_i5218 - 1) < 4611686018427387904 && ($t45824_i5218 - 1) >= -4611686018427387904 ? ($t45824_i5218 - 1) : march_int_ovf(($t45824_i5218 - 1), 1));
          }
          $t45901 = ((low | 0) === low && ($t45825_i5219 | 0) === $t45825_i5219 ? (low & $t45825_i5219) : march_int_and(low, $t45825_i5219));
        }
        return ({ hi: $t45900, lo: $t45901 });
      }
    }
  }
}
const Arcade$U64$add$clo = { _0: ($_, a, b) => Arcade$U64$add(a, b) };

function Arcade$U64$xor(a, b) {
  {
    let $t45904;
    {
      const $t45902 = a.hi;
      {
        const $t45903 = b.hi;
        $t45904 = (($t45902 | 0) === $t45902 && ($t45903 | 0) === $t45903 ? ($t45902 ^ $t45903) : march_int_xor($t45902, $t45903));
      }
    }
    {
      let $t45907;
      {
        const $t45905 = a.lo;
        {
          const $t45906 = b.lo;
          $t45907 = (($t45905 | 0) === $t45905 && ($t45906 | 0) === $t45906 ? ($t45905 ^ $t45906) : march_int_xor($t45905, $t45906));
        }
      }
      return ({ hi: $t45904, lo: $t45907 });
    }
  }
}
const Arcade$U64$xor$clo = { _0: ($_, a, b) => Arcade$U64$xor(a, b) };

function Arcade$U64$shr(a, k) {
  {
    let carried;
    {
      let $t45911;
      {
        const $t45908 = a.hi;
        {
          let $t45910;
          {
            const $t45909 = march_int_shl(1, k);
            $t45910 = (($t45909 - 1) < 4611686018427387904 && ($t45909 - 1) >= -4611686018427387904 ? ($t45909 - 1) : march_int_ovf(($t45909 - 1), 1));
          }
          $t45911 = (($t45908 | 0) === $t45908 && ($t45910 | 0) === $t45910 ? ($t45908 & $t45910) : march_int_and($t45908, $t45910));
        }
      }
      {
        let $t45913;
        {
          const $t45912 = ((32 - k) < 4611686018427387904 && (32 - k) >= -4611686018427387904 ? (32 - k) : march_int_ovf((32 - k), 1));
          $t45913 = march_int_shl(1, $t45912);
        }
        carried = (($t45911 * $t45913) < 4611686018427387904 && ($t45911 * $t45913) >= -4611686018427387904 ? ($t45911 * $t45913) : march_int_ovf(($t45911 * $t45913), 2));
      }
    }
    {
      let $t45915;
      {
        const $t45914 = a.hi;
        $t45915 = (($t45914 | 0) === $t45914 && k >= 0 && k < 32 ? ($t45914 >> k) : march_int_shr($t45914, k));
      }
      {
        let $t45918;
        {
          let $t45917;
          {
            const $t45916 = a.lo;
            $t45917 = (($t45916 | 0) === $t45916 && k >= 0 && k < 32 ? ($t45916 >> k) : march_int_shr($t45916, k));
          }
          $t45918 = ((carried + $t45917) < 4611686018427387904 && (carried + $t45917) >= -4611686018427387904 ? (carried + $t45917) : march_int_ovf((carried + $t45917), 0));
        }
        return ({ hi: $t45915, lo: $t45918 });
      }
    }
  }
}
const Arcade$U64$shr$clo = { _0: ($_, a, k) => Arcade$U64$shr(a, k) };

function Arcade$U64$mul(a, b) {
  {
    let a0;
    {
      const $t45931 = a.lo;
      a0 = (($t45931 | 0) === $t45931 && (65535 | 0) === 65535 ? ($t45931 & 65535) : march_int_and($t45931, 65535));
    }
    {
      let a1;
      {
        const $t45932 = a.lo;
        a1 = (($t45932 | 0) === $t45932 && 16 >= 0 && 16 < 32 ? ($t45932 >> 16) : march_int_shr($t45932, 16));
      }
      {
        let b0;
        {
          const $t45933 = b.lo;
          b0 = (($t45933 | 0) === $t45933 && (65535 | 0) === 65535 ? ($t45933 & 65535) : march_int_and($t45933, 65535));
        }
        {
          let b1;
          {
            const $t45934 = b.lo;
            b1 = (($t45934 | 0) === $t45934 && 16 >= 0 && 16 < 32 ? ($t45934 >> 16) : march_int_shr($t45934, 16));
          }
          {
            const p00 = ((a0 * b0) < 4611686018427387904 && (a0 * b0) >= -4611686018427387904 ? (a0 * b0) : march_int_ovf((a0 * b0), 2));
            {
              let mid;
              {
                let $t45937;
                {
                  const $t45935 = ((a0 * b1) < 4611686018427387904 && (a0 * b1) >= -4611686018427387904 ? (a0 * b1) : march_int_ovf((a0 * b1), 2));
                  {
                    const $t45936 = ((a1 * b0) < 4611686018427387904 && (a1 * b0) >= -4611686018427387904 ? (a1 * b0) : march_int_ovf((a1 * b0), 2));
                    $t45937 = (($t45935 + $t45936) < 4611686018427387904 && ($t45935 + $t45936) >= -4611686018427387904 ? ($t45935 + $t45936) : march_int_ovf(($t45935 + $t45936), 0));
                  }
                }
                {
                  const $t45938 = ((p00 | 0) === p00 && 16 >= 0 && 16 < 32 ? (p00 >> 16) : march_int_shr(p00, 16));
                  mid = (($t45937 + $t45938) < 4611686018427387904 && ($t45937 + $t45938) >= -4611686018427387904 ? ($t45937 + $t45938) : march_int_ovf(($t45937 + $t45938), 0));
                }
              }
              {
                let low;
                {
                  const $t45939 = ((p00 | 0) === p00 && (65535 | 0) === 65535 ? (p00 & 65535) : march_int_and(p00, 65535));
                  {
                    let $t45941;
                    {
                      const $t45940 = ((mid | 0) === mid && (65535 | 0) === 65535 ? (mid & 65535) : march_int_and(mid, 65535));
                      $t45941 = (($t45940 * 65536) < 4611686018427387904 && ($t45940 * 65536) >= -4611686018427387904 ? ($t45940 * 65536) : march_int_ovf(($t45940 * 65536), 2));
                    }
                    low = (($t45939 + $t45941) < 4611686018427387904 && ($t45939 + $t45941) >= -4611686018427387904 ? ($t45939 + $t45941) : march_int_ovf(($t45939 + $t45941), 0));
                  }
                }
                {
                  let carry;
                  {
                    const $t45942 = ((a1 * b1) < 4611686018427387904 && (a1 * b1) >= -4611686018427387904 ? (a1 * b1) : march_int_ovf((a1 * b1), 2));
                    {
                      const $t45943 = ((mid | 0) === mid && 16 >= 0 && 16 < 32 ? (mid >> 16) : march_int_shr(mid, 16));
                      carry = (($t45942 + $t45943) < 4611686018427387904 && ($t45942 + $t45943) >= -4611686018427387904 ? ($t45942 + $t45943) : march_int_ovf(($t45942 + $t45943), 0));
                    }
                  }
                  {
                    let $t45952;
                    {
                      let $t45951;
                      {
                        let $t45947;
                        {
                          let $t45946;
                          {
                            const $t45944 = a.hi;
                            {
                              const $t45945 = b.lo;
                              {
                                let cross_i5260;
                                {
                                  let $t45925_i5259;
                                  {
                                    let $t45921_i5255;
                                    {
                                      const $t45919_i5253 = (($t45944 | 0) === $t45944 && 16 >= 0 && 16 < 32 ? ($t45944 >> 16) : march_int_shr($t45944, 16));
                                      {
                                        const $t45920_i5254 = (($t45945 | 0) === $t45945 && (65535 | 0) === 65535 ? ($t45945 & 65535) : march_int_and($t45945, 65535));
                                        $t45921_i5255 = (($t45919_i5253 * $t45920_i5254) < 4611686018427387904 && ($t45919_i5253 * $t45920_i5254) >= -4611686018427387904 ? ($t45919_i5253 * $t45920_i5254) : march_int_ovf(($t45919_i5253 * $t45920_i5254), 2));
                                      }
                                    }
                                    {
                                      let $t45924_i5258;
                                      {
                                        const $t45922_i5256 = (($t45944 | 0) === $t45944 && (65535 | 0) === 65535 ? ($t45944 & 65535) : march_int_and($t45944, 65535));
                                        {
                                          const $t45923_i5257 = (($t45945 | 0) === $t45945 && 16 >= 0 && 16 < 32 ? ($t45945 >> 16) : march_int_shr($t45945, 16));
                                          $t45924_i5258 = (($t45922_i5256 * $t45923_i5257) < 4611686018427387904 && ($t45922_i5256 * $t45923_i5257) >= -4611686018427387904 ? ($t45922_i5256 * $t45923_i5257) : march_int_ovf(($t45922_i5256 * $t45923_i5257), 2));
                                        }
                                      }
                                      $t45925_i5259 = (($t45921_i5255 + $t45924_i5258) < 4611686018427387904 && ($t45921_i5255 + $t45924_i5258) >= -4611686018427387904 ? ($t45921_i5255 + $t45924_i5258) : march_int_ovf(($t45921_i5255 + $t45924_i5258), 0));
                                    }
                                  }
                                  cross_i5260 = (($t45925_i5259 | 0) === $t45925_i5259 && (65535 | 0) === 65535 ? ($t45925_i5259 & 65535) : march_int_and($t45925_i5259, 65535));
                                }
                                {
                                  let $t45930_i5265;
                                  {
                                    let $t45928_i5263;
                                    {
                                      const $t45926_i5261 = (($t45944 | 0) === $t45944 && (65535 | 0) === 65535 ? ($t45944 & 65535) : march_int_and($t45944, 65535));
                                      {
                                        const $t45927_i5262 = (($t45945 | 0) === $t45945 && (65535 | 0) === 65535 ? ($t45945 & 65535) : march_int_and($t45945, 65535));
                                        $t45928_i5263 = (($t45926_i5261 * $t45927_i5262) < 4611686018427387904 && ($t45926_i5261 * $t45927_i5262) >= -4611686018427387904 ? ($t45926_i5261 * $t45927_i5262) : march_int_ovf(($t45926_i5261 * $t45927_i5262), 2));
                                      }
                                    }
                                    {
                                      const $t45929_i5264 = ((cross_i5260 * 65536) < 4611686018427387904 && (cross_i5260 * 65536) >= -4611686018427387904 ? (cross_i5260 * 65536) : march_int_ovf((cross_i5260 * 65536), 2));
                                      $t45930_i5265 = (($t45928_i5263 + $t45929_i5264) < 4611686018427387904 && ($t45928_i5263 + $t45929_i5264) >= -4611686018427387904 ? ($t45928_i5263 + $t45929_i5264) : march_int_ovf(($t45928_i5263 + $t45929_i5264), 0));
                                    }
                                  }
                                  {
                                    let $t45825_i14556;
                                    {
                                      const $t45824_i14555 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                                      $t45825_i14556 = (($t45824_i14555 - 1) < 4611686018427387904 && ($t45824_i14555 - 1) >= -4611686018427387904 ? ($t45824_i14555 - 1) : march_int_ovf(($t45824_i14555 - 1), 1));
                                    }
                                    $t45946 = (($t45930_i5265 | 0) === $t45930_i5265 && ($t45825_i14556 | 0) === $t45825_i14556 ? ($t45930_i5265 & $t45825_i14556) : march_int_and($t45930_i5265, $t45825_i14556));
                                  }
                                }
                              }
                            }
                          }
                          $t45947 = ((carry + $t45946) < 4611686018427387904 && (carry + $t45946) >= -4611686018427387904 ? (carry + $t45946) : march_int_ovf((carry + $t45946), 0));
                        }
                        {
                          let $t45950;
                          {
                            const $t45948 = a.lo;
                            {
                              const $t45949 = b.hi;
                              {
                                let cross_i5245;
                                {
                                  let $t45925_i5244;
                                  {
                                    let $t45921_i5240;
                                    {
                                      const $t45919_i5238 = (($t45948 | 0) === $t45948 && 16 >= 0 && 16 < 32 ? ($t45948 >> 16) : march_int_shr($t45948, 16));
                                      {
                                        const $t45920_i5239 = (($t45949 | 0) === $t45949 && (65535 | 0) === 65535 ? ($t45949 & 65535) : march_int_and($t45949, 65535));
                                        $t45921_i5240 = (($t45919_i5238 * $t45920_i5239) < 4611686018427387904 && ($t45919_i5238 * $t45920_i5239) >= -4611686018427387904 ? ($t45919_i5238 * $t45920_i5239) : march_int_ovf(($t45919_i5238 * $t45920_i5239), 2));
                                      }
                                    }
                                    {
                                      let $t45924_i5243;
                                      {
                                        const $t45922_i5241 = (($t45948 | 0) === $t45948 && (65535 | 0) === 65535 ? ($t45948 & 65535) : march_int_and($t45948, 65535));
                                        {
                                          const $t45923_i5242 = (($t45949 | 0) === $t45949 && 16 >= 0 && 16 < 32 ? ($t45949 >> 16) : march_int_shr($t45949, 16));
                                          $t45924_i5243 = (($t45922_i5241 * $t45923_i5242) < 4611686018427387904 && ($t45922_i5241 * $t45923_i5242) >= -4611686018427387904 ? ($t45922_i5241 * $t45923_i5242) : march_int_ovf(($t45922_i5241 * $t45923_i5242), 2));
                                        }
                                      }
                                      $t45925_i5244 = (($t45921_i5240 + $t45924_i5243) < 4611686018427387904 && ($t45921_i5240 + $t45924_i5243) >= -4611686018427387904 ? ($t45921_i5240 + $t45924_i5243) : march_int_ovf(($t45921_i5240 + $t45924_i5243), 0));
                                    }
                                  }
                                  cross_i5245 = (($t45925_i5244 | 0) === $t45925_i5244 && (65535 | 0) === 65535 ? ($t45925_i5244 & 65535) : march_int_and($t45925_i5244, 65535));
                                }
                                {
                                  let $t45930_i5250;
                                  {
                                    let $t45928_i5248;
                                    {
                                      const $t45926_i5246 = (($t45948 | 0) === $t45948 && (65535 | 0) === 65535 ? ($t45948 & 65535) : march_int_and($t45948, 65535));
                                      {
                                        const $t45927_i5247 = (($t45949 | 0) === $t45949 && (65535 | 0) === 65535 ? ($t45949 & 65535) : march_int_and($t45949, 65535));
                                        $t45928_i5248 = (($t45926_i5246 * $t45927_i5247) < 4611686018427387904 && ($t45926_i5246 * $t45927_i5247) >= -4611686018427387904 ? ($t45926_i5246 * $t45927_i5247) : march_int_ovf(($t45926_i5246 * $t45927_i5247), 2));
                                      }
                                    }
                                    {
                                      const $t45929_i5249 = ((cross_i5245 * 65536) < 4611686018427387904 && (cross_i5245 * 65536) >= -4611686018427387904 ? (cross_i5245 * 65536) : march_int_ovf((cross_i5245 * 65536), 2));
                                      $t45930_i5250 = (($t45928_i5248 + $t45929_i5249) < 4611686018427387904 && ($t45928_i5248 + $t45929_i5249) >= -4611686018427387904 ? ($t45928_i5248 + $t45929_i5249) : march_int_ovf(($t45928_i5248 + $t45929_i5249), 0));
                                    }
                                  }
                                  {
                                    let $t45825_i14546;
                                    {
                                      const $t45824_i14545 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                                      $t45825_i14546 = (($t45824_i14545 - 1) < 4611686018427387904 && ($t45824_i14545 - 1) >= -4611686018427387904 ? ($t45824_i14545 - 1) : march_int_ovf(($t45824_i14545 - 1), 1));
                                    }
                                    $t45950 = (($t45930_i5250 | 0) === $t45930_i5250 && ($t45825_i14546 | 0) === $t45825_i14546 ? ($t45930_i5250 & $t45825_i14546) : march_int_and($t45930_i5250, $t45825_i14546));
                                  }
                                }
                              }
                            }
                          }
                          $t45951 = (($t45947 + $t45950) < 4611686018427387904 && ($t45947 + $t45950) >= -4611686018427387904 ? ($t45947 + $t45950) : march_int_ovf(($t45947 + $t45950), 0));
                        }
                      }
                      {
                        let $t45825_i5235;
                        {
                          const $t45824_i5234 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                          $t45825_i5235 = (($t45824_i5234 - 1) < 4611686018427387904 && ($t45824_i5234 - 1) >= -4611686018427387904 ? ($t45824_i5234 - 1) : march_int_ovf(($t45824_i5234 - 1), 1));
                        }
                        $t45952 = (($t45951 | 0) === $t45951 && ($t45825_i5235 | 0) === $t45825_i5235 ? ($t45951 & $t45825_i5235) : march_int_and($t45951, $t45825_i5235));
                      }
                    }
                    return ({ hi: $t45952, lo: low });
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Arcade$U64$mul$clo = { _0: ($_, a, b) => Arcade$U64$mul(a, b) };

function Arcade$Rng$next(r) {
  {
    let word;
    {
      const $t45953 = r.word;
      {
        let $t45954;
        {
          let $t45832_i5283;
          {
            let $t45825_i14581;
            {
              const $t45824_i14580 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
              $t45825_i14581 = (($t45824_i14580 - 1) < 4611686018427387904 && ($t45824_i14580 - 1) >= -4611686018427387904 ? ($t45824_i14580 - 1) : march_int_ovf(($t45824_i14580 - 1), 1));
            }
            $t45832_i5283 = ((2654435769 | 0) === 2654435769 && ($t45825_i14581 | 0) === $t45825_i14581 ? (2654435769 & $t45825_i14581) : march_int_and(2654435769, $t45825_i14581));
          }
          {
            let $t45833_i5284;
            {
              let $t45825_i14578;
              {
                const $t45824_i14577 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                $t45825_i14578 = (($t45824_i14577 - 1) < 4611686018427387904 && ($t45824_i14577 - 1) >= -4611686018427387904 ? ($t45824_i14577 - 1) : march_int_ovf(($t45824_i14577 - 1), 1));
              }
              $t45833_i5284 = ((2135587861 | 0) === 2135587861 && ($t45825_i14578 | 0) === $t45825_i14578 ? (2135587861 & $t45825_i14578) : march_int_and(2135587861, $t45825_i14578));
            }
            $t45954 = ({ hi: $t45832_i5283, lo: $t45833_i5284 });
          }
        }
        word = Arcade$U64$add($t45953, $t45954);
      }
    }
    {
      let z1;
      {
        let $t45956;
        {
          let $t45955;
          $t45955 = Arcade$U64$shr(word, 30);
          $t45956 = Arcade$U64$xor(word, $t45955);
        }
        {
          let $t45957;
          {
            let $t45832_i5279;
            {
              let $t45825_i14575;
              {
                const $t45824_i14574 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                $t45825_i14575 = (($t45824_i14574 - 1) < 4611686018427387904 && ($t45824_i14574 - 1) >= -4611686018427387904 ? ($t45824_i14574 - 1) : march_int_ovf(($t45824_i14574 - 1), 1));
              }
              $t45832_i5279 = ((3210233709 | 0) === 3210233709 && ($t45825_i14575 | 0) === $t45825_i14575 ? (3210233709 & $t45825_i14575) : march_int_and(3210233709, $t45825_i14575));
            }
            {
              let $t45833_i5280;
              {
                let $t45825_i14572;
                {
                  const $t45824_i14571 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                  $t45825_i14572 = (($t45824_i14571 - 1) < 4611686018427387904 && ($t45824_i14571 - 1) >= -4611686018427387904 ? ($t45824_i14571 - 1) : march_int_ovf(($t45824_i14571 - 1), 1));
                }
                $t45833_i5280 = ((484763065 | 0) === 484763065 && ($t45825_i14572 | 0) === $t45825_i14572 ? (484763065 & $t45825_i14572) : march_int_and(484763065, $t45825_i14572));
              }
              $t45957 = ({ hi: $t45832_i5279, lo: $t45833_i5280 });
            }
          }
          z1 = Arcade$U64$mul($t45956, $t45957);
        }
      }
      {
        let z2;
        {
          let $t45959;
          {
            let $t45958;
            $t45958 = Arcade$U64$shr(z1, 27);
            $t45959 = Arcade$U64$xor(z1, $t45958);
          }
          {
            let $t45960;
            {
              let $t45832_i5275;
              {
                let $t45825_i14569;
                {
                  const $t45824_i14568 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                  $t45825_i14569 = (($t45824_i14568 - 1) < 4611686018427387904 && ($t45824_i14568 - 1) >= -4611686018427387904 ? ($t45824_i14568 - 1) : march_int_ovf(($t45824_i14568 - 1), 1));
                }
                $t45832_i5275 = ((2496678331 | 0) === 2496678331 && ($t45825_i14569 | 0) === $t45825_i14569 ? (2496678331 & $t45825_i14569) : march_int_and(2496678331, $t45825_i14569));
              }
              {
                let $t45833_i5276;
                {
                  let $t45825_i14566;
                  {
                    const $t45824_i14565 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                    $t45825_i14566 = (($t45824_i14565 - 1) < 4611686018427387904 && ($t45824_i14565 - 1) >= -4611686018427387904 ? ($t45824_i14565 - 1) : march_int_ovf(($t45824_i14565 - 1), 1));
                  }
                  $t45833_i5276 = ((321982955 | 0) === 321982955 && ($t45825_i14566 | 0) === $t45825_i14566 ? (321982955 & $t45825_i14566) : march_int_and(321982955, $t45825_i14566));
                }
                $t45960 = ({ hi: $t45832_i5275, lo: $t45833_i5276 });
              }
            }
            z2 = Arcade$U64$mul($t45959, $t45960);
          }
        }
        {
          let $t45962;
          {
            let $t45961;
            $t45961 = Arcade$U64$shr(z2, 31);
            $t45962 = Arcade$U64$xor(z2, $t45961);
          }
          {
            const $t45963 = ({ word: word });
            return { _0: $t45962, _1: $t45963 };
          }
        }
      }
    }
  }
}
const Arcade$Rng$next$clo = { _0: ($_, r) => Arcade$Rng$next(r) };

function Arcade$Rng$divide_word($tco_a0, $tco_a1, $tco_a2, $tco_a3) {
  __tco: for (;;) {
    const r = $tco_a0;
    const word = $tco_a1;
    const position = $tco_a2;
    const n = $tco_a3;
    {
      const $t45978 = (position < 0);
      if ($t45978 === true) {
        return r;
      } else {
        {
          let $t45981;
          {
            let $t45980;
            {
              const $t45979 = ((word | 0) === word && position >= 0 && position < 32 ? (word >> position) : march_int_shr(word, position));
              $t45980 = (($t45979 | 0) === $t45979 && (1 | 0) === 1 ? ($t45979 & 1) : march_int_and($t45979, 1));
            }
            {
              let doubled_i5291;
              {
                let $t45973_i5289;
                {
                  const $t45972_i5288 = ((n - r) < 4611686018427387904 && (n - r) >= -4611686018427387904 ? (n - r) : march_int_ovf((n - r), 1));
                  $t45973_i5289 = (r >= $t45972_i5288);
                }
                if ($t45973_i5289 === true) {
                  {
                    const $t45974_i5290 = ((n - r) < 4611686018427387904 && (n - r) >= -4611686018427387904 ? (n - r) : march_int_ovf((n - r), 1));
                    doubled_i5291 = ((r - $t45974_i5290) < 4611686018427387904 && (r - $t45974_i5290) >= -4611686018427387904 ? (r - $t45974_i5290) : march_int_ovf((r - $t45974_i5290), 1));
                  }
                } else {
                  doubled_i5291 = ((r + r) < 4611686018427387904 && (r + r) >= -4611686018427387904 ? (r + r) : march_int_ovf((r + r), 0));
                }
              }
              {
                const $t45975_i5292 = ($t45980 === 0);
                if ($t45975_i5292 === true) {
                  $t45981 = doubled_i5291;
                } else {
                  {
                    let $t45977_i5294;
                    {
                      const $t45976_i5293 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                      $t45977_i5294 = (doubled_i5291 === $t45976_i5293);
                    }
                    if ($t45977_i5294 === true) {
                      $t45981 = 0;
                    } else {
                      $t45981 = ((doubled_i5291 + 1) < 4611686018427387904 && (doubled_i5291 + 1) >= -4611686018427387904 ? (doubled_i5291 + 1) : march_int_ovf((doubled_i5291 + 1), 0));
                    }
                  }
                }
              }
            }
          }
          {
            const $t45982 = ((position - 1) < 4611686018427387904 && (position - 1) >= -4611686018427387904 ? (position - 1) : march_int_ovf((position - 1), 1));
            {
              $tco_a0 = $t45981;
              $tco_a1 = word;
              $tco_a2 = $t45982;
              $tco_a3 = n;
              continue __tco;
            }
          }
        }
      }
    }
    return undefined;
  }
}
const Arcade$Rng$divide_word$clo = { _0: ($_, r, word, position, n) => Arcade$Rng$divide_word(r, word, position, n) };

function Arcade$Rng$next_int_below(r, n) {
  {
    const $p45993 = Arcade$Rng$next(r);
    {
      const v = $p45993._0;
      {
        const after = $p45993._1;
        {
          let $t45992;
          {
            const v_i13055 = v;
            {
              const $t45983_i13057 = (n <= 1048576);
              if ($t45983_i13057 === true) {
                {
                  let $t45988_i13062;
                  {
                    let $t45986_i13060;
                    {
                      let $t45985_i13059;
                      {
                        const $t45984_i13058 = v.hi;
                        $t45985_i13059 = ($t45984_i13058 % n);
                      }
                      $t45986_i13060 = (($t45985_i13059 * 4294967296) < 4611686018427387904 && ($t45985_i13059 * 4294967296) >= -4611686018427387904 ? ($t45985_i13059 * 4294967296) : march_int_ovf(($t45985_i13059 * 4294967296), 2));
                    }
                    {
                      const $t45987_i13061 = v.lo;
                      $t45988_i13062 = (($t45986_i13060 + $t45987_i13061) < 4611686018427387904 && ($t45986_i13060 + $t45987_i13061) >= -4611686018427387904 ? ($t45986_i13060 + $t45987_i13061) : march_int_ovf(($t45986_i13060 + $t45987_i13061), 0));
                    }
                  }
                  $t45992 = ($t45988_i13062 % n);
                }
              } else {
                {
                  let $t45990_i13064;
                  {
                    const $t45989_i13063 = v.hi;
                    $t45990_i13064 = Arcade$Rng$divide_word(0, $t45989_i13063, 31, n);
                  }
                  {
                    const $t45991_i13065 = v.lo;
                    $t45992 = Arcade$Rng$divide_word($t45990_i13064, $t45991_i13065, 31, n);
                  }
                }
              }
            }
          }
          {
            const $rc_2500 = { _0: $t45992, _1: after };
            return $rc_2500;
          }
        }
      }
    }
  }
}
const Arcade$Rng$next_int_below$clo = { _0: ($_, r, n) => Arcade$Rng$next_int_below(r, n) };

function Arcade$Vec2$add(a, b) {
  {
    let $t46053;
    {
      const $t46051 = a.x;
      {
        const $t46052 = b.x;
        $t46053 = ($t46051 + $t46052);
      }
    }
    {
      let $t46056;
      {
        const $t46054 = a.y;
        {
          const $t46055 = b.y;
          $t46056 = ($t46054 + $t46055);
        }
      }
      return ({ x: $t46053, y: $t46056 });
    }
  }
}
const Arcade$Vec2$add$clo = { _0: ($_, a, b) => Arcade$Vec2$add(a, b) };

function Arcade$Vec2$sub(a, b) {
  {
    let $t46059;
    {
      const $t46057 = a.x;
      {
        const $t46058 = b.x;
        $t46059 = ($t46057 - $t46058);
      }
    }
    {
      let $t46062;
      {
        const $t46060 = a.y;
        {
          const $t46061 = b.y;
          $t46062 = ($t46060 - $t46061);
        }
      }
      return ({ x: $t46059, y: $t46062 });
    }
  }
}
const Arcade$Vec2$sub$clo = { _0: ($_, a, b) => Arcade$Vec2$sub(a, b) };

function Arcade$Vec2$scale(a, k) {
  {
    let $t46064;
    {
      const $t46063 = a.x;
      $t46064 = ($t46063 * k);
    }
    {
      let $t46066;
      {
        const $t46065 = a.y;
        $t46066 = ($t46065 * k);
      }
      return ({ x: $t46064, y: $t46066 });
    }
  }
}
const Arcade$Vec2$scale$clo = { _0: ($_, a, k) => Arcade$Vec2$scale(a, k) };

function Arcade$Vec2$dot(a, b) {
  {
    let $t46073;
    {
      const $t46071 = a.x;
      {
        const $t46072 = b.x;
        $t46073 = ($t46071 * $t46072);
      }
    }
    {
      let $t46076;
      {
        const $t46074 = a.y;
        {
          const $t46075 = b.y;
          $t46076 = ($t46074 * $t46075);
        }
      }
      return ($t46073 + $t46076);
    }
  }
}
const Arcade$Vec2$dot$clo = { _0: ($_, a, b) => Arcade$Vec2$dot(a, b) };

function Arcade$Vec2$length(a) {
  {
    let $t46083;
    {
      let $t46079;
      {
        const $t46077 = a.x;
        {
          const $t46078 = a.x;
          $t46079 = ($t46077 * $t46078);
        }
      }
      {
        let $t46082;
        {
          const $t46080 = a.y;
          {
            const $t46081 = a.y;
            $t46082 = ($t46080 * $t46081);
          }
        }
        $t46083 = ($t46079 + $t46082);
      }
    }
    return Math.sqrt($t46083);
  }
}
const Arcade$Vec2$length$clo = { _0: ($_, a) => Arcade$Vec2$length(a) };

function Spin$Draw$stick(a, b, w, css) {
  {
    const $t46149 = a.x;
    {
      const $t46150 = a.y;
      {
        const $t46151 = b.x;
        {
          const $t46152 = b.y;
          return { $: "Line", _0: $t46149, _1: $t46150, _2: $t46151, _3: $t46152, _4: w, _5: css };
        }
      }
    }
  }
}
const Spin$Draw$stick$clo = { _0: ($_, a, b, w, css) => Spin$Draw$stick(a, b, w, css) };

function Spin$Draw$rgba(r, g, b, a) {
  {
    const $t46158 = String(r);
    {
      const $t46159 = String(g);
      {
        const $t46160 = String(b);
        {
          let $t46161;
          {
            let k_i14888;
            {
              let $t46154_i14887;
              {
                let $t46153_i14886;
                {
                  let $t45800_i5312_i14884;
                  {
                    const $t45798_i14587_i14883 = (0. >= a);
                    if ($t45798_i14587_i14883 === true) {
                      $t45800_i5312_i14884 = 0.;
                    } else {
                      $t45800_i5312_i14884 = a;
                    }
                  }
                  {
                    const $t45799_i14584_i14885 = (1. < $t45800_i5312_i14884);
                    if ($t45799_i14584_i14885 === true) {
                      $t46153_i14886 = 1.;
                    } else {
                      $t46153_i14886 = $t45800_i5312_i14884;
                    }
                  }
                }
                $t46154_i14887 = ($t46153_i14886 * 1000.);
              }
              k_i14888 = march_float_round($t46154_i14887);
            }
            {
              const $t46155_i14889 = (k_i14888 >= 1000);
              if ($t46155_i14889 === true) {
                $t46161 = "1";
              } else {
                {
                  let $t46157_i14892;
                  {
                    const $t46156_i14890 = String(k_i14888);
                    {
                      const $rc_2506_i14891 = march_string_pad_left($t46156_i14890, 3, "0");
                      $t46157_i14892 = $rc_2506_i14891;
                    }
                  }
                  {
                    const $rc_2505_i14893 = ("0." + $t46157_i14892);
                    $t46161 = $rc_2505_i14893;
                  }
                }
              }
            }
          }
          {
            const $rc_2507 = march_string_concat_n("rgba(", $t46158, ",", $t46159, ",", $t46160, ",", $t46161, ")");
            return $rc_2507;
          }
        }
      }
    }
  }
}
const Spin$Draw$rgba$clo = { _0: ($_, r, g, b, a) => Spin$Draw$rgba(r, g, b, a) };

function Spin$Game$buff_seconds(b) {
  switch (b.$) {
    case "SaveBuff": {
      return 12.;
      break;
    }
    case "FreezeBuff": {
      return 10.;
      break;
    }
    case "SlowBuff": {
      return 8.;
      break;
    }
    case "DoubleBuff": {
      return 15.;
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const Spin$Game$buff_seconds$clo = { _0: ($_, b) => Spin$Game$buff_seconds(b) };

function Spin$Game$buff_name(b) {
  switch (b.$) {
    case "SaveBuff": {
      return "BALL SAVE";
      break;
    }
    case "FreezeBuff": {
      return "METER FREEZE";
      break;
    }
    case "SlowBuff": {
      return "SLOW-MO";
      break;
    }
    case "DoubleBuff": {
      return "DOUBLE PAY";
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const Spin$Game$buff_name$clo = { _0: ($_, b) => Spin$Game$buff_name(b) };

function Spin$Game$ball_at_plunger(t) {
  {
    const $t46169 = t.plunger_rest;
    {
      const $t46170 = ({ x: 0., y: 0. });
      return ({ pos: $t46169, vel: $t46170 });
    }
  }
}
const Spin$Game$ball_at_plunger$clo = { _0: ($_, t) => Spin$Game$ball_at_plunger(t) };

function Spin$Game$boot(seed, best) {
  {
    let n;
    {
      const $t45817_i5318 = Arcade$Numerics$float_of_text("3.141592653589793");
      {
        const $t45818_i5319 = Arcade$Numerics$float_of_text("6.283185307179586");
        {
          const $t45819_i5320 = Arcade$Numerics$float_of_text("1.1102230246251565e-16");
          {
            let $t45821_i5322;
            {
              const $t45820_i5321 = Arcade$Numerics$float_of_text("1e308");
              $t45821_i5322 = ($t45820_i5321 * 10.);
            }
            {
              let $t45823_i5324;
              {
                const $t45822_i5323 = (-1.);
                $t45823_i5324 = Math.sqrt($t45822_i5323);
              }
              n = ({ pi: $t45817_i5318, tau: $t45818_i5319, unit53: $t45819_i5320, floor_u1: 1e-12, infinity: $t45821_i5322, nan: $t45823_i5324 });
            }
          }
        }
      }
    }
    {
      let t;
      t = Spin$Table$layout(n);
      {
        const $t46171 = { $: "Attract" };
        {
          const $t46172 = { $: "Nil" };
          {
            let $t46174;
            {
              const $t46173 = t.left;
              $t46174 = Spin$Physics$resting($t46173);
            }
            {
              let $t46176;
              {
                const $t46175 = t.right;
                $t46176 = Spin$Physics$resting($t46175);
              }
              {
                const $t46177 = Spin$Reels$fresh_bank();
                {
                  const $t46178 = ({ word: seed });
                  {
                    const $t46180 = ({ text: "SPIN SPIN SPIN", sub: "", left: 1000000., hot: false });
                    {
                      const $t46181 = { $: "Nil" };
                      {
                        const $t46182 = ({ left: false, right: false, launch: false, start: false });
                        {
                          const $t46183 = ({ name: "STEEL", sub: "the house ball", gravity: 1150., bounce: 0., drag: 0., wind: 0., magnet: 0., tint: "#b9a6ff" });
                          {
                            const $t46184 = { $: "Nil" };
                            {
                              const $t46185 = { $: "Nil" };
                              {
                                const $t46186 = { $: "Nil" };
                                {
                                  const $t46187 = { $: "Nil" };
                                  return ({ num: n, table: t, mode: $t46171, balls: $t46172, left: $t46174, right: $t46176, bank: $t46177, rng: $t46178, credits: 40, paid: 0, best: best, burn_clock: 0., alive: 0., pull: 0., save_left: 0., owed_balls: 0, carry: 0., banner: $t46180, lights: $t46181, spinner_turn: 0., spinner_rate: 0., last: $t46182, clock: 0., stage: 0, style: $t46183, buffs: $t46184, wins_at: $t46185, sparks: $t46186, pops: $t46187, flash: 0., flash_tint: "#ffd36b", win_glow: 0., start_stage: 0 });
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$boot$clo = { _0: ($_, seed, best) => Spin$Game$boot(seed, best) };

function Spin$Game$new_game(m) {
  {
    const $t46189 = { $: "Playing" };
    {
      let $t46191;
      {
        const $t46190 = m.table;
        $t46191 = Spin$Game$ball_at_plunger($t46190);
      }
      {
        const $t46192 = { $: "Nil" };
        {
          const $t46193 = { $: "Cons", _0: $t46191, _1: $t46192 };
          {
            const $t46194 = Spin$Reels$fresh_bank();
            {
              const $t46197 = ({ text: "SPELL A LINE", sub: "targets put their symbol on the armed reel", left: 3.5, hot: false });
              {
                const $t46198 = { $: "Nil" };
                {
                  let $t46201;
                  {
                    const $t46199 = m.num;
                    {
                      const $t46200 = m.start_stage;
                      $t46201 = Spin$Table$layout_at($t46199, $t46200);
                    }
                  }
                  {
                    const $t46202 = m.start_stage;
                    {
                      let $t46204;
                      {
                        const $t46203 = m.start_stage;
                        $t46204 = Spin$Style$for_stage($t46203);
                      }
                      {
                        const $t46205 = { $: "Nil" };
                        {
                          const $t46206 = { $: "Nil" };
                          {
                            const $t46207 = { $: "Nil" };
                            {
                              const $t46208 = { $: "Nil" };
                              {
                                const $rc_2509 = ({ ...m, mode: $t46189, balls: $t46193, bank: $t46194, credits: 40, paid: 0, burn_clock: 0., alive: 0., pull: 0., save_left: 8., owed_balls: 0, carry: 0., banner: $t46197, lights: $t46198, table: $t46201, stage: $t46202, style: $t46204, buffs: $t46205, wins_at: $t46206, sparks: $t46207, pops: $t46208, flash: 0., win_glow: 0. });
                                return $rc_2509;
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$new_game$clo = { _0: ($_, m) => Spin$Game$new_game(m) };

function Spin$Game$waiting(m) {
  {
    const $t46209 = m.balls;
    {
      const $t46211 = { $: "$Clo_$lam0_Spin_Game_waiting$0_Spin_Game_waiting", _0: $lam0_Spin_Game_waiting$apply$0_Spin_Game_waiting };
      return List$any$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46209, $t46211);
    }
  }
}
const Spin$Game$waiting$clo = { _0: ($_, m) => Spin$Game$waiting(m) };

function Spin$Game$resting_in_lane(b) {
  {
    let $t46217;
    {
      let $t46213;
      {
        const $t46212 = b.pos;
        $t46213 = Spin$Table$in_lane($t46212);
      }
      {
        let $t46216;
        {
          let $t46215;
          {
            const $t46214 = b.pos;
            $t46215 = $t46214.y;
          }
          $t46216 = ($t46215 > 640.);
        }
        $t46217 = ($t46213 && $t46216);
      }
    }
    {
      let $t46220;
      {
        let $t46219;
        {
          const $t46218 = b.vel;
          $t46219 = Arcade$Vec2$length($t46218);
        }
        $t46220 = ($t46219 < 40.);
      }
      return ($t46217 && $t46220);
    }
  }
}
const Spin$Game$resting_in_lane$clo = { _0: ($_, b) => Spin$Game$resting_in_lane(b) };

function Spin$Game$buff_left(m, b) {
  {
    const $t46225 = m.buffs;
    {
      const $t46229 = { $: "$Clo_$lam0_Spin_Game_buff_left$0_Spin_Game_buff_left", _0: $lam0_Spin_Game_buff_left$apply$0_Spin_Game_buff_left, _1: b };
      return List$fold_left$List_T_Buff_Float$Float$Fn_Float_T_Buff_Float_Float($t46225, 0., $t46229);
    }
  }
}
const Spin$Game$buff_left$clo = { _0: ($_, m, b) => Spin$Game$buff_left(m, b) };

function Spin$Game$streak(m) {
  {
    const $t46231 = m.wins_at;
    {
      let $t46236;
      $t46236 = { $: "$Clo_$lam0_Spin_Game_streak$0_Spin_Game_streak", _0: $lam0_Spin_Game_streak$apply$0_Spin_Game_streak, _1: m };
      {
        const open = List$filter$List_Float$Fn_Float_Bool($t46231, $t46236);
        {
          let newest;
          {
            const $t46237 = (-1000.);
            {
              const $t46239 = { $: "$Clo_$lam1_Spin_Game_streak$1_Spin_Game_streak", _0: $lam1_Spin_Game_streak$apply$1_Spin_Game_streak };
              newest = List$fold_left$List_Float$Float$Fn_Float_Float_Float(open, $t46237, $t46239);
            }
          }
          {
            let $t46240;
            {
              let $rc_2510;
              {  };
              $rc_2510 = List$length_onto$List_Float$Int(open, 0);
              $t46240 = $rc_2510;
            }
            {
              let $t46245;
              {
                let $t46244;
                {
                  let $t46243;
                  {
                    const $t46242 = m.clock;
                    $t46243 = ($t46242 - newest);
                  }
                  $t46244 = (12. - $t46243);
                }
                {
                  const $t45798_i5330 = ($t46244 >= 0.);
                  if ($t45798_i5330 === true) {
                    $t46245 = $t46244;
                  } else {
                    $t46245 = 0.;
                  }
                }
              }
              return { _0: $t46240, _1: $t46245 };
            }
          }
        }
      }
    }
  }
}
const Spin$Game$streak$clo = { _0: ($_, m) => Spin$Game$streak(m) };

function Spin$Game$light(m, f) {
  {
    const $t46246 = m.lights;
    {
      const $t46250 = { $: "$Clo_$lam0_Spin_Game_light$0_Spin_Game_light", _0: $lam0_Spin_Game_light$apply$0_Spin_Game_light, _1: f };
      return List$fold_left$List_T_Feature_Float$Float$Fn_Float_T_Feature_Float_Float($t46246, 0., $t46250);
    }
  }
}
const Spin$Game$light$clo = { _0: ($_, m, f) => Spin$Game$light(m, f) };

function Spin$Game$say(m, text, sub, seconds, hot) {
  {
    const $t46251 = ({ text: text, sub: sub, left: seconds, hot: hot });
    {
      const $rc_2511 = ({ ...m, banner: $t46251 });
      return $rc_2511;
    }
  }
}
const Spin$Game$say$clo = { _0: ($_, m, text, sub, seconds, hot) => Spin$Game$say(m, text, sub, seconds, hot) };

function Spin$Game$lit(m, f) {
  {
    const $t46252 = m.lights;
    {
      let $t46255;
      $t46255 = { $: "$Clo_$lam0_Spin_Game_lit$0_Spin_Game_lit", _0: $lam0_Spin_Game_lit$apply$0_Spin_Game_lit, _1: f };
      {
        let others;
        others = List$filter$List_T_Feature_Float$Fn_T_Feature_Float_Bool($t46252, $t46255);
        {
          const $t46256 = { _0: f, _1: 1. };
          {
            const $t46257 = { $: "Cons", _0: $t46256, _1: others };
            {
              const $rc_2512 = ({ ...m, lights: $t46257 });
              return $rc_2512;
            }
          }
        }
      }
    }
  }
}
const Spin$Game$lit$clo = { _0: ($_, m, f) => Spin$Game$lit(m, f) };

function Spin$Game$fade(m, dt) {
  {
    const $t46259 = m.lights;
    {
      const $t46264 = { $: "$Clo_$lam0_Spin_Game_fade$0_Spin_Game_fade", _0: $lam0_Spin_Game_fade$apply$0_Spin_Game_fade, _1: dt };
      {
        let dimmer;
        {
          const xs_i13127 = $t46259;
          {
            const f_i13128 = $t46264;
            switch (xs_i13127.$) {
              case "Nil": {
                dimmer = { $: "Nil" };
                break;
              }
              case "Cons": {
                const $f1006_i13129 = xs_i13127._0;
                const $f1007_i13130 = xs_i13127._1;
                {
                  const t_i13131 = $f1007_i13130;
                  {
                    const h_i13132 = $f1006_i13129;
                    {
                      let $t1004_i13133;
                      $t1004_i13133 = f_i13128._0(f_i13128, h_i13132);
                      {
                        const $trmc15_i13134 = { $: "Cons", _0: $t1004_i13133, _1: null };
                        List$map$dps$List_T_Feature_Float$Fn_T_Feature_Float_T_Feature_Float$List_T_Feature_Float(t_i13131, f_i13128, $trmc15_i13134);
                        dimmer = $trmc15_i13134;
                      }
                    }
                  }
                }
                break;
              }
              default: {
                throw new Error("non-exhaustive pattern match");
                break;
              }
            }
          }
        }
        {
          const b = m.banner;
          {
            const $t46266 = { $: "$Clo_$lam1_Spin_Game_fade$1_Spin_Game_fade", _0: $lam1_Spin_Game_fade$apply$1_Spin_Game_fade };
            {
              const glowing = List$filter$List_T_Feature_Float$Fn_T_Feature_Float_Bool(dimmer, $t46266);
              {
                let counted;
                {
                  let $t46268;
                  {
                    const $t46267 = b.left;
                    $t46268 = ($t46267 - dt);
                  }
                  counted = ({ ...b, left: $t46268 });
                }
                {
                  const $t46269 = m.buffs;
                  {
                    const $t46273 = { $: "$Clo_$lam2_Spin_Game_fade$2_Spin_Game_fade", _0: $lam2_Spin_Game_fade$apply$2_Spin_Game_fade, _1: dt };
                    {
                      let $t46274;
                      {
                        const xs_i13119 = $t46269;
                        {
                          const f_i13120 = $t46273;
                          switch (xs_i13119.$) {
                            case "Nil": {
                              $t46274 = { $: "Nil" };
                              break;
                            }
                            case "Cons": {
                              const $f1006_i13121 = xs_i13119._0;
                              const $f1007_i13122 = xs_i13119._1;
                              {
                                const t_i13123 = $f1007_i13122;
                                {
                                  const h_i13124 = $f1006_i13121;
                                  {
                                    let $t1004_i13125;
                                    $t1004_i13125 = f_i13120._0(f_i13120, h_i13124);
                                    {
                                      const $trmc15_i13126 = { $: "Cons", _0: $t1004_i13125, _1: null };
                                      List$map$dps$List_T_Buff_Float$Fn_T_Buff_Float_T_Buff_Float$List_T_Buff_Float(t_i13123, f_i13120, $trmc15_i13126);
                                      $t46274 = $trmc15_i13126;
                                    }
                                  }
                                }
                              }
                              break;
                            }
                            default: {
                              throw new Error("non-exhaustive pattern match");
                              break;
                            }
                          }
                        }
                      }
                      {
                        const $t46277 = { $: "$Clo_$lam3_Spin_Game_fade$3_Spin_Game_fade", _0: $lam3_Spin_Game_fade$apply$3_Spin_Game_fade };
                        {
                          const buffs = List$filter$List_T_Buff_Float$Fn_T_Buff_Float_Bool($t46274, $t46277);
                          {
                            const $t46278 = m.sparks;
                            {
                              const $t46280 = { $: "$Clo_$lam4_Spin_Game_fade$4_Spin_Game_fade", _0: $lam4_Spin_Game_fade$apply$4_Spin_Game_fade, _1: dt };
                              {
                                let $t46281;
                                {
                                  const xs_i13111 = $t46278;
                                  {
                                    const f_i13112 = $t46280;
                                    switch (xs_i13111.$) {
                                      case "Nil": {
                                        $t46281 = { $: "Nil" };
                                        break;
                                      }
                                      case "Cons": {
                                        const $f1006_i13113 = xs_i13111._0;
                                        const $f1007_i13114 = xs_i13111._1;
                                        {
                                          const t_i13115 = $f1007_i13114;
                                          {
                                            const h_i13116 = $f1006_i13113;
                                            {
                                              let $t1004_i13117;
                                              $t1004_i13117 = f_i13112._0(f_i13112, h_i13116);
                                              {
                                                const $trmc15_i13118 = { $: "Cons", _0: $t1004_i13117, _1: null };
                                                List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t_i13115, f_i13112, $trmc15_i13118);
                                                $t46281 = $trmc15_i13118;
                                              }
                                            }
                                          }
                                        }
                                        break;
                                      }
                                      default: {
                                        throw new Error("non-exhaustive pattern match");
                                        break;
                                      }
                                    }
                                  }
                                }
                                {
                                  const $t46284 = { $: "$Clo_$lam5_Spin_Game_fade$5_Spin_Game_fade", _0: $lam5_Spin_Game_fade$apply$5_Spin_Game_fade };
                                  {
                                    const sparks = List$filter$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46281, $t46284);
                                    {
                                      const $t46285 = m.pops;
                                      {
                                        const $t46296 = { $: "$Clo_$lam6_Spin_Game_fade$6_Spin_Game_fade", _0: $lam6_Spin_Game_fade$apply$6_Spin_Game_fade, _1: dt };
                                        {
                                          let $t46297;
                                          {
                                            const xs_i13103 = $t46285;
                                            {
                                              const f_i13104 = $t46296;
                                              switch (xs_i13103.$) {
                                                case "Nil": {
                                                  $t46297 = { $: "Nil" };
                                                  break;
                                                }
                                                case "Cons": {
                                                  const $f1006_i13105 = xs_i13103._0;
                                                  const $f1007_i13106 = xs_i13103._1;
                                                  {
                                                    const t_i13107 = $f1007_i13106;
                                                    {
                                                      const h_i13108 = $f1006_i13105;
                                                      {
                                                        let $t1004_i13109;
                                                        $t1004_i13109 = f_i13104._0(f_i13104, h_i13108);
                                                        {
                                                          const $trmc15_i13110 = { $: "Cons", _0: $t1004_i13109, _1: null };
                                                          List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String(t_i13107, f_i13104, $trmc15_i13110);
                                                          $t46297 = $trmc15_i13110;
                                                        }
                                                      }
                                                    }
                                                  }
                                                  break;
                                                }
                                                default: {
                                                  throw new Error("non-exhaustive pattern match");
                                                  break;
                                                }
                                              }
                                            }
                                          }
                                          {
                                            const $t46300 = { $: "$Clo_$lam7_Spin_Game_fade$7_Spin_Game_fade", _0: $lam7_Spin_Game_fade$apply$7_Spin_Game_fade };
                                            {
                                              const pops = List$filter$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_Bool($t46297, $t46300);
                                              {
                                                let $t46304;
                                                {
                                                  let $t46303;
                                                  {
                                                    const $t46301 = m.flash;
                                                    {
                                                      const $t46302 = (dt * 1.6);
                                                      $t46303 = ($t46301 - $t46302);
                                                    }
                                                  }
                                                  {
                                                    const $t45798_i5340 = ($t46303 >= 0.);
                                                    if ($t45798_i5340 === true) {
                                                      $t46304 = $t46303;
                                                    } else {
                                                      $t46304 = 0.;
                                                    }
                                                  }
                                                }
                                                {
                                                  let $t46308;
                                                  {
                                                    let $t46307;
                                                    {
                                                      const $t46305 = m.win_glow;
                                                      {
                                                        const $t46306 = (dt * 0.5);
                                                        $t46307 = ($t46305 - $t46306);
                                                      }
                                                    }
                                                    {
                                                      const $t45798_i5337 = ($t46307 >= 0.);
                                                      if ($t45798_i5337 === true) {
                                                        $t46308 = $t46307;
                                                      } else {
                                                        $t46308 = 0.;
                                                      }
                                                    }
                                                  }
                                                  {
                                                    let $t46312;
                                                    {
                                                      const $t46309 = m.spinner_turn;
                                                      {
                                                        let $t46311;
                                                        {
                                                          const $t46310 = m.spinner_rate;
                                                          $t46311 = ($t46310 * dt);
                                                        }
                                                        $t46312 = ($t46309 + $t46311);
                                                      }
                                                    }
                                                    {
                                                      let $t46317;
                                                      {
                                                        const $t46313 = m.spinner_rate;
                                                        {
                                                          let $t46316;
                                                          {
                                                            let $t46315;
                                                            {
                                                              const $t46314 = (2. * dt);
                                                              $t46315 = (1. - $t46314);
                                                            }
                                                            {
                                                              const $t45798_i5334 = ($t46315 >= 0.);
                                                              if ($t45798_i5334 === true) {
                                                                $t46316 = $t46315;
                                                              } else {
                                                                $t46316 = 0.;
                                                              }
                                                            }
                                                          }
                                                          $t46317 = ($t46313 * $t46316);
                                                        }
                                                      }
                                                      {
                                                        const $rc_2513 = ({ ...m, lights: glowing, banner: counted, buffs: buffs, sparks: sparks, pops: pops, flash: $t46304, win_glow: $t46308, spinner_turn: $t46312, spinner_rate: $t46317 });
                                                        return $rc_2513;
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$fade$clo = { _0: ($_, m, dt) => Spin$Game$fade(m, dt) };

function Spin$Game$spark_step(s, dt) {
  {
    let slowed;
    {
      const $t46318 = s.vel;
      {
        let $t46321;
        {
          let $t46320;
          {
            const $t46319 = (3. * dt);
            $t46320 = (1. - $t46319);
          }
          {
            const $t45798_i5345 = ($t46320 >= 0.);
            if ($t45798_i5345 === true) {
              $t46321 = $t46320;
            } else {
              $t46321 = 0.;
            }
          }
        }
        slowed = Arcade$Vec2$scale($t46318, $t46321);
      }
    }
    {
      let $t46324;
      {
        const $t46322 = s.pos;
        {
          let $t46323;
          $t46323 = Arcade$Vec2$scale(slowed, dt);
          $t46324 = Arcade$Vec2$add($t46322, $t46323);
        }
      }
      {
        let $t46327;
        {
          let $t46326;
          {
            const $t46325 = (260. * dt);
            $t46326 = ({ x: 0., y: $t46325 });
          }
          $t46327 = Arcade$Vec2$add(slowed, $t46326);
        }
        {
          let $t46329;
          {
            const $t46328 = s.life;
            $t46329 = ($t46328 - dt);
          }
          {
            const $rc_2514 = ({ ...s, pos: $t46324, vel: $t46327, life: $t46329 });
            return $rc_2514;
          }
        }
      }
    }
  }
}
const Spin$Game$spark_step$clo = { _0: ($_, s, dt) => Spin$Game$spark_step(s, dt) };

function Spin$Game$burst(m, at, count, speed, colour) {
  {
    let $t46330;
    {
      const go_i5351 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
      {
        const $t926_i5352 = ((count - 1) < 4611686018427387904 && (count - 1) >= -4611686018427387904 ? (count - 1) : march_int_ovf((count - 1), 1));
        {
          const $t927_i5353 = { $: "Nil" };
          $t46330 = go$apply$0_List_range(go_i5351, $t926_i5352, $t927_i5353);
        }
      }
    }
    {
      let $t46357;
      $t46357 = { $: "$Clo_$lam0_Spin_Game_burst$0_Spin_Game_burst", _0: $lam0_Spin_Game_burst$apply$0_Spin_Game_burst, _1: at, _2: colour, _3: count, _4: m, _5: speed };
      {
        let fresh;
        {
          const xs_i13142 = $t46330;
          {
            const f_i13143 = $t46357;
            switch (xs_i13142.$) {
              case "Nil": {
                fresh = { $: "Nil" };
                break;
              }
              case "Cons": {
                const $f1006_i13144 = xs_i13142._0;
                const $f1007_i13145 = xs_i13142._1;
                {
                  const t_i13146 = $f1007_i13145;
                  {
                    const h_i13147 = $f1006_i13144;
                    {
                      let $t1004_i13148;
                      $t1004_i13148 = f_i13143._0(f_i13143, h_i13147);
                      {
                        const $trmc15_i13149 = { $: "Cons", _0: $t1004_i13148, _1: null };
                        List$map$dps$List_Int$Fn_Int_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t_i13146, f_i13143, $trmc15_i13149);
                        fresh = $trmc15_i13149;
                      }
                    }
                  }
                }
                break;
              }
              default: {
                throw new Error("non-exhaustive pattern match");
                break;
              }
            }
          }
        }
        {
          const $t46358 = m.sparks;
          {
            let $t46359;
            {
              const xs_i13135 = fresh;
              {
                const ys_i13136 = $t46358;
                switch (xs_i13135.$) {
                  case "Nil": {
                    $t46359 = $t46358;
                    break;
                  }
                  case "Cons": {
                    const $f998_i13137 = xs_i13135._0;
                    const $f999_i13138 = xs_i13135._1;
                    {
                      const t_i13139 = $f999_i13138;
                      {
                        const h_i13140 = $f998_i13137;
                        {
                          const $trmc11_i13141 = { $: "Cons", _0: h_i13140, _1: null };
                          List$append$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t_i13139, $t46358, $trmc11_i13141);
                          $t46359 = $trmc11_i13141;
                        }
                      }
                    }
                    break;
                  }
                  default: {
                    throw new Error("non-exhaustive pattern match");
                    break;
                  }
                }
              }
            }
            {
              let $t46360;
              {
                const $t1237_i5348 = { $: "Nil" };
                $t46360 = List$take_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float($t46359, 90, $t1237_i5348);
              }
              {
                const $rc_2515 = ({ ...m, sparks: $t46360 });
                return $rc_2515;
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$burst$clo = { _0: ($_, m, at, count, speed, colour) => Spin$Game$burst(m, at, count, speed, colour) };

function Spin$Game$stage_up(acc) {
  {
    let $p46383;
    $p46383 = acc;
    {
      const m = $p46383._0;
      {
        const cues = $p46383._1;
        {
          let s;
          {
            const $t46365 = m.paid;
            s = Spin$Style$climb($t46365, 0);
          }
          {
            let $t46367;
            {
              const $t46366 = m.stage;
              $t46367 = (s > $t46366);
            }
            if ($t46367 === true) {
              {
                const style = Spin$Style$for_stage(s);
                {
                  let grown;
                  {
                    let $t46369;
                    {
                      const $t46368 = m.num;
                      $t46369 = Spin$Table$layout_at($t46368, s);
                    }
                    {
                      const $t46370 = style.tint;
                      {
                        let $t46372;
                        {
                          const $t46371 = m.save_left;
                          {
                            const $t45798_i5359 = (6. >= $t46371);
                            if ($t45798_i5359 === true) {
                              $t46372 = 6.;
                            } else {
                              $t46372 = $t46371;
                            }
                          }
                        }
                        grown = ({ ...m, stage: s, style: style, table: $t46369, flash: 1., flash_tint: $t46370, save_left: $t46372 });
                      }
                    }
                  }
                  {
                    let out;
                    {
                      let $t46378;
                      {
                        let $t46376;
                        {
                          let $t46374;
                          {
                            const $t46373 = ((s + 1) < 4611686018427387904 && (s + 1) >= -4611686018427387904 ? (s + 1) : march_int_ovf((s + 1), 0));
                            $t46374 = String($t46373);
                          }
                          {
                            const $t46375 = style.name;
                            {
                              const $rc_2517 = march_string_concat_n("STAGE ", $t46374, " · ", $t46375);
                              $t46376 = $rc_2517;
                            }
                          }
                        }
                        {
                          const $t46377 = style.sub;
                          $t46378 = Spin$Game$say(grown, $t46376, $t46377, 2.6, true);
                        }
                      }
                      {
                        const $t46379 = { $: "CueStage" };
                        {
                          const $t46380 = { $: "Nil" };
                          {
                            const $t46381 = { $: "Cons", _0: $t46379, _1: $t46380 };
                            {
                              let $t46382;
                              $t46382 = List$append$List_Cue$List_Cue(cues, $t46381);
                              out = { _0: $t46378, _1: $t46382 };
                            }
                          }
                        }
                      }
                    }
                    return out;
                  }
                }
              }
            } else {
              return acc;
            }
          }
        }
      }
    }
  }
}
const Spin$Game$stage_up$clo = { _0: ($_, acc) => Spin$Game$stage_up(acc) };

function Spin$Game$give(m, b) {
  {
    const $t46384 = m.buffs;
    {
      let $t46387;
      $t46387 = { $: "$Clo_$lam0_Spin_Game_give$0_Spin_Game_give", _0: $lam0_Spin_Game_give$apply$0_Spin_Game_give, _1: b };
      {
        const others = List$filter$List_T_Buff_Float$Fn_T_Buff_Float_Bool($t46384, $t46387);
        {
          let saved;
          {
            let $t46389;
            {
              const $t46388 = { $: "SaveBuff" };
              {
                const $rc_2526 = march_deep_eq(b, $t46388);
                $t46389 = $rc_2526;
              }
            }
            if ($t46389 === true) {
              {
                let $t46392;
                {
                  const $t46390 = m.save_left;
                  {
                    const $t46391 = Spin$Game$buff_seconds(b);
                    {
                      const $t45798_i5363 = ($t46391 >= $t46390);
                      if ($t45798_i5363 === true) {
                        $t46392 = $t46391;
                      } else {
                        $t46392 = $t46390;
                      }
                    }
                  }
                }
                {
                  const $rc_2527 = ({ ...m, save_left: $t46392 });
                  saved = $rc_2527;
                }
              }
            } else {
              saved = m;
            }
          }
          {
            const $t46393 = Spin$Game$buff_seconds(b);
            {
              const $t46394 = { _0: b, _1: $t46393 };
              {
                const $t46395 = { $: "Cons", _0: $t46394, _1: others };
                {
                  const $rc_2525 = ({ ...saved, buffs: $t46395 });
                  return $rc_2525;
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$give$clo = { _0: ($_, m, b) => Spin$Game$give(m, b) };

function Spin$Game$extra_ball(m) {
  {
    let $t46401;
    {
      let $t46399;
      {
        let $t46397;
        {
          const $t46396 = m.balls;
          {  };
          $t46397 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t46396, 0);
        }
        {
          const $t46398 = m.owed_balls;
          $t46399 = (($t46397 + $t46398) < 4611686018427387904 && ($t46397 + $t46398) >= -4611686018427387904 ? ($t46397 + $t46398) : march_int_ovf(($t46397 + $t46398), 0));
        }
      }
      $t46401 = ($t46399 < 3);
    }
    if ($t46401 === true) {
      {
        let $t46404;
        {
          let $t46403;
          {
            const $t46402 = m.owed_balls;
            $t46403 = (($t46402 + 1) < 4611686018427387904 && ($t46402 + 1) >= -4611686018427387904 ? ($t46402 + 1) : march_int_ovf(($t46402 + 1), 0));
          }
          $t46404 = ({ ...m, owed_balls: $t46403 });
        }
        return { _0: $t46404, _1: "EXTRA BALL" };
      }
    } else {
      {
        let $t46406;
        {
          const $t46405 = { $: "SaveBuff" };
          $t46406 = Spin$Game$give(m, $t46405);
        }
        {
          let $t46408;
          {
            const $t46407 = { $: "SaveBuff" };
            {
              const $rc_2528 = Spin$Game$buff_name($t46407);
              $t46408 = $rc_2528;
            }
          }
          return { _0: $t46406, _1: $t46408 };
        }
      }
    }
  }
}
const Spin$Game$extra_ball$clo = { _0: ($_, m) => Spin$Game$extra_ball(m) };

function Spin$Game$reward(m, tier) {
  {
    const $t46409 = (tier <= 1);
    if ($t46409 === true) {
      {
        let $p46421;
        {
          const $t46410 = m.rng;
          {
            const $t46411 = { $: "SaveBuff" };
            {
              const $t46412 = { $: "FreezeBuff" };
              {
                const $t46413 = { $: "SlowBuff" };
                {
                  const $t46414 = { $: "Nil" };
                  {
                    const $t46415 = { $: "Cons", _0: $t46413, _1: $t46414 };
                    {
                      const $t46416 = { $: "Cons", _0: $t46412, _1: $t46415 };
                      {
                        const $t46417 = { $: "Cons", _0: $t46411, _1: $t46416 };
                        {
                          let $p46044_i13154;
                          {
                            let $t46042_i13153;
                            {  };
                            $t46042_i13153 = List$length_onto$List_Buff$Int($t46417, 0);
                            $p46044_i13154 = Arcade$Rng$next_int_below($t46410, $t46042_i13153);
                          }
                          {
                            const i_i13155 = $p46044_i13154._0;
                            {
                              const after_i13156 = $p46044_i13154._1;
                              {
                                const $t46043_i13157 = List$nth$List_Buff$Int($t46417, i_i13155);
                                {
                                  const $rc_2877_i13158 = { _0: $t46043_i13157, _1: after_i13156 };
                                  $p46421 = $rc_2877_i13158;
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        {
          const b = $p46421._0;
          {
            const rng = $p46421._1;
            {
              let $t46419;
              {
                let $t46418;
                $t46418 = ({ ...m, rng: rng });
                $t46419 = Spin$Game$give($t46418, b);
              }
              {
                const $t46420 = Spin$Game$buff_name(b);
                {
                  const $rc_2530 = { _0: $t46419, _1: $t46420 };
                  return $rc_2530;
                }
              }
            }
          }
        }
      }
    } else {
      {
        const $t46422 = (tier === 2);
        if ($t46422 === true) {
          {
            let $p46429;
            {
              const $t46423 = m.rng;
              $p46429 = Arcade$Rng$next_int_below($t46423, 2);
            }
            {
              const k = $p46429._0;
              {
                const rng = $p46429._1;
                {
                  let rolled;
                  rolled = ({ ...m, rng: rng });
                  {
                    const $t46424 = (k === 0);
                    if ($t46424 === true) {
                      {
                        let $t46426;
                        {
                          const $t46425 = { $: "DoubleBuff" };
                          $t46426 = Spin$Game$give(rolled, $t46425);
                        }
                        {
                          let $t46428;
                          {
                            const $t46427 = { $: "DoubleBuff" };
                            {
                              const $rc_2531 = Spin$Game$buff_name($t46427);
                              $t46428 = $rc_2531;
                            }
                          }
                          {
                            const $rc_2533 = { _0: $t46426, _1: $t46428 };
                            return $rc_2533;
                          }
                        }
                      }
                    } else {
                      return Spin$Game$extra_ball(rolled);
                    }
                  }
                }
              }
            }
          }
        } else {
          {
            let $p46433;
            {
              let $t46431;
              {
                const $t46430 = { $: "DoubleBuff" };
                $t46431 = Spin$Game$give(m, $t46430);
              }
              $p46433 = Spin$Game$extra_ball($t46431);
            }
            {
              const more = $p46433._0;
              {
                const what = $p46433._1;
                {
                  const $t46432 = (what + " + DOUBLE PAY");
                  {
                    const $rc_2535 = { _0: more, _1: $t46432 };
                    return $rc_2535;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$reward$clo = { _0: ($_, m, tier) => Spin$Game$reward(m, tier) };

function Spin$Game$streak_on(acc, pay) {
  {
    let $p46459;
    $p46459 = acc;
    {
      const m = $p46459._0;
      {
        const cues = $p46459._1;
        {
          const $t46435 = (pay < 3);
          if ($t46435 === true) {
            return acc;
          } else {
            {
              const $t46436 = m.wins_at;
              {
                let $t46441;
                $t46441 = { $: "$Clo_$lam0_Spin_Game_streak_on$0_Spin_Game_streak_on", _0: $lam0_Spin_Game_streak_on$apply$0_Spin_Game_streak_on, _1: m };
                {
                  let open;
                  open = List$filter$List_Float$Fn_Float_Bool($t46436, $t46441);
                  {
                    let joined;
                    {
                      const $t46442 = m.clock;
                      {
                        const $t46443 = { $: "Cons", _0: $t46442, _1: open };
                        joined = ({ ...m, wins_at: $t46443 });
                      }
                    }
                    {
                      let n;
                      {
                        const $t46444 = joined.wins_at;
                        {  };
                        n = List$length_onto$List_Float$Int($t46444, 0);
                      }
                      {
                        const $t46445 = (n >= 3);
                        if ($t46445 === true) {
                          {
                            let tier;
                            {
                              const $t46446 = ((n - 2) < 4611686018427387904 && (n - 2) >= -4611686018427387904 ? (n - 2) : march_int_ovf((n - 2), 1));
                              {
                                const $t2473_i5370 = (3 < $t46446);
                                if ($t2473_i5370 === true) {
                                  tier = 3;
                                } else {
                                  tier = $t46446;
                                }
                              }
                            }
                            {
                              const $p46458 = Spin$Game$reward(joined, tier);
                              {
                                const given0 = $p46458._0;
                                {
                                  const what = $p46458._1;
                                  {
                                    let given;
                                    {
                                      const $t46447 = (n >= 5);
                                      if ($t46447 === true) {
                                        {
                                          const $t46448 = { $: "Nil" };
                                          given = ({ ...given0, wins_at: $t46448 });
                                        }
                                      } else {
                                        given = given0;
                                      }
                                    }
                                    {
                                      let lit;
                                      {
                                        let $t46450;
                                        {
                                          const $t46449 = given.flash;
                                          {
                                            const $t45798_i5367 = (0.7 >= $t46449);
                                            if ($t45798_i5367 === true) {
                                              $t46450 = 0.7;
                                            } else {
                                              $t46450 = $t46449;
                                            }
                                          }
                                        }
                                        lit = ({ ...given, flash: $t46450, flash_tint: "#5cf2ff" });
                                      }
                                      {
                                        let out;
                                        {
                                          let $t46453;
                                          {
                                            let $t46452;
                                            {
                                              const $t46451 = String(n);
                                              {
                                                const $rc_2536 = march_string_concat3("STREAK x", $t46451, "!");
                                                $t46452 = $rc_2536;
                                              }
                                            }
                                            $t46453 = Spin$Game$say(lit, $t46452, what, 2.4, true);
                                          }
                                          {
                                            const $t46454 = { $: "CueBuff", _0: tier };
                                            {
                                              const $t46455 = { $: "Nil" };
                                              {
                                                const $t46456 = { $: "Cons", _0: $t46454, _1: $t46455 };
                                                {
                                                  let $t46457;
                                                  $t46457 = List$append$List_Cue$List_Cue(cues, $t46456);
                                                  out = { _0: $t46453, _1: $t46457 };
                                                }
                                              }
                                            }
                                          }
                                        }
                                        return out;
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          {
                            const $rc_2544 = { _0: joined, _1: cues };
                            return $rc_2544;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$streak_on$clo = { _0: ($_, acc, pay) => Spin$Game$streak_on(acc, pay) };

function Spin$Game$win(acc, n0, name) {
  {
    const $p46491 = acc;
    {
      const m = acc._0;
      {
        const cues = acc._1;
        {
          let n;
          {
            let $t46461;
            {
              const $t46460 = { $: "DoubleBuff" };
              {
                const $t46230_i5383 = Spin$Game$buff_left(m, $t46460);
                $t46461 = ($t46230_i5383 > 0.);
              }
            }
            if ($t46461 === true) {
              n = ((n0 * 2) < 4611686018427387904 && (n0 * 2) >= -4611686018427387904 ? (n0 * 2) : march_int_ovf((n0 * 2), 2));
            } else {
              n = n0;
            }
          }
          {
            let won;
            {
              let $t46463;
              {
                const $t46462 = m.credits;
                $t46463 = (($t46462 + n) < 4611686018427387904 && ($t46462 + n) >= -4611686018427387904 ? ($t46462 + n) : march_int_ovf(($t46462 + n), 0));
              }
              {
                let $t46465;
                {
                  const $t46464 = m.paid;
                  $t46465 = (($t46464 + n) < 4611686018427387904 && ($t46464 + n) >= -4611686018427387904 ? ($t46464 + n) : march_int_ovf(($t46464 + n), 0));
                }
                won = ({ ...m, credits: $t46463, paid: $t46465, win_glow: 1. });
              }
            }
            {
              const jackpot = march_string_contains(name, "777");
              {
                let owed;
                {
                  let $t46472;
                  {
                    let $t46471;
                    {
                      let $t46469;
                      {
                        let $t46467;
                        {
                          const $t46466 = m.balls;
                          {  };
                          $t46467 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t46466, 0);
                        }
                        {
                          const $t46468 = m.owed_balls;
                          $t46469 = (($t46467 + $t46468) < 4611686018427387904 && ($t46467 + $t46468) >= -4611686018427387904 ? ($t46467 + $t46468) : march_int_ovf(($t46467 + $t46468), 0));
                        }
                      }
                      $t46471 = ($t46469 < 3);
                    }
                    $t46472 = (jackpot && $t46471);
                  }
                  if ($t46472 === true) {
                    {
                      const $t46473 = won.owed_balls;
                      owed = (($t46473 + 1) < 4611686018427387904 && ($t46473 + 1) >= -4611686018427387904 ? ($t46473 + 1) : march_int_ovf(($t46473 + 1), 0));
                    }
                  } else {
                    owed = won.owed_balls;
                  }
                }
                {
                  let shown;
                  {
                    const $t46474 = ({ ...won, owed_balls: owed });
                    {
                      let $t46479;
                      {
                        const $t46475 = String(n);
                        {
                          let $t46477;
                          {
                            const $t46476 = (n > n0);
                            if ($t46476 === true) {
                              $t46477 = "  DOUBLED";
                            } else {
                              $t46477 = "";
                            }
                          }
                          {
                            let $t46478;
                            if (jackpot === true) {
                              $t46478 = "  MULTIBALL";
                            } else {
                              $t46478 = "";
                            }
                            {
                              const $rc_2548 = march_string_concat_n("+", $t46475, " CREDITS", $t46477, $t46478);
                              $t46479 = $rc_2548;
                            }
                          }
                        }
                      }
                      shown = Spin$Game$say($t46474, name, $t46479, 2.6, true);
                    }
                  }
                  {
                    let popped;
                    {
                      let $t46481;
                      {
                        const $t46480 = String(n);
                        {
                          const $rc_2547 = ("+" + $t46480);
                          $t46481 = $rc_2547;
                        }
                      }
                      {
                        const $t46482 = ({ x: 185., y: 368. });
                        {
                          let $t46483;
                          if (jackpot === true) {
                            $t46483 = "#ff3fa4";
                          } else {
                            $t46483 = "#7dff7a";
                          }
                          {
                            const m_i13166 = shown;
                            {
                              const $t46361_i13170 = ({ text: $t46481, pos: $t46482, life: 1.1, colour: $t46483 });
                              {
                                const $t46362_i13171 = shown.pops;
                                {
                                  let $t46363_i13175;
                                  {
                                    const $t1237_i5356_i13174 = { $: "Nil" };
                                    $t46363_i13175 = List$take_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Int$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String($t46362_i13171, 5, $t1237_i5356_i13174);
                                  }
                                  {
                                    const $t46364_i13176 = { $: "Cons", _0: $t46361_i13170, _1: $t46363_i13175 };
                                    {
                                      const $rc_2516_i13177 = ({ ...shown, pops: $t46364_i13176 });
                                      popped = $rc_2516_i13177;
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    {
                      let flashed;
                      if (jackpot === true) {
                        {
                          const $t46484 = ({ ...popped, flash: 1., flash_tint: "#ff3fa4" });
                          {
                            const $t46485 = ({ x: 185., y: 426. });
                            flashed = Spin$Game$burst($t46484, $t46485, 40, 520., "#ffd36b");
                          }
                        }
                      } else {
                        {
                          const $t46486 = (n >= 10);
                          if ($t46486 === true) {
                            {
                              const $t46487 = ({ x: 185., y: 426. });
                              flashed = Spin$Game$burst(popped, $t46487, 18, 360., "#ffd36b");
                            }
                          } else {
                            flashed = popped;
                          }
                        }
                      }
                      {
                        let streaked;
                        {
                          let $t46488;
                          $t46488 = { _0: flashed, _1: cues };
                          streaked = Spin$Game$streak_on($t46488, n0);
                        }
                        {
                          let $t46490;
                          {
                            let $t46489;
                            if (jackpot === true) {
                              $t46489 = { $: "CueJackpot" };
                            } else {
                              $t46489 = { $: "CueWin", _0: n };
                            }
                            {
                              const $p46544_i13161 = streaked;
                              {
                                const m_i13162 = streaked._0;
                                {
                                  const cues_i13163 = streaked._1;
                                  {
                                    let $t46543_i13164;
                                    $t46543_i13164 = { $: "Cons", _0: $t46489, _1: cues_i13163 };
                                    {
                                      const $rc_2571_i13165 = { _0: m_i13162, _1: $t46543_i13164 };
                                      $t46490 = $rc_2571_i13165;
                                    }
                                  }
                                }
                              }
                            }
                          }
                          return Spin$Game$stage_up($t46490);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$win$clo = { _0: ($_, acc, n0, name) => Spin$Game$win(acc, n0, name) };

function Spin$Game$reel_news(acc, e) {
  {
    const $p46542 = acc;
    {
      const m = acc._0;
      {
        const cues = acc._1;
        switch (e.$) {
          case "Loaded": {
            const $f46526 = e._0;
            const $f46527 = e._1;
            {
              const i = $f46527;
              {
                const s = $f46526;
                {
                  let $t46500;
                  {
                    let $t46495;
                    {
                      let $t46492;
                      switch (s.$) {
                        case "Blank": {
                          $t46492 = "";
                          break;
                        }
                        case "Cherry": {
                          $t46492 = "CHERRY";
                          break;
                        }
                        case "Lemon": {
                          $t46492 = "LEMON";
                          break;
                        }
                        case "Bell": {
                          $t46492 = "BELL";
                          break;
                        }
                        case "Bars": {
                          $t46492 = "BAR";
                          break;
                        }
                        case "Seven": {
                          $t46492 = "7";
                          break;
                        }
                        default: {
                          throw new Error("non-exhaustive pattern match");
                          break;
                        }
                      }
                      {
                        let $t46494;
                        {
                          const $t46493 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
                          $t46494 = String($t46493);
                        }
                        {
                          const $rc_2551 = march_string_concat3($t46492, " ON REEL ", $t46494);
                          $t46495 = $rc_2551;
                        }
                      }
                    }
                    {
                      let $t46499;
                      {
                        const $t46496 = (i === 2);
                        if ($t46496 === true) {
                          $t46499 = "the line is judged";
                        } else {
                          {
                            let $t46498;
                            {
                              const $t46497 = ((i + 2) < 4611686018427387904 && (i + 2) >= -4611686018427387904 ? (i + 2) : march_int_ovf((i + 2), 0));
                              $t46498 = String($t46497);
                            }
                            {
                              const $rc_2550 = ("next: reel " + $t46498);
                              $t46499 = $rc_2550;
                            }
                          }
                        }
                      }
                      $t46500 = Spin$Game$say(m, $t46495, $t46499, 1.4, false);
                    }
                  }
                  {
                    let $t46502;
                    {
                      let $t46501;
                      {
                        const $rc_2549 = Spin$Reels$rank(s);
                        $t46501 = $rc_2549;
                      }
                      $t46502 = { $: "CueLoad", _0: $t46501 };
                    }
                    {
                      let $t46503;
                      $t46503 = { $: "Cons", _0: $t46502, _1: cues };
                      {
                        const $rc_2562 = { _0: $t46500, _1: $t46503 };
                        return $rc_2562;
                      }
                    }
                  }
                }
              }
            }
            break;
          }
          case "Banked": {
            const $f46532 = e._0;
            {
              const n = $f46532;
              {
                let $t46507;
                {
                  const $t46504 = (n > 1);
                  if ($t46504 === true) {
                    {
                      let $t46506;
                      {
                        const $t46505 = String(n);
                        {
                          const $rc_2552 = ("SPINS x" + $t46505);
                          $t46506 = $rc_2552;
                        }
                      }
                      $t46507 = Spin$Game$say(m, $t46506, "banked", 1., false);
                    }
                  } else {
                    $t46507 = m;
                  }
                }
                {
                  const $rc_2563 = { _0: $t46507, _1: cues };
                  return $rc_2563;
                }
              }
            }
            break;
          }
          case "Started": {
            {
              const $t46508 = { $: "CueReelStart" };
              {
                let $t46509;
                $t46509 = { $: "Cons", _0: $t46508, _1: cues };
                {
                  const $rc_2564 = { _0: m, _1: $t46509 };
                  return $rc_2564;
                }
              }
            }
            break;
          }
          case "Landed": {
            const $f46533 = e._0;
            {
              const i = $f46533;
              {
                const $t46510 = { $: "CueReelStop", _0: i };
                {
                  let $t46511;
                  $t46511 = { $: "Cons", _0: $t46510, _1: cues };
                  {
                    const $rc_2565 = { _0: m, _1: $t46511 };
                    return $rc_2565;
                  }
                }
              }
            }
            break;
          }
          case "Paid": {
            const $f46534 = e._0;
            const $f46535 = e._1;
            {
              const name = $f46535;
              {
                const n0 = $f46534;
                {
                  let $t46512;
                  $t46512 = { _0: m, _1: cues };
                  return Spin$Game$win($t46512, n0, name);
                }
              }
            }
            break;
          }
          case "Missed": {
            {
              let $t46514;
              $t46514 = Spin$Game$say(m, "NUDGE!", "bumpers roll the reels", 4., false);
              {
                const $t46515 = { $: "CueMiss" };
                {
                  let $t46516;
                  $t46516 = { $: "Cons", _0: $t46515, _1: cues };
                  {
                    const $rc_2566 = { _0: $t46514, _1: $t46516 };
                    return $rc_2566;
                  }
                }
              }
            }
            break;
          }
          case "Nudged": {
            const $f46540 = e._0;
            {
              const $t46517 = { $: "CueNudge" };
              {
                let $t46518;
                $t46518 = { $: "Cons", _0: $t46517, _1: cues };
                {
                  const $rc_2567 = { _0: m, _1: $t46518 };
                  return $rc_2567;
                }
              }
            }
            break;
          }
          case "Held": {
            const $f46541 = e._0;
            {
              const i = $f46541;
              {
                let $t46522;
                {
                  let $t46521;
                  {
                    let $t46520;
                    {
                      const $t46519 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
                      $t46520 = String($t46519);
                    }
                    {
                      const $rc_2553 = ("HOLD " + $t46520);
                      $t46521 = $rc_2553;
                    }
                  }
                  $t46522 = Spin$Game$say(m, $t46521, "for the next spin", 1.2, false);
                }
                {
                  const $t46523 = { $: "CueLane" };
                  {
                    let $t46524;
                    $t46524 = { $: "Cons", _0: $t46523, _1: cues };
                    {
                      const $rc_2568 = { _0: $t46522, _1: $t46524 };
                      return $rc_2568;
                    }
                  }
                }
              }
            }
            break;
          }
          case "Doubled": {
            {
              let $t46525;
              $t46525 = Spin$Game$say(m, "FREE SPIN x2", "all three lanes", 2., true);
              {
                const $rc_2569 = { _0: $t46525, _1: cues };
                return $rc_2569;
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
  }
}
const Spin$Game$reel_news$clo = { _0: ($_, acc, e) => Spin$Game$reel_news(acc, e) };

function Spin$Game$with_bank(acc, step) {
  {
    const $p46548 = acc;
    {
      const m = acc._0;
      {
        const cues = acc._1;
        {
          const $p46547 = step;
          {
            const b = step._0;
            {
              const evs = step._1;
              {
                let $t46545;
                $t46545 = ({ ...m, bank: b });
                {
                  let $t46546;
                  $t46546 = { _0: $t46545, _1: cues };
                  return List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue(evs, $t46546, Spin$Game$reel_news$clo);
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$with_bank$clo = { _0: ($_, acc, step) => Spin$Game$with_bank(acc, step) };

function Spin$Game$touch(acc, h) {
  {
    let $p46603;
    $p46603 = acc;
    {
      const m = $p46603._0;
      {
        const cues = $p46603._1;
        switch (h.$) {
          case "Flipped": {
            const $f46591 = h._0;
            {
              const speed = $f46591;
              {
                const $t46549 = (speed > 300.);
                {
                  let $t46551;
                  if ($t46549 === true) {
                    {
                      const $t46550 = { $: "CueThud", _0: speed };
                      $t46551 = { $: "Cons", _0: $t46550, _1: cues };
                    }
                  } else {
                    $t46551 = cues;
                  }
                  {
                    const $rc_2577 = { _0: m, _1: $t46551 };
                    return $rc_2577;
                  }
                }
              }
            }
            break;
          }
          case "Touched": {
            const $f46592 = h._0;
            const $f46593 = h._1;
            const $f46594 = h._2;
            {
              const at = $f46594;
              {
                const speed = $f46593;
                {
                  const f = $f46592;
                  switch (f.$) {
                    case "Plain": {
                      {
                        const $t46552 = (speed > 260.);
                        {
                          let $t46554;
                          if ($t46552 === true) {
                            {
                              const $t46553 = { $: "CueThud", _0: speed };
                              $t46554 = { $: "Cons", _0: $t46553, _1: cues };
                            }
                          } else {
                            $t46554 = cues;
                          }
                          {
                            const $rc_2578 = { _0: m, _1: $t46554 };
                            return $rc_2578;
                          }
                        }
                      }
                      break;
                    }
                    case "Bumper": {
                      const $f46588 = f._0;
                      {
                        const i = $f46588;
                        {
                          let $t46556;
                          {
                            let $t46555;
                            $t46555 = Spin$Game$lit(m, f);
                            $t46556 = Spin$Game$burst($t46555, at, 7, 260., "#ff8fcf");
                          }
                          {
                            const $t46557 = { $: "CueBumper" };
                            {
                              let $t46558;
                              $t46558 = { $: "Cons", _0: $t46557, _1: cues };
                              {
                                const $t46559 = { _0: $t46556, _1: $t46558 };
                                {
                                  let $t46562;
                                  {
                                    const $t46560 = m.bank;
                                    {
                                      const $t46561 = march_int_mod_euclid(i, 3);
                                      $t46562 = Spin$Reels$nudge($t46560, $t46561);
                                    }
                                  }
                                  return Spin$Game$with_bank($t46559, $t46562);
                                }
                              }
                            }
                          }
                        }
                      }
                      break;
                    }
                    case "Sling": {
                      {
                        const $t46563 = (speed > 80.);
                        if ($t46563 === true) {
                          {
                            let $t46565;
                            {
                              let $t46564;
                              $t46564 = Spin$Game$lit(m, f);
                              $t46565 = Spin$Game$burst($t46564, at, 5, 200., "#ffb27a");
                            }
                            {
                              const $t46566 = { $: "CueSling" };
                              {
                                let $t46567;
                                $t46567 = { $: "Cons", _0: $t46566, _1: cues };
                                {
                                  const $rc_2580 = { _0: $t46565, _1: $t46567 };
                                  return $rc_2580;
                                }
                              }
                            }
                          }
                        } else {
                          return acc;
                        }
                      }
                      break;
                    }
                    case "Loader": {
                      const $f46589 = f._0;
                      {
                        const s = $f46589;
                        {
                          let $t46571;
                          {
                            const $t46568 = (speed > 60.);
                            {
                              let $t46570;
                              {
                                let $t46569;
                                $t46569 = Spin$Game$light(m, f);
                                $t46570 = ($t46569 < 0.6);
                              }
                              $t46571 = ($t46568 && $t46570);
                            }
                          }
                          if ($t46571 === true) {
                            {
                              let $t46573;
                              {
                                let $t46572;
                                $t46572 = Spin$Game$lit(m, f);
                                $t46573 = Spin$Game$burst($t46572, at, 10, 300., "#ffffff");
                              }
                              {
                                let $t46574;
                                $t46574 = { _0: $t46573, _1: cues };
                                {
                                  let $t46576;
                                  {
                                    const $t46575 = m.bank;
                                    $t46576 = Spin$Reels$load($t46575, s);
                                  }
                                  return Spin$Game$with_bank($t46574, $t46576);
                                }
                              }
                            }
                          } else {
                            return acc;
                          }
                        }
                      }
                      break;
                    }
                    case "Spinner": {
                      {
                        let shone;
                        shone = Spin$Game$lit(m, f);
                        {
                          const spun = ({ ...shone, spinner_rate: 40. });
                          {
                            const $t46577 = Spin$Game$burst(spun, at, 6, 220., "#5cf2ff");
                            {
                              const $t46578 = { $: "CueSpinner" };
                              {
                                let $t46579;
                                $t46579 = { $: "Cons", _0: $t46578, _1: cues };
                                {
                                  const $t46580 = { _0: $t46577, _1: $t46579 };
                                  {
                                    let $t46582;
                                    {
                                      const $t46581 = m.bank;
                                      $t46582 = Spin$Reels$bank_spin($t46581);
                                    }
                                    return Spin$Game$with_bank($t46580, $t46582);
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                      break;
                    }
                    case "HoldLane": {
                      const $f46590 = f._0;
                      {
                        const i = $f46590;
                        {
                          let $t46584;
                          {
                            let $t46583;
                            $t46583 = Spin$Game$lit(m, f);
                            $t46584 = Spin$Game$burst($t46583, at, 6, 180., "#7dff7a");
                          }
                          {
                            let $t46585;
                            $t46585 = { _0: $t46584, _1: cues };
                            {
                              let $t46587;
                              {
                                const $t46586 = m.bank;
                                $t46587 = Spin$Reels$hold($t46586, i);
                              }
                              return Spin$Game$with_bank($t46585, $t46587);
                            }
                          }
                        }
                      }
                      break;
                    }
                    default: {
                      return (() => { throw new Error("non-exhaustive pattern match"); })();
                    }
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
  }
}
const Spin$Game$touch$clo = { _0: ($_, acc, h) => Spin$Game$touch(acc, h) };

function Spin$Game$plunge(m, input, dt) {
  {
    const held = input.launch;
    {
      let was;
      {
        const $t46615 = m.last;
        was = $t46615.launch;
      }
      {
        let $t46622;
        {
          let $t46617;
          {
            let $t46616;
            $t46616 = Spin$Game$waiting(m);
            $t46617 = (held && $t46616);
          }
          {
            let $t46621;
            {
              const $t46618 = (!was);
              {
                let $t46620;
                {
                  const $t46619 = m.pull;
                  $t46620 = ($t46619 > 0.);
                }
                $t46621 = ($t46618 || $t46620);
              }
            }
            $t46622 = ($t46617 && $t46621);
          }
        }
        if ($t46622 === true) {
          {
            let $t46627;
            {
              let $t46626;
              {
                let $t46625;
                {
                  const $t46623 = m.pull;
                  {
                    const $t46624 = (dt * 1.3);
                    $t46625 = ($t46623 + $t46624);
                  }
                }
                {
                  const $t45799_i5387 = ($t46625 < 1.);
                  if ($t45799_i5387 === true) {
                    $t46626 = $t46625;
                  } else {
                    $t46626 = 1.;
                  }
                }
              }
              $t46627 = ({ ...m, pull: $t46626 });
            }
            {
              const $t46628 = { $: "Nil" };
              return { _0: $t46627, _1: $t46628 };
            }
          }
        } else {
          {
            let $t46635;
            {
              let $t46633;
              {
                let $t46630;
                {
                  const $t46629 = (!held);
                  $t46630 = (was && $t46629);
                }
                {
                  let $t46632;
                  {
                    const $t46631 = m.pull;
                    $t46632 = ($t46631 > 0.);
                  }
                  $t46633 = ($t46630 && $t46632);
                }
              }
              {
                let $t46634;
                $t46634 = Spin$Game$waiting(m);
                $t46635 = ($t46633 && $t46634);
              }
            }
            if ($t46635 === true) {
              {
                const $t46636 = m.pull;
                {
                  const m_i13187 = m;
                  {
                    let speed_i13190;
                    {
                      const $t46604_i13189 = (700. * $t46636);
                      speed_i13190 = (1050. + $t46604_i13189);
                    }
                    {
                      const $t46605_i13191 = m.balls;
                      {
                        const $t46610_i13192 = { $: "$Clo_$lam0_Spin_Game_fire$0_Spin_Game_fire", _0: $lam0_Spin_Game_fire$apply$0_Spin_Game_fire, _1: speed_i13190 };
                        {
                          let launched_i13193;
                          {
                            const xs_i14810 = $t46605_i13191;
                            {
                              const f_i14811 = $t46610_i13192;
                              switch (xs_i14810.$) {
                                case "Nil": {
                                  launched_i13193 = { $: "Nil" };
                                  break;
                                }
                                case "Cons": {
                                  const $f1006_i14812 = xs_i14810._0;
                                  const $f1007_i14813 = xs_i14810._1;
                                  {
                                    const t_i14814 = $f1007_i14813;
                                    {
                                      const h_i14815 = $f1006_i14812;
                                      {
                                        let $t1004_i14816;
                                        $t1004_i14816 = f_i14811._0(f_i14811, h_i14815);
                                        {
                                          const $trmc15_i14817 = { $: "Cons", _0: $t1004_i14816, _1: null };
                                          List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t_i14814, f_i14811, $trmc15_i14817);
                                          launched_i13193 = $trmc15_i14817;
                                        }
                                      }
                                    }
                                  }
                                  break;
                                }
                                default: {
                                  throw new Error("non-exhaustive pattern match");
                                  break;
                                }
                              }
                            }
                          }
                          {
                            const $t46611_i13194 = ({ ...m, balls: launched_i13193, pull: 0. });
                            {
                              const $t46612_i13195 = { $: "CueLaunch" };
                              {
                                const $t46613_i13196 = { $: "Nil" };
                                {
                                  const $t46614_i13197 = { $: "Cons", _0: $t46612_i13195, _1: $t46613_i13196 };
                                  return { _0: $t46611_i13194, _1: $t46614_i13197 };
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            } else {
              {
                let $t46639;
                {
                  let $t46638;
                  {
                    let $t46637;
                    $t46637 = Spin$Game$waiting(m);
                    if ($t46637 === true) {
                      $t46638 = m.pull;
                    } else {
                      $t46638 = 0.;
                    }
                  }
                  $t46639 = ({ ...m, pull: $t46638 });
                }
                {
                  const $t46640 = { $: "Nil" };
                  return { _0: $t46639, _1: $t46640 };
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$plunge$clo = { _0: ($_, m, input, dt) => Spin$Game$plunge(m, input, dt) };

function Spin$Game$auto_plunge(m) {
  {
    let lane_clear;
    {
      const $t46641 = m.balls;
      {
        const $t46645 = { $: "$Clo_$lam0_Spin_Game_auto_plunge$0_Spin_Game_auto_plunge", _0: $lam0_Spin_Game_auto_plunge$apply$0_Spin_Game_auto_plunge };
        lane_clear = List$all$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46641, $t46645);
      }
    }
    {
      let $t46648;
      {
        let $t46647;
        {
          const $t46646 = m.owed_balls;
          $t46647 = ($t46646 > 0);
        }
        $t46648 = ($t46647 && lane_clear);
      }
      if ($t46648 === true) {
        {
          let ball;
          {
            let $t46650;
            {
              const $t46649 = m.table;
              $t46650 = $t46649.plunger_rest;
            }
            {
              let $t46652;
              {
                const $t46651 = (-1650.);
                $t46652 = ({ x: 0., y: $t46651 });
              }
              ball = ({ pos: $t46650, vel: $t46652 });
            }
          }
          {
            let out;
            {
              let $t46657;
              {
                const $t46653 = m.balls;
                {
                  let $t46654;
                  $t46654 = { $: "Cons", _0: ball, _1: $t46653 };
                  {
                    let $t46656;
                    {
                      const $t46655 = m.owed_balls;
                      $t46656 = (($t46655 - 1) < 4611686018427387904 && ($t46655 - 1) >= -4611686018427387904 ? ($t46655 - 1) : march_int_ovf(($t46655 - 1), 1));
                    }
                    $t46657 = ({ ...m, balls: $t46654, owed_balls: $t46656 });
                  }
                }
              }
              {
                const $t46658 = { $: "CueLaunch" };
                {
                  const $t46659 = { $: "Nil" };
                  {
                    const $t46660 = { $: "Cons", _0: $t46658, _1: $t46659 };
                    out = { _0: $t46657, _1: $t46660 };
                  }
                }
              }
            }
            return out;
          }
        }
      } else {
        {
          const $t46661 = { $: "Nil" };
          return { _0: m, _1: $t46661 };
        }
      }
    }
  }
}
const Spin$Game$auto_plunge$clo = { _0: ($_, m) => Spin$Game$auto_plunge(m) };

function Spin$Game$step_balls($tco_a0, $tco_a1, $tco_a2, $tco_a3) {
  __tco: for (;;) {
    const m = $tco_a0;
    const input = $tco_a1;
    const steps = $tco_a2;
    const hits = $tco_a3;
    {
      const $t46662 = (steps <= 0);
      if ($t46662 === true) {
        return { _0: m, _1: hits };
      } else {
        {
          let l;
          {
            let $t46664;
            {
              const $t46663 = m.table;
              $t46664 = $t46663.left;
            }
            {
              const $t46665 = m.left;
              {
                const $t46666 = input.left;
                l = Spin$Physics$turn_flipper($t46664, $t46665, $t46666, 0.0025);
              }
            }
          }
          {
            let r;
            {
              let $t46668;
              {
                const $t46667 = m.table;
                $t46668 = $t46667.right;
              }
              {
                const $t46669 = m.right;
                {
                  const $t46670 = input.right;
                  r = Spin$Physics$turn_flipper($t46668, $t46669, $t46670, 0.0025);
                }
              }
            }
            {
              const $t46671 = m.balls;
              {
                let $t46677;
                $t46677 = { $: "$Clo_$lam0_Spin_Game_step_balls$0_Spin_Game_step_balls", _0: $lam0_Spin_Game_step_balls$apply$0_Spin_Game_step_balls, _1: 0.0025, _2: l, _3: m, _4: r };
                {
                  let moved;
                  {
                    const xs_i13221 = $t46671;
                    {
                      const f_i13222 = $t46677;
                      switch (xs_i13221.$) {
                        case "Nil": {
                          moved = { $: "Nil" };
                          break;
                        }
                        case "Cons": {
                          const $f1006_i13223 = xs_i13221._0;
                          const $f1007_i13224 = xs_i13221._1;
                          {
                            const t_i13225 = $f1007_i13224;
                            {
                              const h_i13226 = $f1006_i13223;
                              {
                                let $t1004_i13227;
                                $t1004_i13227 = f_i13222._0(f_i13222, h_i13226);
                                {
                                  const $trmc15_i13228 = { $: "Cons", _0: $t1004_i13227, _1: null };
                                  List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit(t_i13225, f_i13222, $trmc15_i13228);
                                  moved = $trmc15_i13228;
                                }
                              }
                            }
                          }
                          break;
                        }
                        default: {
                          throw new Error("non-exhaustive pattern match");
                          break;
                        }
                      }
                    }
                  }
                  {
                    const $t46680 = { $: "$Clo_$lam1_Spin_Game_step_balls$1_Spin_Game_step_balls", _0: $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls };
                    {
                      let balls;
                      {
                        const xs_i13213 = moved;
                        {
                          const f_i13214 = $t46680;
                          switch (xs_i13213.$) {
                            case "Nil": {
                              balls = { $: "Nil" };
                              break;
                            }
                            case "Cons": {
                              const $f1006_i13215 = xs_i13213._0;
                              const $f1007_i13216 = xs_i13213._1;
                              {
                                const t_i13217 = $f1007_i13216;
                                {
                                  const h_i13218 = $f1006_i13215;
                                  {
                                    let $t1004_i13219;
                                    $t1004_i13219 = f_i13214._0(f_i13214, h_i13218);
                                    {
                                      const $trmc15_i13220 = { $: "Cons", _0: $t1004_i13219, _1: null };
                                      List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t_i13217, f_i13214, $trmc15_i13220);
                                      balls = $trmc15_i13220;
                                    }
                                  }
                                }
                              }
                              break;
                            }
                            default: {
                              throw new Error("non-exhaustive pattern match");
                              break;
                            }
                          }
                        }
                      }
                      {
                        const $t46683 = { $: "$Clo_$lam2_Spin_Game_step_balls$2_Spin_Game_step_balls", _0: $lam2_Spin_Game_step_balls$apply$2_Spin_Game_step_balls };
                        {
                          let $t46684;
                          {
                            const xs_i13205 = moved;
                            {
                              const f_i13206 = $t46683;
                              switch (xs_i13205.$) {
                                case "Nil": {
                                  $t46684 = { $: "Nil" };
                                  break;
                                }
                                case "Cons": {
                                  const $f1006_i13207 = xs_i13205._0;
                                  const $f1007_i13208 = xs_i13205._1;
                                  {
                                    const t_i13209 = $f1007_i13208;
                                    {
                                      const h_i13210 = $f1006_i13207;
                                      {
                                        let $t1004_i13211;
                                        $t1004_i13211 = f_i13206._0(f_i13206, h_i13210);
                                        {
                                          const $trmc15_i13212 = { $: "Cons", _0: $t1004_i13211, _1: null };
                                          List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_List_Hit$List_List_Hit(t_i13209, f_i13206, $trmc15_i13212);
                                          $t46684 = $trmc15_i13212;
                                        }
                                      }
                                    }
                                  }
                                  break;
                                }
                                default: {
                                  throw new Error("non-exhaustive pattern match");
                                  break;
                                }
                              }
                            }
                          }
                          {
                            let new_hits;
                            {
                              const prepend_reversed_i5391 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Hit", _0: prepend_reversed$apply$0_List_concat_List_List_Hit };
                              {
                                const go_i5392 = { $: "$Clo_go$1_List_concat_List_List_Hit", _0: go$apply$1_List_concat_List_List_Hit, _1: prepend_reversed_i5391 };
                                {
                                  const $t1124_i5393 = { $: "Nil" };
                                  new_hits = go$apply$1_List_concat_List_List_Hit(go_i5392, $t46684, $t1124_i5393);
                                }
                              }
                            }
                            {
                              const next = ({ ...m, balls: balls, left: l, right: r });
                              {
                                const $t46685 = ((steps - 1) < 4611686018427387904 && (steps - 1) >= -4611686018427387904 ? (steps - 1) : march_int_ovf((steps - 1), 1));
                                {
                                  let $t46686;
                                  {
                                    const xs_i13198 = hits;
                                    {
                                      const ys_i13199 = new_hits;
                                      switch (xs_i13198.$) {
                                        case "Nil": {
                                          $t46686 = new_hits;
                                          break;
                                        }
                                        case "Cons": {
                                          const $f998_i13200 = xs_i13198._0;
                                          const $f999_i13201 = xs_i13198._1;
                                          {
                                            const t_i13202 = $f999_i13201;
                                            {
                                              const h_i13203 = $f998_i13200;
                                              {
                                                const $trmc11_i13204 = { $: "Cons", _0: h_i13203, _1: null };
                                                List$append$dps$List_Hit$List_Hit$List_Hit(t_i13202, new_hits, $trmc11_i13204);
                                                $t46686 = $trmc11_i13204;
                                              }
                                            }
                                          }
                                          break;
                                        }
                                        default: {
                                          throw new Error("non-exhaustive pattern match");
                                          break;
                                        }
                                      }
                                    }
                                  }
                                  {
                                    $tco_a0 = next;
                                    $tco_a1 = input;
                                    $tco_a2 = $t46685;
                                    $tco_a3 = $t46686;
                                    continue __tco;
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return undefined;
  }
}
const Spin$Game$step_balls$clo = { _0: ($_, m, input, steps, hits) => Spin$Game$step_balls(m, input, steps, hits) };

function Spin$Game$physics(m, input, dt) {
  {
    let total;
    {
      const $t46687 = m.carry;
      total = ($t46687 + dt);
    }
    {
      let steps;
      {
        let $t46689;
        {
          const $t46688 = (total / 0.0025);
          $t46689 = Math.floor($t46688);
        }
        {
          const $t2473_i5399 = ($t46689 < 40);
          if ($t2473_i5399 === true) {
            steps = $t46689;
          } else {
            steps = 40;
          }
        }
      }
      {
        let $p46696;
        {
          const $t46690 = { $: "Nil" };
          $p46696 = Spin$Game$step_balls(m, input, steps, $t46690);
        }
        {
          const moved = $p46696._0;
          {
            const hits = $p46696._1;
            {
              let $t46695;
              {
                let $t46694;
                {
                  let $t46693;
                  {
                    let $t46692;
                    {
                      const $t46691 = steps;
                      $t46692 = ($t46691 * 0.0025);
                    }
                    $t46693 = (total - $t46692);
                  }
                  {
                    const $t45798_i5396 = ($t46693 >= 0.);
                    if ($t45798_i5396 === true) {
                      $t46694 = $t46693;
                    } else {
                      $t46694 = 0.;
                    }
                  }
                }
                $t46695 = ({ ...moved, carry: $t46694 });
              }
              {
                const $rc_2583 = { _0: $t46695, _1: hits };
                return $rc_2583;
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$physics$clo = { _0: ($_, m, input, dt) => Spin$Game$physics(m, input, dt) };

function Spin$Game$drains(m) {
  {
    const $t46697 = m.balls;
    {
      let $t46703;
      $t46703 = { $: "$Clo_$lam0_Spin_Game_drains$0_Spin_Game_drains", _0: $lam0_Spin_Game_drains$apply$0_Spin_Game_drains, _1: m };
      {
        const kept = List$filter$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46697, $t46703);
        {
          let lost;
          {
            let $t46705;
            {
              const $t46704 = m.balls;
              {  };
              $t46705 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t46704, 0);
            }
            {
              let $t46706;
              {  };
              $t46706 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int(kept, 0);
              lost = (($t46705 - $t46706) < 4611686018427387904 && ($t46705 - $t46706) >= -4611686018427387904 ? ($t46705 - $t46706) : march_int_ovf(($t46705 - $t46706), 1));
            }
          }
          {
            const $t46707 = (lost === 0);
            if ($t46707 === true) {
              {
                const $t46708 = { $: "Nil" };
                return { _0: m, _1: $t46708 };
              }
            } else {
              {
                let $t46713;
                {
                  let $t46710;
                  {
                    let $t46709;
                    {  };
                    $t46709 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int(kept, 0);
                    $t46710 = ($t46709 > 0);
                  }
                  {
                    let $t46712;
                    {
                      const $t46711 = m.owed_balls;
                      $t46712 = ($t46711 > 0);
                    }
                    $t46713 = ($t46710 || $t46712);
                  }
                }
                if ($t46713 === true) {
                  {
                    const $t46714 = ({ ...m, balls: kept });
                    {
                      const $t46715 = { $: "CueDrain" };
                      {
                        const $t46716 = { $: "Nil" };
                        {
                          const $t46717 = { $: "Cons", _0: $t46715, _1: $t46716 };
                          return { _0: $t46714, _1: $t46717 };
                        }
                      }
                    }
                  }
                } else {
                  {
                    let fresh;
                    {
                      let $t46719;
                      {
                        const $t46718 = m.table;
                        $t46719 = Spin$Game$ball_at_plunger($t46718);
                      }
                      {
                        const $t46720 = { $: "Nil" };
                        {
                          const $t46721 = { $: "Cons", _0: $t46719, _1: $t46720 };
                          fresh = ({ ...m, balls: $t46721 });
                        }
                      }
                    }
                    {
                      let $t46726;
                      {
                        let $t46723;
                        {
                          const $t46722 = m.save_left;
                          $t46723 = ($t46722 > 0.);
                        }
                        {
                          let $t46725;
                          {
                            const $t46724 = { $: "SaveBuff" };
                            {
                              const $t46230_i5402 = Spin$Game$buff_left(m, $t46724);
                              $t46725 = ($t46230_i5402 > 0.);
                            }
                          }
                          $t46726 = ($t46723 || $t46725);
                        }
                      }
                      if ($t46726 === true) {
                        {
                          let $t46728;
                          {
                            const $t46727 = ({ ...fresh, save_left: 0. });
                            $t46728 = Spin$Game$say($t46727, "BALL SAVED", "on the house", 1.8, false);
                          }
                          {
                            const $t46729 = { $: "CueSaved" };
                            {
                              const $t46730 = { $: "Nil" };
                              {
                                const $t46731 = { $: "Cons", _0: $t46729, _1: $t46730 };
                                {
                                  const $rc_2588 = { _0: $t46728, _1: $t46731 };
                                  return $rc_2588;
                                }
                              }
                            }
                          }
                        }
                      } else {
                        {
                          let charged;
                          {
                            let $t46734;
                            {
                              const $t46732 = m.credits;
                              $t46734 = (($t46732 - 6) < 4611686018427387904 && ($t46732 - 6) >= -4611686018427387904 ? ($t46732 - 6) : march_int_ovf(($t46732 - 6), 1));
                            }
                            charged = ({ ...fresh, credits: $t46734, save_left: 8. });
                          }
                          {
                            let out;
                            {
                              let $t46739;
                              {
                                let $t46738;
                                {
                                  const $t46737 = String(6);
                                  {
                                    const $rc_2584 = march_string_concat3("-", $t46737, " CREDITS");
                                    $t46738 = $rc_2584;
                                  }
                                }
                                $t46739 = Spin$Game$say(charged, "DRAIN", $t46738, 1.8, false);
                              }
                              {
                                const $t46740 = { $: "CueDrain" };
                                {
                                  const $t46741 = { $: "Nil" };
                                  {
                                    const $t46742 = { $: "Cons", _0: $t46740, _1: $t46741 };
                                    out = { _0: $t46739, _1: $t46742 };
                                  }
                                }
                              }
                            }
                            return out;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$drains$clo = { _0: ($_, m) => Spin$Game$drains(m) };

function Spin$Game$burn(m, dt) {
  {
    let $t46743;
    {
      const m_i13229 = m;
      {
        const $t46221_i13230 = m.balls;
        {
          const $t46224_i13231 = { $: "$Clo_$lam0_Spin_Game_in_play$0_Spin_Game_in_play", _0: $lam0_Spin_Game_in_play$apply$0_Spin_Game_in_play };
          $t46743 = List$any$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46221_i13230, $t46224_i13231);
        }
      }
    }
    if ($t46743 === true) {
      {
        let every;
        {
          const $t46744 = m.alive;
          {
            const $t46745 = m.paid;
            {
              let $t46168_i5421;
              {
                let $t46167_i5420;
                {
                  let $t46166_i5419;
                  {
                    let $t46163_i5416;
                    {
                      const $t46162_i5415 = ($t46744 * 0.00385);
                      $t46163_i5416 = (0. - $t46162_i5415);
                    }
                    {
                      let $t46165_i5418;
                      {
                        const $t46164_i5417 = $t46745;
                        $t46165_i5418 = ($t46164_i5417 * 0.00462);
                      }
                      $t46166_i5419 = ($t46163_i5416 - $t46165_i5418);
                    }
                  }
                  $t46167_i5420 = Math.exp($t46166_i5419);
                }
                $t46168_i5421 = (2. * $t46167_i5420);
              }
              {
                const $t45798_i14591 = ($t46168_i5421 >= 0.05);
                if ($t45798_i14591 === true) {
                  every = $t46168_i5421;
                } else {
                  every = 0.05;
                }
              }
            }
          }
        }
        {
          let clock;
          {
            let $t46747;
            {
              const $t46746 = { $: "FreezeBuff" };
              {
                const $t46230_i5412 = Spin$Game$buff_left(m, $t46746);
                $t46747 = ($t46230_i5412 > 0.);
              }
            }
            if ($t46747 === true) {
              clock = m.burn_clock;
            } else {
              {
                const $t46748 = m.burn_clock;
                clock = ($t46748 + dt);
              }
            }
          }
          {
            let saving;
            {
              let $t46751;
              {
                let $t46750;
                {
                  const $t46749 = m.balls;
                  {  };
                  $t46750 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t46749, 0);
                }
                $t46751 = ($t46750 === 1);
              }
              if ($t46751 === true) {
                {
                  const $t46752 = m.save_left;
                  saving = ($t46752 - dt);
                }
              } else {
                saving = m.save_left;
              }
            }
            {
              let ticking;
              {
                let $t46754;
                {
                  const $t46753 = m.alive;
                  $t46754 = ($t46753 + dt);
                }
                {
                  let $t46755;
                  {
                    const $t45798_i5408 = (saving >= 0.);
                    if ($t45798_i5408 === true) {
                      $t46755 = saving;
                    } else {
                      $t46755 = 0.;
                    }
                  }
                  ticking = ({ ...m, alive: $t46754, save_left: $t46755 });
                }
              }
              {
                const $t46756 = (clock >= every);
                if ($t46756 === true) {
                  {
                    let c;
                    {
                      const $t46757 = m.credits;
                      c = (($t46757 - 1) < 4611686018427387904 && ($t46757 - 1) >= -4611686018427387904 ? ($t46757 - 1) : march_int_ovf(($t46757 - 1), 1));
                    }
                    {
                      let $t46759;
                      {
                        const $t46758 = (clock - every);
                        $t46759 = ({ ...ticking, burn_clock: $t46758, credits: c });
                      }
                      {
                        const $t46760 = { $: "CueBurn", _0: c };
                        {
                          const $t46761 = { $: "Nil" };
                          {
                            const $t46762 = { $: "Cons", _0: $t46760, _1: $t46761 };
                            {
                              const $rc_2592 = { _0: $t46759, _1: $t46762 };
                              return $rc_2592;
                            }
                          }
                        }
                      }
                    }
                  }
                } else {
                  {
                    const $t46763 = ({ ...ticking, burn_clock: clock });
                    {
                      const $t46764 = { $: "Nil" };
                      {
                        const $rc_2591 = { _0: $t46763, _1: $t46764 };
                        return $rc_2591;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } else {
      {
        const $t46765 = { $: "Nil" };
        return { _0: m, _1: $t46765 };
      }
    }
  }
}
const Spin$Game$burn$clo = { _0: ($_, m, dt) => Spin$Game$burn(m, dt) };

function Spin$Game$bust(m) {
  {
    let $t46767;
    {
      const $t46766 = m.credits;
      $t46767 = ($t46766 <= 0);
    }
    if ($t46767 === true) {
      {
        let best;
        {
          const $t46768 = m.best;
          {
            const $t46769 = m.paid;
            {
              const $t2474_i5424 = ($t46768 > $t46769);
              if ($t2474_i5424 === true) {
                best = $t46768;
              } else {
                best = $t46769;
              }
            }
          }
        }
        {
          let over;
          {
            const $t46770 = { $: "Busted" };
            {
              const $t46771 = { $: "Nil" };
              over = ({ ...m, mode: $t46770, credits: 0, best: best, balls: $t46771, owed_balls: 0 });
            }
          }
          {
            let out;
            {
              let $t46775;
              {
                let $t46774;
                {
                  let $t46773;
                  {
                    const $t46772 = m.paid;
                    $t46773 = String($t46772);
                  }
                  {
                    const $rc_2593 = ("the reels paid " + $t46773);
                    $t46774 = $rc_2593;
                  }
                }
                $t46775 = Spin$Game$say(over, "BUSTED", $t46774, 1000000., true);
              }
              {
                const $t46776 = { $: "CueBust" };
                {
                  const $t46777 = { $: "CueStore", _0: best };
                  {
                    const $t46778 = { $: "Nil" };
                    {
                      const $t46779 = { $: "Cons", _0: $t46777, _1: $t46778 };
                      {
                        const $t46780 = { $: "Cons", _0: $t46776, _1: $t46779 };
                        out = { _0: $t46775, _1: $t46780 };
                      }
                    }
                  }
                }
              }
            }
            return out;
          }
        }
      }
    } else {
      {
        const $t46781 = { $: "Nil" };
        return { _0: m, _1: $t46781 };
      }
    }
  }
}
const Spin$Game$bust$clo = { _0: ($_, m) => Spin$Game$bust(m) };

function Spin$Game$then_do(acc, f) {
  {
    const $p46784 = acc;
    {
      const m = acc._0;
      {
        const cues = acc._1;
        {
          let $p46783;
          $p46783 = f._0(f, m);
          {
            const n = $p46783._0;
            {
              const more = $p46783._1;
              {
                let $t46782;
                $t46782 = List$append$List_Cue$List_Cue(cues, more);
                {
                  const $rc_2595 = { _0: n, _1: $t46782 };
                  return $rc_2595;
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$then_do$clo = { _0: ($_, acc, f) => Spin$Game$then_do(acc, f) };

function Spin$Game$play(m, input, dt) {
  {
    let $t46795;
    {
      let $t46789;
      {
        const $t46785 = input.left;
        {
          let $t46788;
          {
            let $t46787;
            {
              const $t46786 = m.last;
              $t46787 = $t46786.left;
            }
            $t46788 = (!$t46787);
          }
          $t46789 = ($t46785 && $t46788);
        }
      }
      {
        let $t46794;
        {
          const $t46790 = input.right;
          {
            let $t46793;
            {
              let $t46792;
              {
                const $t46791 = m.last;
                $t46792 = $t46791.right;
              }
              $t46793 = (!$t46792);
            }
            $t46794 = ($t46790 && $t46793);
          }
        }
        $t46795 = ($t46789 || $t46794);
      }
    }
    {
      let flips;
      if ($t46795 === true) {
        {
          const $t46796 = { $: "CueFlip" };
          {
            const $t46797 = { $: "Nil" };
            flips = { $: "Cons", _0: $t46796, _1: $t46797 };
          }
        }
      } else {
        flips = { $: "Nil" };
      }
      {
        let $p46817;
        $p46817 = Spin$Game$plunge(m, input, dt);
        {
          const pulled = $p46817._0;
          {
            const c1 = $p46817._1;
            {
              let $p46816;
              $p46816 = Spin$Game$auto_plunge(pulled);
              {
                const shot = $p46816._0;
                {
                  const c2 = $p46816._1;
                  {
                    let $p46815;
                    {
                      let $t46800;
                      {
                        let $t46799;
                        {
                          const $t46798 = { $: "SlowBuff" };
                          {
                            const $t46230_i5431 = Spin$Game$buff_left(shot, $t46798);
                            $t46799 = ($t46230_i5431 > 0.);
                          }
                        }
                        if ($t46799 === true) {
                          $t46800 = (dt * 0.5);
                        } else {
                          $t46800 = dt;
                        }
                      }
                      $p46815 = Spin$Game$physics(shot, input, $t46800);
                    }
                    {
                      const moved = $p46815._0;
                      {
                        const hits = $p46815._1;
                        {
                          let touched;
                          {
                            const $t46801 = { $: "Nil" };
                            {
                              let $t46802;
                              $t46802 = { $: "Cons", _0: c2, _1: $t46801 };
                              {
                                let $t46803;
                                $t46803 = { $: "Cons", _0: c1, _1: $t46802 };
                                {
                                  const $t46804 = { $: "Cons", _0: flips, _1: $t46803 };
                                  {
                                    let $t46805;
                                    {
                                      const prepend_reversed_i5426 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Cue", _0: prepend_reversed$apply$0_List_concat_List_List_Cue };
                                      {
                                        const go_i5427 = { $: "$Clo_go$1_List_concat_List_List_Cue", _0: go$apply$1_List_concat_List_List_Cue, _1: prepend_reversed_i5426 };
                                        {
                                          const $t1124_i5428 = { $: "Nil" };
                                          $t46805 = go$apply$1_List_concat_List_List_Cue(go_i5427, $t46804, $t1124_i5428);
                                        }
                                      }
                                    }
                                    {
                                      let $t46806;
                                      $t46806 = { _0: moved, _1: $t46805 };
                                      touched = List$fold_left$List_Hit$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue_Hit_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue(hits, $t46806, Spin$Game$touch$clo);
                                    }
                                  }
                                }
                              }
                            }
                          }
                          {
                            const $p46814 = touched;
                            {
                              const m1 = touched._0;
                              {
                                const c3 = touched._1;
                                {
                                  let $p46813;
                                  {
                                    const $t46807 = m1.bank;
                                    {
                                      const $t46808 = m1.rng;
                                      $p46813 = Spin$Reels$tick($t46807, $t46808, dt);
                                    }
                                  }
                                  {
                                    const bank = $p46813._0;
                                    {
                                      const rng = $p46813._1;
                                      {
                                        const evs = $p46813._2;
                                        {
                                          let reeled;
                                          {
                                            let $t46809;
                                            $t46809 = ({ ...m1, rng: rng, bank: bank });
                                            {
                                              let $t46810;
                                              $t46810 = { _0: $t46809, _1: c3 };
                                              reeled = List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue(evs, $t46810, Spin$Game$reel_news$clo);
                                            }
                                          }
                                          {
                                            const drained = Spin$Game$then_do(reeled, Spin$Game$drains$clo);
                                            {
                                              let burned;
                                              {
                                                const $t46812 = { $: "$Clo_$lam0_Spin_Game_play$0_Spin_Game_play", _0: $lam0_Spin_Game_play$apply$0_Spin_Game_play, _1: dt };
                                                burned = Spin$Game$then_do(drained, $t46812);
                                              }
                                              return Spin$Game$then_do(burned, Spin$Game$bust$clo);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$play$clo = { _0: ($_, m, input, dt) => Spin$Game$play(m, input, dt) };

function Spin$Game$tick(m, input, dt0) {
  {
    let dt;
    {
      let $t45800_i5435;
      {
        const $t45798_i14598 = (0. >= dt0);
        if ($t45798_i14598 === true) {
          $t45800_i5435 = 0.;
        } else {
          $t45800_i5435 = dt0;
        }
      }
      {
        const $t45799_i14595 = (0.05 < $t45800_i5435);
        if ($t45799_i14595 === true) {
          dt = 0.05;
        } else {
          dt = $t45800_i5435;
        }
      }
    }
    {
      let dimmed;
      dimmed = Spin$Game$fade(m, dt);
      {
        let faded;
        {
          let $t46819;
          {
            const $t46818 = m.clock;
            $t46819 = ($t46818 + dt);
          }
          faded = ({ ...dimmed, clock: $t46819 });
        }
        {
          let pressed_start;
          {
            let $t46824;
            {
              const $t46820 = input.start;
              {
                let $t46823;
                {
                  let $t46822;
                  {
                    const $t46821 = m.last;
                    $t46822 = $t46821.start;
                  }
                  $t46823 = (!$t46822);
                }
                $t46824 = ($t46820 && $t46823);
              }
            }
            {
              let $t46829;
              {
                const $t46825 = input.launch;
                {
                  let $t46828;
                  {
                    let $t46827;
                    {
                      const $t46826 = m.last;
                      $t46827 = $t46826.launch;
                    }
                    $t46828 = (!$t46827);
                  }
                  $t46829 = ($t46825 && $t46828);
                }
              }
              pressed_start = ($t46824 || $t46829);
            }
          }
          {
            let $p46846;
            {
              const $t46830 = faded.mode;
              switch ($t46830.$) {
                case "Playing": {
                  $p46846 = Spin$Game$play(faded, input, dt);
                  break;
                }
                case "Attract": {
                  if (pressed_start === true) {
                    {
                      const $t46831 = Spin$Game$new_game(faded);
                      {
                        const $t46832 = { $: "CueStart" };
                        {
                          const $t46833 = { $: "Nil" };
                          {
                            const $t46834 = { $: "Cons", _0: $t46832, _1: $t46833 };
                            $p46846 = { _0: $t46831, _1: $t46834 };
                          }
                        }
                      }
                    }
                  } else {
                    {
                      const $t46835 = { $: "Nil" };
                      $p46846 = { _0: faded, _1: $t46835 };
                    }
                  }
                  break;
                }
                case "Busted": {
                  {
                    let $t46839;
                    {
                      let $t46838;
                      {
                        let $t46837;
                        {
                          const $t46836 = faded.banner;
                          $t46837 = $t46836.left;
                        }
                        $t46838 = ($t46837 < 999998.);
                      }
                      $t46839 = (pressed_start && $t46838);
                    }
                    if ($t46839 === true) {
                      {
                        const $t46840 = Spin$Game$new_game(faded);
                        {
                          const $t46841 = { $: "CueStart" };
                          {
                            const $t46842 = { $: "Nil" };
                            {
                              const $t46843 = { $: "Cons", _0: $t46841, _1: $t46842 };
                              $p46846 = { _0: $t46840, _1: $t46843 };
                            }
                          }
                        }
                      }
                    } else {
                      {
                        const $t46844 = { $: "Nil" };
                        $p46846 = { _0: faded, _1: $t46844 };
                      }
                    }
                  }
                  break;
                }
                default: {
                  throw new Error("non-exhaustive pattern match");
                  break;
                }
              }
            }
            {
              const next = $p46846._0;
              {
                const cues = $p46846._1;
                {
                  let $t46845;
                  $t46845 = ({ ...next, last: input });
                  {
                    const $rc_2599 = { _0: $t46845, _1: cues };
                    return $rc_2599;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Game$tick$clo = { _0: ($_, m, input, dt0) => Spin$Game$tick(m, input, dt0) };

function Spin$Physics$resting(spec) {
  {
    const $t46847 = spec.rest;
    return ({ angle: $t46847, omega: 0. });
  }
}
const Spin$Physics$resting$clo = { _0: ($_, spec) => Spin$Physics$resting(spec) };

function Spin$Physics$turn_flipper(spec, f, pressed, h) {
  {
    let target;
    if (pressed === true) {
      target = spec.up;
    } else {
      target = spec.rest;
    }
    {
      let rate;
      if (pressed === true) {
        rate = 26.;
      } else {
        rate = 14.;
      }
      {
        let gap;
        {
          const $t46848 = f.angle;
          gap = (target - $t46848);
        }
        {
          const most = (rate * h);
          {
            let moved;
            {
              const $t46849 = (-most);
              {
                let $t45800_i5439;
                {
                  const $t45798_i14604 = ($t46849 >= gap);
                  if ($t45798_i14604 === true) {
                    $t45800_i5439 = $t46849;
                  } else {
                    $t45800_i5439 = gap;
                  }
                }
                {
                  const $t45799_i14601 = (most < $t45800_i5439);
                  if ($t45799_i14601 === true) {
                    moved = most;
                  } else {
                    moved = $t45800_i5439;
                  }
                }
              }
            }
            {
              let $t46851;
              {
                const $t46850 = f.angle;
                $t46851 = ($t46850 + moved);
              }
              {
                const $t46852 = (moved / h);
                return ({ angle: $t46851, omega: $t46852 });
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Physics$turn_flipper$clo = { _0: ($_, spec, f, pressed, h) => Spin$Physics$turn_flipper(spec, f, pressed, h) };

function Spin$Physics$closest(a, b, p) {
  {
    let ab;
    ab = Arcade$Vec2$sub(b, a);
    {
      let l2;
      l2 = Arcade$Vec2$dot(ab, ab);
      {
        const $t46853 = (l2 > 0.);
        if ($t46853 === true) {
          {
            let $t46858;
            {
              let $t46857;
              {
                let $t46856;
                {
                  let $t46855;
                  {
                    let $t46854;
                    $t46854 = Arcade$Vec2$sub(p, a);
                    $t46855 = Arcade$Vec2$dot($t46854, ab);
                  }
                  $t46856 = ($t46855 / l2);
                }
                {
                  let $t45800_i5443;
                  {
                    const $t45798_i14610 = (0. >= $t46856);
                    if ($t45798_i14610 === true) {
                      $t45800_i5443 = 0.;
                    } else {
                      $t45800_i5443 = $t46856;
                    }
                  }
                  {
                    const $t45799_i14607 = (1. < $t45800_i5443);
                    if ($t45799_i14607 === true) {
                      $t46857 = 1.;
                    } else {
                      $t46857 = $t45800_i5443;
                    }
                  }
                }
              }
              $t46858 = Arcade$Vec2$scale(ab, $t46857);
            }
            return Arcade$Vec2$add(a, $t46858);
          }
        } else {
          return a;
        }
      }
    }
  }
}
const Spin$Physics$closest$clo = { _0: ($_, a, b, p) => Spin$Physics$closest(a, b, p) };

function Spin$Physics$contact(b, q, reach, e, u) {
  {
    let d;
    {
      const $t46859 = b.pos;
      d = Arcade$Vec2$sub($t46859, q);
    }
    {
      let dist;
      dist = Arcade$Vec2$length(d);
      {
        let $t46862;
        {
          const $t46860 = (dist >= reach);
          {
            const $t46861 = (dist === 0.);
            $t46862 = ($t46860 || $t46861);
          }
        }
        if ($t46862 === true) {
          return { $: "None" };
        } else {
          {
            let n;
            {
              const $t46863 = (1. / dist);
              n = Arcade$Vec2$scale(d, $t46863);
            }
            {
              let pos;
              {
                let $t46864;
                $t46864 = Arcade$Vec2$scale(n, reach);
                pos = Arcade$Vec2$add(q, $t46864);
              }
              {
                let rel;
                {
                  const $t46865 = b.vel;
                  rel = Arcade$Vec2$sub($t46865, u);
                }
                {
                  let vn;
                  vn = Arcade$Vec2$dot(rel, n);
                  {
                    const $t46866 = (vn < 0.);
                    if ($t46866 === true) {
                      {
                        let $t46872;
                        {
                          let $t46871;
                          {
                            let $t46870;
                            {
                              let $t46869;
                              {
                                let $t46868;
                                {
                                  const $t46867 = (1. + e);
                                  $t46868 = ($t46867 * vn);
                                }
                                $t46869 = Arcade$Vec2$scale(n, $t46868);
                              }
                              $t46870 = Arcade$Vec2$sub(rel, $t46869);
                            }
                            $t46871 = Arcade$Vec2$add($t46870, u);
                          }
                          $t46872 = ({ pos: pos, vel: $t46871 });
                        }
                        {
                          const $t46873 = (-vn);
                          {
                            const $t46874 = { _0: $t46872, _1: n, _2: $t46873 };
                            return { $: "Some", _0: $t46874 };
                          }
                        }
                      }
                    } else {
                      {
                        let $t46876;
                        {
                          const $t46875 = b.vel;
                          $t46876 = ({ pos: pos, vel: $t46875 });
                        }
                        {
                          const $t46877 = { _0: $t46876, _1: n, _2: 0. };
                          return { $: "Some", _0: $t46877 };
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Physics$contact$clo = { _0: ($_, b, q, reach, e, u) => Spin$Physics$contact(b, q, reach, e, u) };

function Spin$Physics$throw_off(b, n, least) {
  {
    let vn;
    {
      const $t46878 = b.vel;
      vn = Arcade$Vec2$dot($t46878, n);
    }
    {
      const $t46879 = (vn < least);
      if ($t46879 === true) {
        {
          let $t46883;
          {
            const $t46880 = b.vel;
            {
              let $t46882;
              {
                const $t46881 = (least - vn);
                $t46882 = Arcade$Vec2$scale(n, $t46881);
              }
              $t46883 = Arcade$Vec2$add($t46880, $t46882);
            }
          }
          {
            const $rc_2602 = ({ ...b, vel: $t46883 });
            return $rc_2602;
          }
        }
      } else {
        return b;
      }
    }
  }
}
const Spin$Physics$throw_off$clo = { _0: ($_, b, n, least) => Spin$Physics$throw_off(b, n, least) };

function Spin$Physics$side(o, s, t) {
  {
    let $t46890;
    {
      let $t46886;
      {
        const $t46884 = s.x;
        {
          const $t46885 = o.x;
          $t46886 = ($t46884 - $t46885);
        }
      }
      {
        let $t46889;
        {
          const $t46887 = t.y;
          {
            const $t46888 = o.y;
            $t46889 = ($t46887 - $t46888);
          }
        }
        $t46890 = ($t46886 * $t46889);
      }
    }
    {
      let $t46897;
      {
        let $t46893;
        {
          const $t46891 = s.y;
          {
            const $t46892 = o.y;
            $t46893 = ($t46891 - $t46892);
          }
        }
        {
          let $t46896;
          {
            const $t46894 = t.x;
            {
              const $t46895 = o.x;
              $t46896 = ($t46894 - $t46895);
            }
          }
          $t46897 = ($t46893 * $t46896);
        }
      }
      return ($t46890 - $t46897);
    }
  }
}
const Spin$Physics$side$clo = { _0: ($_, o, s, t) => Spin$Physics$side(o, s, t) };

function Spin$Physics$crosses(p, q, a, b) {
  {
    let d1;
    d1 = Spin$Physics$side(a, b, p);
    {
      let d2;
      d2 = Spin$Physics$side(a, b, q);
      {
        let d3;
        d3 = Spin$Physics$side(p, q, a);
        {
          const d4 = Spin$Physics$side(p, q, b);
          {
            let $t46904;
            {
              let $t46900;
              {
                const $t46898 = (d1 > 0.);
                {
                  const $t46899 = (d2 <= 0.);
                  $t46900 = ($t46898 && $t46899);
                }
              }
              {
                let $t46903;
                {
                  const $t46901 = (d1 <= 0.);
                  {
                    const $t46902 = (d2 > 0.);
                    $t46903 = ($t46901 && $t46902);
                  }
                }
                $t46904 = ($t46900 || $t46903);
              }
            }
            {
              let $t46911;
              {
                let $t46907;
                {
                  const $t46905 = (d3 > 0.);
                  {
                    const $t46906 = (d4 <= 0.);
                    $t46907 = ($t46905 && $t46906);
                  }
                }
                {
                  let $t46910;
                  {
                    const $t46908 = (d3 <= 0.);
                    {
                      const $t46909 = (d4 > 0.);
                      $t46910 = ($t46908 && $t46909);
                    }
                  }
                  $t46911 = ($t46907 || $t46910);
                }
              }
              return ($t46904 && $t46911);
            }
          }
        }
      }
    }
  }
}
const Spin$Physics$crosses$clo = { _0: ($_, p, q, a, b) => Spin$Physics$crosses(p, q, a, b) };

function Spin$Physics$springy(w, e) {
  {
    let $t46913;
    {
      const $t46912 = w.bounce;
      $t46913 = (e + $t46912);
    }
    {
      let $t45800_i5447;
      {
        const $t45798_i14616 = (0.05 >= $t46913);
        if ($t45798_i14616 === true) {
          $t45800_i5447 = 0.05;
        } else {
          $t45800_i5447 = $t46913;
        }
      }
      {
        const $t45799_i14613 = (0.92 < $t45800_i5447);
        if ($t45799_i14613 === true) {
          return 0.92;
        } else {
          return $t45800_i5447;
        }
      }
    }
  }
}
const Spin$Physics$springy$clo = { _0: ($_, w, e) => Spin$Physics$springy(w, e) };

function Spin$Physics$against(w, r, before, acc, part) {
  {
    let $p47165;
    $p47165 = acc;
    {
      const b = $p47165._0;
      {
        const hits = $p47165._1;
        switch (part.$) {
          case "Wall": {
            const $f47067 = part._0;
            const $f47068 = part._1;
            const $f47069 = part._2;
            {
              const e = $f47069;
              {
                const c = $f47068;
                {
                  const a = $f47067;
                  {
                    let $t46918;
                    {
                      let $t46915;
                      {
                        const $t46914 = b.pos;
                        $t46915 = Spin$Physics$closest(a, c, $t46914);
                      }
                      {
                        const $t46916 = Spin$Physics$springy(w, e);
                        {
                          const $t46917 = ({ x: 0., y: 0. });
                          $t46918 = Spin$Physics$contact(b, $t46915, r, $t46916, $t46917);
                        }
                      }
                    }
                    switch ($t46918.$) {
                      case "Some": {
                        const $f46923 = $t46918._0;
                        const $f46924 = $f46923._0;
                        const $f46925 = $f46923._1;
                        const $f46926 = $f46923._2;
                        {
                          const speed = $f46926;
                          {
                            const nb = $f46924;
                            {
                              let $t46921;
                              {
                                const $t46919 = { $: "Plain" };
                                {
                                  const $t46920 = nb.pos;
                                  $t46921 = { $: "Touched", _0: $t46919, _1: speed, _2: $t46920 };
                                }
                              }
                              {
                                let $t46922;
                                $t46922 = { $: "Cons", _0: $t46921, _1: hits };
                                {
                                  const $rc_2630 = { _0: nb, _1: $t46922 };
                                  return $rc_2630;
                                }
                              }
                            }
                          }
                        }
                        break;
                      }
                      case "None": {
                        return acc;
                        break;
                      }
                      default: {
                        return (() => { throw new Error("non-exhaustive pattern match"); })();
                      }
                    }
                  }
                }
              }
            }
            break;
          }
          case "Peg": {
            const $f47078 = part._0;
            const $f47079 = part._1;
            const $f47080 = part._2;
            {
              const e = $f47080;
              {
                const pr = $f47079;
                {
                  const c = $f47078;
                  {
                    let $t46938;
                    {
                      const $t46935 = (r + pr);
                      {
                        const $t46936 = Spin$Physics$springy(w, e);
                        {
                          const $t46937 = ({ x: 0., y: 0. });
                          $t46938 = Spin$Physics$contact(b, c, $t46935, $t46936, $t46937);
                        }
                      }
                    }
                    switch ($t46938.$) {
                      case "Some": {
                        const $f46943 = $t46938._0;
                        const $f46944 = $f46943._0;
                        const $f46945 = $f46943._1;
                        const $f46946 = $f46943._2;
                        {
                          const speed = $f46946;
                          {
                            const nb = $f46944;
                            {
                              let $t46941;
                              {
                                const $t46939 = { $: "Plain" };
                                {
                                  const $t46940 = nb.pos;
                                  $t46941 = { $: "Touched", _0: $t46939, _1: speed, _2: $t46940 };
                                }
                              }
                              {
                                let $t46942;
                                $t46942 = { $: "Cons", _0: $t46941, _1: hits };
                                {
                                  const $rc_2632 = { _0: nb, _1: $t46942 };
                                  return $rc_2632;
                                }
                              }
                            }
                          }
                        }
                        break;
                      }
                      case "None": {
                        return acc;
                        break;
                      }
                      default: {
                        return (() => { throw new Error("non-exhaustive pattern match"); })();
                      }
                    }
                  }
                }
              }
            }
            break;
          }
          case "Kicker": {
            const $f47089 = part._0;
            const $f47090 = part._1;
            const $f47091 = part._2;
            {
              const f = $f47091;
              {
                const kr = $f47090;
                {
                  const c = $f47089;
                  {
                    let $t46958;
                    {
                      const $t46955 = (r + kr);
                      {
                        const $t46956 = Spin$Physics$springy(w, 0.6);
                        {
                          const $t46957 = ({ x: 0., y: 0. });
                          $t46958 = Spin$Physics$contact(b, c, $t46955, $t46956, $t46957);
                        }
                      }
                    }
                    switch ($t46958.$) {
                      case "Some": {
                        const $f46964 = $t46958._0;
                        const $f46965 = $f46964._0;
                        const $f46966 = $f46964._1;
                        const $f46967 = $f46964._2;
                        {
                          const speed = $f46967;
                          {
                            const n = $f46966;
                            {
                              const nb = $f46965;
                              {
                                let $t46960;
                                $t46960 = Spin$Physics$throw_off(nb, n, 620.);
                                {
                                  let $t46962;
                                  {
                                    const $t46961 = nb.pos;
                                    $t46962 = { $: "Touched", _0: f, _1: speed, _2: $t46961 };
                                  }
                                  {
                                    let $t46963;
                                    $t46963 = { $: "Cons", _0: $t46962, _1: hits };
                                    {
                                      const $rc_2604 = { _0: $t46960, _1: $t46963 };
                                      return $rc_2604;
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                        break;
                      }
                      case "None": {
                        return acc;
                        break;
                      }
                      default: {
                        return (() => { throw new Error("non-exhaustive pattern match"); })();
                      }
                    }
                  }
                }
              }
            }
            break;
          }
          case "Mover": {
            const $f47100 = part._0;
            const $f47101 = part._1;
            const $f47102 = part._2;
            const $f47103 = part._3;
            const $f47104 = part._4;
            {
              const f = $f47104;
              {
                const period = $f47103;
                {
                  const mr = $f47102;
                  {
                    const c = $f47101;
                    {
                      const a = $f47100;
                      {
                        let $p47000;
                        {
                          const $t46976 = w.clock;
                          {
                            const $t46977 = w.num;
                            $p47000 = Spin$Table$mover_at(a, c, period, $t46976, $t46977);
                          }
                        }
                        {
                          const at = $p47000._0;
                          {
                            const u = $p47000._1;
                            {
                              let $t46980;
                              {
                                const $t46978 = (r + mr);
                                {
                                  const $t46979 = Spin$Physics$springy(w, 0.6);
                                  $t46980 = Spin$Physics$contact(b, at, $t46978, $t46979, u);
                                }
                              }
                              switch ($t46980.$) {
                                case "Some": {
                                  const $f46988 = $t46980._0;
                                  const $f46989 = $f46988._0;
                                  const $f46990 = $f46988._1;
                                  const $f46991 = $f46988._2;
                                  {
                                    const speed = $f46991;
                                    {
                                      const n = $f46990;
                                      {
                                        const nb = $f46989;
                                        {
                                          let $t46984;
                                          {
                                            let $t46983;
                                            {
                                              let $t46982;
                                              $t46982 = Arcade$Vec2$dot(u, n);
                                              $t46983 = (620. + $t46982);
                                            }
                                            $t46984 = Spin$Physics$throw_off(nb, n, $t46983);
                                          }
                                          {
                                            let $t46986;
                                            {
                                              const $t46985 = nb.pos;
                                              $t46986 = { $: "Touched", _0: f, _1: speed, _2: $t46985 };
                                            }
                                            {
                                              let $t46987;
                                              $t46987 = { $: "Cons", _0: $t46986, _1: hits };
                                              {
                                                const $rc_2606 = { _0: $t46984, _1: $t46987 };
                                                return $rc_2606;
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  break;
                                }
                                case "None": {
                                  return acc;
                                  break;
                                }
                                default: {
                                  return (() => { throw new Error("non-exhaustive pattern match"); })();
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            break;
          }
          case "Face": {
            const $f47121 = part._0;
            const $f47122 = part._1;
            const $f47123 = part._2;
            const $f47124 = part._3;
            {
              const f = $f47124;
              {
                const kick = $f47123;
                {
                  const c = $f47122;
                  {
                    const a = $f47121;
                    {
                      let e;
                      {
                        const $t47001 = (kick > 0.);
                        if ($t47001 === true) {
                          e = 0.4;
                        } else {
                          e = 0.55;
                        }
                      }
                      {
                        let $t47006;
                        {
                          let $t47003;
                          {
                            const $t47002 = b.pos;
                            $t47003 = Spin$Physics$closest(a, c, $t47002);
                          }
                          {
                            const $t47004 = Spin$Physics$springy(w, e);
                            {
                              const $t47005 = ({ x: 0., y: 0. });
                              $t47006 = Spin$Physics$contact(b, $t47003, r, $t47004, $t47005);
                            }
                          }
                        }
                        switch ($t47006.$) {
                          case "Some": {
                            const $f47016 = $t47006._0;
                            const $f47017 = $f47016._0;
                            const $f47018 = $f47016._1;
                            const $f47019 = $f47016._2;
                            {
                              const speed = $f47019;
                              {
                                const n = $f47018;
                                {
                                  const nb = $f47017;
                                  {
                                    let thrown;
                                    {
                                      let $t47009;
                                      {
                                        const $t47007 = (kick > 0.);
                                        {
                                          const $t47008 = (speed > 80.);
                                          $t47009 = ($t47007 && $t47008);
                                        }
                                      }
                                      if ($t47009 === true) {
                                        {
                                          let $t47012;
                                          {
                                            const $t47010 = nb.vel;
                                            {
                                              const $t47011 = Arcade$Vec2$scale(n, kick);
                                              $t47012 = Arcade$Vec2$add($t47010, $t47011);
                                            }
                                          }
                                          thrown = ({ ...nb, vel: $t47012 });
                                        }
                                      } else {
                                        thrown = nb;
                                      }
                                    }
                                    {
                                      let $t47014;
                                      {
                                        const $t47013 = nb.pos;
                                        $t47014 = { $: "Touched", _0: f, _1: speed, _2: $t47013 };
                                      }
                                      {
                                        let $t47015;
                                        $t47015 = { $: "Cons", _0: $t47014, _1: hits };
                                        {
                                          const $rc_2612 = { _0: thrown, _1: $t47015 };
                                          return $rc_2612;
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            break;
                          }
                          case "None": {
                            return acc;
                            break;
                          }
                          default: {
                            return (() => { throw new Error("non-exhaustive pattern match"); })();
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            break;
          }
          case "Gate": {
            const $f47137 = part._0;
            const $f47138 = part._1;
            {
              const c = $f47138;
              {
                const a = $f47137;
                {
                  let $t47030;
                  {
                    let $t47029;
                    {
                      const $t47028 = b.vel;
                      $t47029 = $t47028.y;
                    }
                    $t47030 = ($t47029 > 0.);
                  }
                  if ($t47030 === true) {
                    {
                      let $t47034;
                      {
                        let $t47032;
                        {
                          const $t47031 = b.pos;
                          $t47032 = Spin$Physics$closest(a, c, $t47031);
                        }
                        {
                          const $t47033 = ({ x: 0., y: 0. });
                          $t47034 = Spin$Physics$contact(b, $t47032, r, 0.3, $t47033);
                        }
                      }
                      switch ($t47034.$) {
                        case "Some": {
                          const $f47039 = $t47034._0;
                          const $f47040 = $f47039._0;
                          const $f47041 = $f47039._1;
                          const $f47042 = $f47039._2;
                          {
                            const speed = $f47042;
                            {
                              const nb = $f47040;
                              {
                                let $t47037;
                                {
                                  const $t47035 = { $: "Plain" };
                                  {
                                    const $t47036 = nb.pos;
                                    $t47037 = { $: "Touched", _0: $t47035, _1: speed, _2: $t47036 };
                                  }
                                }
                                {
                                  let $t47038;
                                  $t47038 = { $: "Cons", _0: $t47037, _1: hits };
                                  {
                                    const $rc_2641 = { _0: nb, _1: $t47038 };
                                    return $rc_2641;
                                  }
                                }
                              }
                            }
                          }
                          break;
                        }
                        case "None": {
                          return acc;
                          break;
                        }
                        default: {
                          return (() => { throw new Error("non-exhaustive pattern match"); })();
                        }
                      }
                    }
                  } else {
                    return acc;
                  }
                }
              }
            }
            break;
          }
          case "Sensor": {
            const $f47143 = part._0;
            const $f47144 = part._1;
            const $f47145 = part._2;
            {
              const f = $f47145;
              {
                const sr = $f47144;
                {
                  const c = $f47143;
                  {
                    let $t47058;
                    {
                      let $t47054;
                      {
                        let $t47053;
                        {
                          let $t47052;
                          {
                            const $t47051 = b.pos;
                            $t47052 = Arcade$Vec2$sub($t47051, c);
                          }
                          $t47053 = Arcade$Vec2$length($t47052);
                        }
                        $t47054 = ($t47053 < sr);
                      }
                      {
                        let $t47057;
                        {
                          let $t47056;
                          {
                            const $t47055 = Arcade$Vec2$sub(before, c);
                            $t47056 = Arcade$Vec2$length($t47055);
                          }
                          $t47057 = ($t47056 >= sr);
                        }
                        $t47058 = ($t47054 && $t47057);
                      }
                    }
                    if ($t47058 === true) {
                      {
                        let $t47060;
                        {
                          const $t47059 = b.pos;
                          $t47060 = { $: "Touched", _0: f, _1: 0., _2: $t47059 };
                        }
                        {
                          let $t47061;
                          $t47061 = { $: "Cons", _0: $t47060, _1: hits };
                          {
                            const $rc_2644 = { _0: b, _1: $t47061 };
                            return $rc_2644;
                          }
                        }
                      }
                    } else {
                      return acc;
                    }
                  }
                }
              }
            }
            break;
          }
          case "Tripwire": {
            const $f47154 = part._0;
            const $f47155 = part._1;
            const $f47156 = part._2;
            {
              const f = $f47156;
              {
                const c = $f47155;
                {
                  const a = $f47154;
                  {
                    let $t47063;
                    {
                      const $t47062 = b.pos;
                      $t47063 = Spin$Physics$crosses(before, $t47062, a, c);
                    }
                    if ($t47063 === true) {
                      {
                        let $t47065;
                        {
                          const $t47064 = b.pos;
                          $t47065 = { $: "Touched", _0: f, _1: 0., _2: $t47064 };
                        }
                        {
                          let $t47066;
                          $t47066 = { $: "Cons", _0: $t47065, _1: hits };
                          {
                            const $rc_2646 = { _0: b, _1: $t47066 };
                            return $rc_2646;
                          }
                        }
                      }
                    } else {
                      return acc;
                    }
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
  }
}
const Spin$Physics$against$clo = { _0: ($_, w, r, before, acc, part) => Spin$Physics$against(w, r, before, acc, part) };

function Spin$Physics$against_flipper(r, spec, f, acc) {
  {
    let $p47195;
    $p47195 = acc;
    {
      const b = $p47195._0;
      {
        const hits = $p47195._1;
        {
          let q;
          {
            const $t47166 = spec.pivot;
            {
              let $t47168;
              {
                const $t47167 = f.angle;
                $t47168 = Spin$Table$tip(spec, $t47167);
              }
              {
                const $t47169 = b.pos;
                q = Spin$Physics$closest($t47166, $t47168, $t47169);
              }
            }
          }
          {
            let arm;
            {
              const $t47170 = spec.pivot;
              arm = Arcade$Vec2$sub(q, $t47170);
            }
            {
              let u;
              {
                let $t47174;
                {
                  let $t47172;
                  {
                    const $t47171 = f.omega;
                    $t47172 = (-$t47171);
                  }
                  {
                    const $t47173 = arm.y;
                    $t47174 = ($t47172 * $t47173);
                  }
                }
                {
                  let $t47177;
                  {
                    const $t47175 = f.omega;
                    {
                      const $t47176 = arm.x;
                      $t47177 = ($t47175 * $t47176);
                    }
                  }
                  u = ({ x: $t47174, y: $t47177 });
                }
              }
              {
                let $t47180;
                {
                  let $t47179;
                  {
                    const $t47178 = spec.radius;
                    $t47179 = (r + $t47178);
                  }
                  $t47180 = Spin$Physics$contact(b, q, $t47179, 0.3, u);
                }
                switch ($t47180.$) {
                  case "Some": {
                    const $f47183 = $t47180._0;
                    const $f47184 = $f47183._0;
                    const $f47185 = $f47183._1;
                    const $f47186 = $f47183._2;
                    {
                      const speed = $f47186;
                      {
                        const nb = $f47184;
                        {
                          const $t47181 = { $: "Flipped", _0: speed };
                          {
                            let $t47182;
                            $t47182 = { $: "Cons", _0: $t47181, _1: hits };
                            {
                              const $rc_2649 = { _0: nb, _1: $t47182 };
                              return $rc_2649;
                            }
                          }
                        }
                      }
                    }
                    break;
                  }
                  case "None": {
                    {
                      let $rc_2650;
                      $rc_2650 = acc;
                      return $rc_2650;
                    }
                    break;
                  }
                  default: {
                    return (() => { throw new Error("non-exhaustive pattern match"); })();
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Physics$against_flipper$clo = { _0: ($_, r, spec, f, acc) => Spin$Physics$against_flipper(r, spec, f, acc) };

function Spin$Physics$push(s, clock, p) {
  {
    let wind;
    {
      let $t47203;
      {
        const $t47200 = s.wind;
        {
          let $t47202;
          {
            const $t47201 = (clock * 1.9);
            $t47202 = Math.sin($t47201);
          }
          $t47203 = ($t47200 * $t47202);
        }
      }
      {
        let $t47207;
        {
          let $t47206;
          {
            let $t47205;
            {
              const $t47204 = (clock * 0.7);
              $t47205 = Math.sin($t47204);
            }
            $t47206 = (0.4 * $t47205);
          }
          $t47207 = (0.6 + $t47206);
        }
        wind = ($t47203 * $t47207);
      }
    }
    {
      let to;
      {
        const $t47208 = ({ x: 185., y: 426. });
        to = Arcade$Vec2$sub($t47208, p);
      }
      {
        let d;
        {
          let $t47209;
          $t47209 = Arcade$Vec2$length(to);
          {
            const $t45798_i5457 = ($t47209 >= 1.);
            if ($t45798_i5457 === true) {
              d = $t47209;
            } else {
              d = 1.;
            }
          }
        }
        {
          let pull;
          {
            let $t47213;
            {
              let $t47211;
              {
                const $t47210 = s.magnet;
                $t47211 = ($t47210 > 0.);
              }
              {
                const $t47212 = (d < 220.);
                $t47213 = ($t47211 && $t47212);
              }
            }
            if ($t47213 === true) {
              {
                let $t47218;
                {
                  let $t47217;
                  {
                    const $t47214 = s.magnet;
                    {
                      let $t47216;
                      {
                        const $t47215 = (70. / d);
                        {
                          const $t45799_i5454 = ($t47215 < 1.);
                          if ($t45799_i5454 === true) {
                            $t47216 = $t47215;
                          } else {
                            $t47216 = 1.;
                          }
                        }
                      }
                      $t47217 = ($t47214 * $t47216);
                    }
                  }
                  $t47218 = ($t47217 / d);
                }
                pull = Arcade$Vec2$scale(to, $t47218);
              }
            } else {
              pull = ({ x: 0., y: 0. });
            }
          }
          {
            let $t47220;
            {
              const $t47219 = s.gravity;
              $t47220 = ({ x: wind, y: $t47219 });
            }
            return Arcade$Vec2$add($t47220, pull);
          }
        }
      }
    }
  }
}
const Spin$Physics$push$clo = { _0: ($_, s, clock, p) => Spin$Physics$push(s, clock, p) };

function Spin$Physics$step_ball(t, s, clock, num, left, right, h, b) {
  {
    let pushed;
    {
      const $t47222 = b.vel;
      {
        let $t47225;
        {
          let $t47224;
          {
            const $t47223 = b.pos;
            $t47224 = Spin$Physics$push(s, clock, $t47223);
          }
          $t47225 = Arcade$Vec2$scale($t47224, h);
        }
        pushed = Arcade$Vec2$add($t47222, $t47225);
      }
    }
    {
      let vel;
      {
        let $t47230;
        {
          let $t47229;
          {
            let $t47228;
            {
              let $t47227;
              {
                const $t47226 = s.drag;
                $t47227 = ($t47226 * h);
              }
              $t47228 = (1. - $t47227);
            }
            {
              const $t45798_i5464 = ($t47228 >= 0.);
              if ($t45798_i5464 === true) {
                $t47229 = $t47228;
              } else {
                $t47229 = 0.;
              }
            }
          }
          $t47230 = Arcade$Vec2$scale(pushed, $t47229);
        }
        {
          const v_i13232 = $t47230;
          {
            let s_i13233;
            s_i13233 = Arcade$Vec2$length($t47230);
            {
              const $t47197_i13235 = (s_i13233 > 2400.);
              if ($t47197_i13235 === true) {
                {
                  const $t47199_i13237 = (2400. / s_i13233);
                  vel = Arcade$Vec2$scale($t47230, $t47199_i13237);
                }
              } else {
                vel = $t47230;
              }
            }
          }
        }
      }
      {
        let moved;
        {
          let $t47233;
          {
            const $t47231 = b.pos;
            {
              let $t47232;
              $t47232 = Arcade$Vec2$scale(vel, h);
              $t47233 = Arcade$Vec2$add($t47231, $t47232);
            }
          }
          moved = ({ pos: $t47233, vel: vel });
        }
        {
          const r = t.ball_radius;
          {
            let w;
            {
              const $t47234 = s.bounce;
              w = ({ bounce: $t47234, clock: clock, num: num });
            }
            {
              let after_parts;
              {
                const $t47235 = t.parts;
                {
                  const $t47236 = { $: "Nil" };
                  {
                    const $t47237 = { _0: moved, _1: $t47236 };
                    {
                      const $t47240 = { $: "$Clo_$lam0_Spin_Physics_step_ball$0_Spin_Physics_step_ball", _0: $lam0_Spin_Physics_step_ball$apply$0_Spin_Physics_step_ball, _1: b, _2: r, _3: w };
                      after_parts = List$fold_left$List_Part$T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_Part_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit($t47235, $t47237, $t47240);
                    }
                  }
                }
              }
              {
                let after_left;
                {
                  const $t47241 = t.left;
                  after_left = Spin$Physics$against_flipper(r, $t47241, left, after_parts);
                }
                {
                  const $t47242 = t.right;
                  return Spin$Physics$against_flipper(r, $t47242, right, after_left);
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Physics$step_ball$clo = { _0: ($_, t, s, clock, num, left, right, h, b) => Spin$Physics$step_ball(t, s, clock, num, left, right, h, b) };

function Spin$Reels$rank(s) {
  switch (s.$) {
    case "Blank": {
      return 0;
      break;
    }
    case "Cherry": {
      return 1;
      break;
    }
    case "Lemon": {
      return 2;
      break;
    }
    case "Bell": {
      return 3;
      break;
    }
    case "Bars": {
      return 4;
      break;
    }
    case "Seven": {
      return 5;
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const Spin$Reels$rank$clo = { _0: ($_, s) => Spin$Reels$rank(s) };

function Spin$Reels$fresh_bank() {
  {
    let $t47261;
    {
      const $t47244 = { $: "Cherry" };
      {
        const $t47245 = { $: "Blank" };
        {
          const $t47246 = { $: "Blank" };
          {
            const $t47247 = { $: "Lemon" };
            {
              const $t47248 = { $: "Blank" };
              {
                const $t47249 = { $: "Blank" };
                {
                  const $t47250 = { $: "Blank" };
                  {
                    const $t47251 = { $: "Blank" };
                    {
                      const $t47252 = { $: "Nil" };
                      {
                        const $t47253 = { $: "Cons", _0: $t47251, _1: $t47252 };
                        {
                          const $t47254 = { $: "Cons", _0: $t47250, _1: $t47253 };
                          {
                            const $t47255 = { $: "Cons", _0: $t47249, _1: $t47254 };
                            {
                              const $t47256 = { $: "Cons", _0: $t47248, _1: $t47255 };
                              {
                                const $t47257 = { $: "Cons", _0: $t47247, _1: $t47256 };
                                {
                                  const $t47258 = { $: "Cons", _0: $t47246, _1: $t47257 };
                                  {
                                    const $t47259 = { $: "Cons", _0: $t47245, _1: $t47258 };
                                    {
                                      const $t47260 = { $: "Cons", _0: $t47244, _1: $t47259 };
                                      {
                                        const $t47243_i5470 = march_int_ovf(-(1), 3);
                                        $t47261 = ({ stops: $t47260, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t47243_i5470, glow: 0. });
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    {
      let $t47279;
      {
        const $t47262 = { $: "Blank" };
        {
          const $t47263 = { $: "Cherry" };
          {
            const $t47264 = { $: "Blank" };
            {
              const $t47265 = { $: "Blank" };
              {
                const $t47266 = { $: "Blank" };
                {
                  const $t47267 = { $: "Blank" };
                  {
                    const $t47268 = { $: "Bell" };
                    {
                      const $t47269 = { $: "Blank" };
                      {
                        const $t47270 = { $: "Nil" };
                        {
                          const $t47271 = { $: "Cons", _0: $t47269, _1: $t47270 };
                          {
                            const $t47272 = { $: "Cons", _0: $t47268, _1: $t47271 };
                            {
                              const $t47273 = { $: "Cons", _0: $t47267, _1: $t47272 };
                              {
                                const $t47274 = { $: "Cons", _0: $t47266, _1: $t47273 };
                                {
                                  const $t47275 = { $: "Cons", _0: $t47265, _1: $t47274 };
                                  {
                                    const $t47276 = { $: "Cons", _0: $t47264, _1: $t47275 };
                                    {
                                      const $t47277 = { $: "Cons", _0: $t47263, _1: $t47276 };
                                      {
                                        const $t47278 = { $: "Cons", _0: $t47262, _1: $t47277 };
                                        {
                                          const $t47243_i5468 = march_int_ovf(-(1), 3);
                                          $t47279 = ({ stops: $t47278, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t47243_i5468, glow: 0. });
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      {
        let $t47297;
        {
          const $t47280 = { $: "Blank" };
          {
            const $t47281 = { $: "Blank" };
            {
              const $t47282 = { $: "Blank" };
              {
                const $t47283 = { $: "Cherry" };
                {
                  const $t47284 = { $: "Blank" };
                  {
                    const $t47285 = { $: "Blank" };
                    {
                      const $t47286 = { $: "Blank" };
                      {
                        const $t47287 = { $: "Blank" };
                        {
                          const $t47288 = { $: "Nil" };
                          {
                            const $t47289 = { $: "Cons", _0: $t47287, _1: $t47288 };
                            {
                              const $t47290 = { $: "Cons", _0: $t47286, _1: $t47289 };
                              {
                                const $t47291 = { $: "Cons", _0: $t47285, _1: $t47290 };
                                {
                                  const $t47292 = { $: "Cons", _0: $t47284, _1: $t47291 };
                                  {
                                    const $t47293 = { $: "Cons", _0: $t47283, _1: $t47292 };
                                    {
                                      const $t47294 = { $: "Cons", _0: $t47282, _1: $t47293 };
                                      {
                                        const $t47295 = { $: "Cons", _0: $t47281, _1: $t47294 };
                                        {
                                          const $t47296 = { $: "Cons", _0: $t47280, _1: $t47295 };
                                          {
                                            const $t47243_i5466 = march_int_ovf(-(1), 3);
                                            $t47297 = ({ stops: $t47296, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t47243_i5466, glow: 0. });
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        {
          const $t47298 = { $: "Nil" };
          {
            const $t47299 = { $: "Cons", _0: $t47297, _1: $t47298 };
            {
              const $t47300 = { $: "Cons", _0: $t47279, _1: $t47299 };
              {
                const $t47301 = { $: "Cons", _0: $t47261, _1: $t47300 };
                {
                  const $t47302 = { $: "Idle" };
                  return ({ reels: $t47301, armed: 0, banked: 0, phase: $t47302, nudge_left: 0., boost: 1, last_line: "", last_pay: 0 });
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Reels$fresh_bank$clo = { _0: ($_) => Spin$Reels$fresh_bank() };

function Spin$Reels$wrap(i) {
  return march_int_mod_euclid(i, 8);
}
const Spin$Reels$wrap$clo = { _0: ($_, i) => Spin$Reels$wrap(i) };

function Spin$Reels$at(xs, i) {
  {
    let $t47305;
    {
      const $t47304 = Spin$Reels$wrap(i);
      $t47305 = List$nth_opt$List_Symbol$Int(xs, $t47304);
    }
    switch ($t47305.$) {
      case "Some": {
        const $f47306 = $t47305._0;
        {
          const s = $f47306;
          return s;
        }
        break;
      }
      case "None": {
        return { $: "Blank" };
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
  }
}
const Spin$Reels$at$clo = { _0: ($_, xs, i) => Spin$Reels$at(xs, i) };

function Spin$Reels$reel_at(b, i) {
  {
    let $t47312;
    {
      const $t47311 = b.reels;
      $t47312 = List$nth_opt$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($t47311, i);
    }
    switch ($t47312.$) {
      case "Some": {
        const $f47314 = $t47312._0;
        {
          const r = $f47314;
          return r;
        }
        break;
      }
      case "None": {
        {
          const $t47313 = { $: "Nil" };
          {
            const $t47243_i5472 = march_int_ovf(-(1), 3);
            return ({ stops: $t47313, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t47243_i5472, glow: 0. });
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
  }
}
const Spin$Reels$reel_at$clo = { _0: ($_, b, i) => Spin$Reels$reel_at(b, i) };

function Spin$Reels$set_reel(b, i, r) {
  {
    const $t47315 = b.reels;
    {
      let $t47316;
      {
        const xs_i13238 = $t47315;
        {
          let $t47307_i13244;
          {
            const $t1237_i6515_i13243 = { $: "Nil" };
            $t47307_i13244 = List$take_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t47315, i, $t1237_i6515_i13243);
          }
          {
            const $t47308_i13245 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
            {
              const $t47309_i13246 = List$drop$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($t47315, $t47308_i13245);
              {
                const $t47310_i13247 = { $: "Cons", _0: r, _1: $t47309_i13246 };
                {
                  const xs_i14818 = $t47307_i13244;
                  {
                    const ys_i14819 = $t47310_i13247;
                    switch (xs_i14818.$) {
                      case "Nil": {
                        $t47316 = $t47310_i13247;
                        break;
                      }
                      case "Cons": {
                        const $f998_i14820 = xs_i14818._0;
                        const $f999_i14821 = xs_i14818._1;
                        {
                          const t_i14822 = $f999_i14821;
                          {
                            const h_i14823 = $f998_i14820;
                            {
                              const $trmc11_i14824 = { $: "Cons", _0: h_i14823, _1: null };
                              List$append$dps$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(t_i14822, $t47310_i13247, $trmc11_i14824);
                              $t47316 = $trmc11_i14824;
                            }
                          }
                        }
                        break;
                      }
                      default: {
                        throw new Error("non-exhaustive pattern match");
                        break;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      {
        const $rc_2655 = ({ ...b, reels: $t47316 });
        return $rc_2655;
      }
    }
  }
}
const Spin$Reels$set_reel$clo = { _0: ($_, b, i, r) => Spin$Reels$set_reel(b, i, r) };

function Spin$Reels$on_line(b, i) {
  {
    const r = Spin$Reels$reel_at(b, i);
    {
      const $t47317 = r.stops;
      {
        const $t47318 = r.pos;
        return Spin$Reels$at($t47317, $t47318);
      }
    }
  }
}
const Spin$Reels$on_line$clo = { _0: ($_, b, i) => Spin$Reels$on_line(b, i) };

function Spin$Reels$shown(r) {
  {
    let $t47326;
    {
      const $t47325 = r.duration;
      $t47326 = ($t47325 > 0.);
    }
    if ($t47326 === true) {
      {
        let t;
        {
          let $t47329;
          {
            const $t47327 = r.elapsed;
            {
              const $t47328 = r.duration;
              $t47329 = ($t47327 / $t47328);
            }
          }
          {
            let $t45800_i5476;
            {
              const $t45798_i14622 = (0. >= $t47329);
              if ($t45798_i14622 === true) {
                $t45800_i5476 = 0.;
              } else {
                $t45800_i5476 = $t47329;
              }
            }
            {
              const $t45799_i14619 = (1. < $t45800_i5476);
              if ($t45799_i14619 === true) {
                t = 1.;
              } else {
                t = $t45800_i5476;
              }
            }
          }
        }
        {
          const left = (1. - t);
          {
            const $t47330 = r.from;
            {
              let $t47335;
              {
                const $t47331 = r.travel;
                {
                  let $t47334;
                  {
                    let $t47333;
                    {
                      const $t47332 = (left * left);
                      $t47333 = ($t47332 * left);
                    }
                    $t47334 = (1. - $t47333);
                  }
                  $t47335 = ($t47331 * $t47334);
                }
              }
              return ($t47330 + $t47335);
            }
          }
        }
      }
    } else {
      {
        const $t47336 = r.pos;
        return $t47336;
      }
    }
  }
}
const Spin$Reels$shown$clo = { _0: ($_, r) => Spin$Reels$shown(r) };

function Spin$Reels$stop(r, i) {
  {
    const $t47337 = r.stops;
    return Spin$Reels$at($t47337, i);
  }
}
const Spin$Reels$stop$clo = { _0: ($_, r, i) => Spin$Reels$stop(r, i) };

function Spin$Reels$count(xs, s) {
  {
    const $t47339 = { $: "$Clo_$lam0_Spin_Reels_count$0_Spin_Reels_count", _0: $lam0_Spin_Reels_count$apply$0_Spin_Reels_count, _1: s };
    {
      const $t47340 = List$filter$List_Symbol$Fn_Symbol_Bool(xs, $t47339);
      {
        let $rc_2656;
        {  };
        $rc_2656 = List$length_onto$List_Symbol$Int($t47340, 0);
        return $rc_2656;
      }
    }
  }
}
const Spin$Reels$count$clo = { _0: ($_, xs, s) => Spin$Reels$count(xs, s) };

function Spin$Reels$pays(xs) {
  switch (xs.$) {
    case "Cons": {
      const $f47353 = xs._0;
      const $f47354 = xs._1;
      {
        const $jp_clo47360 = { $: "$Clo_$jp2_Spin_Reels_pays$0_Spin_Reels_pays", _0: $jp2_Spin_Reels_pays$apply$0_Spin_Reels_pays };
        switch ($f47354.$) {
          case "Cons": {
            const $f47361 = $f47354._0;
            const $f47362 = $f47354._1;
            {
              const $jp_clo47368 = { $: "$Clo_$jp5_Spin_Reels_pays$1_Spin_Reels_pays", _0: $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays, _1: $jp_clo47360 };
              switch ($f47362.$) {
                case "Cons": {
                  const $f47369 = $f47362._0;
                  const $f47370 = $f47362._1;
                  switch ($f47370.$) {
                    case "Nil": {
                      {
                        const c = $f47369;
                        {
                          const b = $f47361;
                          {
                            const a = $f47353;
                            {
                              let $t47346;
                              {
                                let $t47343;
                                {
                                  const $t47341 = march_deep_eq(a, b);
                                  {
                                    let $t47342;
                                    {
                                      const $rc_2659 = march_deep_eq(b, c);
                                      $t47342 = $rc_2659;
                                    }
                                    $t47343 = ($t47341 && $t47342);
                                  }
                                }
                                {
                                  let $t47345;
                                  {
                                    const $t47344 = { $: "Blank" };
                                    {
                                      const $rc_2658 = (!march_deep_eq(a, $t47344));
                                      $t47345 = $rc_2658;
                                    }
                                  }
                                  $t47346 = ($t47343 && $t47345);
                                }
                              }
                              if ($t47346 === true) {
                                {
                                  let $rc_2657;
                                  switch (a.$) {
                                    case "Seven": {
                                      $rc_2657 = { _0: 77, _1: "JACKPOT 777" };
                                      break;
                                    }
                                    case "Bars": {
                                      $rc_2657 = { _0: 30, _1: "BAR BAR BAR" };
                                      break;
                                    }
                                    case "Bell": {
                                      $rc_2657 = { _0: 20, _1: "THREE BELLS" };
                                      break;
                                    }
                                    case "Lemon": {
                                      $rc_2657 = { _0: 12, _1: "THREE LEMONS" };
                                      break;
                                    }
                                    case "Cherry": {
                                      $rc_2657 = { _0: 10, _1: "THREE CHERRIES" };
                                      break;
                                    }
                                    case "Blank": {
                                      $rc_2657 = { _0: 0, _1: "" };
                                      break;
                                    }
                                    default: {
                                      throw new Error("non-exhaustive pattern match");
                                      break;
                                    }
                                  }
                                  return $rc_2657;
                                }
                              } else {
                                {
                                  let cherries;
                                  {
                                    const $t47347 = { $: "Cherry" };
                                    cherries = Spin$Reels$count(xs, $t47347);
                                  }
                                  {
                                    const $t47348 = (cherries >= 2);
                                    if ($t47348 === true) {
                                      return { _0: 4, _1: "TWO CHERRIES" };
                                    } else {
                                      {
                                        let $t47351;
                                        {
                                          let $t47350;
                                          {
                                            const $t47349 = { $: "Blank" };
                                            $t47350 = Spin$Reels$count(xs, $t47349);
                                          }
                                          $t47351 = ($t47350 === 0);
                                        }
                                        if ($t47351 === true) {
                                          return { _0: 3, _1: "FULL LINE" };
                                        } else {
                                          {
                                            const $t47352 = (cherries === 1);
                                            if ($t47352 === true) {
                                              return { _0: 1, _1: "CHERRY" };
                                            } else {
                                              return { _0: 0, _1: "" };
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                      break;
                    }
                    default: {
                      return $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays($jp_clo47368);
                    }
                  }
                  break;
                }
                default: {
                  return $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays($jp_clo47368);
                }
              }
            }
            break;
          }
          default: {
            return { _0: 0, _1: "" };
          }
        }
      }
      break;
    }
    default: {
      return { _0: 0, _1: "" };
    }
  }
}
const Spin$Reels$pays$clo = { _0: ($_, xs) => Spin$Reels$pays(xs) };

function Spin$Reels$roll_to(r, s) {
  {
    const $t47391 = ((8 + 1) < 4611686018427387904 && (8 + 1) >= -4611686018427387904 ? (8 + 1) : march_int_ovf((8 + 1), 0));
    {
      let ahead;
      {
        const go_i5486 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 1 };
        {
          const $t926_i5487 = (($t47391 - 1) < 4611686018427387904 && ($t47391 - 1) >= -4611686018427387904 ? ($t47391 - 1) : march_int_ovf(($t47391 - 1), 1));
          {
            const $t927_i5488 = { $: "Nil" };
            ahead = go$apply$0_List_range(go_i5486, $t926_i5487, $t927_i5488);
          }
        }
      }
      {
        let $t47397;
        {
          let $t47396;
          $t47396 = { $: "$Clo_$lam0_Spin_Reels_roll_to$0_Spin_Reels_roll_to", _0: $lam0_Spin_Reels_roll_to$apply$0_Spin_Reels_roll_to, _1: r, _2: s };
          $t47397 = List$find$List_Int$Fn_Int_Bool(ahead, $t47396);
        }
        switch ($t47397.$) {
          case "Some": {
            const $f47407 = $t47397._0;
            {
              const k = $f47407;
              return k;
            }
            break;
          }
          case "None": {
            {
              let $t47405;
              {
                const $t47404 = { $: "$Clo_$lam1_Spin_Reels_roll_to$1_Spin_Reels_roll_to", _0: $lam1_Spin_Reels_roll_to$apply$1_Spin_Reels_roll_to, _1: r, _2: s };
                {
                  const $rc_2661 = List$find$List_Int$Fn_Int_Bool(ahead, $t47404);
                  $t47405 = $rc_2661;
                }
              }
              switch ($t47405.$) {
                case "Some": {
                  const $f47406 = $t47405._0;
                  {
                    const k = $f47406;
                    return k;
                  }
                  break;
                }
                case "None": {
                  return 8;
                  break;
                }
                default: {
                  return (() => { throw new Error("non-exhaustive pattern match"); })();
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
  }
}
const Spin$Reels$roll_to$clo = { _0: ($_, r, s) => Spin$Reels$roll_to(r, s) };

function Spin$Reels$load(b, s) {
  {
    const i = b.armed;
    {
      let w;
      {
        let $t47422;
        $t47422 = Spin$Reels$reel_at(b, i);
        {
          const r_i13287 = $t47422;
          {
            const s_i13288 = s;
            {
              let $t47408_i13289;
              {
                const r_i14848 = $t47422;
                {
                  const $t47380_i14849 = ((8 + 1) < 4611686018427387904 && (8 + 1) >= -4611686018427387904 ? (8 + 1) : march_int_ovf((8 + 1), 0));
                  {
                    let $t47381_i14853;
                    {
                      const go_i5481_i14850 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 1 };
                      {
                        const $t926_i5482_i14851 = (($t47380_i14849 - 1) < 4611686018427387904 && ($t47380_i14849 - 1) >= -4611686018427387904 ? ($t47380_i14849 - 1) : march_int_ovf(($t47380_i14849 - 1), 1));
                        {
                          const $t927_i5483_i14852 = { $: "Nil" };
                          $t47381_i14853 = go$apply$0_List_range(go_i5481_i14850, $t926_i5482_i14851, $t927_i5483_i14852);
                        }
                      }
                    }
                    {
                      let $t47385_i14854;
                      $t47385_i14854 = { $: "$Clo_$lam0_Spin_Reels_target_stop$0_Spin_Reels_target_stop", _0: $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop, _1: $t47422 };
                      {
                        let order_i14855;
                        {
                          const xs_i14894 = $t47381_i14853;
                          {
                            const f_i14895 = $t47385_i14854;
                            switch (xs_i14894.$) {
                              case "Nil": {
                                order_i14855 = { $: "Nil" };
                                break;
                              }
                              case "Cons": {
                                const $f1006_i14896 = xs_i14894._0;
                                const $f1007_i14897 = xs_i14894._1;
                                {
                                  const t_i14898 = $f1007_i14897;
                                  {
                                    const h_i14899 = $f1006_i14896;
                                    {
                                      let $t1004_i14900;
                                      $t1004_i14900 = f_i14895._0(f_i14895, h_i14899);
                                      {
                                        const $trmc15_i14901 = { $: "Cons", _0: $t1004_i14900, _1: null };
                                        List$map$dps$List_Int$Fn_Int_Int$List_Int(t_i14898, f_i14895, $trmc15_i14901);
                                        order_i14855 = $trmc15_i14901;
                                      }
                                    }
                                  }
                                }
                                break;
                              }
                              default: {
                                throw new Error("non-exhaustive pattern match");
                                break;
                              }
                            }
                          }
                        }
                        {
                          const $t47389_i14856 = { $: "$Clo_$lam1_Spin_Reels_target_stop$1_Spin_Reels_target_stop", _0: $lam1_Spin_Reels_target_stop$apply$1_Spin_Reels_target_stop, _1: $t47422 };
                          {
                            const $rc_2660_i14857 = List$find$List_Int$Fn_Int_Bool(order_i14855, $t47389_i14856);
                            $t47408_i13289 = $rc_2660_i14857;
                          }
                        }
                      }
                    }
                  }
                }
              }
              switch ($t47408_i13289.$) {
                case "Some": {
                  const $f47411_i13290 = $t47408_i13289._0;
                  {
                    const j_i13291 = $f47411_i13290;
                    {
                      const $t47409_i13292 = $t47422.stops;
                      {
                        let $t47410_i13293;
                        {
                          const xs_i14833 = $t47409_i13292;
                          {
                            let $t47307_i14837;
                            {
                              const $t1237_i6518_i14836 = { $: "Nil" };
                              $t47307_i14837 = List$take_onto$List_Symbol$Int$List_Symbol($t47409_i13292, j_i13291, $t1237_i6518_i14836);
                            }
                            {
                              const $t47308_i14838 = ((j_i13291 + 1) < 4611686018427387904 && (j_i13291 + 1) >= -4611686018427387904 ? (j_i13291 + 1) : march_int_ovf((j_i13291 + 1), 0));
                              {
                                const $t47309_i14839 = List$drop$List_Symbol$Int($t47409_i13292, $t47308_i14838);
                                {
                                  const $t47310_i14840 = { $: "Cons", _0: s, _1: $t47309_i14839 };
                                  {
                                    const xs_i13566_i14841 = $t47307_i14837;
                                    {
                                      const ys_i13567_i14842 = $t47310_i14840;
                                      switch (xs_i13566_i14841.$) {
                                        case "Nil": {
                                          $t47410_i13293 = $t47310_i14840;
                                          break;
                                        }
                                        case "Cons": {
                                          const $f998_i13568_i14843 = xs_i13566_i14841._0;
                                          const $f999_i13569_i14844 = xs_i13566_i14841._1;
                                          {
                                            const t_i13570_i14845 = $f999_i13569_i14844;
                                            {
                                              const h_i13571_i14846 = $f998_i13568_i14843;
                                              {
                                                const $trmc11_i13572_i14847 = { $: "Cons", _0: h_i13571_i14846, _1: null };
                                                List$append$dps$List_Symbol$List_Symbol$List_Symbol(t_i13570_i14845, $t47310_i14840, $trmc11_i13572_i14847);
                                                $t47410_i13293 = $trmc11_i13572_i14847;
                                              }
                                            }
                                          }
                                          break;
                                        }
                                        default: {
                                          throw new Error("non-exhaustive pattern match");
                                          break;
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                        {
                          const $rc_2662_i13294 = ({ ...$t47422, stops: $t47410_i13293, fresh: j_i13291, glow: 1. });
                          w = $rc_2662_i13294;
                        }
                      }
                    }
                  }
                  break;
                }
                case "None": {
                  w = $t47422;
                  break;
                }
                default: {
                  throw new Error("non-exhaustive pattern match");
                  break;
                }
              }
            }
          }
        }
      }
      {
        let next;
        {
          let $t47424;
          {
            const $t47423 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
            $t47424 = march_int_mod_euclid($t47423, 3);
          }
          next = ({ ...b, armed: $t47424 });
        }
        {
          let $t47431;
          {
            let $t47427;
            {
              const $t47425 = b.phase;
              {
                const $t47426 = { $: "Spinning" };
                {
                  const $rc_2665 = march_deep_eq($t47425, $t47426);
                  $t47427 = $rc_2665;
                }
              }
            }
            {
              let $t47430;
              {
                const $t47428 = b.phase;
                {
                  const $t47429 = { $: "Nudging" };
                  {
                    const $rc_2664 = march_deep_eq($t47428, $t47429);
                    $t47430 = $rc_2664;
                  }
                }
              }
              $t47431 = ($t47427 || $t47430);
            }
          }
          if ($t47431 === true) {
            {
              const quiet = Spin$Reels$set_reel(next, i, w);
              {
                const $t47432 = { $: "Loaded", _0: s, _1: i };
                {
                  const $t47433 = { $: "Nil" };
                  {
                    const $t47434 = { $: "Cons", _0: $t47432, _1: $t47433 };
                    return { _0: quiet, _1: $t47434 };
                  }
                }
              }
            }
          } else {
            {
              let placed;
              {
                let $t47436;
                {
                  let $t47435;
                  $t47435 = Spin$Reels$roll_to(w, s);
                  {
                    const r_i13275 = w;
                    {
                      let $t47413_i13278;
                      {
                        const $t47412_i13277 = w.pos;
                        $t47413_i13278 = $t47412_i13277;
                      }
                      {
                        const $t47414_i13279 = $t47435;
                        {
                          let $t47417_i13282;
                          {
                            let $t47416_i13281;
                            {
                              const $t47415_i13280 = $t47435;
                              $t47416_i13281 = (0.05 * $t47415_i13280);
                            }
                            $t47417_i13282 = (0.16 + $t47416_i13281);
                          }
                          {
                            let $t47420_i13285;
                            {
                              let $t47419_i13284;
                              {
                                const $t47418_i13283 = w.pos;
                                $t47419_i13284 = (($t47418_i13283 + $t47435) < 4611686018427387904 && ($t47418_i13283 + $t47435) >= -4611686018427387904 ? ($t47418_i13283 + $t47435) : march_int_ovf(($t47418_i13283 + $t47435), 0));
                              }
                              $t47420_i13285 = Spin$Reels$wrap($t47419_i13284);
                            }
                            {
                              const $rc_2663_i13286 = ({ ...w, from: $t47413_i13278, travel: $t47414_i13279, elapsed: 0., duration: $t47417_i13282, pos: $t47420_i13285 });
                              $t47436 = $rc_2663_i13286;
                            }
                          }
                        }
                      }
                    }
                  }
                }
                placed = Spin$Reels$set_reel(next, i, $t47436);
              }
              {
                let building;
                {
                  let $t47441;
                  {
                    let $t47440;
                    {
                      let $t47438;
                      {
                        const $t47437 = b.phase;
                        {
                          const p_i13272 = $t47437;
                          switch (p_i13272.$) {
                            case "Building": {
                              const $f47421_i13273 = p_i13272._0;
                              {
                                const j_i13274 = $f47421_i13273;
                                $t47438 = j_i13274;
                              }
                              break;
                            }
                            case "Idle": {
                              $t47438 = false;
                              break;
                            }
                            case "Spinning": {
                              $t47438 = false;
                              break;
                            }
                            case "Nudging": {
                              $t47438 = false;
                              break;
                            }
                            default: {
                              throw new Error("non-exhaustive pattern match");
                              break;
                            }
                          }
                        }
                      }
                      {
                        const $t47439 = (i === 2);
                        $t47440 = ($t47438 || $t47439);
                      }
                    }
                    $t47441 = { $: "Building", _0: $t47440 };
                  }
                  building = Spin$Reels$in_phase(placed, $t47441);
                }
                {
                  const $t47442 = { $: "Loaded", _0: s, _1: i };
                  {
                    const $t47443 = { $: "Nil" };
                    {
                      const $t47444 = { $: "Cons", _0: $t47442, _1: $t47443 };
                      return { _0: building, _1: $t47444 };
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Reels$load$clo = { _0: ($_, b, s) => Spin$Reels$load(b, s) };

function Spin$Reels$bank_spin(b) {
  {
    let n;
    {
      let $t47446;
      {
        const $t47445 = b.banked;
        $t47446 = (($t47445 + 1) < 4611686018427387904 && ($t47445 + 1) >= -4611686018427387904 ? ($t47445 + 1) : march_int_ovf(($t47445 + 1), 0));
      }
      {
        const $t2473_i5491 = ($t47446 < 5);
        if ($t2473_i5491 === true) {
          n = $t47446;
        } else {
          n = 5;
        }
      }
    }
    {
      const $t47448 = ({ ...b, banked: n });
      {
        const $t47449 = { $: "Banked", _0: n };
        {
          const $t47450 = { $: "Nil" };
          {
            const $t47451 = { $: "Cons", _0: $t47449, _1: $t47450 };
            return { _0: $t47448, _1: $t47451 };
          }
        }
      }
    }
  }
}
const Spin$Reels$bank_spin$clo = { _0: ($_, b) => Spin$Reels$bank_spin(b) };

function Spin$Reels$start_reel(rng, r, i) {
  {
    const $t47454 = r.held;
    if ($t47454 === true) {
      return { _0: r, _1: rng };
    } else {
      {
        const $p47467 = Arcade$Rng$next_int_below(rng, 8);
        {
          const target = $p47467._0;
          {
            const after = $p47467._1;
            {
              const laps = ((2 + i) < 4611686018427387904 && (2 + i) >= -4611686018427387904 ? (2 + i) : march_int_ovf((2 + i), 0));
              {
                let ahead;
                {
                  let $t47457;
                  {
                    const $t47456 = r.pos;
                    $t47457 = ((target - $t47456) < 4611686018427387904 && (target - $t47456) >= -4611686018427387904 ? (target - $t47456) : march_int_ovf((target - $t47456), 1));
                  }
                  ahead = Spin$Reels$wrap($t47457);
                }
                {
                  let travel;
                  {
                    let $t47460;
                    {
                      const $t47459 = ((laps * 8) < 4611686018427387904 && (laps * 8) >= -4611686018427387904 ? (laps * 8) : march_int_ovf((laps * 8), 2));
                      $t47460 = (($t47459 + ahead) < 4611686018427387904 && ($t47459 + ahead) >= -4611686018427387904 ? ($t47459 + ahead) : march_int_ovf(($t47459 + ahead), 0));
                    }
                    travel = $t47460;
                  }
                  {
                    let $t47466;
                    {
                      let $t47462;
                      {
                        const $t47461 = r.pos;
                        $t47462 = $t47461;
                      }
                      {
                        let $t47465;
                        {
                          let $t47464;
                          {
                            const $t47463 = i;
                            $t47464 = (0.4 * $t47463);
                          }
                          $t47465 = (0.9 + $t47464);
                        }
                        $t47466 = ({ ...r, from: $t47462, travel: travel, elapsed: 0., duration: $t47465, pos: target });
                      }
                    }
                    {
                      const $rc_2668 = { _0: $t47466, _1: after };
                      return $rc_2668;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Reels$start_reel$clo = { _0: ($_, rng, r, i) => Spin$Reels$start_reel(rng, r, i) };

function Spin$Reels$start_spin(b, rng) {
  {
    let $p47481;
    {
      let $t47468;
      $t47468 = Spin$Reels$reel_at(b, 0);
      $p47481 = Spin$Reels$start_reel(rng, $t47468, 0);
    }
    {
      const r0 = $p47481._0;
      {
        const g0 = $p47481._1;
        {
          let $p47480;
          {
            let $t47469;
            $t47469 = Spin$Reels$reel_at(b, 1);
            $p47480 = Spin$Reels$start_reel(g0, $t47469, 1);
          }
          {
            const r1 = $p47480._0;
            {
              const g1 = $p47480._1;
              {
                let $p47479;
                {
                  let $t47470;
                  $t47470 = Spin$Reels$reel_at(b, 2);
                  $p47479 = Spin$Reels$start_reel(g1, $t47470, 2);
                }
                {
                  const r2 = $p47479._0;
                  {
                    const g2 = $p47479._1;
                    {
                      let $t47478;
                      {
                        const $t47471 = { $: "Nil" };
                        {
                          let $t47472;
                          $t47472 = { $: "Cons", _0: r2, _1: $t47471 };
                          {
                            let $t47473;
                            $t47473 = { $: "Cons", _0: r1, _1: $t47472 };
                            {
                              let $t47474;
                              $t47474 = { $: "Cons", _0: r0, _1: $t47473 };
                              {
                                let $t47476;
                                {
                                  const $t47475 = b.banked;
                                  $t47476 = (($t47475 - 1) < 4611686018427387904 && ($t47475 - 1) >= -4611686018427387904 ? ($t47475 - 1) : march_int_ovf(($t47475 - 1), 1));
                                }
                                {
                                  const $t47477 = { $: "Spinning" };
                                  $t47478 = ({ ...b, reels: $t47474, banked: $t47476, phase: $t47477, nudge_left: 0. });
                                }
                              }
                            }
                          }
                        }
                      }
                      {
                        const $rc_2670 = { _0: $t47478, _1: g2 };
                        return $rc_2670;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Reels$start_spin$clo = { _0: ($_, b, rng) => Spin$Reels$start_spin(b, rng) };

function Spin$Reels$turn(r, dt, i) {
  {
    let faded;
    {
      let $t47484;
      {
        let $t47483;
        {
          const $t47482 = r.glow;
          $t47483 = ($t47482 - dt);
        }
        {
          const $t45798_i5494 = ($t47483 >= 0.);
          if ($t45798_i5494 === true) {
            $t47484 = $t47483;
          } else {
            $t47484 = 0.;
          }
        }
      }
      faded = ({ ...r, glow: $t47484 });
    }
    {
      let $t47486;
      {
        const $t47485 = faded.duration;
        $t47486 = ($t47485 > 0.);
      }
      if ($t47486 === true) {
        {
          let e;
          {
            const $t47487 = faded.elapsed;
            e = ($t47487 + dt);
          }
          {
            let $t47489;
            {
              const $t47488 = faded.duration;
              $t47489 = (e >= $t47488);
            }
            if ($t47489 === true) {
              {
                const $t47490 = ({ ...faded, elapsed: 0., duration: 0., travel: 0. });
                {
                  const $t47491 = { $: "Landed", _0: i };
                  {
                    const $t47492 = { $: "Nil" };
                    {
                      const $t47493 = { $: "Cons", _0: $t47491, _1: $t47492 };
                      {
                        const $rc_2678 = { _0: $t47490, _1: $t47493 };
                        return $rc_2678;
                      }
                    }
                  }
                }
              }
            } else {
              {
                const $t47494 = ({ ...faded, elapsed: e });
                {
                  const $t47495 = { $: "Nil" };
                  {
                    const $rc_2677 = { _0: $t47494, _1: $t47495 };
                    return $rc_2677;
                  }
                }
              }
            }
          }
        }
      } else {
        {
          const $t47496 = { $: "Nil" };
          return { _0: faded, _1: $t47496 };
        }
      }
    }
  }
}
const Spin$Reels$turn$clo = { _0: ($_, r, dt, i) => Spin$Reels$turn(r, dt, i) };

function Spin$Reels$unhold(r) {
  {
    const $rc_2679 = ({ ...r, held: false });
    return $rc_2679;
  }
}
const Spin$Reels$unhold$clo = { _0: ($_, r) => Spin$Reels$unhold(r) };

function Spin$Reels$settle(b) {
  {
    let $p47521;
    {
      let $t47501;
      {
        const b_i13295 = b;
        {
          let $t47319_i13296;
          $t47319_i13296 = Spin$Reels$on_line(b, 0);
          {
            let $t47320_i13297;
            $t47320_i13297 = Spin$Reels$on_line(b, 1);
            {
              const $t47321_i13298 = Spin$Reels$on_line(b, 2);
              {
                const $t47322_i13299 = { $: "Nil" };
                {
                  const $t47323_i13300 = { $: "Cons", _0: $t47321_i13298, _1: $t47322_i13299 };
                  {
                    const $t47324_i13301 = { $: "Cons", _0: $t47320_i13297, _1: $t47323_i13300 };
                    $t47501 = { $: "Cons", _0: $t47319_i13296, _1: $t47324_i13301 };
                  }
                }
              }
            }
          }
        }
      }
      $p47521 = Spin$Reels$pays($t47501);
    }
    {
      const pay = $p47521._0;
      {
        const name = $p47521._1;
        {
          let idle;
          {
            const $t47502 = { $: "Idle" };
            idle = ({ ...b, phase: $t47502 });
          }
          {
            const $t47503 = b.phase;
            switch ($t47503.$) {
              case "Building": {
                const $f47520 = $t47503._0;
                {
                  let judge;
                  judge = $f47520;
                  {
                    let $t47505;
                    {
                      const $t47504 = (pay > 0);
                      $t47505 = (judge && $t47504);
                    }
                    if ($t47505 === true) {
                      {
                        let paid;
                        paid = ({ ...idle, last_line: name, last_pay: pay });
                        {
                          let out;
                          {
                            let $t47506;
                            $t47506 = { $: "Paid", _0: pay, _1: name };
                            {
                              const $t47507 = { $: "Nil" };
                              {
                                const $t47508 = { $: "Cons", _0: $t47506, _1: $t47507 };
                                out = { _0: paid, _1: $t47508 };
                              }
                            }
                          }
                          return out;
                        }
                      }
                    } else {
                      {
                        const $t47509 = { $: "Nil" };
                        {
                          const $rc_2689 = { _0: idle, _1: $t47509 };
                          return $rc_2689;
                        }
                      }
                    }
                  }
                }
                break;
              }
              case "Spinning": {
                {
                  const $t47510 = (pay > 0);
                  if ($t47510 === true) {
                    return Spin$Reels$spent(idle, pay, name);
                  } else {
                    {
                      let missed;
                      {
                        const $t47511 = b.reels;
                        {
                          let $t47512;
                          $t47512 = List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t47511, Spin$Reels$unhold$clo);
                          missed = ({ ...idle, reels: $t47512, boost: 1, nudge_left: 4., last_line: "NUDGE!", last_pay: 0 });
                        }
                      }
                      {
                        let out;
                        {
                          const $t47514 = { $: "Missed" };
                          {
                            const $t47515 = { $: "Nil" };
                            {
                              const $t47516 = { $: "Cons", _0: $t47514, _1: $t47515 };
                              out = { _0: missed, _1: $t47516 };
                            }
                          }
                        }
                        return out;
                      }
                    }
                  }
                }
                break;
              }
              case "Nudging": {
                {
                  const $t47517 = (pay > 0);
                  if ($t47517 === true) {
                    return Spin$Reels$spent(idle, pay, name);
                  } else {
                    {
                      const $t47518 = { $: "Nil" };
                      {
                        const $rc_2692 = { _0: idle, _1: $t47518 };
                        return $rc_2692;
                      }
                    }
                  }
                }
                break;
              }
              case "Idle": {
                {
                  const $t47519 = { $: "Nil" };
                  {
                    const $rc_2693 = { _0: idle, _1: $t47519 };
                    return $rc_2693;
                  }
                }
                break;
              }
              default: {
                return (() => { throw new Error("non-exhaustive pattern match"); })();
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Reels$settle$clo = { _0: ($_, b) => Spin$Reels$settle(b) };

function Spin$Reels$spent(b, pay, name) {
  {
    let total;
    {
      const $t47522 = b.boost;
      total = ((pay * $t47522) < 4611686018427387904 && (pay * $t47522) >= -4611686018427387904 ? (pay * $t47522) : march_int_ovf((pay * $t47522), 2));
    }
    {
      let named;
      {
        let $t47524;
        {
          const $t47523 = b.boost;
          $t47524 = ($t47523 > 1);
        }
        if ($t47524 === true) {
          {
            let $t47526;
            {
              const $t47525 = b.boost;
              $t47526 = String($t47525);
            }
            {
              const $rc_2694 = march_string_concat3(name, " x", $t47526);
              named = $rc_2694;
            }
          }
        } else {
          named = name;
        }
      }
      {
        let paid;
        {
          const $t47527 = b.reels;
          {
            let $t47528;
            $t47528 = List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t47527, Spin$Reels$unhold$clo);
            paid = ({ ...b, reels: $t47528, boost: 1, nudge_left: 0., last_line: named, last_pay: total });
          }
        }
        {
          let out;
          {
            const $t47529 = { $: "Paid", _0: total, _1: named };
            {
              const $t47530 = { $: "Nil" };
              {
                const $t47531 = { $: "Cons", _0: $t47529, _1: $t47530 };
                out = { _0: paid, _1: $t47531 };
              }
            }
          }
          return out;
        }
      }
    }
  }
}
const Spin$Reels$spent$clo = { _0: ($_, b, pay, name) => Spin$Reels$spent(b, pay, name) };

function Spin$Reels$tick(b, rng, dt) {
  {
    let $p47572;
    {
      let $t47532;
      $t47532 = Spin$Reels$reel_at(b, 0);
      $p47572 = Spin$Reels$turn($t47532, dt, 0);
    }
    {
      const r0 = $p47572._0;
      {
        const e0 = $p47572._1;
        {
          let $p47571;
          {
            let $t47533;
            $t47533 = Spin$Reels$reel_at(b, 1);
            $p47571 = Spin$Reels$turn($t47533, dt, 1);
          }
          {
            const r1 = $p47571._0;
            {
              const e1 = $p47571._1;
              {
                let $p47570;
                {
                  let $t47534;
                  $t47534 = Spin$Reels$reel_at(b, 2);
                  $p47570 = Spin$Reels$turn($t47534, dt, 2);
                }
                {
                  const r2 = $p47570._0;
                  {
                    const e2 = $p47570._1;
                    {
                      let turned;
                      {
                        const $t47535 = { $: "Nil" };
                        {
                          let $t47536;
                          $t47536 = { $: "Cons", _0: r2, _1: $t47535 };
                          {
                            let $t47537;
                            $t47537 = { $: "Cons", _0: r1, _1: $t47536 };
                            {
                              let $t47538;
                              $t47538 = { $: "Cons", _0: r0, _1: $t47537 };
                              {
                                let $t47541;
                                {
                                  let $t47540;
                                  {
                                    const $t47539 = b.nudge_left;
                                    $t47540 = ($t47539 - dt);
                                  }
                                  {
                                    const $t45798_i5505 = ($t47540 >= 0.);
                                    if ($t45798_i5505 === true) {
                                      $t47541 = $t47540;
                                    } else {
                                      $t47541 = 0.;
                                    }
                                  }
                                }
                                turned = ({ ...b, reels: $t47538, nudge_left: $t47541 });
                              }
                            }
                          }
                        }
                      }
                      {
                        const $t47542 = { $: "Nil" };
                        {
                          let $t47543;
                          $t47543 = { $: "Cons", _0: e2, _1: $t47542 };
                          {
                            let $t47544;
                            $t47544 = { $: "Cons", _0: e1, _1: $t47543 };
                            {
                              let $t47545;
                              $t47545 = { $: "Cons", _0: e0, _1: $t47544 };
                              {
                                let landed;
                                {
                                  const prepend_reversed_i5500 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_ReelEvent", _0: prepend_reversed$apply$0_List_concat_List_List_ReelEvent };
                                  {
                                    const go_i5501 = { $: "$Clo_go$1_List_concat_List_List_ReelEvent", _0: go$apply$1_List_concat_List_List_ReelEvent, _1: prepend_reversed_i5500 };
                                    {
                                      const $t1124_i5502 = { $: "Nil" };
                                      landed = go$apply$1_List_concat_List_List_ReelEvent(go_i5501, $t47545, $t1124_i5502);
                                    }
                                  }
                                }
                                {
                                  let $p47569;
                                  {
                                    let $t47551;
                                    {
                                      let $t47548;
                                      {
                                        const $t47546 = turned.phase;
                                        {
                                          const $t47547 = { $: "Idle" };
                                          {
                                            const $rc_2702 = (!march_deep_eq($t47546, $t47547));
                                            $t47548 = $rc_2702;
                                          }
                                        }
                                      }
                                      {
                                        let $t47550;
                                        {
                                          let $t47549;
                                          {
                                            const b_i13309 = turned;
                                            {
                                              const $t47497_i13310 = turned.reels;
                                              {
                                                const $t47500_i13311 = { $: "$Clo_$lam0_Spin_Reels_turning$0_Spin_Reels_turning", _0: $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning };
                                                $t47549 = List$any$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool($t47497_i13310, $t47500_i13311);
                                              }
                                            }
                                          }
                                          $t47550 = (!$t47549);
                                        }
                                        $t47551 = ($t47548 && $t47550);
                                      }
                                    }
                                    if ($t47551 === true) {
                                      $p47569 = Spin$Reels$settle(turned);
                                    } else {
                                      {
                                        const $t47552 = { $: "Nil" };
                                        $p47569 = { _0: turned, _1: $t47552 };
                                      }
                                    }
                                  }
                                  {
                                    const settled = $p47569._0;
                                    {
                                      const paid = $p47569._1;
                                      {
                                        let $t47558;
                                        {
                                          let $t47555;
                                          {
                                            const $t47553 = settled.phase;
                                            {
                                              const $t47554 = { $: "Idle" };
                                              {
                                                const $rc_2697 = march_deep_eq($t47553, $t47554);
                                                $t47555 = $rc_2697;
                                              }
                                            }
                                          }
                                          {
                                            let $t47557;
                                            {
                                              const $t47556 = settled.banked;
                                              $t47557 = ($t47556 > 0);
                                            }
                                            $t47558 = ($t47555 && $t47557);
                                          }
                                        }
                                        if ($t47558 === true) {
                                          {
                                            let $p47567;
                                            $p47567 = Spin$Reels$start_spin(settled, rng);
                                            {
                                              const spun = $p47567._0;
                                              {
                                                const after = $p47567._1;
                                                {
                                                  const $t47559 = { $: "Started" };
                                                  {
                                                    const $t47560 = { $: "Nil" };
                                                    {
                                                      const $t47561 = { $: "Cons", _0: $t47559, _1: $t47560 };
                                                      {
                                                        const $t47562 = { $: "Nil" };
                                                        {
                                                          const $t47563 = { $: "Cons", _0: $t47561, _1: $t47562 };
                                                          {
                                                            let $t47564;
                                                            $t47564 = { $: "Cons", _0: paid, _1: $t47563 };
                                                            {
                                                              const $t47565 = { $: "Cons", _0: landed, _1: $t47564 };
                                                              {
                                                                let $t47566;
                                                                {
                                                                  const prepend_reversed_i5496 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_ReelEvent", _0: prepend_reversed$apply$0_List_concat_List_List_ReelEvent };
                                                                  {
                                                                    const go_i5497 = { $: "$Clo_go$1_List_concat_List_List_ReelEvent", _0: go$apply$1_List_concat_List_List_ReelEvent, _1: prepend_reversed_i5496 };
                                                                    {
                                                                      const $t1124_i5498 = { $: "Nil" };
                                                                      $t47566 = go$apply$1_List_concat_List_List_ReelEvent(go_i5497, $t47565, $t1124_i5498);
                                                                    }
                                                                  }
                                                                }
                                                                {
                                                                  const $rc_2696 = { _0: spun, _1: after, _2: $t47566 };
                                                                  return $rc_2696;
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        } else {
                                          {
                                            let $t47568;
                                            {
                                              const xs_i13302 = landed;
                                              {
                                                const ys_i13303 = paid;
                                                switch (xs_i13302.$) {
                                                  case "Nil": {
                                                    $t47568 = paid;
                                                    break;
                                                  }
                                                  case "Cons": {
                                                    const $f998_i13304 = xs_i13302._0;
                                                    const $f999_i13305 = xs_i13302._1;
                                                    {
                                                      const t_i13306 = $f999_i13305;
                                                      {
                                                        const h_i13307 = $f998_i13304;
                                                        {
                                                          const $trmc11_i13308 = { $: "Cons", _0: h_i13307, _1: null };
                                                          List$append$dps$List_ReelEvent$List_ReelEvent$List_ReelEvent(t_i13306, paid, $trmc11_i13308);
                                                          $t47568 = $trmc11_i13308;
                                                        }
                                                      }
                                                    }
                                                    break;
                                                  }
                                                  default: {
                                                    throw new Error("non-exhaustive pattern match");
                                                    break;
                                                  }
                                                }
                                              }
                                            }
                                            {
                                              let $rc_2700;
                                              $rc_2700 = { _0: settled, _1: rng, _2: $t47568 };
                                              return $rc_2700;
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Reels$tick$clo = { _0: ($_, b, rng, dt) => Spin$Reels$tick(b, rng, dt) };

function Spin$Reels$in_phase(b, p) {
  {
    const $rc_2715 = ({ ...b, phase: p });
    return $rc_2715;
  }
}
const Spin$Reels$in_phase$clo = { _0: ($_, b, p) => Spin$Reels$in_phase(b, p) };

function Spin$Reels$nudge(b, i) {
  {
    let $t47578;
    {
      let $t47574;
      {
        const $t47573 = b.nudge_left;
        $t47574 = ($t47573 > 0.);
      }
      {
        let $t47577;
        {
          const $t47575 = b.phase;
          {
            const $t47576 = { $: "Idle" };
            {
              const $rc_2718 = march_deep_eq($t47575, $t47576);
              $t47577 = $rc_2718;
            }
          }
        }
        $t47578 = ($t47574 && $t47577);
      }
    }
    if ($t47578 === true) {
      {
        let r;
        r = Spin$Reels$reel_at(b, i);
        {
          let rolled;
          {
            let $t47580;
            {
              const $t47579 = r.pos;
              $t47580 = $t47579;
            }
            {
              let $t47583;
              {
                let $t47582;
                {
                  const $t47581 = r.pos;
                  $t47582 = (($t47581 + 1) < 4611686018427387904 && ($t47581 + 1) >= -4611686018427387904 ? ($t47581 + 1) : march_int_ovf(($t47581 + 1), 0));
                }
                $t47583 = Spin$Reels$wrap($t47582);
              }
              rolled = ({ ...r, from: $t47580, travel: 1., elapsed: 0., duration: 0.16, pos: $t47583 });
            }
          }
          {
            let placed;
            {
              const $t47584 = Spin$Reels$set_reel(b, i, rolled);
              {
                const $t47585 = { $: "Nudging" };
                placed = Spin$Reels$in_phase($t47584, $t47585);
              }
            }
            {
              const $t47586 = { $: "Nudged", _0: i };
              {
                const $t47587 = { $: "Nil" };
                {
                  const $t47588 = { $: "Cons", _0: $t47586, _1: $t47587 };
                  {
                    const $rc_2717 = { _0: placed, _1: $t47588 };
                    return $rc_2717;
                  }
                }
              }
            }
          }
        }
      }
    } else {
      {
        const $t47589 = { $: "Nil" };
        return { _0: b, _1: $t47589 };
      }
    }
  }
}
const Spin$Reels$nudge$clo = { _0: ($_, b, i) => Spin$Reels$nudge(b, i) };

function Spin$Reels$hold(b, i) {
  {
    let r;
    r = Spin$Reels$reel_at(b, i);
    {
      const $t47590 = r.held;
      if ($t47590 === true) {
        {
          const $t47591 = { $: "Nil" };
          return { _0: b, _1: $t47591 };
        }
      } else {
        {
          let held;
          {
            const $t47592 = ({ ...r, held: true });
            held = Spin$Reels$set_reel(b, i, $t47592);
          }
          {
            let $t47596;
            {
              const $t47593 = held.reels;
              {
                const $t47595 = { $: "$Clo_$lam0_Spin_Reels_hold$0_Spin_Reels_hold", _0: $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold };
                $t47596 = List$all$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool($t47593, $t47595);
              }
            }
            if ($t47596 === true) {
              {
                let cleared;
                {
                  const $t47597 = held.reels;
                  {
                    let $t47598;
                    $t47598 = List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t47597, Spin$Reels$unhold$clo);
                    cleared = ({ ...held, reels: $t47598, boost: 2 });
                  }
                }
                {
                  const $p47604 = Spin$Reels$bank_spin(cleared);
                  {
                    const free = $p47604._0;
                    {
                      const $t47599 = { $: "Held", _0: i };
                      {
                        const $t47600 = { $: "Doubled" };
                        {
                          const $t47601 = { $: "Nil" };
                          {
                            const $t47602 = { $: "Cons", _0: $t47600, _1: $t47601 };
                            {
                              const $t47603 = { $: "Cons", _0: $t47599, _1: $t47602 };
                              {
                                const $rc_2720 = { _0: free, _1: $t47603 };
                                return $rc_2720;
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            } else {
              {
                const $t47605 = { $: "Held", _0: i };
                {
                  const $t47606 = { $: "Nil" };
                  {
                    const $t47607 = { $: "Cons", _0: $t47605, _1: $t47606 };
                    {
                      const $rc_2725 = { _0: held, _1: $t47607 };
                      return $rc_2725;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Reels$hold$clo = { _0: ($_, b, i) => Spin$Reels$hold(b, i) };

function Spin$Style$for_stage(s) {
  {
    let k;
    {
      const $t47609 = (s <= 0);
      if ($t47609 === true) {
        k = 0;
      } else {
        {
          let $t47611;
          {
            const $t47610 = ((s - 1) < 4611686018427387904 && (s - 1) >= -4611686018427387904 ? (s - 1) : march_int_ovf((s - 1), 1));
            $t47611 = march_int_mod_euclid($t47610, 5);
          }
          k = (($t47611 + 1) < 4611686018427387904 && ($t47611 + 1) >= -4611686018427387904 ? ($t47611 + 1) : march_int_ovf(($t47611 + 1), 0));
        }
      }
    }
    if (k === 1) {
      return ({ name: "RUBBER", sub: "everything bounces", gravity: 1150., bounce: 0.22, drag: 0., wind: 0., magnet: 0., tint: "#ff8a3d" });
    } else if (k === 2) {
      return ({ name: "MOON", sub: "low gravity", gravity: 640., bounce: 0.05, drag: 0.15, wind: 0., magnet: 0., tint: "#5cf2ff" });
    } else if (k === 3) {
      {
        const $t47608_i5506 = (-0.12);
        return ({ name: "LEAD", sub: "heavy and fast", gravity: 1650., bounce: $t47608_i5506, drag: 0., wind: 0., magnet: 0., tint: "#ff3b4e" });
      }
    } else if (k === 4) {
      return ({ name: "GALE", sub: "the wind swings", gravity: 1100., bounce: 0., drag: 0., wind: 380., magnet: 0., tint: "#7dff7a" });
    } else if (k === 5) {
      return ({ name: "MAGNET", sub: "the reels pull", gravity: 1150., bounce: 0., drag: 0., wind: 0., magnet: 700., tint: "#ffd36b" });
    } else {
      return ({ name: "STEEL", sub: "the house ball", gravity: 1150., bounce: 0., drag: 0., wind: 0., magnet: 0., tint: "#b9a6ff" });
    }
  }
}
const Spin$Style$for_stage$clo = { _0: ($_, s) => Spin$Style$for_stage(s) };

function Spin$Style$climb($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const paid = $tco_a0;
    const s = $tco_a1;
    {
      let $t47638;
      {
        let $t47637;
        {
          const $t47636 = ((s + 1) < 4611686018427387904 && (s + 1) >= -4611686018427387904 ? (s + 1) : march_int_ovf((s + 1), 0));
          if ($t47636 === 0) {
            $t47637 = 0;
          } else if ($t47636 === 1) {
            $t47637 = 30;
          } else if ($t47636 === 2) {
            $t47637 = 75;
          } else if ($t47636 === 3) {
            $t47637 = 140;
          } else if ($t47636 === 4) {
            $t47637 = 230;
          } else if ($t47636 === 5) {
            $t47637 = 350;
          } else {
            {
              let $t47623_i5509;
              {
                const $t47622_i5508 = (($t47636 - 5) < 4611686018427387904 && ($t47636 - 5) >= -4611686018427387904 ? ($t47636 - 5) : march_int_ovf(($t47636 - 5), 1));
                $t47623_i5509 = ((150 * $t47622_i5508) < 4611686018427387904 && (150 * $t47622_i5508) >= -4611686018427387904 ? (150 * $t47622_i5508) : march_int_ovf((150 * $t47622_i5508), 2));
              }
              $t47637 = ((350 + $t47623_i5509) < 4611686018427387904 && (350 + $t47623_i5509) >= -4611686018427387904 ? (350 + $t47623_i5509) : march_int_ovf((350 + $t47623_i5509), 0));
            }
          }
        }
        $t47638 = (paid >= $t47637);
      }
      if ($t47638 === true) {
        {
          const $t47639 = ((s + 1) < 4611686018427387904 && (s + 1) >= -4611686018427387904 ? (s + 1) : march_int_ovf((s + 1), 0));
          {
            $tco_a0 = paid;
            $tco_a1 = $t47639;
            continue __tco;
          }
        }
      } else {
        return s;
      }
    }
    return undefined;
  }
}
const Spin$Style$climb$clo = { _0: ($_, paid, s) => Spin$Style$climb(paid, s) };

function Spin$Table$arch_point(n, i) {
  {
    let a;
    {
      const $t47640 = n.pi;
      {
        let $t47644;
        {
          let $t47643;
          {
            const $t47641 = n.pi;
            {
              const $t47642 = i;
              $t47643 = ($t47641 * $t47642);
            }
          }
          $t47644 = ($t47643 / 12.);
        }
        a = ($t47640 + $t47644);
      }
    }
    {
      let $t47647;
      {
        let $t47646;
        {
          const $t47645 = Math.cos(a);
          $t47646 = (180. * $t47645);
        }
        $t47647 = (200. + $t47646);
      }
      {
        let $t47650;
        {
          let $t47649;
          {
            const $t47648 = Math.sin(a);
            $t47649 = (180. * $t47648);
          }
          $t47650 = (200. + $t47649);
        }
        return ({ x: $t47647, y: $t47650 });
      }
    }
  }
}
const Spin$Table$arch_point$clo = { _0: ($_, n, i) => Spin$Table$arch_point(n, i) };

function Spin$Table$parts(n) {
  {
    let $t47657;
    {
      let $t47651_i5646;
      {
        const go_i14747 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
        {
          const $t926_i14748 = ((12 - 1) < 4611686018427387904 && (12 - 1) >= -4611686018427387904 ? (12 - 1) : march_int_ovf((12 - 1), 1));
          {
            const $t927_i14749 = { $: "Nil" };
            $t47651_i5646 = go$apply$0_List_range(go_i14747, $t926_i14748, $t927_i14749);
          }
        }
      }
      {
        const $t47656_i5647 = { $: "$Clo_$lam0_Spin_Table_arch$0_Spin_Table_arch", _0: $lam0_Spin_Table_arch$apply$0_Spin_Table_arch, _1: n };
        {
          const xs_i14858 = $t47651_i5646;
          {
            const f_i14859 = $t47656_i5647;
            switch (xs_i14858.$) {
              case "Nil": {
                $t47657 = { $: "Nil" };
                break;
              }
              case "Cons": {
                const $f1006_i14860 = xs_i14858._0;
                const $f1007_i14861 = xs_i14858._1;
                {
                  const t_i14862 = $f1007_i14861;
                  {
                    const h_i14863 = $f1006_i14860;
                    {
                      let $t1004_i14864;
                      $t1004_i14864 = f_i14859._0(f_i14859, h_i14863);
                      {
                        const $trmc15_i14865 = { $: "Cons", _0: $t1004_i14864, _1: null };
                        List$map$dps$List_Int$Fn_Int_Part$List_Part(t_i14862, f_i14859, $trmc15_i14865);
                        $t47657 = $trmc15_i14865;
                      }
                    }
                  }
                }
                break;
              }
              default: {
                throw new Error("non-exhaustive pattern match");
                break;
              }
            }
          }
        }
      }
    }
    {
      let $t47660;
      {
        const $t47658 = ({ x: 20., y: 200. });
        {
          const $t47659 = ({ x: 20., y: 568. });
          $t47660 = { $: "Wall", _0: $t47658, _1: $t47659, _2: 0.5 };
        }
      }
      {
        let $t47663;
        {
          const $t47661 = ({ x: 380., y: 200. });
          {
            const $t47662 = ({ x: 380., y: 760. });
            $t47663 = { $: "Wall", _0: $t47661, _1: $t47662, _2: 0.4 };
          }
        }
        {
          let $t47666;
          {
            const $t47664 = ({ x: 350., y: 262. });
            {
              const $t47665 = ({ x: 350., y: 760. });
              $t47666 = { $: "Wall", _0: $t47664, _1: $t47665, _2: 0.4 };
            }
          }
          {
            let $t47669;
            {
              const $t47667 = ({ x: 350., y: 700. });
              {
                const $t47668 = ({ x: 380., y: 700. });
                $t47669 = { $: "Wall", _0: $t47667, _1: $t47668, _2: 0.1 };
              }
            }
            {
              let $t47672;
              {
                const $t47670 = ({ x: 350., y: 262. });
                {
                  const $t47671 = ({ x: 380., y: 236. });
                  $t47672 = { $: "Gate", _0: $t47670, _1: $t47671 };
                }
              }
              {
                let $t47675;
                {
                  const $t47673 = ({ x: 20., y: 568. });
                  {
                    const $t47674 = ({ x: 124.5, y: 654.6 });
                    $t47675 = { $: "Wall", _0: $t47673, _1: $t47674, _2: 0.3 };
                  }
                }
                {
                  let $t47678;
                  {
                    const $t47676 = ({ x: 350., y: 568. });
                    {
                      const $t47677 = ({ x: 245.5, y: 654.6 });
                      $t47678 = { $: "Wall", _0: $t47676, _1: $t47677, _2: 0.3 };
                    }
                  }
                  {
                    let $t47681;
                    {
                      const $t47679 = ({ x: 62., y: 165. });
                      {
                        const $t47680 = ({ x: 62., y: 300. });
                        $t47681 = { $: "Wall", _0: $t47679, _1: $t47680, _2: 0.4 };
                      }
                    }
                    {
                      let $t47683;
                      {
                        const $t47682 = ({ x: 62., y: 165. });
                        $t47683 = { $: "Peg", _0: $t47682, _1: 4., _2: 0.4 };
                      }
                      {
                        let $t47685;
                        {
                          const $t47684 = ({ x: 62., y: 300. });
                          $t47685 = { $: "Peg", _0: $t47684, _1: 4., _2: 0.4 };
                        }
                        {
                          let $t47688;
                          {
                            const $t47686 = ({ x: 308., y: 165. });
                            {
                              const $t47687 = ({ x: 308., y: 300. });
                              $t47688 = { $: "Wall", _0: $t47686, _1: $t47687, _2: 0.4 };
                            }
                          }
                          {
                            let $t47690;
                            {
                              const $t47689 = ({ x: 308., y: 165. });
                              $t47690 = { $: "Peg", _0: $t47689, _1: 4., _2: 0.4 };
                            }
                            {
                              let $t47692;
                              {
                                const $t47691 = ({ x: 308., y: 300. });
                                $t47692 = { $: "Peg", _0: $t47691, _1: 4., _2: 0.4 };
                              }
                              {
                                let $t47696;
                                {
                                  const $t47693 = ({ x: 20., y: 232. });
                                  {
                                    const $t47694 = ({ x: 62., y: 232. });
                                    {
                                      const $t47695 = { $: "Spinner" };
                                      $t47696 = { $: "Tripwire", _0: $t47693, _1: $t47694, _2: $t47695 };
                                    }
                                  }
                                }
                                {
                                  let $t47699;
                                  {
                                    const $t47697 = ({ x: 133., y: 82. });
                                    {
                                      const $t47698 = ({ x: 133., y: 122. });
                                      $t47699 = { $: "Wall", _0: $t47697, _1: $t47698, _2: 0.4 };
                                    }
                                  }
                                  {
                                    let $t47702;
                                    {
                                      const $t47700 = ({ x: 168., y: 82. });
                                      {
                                        const $t47701 = ({ x: 168., y: 122. });
                                        $t47702 = { $: "Wall", _0: $t47700, _1: $t47701, _2: 0.4 };
                                      }
                                    }
                                    {
                                      let $t47705;
                                      {
                                        const $t47703 = ({ x: 203., y: 82. });
                                        {
                                          const $t47704 = ({ x: 203., y: 122. });
                                          $t47705 = { $: "Wall", _0: $t47703, _1: $t47704, _2: 0.4 };
                                        }
                                      }
                                      {
                                        let $t47708;
                                        {
                                          const $t47706 = ({ x: 238., y: 82. });
                                          {
                                            const $t47707 = ({ x: 238., y: 122. });
                                            $t47708 = { $: "Wall", _0: $t47706, _1: $t47707, _2: 0.4 };
                                          }
                                        }
                                        {
                                          let $t47711;
                                          {
                                            const $t47709 = ({ x: 150.5, y: 104. });
                                            {
                                              const $t47710 = { $: "HoldLane", _0: 0 };
                                              $t47711 = { $: "Sensor", _0: $t47709, _1: 9., _2: $t47710 };
                                            }
                                          }
                                          {
                                            let $t47714;
                                            {
                                              const $t47712 = ({ x: 185.5, y: 104. });
                                              {
                                                const $t47713 = { $: "HoldLane", _0: 1 };
                                                $t47714 = { $: "Sensor", _0: $t47712, _1: 9., _2: $t47713 };
                                              }
                                            }
                                            {
                                              let $t47717;
                                              {
                                                const $t47715 = ({ x: 220.5, y: 104. });
                                                {
                                                  const $t47716 = { $: "HoldLane", _0: 2 };
                                                  $t47717 = { $: "Sensor", _0: $t47715, _1: 9., _2: $t47716 };
                                                }
                                              }
                                              {
                                                let $t47720;
                                                {
                                                  const $t47718 = ({ x: 122., y: 228. });
                                                  {
                                                    const $t47719 = { $: "Bumper", _0: 0 };
                                                    $t47720 = { $: "Kicker", _0: $t47718, _1: 21., _2: $t47719 };
                                                  }
                                                }
                                                {
                                                  let $t47723;
                                                  {
                                                    const $t47721 = ({ x: 249., y: 228. });
                                                    {
                                                      const $t47722 = { $: "Bumper", _0: 1 };
                                                      $t47723 = { $: "Kicker", _0: $t47721, _1: 21., _2: $t47722 };
                                                    }
                                                  }
                                                  {
                                                    let $t47726;
                                                    {
                                                      const $t47724 = ({ x: 185.5, y: 300. });
                                                      {
                                                        const $t47725 = { $: "Bumper", _0: 2 };
                                                        $t47726 = { $: "Kicker", _0: $t47724, _1: 21., _2: $t47725 };
                                                      }
                                                    }
                                                    {
                                                      let $t47731;
                                                      {
                                                        const $t47727 = ({ x: 172., y: 168. });
                                                        {
                                                          const $t47728 = ({ x: 199., y: 168. });
                                                          {
                                                            let $t47730;
                                                            {
                                                              const $t47729 = { $: "Seven" };
                                                              $t47730 = { $: "Loader", _0: $t47729 };
                                                            }
                                                            $t47731 = { $: "Face", _0: $t47727, _1: $t47728, _2: 0., _3: $t47730 };
                                                          }
                                                        }
                                                      }
                                                      {
                                                        let $t47736;
                                                        {
                                                          const $t47732 = ({ x: 24., y: 352. });
                                                          {
                                                            const $t47733 = ({ x: 24., y: 392. });
                                                            {
                                                              let $t47735;
                                                              {
                                                                const $t47734 = { $: "Cherry" };
                                                                $t47735 = { $: "Loader", _0: $t47734 };
                                                              }
                                                              $t47736 = { $: "Face", _0: $t47732, _1: $t47733, _2: 0., _3: $t47735 };
                                                            }
                                                          }
                                                        }
                                                        {
                                                          let $t47741;
                                                          {
                                                            const $t47737 = ({ x: 24., y: 414. });
                                                            {
                                                              const $t47738 = ({ x: 24., y: 454. });
                                                              {
                                                                let $t47740;
                                                                {
                                                                  const $t47739 = { $: "Lemon" };
                                                                  $t47740 = { $: "Loader", _0: $t47739 };
                                                                }
                                                                $t47741 = { $: "Face", _0: $t47737, _1: $t47738, _2: 0., _3: $t47740 };
                                                              }
                                                            }
                                                          }
                                                          {
                                                            let $t47746;
                                                            {
                                                              const $t47742 = ({ x: 346., y: 352. });
                                                              {
                                                                const $t47743 = ({ x: 346., y: 392. });
                                                                {
                                                                  let $t47745;
                                                                  {
                                                                    const $t47744 = { $: "Bell" };
                                                                    $t47745 = { $: "Loader", _0: $t47744 };
                                                                  }
                                                                  $t47746 = { $: "Face", _0: $t47742, _1: $t47743, _2: 0., _3: $t47745 };
                                                                }
                                                              }
                                                            }
                                                            {
                                                              let $t47751;
                                                              {
                                                                const $t47747 = ({ x: 346., y: 414. });
                                                                {
                                                                  const $t47748 = ({ x: 346., y: 454. });
                                                                  {
                                                                    let $t47750;
                                                                    {
                                                                      const $t47749 = { $: "Bars" };
                                                                      $t47750 = { $: "Loader", _0: $t47749 };
                                                                    }
                                                                    $t47751 = { $: "Face", _0: $t47747, _1: $t47748, _2: 0., _3: $t47750 };
                                                                  }
                                                                }
                                                              }
                                                              {
                                                                let $t47755;
                                                                {
                                                                  const $t47752 = ({ x: 42., y: 478. });
                                                                  {
                                                                    const $t47753 = ({ x: 100., y: 595. });
                                                                    {
                                                                      const $t47754 = { $: "Sling" };
                                                                      $t47755 = { $: "Face", _0: $t47752, _1: $t47753, _2: 520., _3: $t47754 };
                                                                    }
                                                                  }
                                                                }
                                                                {
                                                                  let $t47758;
                                                                  {
                                                                    const $t47756 = ({ x: 42., y: 478. });
                                                                    {
                                                                      const $t47757 = ({ x: 42., y: 547. });
                                                                      $t47758 = { $: "Wall", _0: $t47756, _1: $t47757, _2: 0.3 };
                                                                    }
                                                                  }
                                                                  {
                                                                    let $t47761;
                                                                    {
                                                                      const $t47759 = ({ x: 42., y: 547. });
                                                                      {
                                                                        const $t47760 = ({ x: 100., y: 595. });
                                                                        $t47761 = { $: "Wall", _0: $t47759, _1: $t47760, _2: 0.3 };
                                                                      }
                                                                    }
                                                                    {
                                                                      let $t47765;
                                                                      {
                                                                        const $t47762 = ({ x: 328., y: 478. });
                                                                        {
                                                                          const $t47763 = ({ x: 270., y: 595. });
                                                                          {
                                                                            const $t47764 = { $: "Sling" };
                                                                            $t47765 = { $: "Face", _0: $t47762, _1: $t47763, _2: 520., _3: $t47764 };
                                                                          }
                                                                        }
                                                                      }
                                                                      {
                                                                        let $t47768;
                                                                        {
                                                                          const $t47766 = ({ x: 328., y: 478. });
                                                                          {
                                                                            const $t47767 = ({ x: 328., y: 547. });
                                                                            $t47768 = { $: "Wall", _0: $t47766, _1: $t47767, _2: 0.3 };
                                                                          }
                                                                        }
                                                                        {
                                                                          let $t47771;
                                                                          {
                                                                            const $t47769 = ({ x: 328., y: 547. });
                                                                            {
                                                                              const $t47770 = ({ x: 270., y: 595. });
                                                                              $t47771 = { $: "Wall", _0: $t47769, _1: $t47770, _2: 0.3 };
                                                                            }
                                                                          }
                                                                          {
                                                                            const $t47772 = { $: "Nil" };
                                                                            {
                                                                              const $t47773 = { $: "Cons", _0: $t47771, _1: $t47772 };
                                                                              {
                                                                                const $t47774 = { $: "Cons", _0: $t47768, _1: $t47773 };
                                                                                {
                                                                                  const $t47775 = { $: "Cons", _0: $t47765, _1: $t47774 };
                                                                                  {
                                                                                    const $t47776 = { $: "Cons", _0: $t47761, _1: $t47775 };
                                                                                    {
                                                                                      const $t47777 = { $: "Cons", _0: $t47758, _1: $t47776 };
                                                                                      {
                                                                                        const $t47778 = { $: "Cons", _0: $t47755, _1: $t47777 };
                                                                                        {
                                                                                          const $t47779 = { $: "Cons", _0: $t47751, _1: $t47778 };
                                                                                          {
                                                                                            const $t47780 = { $: "Cons", _0: $t47746, _1: $t47779 };
                                                                                            {
                                                                                              const $t47781 = { $: "Cons", _0: $t47741, _1: $t47780 };
                                                                                              {
                                                                                                const $t47782 = { $: "Cons", _0: $t47736, _1: $t47781 };
                                                                                                {
                                                                                                  const $t47783 = { $: "Cons", _0: $t47731, _1: $t47782 };
                                                                                                  {
                                                                                                    const $t47784 = { $: "Cons", _0: $t47726, _1: $t47783 };
                                                                                                    {
                                                                                                      const $t47785 = { $: "Cons", _0: $t47723, _1: $t47784 };
                                                                                                      {
                                                                                                        const $t47786 = { $: "Cons", _0: $t47720, _1: $t47785 };
                                                                                                        {
                                                                                                          const $t47787 = { $: "Cons", _0: $t47717, _1: $t47786 };
                                                                                                          {
                                                                                                            const $t47788 = { $: "Cons", _0: $t47714, _1: $t47787 };
                                                                                                            {
                                                                                                              const $t47789 = { $: "Cons", _0: $t47711, _1: $t47788 };
                                                                                                              {
                                                                                                                const $t47790 = { $: "Cons", _0: $t47708, _1: $t47789 };
                                                                                                                {
                                                                                                                  const $t47791 = { $: "Cons", _0: $t47705, _1: $t47790 };
                                                                                                                  {
                                                                                                                    const $t47792 = { $: "Cons", _0: $t47702, _1: $t47791 };
                                                                                                                    {
                                                                                                                      const $t47793 = { $: "Cons", _0: $t47699, _1: $t47792 };
                                                                                                                      {
                                                                                                                        const $t47794 = { $: "Cons", _0: $t47696, _1: $t47793 };
                                                                                                                        {
                                                                                                                          const $t47795 = { $: "Cons", _0: $t47692, _1: $t47794 };
                                                                                                                          {
                                                                                                                            const $t47796 = { $: "Cons", _0: $t47690, _1: $t47795 };
                                                                                                                            {
                                                                                                                              const $t47797 = { $: "Cons", _0: $t47688, _1: $t47796 };
                                                                                                                              {
                                                                                                                                const $t47798 = { $: "Cons", _0: $t47685, _1: $t47797 };
                                                                                                                                {
                                                                                                                                  const $t47799 = { $: "Cons", _0: $t47683, _1: $t47798 };
                                                                                                                                  {
                                                                                                                                    const $t47800 = { $: "Cons", _0: $t47681, _1: $t47799 };
                                                                                                                                    {
                                                                                                                                      const $t47801 = { $: "Cons", _0: $t47678, _1: $t47800 };
                                                                                                                                      {
                                                                                                                                        const $t47802 = { $: "Cons", _0: $t47675, _1: $t47801 };
                                                                                                                                        {
                                                                                                                                          const $t47803 = { $: "Cons", _0: $t47672, _1: $t47802 };
                                                                                                                                          {
                                                                                                                                            const $t47804 = { $: "Cons", _0: $t47669, _1: $t47803 };
                                                                                                                                            {
                                                                                                                                              const $t47805 = { $: "Cons", _0: $t47666, _1: $t47804 };
                                                                                                                                              {
                                                                                                                                                const $t47806 = { $: "Cons", _0: $t47663, _1: $t47805 };
                                                                                                                                                {
                                                                                                                                                  const $t47807 = { $: "Cons", _0: $t47660, _1: $t47806 };
                                                                                                                                                  {
                                                                                                                                                    const $t47808 = { $: "Nil" };
                                                                                                                                                    {
                                                                                                                                                      const $t47809 = { $: "Cons", _0: $t47807, _1: $t47808 };
                                                                                                                                                      {
                                                                                                                                                        const $t47810 = { $: "Cons", _0: $t47657, _1: $t47809 };
                                                                                                                                                        {
                                                                                                                                                          const prepend_reversed_i5522 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Part", _0: prepend_reversed$apply$0_List_concat_List_List_Part };
                                                                                                                                                          {
                                                                                                                                                            const go_i5523 = { $: "$Clo_go$1_List_concat_List_List_Part", _0: go$apply$1_List_concat_List_List_Part, _1: prepend_reversed_i5522 };
                                                                                                                                                            {
                                                                                                                                                              const $t1124_i5524 = { $: "Nil" };
                                                                                                                                                              return go$apply$1_List_concat_List_List_Part(go_i5523, $t47810, $t1124_i5524);
                                                                                                                                                            }
                                                                                                                                                          }
                                                                                                                                                        }
                                                                                                                                                      }
                                                                                                                                                    }
                                                                                                                                                  }
                                                                                                                                                }
                                                                                                                                              }
                                                                                                                                            }
                                                                                                                                          }
                                                                                                                                        }
                                                                                                                                      }
                                                                                                                                    }
                                                                                                                                  }
                                                                                                                                }
                                                                                                                              }
                                                                                                                            }
                                                                                                                          }
                                                                                                                        }
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Table$parts$clo = { _0: ($_, n) => Spin$Table$parts(n) };

function Spin$Table$extras(stage) {
  {
    const $t47811 = (stage >= 1);
    {
      let $t47820;
      if ($t47811 === true) {
        {
          let $t47814;
          {
            const $t47812 = ({ x: 84., y: 334. });
            {
              const $t47813 = { $: "Bumper", _0: 3 };
              $t47814 = { $: "Kicker", _0: $t47812, _1: 10., _2: $t47813 };
            }
          }
          {
            let $t47817;
            {
              const $t47815 = ({ x: 286., y: 334. });
              {
                const $t47816 = { $: "Bumper", _0: 4 };
                $t47817 = { $: "Kicker", _0: $t47815, _1: 10., _2: $t47816 };
              }
            }
            {
              const $t47818 = { $: "Nil" };
              {
                const $t47819 = { $: "Cons", _0: $t47817, _1: $t47818 };
                $t47820 = { $: "Cons", _0: $t47814, _1: $t47819 };
              }
            }
          }
        }
      } else {
        $t47820 = { $: "Nil" };
      }
      {
        const $t47821 = (stage >= 2);
        {
          let $t47827;
          if ($t47821 === true) {
            {
              let $t47825;
              {
                const $t47822 = ({ x: 112., y: 341. });
                {
                  const $t47823 = ({ x: 259., y: 341. });
                  {
                    const $t47824 = { $: "Bumper", _0: 5 };
                    $t47825 = { $: "Mover", _0: $t47822, _1: $t47823, _2: 12., _3: 4.2, _4: $t47824 };
                  }
                }
              }
              {
                const $t47826 = { $: "Nil" };
                $t47827 = { $: "Cons", _0: $t47825, _1: $t47826 };
              }
            }
          } else {
            $t47827 = { $: "Nil" };
          }
          {
            const $t47828 = (stage >= 3);
            {
              let $t47834;
              if ($t47828 === true) {
                {
                  let $t47832;
                  {
                    const $t47829 = ({ x: 308., y: 232. });
                    {
                      const $t47830 = ({ x: 350., y: 232. });
                      {
                        const $t47831 = { $: "Spinner" };
                        $t47832 = { $: "Tripwire", _0: $t47829, _1: $t47830, _2: $t47831 };
                      }
                    }
                  }
                  {
                    const $t47833 = { $: "Nil" };
                    $t47834 = { $: "Cons", _0: $t47832, _1: $t47833 };
                  }
                }
              } else {
                $t47834 = { $: "Nil" };
              }
              {
                const $t47835 = { $: "Nil" };
                {
                  const $t47836 = { $: "Cons", _0: $t47834, _1: $t47835 };
                  {
                    const $t47837 = { $: "Cons", _0: $t47827, _1: $t47836 };
                    {
                      const $t47838 = { $: "Cons", _0: $t47820, _1: $t47837 };
                      {
                        const prepend_reversed_i5649 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Part", _0: prepend_reversed$apply$0_List_concat_List_List_Part };
                        {
                          const go_i5650 = { $: "$Clo_go$1_List_concat_List_List_Part", _0: go$apply$1_List_concat_List_List_Part, _1: prepend_reversed_i5649 };
                          {
                            const $t1124_i5651 = { $: "Nil" };
                            return go$apply$1_List_concat_List_List_Part(go_i5650, $t47838, $t1124_i5651);
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$Table$extras$clo = { _0: ($_, stage) => Spin$Table$extras(stage) };

function Spin$Table$mover_at(a, b, period, t, n) {
  {
    let w;
    {
      const $t47839 = n.tau;
      w = ($t47839 / period);
    }
    {
      let k;
      {
        let $t47842;
        {
          let $t47841;
          {
            const $t47840 = (w * t);
            $t47841 = Math.cos($t47840);
          }
          $t47842 = (0.5 * $t47841);
        }
        k = (0.5 - $t47842);
      }
      {
        let dk;
        {
          const $t47843 = (0.5 * w);
          {
            let $t47845;
            {
              const $t47844 = (w * t);
              $t47845 = Math.sin($t47844);
            }
            dk = ($t47843 * $t47845);
          }
        }
        {
          let ab;
          ab = Arcade$Vec2$sub(b, a);
          {
            let $t47847;
            {
              let $t47846;
              $t47846 = Arcade$Vec2$scale(ab, k);
              $t47847 = Arcade$Vec2$add(a, $t47846);
            }
            {
              const $t47848 = Arcade$Vec2$scale(ab, dk);
              return { _0: $t47847, _1: $t47848 };
            }
          }
        }
      }
    }
  }
}
const Spin$Table$mover_at$clo = { _0: ($_, a, b, period, t, n) => Spin$Table$mover_at(a, b, period, t, n) };

function Spin$Table$layout_at(n, stage) {
  {
    const base = Spin$Table$layout(n);
    {
      const $t47849 = base.parts;
      {
        const $t47850 = Spin$Table$extras(stage);
        {
          let $t47851;
          {
            const xs_i13312 = $t47849;
            {
              const ys_i13313 = $t47850;
              switch (xs_i13312.$) {
                case "Nil": {
                  $t47851 = $t47850;
                  break;
                }
                case "Cons": {
                  const $f998_i13314 = xs_i13312._0;
                  const $f999_i13315 = xs_i13312._1;
                  {
                    const t_i13316 = $f999_i13315;
                    {
                      const h_i13317 = $f998_i13314;
                      {
                        const $trmc11_i13318 = { $: "Cons", _0: h_i13317, _1: null };
                        List$append$dps$List_Part$List_Part$List_Part(t_i13316, $t47850, $trmc11_i13318);
                        $t47851 = $trmc11_i13318;
                      }
                    }
                  }
                  break;
                }
                default: {
                  throw new Error("non-exhaustive pattern match");
                  break;
                }
              }
            }
          }
          {
            const $rc_2728 = ({ ...base, parts: $t47851 });
            return $rc_2728;
          }
        }
      }
    }
  }
}
const Spin$Table$layout_at$clo = { _0: ($_, n, stage) => Spin$Table$layout_at(n, stage) };

function Spin$Table$layout(n) {
  {
    let $t47852;
    $t47852 = Spin$Table$parts(n);
    {
      let $t47855;
      {
        const $t47853 = ({ x: 120., y: 660. });
        {
          const $t47854 = (-0.45);
          $t47855 = ({ pivot: $t47853, length: 54., radius: 7., rest: 0.52, up: $t47854 });
        }
      }
      {
        let $t47861;
        {
          const $t47856 = ({ x: 250., y: 660. });
          {
            let $t47858;
            {
              const $t47857 = n.pi;
              $t47858 = ($t47857 - 0.52);
            }
            {
              let $t47860;
              {
                const $t47859 = n.pi;
                $t47860 = ($t47859 + 0.45);
              }
              $t47861 = ({ pivot: $t47856, length: 54., radius: 7., rest: $t47858, up: $t47860 });
            }
          }
        }
        {
          const $t47862 = ({ x: 365., y: 690. });
          {
            const $t47863 = { _0: 95., _1: 378., _2: 180., _3: 96. };
            return ({ parts: $t47852, left: $t47855, right: $t47861, ball_radius: 9., plunger_rest: $t47862, drain_y: 770., width: 400., height: 760., reel_window: $t47863 });
          }
        }
      }
    }
  }
}
const Spin$Table$layout$clo = { _0: ($_, n) => Spin$Table$layout(n) };

function Spin$Table$tip(f, a) {
  {
    const $t47864 = f.pivot;
    {
      let $t47869;
      {
        let $t47867;
        {
          const $t47865 = Math.cos(a);
          {
            const $t47866 = Math.sin(a);
            $t47867 = ({ x: $t47865, y: $t47866 });
          }
        }
        {
          const $t47868 = f.length;
          $t47869 = Arcade$Vec2$scale($t47867, $t47868);
        }
      }
      return Arcade$Vec2$add($t47864, $t47869);
    }
  }
}
const Spin$Table$tip$clo = { _0: ($_, f, a) => Spin$Table$tip(f, a) };

function Spin$Table$in_lane(p) {
  {
    let $t47871;
    {
      const $t47870 = p.x;
      $t47871 = ($t47870 > 350.);
    }
    {
      let $t47873;
      {
        const $t47872 = p.y;
        $t47873 = ($t47872 > 262.);
      }
      return ($t47871 && $t47873);
    }
  }
}
const Spin$Table$in_lane$clo = { _0: ($_, p) => Spin$Table$in_lane(p) };

function Spin$View$colour(s) {
  switch (s.$) {
    case "Blank": {
      return "#888888";
      break;
    }
    case "Cherry": {
      return "#ff3b4e";
      break;
    }
    case "Lemon": {
      return "#ffe14d";
      break;
    }
    case "Bell": {
      return "#ffb327";
      break;
    }
    case "Bars": {
      return "#f2f2ff";
      break;
    }
    case "Seven": {
      return "#ff2d6f";
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const Spin$View$colour$clo = { _0: ($_, s) => Spin$View$colour(s) };

function Spin$View$symbol(n, s, cx, cy, k) {
  switch (s.$) {
    case "Blank": {
      return { $: "Nil" };
      break;
    }
    case "Cherry": {
      {
        let $t47898;
        {
          let $t47891;
          {
            let $t47888;
            {
              const $t47887 = (6. * k);
              $t47888 = (cx - $t47887);
            }
            {
              let $t47890;
              {
                const $t47889 = (2. * k);
                $t47890 = (cy + $t47889);
              }
              $t47891 = ({ x: $t47888, y: $t47890 });
            }
          }
          {
            let $t47896;
            {
              let $t47893;
              {
                const $t47892 = (2. * k);
                $t47893 = (cx + $t47892);
              }
              {
                let $t47895;
                {
                  const $t47894 = (10. * k);
                  $t47895 = (cy - $t47894);
                }
                $t47896 = ({ x: $t47893, y: $t47895 });
              }
            }
            {
              const $t47897 = (2. * k);
              $t47898 = Spin$Draw$stick($t47891, $t47896, $t47897, "#3fbf4f");
            }
          }
        }
        {
          let $t47910;
          {
            let $t47903;
            {
              let $t47900;
              {
                const $t47899 = (6. * k);
                $t47900 = (cx + $t47899);
              }
              {
                const $t47902 = (cy + k);
                $t47903 = ({ x: $t47900, y: $t47902 });
              }
            }
            {
              let $t47908;
              {
                let $t47905;
                {
                  const $t47904 = (2. * k);
                  $t47905 = (cx + $t47904);
                }
                {
                  let $t47907;
                  {
                    const $t47906 = (10. * k);
                    $t47907 = (cy - $t47906);
                  }
                  $t47908 = ({ x: $t47905, y: $t47907 });
                }
              }
              {
                const $t47909 = (2. * k);
                $t47910 = Spin$Draw$stick($t47903, $t47908, $t47909, "#3fbf4f");
              }
            }
          }
          {
            let $t47917;
            {
              let $t47912;
              {
                const $t47911 = (6. * k);
                $t47912 = (cx - $t47911);
              }
              {
                let $t47914;
                {
                  const $t47913 = (5. * k);
                  $t47914 = (cy + $t47913);
                }
                {
                  const $t47915 = (6.5 * k);
                  {
                    const $t47916 = Spin$View$colour(s);
                    $t47917 = { $: "Disc", _0: $t47912, _1: $t47914, _2: $t47915, _3: $t47916 };
                  }
                }
              }
            }
            {
              let $t47924;
              {
                let $t47919;
                {
                  const $t47918 = (6. * k);
                  $t47919 = (cx + $t47918);
                }
                {
                  let $t47921;
                  {
                    const $t47920 = (4. * k);
                    $t47921 = (cy + $t47920);
                  }
                  {
                    const $t47922 = (6.5 * k);
                    {
                      const $t47923 = Spin$View$colour(s);
                      $t47924 = { $: "Disc", _0: $t47919, _1: $t47921, _2: $t47922, _3: $t47923 };
                    }
                  }
                }
              }
              {
                let $t47930;
                {
                  let $t47926;
                  {
                    const $t47925 = (8. * k);
                    $t47926 = (cx - $t47925);
                  }
                  {
                    let $t47928;
                    {
                      const $t47927 = (3. * k);
                      $t47928 = (cy + $t47927);
                    }
                    {
                      const $t47929 = (1.8 * k);
                      $t47930 = { $: "Disc", _0: $t47926, _1: $t47928, _2: $t47929, _3: "#ffd0d6" };
                    }
                  }
                }
                {
                  const $t47931 = { $: "Nil" };
                  {
                    const $t47932 = { $: "Cons", _0: $t47930, _1: $t47931 };
                    {
                      const $t47933 = { $: "Cons", _0: $t47924, _1: $t47932 };
                      {
                        const $t47934 = { $: "Cons", _0: $t47917, _1: $t47933 };
                        {
                          const $t47935 = { $: "Cons", _0: $t47910, _1: $t47934 };
                          return { $: "Cons", _0: $t47898, _1: $t47935 };
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      break;
    }
    case "Lemon": {
      {
        let $t47940;
        {
          const $t47936 = (12. * k);
          {
            const $t47937 = (8.5 * k);
            {
              let $t47938;
              {
                let $t47875_i5710;
                {
                  const go_i14770 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                  {
                    const $t926_i14771 = ((12 - 1) < 4611686018427387904 && (12 - 1) >= -4611686018427387904 ? (12 - 1) : march_int_ovf((12 - 1), 1));
                    {
                      const $t927_i14772 = { $: "Nil" };
                      $t47875_i5710 = go$apply$0_List_range(go_i14770, $t926_i14771, $t927_i14772);
                    }
                  }
                }
                {
                  const $t47886_i5711 = { $: "$Clo_$lam0_Spin_View_ellipse$0_Spin_View_ellipse", _0: $lam0_Spin_View_ellipse$apply$0_Spin_View_ellipse, _1: cx, _2: cy, _3: n, _4: $t47936, _5: $t47937 };
                  $t47938 = List$map$List_Int$Fn_Int_R_x_Float_y_Float($t47875_i5710, $t47886_i5711);
                }
              }
              {
                const $t47939 = Spin$View$colour(s);
                $t47940 = { $: "Poly", _0: $t47938, _1: $t47939 };
              }
            }
          }
        }
        {
          let $t47946;
          {
            let $t47942;
            {
              const $t47941 = (4. * k);
              $t47942 = (cx - $t47941);
            }
            {
              let $t47944;
              {
                const $t47943 = (3. * k);
                $t47944 = (cy - $t47943);
              }
              {
                const $t47945 = (2. * k);
                $t47946 = { $: "Disc", _0: $t47942, _1: $t47944, _2: $t47945, _3: "#fff7c2" };
              }
            }
          }
          {
            const $t47947 = { $: "Nil" };
            {
              const $t47948 = { $: "Cons", _0: $t47946, _1: $t47947 };
              return { $: "Cons", _0: $t47940, _1: $t47948 };
            }
          }
        }
      }
      break;
    }
    case "Bell": {
      {
        let $t47987;
        {
          let $t47953;
          {
            let $t47950;
            {
              const $t47949 = (11. * k);
              $t47950 = (cx - $t47949);
            }
            {
              let $t47952;
              {
                const $t47951 = (8. * k);
                $t47952 = (cy + $t47951);
              }
              $t47953 = ({ x: $t47950, y: $t47952 });
            }
          }
          {
            let $t47958;
            {
              let $t47955;
              {
                const $t47954 = (8. * k);
                $t47955 = (cx - $t47954);
              }
              {
                const $t47957 = (cy - k);
                $t47958 = ({ x: $t47955, y: $t47957 });
              }
            }
            {
              let $t47963;
              {
                let $t47960;
                {
                  const $t47959 = (5. * k);
                  $t47960 = (cx - $t47959);
                }
                {
                  let $t47962;
                  {
                    const $t47961 = (9. * k);
                    $t47962 = (cy - $t47961);
                  }
                  $t47963 = ({ x: $t47960, y: $t47962 });
                }
              }
              {
                let $t47968;
                {
                  let $t47965;
                  {
                    const $t47964 = (5. * k);
                    $t47965 = (cx + $t47964);
                  }
                  {
                    let $t47967;
                    {
                      const $t47966 = (9. * k);
                      $t47967 = (cy - $t47966);
                    }
                    $t47968 = ({ x: $t47965, y: $t47967 });
                  }
                }
                {
                  let $t47973;
                  {
                    let $t47970;
                    {
                      const $t47969 = (8. * k);
                      $t47970 = (cx + $t47969);
                    }
                    {
                      const $t47972 = (cy - k);
                      $t47973 = ({ x: $t47970, y: $t47972 });
                    }
                  }
                  {
                    let $t47978;
                    {
                      let $t47975;
                      {
                        const $t47974 = (11. * k);
                        $t47975 = (cx + $t47974);
                      }
                      {
                        let $t47977;
                        {
                          const $t47976 = (8. * k);
                          $t47977 = (cy + $t47976);
                        }
                        $t47978 = ({ x: $t47975, y: $t47977 });
                      }
                    }
                    {
                      const $t47979 = { $: "Nil" };
                      {
                        const $t47980 = { $: "Cons", _0: $t47978, _1: $t47979 };
                        {
                          const $t47981 = { $: "Cons", _0: $t47973, _1: $t47980 };
                          {
                            const $t47982 = { $: "Cons", _0: $t47968, _1: $t47981 };
                            {
                              const $t47983 = { $: "Cons", _0: $t47963, _1: $t47982 };
                              {
                                const $t47984 = { $: "Cons", _0: $t47958, _1: $t47983 };
                                {
                                  const $t47985 = { $: "Cons", _0: $t47953, _1: $t47984 };
                                  {
                                    const $t47986 = Spin$View$colour(s);
                                    $t47987 = { $: "Poly", _0: $t47985, _1: $t47986 };
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        {
          let $t47991;
          {
            let $t47989;
            {
              const $t47988 = (9. * k);
              $t47989 = (cy + $t47988);
            }
            {
              const $t47990 = (3. * k);
              $t47991 = { $: "Disc", _0: cx, _1: $t47989, _2: $t47990, _3: "#c47a00" };
            }
          }
          {
            let $t47995;
            {
              let $t47993;
              {
                const $t47992 = (11. * k);
                $t47993 = (cy - $t47992);
              }
              {
                const $t47994 = (2. * k);
                $t47995 = { $: "Disc", _0: cx, _1: $t47993, _2: $t47994, _3: "#c47a00" };
              }
            }
            {
              const $t47996 = { $: "Nil" };
              {
                const $t47997 = { $: "Cons", _0: $t47995, _1: $t47996 };
                {
                  const $t47998 = { $: "Cons", _0: $t47991, _1: $t47997 };
                  return { $: "Cons", _0: $t47987, _1: $t47998 };
                }
              }
            }
          }
        }
      }
      break;
    }
    case "Bars": {
      {
        let $t48005;
        {
          let $t48000;
          {
            const $t47999 = (17. * k);
            $t48000 = (cx - $t47999);
          }
          {
            let $t48002;
            {
              const $t48001 = (7.5 * k);
              $t48002 = (cy - $t48001);
            }
            {
              const $t48003 = (34. * k);
              {
                const $t48004 = (15. * k);
                $t48005 = { $: "Box", _0: $t48000, _1: $t48002, _2: $t48003, _3: $t48004, _4: "#1b1b24" };
              }
            }
          }
        }
        {
          let $t48010;
          {
            let $t48007;
            {
              const $t48006 = (0.5 * k);
              $t48007 = (cy + $t48006);
            }
            {
              const $t48008 = (10. * k);
              {
                const $t48009 = Spin$View$colour(s);
                $t48010 = { $: "Label", _0: "BAR", _1: cx, _2: $t48007, _3: $t48008, _4: $t48009 };
              }
            }
          }
          {
            const $t48011 = { $: "Nil" };
            {
              const $t48012 = { $: "Cons", _0: $t48010, _1: $t48011 };
              return { $: "Cons", _0: $t48005, _1: $t48012 };
            }
          }
        }
      }
      break;
    }
    case "Seven": {
      {
        let $t48018;
        {
          const $t48014 = (cx + k);
          {
            let $t48016;
            {
              const $t48015 = (1.5 * k);
              $t48016 = (cy + $t48015);
            }
            {
              const $t48017 = (28. * k);
              $t48018 = { $: "Label", _0: "7", _1: $t48014, _2: $t48016, _3: $t48017, _4: "#5a0018" };
            }
          }
        }
        {
          let $t48021;
          {
            const $t48019 = (28. * k);
            {
              const $t48020 = Spin$View$colour(s);
              $t48021 = { $: "Label", _0: "7", _1: cx, _2: cy, _3: $t48019, _4: $t48020 };
            }
          }
          {
            const $t48022 = { $: "Nil" };
            {
              const $t48023 = { $: "Cons", _0: $t48021, _1: $t48022 };
              return { $: "Cons", _0: $t48018, _1: $t48023 };
            }
          }
        }
      }
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const Spin$View$symbol$clo = { _0: ($_, n, s, cx, cy, k) => Spin$View$symbol(n, s, cx, cy, k) };

function Spin$View$reel_ops(m, i) {
  {
    let $p48093;
    {
      const $t48024 = m.table;
      $p48093 = $t48024.reel_window;
    }
    {
      const wx = $p48093._0;
      {
        const wy = $p48093._1;
        {
          const wh = $p48093._3;
          {
            let r;
            {
              const $t48025 = m.bank;
              r = Spin$Reels$reel_at($t48025, i);
            }
            {
              let x0;
              {
                let $t48027;
                {
                  const $t48026 = i;
                  $t48027 = (60. * $t48026);
                }
                x0 = (wx + $t48027);
              }
              {
                let line_y;
                {
                  const $t48028 = (wh / 2.);
                  line_y = (wy + $t48028);
                }
                {
                  let shown;
                  shown = Spin$Reels$shown(r);
                  {
                    const base = Math.floor(shown);
                    {
                      let frac;
                      {
                        const $t48029 = base;
                        frac = (shown - $t48029);
                      }
                      {
                        const $t48030 = march_int_ovf(-(2), 3);
                        {
                          let $t48031;
                          {
                            const go_i5766 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: $t48030 };
                            {
                              const $t926_i5767 = ((3 - 1) < 4611686018427387904 && (3 - 1) >= -4611686018427387904 ? (3 - 1) : march_int_ovf((3 - 1), 1));
                              {
                                const $t927_i5768 = { $: "Nil" };
                                $t48031 = go$apply$0_List_range(go_i5766, $t926_i5767, $t927_i5768);
                              }
                            }
                          }
                          {
                            let $t48051;
                            $t48051 = { $: "$Clo_$lam0_Spin_View_reel_ops$0_Spin_View_reel_ops", _0: $lam0_Spin_View_reel_ops$apply$0_Spin_View_reel_ops, _1: base, _2: frac, _3: line_y, _4: m, _5: r, _6: x0 };
                            {
                              const $t48052 = List$map$List_Int$Fn_Int_List_Op($t48031, $t48051);
                              {
                                let cells;
                                {
                                  const prepend_reversed_i5761 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                  {
                                    const go_i5762 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5761 };
                                    {
                                      const $t1124_i5763 = { $: "Nil" };
                                      cells = go$apply$1_List_concat_List_List_Op(go_i5762, $t48052, $t1124_i5763);
                                    }
                                  }
                                }
                                {
                                  const $t48053 = r.held;
                                  {
                                    let held;
                                    if ($t48053 === true) {
                                      {
                                        let $t48057;
                                        {
                                          const $t48054 = (x0 + 2.);
                                          {
                                            let $t48056;
                                            {
                                              const $t48055 = (wy + wh);
                                              $t48056 = ($t48055 - 14.);
                                            }
                                            $t48057 = { $: "Box", _0: $t48054, _1: $t48056, _2: 56., _3: 12., _4: "rgba(40,200,90,0.85)" };
                                          }
                                        }
                                        {
                                          let $t48061;
                                          {
                                            const $t48058 = (x0 + 30.);
                                            {
                                              let $t48060;
                                              {
                                                const $t48059 = (wy + wh);
                                                $t48060 = ($t48059 - 8.);
                                              }
                                              $t48061 = { $: "Label", _0: "HELD", _1: $t48058, _2: $t48060, _3: 9., _4: "#eaffea" };
                                            }
                                          }
                                          {
                                            const $t48062 = { $: "Nil" };
                                            {
                                              const $t48063 = { $: "Cons", _0: $t48061, _1: $t48062 };
                                              held = { $: "Cons", _0: $t48057, _1: $t48063 };
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      held = { $: "Nil" };
                                    }
                                    {
                                      const $t48064 = { $: "ClipBox", _0: x0, _1: wy, _2: 60., _3: wh };
                                      {
                                        const $t48065 = { $: "Box", _0: x0, _1: wy, _2: 60., _3: wh, _4: "#f6f0e2" };
                                        {
                                          const $t48066 = { $: "Nil" };
                                          {
                                            const $t48067 = { $: "Cons", _0: $t48065, _1: $t48066 };
                                            {
                                              const $t48068 = { $: "Cons", _0: $t48064, _1: $t48067 };
                                              {
                                                const $t48069 = { $: "Box", _0: x0, _1: wy, _2: 60., _3: 14., _4: "rgba(0,0,0,0.22)" };
                                                {
                                                  let $t48072;
                                                  {
                                                    let $t48071;
                                                    {
                                                      const $t48070 = (wy + wh);
                                                      $t48071 = ($t48070 - 14.);
                                                    }
                                                    $t48072 = { $: "Box", _0: x0, _1: $t48071, _2: 60., _3: 14., _4: "rgba(0,0,0,0.22)" };
                                                  }
                                                  {
                                                    const $t48073 = { $: "Nil" };
                                                    {
                                                      const $t48074 = { $: "Cons", _0: $t48072, _1: $t48073 };
                                                      {
                                                        const $t48075 = { $: "Cons", _0: $t48069, _1: $t48074 };
                                                        {
                                                          const $t48076 = { $: "Unclip" };
                                                          {
                                                            const $t48077 = { $: "Nil" };
                                                            {
                                                              const $t48078 = { $: "Cons", _0: $t48076, _1: $t48077 };
                                                              {
                                                                const $t48079 = (i > 0);
                                                                {
                                                                  let $t48085;
                                                                  if ($t48079 === true) {
                                                                    {
                                                                      let $t48083;
                                                                      {
                                                                        const $t48080 = ({ x: x0, y: wy });
                                                                        {
                                                                          let $t48082;
                                                                          {
                                                                            const $t48081 = (wy + wh);
                                                                            $t48082 = ({ x: x0, y: $t48081 });
                                                                          }
                                                                          $t48083 = Spin$Draw$stick($t48080, $t48082, 2., "#3a2350");
                                                                        }
                                                                      }
                                                                      {
                                                                        const $t48084 = { $: "Nil" };
                                                                        $t48085 = { $: "Cons", _0: $t48083, _1: $t48084 };
                                                                      }
                                                                    }
                                                                  } else {
                                                                    $t48085 = { $: "Nil" };
                                                                  }
                                                                  {
                                                                    const $t48086 = { $: "Nil" };
                                                                    {
                                                                      const $t48087 = { $: "Cons", _0: $t48085, _1: $t48086 };
                                                                      {
                                                                        const $t48088 = { $: "Cons", _0: $t48078, _1: $t48087 };
                                                                        {
                                                                          const $t48089 = { $: "Cons", _0: held, _1: $t48088 };
                                                                          {
                                                                            const $t48090 = { $: "Cons", _0: $t48075, _1: $t48089 };
                                                                            {
                                                                              const $t48091 = { $: "Cons", _0: cells, _1: $t48090 };
                                                                              {
                                                                                const $t48092 = { $: "Cons", _0: $t48068, _1: $t48091 };
                                                                                {
                                                                                  const prepend_reversed_i5748 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                                                  {
                                                                                    const go_i5749 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5748 };
                                                                                    {
                                                                                      const $t1124_i5750 = { $: "Nil" };
                                                                                      return go$apply$1_List_concat_List_List_Op(go_i5749, $t48092, $t1124_i5750);
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$reel_ops$clo = { _0: ($_, m, i) => Spin$View$reel_ops(m, i) };

function Spin$View$armed_ops(m) {
  {
    let $p48123;
    {
      const $t48094 = m.table;
      $p48123 = $t48094.reel_window;
    }
    {
      const wx = $p48123._0;
      {
        const wy = $p48123._1;
        {
          let cx;
          {
            const $t48095 = (wx + 30.);
            {
              let $t48099;
              {
                let $t48098;
                {
                  let $t48097;
                  {
                    const $t48096 = m.bank;
                    $t48097 = $t48096.armed;
                  }
                  $t48098 = $t48097;
                }
                $t48099 = (60. * $t48098);
              }
              cx = ($t48095 + $t48099);
            }
          }
          {
            let pulse;
            {
              let $t48103;
              {
                let $t48102;
                {
                  let $t48101;
                  {
                    const $t48100 = m.clock;
                    $t48101 = ($t48100 * 6.);
                  }
                  $t48102 = Math.sin($t48101);
                }
                $t48103 = (0.4 * $t48102);
              }
              pulse = (0.6 + $t48103);
            }
            {
              let $t48117;
              {
                let $t48106;
                {
                  const $t48104 = (cx - 7.);
                  {
                    const $t48105 = (wy - 16.);
                    $t48106 = ({ x: $t48104, y: $t48105 });
                  }
                }
                {
                  let $t48109;
                  {
                    const $t48107 = (cx + 7.);
                    {
                      const $t48108 = (wy - 16.);
                      $t48109 = ({ x: $t48107, y: $t48108 });
                    }
                  }
                  {
                    let $t48111;
                    {
                      const $t48110 = (wy - 7.);
                      $t48111 = ({ x: cx, y: $t48110 });
                    }
                    {
                      const $t48112 = { $: "Nil" };
                      {
                        const $t48113 = { $: "Cons", _0: $t48111, _1: $t48112 };
                        {
                          const $t48114 = { $: "Cons", _0: $t48109, _1: $t48113 };
                          {
                            const $t48115 = { $: "Cons", _0: $t48106, _1: $t48114 };
                            {
                              const $t48116 = Spin$Draw$rgba(124, 255, 122, pulse);
                              $t48117 = { $: "Poly", _0: $t48115, _1: $t48116 };
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              {
                let $t48120;
                {
                  const $t48118 = (wy - 21.);
                  {
                    const $t48119 = Spin$Draw$rgba(124, 255, 122, pulse);
                    $t48120 = { $: "Label", _0: "LOAD", _1: cx, _2: $t48118, _3: 7., _4: $t48119 };
                  }
                }
                {
                  const $t48121 = { $: "Nil" };
                  {
                    const $t48122 = { $: "Cons", _0: $t48120, _1: $t48121 };
                    return { $: "Cons", _0: $t48117, _1: $t48122 };
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$armed_ops$clo = { _0: ($_, m) => Spin$View$armed_ops(m) };

function Spin$View$machine_ops(m) {
  {
    let $p48210;
    {
      const $t48124 = m.table;
      $p48210 = $t48124.reel_window;
    }
    {
      const wx = $p48210._0;
      {
        const wy = $p48210._1;
        {
          const ww = $p48210._2;
          {
            const wh = $p48210._3;
            {
              const b = m.bank;
              {
                let line_y;
                {
                  const $t48125 = (wh / 2.);
                  line_y = (wy + $t48125);
                }
                {
                  let $t48127;
                  {
                    const go_i5806 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                    {
                      const $t926_i5807 = ((5 - 1) < 4611686018427387904 && (5 - 1) >= -4611686018427387904 ? (5 - 1) : march_int_ovf((5 - 1), 1));
                      {
                        const $t927_i5808 = { $: "Nil" };
                        $t48127 = go$apply$0_List_range(go_i5806, $t926_i5807, $t927_i5808);
                      }
                    }
                  }
                  {
                    let $t48140;
                    $t48140 = { $: "$Clo_$lam0_Spin_View_machine_ops$0_Spin_View_machine_ops", _0: $lam0_Spin_View_machine_ops$apply$0_Spin_View_machine_ops, _1: b, _2: wh, _3: ww, _4: wx, _5: wy };
                    {
                      const spins = List$map$List_Int$Fn_Int_Op($t48127, $t48140);
                      {
                        let $t48142;
                        {
                          const $t48141 = b.nudge_left;
                          $t48142 = ($t48141 > 0.);
                        }
                        {
                          let nudge;
                          if ($t48142 === true) {
                            {
                              let f;
                              {
                                const $t48143 = b.nudge_left;
                                f = ($t48143 / 4.);
                              }
                              {
                                let $t48148;
                                {
                                  let $t48146;
                                  {
                                    const $t48145 = (wy + wh);
                                    $t48146 = ($t48145 + 26.);
                                  }
                                  {
                                    const $t48147 = (ww * f);
                                    $t48148 = { $: "Box", _0: wx, _1: $t48146, _2: $t48147, _3: 5., _4: "#ff3fa4" };
                                  }
                                }
                                {
                                  let $t48153;
                                  {
                                    let $t48150;
                                    {
                                      const $t48149 = (ww / 2.);
                                      $t48150 = (wx + $t48149);
                                    }
                                    {
                                      let $t48152;
                                      {
                                        const $t48151 = (wy + wh);
                                        $t48152 = ($t48151 + 40.);
                                      }
                                      $t48153 = { $: "Label", _0: "NUDGE", _1: $t48150, _2: $t48152, _3: 10., _4: "#ff8fcf" };
                                    }
                                  }
                                  {
                                    const $t48154 = { $: "Nil" };
                                    {
                                      const $t48155 = { $: "Cons", _0: $t48153, _1: $t48154 };
                                      nudge = { $: "Cons", _0: $t48148, _1: $t48155 };
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            nudge = { $: "Nil" };
                          }
                          {
                            let $t48157;
                            {
                              const $t48156 = b.boost;
                              $t48157 = ($t48156 > 1);
                            }
                            {
                              let boost;
                              if ($t48157 === true) {
                                {
                                  let $t48164;
                                  {
                                    let $t48160;
                                    {
                                      let $t48159;
                                      {
                                        const $t48158 = b.boost;
                                        $t48159 = String($t48158);
                                      }
                                      {
                                        const $rc_2729 = ("x" + $t48159);
                                        $t48160 = $rc_2729;
                                      }
                                    }
                                    {
                                      let $t48162;
                                      {
                                        const $t48161 = (wx + ww);
                                        $t48162 = ($t48161 + 18.);
                                      }
                                      $t48164 = { $: "Label", _0: $t48160, _1: $t48162, _2: line_y, _3: 16., _4: "#ffd36b" };
                                    }
                                  }
                                  {
                                    const $t48165 = { $: "Nil" };
                                    {
                                      const $rc_2731 = { $: "Cons", _0: $t48164, _1: $t48165 };
                                      boost = $rc_2731;
                                    }
                                  }
                                }
                              } else {
                                boost = { $: "Nil" };
                              }
                              {
                                let $t48170;
                                {
                                  const $t48166 = (wx - 8.);
                                  {
                                    const $t48167 = (wy - 8.);
                                    {
                                      const $t48168 = (ww + 16.);
                                      {
                                        const $t48169 = (wh + 16.);
                                        $t48170 = { $: "Box", _0: $t48166, _1: $t48167, _2: $t48168, _3: $t48169, _4: "#2b1645" };
                                      }
                                    }
                                  }
                                }
                                {
                                  let $t48176;
                                  {
                                    const $t48171 = (wx - 4.);
                                    {
                                      const $t48172 = (wy - 4.);
                                      {
                                        const $t48173 = (ww + 8.);
                                        {
                                          const $t48174 = (wh + 8.);
                                          $t48176 = { $: "Box", _0: $t48171, _1: $t48172, _2: $t48173, _3: $t48174, _4: "#ffd36b" };
                                        }
                                      }
                                    }
                                  }
                                  {
                                    const $t48177 = { $: "Nil" };
                                    {
                                      const $t48178 = { $: "Cons", _0: $t48176, _1: $t48177 };
                                      {
                                        const $t48179 = { $: "Cons", _0: $t48170, _1: $t48178 };
                                        {
                                          const $t48180 = { $: "Nil" };
                                          {
                                            const $t48181 = { $: "Cons", _0: 2, _1: $t48180 };
                                            {
                                              const $t48182 = { $: "Cons", _0: 1, _1: $t48181 };
                                              {
                                                const $t48183 = { $: "Cons", _0: 0, _1: $t48182 };
                                                {
                                                  let $t48185;
                                                  $t48185 = { $: "$Clo_$lam1_Spin_View_machine_ops$1_Spin_View_machine_ops", _0: $lam1_Spin_View_machine_ops$apply$1_Spin_View_machine_ops, _1: m };
                                                  {
                                                    const $t48186 = List$map$List_Int$Fn_Int_List_Op($t48183, $t48185);
                                                    {
                                                      let $t48187;
                                                      {
                                                        const prepend_reversed_i5791 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                        {
                                                          const go_i5792 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5791 };
                                                          {
                                                            const $t1124_i5793 = { $: "Nil" };
                                                            $t48187 = go$apply$1_List_concat_List_List_Op(go_i5792, $t48186, $t1124_i5793);
                                                          }
                                                        }
                                                      }
                                                      {
                                                        let $t48191;
                                                        {
                                                          const $t48188 = (wx - 6.);
                                                          {
                                                            let $t48190;
                                                            {
                                                              const $t48189 = (wx + ww);
                                                              $t48190 = ($t48189 + 6.);
                                                            }
                                                            $t48191 = { $: "Line", _0: $t48188, _1: line_y, _2: $t48190, _3: line_y, _4: 2., _5: "rgba(255,40,80,0.75)" };
                                                          }
                                                        }
                                                        {
                                                          const $t48192 = { $: "Nil" };
                                                          {
                                                            const $t48193 = { $: "Cons", _0: $t48191, _1: $t48192 };
                                                            {
                                                              const $t48194 = Spin$View$armed_ops(m);
                                                              {
                                                                let $t48198;
                                                                {
                                                                  const $t48195 = (wx - 22.);
                                                                  {
                                                                    let $t48197;
                                                                    {
                                                                      const $t48196 = (wy + wh);
                                                                      $t48197 = ($t48196 + 14.);
                                                                    }
                                                                    $t48198 = { $: "Label", _0: "SPINS", _1: $t48195, _2: $t48197, _3: 8., _4: "#5cf2ff" };
                                                                  }
                                                                }
                                                                {
                                                                  const $t48199 = { $: "Nil" };
                                                                  {
                                                                    const $t48200 = { $: "Cons", _0: $t48198, _1: $t48199 };
                                                                    {
                                                                      const $t48201 = { $: "Nil" };
                                                                      {
                                                                        const $t48202 = { $: "Cons", _0: $t48200, _1: $t48201 };
                                                                        {
                                                                          const $t48203 = { $: "Cons", _0: boost, _1: $t48202 };
                                                                          {
                                                                            const $t48204 = { $: "Cons", _0: nudge, _1: $t48203 };
                                                                            {
                                                                              const $t48205 = { $: "Cons", _0: spins, _1: $t48204 };
                                                                              {
                                                                                const $t48206 = { $: "Cons", _0: $t48194, _1: $t48205 };
                                                                                {
                                                                                  const $t48207 = { $: "Cons", _0: $t48193, _1: $t48206 };
                                                                                  {
                                                                                    const $t48208 = { $: "Cons", _0: $t48187, _1: $t48207 };
                                                                                    {
                                                                                      const $t48209 = { $: "Cons", _0: $t48179, _1: $t48208 };
                                                                                      {
                                                                                        const prepend_reversed_i5782 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                                                        {
                                                                                          const go_i5783 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5782 };
                                                                                          {
                                                                                            const $t1124_i5784 = { $: "Nil" };
                                                                                            return go$apply$1_List_concat_List_List_Op(go_i5783, $t48209, $t1124_i5784);
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$machine_ops$clo = { _0: ($_, m) => Spin$View$machine_ops(m) };

function Spin$View$part_ops(m, p) {
  switch (p.$) {
    case "Wall": {
      const $f48344 = p._0;
      const $f48345 = p._1;
      const $f48346 = p._2;
      {
        const b = $f48345;
        {
          const a = $f48344;
          {
            let $t48219;
            {
              let $t48218;
              {
                const $t48217 = m.style;
                $t48218 = $t48217.tint;
              }
              $t48219 = Spin$Draw$stick(a, b, 4., $t48218);
            }
            {
              const $t48220 = { $: "Nil" };
              return { $: "Cons", _0: $t48219, _1: $t48220 };
            }
          }
        }
      }
      break;
    }
    case "Peg": {
      const $f48355 = p._0;
      const $f48356 = p._1;
      const $f48357 = p._2;
      {
        const r = $f48356;
        {
          const c = $f48355;
          {
            let $t48226;
            {
              const $t48221 = c.x;
              {
                const $t48222 = c.y;
                {
                  const $t48223 = (r + 1.);
                  {
                    let $t48225;
                    {
                      const $t48224 = m.style;
                      $t48225 = $t48224.tint;
                    }
                    $t48226 = { $: "Disc", _0: $t48221, _1: $t48222, _2: $t48223, _3: $t48225 };
                  }
                }
              }
            }
            {
              const $t48227 = { $: "Nil" };
              {
                const $rc_2735 = { $: "Cons", _0: $t48226, _1: $t48227 };
                return $rc_2735;
              }
            }
          }
        }
      }
      break;
    }
    case "Gate": {
      const $f48366 = p._0;
      const $f48367 = p._1;
      {
        const b = $f48367;
        {
          const a = $f48366;
          {
            const $t48228 = Spin$Draw$stick(a, b, 2., "#7a6aa8");
            {
              const $t48229 = { $: "Nil" };
              return { $: "Cons", _0: $t48228, _1: $t48229 };
            }
          }
        }
      }
      break;
    }
    case "Kicker": {
      const $f48372 = p._0;
      const $f48373 = p._1;
      const $f48374 = p._2;
      {
        const f = $f48374;
        {
          const r = $f48373;
          {
            const c = $f48372;
            return Spin$View$bumper_ops(m, c, r, f);
          }
        }
      }
      break;
    }
    case "Mover": {
      const $f48383 = p._0;
      const $f48384 = p._1;
      const $f48385 = p._2;
      const $f48386 = p._3;
      const $f48387 = p._4;
      {
        const f = $f48387;
        {
          const period = $f48386;
          {
            const r = $f48385;
            {
              const b = $f48384;
              {
                const a = $f48383;
                {
                  let $p48245;
                  {
                    const $t48230 = m.clock;
                    {
                      const $t48231 = m.num;
                      $p48245 = Spin$Table$mover_at(a, b, period, $t48230, $t48231);
                    }
                  }
                  {
                    const at = $p48245._0;
                    {
                      const u = $p48245._1;
                      {
                        let behind;
                        {
                          let $t48232;
                          $t48232 = Arcade$Vec2$scale(u, 0.06);
                          behind = Arcade$Vec2$sub(at, $t48232);
                        }
                        {
                          const $t48233 = Spin$Draw$stick(a, b, 2., "rgba(255,63,164,0.18)");
                          {
                            let $t48237;
                            {
                              const $t48234 = behind.x;
                              {
                                const $t48235 = behind.y;
                                {
                                  const $t48236 = (r * 0.8);
                                  $t48237 = { $: "Disc", _0: $t48234, _1: $t48235, _2: $t48236, _3: "rgba(255,63,164,0.25)" };
                                }
                              }
                            }
                            {
                              const $t48238 = { $: "Nil" };
                              {
                                const $t48239 = { $: "Cons", _0: $t48237, _1: $t48238 };
                                {
                                  const $t48240 = { $: "Cons", _0: $t48233, _1: $t48239 };
                                  {
                                    let $t48241;
                                    $t48241 = Spin$View$bumper_ops(m, at, r, f);
                                    {
                                      const $t48242 = { $: "Nil" };
                                      {
                                        const $t48243 = { $: "Cons", _0: $t48241, _1: $t48242 };
                                        {
                                          const $t48244 = { $: "Cons", _0: $t48240, _1: $t48243 };
                                          {
                                            const prepend_reversed_i5814 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                            {
                                              const go_i5815 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5814 };
                                              {
                                                const $t1124_i5816 = { $: "Nil" };
                                                return go$apply$1_List_concat_List_List_Op(go_i5815, $t48244, $t1124_i5816);
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      break;
    }
    case "Face": {
      const $f48404 = p._0;
      const $f48405 = p._1;
      const $f48406 = p._2;
      const $f48407 = p._3;
      switch ($f48407.$) {
        case "Sling": {
          {
            const b = $f48405;
            {
              const a = $f48404;
              {
                let $t48249;
                {
                  let $t48248;
                  {
                    const $t48246 = { $: "Sling" };
                    {
                      const dim_i13321 = "#ff6b3d";
                      {
                        const bright_i13322 = "#ffd36b";
                        {
                          let $t48212_i13324;
                          {
                            const $t48211_i13323 = Spin$Game$light(m, $t48246);
                            $t48212_i13324 = ($t48211_i13323 > 0.);
                          }
                          if ($t48212_i13324 === true) {
                            $t48248 = "#ffd36b";
                          } else {
                            $t48248 = "#ff6b3d";
                          }
                        }
                      }
                    }
                  }
                  $t48249 = Spin$Draw$stick(a, b, 6., $t48248);
                }
                {
                  const $t48250 = { $: "Nil" };
                  return { $: "Cons", _0: $t48249, _1: $t48250 };
                }
              }
            }
          }
          break;
        }
        default: {
          switch ($f48407.$) {
            case "Loader": {
              const $f48430 = $f48407._0;
              {
                const s = $f48430;
                {
                  const b = $f48405;
                  {
                    const a = $f48404;
                    {
                      let glow;
                      {
                        let $t48251;
                        $t48251 = { $: "Loader", _0: s };
                        glow = Spin$Game$light(m, $t48251);
                      }
                      {
                        let mid;
                        {
                          let $t48252;
                          $t48252 = Arcade$Vec2$add(a, b);
                          mid = Arcade$Vec2$scale($t48252, 0.5);
                        }
                        {
                          let inward;
                          {
                            let $t48256;
                            {
                              let $t48255;
                              {
                                const $t48253 = a.x;
                                {
                                  const $t48254 = b.x;
                                  {
                                    const $t45798_i5836 = ($t48254 >= $t48253);
                                    if ($t45798_i5836 === true) {
                                      $t48255 = $t48254;
                                    } else {
                                      $t48255 = $t48253;
                                    }
                                  }
                                }
                              }
                              $t48256 = ($t48255 < 100.);
                            }
                            if ($t48256 === true) {
                              inward = ({ x: 18., y: 0. });
                            } else {
                              {
                                let $t48260;
                                {
                                  let $t48259;
                                  {
                                    const $t48257 = a.x;
                                    {
                                      const $t48258 = b.x;
                                      {
                                        const $t45799_i5831 = ($t48258 < $t48257);
                                        if ($t45799_i5831 === true) {
                                          $t48259 = $t48258;
                                        } else {
                                          $t48259 = $t48257;
                                        }
                                      }
                                    }
                                  }
                                  $t48260 = ($t48259 > 300.);
                                }
                                {
                                  const $jp1214_$t48261 = (-18.);
                                  if ($t48260 === true) {
                                    inward = ({ x: $jp1214_$t48261, y: 0. });
                                  } else {
                                    inward = ({ x: 0., y: $jp1214_$t48261 });
                                  }
                                }
                              }
                            }
                          }
                          {
                            let icon;
                            icon = Arcade$Vec2$add(mid, inward);
                            {
                              const $t48263 = (glow > 0.);
                              {
                                let $t48270;
                                if ($t48263 === true) {
                                  {
                                    let $t48268;
                                    {
                                      const $t48264 = mid.x;
                                      {
                                        const $t48265 = mid.y;
                                        {
                                          let $t48267;
                                          {
                                            const $t48266 = (glow * 0.7);
                                            $t48267 = Spin$Draw$rgba(255, 255, 255, $t48266);
                                          }
                                          $t48268 = { $: "Glow", _0: $t48264, _1: $t48265, _2: 30., _3: $t48267 };
                                        }
                                      }
                                    }
                                    {
                                      const $t48269 = { $: "Nil" };
                                      {
                                        const $rc_2738 = { $: "Cons", _0: $t48268, _1: $t48269 };
                                        $t48270 = $rc_2738;
                                      }
                                    }
                                  }
                                } else {
                                  $t48270 = { $: "Nil" };
                                }
                                {
                                  let $t48272;
                                  {
                                    const $t48271 = Spin$View$colour(s);
                                    $t48272 = Spin$Draw$stick(a, b, 8., $t48271);
                                  }
                                  {
                                    const $t48273 = { $: "Nil" };
                                    {
                                      const $t48274 = { $: "Cons", _0: $t48272, _1: $t48273 };
                                      {
                                        const $t48275 = m.num;
                                        {
                                          const $t48276 = icon.x;
                                          {
                                            const $t48277 = icon.y;
                                            {
                                              let $t48278;
                                              {
                                                let $rc_2736;
                                                $rc_2736 = Spin$View$symbol($t48275, s, $t48276, $t48277, 0.62);
                                                $t48278 = $rc_2736;
                                              }
                                              {
                                                const $t48279 = { $: "Nil" };
                                                {
                                                  const $t48280 = { $: "Cons", _0: $t48278, _1: $t48279 };
                                                  {
                                                    const $t48281 = { $: "Cons", _0: $t48274, _1: $t48280 };
                                                    {
                                                      const $t48282 = { $: "Cons", _0: $t48270, _1: $t48281 };
                                                      {
                                                        const prepend_reversed_i5822 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                        {
                                                          const go_i5823 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5822 };
                                                          {
                                                            const $t1124_i5824 = { $: "Nil" };
                                                            return go$apply$1_List_concat_List_List_Op(go_i5823, $t48282, $t1124_i5824);
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              break;
            }
            default: {
              {
                const b = $f48405;
                {
                  const a = $f48404;
                  {
                    const $t48284 = Spin$Draw$stick(a, b, 4., "#b9a6ff");
                    {
                      const $t48285 = { $: "Nil" };
                      return { $: "Cons", _0: $t48284, _1: $t48285 };
                    }
                  }
                }
              }
            }
          }
        }
      }
      break;
    }
    case "Sensor": {
      const $f48447 = p._0;
      const $f48448 = p._1;
      const $f48449 = p._2;
      switch ($f48449.$) {
        case "HoldLane": {
          const $f48464 = $f48449._0;
          {
            const i = $f48464;
            {
              const r = $f48448;
              {
                const c = $f48447;
                {
                  let is_on;
                  {
                    const m_i13325 = m;
                    {
                      let $t48215_i13329;
                      {
                        const $t48213_i13327 = m.bank;
                        {
                          const $t48214_i13328 = $t48213_i13327.reels;
                          $t48215_i13329 = List$nth_opt$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($t48214_i13328, i);
                        }
                      }
                      switch ($t48215_i13329.$) {
                        case "Some": {
                          const $f48216_i13330 = $t48215_i13329._0;
                          {
                            const r_i13331 = $f48216_i13330;
                            {
                              const $rc_2733_i13332 = r_i13331.held;
                              is_on = $rc_2733_i13332;
                            }
                          }
                          break;
                        }
                        case "None": {
                          is_on = false;
                          break;
                        }
                        default: {
                          throw new Error("non-exhaustive pattern match");
                          break;
                        }
                      }
                    }
                  }
                  {
                    let $t48289;
                    {
                      const $t48286 = c.x;
                      {
                        const $t48287 = c.y;
                        {
                          let $t48288;
                          if (is_on === true) {
                            $t48288 = "#7dff7a";
                          } else {
                            $t48288 = "#5a4a80";
                          }
                          $t48289 = { $: "Ring", _0: $t48286, _1: $t48287, _2: r, _3: 2., _4: $t48288 };
                        }
                      }
                    }
                    {
                      let $t48294;
                      {
                        const $t48290 = c.x;
                        {
                          const $t48291 = c.y;
                          {
                            const $t48292 = (r - 3.);
                            {
                              let $t48293;
                              if (is_on === true) {
                                $t48293 = "#7dff7a";
                              } else {
                                $t48293 = "#241640";
                              }
                              $t48294 = { $: "Disc", _0: $t48290, _1: $t48291, _2: $t48292, _3: $t48293 };
                            }
                          }
                        }
                      }
                      {
                        let $t48301;
                        {
                          let $t48296;
                          {
                            const $t48295 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
                            $t48296 = String($t48295);
                          }
                          {
                            const $t48297 = c.x;
                            {
                              let $t48299;
                              {
                                const $t48298 = c.y;
                                $t48299 = ($t48298 + 0.5);
                              }
                              {
                                let $t48300;
                                if (is_on === true) {
                                  $t48300 = "#0b2a0b";
                                } else {
                                  $t48300 = "#9a8ac0";
                                }
                                $t48301 = { $: "Label", _0: $t48296, _1: $t48297, _2: $t48299, _3: 9., _4: $t48300 };
                              }
                            }
                          }
                        }
                        {
                          const $t48302 = { $: "Nil" };
                          {
                            const $t48303 = { $: "Cons", _0: $t48301, _1: $t48302 };
                            {
                              const $t48304 = { $: "Cons", _0: $t48294, _1: $t48303 };
                              {
                                const $rc_2740 = { $: "Cons", _0: $t48289, _1: $t48304 };
                                return $rc_2740;
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          break;
        }
        default: {
          return { $: "Nil" };
        }
      }
      break;
    }
    case "Tripwire": {
      const $f48469 = p._0;
      const $f48470 = p._1;
      const $f48471 = p._2;
      {
        const b = $f48470;
        {
          const a = $f48469;
          {
            let h;
            {
              let $t48308;
              {
                let $t48307;
                {
                  let $t48306;
                  {
                    const $t48305 = m.spinner_turn;
                    $t48306 = Math.cos($t48305);
                  }
                  $t48307 = Math.abs($t48306);
                }
                $t48308 = (7. * $t48307);
              }
              h = (2. + $t48308);
            }
            {
              let glow;
              {
                const $t48309 = { $: "Spinner" };
                glow = Spin$Game$light(m, $t48309);
              }
              {
                const $t48310 = (glow > 0.);
                {
                  let $t48320;
                  if ($t48310 === true) {
                    {
                      let $t48318;
                      {
                        let $t48314;
                        {
                          let $t48313;
                          {
                            const $t48311 = a.x;
                            {
                              const $t48312 = b.x;
                              $t48313 = ($t48311 + $t48312);
                            }
                          }
                          $t48314 = ($t48313 / 2.);
                        }
                        {
                          const $t48315 = a.y;
                          {
                            let $t48317;
                            {
                              const $t48316 = (glow * 0.8);
                              $t48317 = Spin$Draw$rgba(92, 242, 255, $t48316);
                            }
                            $t48318 = { $: "Glow", _0: $t48314, _1: $t48315, _2: 34., _3: $t48317 };
                          }
                        }
                      }
                      {
                        const $t48319 = { $: "Nil" };
                        $t48320 = { $: "Cons", _0: $t48318, _1: $t48319 };
                      }
                    }
                  } else {
                    $t48320 = { $: "Nil" };
                  }
                  {
                    let $t48330;
                    {
                      let $t48322;
                      {
                        const $t48321 = a.x;
                        $t48322 = ($t48321 + 3.);
                      }
                      {
                        let $t48325;
                        {
                          const $t48323 = a.y;
                          {
                            const $t48324 = (h / 2.);
                            $t48325 = ($t48323 - $t48324);
                          }
                        }
                        {
                          let $t48329;
                          {
                            let $t48328;
                            {
                              const $t48326 = b.x;
                              {
                                const $t48327 = a.x;
                                $t48328 = ($t48326 - $t48327);
                              }
                            }
                            $t48329 = ($t48328 - 6.);
                          }
                          $t48330 = { $: "Box", _0: $t48322, _1: $t48325, _2: $t48329, _3: h, _4: "#5cf2ff" };
                        }
                      }
                    }
                    {
                      let $t48337;
                      {
                        let $t48334;
                        {
                          let $t48333;
                          {
                            const $t48331 = a.x;
                            {
                              const $t48332 = b.x;
                              $t48333 = ($t48331 + $t48332);
                            }
                          }
                          $t48334 = ($t48333 / 2.);
                        }
                        {
                          let $t48336;
                          {
                            const $t48335 = a.y;
                            $t48336 = ($t48335 + 16.);
                          }
                          $t48337 = { $: "Label", _0: "SPIN", _1: $t48334, _2: $t48336, _3: 9., _4: "#5cf2ff" };
                        }
                      }
                      {
                        const $t48338 = { $: "Nil" };
                        {
                          const $t48339 = { $: "Cons", _0: $t48337, _1: $t48338 };
                          {
                            const $t48340 = { $: "Cons", _0: $t48330, _1: $t48339 };
                            {
                              const $t48341 = { $: "Nil" };
                              {
                                const $t48342 = { $: "Cons", _0: $t48340, _1: $t48341 };
                                {
                                  const $t48343 = { $: "Cons", _0: $t48320, _1: $t48342 };
                                  {
                                    const prepend_reversed_i5847 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                    {
                                      const go_i5848 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5847 };
                                      {
                                        const $t1124_i5849 = { $: "Nil" };
                                        return go$apply$1_List_concat_List_List_Op(go_i5848, $t48343, $t1124_i5849);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const Spin$View$part_ops$clo = { _0: ($_, m, p) => Spin$View$part_ops(m, p) };

function Spin$View$bumper_ops(m, c, r, f) {
  {
    let glow;
    glow = Spin$Game$light(m, f);
    {
      let breathe;
      {
        let $t48486;
        {
          let $t48485;
          {
            let $t48484;
            {
              let $t48481;
              {
                const $t48480 = m.clock;
                $t48481 = ($t48480 * 2.);
              }
              {
                let $t48483;
                {
                  const $t48482 = c.x;
                  $t48483 = ($t48482 * 0.05);
                }
                $t48484 = ($t48481 + $t48483);
              }
            }
            $t48485 = Math.sin($t48484);
          }
          $t48486 = (0.5 * $t48485);
        }
        breathe = (0.5 + $t48486);
      }
      {
        const $t48487 = (glow > 0.);
        {
          let $t48502;
          if ($t48487 === true) {
            {
              let $t48492;
              {
                const $t48488 = c.x;
                {
                  const $t48489 = c.y;
                  {
                    const $t48490 = (r * 2.4);
                    {
                      const $t48491 = Spin$Draw$rgba(255, 63, 164, glow);
                      $t48492 = { $: "Glow", _0: $t48488, _1: $t48489, _2: $t48490, _3: $t48491 };
                    }
                  }
                }
              }
              {
                let $t48499;
                {
                  const $t48493 = c.x;
                  {
                    const $t48494 = c.y;
                    {
                      let $t48497;
                      {
                        let $t48496;
                        {
                          const $t48495 = (1. - glow);
                          $t48496 = ($t48495 * 18.);
                        }
                        $t48497 = (r + $t48496);
                      }
                      {
                        const $t48498 = Spin$Draw$rgba(255, 143, 207, glow);
                        $t48499 = { $: "Ring", _0: $t48493, _1: $t48494, _2: $t48497, _3: 2., _4: $t48498 };
                      }
                    }
                  }
                }
                {
                  const $t48500 = { $: "Nil" };
                  {
                    const $t48501 = { $: "Cons", _0: $t48499, _1: $t48500 };
                    $t48502 = { $: "Cons", _0: $t48492, _1: $t48501 };
                  }
                }
              }
            }
          } else {
            $t48502 = { $: "Nil" };
          }
          {
            let $t48505;
            {
              const $t48503 = c.x;
              {
                const $t48504 = c.y;
                $t48505 = { $: "Disc", _0: $t48503, _1: $t48504, _2: r, _3: "#2a0f3a" };
              }
            }
            {
              let $t48512;
              {
                const $t48506 = c.x;
                {
                  const $t48507 = c.y;
                  {
                    const $t48508 = (r - 2.);
                    {
                      let $t48511;
                      {
                        let $t48510;
                        {
                          const $t48509 = (0.25 * breathe);
                          $t48510 = (0.75 + $t48509);
                        }
                        $t48511 = Spin$Draw$rgba(255, 63, 164, $t48510);
                      }
                      $t48512 = { $: "Ring", _0: $t48506, _1: $t48507, _2: $t48508, _3: 4., _4: $t48511 };
                    }
                  }
                }
              }
              {
                let $t48518;
                {
                  const $t48513 = c.x;
                  {
                    const $t48514 = c.y;
                    {
                      const $t48515 = (r * 0.55);
                      {
                        let $t48517;
                        {
                          const $t48516 = (glow > 0.);
                          if ($t48516 === true) {
                            $t48517 = "#ffe0f2";
                          } else {
                            $t48517 = "#ff3fa4";
                          }
                        }
                        $t48518 = { $: "Disc", _0: $t48513, _1: $t48514, _2: $t48515, _3: $t48517 };
                      }
                    }
                  }
                }
                {
                  const $t48519 = { $: "Nil" };
                  {
                    const $t48520 = { $: "Cons", _0: $t48518, _1: $t48519 };
                    {
                      const $t48521 = { $: "Cons", _0: $t48512, _1: $t48520 };
                      {
                        const $t48522 = { $: "Cons", _0: $t48505, _1: $t48521 };
                        {
                          const $t48523 = { $: "Nil" };
                          {
                            const $t48524 = { $: "Cons", _0: $t48522, _1: $t48523 };
                            {
                              const $t48525 = { $: "Cons", _0: $t48502, _1: $t48524 };
                              {
                                const prepend_reversed_i5857 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                {
                                  const go_i5858 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5857 };
                                  {
                                    const $t1124_i5859 = { $: "Nil" };
                                    return go$apply$1_List_concat_List_List_Op(go_i5858, $t48525, $t1124_i5859);
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$bumper_ops$clo = { _0: ($_, m, c, r, f) => Spin$View$bumper_ops(m, c, r, f) };

function Spin$View$flipper_ops(spec, f) {
  {
    let tip;
    {
      const $t48526 = f.angle;
      tip = Spin$Table$tip(spec, $t48526);
    }
    {
      let $t48531;
      {
        const $t48527 = spec.pivot;
        {
          let $t48530;
          {
            let $t48529;
            {
              const $t48528 = spec.radius;
              $t48529 = ($t48528 * 2.);
            }
            $t48530 = ($t48529 + 3.);
          }
          $t48531 = Spin$Draw$stick($t48527, tip, $t48530, "#3b2a5c");
        }
      }
      {
        let $t48535;
        {
          const $t48532 = spec.pivot;
          {
            let $t48534;
            {
              const $t48533 = spec.radius;
              $t48534 = ($t48533 * 2.);
            }
            $t48535 = Spin$Draw$stick($t48532, tip, $t48534, "#f4f1ff");
          }
        }
        {
          let $t48540;
          {
            let $t48537;
            {
              const $t48536 = spec.pivot;
              $t48537 = $t48536.x;
            }
            {
              let $t48539;
              {
                const $t48538 = spec.pivot;
                $t48539 = $t48538.y;
              }
              $t48540 = { $: "Disc", _0: $t48537, _1: $t48539, _2: 3., _3: "#ff3fa4" };
            }
          }
          {
            const $t48541 = { $: "Nil" };
            {
              const $t48542 = { $: "Cons", _0: $t48540, _1: $t48541 };
              {
                const $t48543 = { $: "Cons", _0: $t48535, _1: $t48542 };
                return { $: "Cons", _0: $t48531, _1: $t48543 };
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$flipper_ops$clo = { _0: ($_, spec, f) => Spin$View$flipper_ops(spec, f) };

function Spin$View$ball_ops(m, b) {
  {
    let speed;
    {
      const $t48544 = b.vel;
      speed = Arcade$Vec2$length($t48544);
    }
    {
      const $t48545 = (speed > 500.);
      {
        let trail;
        if ($t48545 === true) {
          {
            const $t48546 = { $: "Nil" };
            {
              const $t48547 = { $: "Cons", _0: 1, _1: $t48546 };
              {
                const $t48548 = { $: "Cons", _0: 2, _1: $t48547 };
                {
                  const $t48549 = { $: "Cons", _0: 3, _1: $t48548 };
                  {
                    let $t48562;
                    $t48562 = { $: "$Clo_$lam0_Spin_View_ball_ops$0_Spin_View_ball_ops", _0: $lam0_Spin_View_ball_ops$apply$0_Spin_View_ball_ops, _1: b };
                    trail = List$map$List_Int$Fn_Int_Op($t48549, $t48562);
                  }
                }
              }
            }
          }
        } else {
          trail = { $: "Nil" };
        }
        {
          let $t48567;
          {
            let $t48564;
            {
              const $t48563 = b.pos;
              $t48564 = $t48563.x;
            }
            {
              let $t48566;
              {
                const $t48565 = b.pos;
                $t48566 = $t48565.y;
              }
              $t48567 = { $: "Glow", _0: $t48564, _1: $t48566, _2: 24., _3: "rgba(255,255,255,0.28)" };
            }
          }
          {
            let $t48574;
            {
              let $t48569;
              {
                const $t48568 = b.pos;
                $t48569 = $t48568.x;
              }
              {
                let $t48571;
                {
                  const $t48570 = b.pos;
                  $t48571 = $t48570.y;
                }
                {
                  let $t48573;
                  {
                    const $t48572 = m.style;
                    $t48573 = $t48572.tint;
                  }
                  $t48574 = { $: "Ring", _0: $t48569, _1: $t48571, _2: 11.5, _3: 1.5, _4: $t48573 };
                }
              }
            }
            {
              const $t48575 = { $: "Nil" };
              {
                const $t48576 = { $: "Cons", _0: $t48574, _1: $t48575 };
                {
                  const $t48577 = { $: "Cons", _0: $t48567, _1: $t48576 };
                  {
                    let $t48578;
                    $t48578 = Spin$View$steel(b);
                    {
                      const $t48579 = { $: "Nil" };
                      {
                        const $t48580 = { $: "Cons", _0: $t48578, _1: $t48579 };
                        {
                          const $t48581 = { $: "Cons", _0: $t48577, _1: $t48580 };
                          {
                            const $t48582 = { $: "Cons", _0: trail, _1: $t48581 };
                            {
                              const prepend_reversed_i5874 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                              {
                                const go_i5875 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5874 };
                                {
                                  const $t1124_i5876 = { $: "Nil" };
                                  return go$apply$1_List_concat_List_List_Op(go_i5875, $t48582, $t1124_i5876);
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$ball_ops$clo = { _0: ($_, m, b) => Spin$View$ball_ops(m, b) };

function Spin$View$steel(b) {
  {
    let $t48589;
    {
      let $t48585;
      {
        let $t48584;
        {
          const $t48583 = b.pos;
          $t48584 = $t48583.x;
        }
        $t48585 = ($t48584 + 2.);
      }
      {
        let $t48588;
        {
          let $t48587;
          {
            const $t48586 = b.pos;
            $t48587 = $t48586.y;
          }
          $t48588 = ($t48587 + 3.);
        }
        $t48589 = { $: "Disc", _0: $t48585, _1: $t48588, _2: 9., _3: "rgba(0,0,0,0.35)" };
      }
    }
    {
      let $t48594;
      {
        let $t48591;
        {
          const $t48590 = b.pos;
          $t48591 = $t48590.x;
        }
        {
          let $t48593;
          {
            const $t48592 = b.pos;
            $t48593 = $t48592.y;
          }
          $t48594 = { $: "Disc", _0: $t48591, _1: $t48593, _2: 9., _3: "#cfd5e2" };
        }
      }
      {
        let $t48601;
        {
          let $t48597;
          {
            let $t48596;
            {
              const $t48595 = b.pos;
              $t48596 = $t48595.x;
            }
            $t48597 = ($t48596 - 1.);
          }
          {
            let $t48600;
            {
              let $t48599;
              {
                const $t48598 = b.pos;
                $t48599 = $t48598.y;
              }
              $t48600 = ($t48599 - 1.);
            }
            $t48601 = { $: "Disc", _0: $t48597, _1: $t48600, _2: 7., _3: "#e9edf5" };
          }
        }
        {
          let $t48608;
          {
            let $t48604;
            {
              let $t48603;
              {
                const $t48602 = b.pos;
                $t48603 = $t48602.x;
              }
              $t48604 = ($t48603 - 3.);
            }
            {
              let $t48607;
              {
                let $t48606;
                {
                  const $t48605 = b.pos;
                  $t48606 = $t48605.y;
                }
                $t48607 = ($t48606 - 3.5);
              }
              $t48608 = { $: "Disc", _0: $t48604, _1: $t48607, _2: 2.6, _3: "#ffffff" };
            }
          }
          {
            const $t48609 = { $: "Nil" };
            {
              const $t48610 = { $: "Cons", _0: $t48608, _1: $t48609 };
              {
                const $t48611 = { $: "Cons", _0: $t48601, _1: $t48610 };
                {
                  const $t48612 = { $: "Cons", _0: $t48594, _1: $t48611 };
                  return { $: "Cons", _0: $t48589, _1: $t48612 };
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$steel$clo = { _0: ($_, b) => Spin$View$steel(b) };

function Spin$View$launch_button_ops(m) {
  {
    let ready;
    {
      let $t48613;
      $t48613 = Spin$Game$waiting(m);
      {
        let $t48616;
        {
          const $t48614 = m.mode;
          {
            const $t48615 = { $: "Playing" };
            {
              const $rc_2741 = march_deep_eq($t48614, $t48615);
              $t48616 = $rc_2741;
            }
          }
        }
        ready = ($t48613 && $t48616);
      }
    }
    {
      let pulse;
      {
        let $t48620;
        {
          let $t48619;
          {
            let $t48618;
            {
              const $t48617 = m.clock;
              $t48618 = ($t48617 * 6.);
            }
            $t48619 = Math.sin($t48618);
          }
          $t48620 = (0.5 * $t48619);
        }
        pulse = (0.5 + $t48620);
      }
      {
        let fill;
        {
          const $t48621 = (2. * 30.);
          {
            const $t48622 = m.pull;
            fill = ($t48621 * $t48622);
          }
        }
        if (ready === true) {
          {
            let $t48627;
            {
              const $t48623 = (30. * 1.9);
              {
                let $t48626;
                {
                  let $t48625;
                  {
                    const $t48624 = (0.25 * pulse);
                    $t48625 = (0.25 + $t48624);
                  }
                  $t48626 = Spin$Draw$rgba(255, 63, 80, $t48625);
                }
                $t48627 = { $: "Glow", _0: 306., _1: 724., _2: $t48623, _3: $t48626 };
              }
            }
            {
              const $t48628 = { $: "Disc", _0: 306., _1: 724., _2: 30., _3: "#3a0d1a" };
              {
                let $t48633;
                {
                  const $t48629 = (306. - 30.);
                  {
                    let $t48631;
                    {
                      const $t48630 = (724. + 30.);
                      $t48631 = ($t48630 - fill);
                    }
                    {
                      const $t48632 = (2. * 30.);
                      $t48633 = { $: "ClipBox", _0: $t48629, _1: $t48631, _2: $t48632, _3: fill };
                    }
                  }
                }
                {
                  const $t48634 = { $: "Disc", _0: 306., _1: 724., _2: 30., _3: "#ff3b4e" };
                  {
                    const $t48635 = { $: "Unclip" };
                    {
                      let $t48639;
                      {
                        let $t48638;
                        {
                          let $t48637;
                          {
                            const $t48636 = (0.3 * pulse);
                            $t48637 = (0.7 + $t48636);
                          }
                          $t48638 = Spin$Draw$rgba(255, 211, 107, $t48637);
                        }
                        $t48639 = { $: "Ring", _0: 306., _1: 724., _2: 30., _3: 3., _4: $t48638 };
                      }
                      {
                        let $t48641;
                        {
                          const $t48640 = (724. - 4.);
                          $t48641 = { $: "Label", _0: "LAUNCH", _1: 306., _2: $t48640, _3: 10., _4: "#ffffff" };
                        }
                        {
                          let $t48647;
                          {
                            let $t48644;
                            {
                              let $t48643;
                              {
                                const $t48642 = m.pull;
                                $t48643 = ($t48642 > 0.);
                              }
                              if ($t48643 === true) {
                                $t48644 = "let go";
                              } else {
                                $t48644 = "hold";
                              }
                            }
                            {
                              const $t48645 = (724. + 9.);
                              {
                                const $t48646 = Spin$Draw$rgba(255, 230, 200, 0.9);
                                $t48647 = { $: "Label", _0: $t48644, _1: 306., _2: $t48645, _3: 8., _4: $t48646 };
                              }
                            }
                          }
                          {
                            const $t48648 = { $: "Nil" };
                            {
                              const $t48649 = { $: "Cons", _0: $t48647, _1: $t48648 };
                              {
                                const $t48650 = { $: "Cons", _0: $t48641, _1: $t48649 };
                                {
                                  const $t48651 = { $: "Cons", _0: $t48639, _1: $t48650 };
                                  {
                                    const $t48652 = { $: "Cons", _0: $t48635, _1: $t48651 };
                                    {
                                      const $t48653 = { $: "Cons", _0: $t48634, _1: $t48652 };
                                      {
                                        const $t48654 = { $: "Cons", _0: $t48633, _1: $t48653 };
                                        {
                                          const $t48655 = { $: "Cons", _0: $t48628, _1: $t48654 };
                                          {
                                            const $rc_2745 = { $: "Cons", _0: $t48627, _1: $t48655 };
                                            return $rc_2745;
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        } else {
          {
            const $t48656 = { $: "Disc", _0: 306., _1: 724., _2: 30., _3: "rgba(58,13,26,0.5)" };
            {
              const $t48657 = { $: "Ring", _0: 306., _1: 724., _2: 30., _3: 2., _4: "rgba(255,59,78,0.25)" };
              {
                const $t48658 = { $: "Label", _0: "LAUNCH", _1: 306., _2: 724., _3: 9., _4: "rgba(255,255,255,0.22)" };
                {
                  const $t48659 = { $: "Nil" };
                  {
                    const $t48660 = { $: "Cons", _0: $t48658, _1: $t48659 };
                    {
                      const $t48661 = { $: "Cons", _0: $t48657, _1: $t48660 };
                      {
                        const $rc_2744 = { $: "Cons", _0: $t48656, _1: $t48661 };
                        return $rc_2744;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$launch_button_ops$clo = { _0: ($_, m) => Spin$View$launch_button_ops(m) };

function Spin$View$plunger_ops(m, touch) {
  {
    let top;
    {
      let $t48664;
      {
        const $t48663 = m.pull;
        $t48664 = (26. * $t48663);
      }
      top = (702. + $t48664);
    }
    {
      let $t48665;
      {
        const go_i5938 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
        {
          const $t926_i5939 = ((6 - 1) < 4611686018427387904 && (6 - 1) >= -4611686018427387904 ? (6 - 1) : march_int_ovf((6 - 1), 1));
          {
            const $t927_i5940 = { $: "Nil" };
            $t48665 = go$apply$0_List_range(go_i5938, $t926_i5939, $t927_i5940);
          }
        }
      }
      {
        let $t48677;
        $t48677 = { $: "$Clo_$lam0_Spin_View_plunger_ops$0_Spin_View_plunger_ops", _0: $lam0_Spin_View_plunger_ops$apply$0_Spin_View_plunger_ops, _1: m, _2: top };
        {
          const coils = List$map$List_Int$Fn_Int_Op($t48665, $t48677);
          {
            let pulse;
            {
              let $t48681;
              {
                let $t48680;
                {
                  let $t48679;
                  {
                    const $t48678 = m.clock;
                    $t48679 = ($t48678 * 5.);
                  }
                  $t48680 = Math.sin($t48679);
                }
                $t48681 = (0.4 * $t48680);
              }
              pulse = (0.6 + $t48681);
            }
            {
              let $t48686;
              {
                let $t48682;
                $t48682 = Spin$Game$waiting(m);
                {
                  let $t48685;
                  {
                    const $t48683 = m.mode;
                    {
                      const $t48684 = { $: "Playing" };
                      {
                        const $rc_2746 = march_deep_eq($t48683, $t48684);
                        $t48685 = $rc_2746;
                      }
                    }
                  }
                  $t48686 = ($t48682 && $t48685);
                }
              }
              {
                let hint;
                if ($t48686 === true) {
                  if (touch === true) {
                    hint = { $: "Nil" };
                  } else {
                    {
                      let $t48688;
                      {
                        const $t48687 = Spin$Draw$rgba(255, 211, 107, pulse);
                        $t48688 = { $: "Label", _0: "HOLD SPACE", _1: 318., _2: 700., _3: 8., _4: $t48687 };
                      }
                      {
                        let $t48690;
                        {
                          const $t48689 = Spin$Draw$rgba(255, 211, 107, pulse);
                          $t48690 = { $: "Label", _0: "let go to launch", _1: 318., _2: 711., _3: 6.5, _4: $t48689 };
                        }
                        {
                          const $t48691 = { $: "Nil" };
                          {
                            const $t48692 = { $: "Cons", _0: $t48690, _1: $t48691 };
                            hint = { $: "Cons", _0: $t48688, _1: $t48692 };
                          }
                        }
                      }
                    }
                  }
                } else {
                  hint = { $: "Nil" };
                }
                {
                  let button;
                  if (touch === true) {
                    button = Spin$View$launch_button_ops(m);
                  } else {
                    button = { $: "Nil" };
                  }
                  {
                    const $t48693 = { $: "Box", _0: 357., _1: top, _2: 16., _3: 6., _4: "#e33" };
                    {
                      let $t48695;
                      {
                        const $t48694 = (top + 6.);
                        $t48695 = { $: "Box", _0: 362., _1: $t48694, _2: 6., _3: 50., _4: "#556" };
                      }
                      {
                        const $t48696 = { $: "Nil" };
                        {
                          const $t48697 = { $: "Cons", _0: $t48695, _1: $t48696 };
                          {
                            const $t48698 = { $: "Cons", _0: $t48693, _1: $t48697 };
                            {
                              const $t48699 = { $: "Nil" };
                              {
                                const $t48700 = { $: "Cons", _0: button, _1: $t48699 };
                                {
                                  const $t48701 = { $: "Cons", _0: hint, _1: $t48700 };
                                  {
                                    const $t48702 = { $: "Cons", _0: coils, _1: $t48701 };
                                    {
                                      const $t48703 = { $: "Cons", _0: $t48698, _1: $t48702 };
                                      {
                                        const prepend_reversed_i5922 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                        {
                                          const go_i5923 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5922 };
                                          {
                                            const $t1124_i5924 = { $: "Nil" };
                                            return go$apply$1_List_concat_List_List_Op(go_i5923, $t48703, $t1124_i5924);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$plunger_ops$clo = { _0: ($_, m, touch) => Spin$View$plunger_ops(m, touch) };

function Spin$View$field_ops(m) {
  {
    const $t48705 = { $: "Disc", _0: 200., _1: 200., _2: 182., _3: "#1a0c30" };
    {
      const $t48707 = { $: "Box", _0: 18., _1: 200., _2: 364., _3: 570., _4: "#1a0c30" };
      {
        const $t48708 = { $: "Nil" };
        {
          const $t48709 = { $: "Cons", _0: $t48707, _1: $t48708 };
          {
            const $t48710 = { $: "Cons", _0: $t48705, _1: $t48709 };
            {
              const $t48711 = { $: "Glow", _0: 185., _1: 420., _2: 230., _3: "rgba(120,40,200,0.25)" };
              {
                const $t48712 = { $: "Nil" };
                {
                  const $t48713 = { $: "Cons", _0: $t48711, _1: $t48712 };
                  {
                    let $t48715;
                    {
                      const $t48714 = m.win_glow;
                      $t48715 = ($t48714 > 0.);
                    }
                    {
                      let $t48724;
                      if ($t48715 === true) {
                        {
                          let $t48722;
                          {
                            let $t48718;
                            {
                              let $t48717;
                              {
                                const $t48716 = m.win_glow;
                                $t48717 = (60. * $t48716);
                              }
                              $t48718 = (160. + $t48717);
                            }
                            {
                              let $t48721;
                              {
                                let $t48720;
                                {
                                  const $t48719 = m.win_glow;
                                  $t48720 = (0.22 * $t48719);
                                }
                                $t48721 = Spin$Draw$rgba(255, 211, 107, $t48720);
                              }
                              $t48722 = { $: "Glow", _0: 185., _1: 426., _2: $t48718, _3: $t48721 };
                            }
                          }
                          {
                            const $t48723 = { $: "Nil" };
                            $t48724 = { $: "Cons", _0: $t48722, _1: $t48723 };
                          }
                        }
                      } else {
                        $t48724 = { $: "Nil" };
                      }
                      {
                        const $t48725 = { $: "Nil" };
                        {
                          const $t48726 = { $: "Cons", _0: $t48724, _1: $t48725 };
                          {
                            const $t48727 = { $: "Cons", _0: $t48713, _1: $t48726 };
                            {
                              const $t48728 = { $: "Cons", _0: $t48710, _1: $t48727 };
                              {
                                const prepend_reversed_i5942 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                {
                                  const go_i5943 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5942 };
                                  {
                                    const $t1124_i5944 = { $: "Nil" };
                                    return go$apply$1_List_concat_List_List_Op(go_i5943, $t48728, $t1124_i5944);
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$field_ops$clo = { _0: ($_, m) => Spin$View$field_ops(m) };

function Spin$View$marquee_ops(m) {
  {
    let $p48839;
    {
      const $t48755 = m.table;
      $p48839 = $t48755.reel_window;
    }
    {
      const wx = $p48839._0;
      {
        const wy = $p48839._1;
        {
          const ww = $p48839._2;
          {
            const wh = $p48839._3;
            {
              let spinning;
              {
                const $t48756 = m.bank;
                {
                  const b_i13341 = $t48756;
                  {
                    const $t47452_i13342 = $t48756.phase;
                    {
                      const $t47453_i13343 = { $: "Idle" };
                      {
                        const $rc_2666_i13344 = (!march_deep_eq($t47452_i13342, $t47453_i13343));
                        spinning = $rc_2666_i13344;
                      }
                    }
                  }
                }
              }
              {
                let $t48757;
                {
                  const go_i5978 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                  {
                    const $t926_i5979 = ((8 - 1) < 4611686018427387904 && (8 - 1) >= -4611686018427387904 ? (8 - 1) : march_int_ovf((8 - 1), 1));
                    {
                      const $t927_i5980 = { $: "Nil" };
                      $t48757 = go$apply$0_List_range(go_i5978, $t926_i5979, $t927_i5980);
                    }
                  }
                }
                {
                  const $t48767 = { $: "$Clo_$lam0_Spin_View_marquee_ops$0_Spin_View_marquee_ops", _0: $lam0_Spin_View_marquee_ops$apply$0_Spin_View_marquee_ops, _1: 8, _2: ww, _3: wx, _4: wy };
                  {
                    const $t48768 = List$map$List_Int$Fn_Int_R_x_Float_y_Float($t48757, $t48767);
                    {
                      let $t48769;
                      {
                        const go_i5973 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                        {
                          const $t926_i5974 = ((4 - 1) < 4611686018427387904 && (4 - 1) >= -4611686018427387904 ? (4 - 1) : march_int_ovf((4 - 1), 1));
                          {
                            const $t927_i5975 = { $: "Nil" };
                            $t48769 = go$apply$0_List_range(go_i5973, $t926_i5974, $t927_i5975);
                          }
                        }
                      }
                      {
                        const $t48779 = { $: "$Clo_$lam1_Spin_View_marquee_ops$1_Spin_View_marquee_ops", _0: $lam1_Spin_View_marquee_ops$apply$1_Spin_View_marquee_ops, _1: wh, _2: ww, _3: wx, _4: wy };
                        {
                          const $t48780 = List$map$List_Int$Fn_Int_R_x_Float_y_Float($t48769, $t48779);
                          {
                            let $t48781;
                            {
                              const go_i5968 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                              {
                                const $t926_i5969 = ((8 - 1) < 4611686018427387904 && (8 - 1) >= -4611686018427387904 ? (8 - 1) : march_int_ovf((8 - 1), 1));
                                {
                                  const $t927_i5970 = { $: "Nil" };
                                  $t48781 = go$apply$0_List_range(go_i5968, $t926_i5969, $t927_i5970);
                                }
                              }
                            }
                            {
                              const $t48793 = { $: "$Clo_$lam2_Spin_View_marquee_ops$2_Spin_View_marquee_ops", _0: $lam2_Spin_View_marquee_ops$apply$2_Spin_View_marquee_ops, _1: 8, _2: wh, _3: ww, _4: wx, _5: wy };
                              {
                                const $t48794 = List$map$List_Int$Fn_Int_R_x_Float_y_Float($t48781, $t48793);
                                {
                                  let $t48795;
                                  {
                                    const go_i5963 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                                    {
                                      const $t926_i5964 = ((4 - 1) < 4611686018427387904 && (4 - 1) >= -4611686018427387904 ? (4 - 1) : march_int_ovf((4 - 1), 1));
                                      {
                                        const $t927_i5965 = { $: "Nil" };
                                        $t48795 = go$apply$0_List_range(go_i5963, $t926_i5964, $t927_i5965);
                                      }
                                    }
                                  }
                                  {
                                    const $t48805 = { $: "$Clo_$lam3_Spin_View_marquee_ops$3_Spin_View_marquee_ops", _0: $lam3_Spin_View_marquee_ops$apply$3_Spin_View_marquee_ops, _1: wh, _2: wx, _3: wy };
                                    {
                                      const $t48806 = List$map$List_Int$Fn_Int_R_x_Float_y_Float($t48795, $t48805);
                                      {
                                        const $t48807 = { $: "Nil" };
                                        {
                                          const $t48808 = { $: "Cons", _0: $t48806, _1: $t48807 };
                                          {
                                            const $t48809 = { $: "Cons", _0: $t48794, _1: $t48808 };
                                            {
                                              const $t48810 = { $: "Cons", _0: $t48780, _1: $t48809 };
                                              {
                                                const $t48811 = { $: "Cons", _0: $t48768, _1: $t48810 };
                                                {
                                                  let pts;
                                                  {
                                                    const prepend_reversed_i5958 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_R_x_Float_y_Float", _0: prepend_reversed$apply$0_List_concat_List_List_R_x_Float_y_Float };
                                                    {
                                                      const go_i5959 = { $: "$Clo_go$1_List_concat_List_List_R_x_Float_y_Float", _0: go$apply$1_List_concat_List_List_R_x_Float_y_Float, _1: prepend_reversed_i5958 };
                                                      {
                                                        const $t1124_i5960 = { $: "Nil" };
                                                        pts = go$apply$1_List_concat_List_List_R_x_Float_y_Float(go_i5959, $t48811, $t1124_i5960);
                                                      }
                                                    }
                                                  }
                                                  {
                                                    let $t48812;
                                                    {
                                                      const go_i5955 = { $: "$Clo_go$0_List_enumerate_List_R_x_Float_y_Float", _0: go$apply$0_List_enumerate_List_R_x_Float_y_Float };
                                                      {
                                                        const $t1365_i5956 = { $: "Nil" };
                                                        $t48812 = go$apply$0_List_enumerate_List_R_x_Float_y_Float(go_i5955, pts, 0, $t1365_i5956);
                                                      }
                                                    }
                                                    {
                                                      const $t48838 = { $: "$Clo_$lam4_Spin_View_marquee_ops$4_Spin_View_marquee_ops", _0: $lam4_Spin_View_marquee_ops$apply$4_Spin_View_marquee_ops, _1: m, _2: spinning };
                                                      {
                                                        const xs_i13333 = $t48812;
                                                        {
                                                          const f_i13334 = $t48838;
                                                          switch (xs_i13333.$) {
                                                            case "Nil": {
                                                              return { $: "Nil" };
                                                              break;
                                                            }
                                                            case "Cons": {
                                                              const $f1006_i13335 = xs_i13333._0;
                                                              const $f1007_i13336 = xs_i13333._1;
                                                              {
                                                                const t_i13337 = $f1007_i13336;
                                                                {
                                                                  const h_i13338 = $f1006_i13335;
                                                                  {
                                                                    let $t1004_i13339;
                                                                    $t1004_i13339 = f_i13334._0(f_i13334, h_i13338);
                                                                    {
                                                                      const $trmc15_i13340 = { $: "Cons", _0: $t1004_i13339, _1: null };
                                                                      List$map$dps$List_T_Int_R_x_Float_y_Float$Fn_T_Int_R_x_Float_y_Float_Op$List_Op(t_i13337, f_i13334, $trmc15_i13340);
                                                                      return $trmc15_i13340;
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                              break;
                                                            }
                                                            default: {
                                                              return (() => { throw new Error("non-exhaustive pattern match"); })();
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$marquee_ops$clo = { _0: ($_, m) => Spin$View$marquee_ops(m) };

function Spin$View$flash_ops(m) {
  {
    let $t48841;
    {
      const $t48840 = m.flash;
      $t48841 = ($t48840 > 0.);
    }
    if ($t48841 === true) {
      {
        let a;
        {
          const $t48842 = m.flash;
          {
            const $t45799_i5984 = ($t48842 < 1.);
            if ($t45799_i5984 === true) {
              a = $t48842;
            } else {
              a = 1.;
            }
          }
        }
        {
          let flick;
          {
            let $t48846;
            {
              let $t48845;
              {
                let $t48844;
                {
                  const $t48843 = m.clock;
                  $t48844 = ($t48843 * 30.);
                }
                $t48845 = Math.sin($t48844);
              }
              $t48846 = ($t48845 > 0.);
            }
            if ($t48846 === true) {
              flick = 1.;
            } else {
              flick = 0.6;
            }
          }
          {
            let $t48848;
            {
              const $t48847 = (a * flick);
              $t48848 = { $: "Fade", _0: $t48847 };
            }
            {
              let $t48850;
              {
                const $t48849 = m.flash_tint;
                $t48850 = { $: "Box", _0: 0., _1: 0., _2: 16., _3: 770., _4: $t48849 };
              }
              {
                let $t48852;
                {
                  const $t48851 = m.flash_tint;
                  $t48852 = { $: "Box", _0: 384., _1: 0., _2: 16., _3: 770., _4: $t48851 };
                }
                {
                  let $t48855;
                  {
                    const $t48853 = (-6.);
                    {
                      const $t48854 = m.flash_tint;
                      $t48855 = { $: "Box", _0: 0., _1: $t48853, _2: 400., _3: 6., _4: $t48854 };
                    }
                  }
                  {
                    const $t48856 = { $: "Fade", _0: 1. };
                    {
                      const $t48857 = { $: "Nil" };
                      {
                        const $t48858 = { $: "Cons", _0: $t48856, _1: $t48857 };
                        {
                          const $t48859 = { $: "Cons", _0: $t48855, _1: $t48858 };
                          {
                            const $t48860 = { $: "Cons", _0: $t48852, _1: $t48859 };
                            {
                              const $t48861 = { $: "Cons", _0: $t48850, _1: $t48860 };
                              return { $: "Cons", _0: $t48848, _1: $t48861 };
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } else {
      return { $: "Nil" };
    }
  }
}
const Spin$View$flash_ops$clo = { _0: ($_, m) => Spin$View$flash_ops(m) };

function Spin$View$stage_ops(m) {
  {
    let here;
    {
      const $t48895 = m.stage;
      if ($t48895 === 0) {
        here = 0;
      } else if ($t48895 === 1) {
        here = 30;
      } else if ($t48895 === 2) {
        here = 75;
      } else if ($t48895 === 3) {
        here = 140;
      } else if ($t48895 === 4) {
        here = 230;
      } else if ($t48895 === 5) {
        here = 350;
      } else {
        {
          let $t47623_i6020;
          {
            const $t47622_i6019 = (($t48895 - 5) < 4611686018427387904 && ($t48895 - 5) >= -4611686018427387904 ? ($t48895 - 5) : march_int_ovf(($t48895 - 5), 1));
            $t47623_i6020 = ((150 * $t47622_i6019) < 4611686018427387904 && (150 * $t47622_i6019) >= -4611686018427387904 ? (150 * $t47622_i6019) : march_int_ovf((150 * $t47622_i6019), 2));
          }
          here = ((350 + $t47623_i6020) < 4611686018427387904 && (350 + $t47623_i6020) >= -4611686018427387904 ? (350 + $t47623_i6020) : march_int_ovf((350 + $t47623_i6020), 0));
        }
      }
    }
    {
      let next;
      {
        let $t48897;
        {
          const $t48896 = m.stage;
          $t48897 = (($t48896 + 1) < 4611686018427387904 && ($t48896 + 1) >= -4611686018427387904 ? ($t48896 + 1) : march_int_ovf(($t48896 + 1), 0));
        }
        if ($t48897 === 0) {
          next = 0;
        } else if ($t48897 === 1) {
          next = 30;
        } else if ($t48897 === 2) {
          next = 75;
        } else if ($t48897 === 3) {
          next = 140;
        } else if ($t48897 === 4) {
          next = 230;
        } else if ($t48897 === 5) {
          next = 350;
        } else {
          {
            let $t47623_i6017;
            {
              const $t47622_i6016 = (($t48897 - 5) < 4611686018427387904 && ($t48897 - 5) >= -4611686018427387904 ? ($t48897 - 5) : march_int_ovf(($t48897 - 5), 1));
              $t47623_i6017 = ((150 * $t47622_i6016) < 4611686018427387904 && (150 * $t47622_i6016) >= -4611686018427387904 ? (150 * $t47622_i6016) : march_int_ovf((150 * $t47622_i6016), 2));
            }
            next = ((350 + $t47623_i6017) < 4611686018427387904 && (350 + $t47623_i6017) >= -4611686018427387904 ? (350 + $t47623_i6017) : march_int_ovf((350 + $t47623_i6017), 0));
          }
        }
      }
      {
        let f;
        {
          let $t48904;
          {
            let $t48900;
            {
              let $t48899;
              {
                const $t48898 = m.paid;
                $t48899 = (($t48898 - here) < 4611686018427387904 && ($t48898 - here) >= -4611686018427387904 ? ($t48898 - here) : march_int_ovf(($t48898 - here), 1));
              }
              $t48900 = $t48899;
            }
            {
              let $t48903;
              {
                let $t48902;
                {
                  const $t48901 = ((next - here) < 4611686018427387904 && (next - here) >= -4611686018427387904 ? (next - here) : march_int_ovf((next - here), 1));
                  {
                    const $t2474_i6014 = (1 > $t48901);
                    if ($t2474_i6014 === true) {
                      $t48902 = 1;
                    } else {
                      $t48902 = $t48901;
                    }
                  }
                }
                $t48903 = $t48902;
              }
              $t48904 = ($t48900 / $t48903);
            }
          }
          {
            let $t45800_i6011;
            {
              const $t45798_i14778 = (0. >= $t48904);
              if ($t45798_i14778 === true) {
                $t45800_i6011 = 0.;
              } else {
                $t45800_i6011 = $t48904;
              }
            }
            {
              const $t45799_i14775 = (1. < $t45800_i6011);
              if ($t45799_i14775 === true) {
                f = 1.;
              } else {
                f = $t45800_i6011;
              }
            }
          }
        }
        {
          let $t48911;
          {
            let $t48908;
            {
              let $t48907;
              {
                let $t48906;
                {
                  const $t48905 = m.stage;
                  $t48906 = (($t48905 + 1) < 4611686018427387904 && ($t48905 + 1) >= -4611686018427387904 ? ($t48905 + 1) : march_int_ovf(($t48905 + 1), 0));
                }
                $t48907 = String($t48906);
              }
              {
                const $rc_2748 = ("STAGE " + $t48907);
                $t48908 = $rc_2748;
              }
            }
            {
              let $t48910;
              {
                const $t48909 = m.style;
                $t48910 = $t48909.tint;
              }
              $t48911 = { $: "Label", _0: $t48908, _1: 44., _2: 9., _3: 10., _4: $t48910 };
            }
          }
          {
            let $t48915;
            {
              let $t48914;
              {
                let $t48913;
                {
                  const $t48912 = m.style;
                  $t48913 = $t48912.name;
                }
                $t48914 = ($t48913 + " BALL");
              }
              $t48915 = { $: "Label", _0: $t48914, _1: 44., _2: 21., _3: 8., _4: "#d8ccff" };
            }
            {
              const $t48916 = { $: "Box", _0: 10., _1: 29., _2: 68., _3: 4., _4: "#0b0614" };
              {
                let $t48920;
                {
                  const $t48917 = (68. * f);
                  {
                    let $t48919;
                    {
                      const $t48918 = m.style;
                      $t48919 = $t48918.tint;
                    }
                    $t48920 = { $: "Box", _0: 10., _1: 29., _2: $t48917, _3: 4., _4: $t48919 };
                  }
                }
                {
                  let $t48923;
                  {
                    let $t48922;
                    {
                      const $t48921 = String(next);
                      {
                        const $rc_2747 = ("next at " + $t48921);
                        $t48922 = $rc_2747;
                      }
                    }
                    $t48923 = { $: "Label", _0: $t48922, _1: 44., _2: 39., _3: 6.5, _4: "rgba(185,166,255,0.6)" };
                  }
                  {
                    const $t48924 = { $: "Nil" };
                    {
                      const $t48925 = { $: "Cons", _0: $t48923, _1: $t48924 };
                      {
                        const $t48926 = { $: "Cons", _0: $t48920, _1: $t48925 };
                        {
                          const $t48927 = { $: "Cons", _0: $t48916, _1: $t48926 };
                          {
                            const $t48928 = { $: "Cons", _0: $t48915, _1: $t48927 };
                            return { $: "Cons", _0: $t48911, _1: $t48928 };
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$stage_ops$clo = { _0: ($_, m) => Spin$View$stage_ops(m) };

function Spin$View$buff_ops(m) {
  {
    let $p48962;
    $p48962 = Spin$Game$streak(m);
    {
      const n = $p48962._0;
      {
        const left = $p48962._1;
        {
          let $t48931;
          {
            const $t48929 = (n > 0);
            {
              const $t48930 = (left > 0.);
              $t48931 = ($t48929 && $t48930);
            }
          }
          {
            let streak;
            if ($t48931 === true) {
              {
                let $t48934;
                {
                  let $t48933;
                  {
                    const $t48932 = String(n);
                    {
                      const $rc_2749 = ("STREAK " + $t48932);
                      $t48933 = $rc_2749;
                    }
                  }
                  $t48934 = { $: "Label", _0: $t48933, _1: 340., _2: 8., _3: 9., _4: "#5cf2ff" };
                }
                {
                  let $t48938;
                  {
                    let $t48937;
                    {
                      const $t48935 = (68. * left);
                      $t48937 = ($t48935 / 12.);
                    }
                    $t48938 = { $: "Box", _0: 306., _1: 14., _2: $t48937, _3: 3., _4: "#5cf2ff" };
                  }
                  {
                    const $t48939 = { $: "Nil" };
                    {
                      const $t48940 = { $: "Cons", _0: $t48938, _1: $t48939 };
                      streak = { $: "Cons", _0: $t48934, _1: $t48940 };
                    }
                  }
                }
              }
            } else {
              {
                const $t48941 = { $: "Label", _0: "no streak", _1: 340., _2: 8., _3: 7., _4: "rgba(92,242,255,0.35)" };
                {
                  const $t48942 = { $: "Nil" };
                  streak = { $: "Cons", _0: $t48941, _1: $t48942 };
                }
              }
            }
            {
              const $t48943 = m.buffs;
              {
                let $t48944;
                {
                  const go_i6022 = { $: "$Clo_go$0_List_enumerate_List_T_Buff_Float", _0: go$apply$0_List_enumerate_List_T_Buff_Float };
                  {
                    const $t1365_i6023 = { $: "Nil" };
                    $t48944 = go$apply$0_List_enumerate_List_T_Buff_Float(go_i6022, $t48943, 0, $t1365_i6023);
                  }
                }
                {
                  const $t48961 = { $: "$Clo_$lam0_Spin_View_buff_ops$0_Spin_View_buff_ops", _0: $lam0_Spin_View_buff_ops$apply$0_Spin_View_buff_ops, _1: m };
                  {
                    let rows;
                    {
                      const xs_i13361 = $t48944;
                      {
                        const f_i13362 = $t48961;
                        switch (xs_i13361.$) {
                          case "Nil": {
                            rows = { $: "Nil" };
                            break;
                          }
                          case "Cons": {
                            const $f1006_i13363 = xs_i13361._0;
                            const $f1007_i13364 = xs_i13361._1;
                            {
                              const t_i13365 = $f1007_i13364;
                              {
                                const h_i13366 = $f1006_i13363;
                                {
                                  let $t1004_i13367;
                                  $t1004_i13367 = f_i13362._0(f_i13362, h_i13366);
                                  {
                                    const $trmc15_i13368 = { $: "Cons", _0: $t1004_i13367, _1: null };
                                    List$map$dps$List_T_Int_T_Buff_Float$Fn_T_Int_T_Buff_Float_Op$List_Op(t_i13365, f_i13362, $trmc15_i13368);
                                    rows = $trmc15_i13368;
                                  }
                                }
                              }
                            }
                            break;
                          }
                          default: {
                            throw new Error("non-exhaustive pattern match");
                            break;
                          }
                        }
                      }
                    }
                    return List$append$List_Op$List_Op(streak, rows);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$buff_ops$clo = { _0: ($_, m) => Spin$View$buff_ops(m) };

function Spin$View$banner_ops(m) {
  {
    const b = m.banner;
    {
      let $t48968;
      {
        let $t48964;
        {
          const $t48963 = b.left;
          $t48964 = ($t48963 > 0.);
        }
        {
          let $t48967;
          {
            const $t48965 = m.mode;
            {
              const $t48966 = { $: "Playing" };
              {
                const $rc_2750 = march_deep_eq($t48965, $t48966);
                $t48967 = $rc_2750;
              }
            }
          }
          $t48968 = ($t48964 && $t48967);
        }
      }
      if ($t48968 === true) {
        {
          let a;
          {
            let $t48970;
            {
              const $t48969 = b.left;
              $t48970 = ($t48969 * 3.);
            }
            {
              const $t45799_i6046 = ($t48970 < 1.);
              if ($t45799_i6046 === true) {
                a = $t48970;
              } else {
                a = 1.;
              }
            }
          }
          {
            let main;
            {
              const $t48971 = b.hot;
              if ($t48971 === true) {
                main = Spin$Draw$rgba(255, 211, 107, a);
              } else {
                main = Spin$Draw$rgba(255, 255, 255, a);
              }
            }
            {
              let $t48974;
              {
                let $t48973;
                {
                  const $t48972 = (0.55 * a);
                  $t48973 = Spin$Draw$rgba(7, 4, 15, $t48972);
                }
                $t48974 = { $: "Box", _0: 100., _1: 548., _2: 170., _3: 40., _4: $t48973 };
              }
              {
                let $t48976;
                {
                  const $t48975 = b.text;
                  $t48976 = { $: "Label", _0: $t48975, _1: 185., _2: 562., _3: 16., _4: main };
                }
                {
                  let $t48979;
                  {
                    const $t48977 = b.sub;
                    {
                      const $t48978 = Spin$Draw$rgba(200, 190, 255, a);
                      $t48979 = { $: "Label", _0: $t48977, _1: 185., _2: 579., _3: 8., _4: $t48978 };
                    }
                  }
                  {
                    const $t48980 = { $: "Nil" };
                    {
                      const $t48981 = { $: "Cons", _0: $t48979, _1: $t48980 };
                      {
                        const $t48982 = { $: "Cons", _0: $t48976, _1: $t48981 };
                        return { $: "Cons", _0: $t48974, _1: $t48982 };
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        return { $: "Nil" };
      }
    }
  }
}
const Spin$View$banner_ops$clo = { _0: ($_, m) => Spin$View$banner_ops(m) };

function Spin$View$panel_ops(m) {
  {
    let low;
    {
      let $t48984;
      {
        const $t48983 = m.credits;
        $t48984 = ($t48983 <= 10);
      }
      {
        let $t48987;
        {
          const $t48985 = m.mode;
          {
            const $t48986 = { $: "Playing" };
            {
              const $rc_2753 = march_deep_eq($t48985, $t48986);
              $t48987 = $rc_2753;
            }
          }
        }
        low = ($t48984 && $t48987);
      }
    }
    {
      let blink;
      {
        let $t48991;
        {
          let $t48990;
          {
            let $t48989;
            {
              const $t48988 = m.clock;
              $t48989 = ($t48988 * 10.);
            }
            $t48990 = Math.sin($t48989);
          }
          $t48991 = ($t48990 > 0.);
        }
        blink = (low && $t48991);
      }
      {
        let credit_colour;
        if (blink === true) {
          credit_colour = "#ff3b4e";
        } else {
          credit_colour = "#ffd36b";
        }
        {
          let every;
          {
            const $t48992 = m.alive;
            {
              const $t48993 = m.paid;
              {
                let $t46168_i6094;
                {
                  let $t46167_i6093;
                  {
                    let $t46166_i6092;
                    {
                      let $t46163_i6089;
                      {
                        const $t46162_i6088 = ($t48992 * 0.00385);
                        $t46163_i6089 = (0. - $t46162_i6088);
                      }
                      {
                        let $t46165_i6091;
                        {
                          const $t46164_i6090 = $t48993;
                          $t46165_i6091 = ($t46164_i6090 * 0.00462);
                        }
                        $t46166_i6092 = ($t46163_i6089 - $t46165_i6091);
                      }
                    }
                    $t46167_i6093 = Math.exp($t46166_i6092);
                  }
                  $t46168_i6094 = (2. * $t46167_i6093);
                }
                {
                  const $t45798_i14787 = ($t46168_i6094 >= 0.05);
                  if ($t45798_i14787 === true) {
                    every = $t46168_i6094;
                  } else {
                    every = 0.05;
                  }
                }
              }
            }
          }
          {
            let f;
            {
              let $t48995;
              {
                const $t48994 = m.burn_clock;
                $t48995 = ($t48994 / every);
              }
              {
                let $t45800_i6085;
                {
                  const $t45798_i14784 = (0. >= $t48995);
                  if ($t45798_i14784 === true) {
                    $t45800_i6085 = 0.;
                  } else {
                    $t45800_i6085 = $t48995;
                  }
                }
                {
                  const $t45799_i14781 = (1. < $t45800_i6085);
                  if ($t45799_i14781 === true) {
                    f = 1.;
                  } else {
                    f = $t45800_i6085;
                  }
                }
              }
            }
            {
              let $t48997;
              {
                const $t48996 = (-92.);
                $t48997 = { $: "Box", _0: 6., _1: $t48996, _2: 388., _3: 84., _4: "#140a24" };
              }
              {
                let $t48999;
                {
                  const $t48998 = (-88.);
                  $t48999 = { $: "Box", _0: 10., _1: $t48998, _2: 380., _3: 76., _4: "#1f1035" };
                }
                {
                  let $t49001;
                  {
                    const $t49000 = (-74.);
                    $t49001 = { $: "Label", _0: "CREDITS", _1: 80., _2: $t49000, _3: 9., _4: "#b9a6ff" };
                  }
                  {
                    let $t49005;
                    {
                      let $t49003;
                      {
                        const $t49002 = m.credits;
                        $t49003 = String($t49002);
                      }
                      {
                        const $t49004 = (-42.);
                        $t49005 = { $: "Label", _0: $t49003, _1: 80., _2: $t49004, _3: 38., _4: credit_colour };
                      }
                    }
                    {
                      let $t49007;
                      {
                        const $t49006 = (-74.);
                        $t49007 = { $: "Label", _0: "METER", _1: 200., _2: $t49006, _3: 9., _4: "#b9a6ff" };
                      }
                      {
                        let $t49009;
                        {
                          const $t49008 = (-54.);
                          $t49009 = { $: "Box", _0: 160., _1: $t49008, _2: 80., _3: 12., _4: "#0b0614" };
                        }
                        {
                          let $t49013;
                          {
                            const $t49010 = (-54.);
                            {
                              const $t49011 = (80. * f);
                              {
                                let $t49012;
                                if (low === true) {
                                  $t49012 = "#ff3b4e";
                                } else {
                                  $t49012 = "#ff8a3d";
                                }
                                $t49013 = { $: "Box", _0: 160., _1: $t49010, _2: $t49011, _3: 12., _4: $t49012 };
                              }
                            }
                          }
                          {
                            let $t49017;
                            {
                              let $t49015;
                              {
                                let $t49014;
                                {
                                  let t_i13371;
                                  {
                                    const $t49040_i13370 = (every * 10.);
                                    t_i13371 = march_float_round($t49040_i13370);
                                  }
                                  {
                                    let $t49042_i13373;
                                    {
                                      const $t49041_i13372 = ((t_i13371 - t_i13371 % 10) / 10);
                                      $t49042_i13373 = String($t49041_i13372);
                                    }
                                    {
                                      let $t49044_i13375;
                                      {
                                        const $t49043_i13374 = (t_i13371 % 10);
                                        $t49044_i13375 = String($t49043_i13374);
                                      }
                                      {
                                        const $rc_2754_i13376 = march_string_concat3($t49042_i13373, ".", $t49044_i13375);
                                        $t49014 = $rc_2754_i13376;
                                      }
                                    }
                                  }
                                }
                                {
                                  const $rc_2752 = march_string_concat3("1 per ", $t49014, "s");
                                  $t49015 = $rc_2752;
                                }
                              }
                              {
                                const $t49016 = (-28.);
                                $t49017 = { $: "Label", _0: $t49015, _1: 200., _2: $t49016, _3: 8., _4: "#8a7ab0" };
                              }
                            }
                            {
                              let $t49019;
                              {
                                const $t49018 = (-74.);
                                $t49019 = { $: "Label", _0: "PAID", _1: 320., _2: $t49018, _3: 9., _4: "#b9a6ff" };
                              }
                              {
                                let $t49023;
                                {
                                  let $t49021;
                                  {
                                    const $t49020 = m.paid;
                                    $t49021 = String($t49020);
                                  }
                                  {
                                    const $t49022 = (-50.);
                                    $t49023 = { $: "Label", _0: $t49021, _1: 320., _2: $t49022, _3: 22., _4: "#7dff7a" };
                                  }
                                }
                                {
                                  let $t49028;
                                  {
                                    let $t49026;
                                    {
                                      let $t49025;
                                      {
                                        const $t49024 = m.best;
                                        $t49025 = String($t49024);
                                      }
                                      {
                                        const $rc_2751 = ("BEST " + $t49025);
                                        $t49026 = $rc_2751;
                                      }
                                    }
                                    {
                                      const $t49027 = (-26.);
                                      $t49028 = { $: "Label", _0: $t49026, _1: 320., _2: $t49027, _3: 9., _4: "#8a7ab0" };
                                    }
                                  }
                                  {
                                    const $t49029 = { $: "Nil" };
                                    {
                                      const $t49030 = { $: "Cons", _0: $t49028, _1: $t49029 };
                                      {
                                        const $t49031 = { $: "Cons", _0: $t49023, _1: $t49030 };
                                        {
                                          const $t49032 = { $: "Cons", _0: $t49019, _1: $t49031 };
                                          {
                                            const $t49033 = { $: "Cons", _0: $t49017, _1: $t49032 };
                                            {
                                              const $t49034 = { $: "Cons", _0: $t49013, _1: $t49033 };
                                              {
                                                const $t49035 = { $: "Cons", _0: $t49009, _1: $t49034 };
                                                {
                                                  const $t49036 = { $: "Cons", _0: $t49007, _1: $t49035 };
                                                  {
                                                    const $t49037 = { $: "Cons", _0: $t49005, _1: $t49036 };
                                                    {
                                                      const $t49038 = { $: "Cons", _0: $t49001, _1: $t49037 };
                                                      {
                                                        const $t49039 = { $: "Cons", _0: $t48999, _1: $t49038 };
                                                        return { $: "Cons", _0: $t48997, _1: $t49039 };
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$panel_ops$clo = { _0: ($_, m) => Spin$View$panel_ops(m) };

function Spin$View$screen_ops(m) {
  {
    const $t49045 = m.mode;
    switch ($t49045.$) {
      case "Playing": {
        return { $: "Nil" };
        break;
      }
      case "Attract": {
        {
          let pulse;
          {
            let $t49049;
            {
              let $t49048;
              {
                let $t49047;
                {
                  const $t49046 = m.clock;
                  $t49047 = ($t49046 * 3.);
                }
                $t49048 = Math.sin($t49047);
              }
              $t49049 = (0.45 * $t49048);
            }
            pulse = (0.55 + $t49049);
          }
          {
            const $t49050 = { $: "Box", _0: 30., _1: 150., _2: 310., _3: 330., _4: "rgba(7,4,15,0.86)" };
            {
              const $t49051 = { $: "Label", _0: "SPIN", _1: 185., _2: 190., _3: 40., _4: "#ff3fa4" };
              {
                const $t49052 = { $: "Label", _0: "SPIN", _1: 185., _2: 232., _3: 40., _4: "#5cf2ff" };
                {
                  const $t49054 = { $: "Label", _0: "SPIN", _1: 185., _2: 274., _3: 40., _4: "#ffd36b" };
                  {
                    const $t49055 = { $: "Label", _0: "pinball that plays a slot machine", _1: 185., _2: 306., _3: 10., _4: "#d8ccff" };
                    {
                      const $t49056 = { $: "Label", _0: "TARGETS put their symbol on the line:", _1: 185., _2: 330., _3: 9., _4: "#ffffff" };
                      {
                        const $t49057 = { $: "Label", _0: "hit three, left reel to right, to spell it", _1: 185., _2: 344., _3: 9., _4: "#ffffff" };
                        {
                          const $t49058 = { $: "Label", _0: "the SPINNER spins all three", _1: 185., _2: 362., _3: 9., _4: "#5cf2ff" };
                          {
                            const $t49059 = { $: "Label", _0: "BUMPERS nudge them after a miss", _1: 185., _2: 376., _3: 9., _4: "#ff8fcf" };
                            {
                              const $t49060 = { $: "Label", _0: "TOP LANES hold a reel; all three: x2", _1: 185., _2: 390., _3: 9., _4: "#7dff7a" };
                              {
                                const $t49061 = { $: "Label", _0: "the meter eats credits. only the reels pay.", _1: 185., _2: 412., _3: 9., _4: "#ff8a3d" };
                                {
                                  let $t49063;
                                  {
                                    const $t49062 = Spin$Draw$rgba(255, 211, 107, pulse);
                                    $t49063 = { $: "Label", _0: "TAP OR PRESS SPACE", _1: 185., _2: 446., _3: 14., _4: $t49062 };
                                  }
                                  {
                                    const $t49064 = { $: "Nil" };
                                    {
                                      const $t49065 = { $: "Cons", _0: $t49063, _1: $t49064 };
                                      {
                                        const $t49066 = { $: "Cons", _0: $t49061, _1: $t49065 };
                                        {
                                          const $t49067 = { $: "Cons", _0: $t49060, _1: $t49066 };
                                          {
                                            const $t49068 = { $: "Cons", _0: $t49059, _1: $t49067 };
                                            {
                                              const $t49069 = { $: "Cons", _0: $t49058, _1: $t49068 };
                                              {
                                                const $t49070 = { $: "Cons", _0: $t49057, _1: $t49069 };
                                                {
                                                  const $t49071 = { $: "Cons", _0: $t49056, _1: $t49070 };
                                                  {
                                                    const $t49072 = { $: "Cons", _0: $t49055, _1: $t49071 };
                                                    {
                                                      const $t49073 = { $: "Cons", _0: $t49054, _1: $t49072 };
                                                      {
                                                        const $t49074 = { $: "Cons", _0: $t49052, _1: $t49073 };
                                                        {
                                                          const $t49075 = { $: "Cons", _0: $t49051, _1: $t49074 };
                                                          return { $: "Cons", _0: $t49050, _1: $t49075 };
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        break;
      }
      case "Busted": {
        {
          let pulse;
          {
            let $t49079;
            {
              let $t49078;
              {
                let $t49077;
                {
                  const $t49076 = m.clock;
                  $t49077 = ($t49076 * 3.);
                }
                $t49078 = Math.sin($t49077);
              }
              $t49079 = (0.45 * $t49078);
            }
            pulse = (0.55 + $t49079);
          }
          {
            const $t49080 = { $: "Box", _0: 40., _1: 230., _2: 290., _3: 190., _4: "rgba(7,4,15,0.9)" };
            {
              const $t49081 = { $: "Label", _0: "BUSTED", _1: 185., _2: 270., _3: 38., _4: "#ff3b4e" };
              {
                let $t49085;
                {
                  let $t49084;
                  {
                    let $t49083;
                    {
                      const $t49082 = m.paid;
                      $t49083 = String($t49082);
                    }
                    {
                      const $rc_2756 = ("the reels paid " + $t49083);
                      $t49084 = $rc_2756;
                    }
                  }
                  $t49085 = { $: "Label", _0: $t49084, _1: 185., _2: 312., _3: 13., _4: "#ffffff" };
                }
                {
                  let $t49090;
                  {
                    let $t49088;
                    {
                      let $t49087;
                      {
                        const $t49086 = m.best;
                        $t49087 = String($t49086);
                      }
                      {
                        const $rc_2755 = ("best " + $t49087);
                        $t49088 = $rc_2755;
                      }
                    }
                    $t49090 = { $: "Label", _0: $t49088, _1: 185., _2: 334., _3: 11., _4: "#ffd36b" };
                  }
                  {
                    let $t49096;
                    {
                      let $t49095;
                      {
                        let $t49094;
                        {
                          let $t49093;
                          {
                            let $t49092;
                            {
                              const $t49091 = m.banner;
                              $t49092 = $t49091.left;
                            }
                            $t49093 = ($t49092 < 999998.);
                          }
                          if ($t49093 === true) {
                            $t49094 = pulse;
                          } else {
                            $t49094 = 0.2;
                          }
                        }
                        $t49095 = Spin$Draw$rgba(255, 211, 107, $t49094);
                      }
                      $t49096 = { $: "Label", _0: "TAP OR PRESS SPACE", _1: 185., _2: 386., _3: 13., _4: $t49095 };
                    }
                    {
                      const $t49097 = { $: "Nil" };
                      {
                        const $t49098 = { $: "Cons", _0: $t49096, _1: $t49097 };
                        {
                          const $t49099 = { $: "Cons", _0: $t49090, _1: $t49098 };
                          {
                            const $t49100 = { $: "Cons", _0: $t49085, _1: $t49099 };
                            {
                              const $t49101 = { $: "Cons", _0: $t49081, _1: $t49100 };
                              return { $: "Cons", _0: $t49080, _1: $t49101 };
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
  }
}
const Spin$View$screen_ops$clo = { _0: ($_, m) => Spin$View$screen_ops(m) };

function Spin$View$frame(m, touch) {
  {
    const $t49107 = { $: "Clear", _0: "#07040f" };
    {
      const $t49108 = { $: "Nil" };
      {
        const $t49109 = { $: "Cons", _0: $t49107, _1: $t49108 };
        {
          let $t49110;
          $t49110 = Spin$View$field_ops(m);
          {
            let $t49111;
            $t49111 = Spin$View$flash_ops(m);
            {
              let $t49112;
              {
                let hot_i6202;
                {
                  const $t48729_i6201 = m.win_glow;
                  hot_i6202 = ($t48729_i6201 > 0.);
                }
                {
                  let speed_i6203;
                  if (hot_i6202 === true) {
                    speed_i6203 = 14.;
                  } else {
                    speed_i6203 = 3.;
                  }
                  {
                    let head_i6205;
                    {
                      const $t48730_i6204 = m.clock;
                      head_i6205 = ($t48730_i6204 * speed_i6203);
                    }
                    {
                      let $t48731_i6206;
                      {
                        const go_i14801 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                        {
                          const $t926_i14802 = ((25 - 1) < 4611686018427387904 && (25 - 1) >= -4611686018427387904 ? (25 - 1) : march_int_ovf((25 - 1), 1));
                          {
                            const $t927_i14803 = { $: "Nil" };
                            $t48731_i6206 = go$apply$0_List_range(go_i14801, $t926_i14802, $t927_i14803);
                          }
                        }
                      }
                      {
                        const $t48754_i6207 = { $: "$Clo_$lam0_Spin_View_chase_ops$0_Spin_View_chase_ops", _0: $lam0_Spin_View_chase_ops$apply$0_Spin_View_chase_ops, _1: head_i6205, _2: hot_i6202, _3: m };
                        $t49112 = List$map$List_Int$Fn_Int_Op($t48731_i6206, $t48754_i6207);
                      }
                    }
                  }
                }
              }
              {
                let $t49113;
                $t49113 = Spin$View$machine_ops(m);
                {
                  let $t49114;
                  $t49114 = Spin$View$marquee_ops(m);
                  {
                    const $t49115 = m.table;
                    {
                      const $t49116 = $t49115.parts;
                      {
                        let $t49118;
                        $t49118 = { $: "$Clo_$lam0_Spin_View_frame$0_Spin_View_frame", _0: $lam0_Spin_View_frame$apply$0_Spin_View_frame, _1: m };
                        {
                          let $t49119;
                          {
                            const xs_i13401 = $t49116;
                            {
                              const f_i13402 = $t49118;
                              switch (xs_i13401.$) {
                                case "Nil": {
                                  $t49119 = { $: "Nil" };
                                  break;
                                }
                                case "Cons": {
                                  const $f1006_i13403 = xs_i13401._0;
                                  const $f1007_i13404 = xs_i13401._1;
                                  {
                                    const t_i13405 = $f1007_i13404;
                                    {
                                      const h_i13406 = $f1006_i13403;
                                      {
                                        let $t1004_i13407;
                                        $t1004_i13407 = f_i13402._0(f_i13402, h_i13406);
                                        {
                                          const $trmc15_i13408 = { $: "Cons", _0: $t1004_i13407, _1: null };
                                          List$map$dps$List_Part$Fn_Part_List_Op$List_List_Op(t_i13405, f_i13402, $trmc15_i13408);
                                          $t49119 = $trmc15_i13408;
                                        }
                                      }
                                    }
                                  }
                                  break;
                                }
                                default: {
                                  throw new Error("non-exhaustive pattern match");
                                  break;
                                }
                              }
                            }
                          }
                          {
                            let $t49120;
                            {
                              const prepend_reversed_i6197 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                              {
                                const go_i6198 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i6197 };
                                {
                                  const $t1124_i6199 = { $: "Nil" };
                                  $t49120 = go$apply$1_List_concat_List_List_Op(go_i6198, $t49119, $t1124_i6199);
                                }
                              }
                            }
                            {
                              let $t49121;
                              $t49121 = Spin$View$plunger_ops(m, touch);
                              {
                                let $t49123;
                                {
                                  const $t49122 = m.table;
                                  $t49123 = $t49122.left;
                                }
                                {
                                  const $t49124 = m.left;
                                  {
                                    const $t49125 = Spin$View$flipper_ops($t49123, $t49124);
                                    {
                                      let $t49127;
                                      {
                                        const $t49126 = m.table;
                                        $t49127 = $t49126.right;
                                      }
                                      {
                                        const $t49128 = m.right;
                                        {
                                          const $t49129 = Spin$View$flipper_ops($t49127, $t49128);
                                          {
                                            let $t49130;
                                            {
                                              const m_i13393 = m;
                                              {
                                                const $t48862_i13394 = m.sparks;
                                                {
                                                  const $t48876_i13395 = { $: "$Clo_$lam0_Spin_View_spark_ops$0_Spin_View_spark_ops", _0: $lam0_Spin_View_spark_ops$apply$0_Spin_View_spark_ops };
                                                  {
                                                    let $t48877_i13396;
                                                    {
                                                      const xs_i14874 = $t48862_i13394;
                                                      {
                                                        const f_i14875 = $t48876_i13395;
                                                        switch (xs_i14874.$) {
                                                          case "Nil": {
                                                            $t48877_i13396 = { $: "Nil" };
                                                            break;
                                                          }
                                                          case "Cons": {
                                                            const $f1006_i14876 = xs_i14874._0;
                                                            const $f1007_i14877 = xs_i14874._1;
                                                            {
                                                              const t_i14878 = $f1007_i14877;
                                                              {
                                                                const h_i14879 = $f1006_i14876;
                                                                {
                                                                  let $t1004_i14880;
                                                                  $t1004_i14880 = f_i14875._0(f_i14875, h_i14879);
                                                                  {
                                                                    const $trmc15_i14881 = { $: "Cons", _0: $t1004_i14880, _1: null };
                                                                    List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Op$List_List_Op(t_i14878, f_i14875, $trmc15_i14881);
                                                                    $t48877_i13396 = $trmc15_i14881;
                                                                  }
                                                                }
                                                              }
                                                            }
                                                            break;
                                                          }
                                                          default: {
                                                            throw new Error("non-exhaustive pattern match");
                                                            break;
                                                          }
                                                        }
                                                      }
                                                    }
                                                    {
                                                      const prepend_reversed_i5986_i13398 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                      {
                                                        const go_i5987_i13399 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5986_i13398 };
                                                        {
                                                          const $t1124_i5988_i13400 = { $: "Nil" };
                                                          $t49130 = go$apply$1_List_concat_List_List_Op(go_i5987_i13399, $t48877_i13396, $t1124_i5988_i13400);
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                            {
                                              let $t49131;
                                              {
                                                const m_i13385 = m;
                                                {
                                                  const $t48878_i13386 = m.pops;
                                                  {
                                                    const $t48893_i13387 = { $: "$Clo_$lam0_Spin_View_pop_ops$0_Spin_View_pop_ops", _0: $lam0_Spin_View_pop_ops$apply$0_Spin_View_pop_ops };
                                                    {
                                                      let $t48894_i13388;
                                                      {
                                                        const xs_i14866 = $t48878_i13386;
                                                        {
                                                          const f_i14867 = $t48893_i13387;
                                                          switch (xs_i14866.$) {
                                                            case "Nil": {
                                                              $t48894_i13388 = { $: "Nil" };
                                                              break;
                                                            }
                                                            case "Cons": {
                                                              const $f1006_i14868 = xs_i14866._0;
                                                              const $f1007_i14869 = xs_i14866._1;
                                                              {
                                                                const t_i14870 = $f1007_i14869;
                                                                {
                                                                  const h_i14871 = $f1006_i14868;
                                                                  {
                                                                    let $t1004_i14872;
                                                                    $t1004_i14872 = f_i14867._0(f_i14867, h_i14871);
                                                                    {
                                                                      const $trmc15_i14873 = { $: "Cons", _0: $t1004_i14872, _1: null };
                                                                      List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_List_Op$List_List_Op(t_i14870, f_i14867, $trmc15_i14873);
                                                                      $t48894_i13388 = $trmc15_i14873;
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                              break;
                                                            }
                                                            default: {
                                                              throw new Error("non-exhaustive pattern match");
                                                              break;
                                                            }
                                                          }
                                                        }
                                                      }
                                                      {
                                                        const prepend_reversed_i5990_i13390 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                        {
                                                          const go_i5991_i13391 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5990_i13390 };
                                                          {
                                                            const $t1124_i5992_i13392 = { $: "Nil" };
                                                            $t49131 = go$apply$1_List_concat_List_List_Op(go_i5991_i13391, $t48894_i13388, $t1124_i5992_i13392);
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                              {
                                                const $t49132 = { $: "Fade", _0: 1. };
                                                {
                                                  const $t49133 = { $: "Nil" };
                                                  {
                                                    const $t49134 = { $: "Cons", _0: $t49132, _1: $t49133 };
                                                    {
                                                      let $t49135;
                                                      $t49135 = Spin$View$banner_ops(m);
                                                      {
                                                        const $t49136 = m.balls;
                                                        {
                                                          let $t49138;
                                                          $t49138 = { $: "$Clo_$lam1_Spin_View_frame$1_Spin_View_frame", _0: $lam1_Spin_View_frame$apply$1_Spin_View_frame, _1: m };
                                                          {
                                                            let $t49139;
                                                            {
                                                              const xs_i13377 = $t49136;
                                                              {
                                                                const f_i13378 = $t49138;
                                                                switch (xs_i13377.$) {
                                                                  case "Nil": {
                                                                    $t49139 = { $: "Nil" };
                                                                    break;
                                                                  }
                                                                  case "Cons": {
                                                                    const $f1006_i13379 = xs_i13377._0;
                                                                    const $f1007_i13380 = xs_i13377._1;
                                                                    {
                                                                      const t_i13381 = $f1007_i13380;
                                                                      {
                                                                        const h_i13382 = $f1006_i13379;
                                                                        {
                                                                          let $t1004_i13383;
                                                                          $t1004_i13383 = f_i13378._0(f_i13378, h_i13382);
                                                                          {
                                                                            const $trmc15_i13384 = { $: "Cons", _0: $t1004_i13383, _1: null };
                                                                            List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Op$List_List_Op(t_i13381, f_i13378, $trmc15_i13384);
                                                                            $t49139 = $trmc15_i13384;
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                    break;
                                                                  }
                                                                  default: {
                                                                    throw new Error("non-exhaustive pattern match");
                                                                    break;
                                                                  }
                                                                }
                                                              }
                                                            }
                                                            {
                                                              let $t49140;
                                                              {
                                                                const prepend_reversed_i6193 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                                {
                                                                  const go_i6194 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i6193 };
                                                                  {
                                                                    const $t1124_i6195 = { $: "Nil" };
                                                                    $t49140 = go$apply$1_List_concat_List_List_Op(go_i6194, $t49139, $t1124_i6195);
                                                                  }
                                                                }
                                                              }
                                                              {
                                                                let $t49143;
                                                                {
                                                                  const $t49141 = m.mode;
                                                                  {
                                                                    const $t49142 = { $: "Playing" };
                                                                    {
                                                                      const $rc_2757 = march_deep_eq($t49141, $t49142);
                                                                      $t49143 = $rc_2757;
                                                                    }
                                                                  }
                                                                }
                                                                {
                                                                  let $t49146;
                                                                  if ($t49143 === true) {
                                                                    {
                                                                      let $t49144;
                                                                      $t49144 = Spin$View$stage_ops(m);
                                                                      {
                                                                        let $t49145;
                                                                        $t49145 = Spin$View$buff_ops(m);
                                                                        $t49146 = List$append$List_Op$List_Op($t49144, $t49145);
                                                                      }
                                                                    }
                                                                  } else {
                                                                    $t49146 = { $: "Nil" };
                                                                  }
                                                                  {
                                                                    let $t49147;
                                                                    $t49147 = Spin$View$panel_ops(m);
                                                                    {
                                                                      let $t49148;
                                                                      if (touch === true) {
                                                                        {
                                                                          const $t49102_i6188 = { $: "Label", _0: "tap left · tap right to flip", _1: 140., _2: 752., _3: 9., _4: "rgba(185,166,255,0.55)" };
                                                                          {
                                                                            const $t49103_i6189 = { $: "Nil" };
                                                                            $t49148 = { $: "Cons", _0: $t49102_i6188, _1: $t49103_i6189 };
                                                                          }
                                                                        }
                                                                      } else {
                                                                        {
                                                                          const $t49104_i6190 = { $: "Label", _0: "Z / ←  left    right  → / M    SPACE launch", _1: 185., _2: 752., _3: 7.5, _4: "rgba(185,166,255,0.45)" };
                                                                          {
                                                                            const $t49105_i6191 = { $: "Nil" };
                                                                            $t49148 = { $: "Cons", _0: $t49104_i6190, _1: $t49105_i6191 };
                                                                          }
                                                                        }
                                                                      }
                                                                      {
                                                                        const $t49149 = Spin$View$screen_ops(m);
                                                                        {
                                                                          const $t49150 = { $: "Nil" };
                                                                          {
                                                                            const $t49151 = { $: "Cons", _0: $t49149, _1: $t49150 };
                                                                            {
                                                                              const $t49152 = { $: "Cons", _0: $t49148, _1: $t49151 };
                                                                              {
                                                                                const $t49153 = { $: "Cons", _0: $t49147, _1: $t49152 };
                                                                                {
                                                                                  const $t49154 = { $: "Cons", _0: $t49146, _1: $t49153 };
                                                                                  {
                                                                                    const $t49155 = { $: "Cons", _0: $t49140, _1: $t49154 };
                                                                                    {
                                                                                      const $t49156 = { $: "Cons", _0: $t49135, _1: $t49155 };
                                                                                      {
                                                                                        const $t49157 = { $: "Cons", _0: $t49134, _1: $t49156 };
                                                                                        {
                                                                                          const $t49158 = { $: "Cons", _0: $t49131, _1: $t49157 };
                                                                                          {
                                                                                            const $t49159 = { $: "Cons", _0: $t49130, _1: $t49158 };
                                                                                            {
                                                                                              const $t49160 = { $: "Cons", _0: $t49129, _1: $t49159 };
                                                                                              {
                                                                                                const $t49161 = { $: "Cons", _0: $t49125, _1: $t49160 };
                                                                                                {
                                                                                                  const $t49162 = { $: "Cons", _0: $t49121, _1: $t49161 };
                                                                                                  {
                                                                                                    const $t49163 = { $: "Cons", _0: $t49120, _1: $t49162 };
                                                                                                    {
                                                                                                      const $t49164 = { $: "Cons", _0: $t49114, _1: $t49163 };
                                                                                                      {
                                                                                                        const $t49165 = { $: "Cons", _0: $t49113, _1: $t49164 };
                                                                                                        {
                                                                                                          const $t49166 = { $: "Cons", _0: $t49112, _1: $t49165 };
                                                                                                          {
                                                                                                            const $t49167 = { $: "Cons", _0: $t49111, _1: $t49166 };
                                                                                                            {
                                                                                                              const $t49168 = { $: "Cons", _0: $t49110, _1: $t49167 };
                                                                                                              {
                                                                                                                const $t49169 = { $: "Cons", _0: $t49109, _1: $t49168 };
                                                                                                                {
                                                                                                                  const prepend_reversed_i6184 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                                                                                  {
                                                                                                                    const go_i6185 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i6184 };
                                                                                                                    {
                                                                                                                      const $t1124_i6186 = { $: "Nil" };
                                                                                                                      return go$apply$1_List_concat_List_List_Op(go_i6185, $t49169, $t1124_i6186);
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$frame$clo = { _0: ($_, m, touch) => Spin$View$frame(m, touch) };

function sound(c) {
  switch (c.$) {
    case "CueFlip": {
      return { _0: "flip", _1: 0. };
      break;
    }
    case "CueBumper": {
      return { _0: "bumper", _1: 0. };
      break;
    }
    case "CueSling": {
      return { _0: "sling", _1: 0. };
      break;
    }
    case "CueLoad": {
      const $f49175 = c._0;
      {
        const n = $f49175;
        {
          const $t49170 = n;
          return { _0: "load", _1: $t49170 };
        }
      }
      break;
    }
    case "CueLane": {
      return { _0: "lane", _1: 0. };
      break;
    }
    case "CueSpinner": {
      return { _0: "spinner", _1: 0. };
      break;
    }
    case "CueReelStop": {
      const $f49176 = c._0;
      {
        const i = $f49176;
        {
          const $t49171 = i;
          return { _0: "reelstop", _1: $t49171 };
        }
      }
      break;
    }
    case "CueReelStart": {
      return { _0: "reelstart", _1: 0. };
      break;
    }
    case "CueWin": {
      const $f49177 = c._0;
      {
        const n = $f49177;
        {
          const $t49172 = n;
          return { _0: "win", _1: $t49172 };
        }
      }
      break;
    }
    case "CueJackpot": {
      return { _0: "jackpot", _1: 0. };
      break;
    }
    case "CueMiss": {
      return { _0: "miss", _1: 0. };
      break;
    }
    case "CueNudge": {
      return { _0: "nudge", _1: 0. };
      break;
    }
    case "CueDrain": {
      return { _0: "drain", _1: 0. };
      break;
    }
    case "CueSaved": {
      return { _0: "saved", _1: 0. };
      break;
    }
    case "CueLaunch": {
      return { _0: "launch", _1: 0. };
      break;
    }
    case "CueBurn": {
      const $f49178 = c._0;
      {
        const n = $f49178;
        {
          const $t49173 = n;
          return { _0: "burn", _1: $t49173 };
        }
      }
      break;
    }
    case "CueBust": {
      return { _0: "bust", _1: 0. };
      break;
    }
    case "CueStart": {
      return { _0: "start", _1: 0. };
      break;
    }
    case "CueThud": {
      const $f49179 = c._0;
      {
        const speed = $f49179;
        return { _0: "thud", _1: speed };
      }
      break;
    }
    case "CueStore": {
      const $f49180 = c._0;
      return { _0: "", _1: 0. };
      break;
    }
    case "CueStage": {
      return { _0: "stage", _1: 0. };
      break;
    }
    case "CueBuff": {
      const $f49181 = c._0;
      {
        const tier = $f49181;
        {
          const $t49174 = tier;
          return { _0: "buff", _1: $t49174 };
        }
      }
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const sound$clo = { _0: ($_, c) => sound(c) };

function perform(c) {
  switch (c.$) {
    case "CueStore": {
      const $f49183 = c._0;
      {
        const best = $f49183;
        return glue_save_best$clo._0(glue_save_best$clo, best);
      }
      break;
    }
    default: {
      {
        const $p49182 = sound(c);
        {
          const name = $p49182._0;
          {
            const x = $p49182._1;
            return glue_sound$clo._0(glue_sound$clo, name, x);
          }
        }
      }
    }
  }
}
const perform$clo = { _0: ($_, c) => perform(c) };

function mark(m, flips) {
  {
    let $eff;
    {
      let $t49189;
      {
        const $t49188 = m.mode;
        switch ($t49188.$) {
          case "Attract": {
            $t49189 = "attract";
            break;
          }
          case "Playing": {
            $t49189 = "playing";
            break;
          }
          case "Busted": {
            $t49189 = "busted";
            break;
          }
          default: {
            throw new Error("non-exhaustive pattern match");
            break;
          }
        }
      }
      {
        const $rc_2764 = glue_mark$clo._0(glue_mark$clo, "data-mode", $t49189);
        $eff = $rc_2764;
      }
    }
  }
  {
    let $eff;
    {
      let $t49191;
      {
        const $t49190 = m.credits;
        $t49191 = String($t49190);
      }
      {
        const $rc_2763 = glue_mark$clo._0(glue_mark$clo, "data-credits", $t49191);
        $eff = $rc_2763;
      }
    }
  }
  {
    let $eff;
    {
      let $t49194;
      {
        let $t49193;
        {
          const $t49192 = m.balls;
          {  };
          $t49193 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t49192, 0);
        }
        $t49194 = String($t49193);
      }
      {
        const $rc_2762 = glue_mark$clo._0(glue_mark$clo, "data-balls", $t49194);
        $eff = $rc_2762;
      }
    }
  }
  {
    let $eff;
    {
      let $t49197;
      {
        let $t49196;
        {
          const $t49195 = m.bank;
          $t49196 = $t49195.banked;
        }
        $t49197 = String($t49196);
      }
      {
        const $rc_2761 = glue_mark$clo._0(glue_mark$clo, "data-banked", $t49197);
        $eff = $rc_2761;
      }
    }
  }
  {
    let $eff;
    {
      let $t49199;
      {
        const $t49198 = m.paid;
        $t49199 = String($t49198);
      }
      {
        const $rc_2760 = glue_mark$clo._0(glue_mark$clo, "data-paid", $t49199);
        $eff = $rc_2760;
      }
    }
  }
  {
    let $eff;
    {
      let $t49201;
      {
        const $t49200 = Spin$Game$waiting(m);
        if ($t49200 === true) {
          $t49201 = "1";
        } else {
          $t49201 = "0";
        }
      }
      {
        const $rc_2759 = glue_mark$clo._0(glue_mark$clo, "data-waiting", $t49201);
        $eff = $rc_2759;
      }
    }
  }
  {
    const $t49202 = String(flips);
    {
      const $rc_2758 = glue_mark$clo._0(glue_mark$clo, "data-flips", $t49202);
      return $rc_2758;
    }
  }
}
const mark$clo = { _0: ($_, m, flips) => mark(m, flips) };

function frame(t) {
  {
    const s = glue_cell_get();
    {
      let dt;
      {
        let $t49204;
        {
          const $t49203 = s.last_t;
          $t49204 = ($t49203 > 0.);
        }
        if ($t49204 === true) {
          {
            const $t49205 = s.last_t;
            dt = (t - $t49205);
          }
        } else {
          dt = 0.;
        }
      }
      {
        let $eff;
        {
          let $t49212;
          {
            let $t49207;
            {
              const $t49206 = s.model;
              $t49207 = Spin$Game$waiting($t49206);
            }
            {
              let $t49211;
              {
                let $t49209;
                {
                  const $t49208 = s.model;
                  $t49209 = $t49208.mode;
                }
                {
                  const $t49210 = { $: "Playing" };
                  {
                    const $rc_2768 = march_deep_eq($t49209, $t49210);
                    $t49211 = $rc_2768;
                  }
                }
              }
              $t49212 = ($t49207 && $t49211);
            }
          }
          $eff = glue_launch_button$clo._0(glue_launch_button$clo, 306., 724., 30., $t49212);
        }
      }
      {
        const $p49229 = glue_input();
        {
          const l = $p49229._0;
          {
            const r = $p49229._1;
            {
              const launch = $p49229._2;
              {
                const start = $p49229._3;
                {
                  let $p49228;
                  {
                    const $t49213 = s.model;
                    {
                      const $t49214 = ({ left: l, right: r, launch: launch, start: start });
                      $p49228 = Spin$Game$tick($t49213, $t49214, dt);
                    }
                  }
                  {
                    const m = $p49228._0;
                    {
                      const cues = $p49228._1;
                      {
                        let flips;
                        {
                          const $t49215 = s.flips;
                          {
                            let $t49219;
                            {
                              const $t49217 = { $: "$Clo_$lam0_frame$0_frame", _0: $lam0_frame$apply$0_frame };
                              {
                                let $t49218;
                                $t49218 = List$filter$List_Cue$Fn_Cue_Bool(cues, $t49217);
                                {
                                  let $rc_2767;
                                  {  };
                                  $rc_2767 = List$length_onto$List_Cue$Int($t49218, 0);
                                  $t49219 = $rc_2767;
                                }
                              }
                            }
                            flips = (($t49215 + $t49219) < 4611686018427387904 && ($t49215 + $t49219) >= -4611686018427387904 ? ($t49215 + $t49219) : march_int_ovf(($t49215 + $t49219), 0));
                          }
                        }
                        {
                          let $eff;
                          {
                            let $t49220;
                            $t49220 = ({ ...s, model: m, last_t: t, flips: flips });
                            {
                              const $rc_2766 = glue_cell_put$clo._0(glue_cell_put$clo, $t49220);
                              $eff = $rc_2766;
                            }
                          }
                        }
                        {
                          let $eff;
                          {
                            const f_i6211 = perform$clo;
                            {
                              const go_i6212 = { $: "$Clo_go$0_List_each_List_Cue_Fn_Cue_T_", _0: go$apply$0_List_each_List_Cue_Fn_Cue_T_, _1: f_i6211 };
                              $eff = go$apply$0_List_each_List_Cue_Fn_Cue_T_(go_i6212, cues);
                            }
                          }
                        }
                        {
                          let $p49227;
                          {
                            const $t47874_i6209 = (-96.);
                            $p49227 = { _0: 0., _1: $t47874_i6209, _2: 400., _3: 866. };
                          }
                          {
                            const x = $p49227._0;
                            {
                              const y = $p49227._1;
                              {
                                const w = $p49227._2;
                                {
                                  const h = $p49227._3;
                                  {
                                    let $eff;
                                    {
                                      const $t49221 = s.canvas;
                                      $eff = glue_fit$clo._0(glue_fit$clo, $t49221, x, y, w, h);
                                    }
                                  }
                                  {
                                    let $eff;
                                    {
                                      const $t49222 = s.ctx;
                                      {
                                        const $t49223 = glue_touch();
                                        {
                                          let $t49224;
                                          $t49224 = Spin$View$frame(m, $t49223);
                                          {
                                            const $rc_2765 = glue_paint$clo._0(glue_paint$clo, $t49222, $t49224);
                                            $eff = $rc_2765;
                                          }
                                        }
                                      }
                                    }
                                  }
                                  {
                                    let $eff;
                                    $eff = mark(m, flips);
                                  }
                                  {
                                    const $t49226 = { $: "$Clo_$lam1_frame$1_frame", _0: $lam1_frame$apply$1_frame };
                                    return glue_request_frame$clo._0(glue_request_frame$clo, $t49226);
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const frame$clo = { _0: ($_, t) => frame(t) };

function launch() {
  {
    let canvas;
    {
      let $t49231;
      {
        const id_i13419 = "table";
        {
          const $rc_2410_i13420 = dom_get_element_by_id$clo._0(dom_get_element_by_id$clo, "table");
          $t49231 = $rc_2410_i13420;
        }
      }
      switch ($t49231.$) {
        case "Some": {
          const $f49232 = $t49231._0;
          {
            const node = $f49232;
            canvas = node;
          }
          break;
        }
        case "None": {
          undefined;
          throw new Error("index.html has no <canvas id=table>");
          break;
        }
        default: {
          throw new Error("non-exhaustive pattern match");
          break;
        }
      }
    }
    {
      let ctx;
      {
        let $t49233;
        {
          const node_i13417 = canvas;
          {
            const $rc_2456_i13418 = canvas_get_context$clo._0(canvas_get_context$clo, canvas);
            $t49233 = $rc_2456_i13418;
          }
        }
        switch ($t49233.$) {
          case "Some": {
            const $f49234 = $t49233._0;
            {
              const c = $f49234;
              ctx = c;
            }
            break;
          }
          case "None": {
            undefined;
            throw new Error("this browser gives no 2D canvas context");
            break;
          }
          default: {
            throw new Error("non-exhaustive pattern match");
            break;
          }
        }
      }
      {
        const $p49242 = glue_seed_limbs();
        {
          const hi = $p49242._0;
          {
            const lo = $p49242._1;
            {
              let model;
              {
                let $t49237;
                {
                  let $t49235;
                  {
                    let $t45832_i6216;
                    {
                      let $t45825_i14809;
                      {
                        const $t45824_i14808 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                        $t45825_i14809 = (($t45824_i14808 - 1) < 4611686018427387904 && ($t45824_i14808 - 1) >= -4611686018427387904 ? ($t45824_i14808 - 1) : march_int_ovf(($t45824_i14808 - 1), 1));
                      }
                      $t45832_i6216 = ((hi | 0) === hi && ($t45825_i14809 | 0) === $t45825_i14809 ? (hi & $t45825_i14809) : march_int_and(hi, $t45825_i14809));
                    }
                    {
                      let $t45833_i6217;
                      {
                        let $t45825_i14806;
                        {
                          const $t45824_i14805 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                          $t45825_i14806 = (($t45824_i14805 - 1) < 4611686018427387904 && ($t45824_i14805 - 1) >= -4611686018427387904 ? ($t45824_i14805 - 1) : march_int_ovf(($t45824_i14805 - 1), 1));
                        }
                        $t45833_i6217 = ((lo | 0) === lo && ($t45825_i14806 | 0) === $t45825_i14806 ? (lo & $t45825_i14806) : march_int_and(lo, $t45825_i14806));
                      }
                      $t49235 = ({ hi: $t45832_i6216, lo: $t45833_i6217 });
                    }
                  }
                  {
                    const $t49236 = glue_load_best();
                    $t49237 = Spin$Game$boot($t49235, $t49236);
                  }
                }
                {
                  const $t49238 = glue_start_stage();
                  {
                    const m_i13410 = $t49237;
                    {
                      let $t46188_i13415;
                      {
                        const $t2474_i5327_i13414 = (0 > $t49238);
                        if ($t2474_i5327_i13414 === true) {
                          $t46188_i13415 = 0;
                        } else {
                          $t46188_i13415 = $t49238;
                        }
                      }
                      {
                        const $rc_2508_i13416 = ({ ...$t49237, start_stage: $t46188_i13415 });
                        model = $rc_2508_i13416;
                      }
                    }
                  }
                }
              }
              {
                let $eff;
                {
                  let $t49239;
                  $t49239 = ({ model: model, ctx: ctx, canvas: canvas, last_t: 0., flips: 0 });
                  {
                    const $rc_2770 = glue_cell_put$clo._0(glue_cell_put$clo, $t49239);
                    $eff = $rc_2770;
                  }
                }
              }
              {
                let $eff;
                {
                  const $rc_2769 = glue_listen$clo._0(glue_listen$clo, canvas);
                  $eff = $rc_2769;
                }
              }
              {
                const $t49241 = { $: "$Clo_$lam0_launch$0_launch", _0: $lam0_launch$apply$0_launch };
                return glue_request_frame$clo._0(glue_request_frame$clo, $t49241);
              }
            }
          }
        }
      }
    }
  }
}
const launch$clo = { _0: ($_) => launch() };

function main(_f) {
  return launch();
}
const main$clo = { _0: ($_, _f) => main(_f) };

function panic(msg) {
  return (() => { throw new Error(msg); })();
}
const panic$clo = { _0: ($_, msg) => panic(msg) };

function List$fold_left$List_Float$Float$Fn_Float_Float_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const acc = $tco_a1;
    const f = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f1092 = xs._0;
        const $f1093 = xs._1;
        {
          const t = $f1093;
          {
            let h;
            h = $f1092;
            {
              let $t1091;
              $t1091 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t1091;
                $tco_a2 = f;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$fold_left$List_Float$Float$Fn_Float_Float_Float$clo = { _0: ($_, xs, acc, f) => List$fold_left$List_Float$Float$Fn_Float_Float_Float(xs, acc, f) };

function List$any$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return false;
        break;
      }
      case "Cons": {
        const $f1155 = xs._0;
        const $f1156 = xs._1;
        {
          const t = $f1156;
          {
            const h = $f1155;
            {
              let $t1154;
              $t1154 = pred._0(pred, h);
              if ($t1154 === true) {
                return true;
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$any$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$clo = { _0: ($_, xs, pred) => List$any$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool(xs, pred) };

function List$fold_left$List_T_Buff_Float$Float$Fn_Float_T_Buff_Float_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const acc = $tco_a1;
    const f = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f1092 = xs._0;
        const $f1093 = xs._1;
        {
          const t = $f1093;
          {
            const h = $f1092;
            {
              let $t1091;
              $t1091 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t1091;
                $tco_a2 = f;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$fold_left$List_T_Buff_Float$Float$Fn_Float_T_Buff_Float_Float$clo = { _0: ($_, xs, acc, f) => List$fold_left$List_T_Buff_Float$Float$Fn_Float_T_Buff_Float_Float(xs, acc, f) };

function List$filter$List_Float$Fn_Float_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "Nil" };
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc24 = { $: "Cons", _0: h, _1: null };
                  List$filter$dps$List_Float$Fn_Float_Bool$List_Float(t, pred, $trmc24);
                  return $trmc24;
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$filter$List_Float$Fn_Float_Bool$clo = { _0: ($_, xs, pred) => List$filter$List_Float$Fn_Float_Bool(xs, pred) };

function List$fold_left$List_T_Feature_Float$Float$Fn_Float_T_Feature_Float_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const acc = $tco_a1;
    const f = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f1092 = xs._0;
        const $f1093 = xs._1;
        {
          const t = $f1093;
          {
            const h = $f1092;
            {
              let $t1091;
              $t1091 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t1091;
                $tco_a2 = f;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$fold_left$List_T_Feature_Float$Float$Fn_Float_T_Feature_Float_Float$clo = { _0: ($_, xs, acc, f) => List$fold_left$List_T_Feature_Float$Float$Fn_Float_T_Feature_Float_Float(xs, acc, f) };

function List$filter$List_T_Feature_Float$Fn_T_Feature_Float_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "Nil" };
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc24 = { $: "Cons", _0: h, _1: null };
                  List$filter$dps$List_T_Feature_Float$Fn_T_Feature_Float_Bool$List_T_Feature_Float(t, pred, $trmc24);
                  return $trmc24;
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$filter$List_T_Feature_Float$Fn_T_Feature_Float_Bool$clo = { _0: ($_, xs, pred) => List$filter$List_T_Feature_Float$Fn_T_Feature_Float_Bool(xs, pred) };

function List$filter$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "Nil" };
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc24 = { $: "Cons", _0: h, _1: null };
                  List$filter$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_Bool$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String(t, pred, $trmc24);
                  return $trmc24;
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$filter$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_Bool$clo = { _0: ($_, xs, pred) => List$filter$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_Bool(xs, pred) };

function List$filter$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "Nil" };
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc24 = { $: "Cons", _0: h, _1: null };
                  List$filter$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t, pred, $trmc24);
                  return $trmc24;
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$filter$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$clo = { _0: ($_, xs, pred) => List$filter$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool(xs, pred) };

function List$filter$List_T_Buff_Float$Fn_T_Buff_Float_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "Nil" };
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc24 = { $: "Cons", _0: h, _1: null };
                  List$filter$dps$List_T_Buff_Float$Fn_T_Buff_Float_Bool$List_T_Buff_Float(t, pred, $trmc24);
                  return $trmc24;
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$filter$List_T_Buff_Float$Fn_T_Buff_Float_Bool$clo = { _0: ($_, xs, pred) => List$filter$List_T_Buff_Float$Fn_T_Buff_Float_Bool(xs, pred) };

function List$append$List_Cue$List_Cue(xs, ys) {
  switch (xs.$) {
    case "Nil": {
      return ys;
      break;
    }
    case "Cons": {
      const $f998 = xs._0;
      const $f999 = xs._1;
      {
        const t = $f999;
        {
          const h = $f998;
          {
            const $trmc11 = { $: "Cons", _0: h, _1: null };
            List$append$dps$List_Cue$List_Cue$List_Cue(t, ys, $trmc11);
            return $trmc11;
          }
        }
      }
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const List$append$List_Cue$List_Cue$clo = { _0: ($_, xs, ys) => List$append$List_Cue$List_Cue(xs, ys) };

function List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const acc = $tco_a1;
    const f = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f1092 = xs._0;
        const $f1093 = xs._1;
        {
          const t = $f1093;
          {
            const h = $f1092;
            {
              let $t1091;
              $t1091 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t1091;
                $tco_a2 = f;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$clo = { _0: ($_, xs, acc, f) => List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue(xs, acc, f) };

function List$all$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return true;
        break;
      }
      case "Cons": {
        const $f1162 = xs._0;
        const $f1163 = xs._1;
        {
          const t = $f1163;
          {
            const h = $f1162;
            {
              let $t1161;
              $t1161 = pred._0(pred, h);
              if ($t1161 === true) {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              } else {
                return false;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$all$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$clo = { _0: ($_, xs, pred) => List$all$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool(xs, pred) };

function List$filter$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "Nil" };
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc24 = { $: "Cons", _0: h, _1: null };
                  List$filter$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t, pred, $trmc24);
                  return $trmc24;
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$filter$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$clo = { _0: ($_, xs, pred) => List$filter$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool(xs, pred) };

function List$fold_left$List_Hit$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue_Hit_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const acc = $tco_a1;
    const f = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f1092 = xs._0;
        const $f1093 = xs._1;
        {
          const t = $f1093;
          {
            const h = $f1092;
            {
              let $t1091;
              $t1091 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t1091;
                $tco_a2 = f;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$fold_left$List_Hit$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue_Hit_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$clo = { _0: ($_, xs, acc, f) => List$fold_left$List_Hit$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue_Hit_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_buffs_List_T_Buff_Float_burn_clock_Float_carry_Float_clock_Float_credits_Int_flash_Float_flash_tint_String_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pops_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_sparks_List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_spinner_rate_Float_spinner_turn_Float_stage_Int_start_stage_Int_style_R_bounce_Float_drag_Float_gravity_Float_magnet_Float_name_String_sub_String_tint_String_wind_Float_table_R_ball_radius_Float_drain_y_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_win_glow_Float_wins_at_List_Float_List_Cue(xs, acc, f) };

function List$fold_left$List_Part$T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_Part_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const acc = $tco_a1;
    const f = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f1092 = xs._0;
        const $f1093 = xs._1;
        {
          const t = $f1093;
          {
            const h = $f1092;
            {
              let $t1091;
              $t1091 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t1091;
                $tco_a2 = f;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$fold_left$List_Part$T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_Part_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$clo = { _0: ($_, xs, acc, f) => List$fold_left$List_Part$T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_Part_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit(xs, acc, f) };

function List$nth_opt$List_Symbol$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const n = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "None" };
        break;
      }
      case "Cons": {
        const $f976 = xs._0;
        const $f977 = xs._1;
        {
          const t = $f977;
          {
            const h = $f976;
            {
              const $t974 = (n === 0);
              if ($t974 === true) {
                return { $: "Some", _0: h };
              } else {
                {
                  const $t975 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                  {
                    $tco_a0 = t;
                    $tco_a1 = $t975;
                    continue __tco;
                  }
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$nth_opt$List_Symbol$Int$clo = { _0: ($_, xs, n) => List$nth_opt$List_Symbol$Int(xs, n) };

function List$nth_opt$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const n = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "None" };
        break;
      }
      case "Cons": {
        const $f976 = xs._0;
        const $f977 = xs._1;
        {
          const t = $f977;
          {
            const h = $f976;
            {
              const $t974 = (n === 0);
              if ($t974 === true) {
                return { $: "Some", _0: h };
              } else {
                {
                  const $t975 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                  {
                    $tco_a0 = t;
                    $tco_a1 = $t975;
                    continue __tco;
                  }
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$nth_opt$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int$clo = { _0: ($_, xs, n) => List$nth_opt$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int(xs, n) };

function List$filter$List_Symbol$Fn_Symbol_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "Nil" };
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc24 = { $: "Cons", _0: h, _1: null };
                  List$filter$dps$List_Symbol$Fn_Symbol_Bool$List_Symbol(t, pred, $trmc24);
                  return $trmc24;
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$filter$List_Symbol$Fn_Symbol_Bool$clo = { _0: ($_, xs, pred) => List$filter$List_Symbol$Fn_Symbol_Bool(xs, pred) };

function List$find$List_Int$Fn_Int_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "None" };
        break;
      }
      case "Cons": {
        const $f1140 = xs._0;
        const $f1141 = xs._1;
        {
          const t = $f1141;
          {
            let h;
            h = $f1140;
            {
              let $t1139;
              $t1139 = pred._0(pred, h);
              if ($t1139 === true) {
                return { $: "Some", _0: h };
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$find$List_Int$Fn_Int_Bool$clo = { _0: ($_, xs, pred) => List$find$List_Int$Fn_Int_Bool(xs, pred) };

function List$any$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return false;
        break;
      }
      case "Cons": {
        const $f1155 = xs._0;
        const $f1156 = xs._1;
        {
          const t = $f1156;
          {
            const h = $f1155;
            {
              let $t1154;
              $t1154 = pred._0(pred, h);
              if ($t1154 === true) {
                return true;
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$any$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool$clo = { _0: ($_, xs, pred) => List$any$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool(xs, pred) };

function List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(xs, f) {
  switch (xs.$) {
    case "Nil": {
      return { $: "Nil" };
      break;
    }
    case "Cons": {
      const $f1006 = xs._0;
      const $f1007 = xs._1;
      {
        const t = $f1007;
        {
          const h = $f1006;
          {
            let $t1004;
            $t1004 = f._0(f, h);
            {
              const $trmc15 = { $: "Cons", _0: $t1004, _1: null };
              List$map$dps$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(t, f, $trmc15);
              return $trmc15;
            }
          }
        }
      }
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$clo = { _0: ($_, xs, f) => List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(xs, f) };

function List$all$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return true;
        break;
      }
      case "Cons": {
        const $f1162 = xs._0;
        const $f1163 = xs._1;
        {
          const t = $f1163;
          {
            const h = $f1162;
            {
              let $t1161;
              $t1161 = pred._0(pred, h);
              if ($t1161 === true) {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              } else {
                return false;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$all$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool$clo = { _0: ($_, xs, pred) => List$all$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool(xs, pred) };

function List$map$List_Int$Fn_Int_R_x_Float_y_Float(xs, f) {
  switch (xs.$) {
    case "Nil": {
      return { $: "Nil" };
      break;
    }
    case "Cons": {
      const $f1006 = xs._0;
      const $f1007 = xs._1;
      {
        const t = $f1007;
        {
          const h = $f1006;
          {
            let $t1004;
            $t1004 = f._0(f, h);
            {
              const $trmc15 = { $: "Cons", _0: $t1004, _1: null };
              List$map$dps$List_Int$Fn_Int_R_x_Float_y_Float$List_R_x_Float_y_Float(t, f, $trmc15);
              return $trmc15;
            }
          }
        }
      }
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const List$map$List_Int$Fn_Int_R_x_Float_y_Float$clo = { _0: ($_, xs, f) => List$map$List_Int$Fn_Int_R_x_Float_y_Float(xs, f) };

function List$map$List_Int$Fn_Int_List_Op(xs, f) {
  switch (xs.$) {
    case "Nil": {
      return { $: "Nil" };
      break;
    }
    case "Cons": {
      const $f1006 = xs._0;
      const $f1007 = xs._1;
      {
        const t = $f1007;
        {
          const h = $f1006;
          {
            let $t1004;
            $t1004 = f._0(f, h);
            {
              const $trmc15 = { $: "Cons", _0: $t1004, _1: null };
              List$map$dps$List_Int$Fn_Int_List_Op$List_List_Op(t, f, $trmc15);
              return $trmc15;
            }
          }
        }
      }
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const List$map$List_Int$Fn_Int_List_Op$clo = { _0: ($_, xs, f) => List$map$List_Int$Fn_Int_List_Op(xs, f) };

function List$append$List_Op$List_Op(xs, ys) {
  switch (xs.$) {
    case "Nil": {
      return ys;
      break;
    }
    case "Cons": {
      const $f998 = xs._0;
      const $f999 = xs._1;
      {
        const t = $f999;
        {
          const h = $f998;
          {
            const $trmc11 = { $: "Cons", _0: h, _1: null };
            List$append$dps$List_Op$List_Op$List_Op(t, ys, $trmc11);
            return $trmc11;
          }
        }
      }
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const List$append$List_Op$List_Op$clo = { _0: ($_, xs, ys) => List$append$List_Op$List_Op(xs, ys) };

function List$map$List_Int$Fn_Int_Op(xs, f) {
  switch (xs.$) {
    case "Nil": {
      return { $: "Nil" };
      break;
    }
    case "Cons": {
      const $f1006 = xs._0;
      const $f1007 = xs._1;
      {
        const t = $f1007;
        {
          const h = $f1006;
          {
            let $t1004;
            $t1004 = f._0(f, h);
            {
              const $trmc15 = { $: "Cons", _0: $t1004, _1: null };
              List$map$dps$List_Int$Fn_Int_Op$List_Op(t, f, $trmc15);
              return $trmc15;
            }
          }
        }
      }
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const List$map$List_Int$Fn_Int_Op$clo = { _0: ($_, xs, f) => List$map$List_Int$Fn_Int_Op(xs, f) };

function List$filter$List_Cue$Fn_Cue_Bool($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        return { $: "Nil" };
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc24 = { $: "Cons", _0: h, _1: null };
                  List$filter$dps$List_Cue$Fn_Cue_Bool$List_Cue(t, pred, $trmc24);
                  return $trmc24;
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$filter$List_Cue$Fn_Cue_Bool$clo = { _0: ($_, xs, pred) => List$filter$List_Cue$Fn_Cue_Bool(xs, pred) };

function List$length_onto$List_Float$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f983 = lst._0;
        const $f984 = lst._1;
        {
          const t = $f984;
          {
            const $t982 = ((acc + 1) < 4611686018427387904 && (acc + 1) >= -4611686018427387904 ? (acc + 1) : march_int_ovf((acc + 1), 0));
            {
              $tco_a0 = t;
              $tco_a1 = $t982;
              continue __tco;
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$length_onto$List_Float$Int$clo = { _0: ($_, lst, acc) => List$length_onto$List_Float$Int(lst, acc) };

function List$map$dps$List_Int$Fn_Int_Int$List_Int($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_Int$Fn_Int_Int$List_Int$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_Int$Fn_Int_Int$List_Int(xs, f, $dst) };

function List$filter$dps$List_Float$Fn_Float_Bool$List_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc22 = { $: "Nil" };
          return ($dst._1 = $trmc22, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc23 = { $: "Cons", _0: h, _1: null };
                  ($dst._1 = $trmc23, undefined);
                  {
                    $tco_a0 = t;
                    $tco_a1 = pred;
                    $tco_a2 = $trmc23;
                    continue __tco;
                  }
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  $tco_a2 = $dst;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc21 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc21, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$filter$dps$List_Float$Fn_Float_Bool$List_Float$clo = { _0: ($_, xs, pred, $dst) => List$filter$dps$List_Float$Fn_Float_Bool$List_Float(xs, pred, $dst) };

function List$filter$dps$List_T_Feature_Float$Fn_T_Feature_Float_Bool$List_T_Feature_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc22 = { $: "Nil" };
          return ($dst._1 = $trmc22, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc23 = { $: "Cons", _0: h, _1: null };
                  ($dst._1 = $trmc23, undefined);
                  {
                    $tco_a0 = t;
                    $tco_a1 = pred;
                    $tco_a2 = $trmc23;
                    continue __tco;
                  }
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  $tco_a2 = $dst;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc21 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc21, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$filter$dps$List_T_Feature_Float$Fn_T_Feature_Float_Bool$List_T_Feature_Float$clo = { _0: ($_, xs, pred, $dst) => List$filter$dps$List_T_Feature_Float$Fn_T_Feature_Float_Bool$List_T_Feature_Float(xs, pred, $dst) };

function List$filter$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_Bool$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc22 = { $: "Nil" };
          return ($dst._1 = $trmc22, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc23 = { $: "Cons", _0: h, _1: null };
                  ($dst._1 = $trmc23, undefined);
                  {
                    $tco_a0 = t;
                    $tco_a1 = pred;
                    $tco_a2 = $trmc23;
                    continue __tco;
                  }
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  $tco_a2 = $dst;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc21 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc21, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$filter$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_Bool$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$clo = { _0: ($_, xs, pred, $dst) => List$filter$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_Bool$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String(xs, pred, $dst) };

function List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String(xs, f, $dst) };

function List$filter$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc22 = { $: "Nil" };
          return ($dst._1 = $trmc22, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc23 = { $: "Cons", _0: h, _1: null };
                  ($dst._1 = $trmc23, undefined);
                  {
                    $tco_a0 = t;
                    $tco_a1 = pred;
                    $tco_a2 = $trmc23;
                    continue __tco;
                  }
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  $tco_a2 = $dst;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc21 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc21, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$filter$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$clo = { _0: ($_, xs, pred, $dst) => List$filter$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(xs, pred, $dst) };

function List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(xs, f, $dst) };

function List$filter$dps$List_T_Buff_Float$Fn_T_Buff_Float_Bool$List_T_Buff_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc22 = { $: "Nil" };
          return ($dst._1 = $trmc22, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc23 = { $: "Cons", _0: h, _1: null };
                  ($dst._1 = $trmc23, undefined);
                  {
                    $tco_a0 = t;
                    $tco_a1 = pred;
                    $tco_a2 = $trmc23;
                    continue __tco;
                  }
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  $tco_a2 = $dst;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc21 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc21, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$filter$dps$List_T_Buff_Float$Fn_T_Buff_Float_Bool$List_T_Buff_Float$clo = { _0: ($_, xs, pred, $dst) => List$filter$dps$List_T_Buff_Float$Fn_T_Buff_Float_Bool$List_T_Buff_Float(xs, pred, $dst) };

function List$map$dps$List_T_Buff_Float$Fn_T_Buff_Float_T_Buff_Float$List_T_Buff_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_T_Buff_Float$Fn_T_Buff_Float_T_Buff_Float$List_T_Buff_Float$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_T_Buff_Float$Fn_T_Buff_Float_T_Buff_Float$List_T_Buff_Float(xs, f, $dst) };

function List$map$dps$List_T_Feature_Float$Fn_T_Feature_Float_T_Feature_Float$List_T_Feature_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_T_Feature_Float$Fn_T_Feature_Float_T_Feature_Float$List_T_Feature_Float$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_T_Feature_Float$Fn_T_Feature_Float_T_Feature_Float$List_T_Feature_Float(xs, f, $dst) };

function List$take_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const k = $tco_a1;
    const acc = $tco_a2;
    {
      const $t1238 = (k <= 0);
      if ($t1238 === true) {
        {
          const $t989_i8036 = { $: "Nil" };
          return List$reverse_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(acc, $t989_i8036);
        }
      } else {
        switch (lst.$) {
          case "Nil": {
            {
              const $t989_i8034 = { $: "Nil" };
              return List$reverse_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(acc, $t989_i8034);
            }
            break;
          }
          case "Cons": {
            const $f1241 = lst._0;
            const $f1242 = lst._1;
            {
              const t = $f1242;
              {
                const h = $f1241;
                {
                  const $t1239 = ((k - 1) < 4611686018427387904 && (k - 1) >= -4611686018427387904 ? (k - 1) : march_int_ovf((k - 1), 1));
                  {
                    const $t1240 = { $: "Cons", _0: h, _1: acc };
                    {
                      $tco_a0 = t;
                      $tco_a1 = $t1239;
                      $tco_a2 = $t1240;
                      continue __tco;
                    }
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const List$take_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$clo = { _0: ($_, lst, k, acc) => List$take_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(lst, k, acc) };

function List$append$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const ys = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return ($dst._1 = ys, undefined);
        break;
      }
      case "Cons": {
        const $f998 = xs._0;
        const $f999 = xs._1;
        {
          const t = $f999;
          {
            const h = $f998;
            {
              const $trmc10 = { $: "Cons", _0: h, _1: null };
              ($dst._1 = $trmc10, undefined);
              {
                $tco_a0 = t;
                $tco_a1 = ys;
                $tco_a2 = $trmc10;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc8 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc8, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$append$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$clo = { _0: ($_, xs, ys, $dst) => List$append$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(xs, ys, $dst) };

function List$map$dps$List_Int$Fn_Int_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_Int$Fn_Int_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_Int$Fn_Int_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(xs, f, $dst) };

function List$take_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Int$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const k = $tco_a1;
    const acc = $tco_a2;
    {
      const $t1238 = (k <= 0);
      if ($t1238 === true) {
        {
          const $t989_i8040 = { $: "Nil" };
          return List$reverse_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String(acc, $t989_i8040);
        }
      } else {
        switch (lst.$) {
          case "Nil": {
            {
              const $t989_i8038 = { $: "Nil" };
              return List$reverse_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String(acc, $t989_i8038);
            }
            break;
          }
          case "Cons": {
            const $f1241 = lst._0;
            const $f1242 = lst._1;
            {
              const t = $f1242;
              {
                const h = $f1241;
                {
                  const $t1239 = ((k - 1) < 4611686018427387904 && (k - 1) >= -4611686018427387904 ? (k - 1) : march_int_ovf((k - 1), 1));
                  {
                    const $t1240 = { $: "Cons", _0: h, _1: acc };
                    {
                      $tco_a0 = t;
                      $tco_a1 = $t1239;
                      $tco_a2 = $t1240;
                      continue __tco;
                    }
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const List$take_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Int$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$clo = { _0: ($_, lst, k, acc) => List$take_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Int$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String(lst, k, acc) };

function List$append$dps$List_Cue$List_Cue$List_Cue($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const ys = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return ($dst._1 = ys, undefined);
        break;
      }
      case "Cons": {
        const $f998 = xs._0;
        const $f999 = xs._1;
        {
          const t = $f999;
          {
            const h = $f998;
            {
              const $trmc10 = { $: "Cons", _0: h, _1: null };
              ($dst._1 = $trmc10, undefined);
              {
                $tco_a0 = t;
                $tco_a1 = ys;
                $tco_a2 = $trmc10;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc8 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc8, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$append$dps$List_Cue$List_Cue$List_Cue$clo = { _0: ($_, xs, ys, $dst) => List$append$dps$List_Cue$List_Cue$List_Cue(xs, ys, $dst) };

function List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f983 = lst._0;
        const $f984 = lst._1;
        {
          const t = $f984;
          {
            const $t982 = ((acc + 1) < 4611686018427387904 && (acc + 1) >= -4611686018427387904 ? (acc + 1) : march_int_ovf((acc + 1), 0));
            {
              $tco_a0 = t;
              $tco_a1 = $t982;
              continue __tco;
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int$clo = { _0: ($_, lst, acc) => List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int(lst, acc) };

function List$nth$List_Buff$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const n = $tco_a1;
    switch (xs.$) {
      case "Nil": {
        undefined;
        return (() => { throw new Error("List.nth: index out of bounds"); })();
        break;
      }
      case "Cons": {
        const $f968 = xs._0;
        const $f969 = xs._1;
        {
          const t = $f969;
          {
            const h = $f968;
            {
              const $t966 = (n === 0);
              if ($t966 === true) {
                return h;
              } else {
                {
                  const $t967 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                  {
                    $tco_a0 = t;
                    $tco_a1 = $t967;
                    continue __tco;
                  }
                }
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$nth$List_Buff$Int$clo = { _0: ($_, xs, n) => List$nth$List_Buff$Int(xs, n) };

function List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(xs, f, $dst) };

function List$append$dps$List_Hit$List_Hit$List_Hit($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const ys = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return ($dst._1 = ys, undefined);
        break;
      }
      case "Cons": {
        const $f998 = xs._0;
        const $f999 = xs._1;
        {
          const t = $f999;
          {
            const h = $f998;
            {
              const $trmc10 = { $: "Cons", _0: h, _1: null };
              ($dst._1 = $trmc10, undefined);
              {
                $tco_a0 = t;
                $tco_a1 = ys;
                $tco_a2 = $trmc10;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc8 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc8, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$append$dps$List_Hit$List_Hit$List_Hit$clo = { _0: ($_, xs, ys, $dst) => List$append$dps$List_Hit$List_Hit$List_Hit(xs, ys, $dst) };

function List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_List_Hit$List_List_Hit($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_List_Hit$List_List_Hit$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_List_Hit$List_List_Hit(xs, f, $dst) };

function List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(xs, f, $dst) };

function List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit(xs, f, $dst) };

function List$filter$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc22 = { $: "Nil" };
          return ($dst._1 = $trmc22, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc23 = { $: "Cons", _0: h, _1: null };
                  ($dst._1 = $trmc23, undefined);
                  {
                    $tco_a0 = t;
                    $tco_a1 = pred;
                    $tco_a2 = $trmc23;
                    continue __tco;
                  }
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  $tco_a2 = $dst;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc21 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc21, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$filter$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$clo = { _0: ($_, xs, pred, $dst) => List$filter$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(xs, pred, $dst) };

function List$drop$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const n = $tco_a1;
    {
      const $t1247 = (n <= 0);
      if ($t1247 === true) {
        return xs;
      } else {
        switch (xs.$) {
          case "Nil": {
            return { $: "Nil" };
            break;
          }
          case "Cons": {
            const $f1249 = xs._0;
            const $f1250 = xs._1;
            {
              const t = $f1250;
              {
                const $t1248 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                {
                  $tco_a0 = t;
                  $tco_a1 = $t1248;
                  continue __tco;
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const List$drop$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int$clo = { _0: ($_, xs, n) => List$drop$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int(xs, n) };

function List$length_onto$List_Symbol$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f983 = lst._0;
        const $f984 = lst._1;
        {
          const t = $f984;
          {
            const $t982 = ((acc + 1) < 4611686018427387904 && (acc + 1) >= -4611686018427387904 ? (acc + 1) : march_int_ovf((acc + 1), 0));
            {
              $tco_a0 = t;
              $tco_a1 = $t982;
              continue __tco;
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$length_onto$List_Symbol$Int$clo = { _0: ($_, lst, acc) => List$length_onto$List_Symbol$Int(lst, acc) };

function List$filter$dps$List_Symbol$Fn_Symbol_Bool$List_Symbol($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc22 = { $: "Nil" };
          return ($dst._1 = $trmc22, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc23 = { $: "Cons", _0: h, _1: null };
                  ($dst._1 = $trmc23, undefined);
                  {
                    $tco_a0 = t;
                    $tco_a1 = pred;
                    $tco_a2 = $trmc23;
                    continue __tco;
                  }
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  $tco_a2 = $dst;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc21 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc21, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$filter$dps$List_Symbol$Fn_Symbol_Bool$List_Symbol$clo = { _0: ($_, xs, pred, $dst) => List$filter$dps$List_Symbol$Fn_Symbol_Bool$List_Symbol(xs, pred, $dst) };

function List$drop$List_Symbol$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const n = $tco_a1;
    {
      const $t1247 = (n <= 0);
      if ($t1247 === true) {
        return xs;
      } else {
        switch (xs.$) {
          case "Nil": {
            return { $: "Nil" };
            break;
          }
          case "Cons": {
            const $f1249 = xs._0;
            const $f1250 = xs._1;
            {
              const t = $f1250;
              {
                const $t1248 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                {
                  $tco_a0 = t;
                  $tco_a1 = $t1248;
                  continue __tco;
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const List$drop$List_Symbol$Int$clo = { _0: ($_, xs, n) => List$drop$List_Symbol$Int(xs, n) };

function List$map$dps$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(xs, f, $dst) };

function List$append$dps$List_ReelEvent$List_ReelEvent$List_ReelEvent($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const ys = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return ($dst._1 = ys, undefined);
        break;
      }
      case "Cons": {
        const $f998 = xs._0;
        const $f999 = xs._1;
        {
          const t = $f999;
          {
            const h = $f998;
            {
              const $trmc10 = { $: "Cons", _0: h, _1: null };
              ($dst._1 = $trmc10, undefined);
              {
                $tco_a0 = t;
                $tco_a1 = ys;
                $tco_a2 = $trmc10;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc8 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc8, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$append$dps$List_ReelEvent$List_ReelEvent$List_ReelEvent$clo = { _0: ($_, xs, ys, $dst) => List$append$dps$List_ReelEvent$List_ReelEvent$List_ReelEvent(xs, ys, $dst) };

function List$map$dps$List_Int$Fn_Int_Part$List_Part($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_Int$Fn_Int_Part$List_Part$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_Int$Fn_Int_Part$List_Part(xs, f, $dst) };

function List$append$dps$List_Part$List_Part$List_Part($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const ys = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return ($dst._1 = ys, undefined);
        break;
      }
      case "Cons": {
        const $f998 = xs._0;
        const $f999 = xs._1;
        {
          const t = $f999;
          {
            const h = $f998;
            {
              const $trmc10 = { $: "Cons", _0: h, _1: null };
              ($dst._1 = $trmc10, undefined);
              {
                $tco_a0 = t;
                $tco_a1 = ys;
                $tco_a2 = $trmc10;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc8 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc8, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$append$dps$List_Part$List_Part$List_Part$clo = { _0: ($_, xs, ys, $dst) => List$append$dps$List_Part$List_Part$List_Part(xs, ys, $dst) };

function List$map$dps$List_Int$Fn_Int_R_x_Float_y_Float$List_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_Int$Fn_Int_R_x_Float_y_Float$List_R_x_Float_y_Float$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_Int$Fn_Int_R_x_Float_y_Float$List_R_x_Float_y_Float(xs, f, $dst) };

function List$map$dps$List_Int$Fn_Int_List_Op$List_List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_Int$Fn_Int_List_Op$List_List_Op$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_Int$Fn_Int_List_Op$List_List_Op(xs, f, $dst) };

function List$append$dps$List_Op$List_Op$List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const ys = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return ($dst._1 = ys, undefined);
        break;
      }
      case "Cons": {
        const $f998 = xs._0;
        const $f999 = xs._1;
        {
          const t = $f999;
          {
            const h = $f998;
            {
              const $trmc10 = { $: "Cons", _0: h, _1: null };
              ($dst._1 = $trmc10, undefined);
              {
                $tco_a0 = t;
                $tco_a1 = ys;
                $tco_a2 = $trmc10;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc8 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc8, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$append$dps$List_Op$List_Op$List_Op$clo = { _0: ($_, xs, ys, $dst) => List$append$dps$List_Op$List_Op$List_Op(xs, ys, $dst) };

function List$map$dps$List_Int$Fn_Int_Op$List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_Int$Fn_Int_Op$List_Op$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_Int$Fn_Int_Op$List_Op(xs, f, $dst) };

function List$map$dps$List_T_Int_R_x_Float_y_Float$Fn_T_Int_R_x_Float_y_Float_Op$List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_T_Int_R_x_Float_y_Float$Fn_T_Int_R_x_Float_y_Float_Op$List_Op$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_T_Int_R_x_Float_y_Float$Fn_T_Int_R_x_Float_y_Float_Op$List_Op(xs, f, $dst) };

function List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Op$List_List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Op$List_List_Op$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Op$List_List_Op(xs, f, $dst) };

function List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_List_Op$List_List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_List_Op$List_List_Op$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$Fn_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String_List_Op$List_List_Op(xs, f, $dst) };

function List$map$dps$List_T_Int_T_Buff_Float$Fn_T_Int_T_Buff_Float_Op$List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_T_Int_T_Buff_Float$Fn_T_Int_T_Buff_Float_Op$List_Op$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_T_Int_T_Buff_Float$Fn_T_Int_T_Buff_Float_Op$List_Op(xs, f, $dst) };

function List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Op$List_List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Op$List_List_Op$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Op$List_List_Op(xs, f, $dst) };

function List$map$dps$List_Part$Fn_Part_List_Op$List_List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const f = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc13 = { $: "Nil" };
          return ($dst._1 = $trmc13, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1006 = xs._0;
        const $f1007 = xs._1;
        {
          const t = $f1007;
          {
            const h = $f1006;
            {
              let $t1004;
              $t1004 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t1004, _1: null };
                ($dst._1 = $trmc14, undefined);
                {
                  $tco_a0 = t;
                  $tco_a1 = f;
                  $tco_a2 = $trmc14;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc12 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc12, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$map$dps$List_Part$Fn_Part_List_Op$List_List_Op$clo = { _0: ($_, xs, f, $dst) => List$map$dps$List_Part$Fn_Part_List_Op$List_List_Op(xs, f, $dst) };

function List$length_onto$List_Cue$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f983 = lst._0;
        const $f984 = lst._1;
        {
          const t = $f984;
          {
            const $t982 = ((acc + 1) < 4611686018427387904 && (acc + 1) >= -4611686018427387904 ? (acc + 1) : march_int_ovf((acc + 1), 0));
            {
              $tco_a0 = t;
              $tco_a1 = $t982;
              continue __tco;
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$length_onto$List_Cue$Int$clo = { _0: ($_, lst, acc) => List$length_onto$List_Cue$Int(lst, acc) };

function List$filter$dps$List_Cue$Fn_Cue_Bool$List_Cue($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const pred = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        {
          const $trmc22 = { $: "Nil" };
          return ($dst._1 = $trmc22, undefined);
        }
        break;
      }
      case "Cons": {
        const $f1036 = xs._0;
        const $f1037 = xs._1;
        {
          const t = $f1037;
          {
            const h = $f1036;
            {
              let $t1034;
              $t1034 = pred._0(pred, h);
              if ($t1034 === true) {
                {
                  const $trmc23 = { $: "Cons", _0: h, _1: null };
                  ($dst._1 = $trmc23, undefined);
                  {
                    $tco_a0 = t;
                    $tco_a1 = pred;
                    $tco_a2 = $trmc23;
                    continue __tco;
                  }
                }
              } else {
                {
                  $tco_a0 = t;
                  $tco_a1 = pred;
                  $tco_a2 = $dst;
                  continue __tco;
                }
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc21 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc21, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$filter$dps$List_Cue$Fn_Cue_Bool$List_Cue$clo = { _0: ($_, xs, pred, $dst) => List$filter$dps$List_Cue$Fn_Cue_Bool$List_Cue(xs, pred, $dst) };

function List$length_onto$List_Buff$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f983 = lst._0;
        const $f984 = lst._1;
        {
          const t = $f984;
          {
            const $t982 = ((acc + 1) < 4611686018427387904 && (acc + 1) >= -4611686018427387904 ? (acc + 1) : march_int_ovf((acc + 1), 0));
            {
              $tco_a0 = t;
              $tco_a1 = $t982;
              continue __tco;
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$length_onto$List_Buff$Int$clo = { _0: ($_, lst, acc) => List$length_onto$List_Buff$Int(lst, acc) };

function List$reverse_onto$List_Hit$List_Hit($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_Hit$List_Hit$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_Hit$List_Hit(lst, acc) };

function List$reverse_onto$List_Cue$List_Cue($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_Cue$List_Cue$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_Cue$List_Cue(lst, acc) };

function List$append$dps$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const ys = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return ($dst._1 = ys, undefined);
        break;
      }
      case "Cons": {
        const $f998 = xs._0;
        const $f999 = xs._1;
        {
          const t = $f999;
          {
            const h = $f998;
            {
              const $trmc10 = { $: "Cons", _0: h, _1: null };
              ($dst._1 = $trmc10, undefined);
              {
                $tco_a0 = t;
                $tco_a1 = ys;
                $tco_a2 = $trmc10;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc8 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc8, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$append$dps$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$clo = { _0: ($_, xs, ys, $dst) => List$append$dps$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(xs, ys, $dst) };

function List$take_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const k = $tco_a1;
    const acc = $tco_a2;
    {
      const $t1238 = (k <= 0);
      if ($t1238 === true) {
        {
          const $t989_i8106 = { $: "Nil" };
          return List$reverse_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(acc, $t989_i8106);
        }
      } else {
        switch (lst.$) {
          case "Nil": {
            {
              const $t989_i8104 = { $: "Nil" };
              return List$reverse_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(acc, $t989_i8104);
            }
            break;
          }
          case "Cons": {
            const $f1241 = lst._0;
            const $f1242 = lst._1;
            {
              const t = $f1242;
              {
                const h = $f1241;
                {
                  const $t1239 = ((k - 1) < 4611686018427387904 && (k - 1) >= -4611686018427387904 ? (k - 1) : march_int_ovf((k - 1), 1));
                  {
                    const $t1240 = { $: "Cons", _0: h, _1: acc };
                    {
                      $tco_a0 = t;
                      $tco_a1 = $t1239;
                      $tco_a2 = $t1240;
                      continue __tco;
                    }
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const List$take_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$clo = { _0: ($_, lst, k, acc) => List$take_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(lst, k, acc) };

function List$append$dps$List_Symbol$List_Symbol$List_Symbol($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const ys = $tco_a1;
    const $dst = $tco_a2;
    switch (xs.$) {
      case "Nil": {
        return ($dst._1 = ys, undefined);
        break;
      }
      case "Cons": {
        const $f998 = xs._0;
        const $f999 = xs._1;
        {
          const t = $f999;
          {
            const h = $f998;
            {
              const $trmc10 = { $: "Cons", _0: h, _1: null };
              ($dst._1 = $trmc10, undefined);
              {
                $tco_a0 = t;
                $tco_a1 = ys;
                $tco_a2 = $trmc10;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        {
          const $trmc8 = (() => { throw new Error("non-exhaustive pattern match"); })();
          return ($dst._1 = $trmc8, undefined);
        }
      }
    }
    return undefined;
  }
}
const List$append$dps$List_Symbol$List_Symbol$List_Symbol$clo = { _0: ($_, xs, ys, $dst) => List$append$dps$List_Symbol$List_Symbol$List_Symbol(xs, ys, $dst) };

function List$take_onto$List_Symbol$Int$List_Symbol($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const k = $tco_a1;
    const acc = $tco_a2;
    {
      const $t1238 = (k <= 0);
      if ($t1238 === true) {
        {
          const $t989_i8110 = { $: "Nil" };
          return List$reverse_onto$List_Symbol$List_Symbol(acc, $t989_i8110);
        }
      } else {
        switch (lst.$) {
          case "Nil": {
            {
              const $t989_i8108 = { $: "Nil" };
              return List$reverse_onto$List_Symbol$List_Symbol(acc, $t989_i8108);
            }
            break;
          }
          case "Cons": {
            const $f1241 = lst._0;
            const $f1242 = lst._1;
            {
              const t = $f1242;
              {
                const h = $f1241;
                {
                  const $t1239 = ((k - 1) < 4611686018427387904 && (k - 1) >= -4611686018427387904 ? (k - 1) : march_int_ovf((k - 1), 1));
                  {
                    const $t1240 = { $: "Cons", _0: h, _1: acc };
                    {
                      $tco_a0 = t;
                      $tco_a1 = $t1239;
                      $tco_a2 = $t1240;
                      continue __tco;
                    }
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const List$take_onto$List_Symbol$Int$List_Symbol$clo = { _0: ($_, lst, k, acc) => List$take_onto$List_Symbol$Int$List_Symbol(lst, k, acc) };

function List$reverse_onto$List_ReelEvent$List_ReelEvent($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_ReelEvent$List_ReelEvent$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_ReelEvent$List_ReelEvent(lst, acc) };

function List$reverse_onto$List_Part$List_Part($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_Part$List_Part$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_Part$List_Part(lst, acc) };

function List$reverse_onto$List_Op$List_Op($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_Op$List_Op$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_Op$List_Op(lst, acc) };

function List$reverse_onto$List_T_Int_R_x_Float_y_Float$List_T_Int_R_x_Float_y_Float($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_T_Int_R_x_Float_y_Float$List_T_Int_R_x_Float_y_Float$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_T_Int_R_x_Float_y_Float$List_T_Int_R_x_Float_y_Float(lst, acc) };

function List$reverse_onto$List_R_x_Float_y_Float$List_R_x_Float_y_Float($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_R_x_Float_y_Float$List_R_x_Float_y_Float$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_R_x_Float_y_Float$List_R_x_Float_y_Float(lst, acc) };

function List$reverse_onto$List_T_Int_T_Buff_Float$List_T_Int_T_Buff_Float($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_T_Int_T_Buff_Float$List_T_Int_T_Buff_Float$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_T_Int_T_Buff_Float$List_T_Int_T_Buff_Float(lst, acc) };

function List$reverse_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(lst, acc) };

function List$reverse_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String$List_R_colour_String_life_Float_pos_R_x_Float_y_Float_text_String(lst, acc) };

function List$reverse_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(lst, acc) };

function List$reverse_onto$List_Symbol$List_Symbol($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f991 = lst._0;
        const $f992 = lst._1;
        {
          const t = $f992;
          {
            const h = $f991;
            {
              const $t990 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t990;
                continue __tco;
              }
            }
          }
        }
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
    return undefined;
  }
}
const List$reverse_onto$List_Symbol$List_Symbol$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_Symbol$List_Symbol(lst, acc) };

function go$apply$0_List_range($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const i = $tco_a1;
    const acc = $tco_a2;
    {
      let go;
      go = $clo;
      {
        const start = $clo._1;
        {
          const $t923 = (i < start);
          if ($t923 === true) {
            return acc;
          } else {
            {
              const $t924 = ((i - 1) < 4611686018427387904 && (i - 1) >= -4611686018427387904 ? (i - 1) : march_int_ovf((i - 1), 1));
              {
                const $t925 = { $: "Cons", _0: i, _1: acc };
                {
                  $tco_a0 = go;
                  $tco_a1 = $t924;
                  $tco_a2 = $t925;
                  continue __tco;
                }
              }
            }
          }
        }
      }
    }
    return undefined;
  }
}
const go$apply$0_List_range$clo = { _0: ($_, $clo, i, acc) => go$apply$0_List_range($clo, i, acc) };

function $lam0_Spin_Game_waiting$apply$0_Spin_Game_waiting($clo, b) {
  return Spin$Game$resting_in_lane(b);
}
const $lam0_Spin_Game_waiting$apply$0_Spin_Game_waiting$clo = { _0: ($_, $clo, b) => $lam0_Spin_Game_waiting$apply$0_Spin_Game_waiting($clo, b) };

function $lam0_Spin_Game_in_play$apply$0_Spin_Game_in_play($clo, b) {
  {
    const $t46223 = Spin$Game$resting_in_lane(b);
    return (!$t46223);
  }
}
const $lam0_Spin_Game_in_play$apply$0_Spin_Game_in_play$clo = { _0: ($_, $clo, b) => $lam0_Spin_Game_in_play$apply$0_Spin_Game_in_play($clo, b) };

function $lam0_Spin_Game_buff_left$apply$0_Spin_Game_buff_left($clo, acc, x) {
  {
    const b = $clo._1;
    {
      const $p46228 = x;
      {
        const g = x._0;
        {
          const t = x._1;
          {
            const $t46227 = march_deep_eq(g, b);
            if ($t46227 === true) {
              {
                const $t45798_i8964 = (t >= acc);
                if ($t45798_i8964 === true) {
                  return t;
                } else {
                  return acc;
                }
              }
            } else {
              return acc;
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_Game_buff_left$apply$0_Spin_Game_buff_left$clo = { _0: ($_, $clo, acc, x) => $lam0_Spin_Game_buff_left$apply$0_Spin_Game_buff_left($clo, acc, x) };

function $lam0_Spin_Game_streak$apply$0_Spin_Game_streak($clo, t) {
  {
    const m = $clo._1;
    {
      let $t46234;
      {
        const $t46233 = m.clock;
        $t46234 = ($t46233 - t);
      }
      return ($t46234 < 12.);
    }
  }
}
const $lam0_Spin_Game_streak$apply$0_Spin_Game_streak$clo = { _0: ($_, $clo, t) => $lam0_Spin_Game_streak$apply$0_Spin_Game_streak($clo, t) };

function $lam1_Spin_Game_streak$apply$1_Spin_Game_streak($clo, acc, t) {
  {
    const $t45798_i8967 = (t >= acc);
    if ($t45798_i8967 === true) {
      return t;
    } else {
      return acc;
    }
  }
}
const $lam1_Spin_Game_streak$apply$1_Spin_Game_streak$clo = { _0: ($_, $clo, acc, t) => $lam1_Spin_Game_streak$apply$1_Spin_Game_streak($clo, acc, t) };

function $lam0_Spin_Game_light$apply$0_Spin_Game_light($clo, acc, l) {
  {
    const f = $clo._1;
    {
      const $p46249 = l;
      {
        const g = l._0;
        {
          const t = l._1;
          {
            const $t46248 = march_deep_eq(g, f);
            if ($t46248 === true) {
              {
                const $t45798_i8970 = (t >= acc);
                if ($t45798_i8970 === true) {
                  return t;
                } else {
                  return acc;
                }
              }
            } else {
              return acc;
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_Game_light$apply$0_Spin_Game_light$clo = { _0: ($_, $clo, acc, l) => $lam0_Spin_Game_light$apply$0_Spin_Game_light($clo, acc, l) };

function $lam0_Spin_Game_lit$apply$0_Spin_Game_lit($clo, l) {
  {
    const f = $clo._1;
    {
      const $p46254 = l;
      {
        const g = l._0;
        {
          const $rc_3493 = (!march_deep_eq(g, f));
          return $rc_3493;
        }
      }
    }
  }
}
const $lam0_Spin_Game_lit$apply$0_Spin_Game_lit$clo = { _0: ($_, $clo, l) => $lam0_Spin_Game_lit$apply$0_Spin_Game_lit($clo, l) };

function $lam0_Spin_Game_fade$apply$0_Spin_Game_fade($clo, l) {
  {
    const dt = $clo._1;
    {
      const $p46263 = l;
      {
        const g = l._0;
        {
          const t = l._1;
          {
            let $t46262;
            {
              const $t46261 = (dt * 2.5);
              $t46262 = (t - $t46261);
            }
            {
              const $rc_3495 = { _0: g, _1: $t46262 };
              return $rc_3495;
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_Game_fade$apply$0_Spin_Game_fade$clo = { _0: ($_, $clo, l) => $lam0_Spin_Game_fade$apply$0_Spin_Game_fade($clo, l) };

function $lam1_Spin_Game_fade$apply$1_Spin_Game_fade($clo, l) {
  {
    const $p46258_i14444 = l;
    {
      const t_i14445 = l._1;
      return (t_i14445 > 0.);
    }
  }
}
const $lam1_Spin_Game_fade$apply$1_Spin_Game_fade$clo = { _0: ($_, $clo, l) => $lam1_Spin_Game_fade$apply$1_Spin_Game_fade($clo, l) };

function $lam2_Spin_Game_fade$apply$2_Spin_Game_fade($clo, x) {
  {
    const dt = $clo._1;
    {
      const $p46272 = x;
      {
        const g = x._0;
        {
          const t = x._1;
          {
            const $t46271 = (t - dt);
            {
              const $rc_3497 = { _0: g, _1: $t46271 };
              return $rc_3497;
            }
          }
        }
      }
    }
  }
}
const $lam2_Spin_Game_fade$apply$2_Spin_Game_fade$clo = { _0: ($_, $clo, x) => $lam2_Spin_Game_fade$apply$2_Spin_Game_fade($clo, x) };

function $lam3_Spin_Game_fade$apply$3_Spin_Game_fade($clo, x) {
  {
    const $p46276 = x;
    {
      const t = x._1;
      return (t > 0.);
    }
  }
}
const $lam3_Spin_Game_fade$apply$3_Spin_Game_fade$clo = { _0: ($_, $clo, x) => $lam3_Spin_Game_fade$apply$3_Spin_Game_fade($clo, x) };

function $lam4_Spin_Game_fade$apply$4_Spin_Game_fade($clo, s) {
  {
    const dt = $clo._1;
    return Spin$Game$spark_step(s, dt);
  }
}
const $lam4_Spin_Game_fade$apply$4_Spin_Game_fade$clo = { _0: ($_, $clo, s) => $lam4_Spin_Game_fade$apply$4_Spin_Game_fade($clo, s) };

function $lam5_Spin_Game_fade$apply$5_Spin_Game_fade($clo, s) {
  {
    const $t46283 = s.life;
    return ($t46283 > 0.);
  }
}
const $lam5_Spin_Game_fade$apply$5_Spin_Game_fade$clo = { _0: ($_, $clo, s) => $lam5_Spin_Game_fade$apply$5_Spin_Game_fade($clo, s) };

function $lam6_Spin_Game_fade$apply$6_Spin_Game_fade($clo, p) {
  {
    const dt = $clo._1;
    {
      let $t46293;
      {
        let $t46288;
        {
          const $t46287 = p.pos;
          $t46288 = $t46287.x;
        }
        {
          let $t46292;
          {
            let $t46290;
            {
              const $t46289 = p.pos;
              $t46290 = $t46289.y;
            }
            {
              const $t46291 = (34. * dt);
              $t46292 = ($t46290 - $t46291);
            }
          }
          $t46293 = ({ x: $t46288, y: $t46292 });
        }
      }
      {
        let $t46295;
        {
          const $t46294 = p.life;
          $t46295 = ($t46294 - dt);
        }
        {
          const $rc_3498 = ({ ...p, pos: $t46293, life: $t46295 });
          return $rc_3498;
        }
      }
    }
  }
}
const $lam6_Spin_Game_fade$apply$6_Spin_Game_fade$clo = { _0: ($_, $clo, p) => $lam6_Spin_Game_fade$apply$6_Spin_Game_fade($clo, p) };

function $lam7_Spin_Game_fade$apply$7_Spin_Game_fade($clo, p) {
  {
    const $t46299 = p.life;
    return ($t46299 > 0.);
  }
}
const $lam7_Spin_Game_fade$apply$7_Spin_Game_fade$clo = { _0: ($_, $clo, p) => $lam7_Spin_Game_fade$apply$7_Spin_Game_fade($clo, p) };

function $lam0_Spin_Game_burst$apply$0_Spin_Game_burst($clo, i) {
  {
    const at = $clo._1;
    {
      const colour = $clo._2;
      {
        const count = $clo._3;
        {
          const m = $clo._4;
          {
            const speed = $clo._5;
            {
              let a;
              {
                let $t46333;
                {
                  const $t46332 = m.clock;
                  $t46333 = ($t46332 * 7.3);
                }
                {
                  let $t46337;
                  {
                    let $t46335;
                    {
                      const $t46334 = i;
                      $t46335 = ($t46334 * 6.2832);
                    }
                    {
                      const $t46336 = count;
                      $t46337 = ($t46335 / $t46336);
                    }
                  }
                  a = ($t46333 + $t46337);
                }
              }
              {
                let k;
                {
                  let $t46344;
                  {
                    let $t46343;
                    {
                      let $t46342;
                      {
                        let $t46341;
                        {
                          let $t46339;
                          {
                            const $t46338 = i;
                            $t46339 = ($t46338 * 2.7);
                          }
                          {
                            const $t46340 = m.clock;
                            $t46341 = ($t46339 + $t46340);
                          }
                        }
                        $t46342 = Math.sin($t46341);
                      }
                      $t46343 = (0.3 * $t46342);
                    }
                    $t46344 = (0.7 + $t46343);
                  }
                  k = (speed * $t46344);
                }
                {
                  let $t46349;
                  {
                    let $t46346;
                    {
                      const $t46345 = Math.cos(a);
                      $t46346 = ($t46345 * k);
                    }
                    {
                      let $t46348;
                      {
                        const $t46347 = Math.sin(a);
                        $t46348 = ($t46347 * k);
                      }
                      $t46349 = ({ x: $t46346, y: $t46348 });
                    }
                  }
                  {
                    let $t46356;
                    {
                      let $t46355;
                      {
                        let $t46354;
                        {
                          let $t46353;
                          {
                            const $t46350 = i;
                            {
                              let $t46352;
                              {
                                const $t46351 = m.clock;
                                $t46352 = ($t46351 * 3.);
                              }
                              $t46353 = ($t46350 + $t46352);
                            }
                          }
                          $t46354 = Math.sin($t46353);
                        }
                        $t46355 = (0.12 * $t46354);
                      }
                      $t46356 = (0.32 + $t46355);
                    }
                    return ({ pos: at, vel: $t46349, life: $t46356, colour: colour });
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_Game_burst$apply$0_Spin_Game_burst$clo = { _0: ($_, $clo, i) => $lam0_Spin_Game_burst$apply$0_Spin_Game_burst($clo, i) };

function $lam0_Spin_Game_give$apply$0_Spin_Game_give($clo, x) {
  {
    const b = $clo._1;
    {
      const $p46386 = x;
      {
        const g = x._0;
        {
          const $rc_3500 = (!march_deep_eq(g, b));
          return $rc_3500;
        }
      }
    }
  }
}
const $lam0_Spin_Game_give$apply$0_Spin_Game_give$clo = { _0: ($_, $clo, x) => $lam0_Spin_Game_give$apply$0_Spin_Game_give($clo, x) };

function $lam0_Spin_Game_streak_on$apply$0_Spin_Game_streak_on($clo, t) {
  {
    const m = $clo._1;
    {
      let $t46439;
      {
        const $t46438 = m.clock;
        $t46439 = ($t46438 - t);
      }
      return ($t46439 < 12.);
    }
  }
}
const $lam0_Spin_Game_streak_on$apply$0_Spin_Game_streak_on$clo = { _0: ($_, $clo, t) => $lam0_Spin_Game_streak_on$apply$0_Spin_Game_streak_on($clo, t) };

function $lam0_Spin_Game_fire$apply$0_Spin_Game_fire($clo, b) {
  {
    const speed = $clo._1;
    {
      let $t46607;
      $t46607 = Spin$Game$resting_in_lane(b);
      if ($t46607 === true) {
        {
          let $t46609;
          {
            const $t46608 = (-speed);
            $t46609 = ({ x: 0., y: $t46608 });
          }
          {
            const $rc_3501 = ({ ...b, vel: $t46609 });
            return $rc_3501;
          }
        }
      } else {
        return b;
      }
    }
  }
}
const $lam0_Spin_Game_fire$apply$0_Spin_Game_fire$clo = { _0: ($_, $clo, b) => $lam0_Spin_Game_fire$apply$0_Spin_Game_fire($clo, b) };

function $lam0_Spin_Game_auto_plunge$apply$0_Spin_Game_auto_plunge($clo, b) {
  {
    let $t46644;
    {
      const $t46643 = b.pos;
      $t46644 = Spin$Table$in_lane($t46643);
    }
    return (!$t46644);
  }
}
const $lam0_Spin_Game_auto_plunge$apply$0_Spin_Game_auto_plunge$clo = { _0: ($_, $clo, b) => $lam0_Spin_Game_auto_plunge$apply$0_Spin_Game_auto_plunge($clo, b) };

function $lam0_Spin_Game_step_balls$apply$0_Spin_Game_step_balls($clo, b) {
  {
    const h = $clo._1;
    {
      const l = $clo._2;
      {
        const m = $clo._3;
        {
          const r = $clo._4;
          {
            const $t46673 = m.table;
            {
              const $t46674 = m.style;
              {
                const $t46675 = m.clock;
                {
                  const $t46676 = m.num;
                  return Spin$Physics$step_ball($t46673, $t46674, $t46675, $t46676, l, r, h, b);
                }
              }
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_Game_step_balls$apply$0_Spin_Game_step_balls$clo = { _0: ($_, $clo, b) => $lam0_Spin_Game_step_balls$apply$0_Spin_Game_step_balls($clo, b) };

function $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls($clo, x) {
  {
    const $p46679 = x;
    {
      const b = x._0;
      return b;
    }
  }
}
const $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls$clo = { _0: ($_, $clo, x) => $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls($clo, x) };

function $lam2_Spin_Game_step_balls$apply$2_Spin_Game_step_balls($clo, x) {
  {
    const $p46682 = x;
    {
      const hs = x._1;
      return hs;
    }
  }
}
const $lam2_Spin_Game_step_balls$apply$2_Spin_Game_step_balls$clo = { _0: ($_, $clo, x) => $lam2_Spin_Game_step_balls$apply$2_Spin_Game_step_balls($clo, x) };

function $lam0_Spin_Game_drains$apply$0_Spin_Game_drains($clo, b) {
  {
    const m = $clo._1;
    {
      let $t46700;
      {
        const $t46699 = b.pos;
        $t46700 = $t46699.y;
      }
      {
        let $t46702;
        {
          const $t46701 = m.table;
          $t46702 = $t46701.drain_y;
        }
        return ($t46700 < $t46702);
      }
    }
  }
}
const $lam0_Spin_Game_drains$apply$0_Spin_Game_drains$clo = { _0: ($_, $clo, b) => $lam0_Spin_Game_drains$apply$0_Spin_Game_drains($clo, b) };

function $lam0_Spin_Game_play$apply$0_Spin_Game_play($clo, x) {
  {
    const dt = $clo._1;
    return Spin$Game$burn(x, dt);
  }
}
const $lam0_Spin_Game_play$apply$0_Spin_Game_play$clo = { _0: ($_, $clo, x) => $lam0_Spin_Game_play$apply$0_Spin_Game_play($clo, x) };

function $lam0_Spin_Physics_step_ball$apply$0_Spin_Physics_step_ball($clo, acc, part) {
  {
    const b = $clo._1;
    {
      const r = $clo._2;
      {
        const w = $clo._3;
        {
          const $t47239 = b.pos;
          return Spin$Physics$against(w, r, $t47239, acc, part);
        }
      }
    }
  }
}
const $lam0_Spin_Physics_step_ball$apply$0_Spin_Physics_step_ball$clo = { _0: ($_, $clo, acc, part) => $lam0_Spin_Physics_step_ball$apply$0_Spin_Physics_step_ball($clo, acc, part) };

function $lam0_Spin_Reels_count$apply$0_Spin_Reels_count($clo, x) {
  {
    const s = $clo._1;
    {
      const $rc_3506 = march_deep_eq(x, s);
      return $rc_3506;
    }
  }
}
const $lam0_Spin_Reels_count$apply$0_Spin_Reels_count$clo = { _0: ($_, $clo, x) => $lam0_Spin_Reels_count$apply$0_Spin_Reels_count($clo, x) };

function $jp2_Spin_Reels_pays$apply$0_Spin_Reels_pays($clo) {
  return { _0: 0, _1: "" };
}
const $jp2_Spin_Reels_pays$apply$0_Spin_Reels_pays$clo = { _0: ($_, $clo) => $jp2_Spin_Reels_pays$apply$0_Spin_Reels_pays($clo) };

function $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays($clo) {
  {
    const $jp_clo47360 = $clo._1;
    return $jp_clo47360._0($jp_clo47360);
  }
}
const $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays$clo = { _0: ($_, $clo) => $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays($clo) };

function $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop($clo, k) {
  {
    const r = $clo._1;
    {
      let $t47384;
      {
        const $t47383 = r.pos;
        $t47384 = (($t47383 + k) < 4611686018427387904 && ($t47383 + k) >= -4611686018427387904 ? ($t47383 + k) : march_int_ovf(($t47383 + k), 0));
      }
      return Spin$Reels$wrap($t47384);
    }
  }
}
const $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop$clo = { _0: ($_, $clo, k) => $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop($clo, k) };

function $lam1_Spin_Reels_target_stop$apply$1_Spin_Reels_target_stop($clo, i) {
  {
    const r = $clo._1;
    {
      let $t47387;
      $t47387 = Spin$Reels$stop(r, i);
      {
        const $t47388 = { $: "Blank" };
        {
          const $rc_3507 = march_deep_eq($t47387, $t47388);
          return $rc_3507;
        }
      }
    }
  }
}
const $lam1_Spin_Reels_target_stop$apply$1_Spin_Reels_target_stop$clo = { _0: ($_, $clo, i) => $lam1_Spin_Reels_target_stop$apply$1_Spin_Reels_target_stop($clo, i) };

function $lam0_Spin_Reels_roll_to$apply$0_Spin_Reels_roll_to($clo, k) {
  {
    const r = $clo._1;
    {
      const s = $clo._2;
      {
        let $t47395;
        {
          let $t47394;
          {
            const $t47393 = r.pos;
            $t47394 = (($t47393 + k) < 4611686018427387904 && ($t47393 + k) >= -4611686018427387904 ? ($t47393 + k) : march_int_ovf(($t47393 + k), 0));
          }
          $t47395 = Spin$Reels$stop(r, $t47394);
        }
        {
          const $rc_3508 = march_deep_eq($t47395, s);
          return $rc_3508;
        }
      }
    }
  }
}
const $lam0_Spin_Reels_roll_to$apply$0_Spin_Reels_roll_to$clo = { _0: ($_, $clo, k) => $lam0_Spin_Reels_roll_to$apply$0_Spin_Reels_roll_to($clo, k) };

function $lam1_Spin_Reels_roll_to$apply$1_Spin_Reels_roll_to($clo, k) {
  {
    const r = $clo._1;
    {
      const s = $clo._2;
      {
        let $t47402;
        {
          let $t47401;
          {
            let $t47400;
            {
              const $t47399 = r.pos;
              $t47400 = (($t47399 + k) < 4611686018427387904 && ($t47399 + k) >= -4611686018427387904 ? ($t47399 + k) : march_int_ovf(($t47399 + k), 0));
            }
            $t47401 = Spin$Reels$stop(r, $t47400);
          }
          {
            const $rc_3509 = Spin$Reels$rank($t47401);
            $t47402 = $rc_3509;
          }
        }
        {
          const $t47403 = Spin$Reels$rank(s);
          return ($t47402 >= $t47403);
        }
      }
    }
  }
}
const $lam1_Spin_Reels_roll_to$apply$1_Spin_Reels_roll_to$clo = { _0: ($_, $clo, k) => $lam1_Spin_Reels_roll_to$apply$1_Spin_Reels_roll_to($clo, k) };

function $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning($clo, r) {
  {
    const $t47499 = r.duration;
    return ($t47499 > 0.);
  }
}
const $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning$clo = { _0: ($_, $clo, r) => $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning($clo, r) };

function $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold($clo, x) {
  {
    const $rc_3510 = x.held;
    return $rc_3510;
  }
}
const $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold$clo = { _0: ($_, $clo, x) => $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold($clo, x) };

function $lam0_Spin_Table_arch$apply$0_Spin_Table_arch($clo, i) {
  {
    const n = $clo._1;
    {
      let $t47653;
      $t47653 = Spin$Table$arch_point(n, i);
      {
        let $t47655;
        {
          const $t47654 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
          $t47655 = Spin$Table$arch_point(n, $t47654);
        }
        return { $: "Wall", _0: $t47653, _1: $t47655, _2: 0.5 };
      }
    }
  }
}
const $lam0_Spin_Table_arch$apply$0_Spin_Table_arch$clo = { _0: ($_, $clo, i) => $lam0_Spin_Table_arch$apply$0_Spin_Table_arch($clo, i) };

function $lam0_Spin_View_ellipse$apply$0_Spin_View_ellipse($clo, i) {
  {
    const cx = $clo._1;
    {
      const cy = $clo._2;
      {
        const n = $clo._3;
        {
          const rx = $clo._4;
          {
            const ry = $clo._5;
            {
              let a;
              {
                let $t47879;
                {
                  const $t47877 = n.tau;
                  {
                    const $t47878 = i;
                    $t47879 = ($t47877 * $t47878);
                  }
                }
                a = ($t47879 / 12.);
              }
              {
                let $t47882;
                {
                  let $t47881;
                  {
                    const $t47880 = Math.cos(a);
                    $t47881 = (rx * $t47880);
                  }
                  $t47882 = (cx + $t47881);
                }
                {
                  let $t47885;
                  {
                    let $t47884;
                    {
                      const $t47883 = Math.sin(a);
                      $t47884 = (ry * $t47883);
                    }
                    $t47885 = (cy + $t47884);
                  }
                  return ({ x: $t47882, y: $t47885 });
                }
              }
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_View_ellipse$apply$0_Spin_View_ellipse$clo = { _0: ($_, $clo, i) => $lam0_Spin_View_ellipse$apply$0_Spin_View_ellipse($clo, i) };

function $lam0_Spin_View_reel_ops$apply$0_Spin_View_reel_ops($clo, k) {
  {
    const base = $clo._1;
    {
      const frac = $clo._2;
      {
        const line_y = $clo._3;
        {
          const m = $clo._4;
          {
            const r = $clo._5;
            {
              const x0 = $clo._6;
              {
                const j = ((base + k) < 4611686018427387904 && (base + k) >= -4611686018427387904 ? (base + k) : march_int_ovf((base + k), 0));
                {
                  let y;
                  {
                    let $t48036;
                    {
                      let $t48034;
                      {
                        const $t48033 = k;
                        $t48034 = (frac - $t48033);
                      }
                      $t48036 = ($t48034 * 32.);
                    }
                    y = (line_y + $t48036);
                  }
                  {
                    let s;
                    s = Spin$Reels$stop(r, j);
                    {
                      let fresh;
                      {
                        let $t48040;
                        {
                          const $t48038 = march_int_mod_euclid(j, 8);
                          {
                            const $t48039 = r.fresh;
                            $t48040 = ($t48038 === $t48039);
                          }
                        }
                        {
                          let $t48042;
                          {
                            const $t48041 = r.glow;
                            $t48042 = ($t48041 > 0.);
                          }
                          fresh = ($t48040 && $t48042);
                        }
                      }
                      {
                        let halo;
                        if (fresh === true) {
                          {
                            let $t48046;
                            {
                              const $t48043 = (x0 + 30.);
                              {
                                let $t48045;
                                {
                                  const $t48044 = r.glow;
                                  $t48045 = Spin$Draw$rgba(255, 230, 120, $t48044);
                                }
                                $t48046 = { $: "Glow", _0: $t48043, _1: y, _2: 26., _3: $t48045 };
                              }
                            }
                            {
                              const $t48047 = { $: "Nil" };
                              halo = { $: "Cons", _0: $t48046, _1: $t48047 };
                            }
                          }
                        } else {
                          halo = { $: "Nil" };
                        }
                        {
                          const $t48048 = m.num;
                          {
                            const $t48049 = (x0 + 30.);
                            {
                              let $t48050;
                              {
                                let $rc_3511;
                                $rc_3511 = Spin$View$symbol($t48048, s, $t48049, y, 1.);
                                $t48050 = $rc_3511;
                              }
                              return List$append$List_Op$List_Op(halo, $t48050);
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_View_reel_ops$apply$0_Spin_View_reel_ops$clo = { _0: ($_, $clo, k) => $lam0_Spin_View_reel_ops$apply$0_Spin_View_reel_ops($clo, k) };

function $lam0_Spin_View_machine_ops$apply$0_Spin_View_machine_ops($clo, i) {
  {
    const b = $clo._1;
    {
      const wh = $clo._2;
      {
        const ww = $clo._3;
        {
          const wx = $clo._4;
          {
            const wy = $clo._5;
            {
              let cx;
              {
                let $t48130;
                {
                  const $t48129 = (ww / 2.);
                  $t48130 = (wx + $t48129);
                }
                {
                  let $t48133;
                  {
                    let $t48132;
                    {
                      const $t48131 = i;
                      $t48132 = ($t48131 - 2.);
                    }
                    $t48133 = ($t48132 * 16.);
                  }
                  cx = ($t48130 + $t48133);
                }
              }
              {
                let $t48135;
                {
                  const $t48134 = b.banked;
                  $t48135 = (i < $t48134);
                }
                if ($t48135 === true) {
                  {
                    let $t48137;
                    {
                      const $t48136 = (wy + wh);
                      $t48137 = ($t48136 + 14.);
                    }
                    return { $: "Disc", _0: cx, _1: $t48137, _2: 5., _3: "#5cf2ff" };
                  }
                } else {
                  {
                    let $t48139;
                    {
                      const $t48138 = (wy + wh);
                      $t48139 = ($t48138 + 14.);
                    }
                    return { $: "Ring", _0: cx, _1: $t48139, _2: 5., _3: 1.5, _4: "#3d4d6a" };
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_View_machine_ops$apply$0_Spin_View_machine_ops$clo = { _0: ($_, $clo, i) => $lam0_Spin_View_machine_ops$apply$0_Spin_View_machine_ops($clo, i) };

function $lam1_Spin_View_machine_ops$apply$1_Spin_View_machine_ops($clo, i) {
  {
    const m = $clo._1;
    return Spin$View$reel_ops(m, i);
  }
}
const $lam1_Spin_View_machine_ops$apply$1_Spin_View_machine_ops$clo = { _0: ($_, $clo, i) => $lam1_Spin_View_machine_ops$apply$1_Spin_View_machine_ops($clo, i) };

function $lam0_Spin_View_ball_ops$apply$0_Spin_View_ball_ops($clo, i) {
  {
    const b = $clo._1;
    {
      const k = i;
      {
        let p;
        {
          const $t48551 = b.pos;
          {
            let $t48554;
            {
              const $t48552 = b.vel;
              {
                const $t48553 = (0.007 * k);
                $t48554 = Arcade$Vec2$scale($t48552, $t48553);
              }
            }
            p = Arcade$Vec2$sub($t48551, $t48554);
          }
        }
        {
          const $t48555 = p.x;
          {
            const $t48556 = p.y;
            {
              let $t48558;
              {
                const $t48557 = (1.8 * k);
                $t48558 = (9. - $t48557);
              }
              {
                let $t48561;
                {
                  let $t48560;
                  {
                    const $t48559 = (0.05 * k);
                    $t48560 = (0.22 - $t48559);
                  }
                  $t48561 = Spin$Draw$rgba(220, 230, 255, $t48560);
                }
                return { $: "Disc", _0: $t48555, _1: $t48556, _2: $t48558, _3: $t48561 };
              }
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_View_ball_ops$apply$0_Spin_View_ball_ops$clo = { _0: ($_, $clo, i) => $lam0_Spin_View_ball_ops$apply$0_Spin_View_ball_ops($clo, i) };

function $lam0_Spin_View_plunger_ops$apply$0_Spin_View_plunger_ops($clo, i) {
  {
    const m = $clo._1;
    {
      const top = $clo._2;
      {
        let y;
        {
          const $t48667 = (top + 6.);
          {
            let $t48673;
            {
              let $t48672;
              {
                const $t48668 = i;
                {
                  let $t48671;
                  {
                    let $t48670;
                    {
                      const $t48669 = m.pull;
                      $t48670 = (20. * $t48669);
                    }
                    $t48671 = (40. - $t48670);
                  }
                  $t48672 = ($t48668 * $t48671);
                }
              }
              $t48673 = ($t48672 / 6.);
            }
            y = ($t48667 + $t48673);
          }
        }
        {
          const $t48674 = ({ x: 356., y: y });
          {
            let $t48676;
            {
              const $t48675 = (y + 3.);
              $t48676 = ({ x: 374., y: $t48675 });
            }
            return Spin$Draw$stick($t48674, $t48676, 2., "#9aa3b5");
          }
        }
      }
    }
  }
}
const $lam0_Spin_View_plunger_ops$apply$0_Spin_View_plunger_ops$clo = { _0: ($_, $clo, i) => $lam0_Spin_View_plunger_ops$apply$0_Spin_View_plunger_ops($clo, i) };

function $lam0_Spin_View_chase_ops$apply$0_Spin_View_chase_ops($clo, i) {
  {
    const head = $clo._1;
    {
      const hot = $clo._2;
      {
        const m = $clo._3;
        {
          let a;
          {
            let $t48734;
            {
              const $t48733 = m.num;
              $t48734 = $t48733.pi;
            }
            {
              let $t48739;
              {
                let $t48738;
                {
                  let $t48736;
                  {
                    const $t48735 = m.num;
                    $t48736 = $t48735.pi;
                  }
                  {
                    const $t48737 = i;
                    $t48738 = ($t48736 * $t48737);
                  }
                }
                $t48739 = ($t48738 / 24.);
              }
              a = ($t48734 + $t48739);
            }
          }
          {
            let x;
            {
              let $t48741;
              {
                const $t48740 = Math.cos(a);
                $t48741 = (190. * $t48740);
              }
              x = (200. + $t48741);
            }
            {
              let y;
              {
                let $t48743;
                {
                  const $t48742 = Math.sin(a);
                  $t48743 = (190. * $t48742);
                }
                y = (200. + $t48743);
              }
              {
                let phase;
                {
                  const $t48744 = i;
                  phase = ($t48744 - head);
                }
                {
                  let bright;
                  {
                    let $t48747;
                    {
                      let $t48746;
                      {
                        const $t48745 = (phase * 1.3);
                        $t48746 = Math.cos($t48745);
                      }
                      $t48747 = (0.5 * $t48746);
                    }
                    bright = (0.5 + $t48747);
                  }
                  {
                    const lit = (bright * bright);
                    if (hot === true) {
                      {
                        let $t48750;
                        {
                          let $t48749;
                          {
                            const $t48748 = (0.75 * lit);
                            $t48749 = (0.25 + $t48748);
                          }
                          $t48750 = Spin$Draw$rgba(255, 211, 107, $t48749);
                        }
                        return { $: "Disc", _0: x, _1: y, _2: 2.6, _3: $t48750 };
                      }
                    } else {
                      {
                        let $t48753;
                        {
                          let $t48752;
                          {
                            const $t48751 = (0.5 * lit);
                            $t48752 = (0.12 + $t48751);
                          }
                          $t48753 = Spin$Draw$rgba(185, 166, 255, $t48752);
                        }
                        return { $: "Disc", _0: x, _1: y, _2: 2.2, _3: $t48753 };
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_View_chase_ops$apply$0_Spin_View_chase_ops$clo = { _0: ($_, $clo, i) => $lam0_Spin_View_chase_ops$apply$0_Spin_View_chase_ops($clo, i) };

function $lam0_Spin_View_marquee_ops$apply$0_Spin_View_marquee_ops($clo, i) {
  {
    const per_side = $clo._1;
    {
      const ww = $clo._2;
      {
        const wx = $clo._3;
        {
          const wy = $clo._4;
          {
            let $t48765;
            {
              const $t48759 = (wx - 8.);
              {
                let $t48764;
                {
                  let $t48762;
                  {
                    const $t48760 = (ww + 16.);
                    {
                      const $t48761 = i;
                      $t48762 = ($t48760 * $t48761);
                    }
                  }
                  {
                    const $t48763 = per_side;
                    $t48764 = ($t48762 / $t48763);
                  }
                }
                $t48765 = ($t48759 + $t48764);
              }
            }
            {
              const $t48766 = (wy - 8.);
              return ({ x: $t48765, y: $t48766 });
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_View_marquee_ops$apply$0_Spin_View_marquee_ops$clo = { _0: ($_, $clo, i) => $lam0_Spin_View_marquee_ops$apply$0_Spin_View_marquee_ops($clo, i) };

function $lam1_Spin_View_marquee_ops$apply$1_Spin_View_marquee_ops($clo, i) {
  {
    const wh = $clo._1;
    {
      const ww = $clo._2;
      {
        const wx = $clo._3;
        {
          const wy = $clo._4;
          {
            let $t48772;
            {
              const $t48771 = (wx + ww);
              $t48772 = ($t48771 + 8.);
            }
            {
              let $t48778;
              {
                const $t48773 = (wy - 8.);
                {
                  let $t48777;
                  {
                    let $t48776;
                    {
                      const $t48774 = (wh + 16.);
                      {
                        const $t48775 = i;
                        $t48776 = ($t48774 * $t48775);
                      }
                    }
                    $t48777 = ($t48776 / 4.);
                  }
                  $t48778 = ($t48773 + $t48777);
                }
              }
              return ({ x: $t48772, y: $t48778 });
            }
          }
        }
      }
    }
  }
}
const $lam1_Spin_View_marquee_ops$apply$1_Spin_View_marquee_ops$clo = { _0: ($_, $clo, i) => $lam1_Spin_View_marquee_ops$apply$1_Spin_View_marquee_ops($clo, i) };

function $lam2_Spin_View_marquee_ops$apply$2_Spin_View_marquee_ops($clo, i) {
  {
    const per_side = $clo._1;
    {
      const wh = $clo._2;
      {
        const ww = $clo._3;
        {
          const wx = $clo._4;
          {
            const wy = $clo._5;
            {
              let $t48790;
              {
                let $t48784;
                {
                  const $t48783 = (wx + ww);
                  $t48784 = ($t48783 + 8.);
                }
                {
                  let $t48789;
                  {
                    let $t48787;
                    {
                      const $t48785 = (ww + 16.);
                      {
                        const $t48786 = i;
                        $t48787 = ($t48785 * $t48786);
                      }
                    }
                    {
                      const $t48788 = per_side;
                      $t48789 = ($t48787 / $t48788);
                    }
                  }
                  $t48790 = ($t48784 - $t48789);
                }
              }
              {
                let $t48792;
                {
                  const $t48791 = (wy + wh);
                  $t48792 = ($t48791 + 8.);
                }
                return ({ x: $t48790, y: $t48792 });
              }
            }
          }
        }
      }
    }
  }
}
const $lam2_Spin_View_marquee_ops$apply$2_Spin_View_marquee_ops$clo = { _0: ($_, $clo, i) => $lam2_Spin_View_marquee_ops$apply$2_Spin_View_marquee_ops($clo, i) };

function $lam3_Spin_View_marquee_ops$apply$3_Spin_View_marquee_ops($clo, i) {
  {
    const wh = $clo._1;
    {
      const wx = $clo._2;
      {
        const wy = $clo._3;
        {
          const $t48797 = (wx - 8.);
          {
            let $t48804;
            {
              let $t48799;
              {
                const $t48798 = (wy + wh);
                $t48799 = ($t48798 + 8.);
              }
              {
                let $t48803;
                {
                  let $t48802;
                  {
                    const $t48800 = (wh + 16.);
                    {
                      const $t48801 = i;
                      $t48802 = ($t48800 * $t48801);
                    }
                  }
                  $t48803 = ($t48802 / 4.);
                }
                $t48804 = ($t48799 - $t48803);
              }
            }
            return ({ x: $t48797, y: $t48804 });
          }
        }
      }
    }
  }
}
const $lam3_Spin_View_marquee_ops$apply$3_Spin_View_marquee_ops$clo = { _0: ($_, $clo, i) => $lam3_Spin_View_marquee_ops$apply$3_Spin_View_marquee_ops($clo, i) };

function $lam4_Spin_View_marquee_ops$apply$4_Spin_View_marquee_ops($clo, x) {
  {
    const m = $clo._1;
    {
      const spinning = $clo._2;
      {
        const $p48837 = x;
        {
          const i = x._0;
          {
            const p = x._1;
            {
              const k = i;
              {
                let a;
                {
                  let $t48815;
                  {
                    const $t48814 = m.win_glow;
                    $t48815 = ($t48814 > 0.);
                  }
                  if ($t48815 === true) {
                    {
                      let $t48819;
                      {
                        let $t48818;
                        {
                          let $t48817;
                          {
                            const $t48816 = m.clock;
                            $t48817 = ($t48816 * 18.);
                          }
                          $t48818 = Math.sin($t48817);
                        }
                        $t48819 = ($t48818 > 0.);
                      }
                      if ($t48819 === true) {
                        a = 1.;
                      } else {
                        a = 0.25;
                      }
                    }
                  } else {
                    if (spinning === true) {
                      {
                        let $t48825;
                        {
                          let $t48824;
                          {
                            let $t48823;
                            {
                              const $t48820 = (k * 0.9);
                              {
                                let $t48822;
                                {
                                  const $t48821 = m.clock;
                                  $t48822 = ($t48821 * 16.);
                                }
                                $t48823 = ($t48820 - $t48822);
                              }
                            }
                            $t48824 = Math.cos($t48823);
                          }
                          $t48825 = (0.5 * $t48824);
                        }
                        a = (0.5 + $t48825);
                      }
                    } else {
                      {
                        let $t48831;
                        {
                          let $t48830;
                          {
                            let $t48829;
                            {
                              const $t48826 = (k * 0.6);
                              {
                                let $t48828;
                                {
                                  const $t48827 = m.clock;
                                  $t48828 = ($t48827 * 2.);
                                }
                                $t48829 = ($t48826 + $t48828);
                              }
                            }
                            $t48830 = Math.sin($t48829);
                          }
                          $t48831 = (0.25 * $t48830);
                        }
                        a = (0.35 + $t48831);
                      }
                    }
                  }
                }
                {
                  const $t48832 = p.x;
                  {
                    const $t48833 = p.y;
                    {
                      let $t48836;
                      {
                        let $t48835;
                        {
                          const $t48834 = m.win_glow;
                          $t48835 = ($t48834 > 0.);
                        }
                        if ($t48835 === true) {
                          $t48836 = Spin$Draw$rgba(255, 211, 107, a);
                        } else {
                          $t48836 = Spin$Draw$rgba(255, 255, 255, a);
                        }
                      }
                      return { $: "Disc", _0: $t48832, _1: $t48833, _2: 2.4, _3: $t48836 };
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const $lam4_Spin_View_marquee_ops$apply$4_Spin_View_marquee_ops$clo = { _0: ($_, $clo, x) => $lam4_Spin_View_marquee_ops$apply$4_Spin_View_marquee_ops($clo, x) };

function $lam0_Spin_View_spark_ops$apply$0_Spin_View_spark_ops($clo, s) {
  {
    let $t48867;
    {
      let $t48866;
      {
        let $t48865;
        {
          const $t48864 = s.life;
          $t48865 = ($t48864 * 3.);
        }
        {
          const $t45799_i9029 = ($t48865 < 1.);
          if ($t45799_i9029 === true) {
            $t48866 = $t48865;
          } else {
            $t48866 = 1.;
          }
        }
      }
      $t48867 = { $: "Fade", _0: $t48866 };
    }
    {
      let $t48873;
      {
        let $t48869;
        {
          const $t48868 = s.pos;
          $t48869 = $t48868.x;
        }
        {
          let $t48871;
          {
            const $t48870 = s.pos;
            $t48871 = $t48870.y;
          }
          {
            const $t48872 = s.colour;
            $t48873 = { $: "Disc", _0: $t48869, _1: $t48871, _2: 1.9, _3: $t48872 };
          }
        }
      }
      {
        const $t48874 = { $: "Nil" };
        {
          const $t48875 = { $: "Cons", _0: $t48873, _1: $t48874 };
          return { $: "Cons", _0: $t48867, _1: $t48875 };
        }
      }
    }
  }
}
const $lam0_Spin_View_spark_ops$apply$0_Spin_View_spark_ops$clo = { _0: ($_, $clo, s) => $lam0_Spin_View_spark_ops$apply$0_Spin_View_spark_ops($clo, s) };

function $lam0_Spin_View_pop_ops$apply$0_Spin_View_pop_ops($clo, p) {
  {
    let $t48883;
    {
      let $t48882;
      {
        let $t48881;
        {
          const $t48880 = p.life;
          $t48881 = ($t48880 * 2.);
        }
        {
          const $t45799_i9037 = ($t48881 < 1.);
          if ($t45799_i9037 === true) {
            $t48882 = $t48881;
          } else {
            $t48882 = 1.;
          }
        }
      }
      $t48883 = { $: "Fade", _0: $t48882 };
    }
    {
      let $t48890;
      {
        const $t48884 = p.text;
        {
          let $t48886;
          {
            const $t48885 = p.pos;
            $t48886 = $t48885.x;
          }
          {
            let $t48888;
            {
              const $t48887 = p.pos;
              $t48888 = $t48887.y;
            }
            {
              const $t48889 = p.colour;
              $t48890 = { $: "Label", _0: $t48884, _1: $t48886, _2: $t48888, _3: 18., _4: $t48889 };
            }
          }
        }
      }
      {
        const $t48891 = { $: "Nil" };
        {
          const $t48892 = { $: "Cons", _0: $t48890, _1: $t48891 };
          return { $: "Cons", _0: $t48883, _1: $t48892 };
        }
      }
    }
  }
}
const $lam0_Spin_View_pop_ops$apply$0_Spin_View_pop_ops$clo = { _0: ($_, $clo, p) => $lam0_Spin_View_pop_ops$apply$0_Spin_View_pop_ops($clo, p) };

function $lam0_Spin_View_buff_ops$apply$0_Spin_View_buff_ops($clo, x) {
  {
    const m = $clo._1;
    {
      const $p48960 = x;
      {
        const i = x._0;
        {
          const b = x._1;
          {
            const buff = b._0;
            {
              const t = b._1;
              {
                let y;
                {
                  let $t48947;
                  {
                    const $t48946 = i;
                    $t48947 = (10. * $t48946);
                  }
                  y = (24. + $t48947);
                }
                {
                  let blink;
                  {
                    const $t48948 = (t > 2.);
                    {
                      let $t48952;
                      {
                        let $t48951;
                        {
                          let $t48950;
                          {
                            const $t48949 = m.clock;
                            $t48950 = ($t48949 * 14.);
                          }
                          $t48951 = Math.sin($t48950);
                        }
                        $t48952 = ($t48951 > 0.);
                      }
                      blink = ($t48948 || $t48952);
                    }
                  }
                  if (blink === true) {
                    {
                      let $t48957;
                      {
                        const $t48953 = Spin$Game$buff_name(buff);
                        {
                          let $t48956;
                          {
                            let $t48955;
                            {
                              const $t48954 = Math.floor(t);
                              $t48955 = (($t48954 + 1) < 4611686018427387904 && ($t48954 + 1) >= -4611686018427387904 ? ($t48954 + 1) : march_int_ovf(($t48954 + 1), 0));
                            }
                            $t48956 = String($t48955);
                          }
                          {
                            const $rc_3512 = march_string_concat3($t48953, " ", $t48956);
                            $t48957 = $rc_3512;
                          }
                        }
                      }
                      return { $: "Label", _0: $t48957, _1: 340., _2: y, _3: 7.5, _4: "#ffd36b" };
                    }
                  } else {
                    return { $: "Label", _0: "", _1: 0., _2: 0., _3: 1., _4: "#000" };
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const $lam0_Spin_View_buff_ops$apply$0_Spin_View_buff_ops$clo = { _0: ($_, $clo, x) => $lam0_Spin_View_buff_ops$apply$0_Spin_View_buff_ops($clo, x) };

function $lam0_Spin_View_frame$apply$0_Spin_View_frame($clo, p) {
  {
    const m = $clo._1;
    return Spin$View$part_ops(m, p);
  }
}
const $lam0_Spin_View_frame$apply$0_Spin_View_frame$clo = { _0: ($_, $clo, p) => $lam0_Spin_View_frame$apply$0_Spin_View_frame($clo, p) };

function $lam1_Spin_View_frame$apply$1_Spin_View_frame($clo, b) {
  {
    const m = $clo._1;
    return Spin$View$ball_ops(m, b);
  }
}
const $lam1_Spin_View_frame$apply$1_Spin_View_frame$clo = { _0: ($_, $clo, b) => $lam1_Spin_View_frame$apply$1_Spin_View_frame($clo, b) };

function $lam0_frame$apply$0_frame($clo, c) {
  switch (c.$) {
    case "CueFlip": {
      return true;
      break;
    }
    default: {
      return false;
    }
  }
}
const $lam0_frame$apply$0_frame$clo = { _0: ($_, $clo, c) => $lam0_frame$apply$0_frame($clo, c) };

function $lam1_frame$apply$1_frame($clo, next) {
  return frame(next);
}
const $lam1_frame$apply$1_frame$clo = { _0: ($_, $clo, next) => $lam1_frame$apply$1_frame($clo, next) };

function $lam0_launch$apply$0_launch($clo, t) {
  return frame(t);
}
const $lam0_launch$apply$0_launch$clo = { _0: ($_, $clo, t) => $lam0_launch$apply$0_launch($clo, t) };

function prepend_reversed$apply$0_List_concat_List_List_Hit($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const sub = $tco_a1;
    const acc = $tco_a2;
    {
      const prepend_reversed = $clo;
      switch (sub.$) {
        case "Nil": {
          return acc;
          break;
        }
        case "Cons": {
          const $f1111 = sub._0;
          const $f1112 = sub._1;
          {
            const rest = $f1112;
            {
              const x = $f1111;
              {
                const $t1110 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1110;
                  continue __tco;
                }
              }
            }
          }
          break;
        }
        default: {
          return (() => { throw new Error("non-exhaustive pattern match"); })();
        }
      }
    }
    return undefined;
  }
}
const prepend_reversed$apply$0_List_concat_List_List_Hit$clo = { _0: ($_, $clo, sub, acc) => prepend_reversed$apply$0_List_concat_List_List_Hit($clo, sub, acc) };

function go$apply$1_List_concat_List_List_Hit($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const lst = $tco_a1;
    const acc = $tco_a2;
    {
      let go;
      go = $clo;
      {
        const prepend_reversed = $clo._1;
        switch (lst.$) {
          case "Nil": {
            {
              const $t989_i9182 = { $: "Nil" };
              return List$reverse_onto$List_Hit$List_Hit(acc, $t989_i9182);
            }
            break;
          }
          case "Cons": {
            const $f1118 = lst._0;
            const $f1119 = lst._1;
            {
              const rest = $f1119;
              {
                const xs = $f1118;
                {
                  let $t1117;
                  $t1117 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1117;
                    continue __tco;
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const go$apply$1_List_concat_List_List_Hit$clo = { _0: ($_, $clo, lst, acc) => go$apply$1_List_concat_List_List_Hit($clo, lst, acc) };

function prepend_reversed$apply$0_List_concat_List_List_Cue($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const sub = $tco_a1;
    const acc = $tco_a2;
    {
      const prepend_reversed = $clo;
      switch (sub.$) {
        case "Nil": {
          return acc;
          break;
        }
        case "Cons": {
          const $f1111 = sub._0;
          const $f1112 = sub._1;
          {
            const rest = $f1112;
            {
              const x = $f1111;
              {
                const $t1110 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1110;
                  continue __tco;
                }
              }
            }
          }
          break;
        }
        default: {
          return (() => { throw new Error("non-exhaustive pattern match"); })();
        }
      }
    }
    return undefined;
  }
}
const prepend_reversed$apply$0_List_concat_List_List_Cue$clo = { _0: ($_, $clo, sub, acc) => prepend_reversed$apply$0_List_concat_List_List_Cue($clo, sub, acc) };

function go$apply$1_List_concat_List_List_Cue($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const lst = $tco_a1;
    const acc = $tco_a2;
    {
      let go;
      go = $clo;
      {
        const prepend_reversed = $clo._1;
        switch (lst.$) {
          case "Nil": {
            {
              const $t989_i9184 = { $: "Nil" };
              return List$reverse_onto$List_Cue$List_Cue(acc, $t989_i9184);
            }
            break;
          }
          case "Cons": {
            const $f1118 = lst._0;
            const $f1119 = lst._1;
            {
              const rest = $f1119;
              {
                const xs = $f1118;
                {
                  let $t1117;
                  $t1117 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1117;
                    continue __tco;
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const go$apply$1_List_concat_List_List_Cue$clo = { _0: ($_, $clo, lst, acc) => go$apply$1_List_concat_List_List_Cue($clo, lst, acc) };

function prepend_reversed$apply$0_List_concat_List_List_ReelEvent($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const sub = $tco_a1;
    const acc = $tco_a2;
    {
      const prepend_reversed = $clo;
      switch (sub.$) {
        case "Nil": {
          return acc;
          break;
        }
        case "Cons": {
          const $f1111 = sub._0;
          const $f1112 = sub._1;
          {
            const rest = $f1112;
            {
              const x = $f1111;
              {
                const $t1110 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1110;
                  continue __tco;
                }
              }
            }
          }
          break;
        }
        default: {
          return (() => { throw new Error("non-exhaustive pattern match"); })();
        }
      }
    }
    return undefined;
  }
}
const prepend_reversed$apply$0_List_concat_List_List_ReelEvent$clo = { _0: ($_, $clo, sub, acc) => prepend_reversed$apply$0_List_concat_List_List_ReelEvent($clo, sub, acc) };

function go$apply$1_List_concat_List_List_ReelEvent($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const lst = $tco_a1;
    const acc = $tco_a2;
    {
      let go;
      go = $clo;
      {
        const prepend_reversed = $clo._1;
        switch (lst.$) {
          case "Nil": {
            {
              const $t989_i9186 = { $: "Nil" };
              return List$reverse_onto$List_ReelEvent$List_ReelEvent(acc, $t989_i9186);
            }
            break;
          }
          case "Cons": {
            const $f1118 = lst._0;
            const $f1119 = lst._1;
            {
              const rest = $f1119;
              {
                const xs = $f1118;
                {
                  let $t1117;
                  $t1117 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1117;
                    continue __tco;
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const go$apply$1_List_concat_List_List_ReelEvent$clo = { _0: ($_, $clo, lst, acc) => go$apply$1_List_concat_List_List_ReelEvent($clo, lst, acc) };

function prepend_reversed$apply$0_List_concat_List_List_Part($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const sub = $tco_a1;
    const acc = $tco_a2;
    {
      const prepend_reversed = $clo;
      switch (sub.$) {
        case "Nil": {
          return acc;
          break;
        }
        case "Cons": {
          const $f1111 = sub._0;
          const $f1112 = sub._1;
          {
            const rest = $f1112;
            {
              const x = $f1111;
              {
                const $t1110 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1110;
                  continue __tco;
                }
              }
            }
          }
          break;
        }
        default: {
          return (() => { throw new Error("non-exhaustive pattern match"); })();
        }
      }
    }
    return undefined;
  }
}
const prepend_reversed$apply$0_List_concat_List_List_Part$clo = { _0: ($_, $clo, sub, acc) => prepend_reversed$apply$0_List_concat_List_List_Part($clo, sub, acc) };

function go$apply$1_List_concat_List_List_Part($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const lst = $tco_a1;
    const acc = $tco_a2;
    {
      let go;
      go = $clo;
      {
        const prepend_reversed = $clo._1;
        switch (lst.$) {
          case "Nil": {
            {
              const $t989_i9188 = { $: "Nil" };
              return List$reverse_onto$List_Part$List_Part(acc, $t989_i9188);
            }
            break;
          }
          case "Cons": {
            const $f1118 = lst._0;
            const $f1119 = lst._1;
            {
              const rest = $f1119;
              {
                const xs = $f1118;
                {
                  let $t1117;
                  $t1117 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1117;
                    continue __tco;
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const go$apply$1_List_concat_List_List_Part$clo = { _0: ($_, $clo, lst, acc) => go$apply$1_List_concat_List_List_Part($clo, lst, acc) };

function prepend_reversed$apply$0_List_concat_List_List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const sub = $tco_a1;
    const acc = $tco_a2;
    {
      const prepend_reversed = $clo;
      switch (sub.$) {
        case "Nil": {
          return acc;
          break;
        }
        case "Cons": {
          const $f1111 = sub._0;
          const $f1112 = sub._1;
          {
            const rest = $f1112;
            {
              const x = $f1111;
              {
                const $t1110 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1110;
                  continue __tco;
                }
              }
            }
          }
          break;
        }
        default: {
          return (() => { throw new Error("non-exhaustive pattern match"); })();
        }
      }
    }
    return undefined;
  }
}
const prepend_reversed$apply$0_List_concat_List_List_Op$clo = { _0: ($_, $clo, sub, acc) => prepend_reversed$apply$0_List_concat_List_List_Op($clo, sub, acc) };

function go$apply$1_List_concat_List_List_Op($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const lst = $tco_a1;
    const acc = $tco_a2;
    {
      let go;
      go = $clo;
      {
        const prepend_reversed = $clo._1;
        switch (lst.$) {
          case "Nil": {
            {
              const $t989_i9190 = { $: "Nil" };
              return List$reverse_onto$List_Op$List_Op(acc, $t989_i9190);
            }
            break;
          }
          case "Cons": {
            const $f1118 = lst._0;
            const $f1119 = lst._1;
            {
              const rest = $f1119;
              {
                const xs = $f1118;
                {
                  let $t1117;
                  $t1117 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1117;
                    continue __tco;
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const go$apply$1_List_concat_List_List_Op$clo = { _0: ($_, $clo, lst, acc) => go$apply$1_List_concat_List_List_Op($clo, lst, acc) };

function go$apply$0_List_enumerate_List_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2, $tco_a3) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const lst = $tco_a1;
    const i = $tco_a2;
    const acc = $tco_a3;
    {
      const go = $clo;
      switch (lst.$) {
        case "Nil": {
          {
            const $t989_i9192 = { $: "Nil" };
            return List$reverse_onto$List_T_Int_R_x_Float_y_Float$List_T_Int_R_x_Float_y_Float(acc, $t989_i9192);
          }
          break;
        }
        case "Cons": {
          const $f1359 = lst._0;
          const $f1360 = lst._1;
          {
            const t = $f1360;
            {
              const h = $f1359;
              {
                const $t1356 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
                {
                  const $t1357 = { _0: i, _1: h };
                  {
                    const $t1358 = { $: "Cons", _0: $t1357, _1: acc };
                    {
                      $tco_a0 = $clo;
                      $tco_a1 = t;
                      $tco_a2 = $t1356;
                      $tco_a3 = $t1358;
                      continue __tco;
                    }
                  }
                }
              }
            }
          }
          break;
        }
        default: {
          return (() => { throw new Error("non-exhaustive pattern match"); })();
        }
      }
    }
    return undefined;
  }
}
const go$apply$0_List_enumerate_List_R_x_Float_y_Float$clo = { _0: ($_, $clo, lst, i, acc) => go$apply$0_List_enumerate_List_R_x_Float_y_Float($clo, lst, i, acc) };

function prepend_reversed$apply$0_List_concat_List_List_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const sub = $tco_a1;
    const acc = $tco_a2;
    {
      const prepend_reversed = $clo;
      switch (sub.$) {
        case "Nil": {
          return acc;
          break;
        }
        case "Cons": {
          const $f1111 = sub._0;
          const $f1112 = sub._1;
          {
            const rest = $f1112;
            {
              const x = $f1111;
              {
                const $t1110 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1110;
                  continue __tco;
                }
              }
            }
          }
          break;
        }
        default: {
          return (() => { throw new Error("non-exhaustive pattern match"); })();
        }
      }
    }
    return undefined;
  }
}
const prepend_reversed$apply$0_List_concat_List_List_R_x_Float_y_Float$clo = { _0: ($_, $clo, sub, acc) => prepend_reversed$apply$0_List_concat_List_List_R_x_Float_y_Float($clo, sub, acc) };

function go$apply$1_List_concat_List_List_R_x_Float_y_Float($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const lst = $tco_a1;
    const acc = $tco_a2;
    {
      let go;
      go = $clo;
      {
        const prepend_reversed = $clo._1;
        switch (lst.$) {
          case "Nil": {
            {
              const $t989_i9194 = { $: "Nil" };
              return List$reverse_onto$List_R_x_Float_y_Float$List_R_x_Float_y_Float(acc, $t989_i9194);
            }
            break;
          }
          case "Cons": {
            const $f1118 = lst._0;
            const $f1119 = lst._1;
            {
              const rest = $f1119;
              {
                const xs = $f1118;
                {
                  let $t1117;
                  $t1117 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1117;
                    continue __tco;
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const go$apply$1_List_concat_List_List_R_x_Float_y_Float$clo = { _0: ($_, $clo, lst, acc) => go$apply$1_List_concat_List_List_R_x_Float_y_Float($clo, lst, acc) };

function go$apply$0_List_enumerate_List_T_Buff_Float($tco_a0, $tco_a1, $tco_a2, $tco_a3) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const lst = $tco_a1;
    const i = $tco_a2;
    const acc = $tco_a3;
    {
      const go = $clo;
      switch (lst.$) {
        case "Nil": {
          {
            const $t989_i9196 = { $: "Nil" };
            return List$reverse_onto$List_T_Int_T_Buff_Float$List_T_Int_T_Buff_Float(acc, $t989_i9196);
          }
          break;
        }
        case "Cons": {
          const $f1359 = lst._0;
          const $f1360 = lst._1;
          {
            const t = $f1360;
            {
              const h = $f1359;
              {
                const $t1356 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
                {
                  const $t1357 = { _0: i, _1: h };
                  {
                    const $t1358 = { $: "Cons", _0: $t1357, _1: acc };
                    {
                      $tco_a0 = $clo;
                      $tco_a1 = t;
                      $tco_a2 = $t1356;
                      $tco_a3 = $t1358;
                      continue __tco;
                    }
                  }
                }
              }
            }
          }
          break;
        }
        default: {
          return (() => { throw new Error("non-exhaustive pattern match"); })();
        }
      }
    }
    return undefined;
  }
}
const go$apply$0_List_enumerate_List_T_Buff_Float$clo = { _0: ($_, $clo, lst, i, acc) => go$apply$0_List_enumerate_List_T_Buff_Float($clo, lst, i, acc) };

function go$apply$0_List_each_List_Cue_Fn_Cue_T_($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const $clo = $tco_a0;
    const lst = $tco_a1;
    {
      let go;
      go = $clo;
      {
        const f = $clo._1;
        switch (lst.$) {
          case "Nil": {
            return {  };
            break;
          }
          case "Cons": {
            const $f1013 = lst._0;
            const $f1014 = lst._1;
            {
              const t = $f1014;
              {
                const h = $f1013;
                {
                  let $p1012;
                  $p1012 = f._0(f, h);
                  {
                    $tco_a0 = go;
                    $tco_a1 = t;
                    continue __tco;
                  }
                }
              }
            }
            break;
          }
          default: {
            return (() => { throw new Error("non-exhaustive pattern match"); })();
          }
        }
      }
    }
    return undefined;
  }
}
const go$apply$0_List_each_List_Cue_Fn_Cue_T_$clo = { _0: ($_, $clo, lst) => go$apply$0_List_each_List_Cue_Fn_Cue_T_($clo, lst) };

export { main };
main();
//# sourceMappingURL=spin.mjs.map
