import { march_deep_eq, march_float_round, march_float_to_string, march_int_and, march_int_div, march_int_div_euclid, march_int_div_floor, march_int_mod, march_int_mod_euclid, march_int_mod_floor, march_int_not, march_int_or, march_int_ovf, march_int_popcount, march_int_shl, march_int_shr, march_int_wrapping_add, march_int_wrapping_mul, march_int_wrapping_sub, march_int_xor, march_string_byte_length, march_string_concat3, march_string_concat_n, march_string_contains, march_string_pad_left, march_string_to_float, march_unix_time, march_unix_time_ms } from "./march_runtime.mjs";

import { glue_mark, glue_save_best, glue_load_best, glue_seed_limbs, glue_sound, glue_paint, glue_fit, glue_launch_button, glue_touch, glue_input, glue_listen, glue_request_frame, glue_cell_get, glue_cell_put } from "./spin_glue.mjs";
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
  }
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
      return true;
    }
    case "Flipped": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
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
  if (a.gravity !== b.gravity) return false;
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
    const $t45804 = march_string_to_float(text);
    switch ($t45804.$) {
      case "Some": {
        const $f45805 = $t45804._0;
        {
          const x = $f45805;
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
      const $t45881 = a.lo;
      {
        const $t45882 = b.lo;
        low = (($t45881 + $t45882) < 4611686018427387904 && ($t45881 + $t45882) >= -4611686018427387904 ? ($t45881 + $t45882) : march_int_ovf(($t45881 + $t45882), 0));
      }
    }
    {
      let $t45889;
      {
        let $t45888;
        {
          let $t45885;
          {
            const $t45883 = a.hi;
            {
              const $t45884 = b.hi;
              $t45885 = (($t45883 + $t45884) < 4611686018427387904 && ($t45883 + $t45884) >= -4611686018427387904 ? ($t45883 + $t45884) : march_int_ovf(($t45883 + $t45884), 0));
            }
          }
          {
            let $t45887;
            {
              const $t45886 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
              $t45887 = ((low - low % $t45886) / $t45886);
            }
            $t45888 = (($t45885 + $t45887) < 4611686018427387904 && ($t45885 + $t45887) >= -4611686018427387904 ? ($t45885 + $t45887) : march_int_ovf(($t45885 + $t45887), 0));
          }
        }
        {
          let $t45814_i5221;
          {
            const $t45813_i5220 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
            $t45814_i5221 = (($t45813_i5220 - 1) < 4611686018427387904 && ($t45813_i5220 - 1) >= -4611686018427387904 ? ($t45813_i5220 - 1) : march_int_ovf(($t45813_i5220 - 1), 1));
          }
          $t45889 = (($t45888 | 0) === $t45888 && ($t45814_i5221 | 0) === $t45814_i5221 ? ($t45888 & $t45814_i5221) : march_int_and($t45888, $t45814_i5221));
        }
      }
      {
        let $t45890;
        {
          let $t45814_i5218;
          {
            const $t45813_i5217 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
            $t45814_i5218 = (($t45813_i5217 - 1) < 4611686018427387904 && ($t45813_i5217 - 1) >= -4611686018427387904 ? ($t45813_i5217 - 1) : march_int_ovf(($t45813_i5217 - 1), 1));
          }
          $t45890 = ((low | 0) === low && ($t45814_i5218 | 0) === $t45814_i5218 ? (low & $t45814_i5218) : march_int_and(low, $t45814_i5218));
        }
        return ({ hi: $t45889, lo: $t45890 });
      }
    }
  }
}
const Arcade$U64$add$clo = { _0: ($_, a, b) => Arcade$U64$add(a, b) };

function Arcade$U64$xor(a, b) {
  {
    let $t45893;
    {
      const $t45891 = a.hi;
      {
        const $t45892 = b.hi;
        $t45893 = (($t45891 | 0) === $t45891 && ($t45892 | 0) === $t45892 ? ($t45891 ^ $t45892) : march_int_xor($t45891, $t45892));
      }
    }
    {
      let $t45896;
      {
        const $t45894 = a.lo;
        {
          const $t45895 = b.lo;
          $t45896 = (($t45894 | 0) === $t45894 && ($t45895 | 0) === $t45895 ? ($t45894 ^ $t45895) : march_int_xor($t45894, $t45895));
        }
      }
      return ({ hi: $t45893, lo: $t45896 });
    }
  }
}
const Arcade$U64$xor$clo = { _0: ($_, a, b) => Arcade$U64$xor(a, b) };

function Arcade$U64$shr(a, k) {
  {
    let carried;
    {
      let $t45900;
      {
        const $t45897 = a.hi;
        {
          let $t45899;
          {
            const $t45898 = march_int_shl(1, k);
            $t45899 = (($t45898 - 1) < 4611686018427387904 && ($t45898 - 1) >= -4611686018427387904 ? ($t45898 - 1) : march_int_ovf(($t45898 - 1), 1));
          }
          $t45900 = (($t45897 | 0) === $t45897 && ($t45899 | 0) === $t45899 ? ($t45897 & $t45899) : march_int_and($t45897, $t45899));
        }
      }
      {
        let $t45902;
        {
          const $t45901 = ((32 - k) < 4611686018427387904 && (32 - k) >= -4611686018427387904 ? (32 - k) : march_int_ovf((32 - k), 1));
          $t45902 = march_int_shl(1, $t45901);
        }
        carried = (($t45900 * $t45902) < 4611686018427387904 && ($t45900 * $t45902) >= -4611686018427387904 ? ($t45900 * $t45902) : march_int_ovf(($t45900 * $t45902), 2));
      }
    }
    {
      let $t45904;
      {
        const $t45903 = a.hi;
        $t45904 = (($t45903 | 0) === $t45903 && k >= 0 && k < 32 ? ($t45903 >> k) : march_int_shr($t45903, k));
      }
      {
        let $t45907;
        {
          let $t45906;
          {
            const $t45905 = a.lo;
            $t45906 = (($t45905 | 0) === $t45905 && k >= 0 && k < 32 ? ($t45905 >> k) : march_int_shr($t45905, k));
          }
          $t45907 = ((carried + $t45906) < 4611686018427387904 && (carried + $t45906) >= -4611686018427387904 ? (carried + $t45906) : march_int_ovf((carried + $t45906), 0));
        }
        return ({ hi: $t45904, lo: $t45907 });
      }
    }
  }
}
const Arcade$U64$shr$clo = { _0: ($_, a, k) => Arcade$U64$shr(a, k) };

function Arcade$U64$mul(a, b) {
  {
    let a0;
    {
      const $t45920 = a.lo;
      a0 = (($t45920 | 0) === $t45920 && (65535 | 0) === 65535 ? ($t45920 & 65535) : march_int_and($t45920, 65535));
    }
    {
      let a1;
      {
        const $t45921 = a.lo;
        a1 = (($t45921 | 0) === $t45921 && 16 >= 0 && 16 < 32 ? ($t45921 >> 16) : march_int_shr($t45921, 16));
      }
      {
        let b0;
        {
          const $t45922 = b.lo;
          b0 = (($t45922 | 0) === $t45922 && (65535 | 0) === 65535 ? ($t45922 & 65535) : march_int_and($t45922, 65535));
        }
        {
          let b1;
          {
            const $t45923 = b.lo;
            b1 = (($t45923 | 0) === $t45923 && 16 >= 0 && 16 < 32 ? ($t45923 >> 16) : march_int_shr($t45923, 16));
          }
          {
            const p00 = ((a0 * b0) < 4611686018427387904 && (a0 * b0) >= -4611686018427387904 ? (a0 * b0) : march_int_ovf((a0 * b0), 2));
            {
              let mid;
              {
                let $t45926;
                {
                  const $t45924 = ((a0 * b1) < 4611686018427387904 && (a0 * b1) >= -4611686018427387904 ? (a0 * b1) : march_int_ovf((a0 * b1), 2));
                  {
                    const $t45925 = ((a1 * b0) < 4611686018427387904 && (a1 * b0) >= -4611686018427387904 ? (a1 * b0) : march_int_ovf((a1 * b0), 2));
                    $t45926 = (($t45924 + $t45925) < 4611686018427387904 && ($t45924 + $t45925) >= -4611686018427387904 ? ($t45924 + $t45925) : march_int_ovf(($t45924 + $t45925), 0));
                  }
                }
                {
                  const $t45927 = ((p00 | 0) === p00 && 16 >= 0 && 16 < 32 ? (p00 >> 16) : march_int_shr(p00, 16));
                  mid = (($t45926 + $t45927) < 4611686018427387904 && ($t45926 + $t45927) >= -4611686018427387904 ? ($t45926 + $t45927) : march_int_ovf(($t45926 + $t45927), 0));
                }
              }
              {
                let low;
                {
                  const $t45928 = ((p00 | 0) === p00 && (65535 | 0) === 65535 ? (p00 & 65535) : march_int_and(p00, 65535));
                  {
                    let $t45930;
                    {
                      const $t45929 = ((mid | 0) === mid && (65535 | 0) === 65535 ? (mid & 65535) : march_int_and(mid, 65535));
                      $t45930 = (($t45929 * 65536) < 4611686018427387904 && ($t45929 * 65536) >= -4611686018427387904 ? ($t45929 * 65536) : march_int_ovf(($t45929 * 65536), 2));
                    }
                    low = (($t45928 + $t45930) < 4611686018427387904 && ($t45928 + $t45930) >= -4611686018427387904 ? ($t45928 + $t45930) : march_int_ovf(($t45928 + $t45930), 0));
                  }
                }
                {
                  let carry;
                  {
                    const $t45931 = ((a1 * b1) < 4611686018427387904 && (a1 * b1) >= -4611686018427387904 ? (a1 * b1) : march_int_ovf((a1 * b1), 2));
                    {
                      const $t45932 = ((mid | 0) === mid && 16 >= 0 && 16 < 32 ? (mid >> 16) : march_int_shr(mid, 16));
                      carry = (($t45931 + $t45932) < 4611686018427387904 && ($t45931 + $t45932) >= -4611686018427387904 ? ($t45931 + $t45932) : march_int_ovf(($t45931 + $t45932), 0));
                    }
                  }
                  {
                    let $t45941;
                    {
                      let $t45940;
                      {
                        let $t45936;
                        {
                          let $t45935;
                          {
                            const $t45933 = a.hi;
                            {
                              const $t45934 = b.lo;
                              {
                                let cross_i5259;
                                {
                                  let $t45914_i5258;
                                  {
                                    let $t45910_i5254;
                                    {
                                      const $t45908_i5252 = (($t45933 | 0) === $t45933 && 16 >= 0 && 16 < 32 ? ($t45933 >> 16) : march_int_shr($t45933, 16));
                                      {
                                        const $t45909_i5253 = (($t45934 | 0) === $t45934 && (65535 | 0) === 65535 ? ($t45934 & 65535) : march_int_and($t45934, 65535));
                                        $t45910_i5254 = (($t45908_i5252 * $t45909_i5253) < 4611686018427387904 && ($t45908_i5252 * $t45909_i5253) >= -4611686018427387904 ? ($t45908_i5252 * $t45909_i5253) : march_int_ovf(($t45908_i5252 * $t45909_i5253), 2));
                                      }
                                    }
                                    {
                                      let $t45913_i5257;
                                      {
                                        const $t45911_i5255 = (($t45933 | 0) === $t45933 && (65535 | 0) === 65535 ? ($t45933 & 65535) : march_int_and($t45933, 65535));
                                        {
                                          const $t45912_i5256 = (($t45934 | 0) === $t45934 && 16 >= 0 && 16 < 32 ? ($t45934 >> 16) : march_int_shr($t45934, 16));
                                          $t45913_i5257 = (($t45911_i5255 * $t45912_i5256) < 4611686018427387904 && ($t45911_i5255 * $t45912_i5256) >= -4611686018427387904 ? ($t45911_i5255 * $t45912_i5256) : march_int_ovf(($t45911_i5255 * $t45912_i5256), 2));
                                        }
                                      }
                                      $t45914_i5258 = (($t45910_i5254 + $t45913_i5257) < 4611686018427387904 && ($t45910_i5254 + $t45913_i5257) >= -4611686018427387904 ? ($t45910_i5254 + $t45913_i5257) : march_int_ovf(($t45910_i5254 + $t45913_i5257), 0));
                                    }
                                  }
                                  cross_i5259 = (($t45914_i5258 | 0) === $t45914_i5258 && (65535 | 0) === 65535 ? ($t45914_i5258 & 65535) : march_int_and($t45914_i5258, 65535));
                                }
                                {
                                  let $t45919_i5264;
                                  {
                                    let $t45917_i5262;
                                    {
                                      const $t45915_i5260 = (($t45933 | 0) === $t45933 && (65535 | 0) === 65535 ? ($t45933 & 65535) : march_int_and($t45933, 65535));
                                      {
                                        const $t45916_i5261 = (($t45934 | 0) === $t45934 && (65535 | 0) === 65535 ? ($t45934 & 65535) : march_int_and($t45934, 65535));
                                        $t45917_i5262 = (($t45915_i5260 * $t45916_i5261) < 4611686018427387904 && ($t45915_i5260 * $t45916_i5261) >= -4611686018427387904 ? ($t45915_i5260 * $t45916_i5261) : march_int_ovf(($t45915_i5260 * $t45916_i5261), 2));
                                      }
                                    }
                                    {
                                      const $t45918_i5263 = ((cross_i5259 * 65536) < 4611686018427387904 && (cross_i5259 * 65536) >= -4611686018427387904 ? (cross_i5259 * 65536) : march_int_ovf((cross_i5259 * 65536), 2));
                                      $t45919_i5264 = (($t45917_i5262 + $t45918_i5263) < 4611686018427387904 && ($t45917_i5262 + $t45918_i5263) >= -4611686018427387904 ? ($t45917_i5262 + $t45918_i5263) : march_int_ovf(($t45917_i5262 + $t45918_i5263), 0));
                                    }
                                  }
                                  {
                                    let $t45814_i14184;
                                    {
                                      const $t45813_i14183 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                                      $t45814_i14184 = (($t45813_i14183 - 1) < 4611686018427387904 && ($t45813_i14183 - 1) >= -4611686018427387904 ? ($t45813_i14183 - 1) : march_int_ovf(($t45813_i14183 - 1), 1));
                                    }
                                    $t45935 = (($t45919_i5264 | 0) === $t45919_i5264 && ($t45814_i14184 | 0) === $t45814_i14184 ? ($t45919_i5264 & $t45814_i14184) : march_int_and($t45919_i5264, $t45814_i14184));
                                  }
                                }
                              }
                            }
                          }
                          $t45936 = ((carry + $t45935) < 4611686018427387904 && (carry + $t45935) >= -4611686018427387904 ? (carry + $t45935) : march_int_ovf((carry + $t45935), 0));
                        }
                        {
                          let $t45939;
                          {
                            const $t45937 = a.lo;
                            {
                              const $t45938 = b.hi;
                              {
                                let cross_i5244;
                                {
                                  let $t45914_i5243;
                                  {
                                    let $t45910_i5239;
                                    {
                                      const $t45908_i5237 = (($t45937 | 0) === $t45937 && 16 >= 0 && 16 < 32 ? ($t45937 >> 16) : march_int_shr($t45937, 16));
                                      {
                                        const $t45909_i5238 = (($t45938 | 0) === $t45938 && (65535 | 0) === 65535 ? ($t45938 & 65535) : march_int_and($t45938, 65535));
                                        $t45910_i5239 = (($t45908_i5237 * $t45909_i5238) < 4611686018427387904 && ($t45908_i5237 * $t45909_i5238) >= -4611686018427387904 ? ($t45908_i5237 * $t45909_i5238) : march_int_ovf(($t45908_i5237 * $t45909_i5238), 2));
                                      }
                                    }
                                    {
                                      let $t45913_i5242;
                                      {
                                        const $t45911_i5240 = (($t45937 | 0) === $t45937 && (65535 | 0) === 65535 ? ($t45937 & 65535) : march_int_and($t45937, 65535));
                                        {
                                          const $t45912_i5241 = (($t45938 | 0) === $t45938 && 16 >= 0 && 16 < 32 ? ($t45938 >> 16) : march_int_shr($t45938, 16));
                                          $t45913_i5242 = (($t45911_i5240 * $t45912_i5241) < 4611686018427387904 && ($t45911_i5240 * $t45912_i5241) >= -4611686018427387904 ? ($t45911_i5240 * $t45912_i5241) : march_int_ovf(($t45911_i5240 * $t45912_i5241), 2));
                                        }
                                      }
                                      $t45914_i5243 = (($t45910_i5239 + $t45913_i5242) < 4611686018427387904 && ($t45910_i5239 + $t45913_i5242) >= -4611686018427387904 ? ($t45910_i5239 + $t45913_i5242) : march_int_ovf(($t45910_i5239 + $t45913_i5242), 0));
                                    }
                                  }
                                  cross_i5244 = (($t45914_i5243 | 0) === $t45914_i5243 && (65535 | 0) === 65535 ? ($t45914_i5243 & 65535) : march_int_and($t45914_i5243, 65535));
                                }
                                {
                                  let $t45919_i5249;
                                  {
                                    let $t45917_i5247;
                                    {
                                      const $t45915_i5245 = (($t45937 | 0) === $t45937 && (65535 | 0) === 65535 ? ($t45937 & 65535) : march_int_and($t45937, 65535));
                                      {
                                        const $t45916_i5246 = (($t45938 | 0) === $t45938 && (65535 | 0) === 65535 ? ($t45938 & 65535) : march_int_and($t45938, 65535));
                                        $t45917_i5247 = (($t45915_i5245 * $t45916_i5246) < 4611686018427387904 && ($t45915_i5245 * $t45916_i5246) >= -4611686018427387904 ? ($t45915_i5245 * $t45916_i5246) : march_int_ovf(($t45915_i5245 * $t45916_i5246), 2));
                                      }
                                    }
                                    {
                                      const $t45918_i5248 = ((cross_i5244 * 65536) < 4611686018427387904 && (cross_i5244 * 65536) >= -4611686018427387904 ? (cross_i5244 * 65536) : march_int_ovf((cross_i5244 * 65536), 2));
                                      $t45919_i5249 = (($t45917_i5247 + $t45918_i5248) < 4611686018427387904 && ($t45917_i5247 + $t45918_i5248) >= -4611686018427387904 ? ($t45917_i5247 + $t45918_i5248) : march_int_ovf(($t45917_i5247 + $t45918_i5248), 0));
                                    }
                                  }
                                  {
                                    let $t45814_i14174;
                                    {
                                      const $t45813_i14173 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                                      $t45814_i14174 = (($t45813_i14173 - 1) < 4611686018427387904 && ($t45813_i14173 - 1) >= -4611686018427387904 ? ($t45813_i14173 - 1) : march_int_ovf(($t45813_i14173 - 1), 1));
                                    }
                                    $t45939 = (($t45919_i5249 | 0) === $t45919_i5249 && ($t45814_i14174 | 0) === $t45814_i14174 ? ($t45919_i5249 & $t45814_i14174) : march_int_and($t45919_i5249, $t45814_i14174));
                                  }
                                }
                              }
                            }
                          }
                          $t45940 = (($t45936 + $t45939) < 4611686018427387904 && ($t45936 + $t45939) >= -4611686018427387904 ? ($t45936 + $t45939) : march_int_ovf(($t45936 + $t45939), 0));
                        }
                      }
                      {
                        let $t45814_i5234;
                        {
                          const $t45813_i5233 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                          $t45814_i5234 = (($t45813_i5233 - 1) < 4611686018427387904 && ($t45813_i5233 - 1) >= -4611686018427387904 ? ($t45813_i5233 - 1) : march_int_ovf(($t45813_i5233 - 1), 1));
                        }
                        $t45941 = (($t45940 | 0) === $t45940 && ($t45814_i5234 | 0) === $t45814_i5234 ? ($t45940 & $t45814_i5234) : march_int_and($t45940, $t45814_i5234));
                      }
                    }
                    return ({ hi: $t45941, lo: low });
                  }
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
      const $t45942 = r.word;
      {
        let $t45943;
        {
          let $t45821_i5282;
          {
            let $t45814_i14209;
            {
              const $t45813_i14208 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
              $t45814_i14209 = (($t45813_i14208 - 1) < 4611686018427387904 && ($t45813_i14208 - 1) >= -4611686018427387904 ? ($t45813_i14208 - 1) : march_int_ovf(($t45813_i14208 - 1), 1));
            }
            $t45821_i5282 = ((2654435769 | 0) === 2654435769 && ($t45814_i14209 | 0) === $t45814_i14209 ? (2654435769 & $t45814_i14209) : march_int_and(2654435769, $t45814_i14209));
          }
          {
            let $t45822_i5283;
            {
              let $t45814_i14206;
              {
                const $t45813_i14205 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                $t45814_i14206 = (($t45813_i14205 - 1) < 4611686018427387904 && ($t45813_i14205 - 1) >= -4611686018427387904 ? ($t45813_i14205 - 1) : march_int_ovf(($t45813_i14205 - 1), 1));
              }
              $t45822_i5283 = ((2135587861 | 0) === 2135587861 && ($t45814_i14206 | 0) === $t45814_i14206 ? (2135587861 & $t45814_i14206) : march_int_and(2135587861, $t45814_i14206));
            }
            $t45943 = ({ hi: $t45821_i5282, lo: $t45822_i5283 });
          }
        }
        word = Arcade$U64$add($t45942, $t45943);
      }
    }
    {
      let z1;
      {
        let $t45945;
        {
          let $t45944;
          $t45944 = Arcade$U64$shr(word, 30);
          $t45945 = Arcade$U64$xor(word, $t45944);
        }
        {
          let $t45946;
          {
            let $t45821_i5278;
            {
              let $t45814_i14203;
              {
                const $t45813_i14202 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                $t45814_i14203 = (($t45813_i14202 - 1) < 4611686018427387904 && ($t45813_i14202 - 1) >= -4611686018427387904 ? ($t45813_i14202 - 1) : march_int_ovf(($t45813_i14202 - 1), 1));
              }
              $t45821_i5278 = ((3210233709 | 0) === 3210233709 && ($t45814_i14203 | 0) === $t45814_i14203 ? (3210233709 & $t45814_i14203) : march_int_and(3210233709, $t45814_i14203));
            }
            {
              let $t45822_i5279;
              {
                let $t45814_i14200;
                {
                  const $t45813_i14199 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                  $t45814_i14200 = (($t45813_i14199 - 1) < 4611686018427387904 && ($t45813_i14199 - 1) >= -4611686018427387904 ? ($t45813_i14199 - 1) : march_int_ovf(($t45813_i14199 - 1), 1));
                }
                $t45822_i5279 = ((484763065 | 0) === 484763065 && ($t45814_i14200 | 0) === $t45814_i14200 ? (484763065 & $t45814_i14200) : march_int_and(484763065, $t45814_i14200));
              }
              $t45946 = ({ hi: $t45821_i5278, lo: $t45822_i5279 });
            }
          }
          z1 = Arcade$U64$mul($t45945, $t45946);
        }
      }
      {
        let z2;
        {
          let $t45948;
          {
            let $t45947;
            $t45947 = Arcade$U64$shr(z1, 27);
            $t45948 = Arcade$U64$xor(z1, $t45947);
          }
          {
            let $t45949;
            {
              let $t45821_i5274;
              {
                let $t45814_i14197;
                {
                  const $t45813_i14196 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                  $t45814_i14197 = (($t45813_i14196 - 1) < 4611686018427387904 && ($t45813_i14196 - 1) >= -4611686018427387904 ? ($t45813_i14196 - 1) : march_int_ovf(($t45813_i14196 - 1), 1));
                }
                $t45821_i5274 = ((2496678331 | 0) === 2496678331 && ($t45814_i14197 | 0) === $t45814_i14197 ? (2496678331 & $t45814_i14197) : march_int_and(2496678331, $t45814_i14197));
              }
              {
                let $t45822_i5275;
                {
                  let $t45814_i14194;
                  {
                    const $t45813_i14193 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                    $t45814_i14194 = (($t45813_i14193 - 1) < 4611686018427387904 && ($t45813_i14193 - 1) >= -4611686018427387904 ? ($t45813_i14193 - 1) : march_int_ovf(($t45813_i14193 - 1), 1));
                  }
                  $t45822_i5275 = ((321982955 | 0) === 321982955 && ($t45814_i14194 | 0) === $t45814_i14194 ? (321982955 & $t45814_i14194) : march_int_and(321982955, $t45814_i14194));
                }
                $t45949 = ({ hi: $t45821_i5274, lo: $t45822_i5275 });
              }
            }
            z2 = Arcade$U64$mul($t45948, $t45949);
          }
        }
        {
          let $t45951;
          {
            let $t45950;
            $t45950 = Arcade$U64$shr(z2, 31);
            $t45951 = Arcade$U64$xor(z2, $t45950);
          }
          {
            const $t45952 = ({ word: word });
            return { _0: $t45951, _1: $t45952 };
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
      const $t45967 = (position < 0);
      if ($t45967 === true) {
        return r;
      } else {
        {
          let $t45970;
          {
            let $t45969;
            {
              const $t45968 = ((word | 0) === word && position >= 0 && position < 32 ? (word >> position) : march_int_shr(word, position));
              $t45969 = (($t45968 | 0) === $t45968 && (1 | 0) === 1 ? ($t45968 & 1) : march_int_and($t45968, 1));
            }
            {
              let doubled_i5290;
              {
                let $t45962_i5288;
                {
                  const $t45961_i5287 = ((n - r) < 4611686018427387904 && (n - r) >= -4611686018427387904 ? (n - r) : march_int_ovf((n - r), 1));
                  $t45962_i5288 = (r >= $t45961_i5287);
                }
                if ($t45962_i5288 === true) {
                  {
                    const $t45963_i5289 = ((n - r) < 4611686018427387904 && (n - r) >= -4611686018427387904 ? (n - r) : march_int_ovf((n - r), 1));
                    doubled_i5290 = ((r - $t45963_i5289) < 4611686018427387904 && (r - $t45963_i5289) >= -4611686018427387904 ? (r - $t45963_i5289) : march_int_ovf((r - $t45963_i5289), 1));
                  }
                } else {
                  doubled_i5290 = ((r + r) < 4611686018427387904 && (r + r) >= -4611686018427387904 ? (r + r) : march_int_ovf((r + r), 0));
                }
              }
              {
                const $t45964_i5291 = ($t45969 === 0);
                if ($t45964_i5291 === true) {
                  $t45970 = doubled_i5290;
                } else {
                  {
                    let $t45966_i5293;
                    {
                      const $t45965_i5292 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                      $t45966_i5293 = (doubled_i5290 === $t45965_i5292);
                    }
                    if ($t45966_i5293 === true) {
                      $t45970 = 0;
                    } else {
                      $t45970 = ((doubled_i5290 + 1) < 4611686018427387904 && (doubled_i5290 + 1) >= -4611686018427387904 ? (doubled_i5290 + 1) : march_int_ovf((doubled_i5290 + 1), 0));
                    }
                  }
                }
              }
            }
          }
          {
            const $t45971 = ((position - 1) < 4611686018427387904 && (position - 1) >= -4611686018427387904 ? (position - 1) : march_int_ovf((position - 1), 1));
            {
              $tco_a0 = $t45970;
              $tco_a1 = word;
              $tco_a2 = $t45971;
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

function Arcade$Vec2$add(a, b) {
  {
    let $t46042;
    {
      const $t46040 = a.x;
      {
        const $t46041 = b.x;
        $t46042 = ($t46040 + $t46041);
      }
    }
    {
      let $t46045;
      {
        const $t46043 = a.y;
        {
          const $t46044 = b.y;
          $t46045 = ($t46043 + $t46044);
        }
      }
      return ({ x: $t46042, y: $t46045 });
    }
  }
}
const Arcade$Vec2$add$clo = { _0: ($_, a, b) => Arcade$Vec2$add(a, b) };

function Arcade$Vec2$sub(a, b) {
  {
    let $t46048;
    {
      const $t46046 = a.x;
      {
        const $t46047 = b.x;
        $t46048 = ($t46046 - $t46047);
      }
    }
    {
      let $t46051;
      {
        const $t46049 = a.y;
        {
          const $t46050 = b.y;
          $t46051 = ($t46049 - $t46050);
        }
      }
      return ({ x: $t46048, y: $t46051 });
    }
  }
}
const Arcade$Vec2$sub$clo = { _0: ($_, a, b) => Arcade$Vec2$sub(a, b) };

function Arcade$Vec2$scale(a, k) {
  {
    let $t46053;
    {
      const $t46052 = a.x;
      $t46053 = ($t46052 * k);
    }
    {
      let $t46055;
      {
        const $t46054 = a.y;
        $t46055 = ($t46054 * k);
      }
      return ({ x: $t46053, y: $t46055 });
    }
  }
}
const Arcade$Vec2$scale$clo = { _0: ($_, a, k) => Arcade$Vec2$scale(a, k) };

function Arcade$Vec2$dot(a, b) {
  {
    let $t46062;
    {
      const $t46060 = a.x;
      {
        const $t46061 = b.x;
        $t46062 = ($t46060 * $t46061);
      }
    }
    {
      let $t46065;
      {
        const $t46063 = a.y;
        {
          const $t46064 = b.y;
          $t46065 = ($t46063 * $t46064);
        }
      }
      return ($t46062 + $t46065);
    }
  }
}
const Arcade$Vec2$dot$clo = { _0: ($_, a, b) => Arcade$Vec2$dot(a, b) };

function Arcade$Vec2$length(a) {
  {
    let $t46072;
    {
      let $t46068;
      {
        const $t46066 = a.x;
        {
          const $t46067 = a.x;
          $t46068 = ($t46066 * $t46067);
        }
      }
      {
        let $t46071;
        {
          const $t46069 = a.y;
          {
            const $t46070 = a.y;
            $t46071 = ($t46069 * $t46070);
          }
        }
        $t46072 = ($t46068 + $t46071);
      }
    }
    return Math.sqrt($t46072);
  }
}
const Arcade$Vec2$length$clo = { _0: ($_, a) => Arcade$Vec2$length(a) };

function Spin$Draw$stick(a, b, w, css) {
  {
    const $t46138 = a.x;
    {
      const $t46139 = a.y;
      {
        const $t46140 = b.x;
        {
          const $t46141 = b.y;
          return { $: "Line", _0: $t46138, _1: $t46139, _2: $t46140, _3: $t46141, _4: w, _5: css };
        }
      }
    }
  }
}
const Spin$Draw$stick$clo = { _0: ($_, a, b, w, css) => Spin$Draw$stick(a, b, w, css) };

function Spin$Draw$rgba(r, g, b, a) {
  {
    const $t46147 = String(r);
    {
      const $t46148 = String(g);
      {
        const $t46149 = String(b);
        {
          let $t46150;
          {
            let k_i14509;
            {
              let $t46143_i14508;
              {
                let $t46142_i14507;
                {
                  let $t45789_i5311_i14505;
                  {
                    const $t45787_i14215_i14504 = (0. >= a);
                    if ($t45787_i14215_i14504 === true) {
                      $t45789_i5311_i14505 = 0.;
                    } else {
                      $t45789_i5311_i14505 = a;
                    }
                  }
                  {
                    const $t45788_i14212_i14506 = (1. < $t45789_i5311_i14505);
                    if ($t45788_i14212_i14506 === true) {
                      $t46142_i14507 = 1.;
                    } else {
                      $t46142_i14507 = $t45789_i5311_i14505;
                    }
                  }
                }
                $t46143_i14508 = ($t46142_i14507 * 1000.);
              }
              k_i14509 = march_float_round($t46143_i14508);
            }
            {
              const $t46144_i14510 = (k_i14509 >= 1000);
              if ($t46144_i14510 === true) {
                $t46150 = "1";
              } else {
                {
                  let $t46146_i14513;
                  {
                    const $t46145_i14511 = String(k_i14509);
                    {
                      const $rc_2505_i14512 = march_string_pad_left($t46145_i14511, 3, "0");
                      $t46146_i14513 = $rc_2505_i14512;
                    }
                  }
                  {
                    const $rc_2504_i14514 = ("0." + $t46146_i14513);
                    $t46150 = $rc_2504_i14514;
                  }
                }
              }
            }
          }
          {
            const $rc_2506 = march_string_concat_n("rgba(", $t46147, ",", $t46148, ",", $t46149, ",", $t46150, ")");
            return $rc_2506;
          }
        }
      }
    }
  }
}
const Spin$Draw$rgba$clo = { _0: ($_, r, g, b, a) => Spin$Draw$rgba(r, g, b, a) };

function Spin$Game$ball_at_plunger(t) {
  {
    const $t46155 = t.plunger_rest;
    {
      const $t46156 = ({ x: 0., y: 0. });
      return ({ pos: $t46155, vel: $t46156 });
    }
  }
}
const Spin$Game$ball_at_plunger$clo = { _0: ($_, t) => Spin$Game$ball_at_plunger(t) };

function Spin$Game$boot(seed, best) {
  {
    let n;
    {
      const $t45806_i5317 = Arcade$Numerics$float_of_text("3.141592653589793");
      {
        const $t45807_i5318 = Arcade$Numerics$float_of_text("6.283185307179586");
        {
          const $t45808_i5319 = Arcade$Numerics$float_of_text("1.1102230246251565e-16");
          {
            let $t45810_i5321;
            {
              const $t45809_i5320 = Arcade$Numerics$float_of_text("1e308");
              $t45810_i5321 = ($t45809_i5320 * 10.);
            }
            {
              let $t45812_i5323;
              {
                const $t45811_i5322 = (-1.);
                $t45812_i5323 = Math.sqrt($t45811_i5322);
              }
              n = ({ pi: $t45806_i5317, tau: $t45807_i5318, unit53: $t45808_i5319, floor_u1: 1e-12, infinity: $t45810_i5321, nan: $t45812_i5323 });
            }
          }
        }
      }
    }
    {
      let t;
      {
        const n_i14409 = n;
        {
          let $t47420_i14410;
          $t47420_i14410 = Spin$Table$parts(n);
          {
            let $t47423_i14415;
            {
              const $t47421_i14413 = ({ x: 120., y: 660. });
              {
                const $t47422_i14414 = (-0.45);
                $t47423_i14415 = ({ pivot: $t47421_i14413, length: 54., radius: 7., rest: 0.52, up: $t47422_i14414 });
              }
            }
            {
              let $t47429_i14423;
              {
                const $t47424_i14418 = ({ x: 250., y: 660. });
                {
                  let $t47426_i14420;
                  {
                    const $t47425_i14419 = n.pi;
                    $t47426_i14420 = ($t47425_i14419 - 0.52);
                  }
                  {
                    let $t47428_i14422;
                    {
                      const $t47427_i14421 = n.pi;
                      $t47428_i14422 = ($t47427_i14421 + 0.45);
                    }
                    $t47429_i14423 = ({ pivot: $t47424_i14418, length: 54., radius: 7., rest: $t47426_i14420, up: $t47428_i14422 });
                  }
                }
              }
              {
                const $t47430_i14426 = ({ x: 365., y: 690. });
                {
                  const $t47431_i14427 = { _0: 95., _1: 378., _2: 180., _3: 96. };
                  t = ({ parts: $t47420_i14410, left: $t47423_i14415, right: $t47429_i14423, ball_radius: 9., gravity: 1150., plunger_rest: $t47430_i14426, drain_y: 770., width: 400., height: 760., reel_window: $t47431_i14427 });
                }
              }
            }
          }
        }
      }
      {
        const $t46157 = { $: "Attract" };
        {
          const $t46158 = { $: "Nil" };
          {
            let $t46160;
            {
              const $t46159 = t.left;
              $t46160 = Spin$Physics$resting($t46159);
            }
            {
              let $t46162;
              {
                const $t46161 = t.right;
                $t46162 = Spin$Physics$resting($t46161);
              }
              {
                const $t46163 = Spin$Reels$fresh_bank();
                {
                  const $t46164 = ({ word: seed });
                  {
                    const $t46166 = ({ text: "SPIN SPIN SPIN", sub: "", left: 1000000., hot: false });
                    {
                      const $t46167 = { $: "Nil" };
                      {
                        const $t46168 = ({ left: false, right: false, launch: false, start: false });
                        return ({ num: n, table: t, mode: $t46157, balls: $t46158, left: $t46160, right: $t46162, bank: $t46163, rng: $t46164, credits: 40, paid: 0, best: best, burn_clock: 0., alive: 0., pull: 0., save_left: 0., owed_balls: 0, carry: 0., banner: $t46166, lights: $t46167, spinner_turn: 0., spinner_rate: 0., last: $t46168, clock: 0. });
                      }
                    }
                  }
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
    const $t46169 = { $: "Playing" };
    {
      let $t46171;
      {
        const $t46170 = m.table;
        $t46171 = Spin$Game$ball_at_plunger($t46170);
      }
      {
        const $t46172 = { $: "Nil" };
        {
          const $t46173 = { $: "Cons", _0: $t46171, _1: $t46172 };
          {
            const $t46174 = Spin$Reels$fresh_bank();
            {
              const $t46177 = ({ text: "SPELL A LINE", sub: "targets put their symbol on the armed reel", left: 3.5, hot: false });
              {
                const $t46178 = { $: "Nil" };
                {
                  const $rc_2507 = ({ ...m, mode: $t46169, balls: $t46173, bank: $t46174, credits: 40, paid: 0, burn_clock: 0., alive: 0., pull: 0., save_left: 8., owed_balls: 0, carry: 0., banner: $t46177, lights: $t46178 });
                  return $rc_2507;
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
    const $t46179 = m.balls;
    {
      const $t46181 = { $: "$Clo_$lam0_Spin_Game_waiting$0_Spin_Game_waiting", _0: $lam0_Spin_Game_waiting$apply$0_Spin_Game_waiting };
      return List$any$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46179, $t46181);
    }
  }
}
const Spin$Game$waiting$clo = { _0: ($_, m) => Spin$Game$waiting(m) };

function Spin$Game$resting_in_lane(b) {
  {
    let $t46187;
    {
      let $t46183;
      {
        const $t46182 = b.pos;
        $t46183 = Spin$Table$in_lane($t46182);
      }
      {
        let $t46186;
        {
          let $t46185;
          {
            const $t46184 = b.pos;
            $t46185 = $t46184.y;
          }
          $t46186 = ($t46185 > 640.);
        }
        $t46187 = ($t46183 && $t46186);
      }
    }
    {
      let $t46190;
      {
        let $t46189;
        {
          const $t46188 = b.vel;
          $t46189 = Arcade$Vec2$length($t46188);
        }
        $t46190 = ($t46189 < 40.);
      }
      return ($t46187 && $t46190);
    }
  }
}
const Spin$Game$resting_in_lane$clo = { _0: ($_, b) => Spin$Game$resting_in_lane(b) };

function Spin$Game$light(m, f) {
  {
    const $t46195 = m.lights;
    {
      const $t46199 = { $: "$Clo_$lam0_Spin_Game_light$0_Spin_Game_light", _0: $lam0_Spin_Game_light$apply$0_Spin_Game_light, _1: f };
      return List$fold_left$List_T_Feature_Float$Float$Fn_Float_T_Feature_Float_Float($t46195, 0., $t46199);
    }
  }
}
const Spin$Game$light$clo = { _0: ($_, m, f) => Spin$Game$light(m, f) };

function Spin$Game$say(m, text, sub, seconds, hot) {
  {
    const $t46200 = ({ text: text, sub: sub, left: seconds, hot: hot });
    {
      const $rc_2508 = ({ ...m, banner: $t46200 });
      return $rc_2508;
    }
  }
}
const Spin$Game$say$clo = { _0: ($_, m, text, sub, seconds, hot) => Spin$Game$say(m, text, sub, seconds, hot) };

function Spin$Game$lit(m, f) {
  {
    const $t46201 = m.lights;
    {
      let $t46204;
      $t46204 = { $: "$Clo_$lam0_Spin_Game_lit$0_Spin_Game_lit", _0: $lam0_Spin_Game_lit$apply$0_Spin_Game_lit, _1: f };
      {
        let others;
        others = List$filter$List_T_Feature_Float$Fn_T_Feature_Float_Bool($t46201, $t46204);
        {
          const $t46205 = { _0: f, _1: 1. };
          {
            const $t46206 = { $: "Cons", _0: $t46205, _1: others };
            {
              const $rc_2509 = ({ ...m, lights: $t46206 });
              return $rc_2509;
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
    const $t46208 = m.lights;
    {
      const $t46213 = { $: "$Clo_$lam0_Spin_Game_fade$0_Spin_Game_fade", _0: $lam0_Spin_Game_fade$apply$0_Spin_Game_fade, _1: dt };
      {
        let dimmer;
        {
          const xs_i12802 = $t46208;
          {
            const f_i12803 = $t46213;
            switch (xs_i12802.$) {
              case "Nil": {
                dimmer = { $: "Nil" };
                break;
              }
              case "Cons": {
                const $f995_i12804 = xs_i12802._0;
                const $f996_i12805 = xs_i12802._1;
                {
                  const t_i12806 = $f996_i12805;
                  {
                    const h_i12807 = $f995_i12804;
                    {
                      let $t993_i12808;
                      $t993_i12808 = f_i12803._0(f_i12803, h_i12807);
                      {
                        const $trmc15_i12809 = { $: "Cons", _0: $t993_i12808, _1: null };
                        List$map$dps$List_T_Feature_Float$Fn_T_Feature_Float_T_Feature_Float$List_T_Feature_Float(t_i12806, f_i12803, $trmc15_i12809);
                        dimmer = $trmc15_i12809;
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
            const $t46215 = { $: "$Clo_$lam1_Spin_Game_fade$1_Spin_Game_fade", _0: $lam1_Spin_Game_fade$apply$1_Spin_Game_fade };
            {
              const glowing = List$filter$List_T_Feature_Float$Fn_T_Feature_Float_Bool(dimmer, $t46215);
              {
                let counted;
                {
                  let $t46217;
                  {
                    const $t46216 = b.left;
                    $t46217 = ($t46216 - dt);
                  }
                  counted = ({ ...b, left: $t46217 });
                }
                {
                  let $t46221;
                  {
                    const $t46218 = m.spinner_turn;
                    {
                      let $t46220;
                      {
                        const $t46219 = m.spinner_rate;
                        $t46220 = ($t46219 * dt);
                      }
                      $t46221 = ($t46218 + $t46220);
                    }
                  }
                  {
                    let $t46226;
                    {
                      const $t46222 = m.spinner_rate;
                      {
                        let $t46225;
                        {
                          let $t46224;
                          {
                            const $t46223 = (2. * dt);
                            $t46224 = (1. - $t46223);
                          }
                          {
                            const $t45787_i5326 = ($t46224 >= 0.);
                            if ($t45787_i5326 === true) {
                              $t46225 = $t46224;
                            } else {
                              $t46225 = 0.;
                            }
                          }
                        }
                        $t46226 = ($t46222 * $t46225);
                      }
                    }
                    {
                      const $rc_2510 = ({ ...m, lights: glowing, banner: counted, spinner_turn: $t46221, spinner_rate: $t46226 });
                      return $rc_2510;
                    }
                  }
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

function Spin$Game$reel_news(acc, e) {
  {
    const $p46294 = acc;
    {
      const m = acc._0;
      {
        const cues = acc._1;
        switch (e.$) {
          case "Loaded": {
            const $f46278 = e._0;
            const $f46279 = e._1;
            {
              const i = $f46279;
              {
                const s = $f46278;
                {
                  let $t46235;
                  {
                    let $t46230;
                    {
                      let $t46227;
                      switch (s.$) {
                        case "Blank": {
                          $t46227 = "";
                          break;
                        }
                        case "Cherry": {
                          $t46227 = "CHERRY";
                          break;
                        }
                        case "Lemon": {
                          $t46227 = "LEMON";
                          break;
                        }
                        case "Bell": {
                          $t46227 = "BELL";
                          break;
                        }
                        case "Bars": {
                          $t46227 = "BAR";
                          break;
                        }
                        case "Seven": {
                          $t46227 = "7";
                          break;
                        }
                        default: {
                          throw new Error("non-exhaustive pattern match");
                          break;
                        }
                      }
                      {
                        let $t46229;
                        {
                          const $t46228 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
                          $t46229 = String($t46228);
                        }
                        {
                          const $rc_2513 = march_string_concat3($t46227, " ON REEL ", $t46229);
                          $t46230 = $rc_2513;
                        }
                      }
                    }
                    {
                      let $t46234;
                      {
                        const $t46231 = (i === 2);
                        if ($t46231 === true) {
                          $t46234 = "the line is judged";
                        } else {
                          {
                            let $t46233;
                            {
                              const $t46232 = ((i + 2) < 4611686018427387904 && (i + 2) >= -4611686018427387904 ? (i + 2) : march_int_ovf((i + 2), 0));
                              $t46233 = String($t46232);
                            }
                            {
                              const $rc_2512 = ("next: reel " + $t46233);
                              $t46234 = $rc_2512;
                            }
                          }
                        }
                      }
                      $t46235 = Spin$Game$say(m, $t46230, $t46234, 1.4, false);
                    }
                  }
                  {
                    let $t46237;
                    {
                      let $t46236;
                      {
                        const $rc_2511 = Spin$Reels$rank(s);
                        $t46236 = $rc_2511;
                      }
                      $t46237 = { $: "CueLoad", _0: $t46236 };
                    }
                    {
                      let $t46238;
                      $t46238 = { $: "Cons", _0: $t46237, _1: cues };
                      {
                        const $rc_2528 = { _0: $t46235, _1: $t46238 };
                        return $rc_2528;
                      }
                    }
                  }
                }
              }
            }
            break;
          }
          case "Banked": {
            const $f46284 = e._0;
            {
              const n = $f46284;
              {
                let $t46242;
                {
                  const $t46239 = (n > 1);
                  if ($t46239 === true) {
                    {
                      let $t46241;
                      {
                        const $t46240 = String(n);
                        {
                          const $rc_2514 = ("SPINS x" + $t46240);
                          $t46241 = $rc_2514;
                        }
                      }
                      $t46242 = Spin$Game$say(m, $t46241, "banked", 1., false);
                    }
                  } else {
                    $t46242 = m;
                  }
                }
                {
                  const $rc_2529 = { _0: $t46242, _1: cues };
                  return $rc_2529;
                }
              }
            }
            break;
          }
          case "Started": {
            {
              const $t46243 = { $: "CueReelStart" };
              {
                let $t46244;
                $t46244 = { $: "Cons", _0: $t46243, _1: cues };
                {
                  const $rc_2530 = { _0: m, _1: $t46244 };
                  return $rc_2530;
                }
              }
            }
            break;
          }
          case "Landed": {
            const $f46285 = e._0;
            {
              const i = $f46285;
              {
                const $t46245 = { $: "CueReelStop", _0: i };
                {
                  let $t46246;
                  $t46246 = { $: "Cons", _0: $t46245, _1: cues };
                  {
                    const $rc_2531 = { _0: m, _1: $t46246 };
                    return $rc_2531;
                  }
                }
              }
            }
            break;
          }
          case "Paid": {
            const $f46286 = e._0;
            const $f46287 = e._1;
            {
              const name = $f46287;
              {
                const n = $f46286;
                {
                  let won;
                  {
                    let $t46248;
                    {
                      const $t46247 = m.credits;
                      $t46248 = (($t46247 + n) < 4611686018427387904 && ($t46247 + n) >= -4611686018427387904 ? ($t46247 + n) : march_int_ovf(($t46247 + n), 0));
                    }
                    {
                      let $t46250;
                      {
                        const $t46249 = m.paid;
                        $t46250 = (($t46249 + n) < 4611686018427387904 && ($t46249 + n) >= -4611686018427387904 ? ($t46249 + n) : march_int_ovf(($t46249 + n), 0));
                      }
                      won = ({ ...m, credits: $t46248, paid: $t46250 });
                    }
                  }
                  {
                    const jackpot = march_string_contains(name, "777");
                    {
                      let owed;
                      {
                        let $t46257;
                        {
                          let $t46256;
                          {
                            let $t46254;
                            {
                              let $t46252;
                              {
                                const $t46251 = m.balls;
                                {  };
                                $t46252 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t46251, 0);
                              }
                              {
                                const $t46253 = m.owed_balls;
                                $t46254 = (($t46252 + $t46253) < 4611686018427387904 && ($t46252 + $t46253) >= -4611686018427387904 ? ($t46252 + $t46253) : march_int_ovf(($t46252 + $t46253), 0));
                              }
                            }
                            $t46256 = ($t46254 < 3);
                          }
                          $t46257 = (jackpot && $t46256);
                        }
                        if ($t46257 === true) {
                          {
                            const $t46258 = won.owed_balls;
                            owed = (($t46258 + 1) < 4611686018427387904 && ($t46258 + 1) >= -4611686018427387904 ? ($t46258 + 1) : march_int_ovf(($t46258 + 1), 0));
                          }
                        } else {
                          owed = won.owed_balls;
                        }
                      }
                      {
                        let shown;
                        {
                          const $t46259 = ({ ...won, owed_balls: owed });
                          {
                            let $t46262;
                            {
                              const $t46260 = String(n);
                              {
                                let $t46261;
                                if (jackpot === true) {
                                  $t46261 = "  MULTIBALL";
                                } else {
                                  $t46261 = "";
                                }
                                {
                                  const $rc_2515 = march_string_concat_n("+", $t46260, " CREDITS", $t46261);
                                  $t46262 = $rc_2515;
                                }
                              }
                            }
                            shown = Spin$Game$say($t46259, name, $t46262, 2.6, true);
                          }
                        }
                        {
                          let $t46263;
                          if (jackpot === true) {
                            $t46263 = { $: "CueJackpot" };
                          } else {
                            $t46263 = { $: "CueWin", _0: n };
                          }
                          {
                            let $t46264;
                            $t46264 = { $: "Cons", _0: $t46263, _1: cues };
                            {
                              const $rc_2517 = { _0: shown, _1: $t46264 };
                              return $rc_2517;
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
          case "Missed": {
            {
              let $t46266;
              $t46266 = Spin$Game$say(m, "NUDGE!", "bumpers roll the reels", 4., false);
              {
                const $t46267 = { $: "CueMiss" };
                {
                  let $t46268;
                  $t46268 = { $: "Cons", _0: $t46267, _1: cues };
                  {
                    const $rc_2533 = { _0: $t46266, _1: $t46268 };
                    return $rc_2533;
                  }
                }
              }
            }
            break;
          }
          case "Nudged": {
            const $f46292 = e._0;
            {
              const $t46269 = { $: "CueNudge" };
              {
                let $t46270;
                $t46270 = { $: "Cons", _0: $t46269, _1: cues };
                {
                  const $rc_2534 = { _0: m, _1: $t46270 };
                  return $rc_2534;
                }
              }
            }
            break;
          }
          case "Held": {
            const $f46293 = e._0;
            {
              const i = $f46293;
              {
                let $t46274;
                {
                  let $t46273;
                  {
                    let $t46272;
                    {
                      const $t46271 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
                      $t46272 = String($t46271);
                    }
                    {
                      const $rc_2518 = ("HOLD " + $t46272);
                      $t46273 = $rc_2518;
                    }
                  }
                  $t46274 = Spin$Game$say(m, $t46273, "for the next spin", 1.2, false);
                }
                {
                  const $t46275 = { $: "CueLane" };
                  {
                    let $t46276;
                    $t46276 = { $: "Cons", _0: $t46275, _1: cues };
                    {
                      const $rc_2535 = { _0: $t46274, _1: $t46276 };
                      return $rc_2535;
                    }
                  }
                }
              }
            }
            break;
          }
          case "Doubled": {
            {
              let $t46277;
              $t46277 = Spin$Game$say(m, "FREE SPIN x2", "all three lanes", 2., true);
              {
                const $rc_2536 = { _0: $t46277, _1: cues };
                return $rc_2536;
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
    const $p46298 = acc;
    {
      const m = acc._0;
      {
        const cues = acc._1;
        {
          const $p46297 = step;
          {
            const b = step._0;
            {
              const evs = step._1;
              {
                let $t46295;
                $t46295 = ({ ...m, bank: b });
                {
                  let $t46296;
                  $t46296 = { _0: $t46295, _1: cues };
                  return List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue(evs, $t46296, Spin$Game$reel_news$clo);
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
    let $p46342;
    $p46342 = acc;
    {
      const m = $p46342._0;
      {
        const cues = $p46342._1;
        switch (h.$) {
          case "Flipped": {
            const $f46335 = h._0;
            {
              const speed = $f46335;
              {
                const $t46299 = (speed > 300.);
                {
                  let $t46301;
                  if ($t46299 === true) {
                    {
                      const $t46300 = { $: "CueThud", _0: speed };
                      $t46301 = { $: "Cons", _0: $t46300, _1: cues };
                    }
                  } else {
                    $t46301 = cues;
                  }
                  {
                    const $rc_2542 = { _0: m, _1: $t46301 };
                    return $rc_2542;
                  }
                }
              }
            }
            break;
          }
          case "Touched": {
            const $f46336 = h._0;
            const $f46337 = h._1;
            {
              const speed = $f46337;
              {
                const f = $f46336;
                switch (f.$) {
                  case "Plain": {
                    {
                      const $t46302 = (speed > 260.);
                      {
                        let $t46304;
                        if ($t46302 === true) {
                          {
                            const $t46303 = { $: "CueThud", _0: speed };
                            $t46304 = { $: "Cons", _0: $t46303, _1: cues };
                          }
                        } else {
                          $t46304 = cues;
                        }
                        {
                          const $rc_2543 = { _0: m, _1: $t46304 };
                          return $rc_2543;
                        }
                      }
                    }
                    break;
                  }
                  case "Bumper": {
                    const $f46332 = f._0;
                    {
                      const i = $f46332;
                      {
                        let $t46305;
                        $t46305 = Spin$Game$lit(m, f);
                        {
                          const $t46306 = { $: "CueBumper" };
                          {
                            let $t46307;
                            $t46307 = { $: "Cons", _0: $t46306, _1: cues };
                            {
                              const $t46308 = { _0: $t46305, _1: $t46307 };
                              {
                                let $t46310;
                                {
                                  const $t46309 = m.bank;
                                  $t46310 = Spin$Reels$nudge($t46309, i);
                                }
                                return Spin$Game$with_bank($t46308, $t46310);
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
                      const $t46311 = (speed > 80.);
                      if ($t46311 === true) {
                        {
                          let $t46312;
                          $t46312 = Spin$Game$lit(m, f);
                          {
                            const $t46313 = { $: "CueSling" };
                            {
                              let $t46314;
                              $t46314 = { $: "Cons", _0: $t46313, _1: cues };
                              {
                                const $rc_2545 = { _0: $t46312, _1: $t46314 };
                                return $rc_2545;
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
                    const $f46333 = f._0;
                    {
                      const s = $f46333;
                      {
                        let $t46318;
                        {
                          const $t46315 = (speed > 60.);
                          {
                            let $t46317;
                            {
                              let $t46316;
                              $t46316 = Spin$Game$light(m, f);
                              $t46317 = ($t46316 < 0.6);
                            }
                            $t46318 = ($t46315 && $t46317);
                          }
                        }
                        if ($t46318 === true) {
                          {
                            let $t46319;
                            $t46319 = Spin$Game$lit(m, f);
                            {
                              let $t46320;
                              $t46320 = { _0: $t46319, _1: cues };
                              {
                                let $t46322;
                                {
                                  const $t46321 = m.bank;
                                  $t46322 = Spin$Reels$load($t46321, s);
                                }
                                return Spin$Game$with_bank($t46320, $t46322);
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
                          const $t46323 = { $: "CueSpinner" };
                          {
                            let $t46324;
                            $t46324 = { $: "Cons", _0: $t46323, _1: cues };
                            {
                              const $t46325 = { _0: spun, _1: $t46324 };
                              {
                                let $t46327;
                                {
                                  const $t46326 = m.bank;
                                  $t46327 = Spin$Reels$bank_spin($t46326);
                                }
                                return Spin$Game$with_bank($t46325, $t46327);
                              }
                            }
                          }
                        }
                      }
                    }
                    break;
                  }
                  case "HoldLane": {
                    const $f46334 = f._0;
                    {
                      const i = $f46334;
                      {
                        let $t46328;
                        $t46328 = Spin$Game$lit(m, f);
                        {
                          let $t46329;
                          $t46329 = { _0: $t46328, _1: cues };
                          {
                            let $t46331;
                            {
                              const $t46330 = m.bank;
                              $t46331 = Spin$Reels$hold($t46330, i);
                            }
                            return Spin$Game$with_bank($t46329, $t46331);
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
        const $t46354 = m.last;
        was = $t46354.launch;
      }
      {
        let $t46361;
        {
          let $t46356;
          {
            let $t46355;
            $t46355 = Spin$Game$waiting(m);
            $t46356 = (held && $t46355);
          }
          {
            let $t46360;
            {
              const $t46357 = (!was);
              {
                let $t46359;
                {
                  const $t46358 = m.pull;
                  $t46359 = ($t46358 > 0.);
                }
                $t46360 = ($t46357 || $t46359);
              }
            }
            $t46361 = ($t46356 && $t46360);
          }
        }
        if ($t46361 === true) {
          {
            let $t46366;
            {
              let $t46365;
              {
                let $t46364;
                {
                  const $t46362 = m.pull;
                  {
                    const $t46363 = (dt * 1.3);
                    $t46364 = ($t46362 + $t46363);
                  }
                }
                {
                  const $t45788_i5333 = ($t46364 < 1.);
                  if ($t45788_i5333 === true) {
                    $t46365 = $t46364;
                  } else {
                    $t46365 = 1.;
                  }
                }
              }
              $t46366 = ({ ...m, pull: $t46365 });
            }
            {
              const $t46367 = { $: "Nil" };
              return { _0: $t46366, _1: $t46367 };
            }
          }
        } else {
          {
            let $t46374;
            {
              let $t46372;
              {
                let $t46369;
                {
                  const $t46368 = (!held);
                  $t46369 = (was && $t46368);
                }
                {
                  let $t46371;
                  {
                    const $t46370 = m.pull;
                    $t46371 = ($t46370 > 0.);
                  }
                  $t46372 = ($t46369 && $t46371);
                }
              }
              {
                let $t46373;
                $t46373 = Spin$Game$waiting(m);
                $t46374 = ($t46372 && $t46373);
              }
            }
            if ($t46374 === true) {
              {
                const $t46375 = m.pull;
                {
                  const m_i12819 = m;
                  {
                    let speed_i12822;
                    {
                      const $t46343_i12821 = (700. * $t46375);
                      speed_i12822 = (1050. + $t46343_i12821);
                    }
                    {
                      const $t46344_i12823 = m.balls;
                      {
                        const $t46349_i12824 = { $: "$Clo_$lam0_Spin_Game_fire$0_Spin_Game_fire", _0: $lam0_Spin_Game_fire$apply$0_Spin_Game_fire, _1: speed_i12822 };
                        {
                          let launched_i12825;
                          {
                            const xs_i14428 = $t46344_i12823;
                            {
                              const f_i14429 = $t46349_i12824;
                              switch (xs_i14428.$) {
                                case "Nil": {
                                  launched_i12825 = { $: "Nil" };
                                  break;
                                }
                                case "Cons": {
                                  const $f995_i14430 = xs_i14428._0;
                                  const $f996_i14431 = xs_i14428._1;
                                  {
                                    const t_i14432 = $f996_i14431;
                                    {
                                      const h_i14433 = $f995_i14430;
                                      {
                                        let $t993_i14434;
                                        $t993_i14434 = f_i14429._0(f_i14429, h_i14433);
                                        {
                                          const $trmc15_i14435 = { $: "Cons", _0: $t993_i14434, _1: null };
                                          List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t_i14432, f_i14429, $trmc15_i14435);
                                          launched_i12825 = $trmc15_i14435;
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
                            const $t46350_i12826 = ({ ...m, balls: launched_i12825, pull: 0. });
                            {
                              const $t46351_i12827 = { $: "CueLaunch" };
                              {
                                const $t46352_i12828 = { $: "Nil" };
                                {
                                  const $t46353_i12829 = { $: "Cons", _0: $t46351_i12827, _1: $t46352_i12828 };
                                  return { _0: $t46350_i12826, _1: $t46353_i12829 };
                                }
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
                let $t46378;
                {
                  let $t46377;
                  {
                    let $t46376;
                    $t46376 = Spin$Game$waiting(m);
                    if ($t46376 === true) {
                      $t46377 = m.pull;
                    } else {
                      $t46377 = 0.;
                    }
                  }
                  $t46378 = ({ ...m, pull: $t46377 });
                }
                {
                  const $t46379 = { $: "Nil" };
                  return { _0: $t46378, _1: $t46379 };
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
      const $t46380 = m.balls;
      {
        const $t46384 = { $: "$Clo_$lam0_Spin_Game_auto_plunge$0_Spin_Game_auto_plunge", _0: $lam0_Spin_Game_auto_plunge$apply$0_Spin_Game_auto_plunge };
        lane_clear = List$all$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46380, $t46384);
      }
    }
    {
      let $t46387;
      {
        let $t46386;
        {
          const $t46385 = m.owed_balls;
          $t46386 = ($t46385 > 0);
        }
        $t46387 = ($t46386 && lane_clear);
      }
      if ($t46387 === true) {
        {
          let ball;
          {
            let $t46389;
            {
              const $t46388 = m.table;
              $t46389 = $t46388.plunger_rest;
            }
            {
              let $t46391;
              {
                const $t46390 = (-1650.);
                $t46391 = ({ x: 0., y: $t46390 });
              }
              ball = ({ pos: $t46389, vel: $t46391 });
            }
          }
          {
            let out;
            {
              let $t46396;
              {
                const $t46392 = m.balls;
                {
                  let $t46393;
                  $t46393 = { $: "Cons", _0: ball, _1: $t46392 };
                  {
                    let $t46395;
                    {
                      const $t46394 = m.owed_balls;
                      $t46395 = (($t46394 - 1) < 4611686018427387904 && ($t46394 - 1) >= -4611686018427387904 ? ($t46394 - 1) : march_int_ovf(($t46394 - 1), 1));
                    }
                    $t46396 = ({ ...m, balls: $t46393, owed_balls: $t46395 });
                  }
                }
              }
              {
                const $t46397 = { $: "CueLaunch" };
                {
                  const $t46398 = { $: "Nil" };
                  {
                    const $t46399 = { $: "Cons", _0: $t46397, _1: $t46398 };
                    out = { _0: $t46396, _1: $t46399 };
                  }
                }
              }
            }
            return out;
          }
        }
      } else {
        {
          const $t46400 = { $: "Nil" };
          return { _0: m, _1: $t46400 };
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
      const $t46401 = (steps <= 0);
      if ($t46401 === true) {
        return { _0: m, _1: hits };
      } else {
        {
          let l;
          {
            let $t46403;
            {
              const $t46402 = m.table;
              $t46403 = $t46402.left;
            }
            {
              const $t46404 = m.left;
              {
                const $t46405 = input.left;
                l = Spin$Physics$turn_flipper($t46403, $t46404, $t46405, 0.0025);
              }
            }
          }
          {
            let r;
            {
              let $t46407;
              {
                const $t46406 = m.table;
                $t46407 = $t46406.right;
              }
              {
                const $t46408 = m.right;
                {
                  const $t46409 = input.right;
                  r = Spin$Physics$turn_flipper($t46407, $t46408, $t46409, 0.0025);
                }
              }
            }
            {
              const $t46410 = m.balls;
              {
                let $t46413;
                $t46413 = { $: "$Clo_$lam0_Spin_Game_step_balls$0_Spin_Game_step_balls", _0: $lam0_Spin_Game_step_balls$apply$0_Spin_Game_step_balls, _1: 0.0025, _2: l, _3: m, _4: r };
                {
                  let moved;
                  {
                    const xs_i12853 = $t46410;
                    {
                      const f_i12854 = $t46413;
                      switch (xs_i12853.$) {
                        case "Nil": {
                          moved = { $: "Nil" };
                          break;
                        }
                        case "Cons": {
                          const $f995_i12855 = xs_i12853._0;
                          const $f996_i12856 = xs_i12853._1;
                          {
                            const t_i12857 = $f996_i12856;
                            {
                              const h_i12858 = $f995_i12855;
                              {
                                let $t993_i12859;
                                $t993_i12859 = f_i12854._0(f_i12854, h_i12858);
                                {
                                  const $trmc15_i12860 = { $: "Cons", _0: $t993_i12859, _1: null };
                                  List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit(t_i12857, f_i12854, $trmc15_i12860);
                                  moved = $trmc15_i12860;
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
                    const $t46416 = { $: "$Clo_$lam1_Spin_Game_step_balls$1_Spin_Game_step_balls", _0: $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls };
                    {
                      let balls;
                      {
                        const xs_i12845 = moved;
                        {
                          const f_i12846 = $t46416;
                          switch (xs_i12845.$) {
                            case "Nil": {
                              balls = { $: "Nil" };
                              break;
                            }
                            case "Cons": {
                              const $f995_i12847 = xs_i12845._0;
                              const $f996_i12848 = xs_i12845._1;
                              {
                                const t_i12849 = $f996_i12848;
                                {
                                  const h_i12850 = $f995_i12847;
                                  {
                                    let $t993_i12851;
                                    $t993_i12851 = f_i12846._0(f_i12846, h_i12850);
                                    {
                                      const $trmc15_i12852 = { $: "Cons", _0: $t993_i12851, _1: null };
                                      List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t_i12849, f_i12846, $trmc15_i12852);
                                      balls = $trmc15_i12852;
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
                        const $t46419 = { $: "$Clo_$lam2_Spin_Game_step_balls$2_Spin_Game_step_balls", _0: $lam2_Spin_Game_step_balls$apply$2_Spin_Game_step_balls };
                        {
                          let $t46420;
                          {
                            const xs_i12837 = moved;
                            {
                              const f_i12838 = $t46419;
                              switch (xs_i12837.$) {
                                case "Nil": {
                                  $t46420 = { $: "Nil" };
                                  break;
                                }
                                case "Cons": {
                                  const $f995_i12839 = xs_i12837._0;
                                  const $f996_i12840 = xs_i12837._1;
                                  {
                                    const t_i12841 = $f996_i12840;
                                    {
                                      const h_i12842 = $f995_i12839;
                                      {
                                        let $t993_i12843;
                                        $t993_i12843 = f_i12838._0(f_i12838, h_i12842);
                                        {
                                          const $trmc15_i12844 = { $: "Cons", _0: $t993_i12843, _1: null };
                                          List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_List_Hit$List_List_Hit(t_i12841, f_i12838, $trmc15_i12844);
                                          $t46420 = $trmc15_i12844;
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
                              const prepend_reversed_i5337 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Hit", _0: prepend_reversed$apply$0_List_concat_List_List_Hit };
                              {
                                const go_i5338 = { $: "$Clo_go$1_List_concat_List_List_Hit", _0: go$apply$1_List_concat_List_List_Hit, _1: prepend_reversed_i5337 };
                                {
                                  const $t1113_i5339 = { $: "Nil" };
                                  new_hits = go$apply$1_List_concat_List_List_Hit(go_i5338, $t46420, $t1113_i5339);
                                }
                              }
                            }
                            {
                              const next = ({ ...m, balls: balls, left: l, right: r });
                              {
                                const $t46421 = ((steps - 1) < 4611686018427387904 && (steps - 1) >= -4611686018427387904 ? (steps - 1) : march_int_ovf((steps - 1), 1));
                                {
                                  let $t46422;
                                  {
                                    const xs_i12830 = hits;
                                    {
                                      const ys_i12831 = new_hits;
                                      switch (xs_i12830.$) {
                                        case "Nil": {
                                          $t46422 = new_hits;
                                          break;
                                        }
                                        case "Cons": {
                                          const $f987_i12832 = xs_i12830._0;
                                          const $f988_i12833 = xs_i12830._1;
                                          {
                                            const t_i12834 = $f988_i12833;
                                            {
                                              const h_i12835 = $f987_i12832;
                                              {
                                                const $trmc11_i12836 = { $: "Cons", _0: h_i12835, _1: null };
                                                List$append$dps$List_Hit$List_Hit$List_Hit(t_i12834, new_hits, $trmc11_i12836);
                                                $t46422 = $trmc11_i12836;
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
                                    $tco_a2 = $t46421;
                                    $tco_a3 = $t46422;
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
      const $t46423 = m.carry;
      total = ($t46423 + dt);
    }
    {
      let steps;
      {
        let $t46425;
        {
          const $t46424 = (total / 0.0025);
          $t46425 = Math.floor($t46424);
        }
        {
          const $t2462_i5345 = ($t46425 < 40);
          if ($t2462_i5345 === true) {
            steps = $t46425;
          } else {
            steps = 40;
          }
        }
      }
      {
        let $p46432;
        {
          const $t46426 = { $: "Nil" };
          $p46432 = Spin$Game$step_balls(m, input, steps, $t46426);
        }
        {
          const moved = $p46432._0;
          {
            const hits = $p46432._1;
            {
              let $t46431;
              {
                let $t46430;
                {
                  let $t46429;
                  {
                    let $t46428;
                    {
                      const $t46427 = steps;
                      $t46428 = ($t46427 * 0.0025);
                    }
                    $t46429 = (total - $t46428);
                  }
                  {
                    const $t45787_i5342 = ($t46429 >= 0.);
                    if ($t45787_i5342 === true) {
                      $t46430 = $t46429;
                    } else {
                      $t46430 = 0.;
                    }
                  }
                }
                $t46431 = ({ ...moved, carry: $t46430 });
              }
              {
                const $rc_2548 = { _0: $t46431, _1: hits };
                return $rc_2548;
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
    const $t46433 = m.balls;
    {
      let $t46439;
      $t46439 = { $: "$Clo_$lam0_Spin_Game_drains$0_Spin_Game_drains", _0: $lam0_Spin_Game_drains$apply$0_Spin_Game_drains, _1: m };
      {
        const kept = List$filter$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46433, $t46439);
        {
          let lost;
          {
            let $t46441;
            {
              const $t46440 = m.balls;
              {  };
              $t46441 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t46440, 0);
            }
            {
              let $t46442;
              {  };
              $t46442 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int(kept, 0);
              lost = (($t46441 - $t46442) < 4611686018427387904 && ($t46441 - $t46442) >= -4611686018427387904 ? ($t46441 - $t46442) : march_int_ovf(($t46441 - $t46442), 1));
            }
          }
          {
            const $t46443 = (lost === 0);
            if ($t46443 === true) {
              {
                const $t46444 = { $: "Nil" };
                return { _0: m, _1: $t46444 };
              }
            } else {
              {
                let $t46449;
                {
                  let $t46446;
                  {
                    let $t46445;
                    {  };
                    $t46445 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int(kept, 0);
                    $t46446 = ($t46445 > 0);
                  }
                  {
                    let $t46448;
                    {
                      const $t46447 = m.owed_balls;
                      $t46448 = ($t46447 > 0);
                    }
                    $t46449 = ($t46446 || $t46448);
                  }
                }
                if ($t46449 === true) {
                  {
                    const $t46450 = ({ ...m, balls: kept });
                    {
                      const $t46451 = { $: "CueDrain" };
                      {
                        const $t46452 = { $: "Nil" };
                        {
                          const $t46453 = { $: "Cons", _0: $t46451, _1: $t46452 };
                          return { _0: $t46450, _1: $t46453 };
                        }
                      }
                    }
                  }
                } else {
                  {
                    let fresh;
                    {
                      let $t46455;
                      {
                        const $t46454 = m.table;
                        $t46455 = Spin$Game$ball_at_plunger($t46454);
                      }
                      {
                        const $t46456 = { $: "Nil" };
                        {
                          const $t46457 = { $: "Cons", _0: $t46455, _1: $t46456 };
                          fresh = ({ ...m, balls: $t46457 });
                        }
                      }
                    }
                    {
                      let $t46459;
                      {
                        const $t46458 = m.save_left;
                        $t46459 = ($t46458 > 0.);
                      }
                      if ($t46459 === true) {
                        {
                          let $t46461;
                          {
                            const $t46460 = ({ ...fresh, save_left: 0. });
                            $t46461 = Spin$Game$say($t46460, "BALL SAVED", "on the house", 1.8, false);
                          }
                          {
                            const $t46462 = { $: "CueSaved" };
                            {
                              const $t46463 = { $: "Nil" };
                              {
                                const $t46464 = { $: "Cons", _0: $t46462, _1: $t46463 };
                                {
                                  const $rc_2553 = { _0: $t46461, _1: $t46464 };
                                  return $rc_2553;
                                }
                              }
                            }
                          }
                        }
                      } else {
                        {
                          let charged;
                          {
                            let $t46467;
                            {
                              const $t46465 = m.credits;
                              $t46467 = (($t46465 - 6) < 4611686018427387904 && ($t46465 - 6) >= -4611686018427387904 ? ($t46465 - 6) : march_int_ovf(($t46465 - 6), 1));
                            }
                            charged = ({ ...fresh, credits: $t46467, save_left: 8. });
                          }
                          {
                            let out;
                            {
                              let $t46472;
                              {
                                let $t46471;
                                {
                                  const $t46470 = String(6);
                                  {
                                    const $rc_2549 = march_string_concat3("-", $t46470, " CREDITS");
                                    $t46471 = $rc_2549;
                                  }
                                }
                                $t46472 = Spin$Game$say(charged, "DRAIN", $t46471, 1.8, false);
                              }
                              {
                                const $t46473 = { $: "CueDrain" };
                                {
                                  const $t46474 = { $: "Nil" };
                                  {
                                    const $t46475 = { $: "Cons", _0: $t46473, _1: $t46474 };
                                    out = { _0: $t46472, _1: $t46475 };
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
    let $t46476;
    {
      const m_i12861 = m;
      {
        const $t46191_i12862 = m.balls;
        {
          const $t46194_i12863 = { $: "$Clo_$lam0_Spin_Game_in_play$0_Spin_Game_in_play", _0: $lam0_Spin_Game_in_play$apply$0_Spin_Game_in_play };
          $t46476 = List$any$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46191_i12862, $t46194_i12863);
        }
      }
    }
    if ($t46476 === true) {
      {
        let every;
        {
          const $t46477 = m.alive;
          {
            let $t46154_i5357;
            {
              let $t46153_i5356;
              {
                let $t46152_i5355;
                {
                  const $t46151_i5354 = ($t46477 * 0.00385);
                  $t46152_i5355 = (0. - $t46151_i5354);
                }
                $t46153_i5356 = Math.exp($t46152_i5355);
              }
              $t46154_i5357 = (2.4 * $t46153_i5356);
            }
            {
              const $t45787_i14219 = ($t46154_i5357 >= 0.05);
              if ($t45787_i14219 === true) {
                every = $t46154_i5357;
              } else {
                every = 0.05;
              }
            }
          }
        }
        {
          let clock;
          {
            const $t46478 = m.burn_clock;
            clock = ($t46478 + dt);
          }
          {
            let saving;
            {
              let $t46481;
              {
                let $t46480;
                {
                  const $t46479 = m.balls;
                  {  };
                  $t46480 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t46479, 0);
                }
                $t46481 = ($t46480 === 1);
              }
              if ($t46481 === true) {
                {
                  const $t46482 = m.save_left;
                  saving = ($t46482 - dt);
                }
              } else {
                saving = m.save_left;
              }
            }
            {
              let ticking;
              {
                let $t46484;
                {
                  const $t46483 = m.alive;
                  $t46484 = ($t46483 + dt);
                }
                {
                  let $t46485;
                  {
                    const $t45787_i5351 = (saving >= 0.);
                    if ($t45787_i5351 === true) {
                      $t46485 = saving;
                    } else {
                      $t46485 = 0.;
                    }
                  }
                  ticking = ({ ...m, alive: $t46484, save_left: $t46485 });
                }
              }
              {
                const $t46486 = (clock >= every);
                if ($t46486 === true) {
                  {
                    let c;
                    {
                      const $t46487 = m.credits;
                      c = (($t46487 - 1) < 4611686018427387904 && ($t46487 - 1) >= -4611686018427387904 ? ($t46487 - 1) : march_int_ovf(($t46487 - 1), 1));
                    }
                    {
                      let $t46489;
                      {
                        const $t46488 = (clock - every);
                        $t46489 = ({ ...ticking, burn_clock: $t46488, credits: c });
                      }
                      {
                        const $t46490 = { $: "CueBurn", _0: c };
                        {
                          const $t46491 = { $: "Nil" };
                          {
                            const $t46492 = { $: "Cons", _0: $t46490, _1: $t46491 };
                            {
                              const $rc_2557 = { _0: $t46489, _1: $t46492 };
                              return $rc_2557;
                            }
                          }
                        }
                      }
                    }
                  }
                } else {
                  {
                    const $t46493 = ({ ...ticking, burn_clock: clock });
                    {
                      const $t46494 = { $: "Nil" };
                      {
                        const $rc_2556 = { _0: $t46493, _1: $t46494 };
                        return $rc_2556;
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
        const $t46495 = { $: "Nil" };
        return { _0: m, _1: $t46495 };
      }
    }
  }
}
const Spin$Game$burn$clo = { _0: ($_, m, dt) => Spin$Game$burn(m, dt) };

function Spin$Game$bust(m) {
  {
    let $t46497;
    {
      const $t46496 = m.credits;
      $t46497 = ($t46496 <= 0);
    }
    if ($t46497 === true) {
      {
        let best;
        {
          const $t46498 = m.best;
          {
            const $t46499 = m.paid;
            {
              const $t2463_i5360 = ($t46498 > $t46499);
              if ($t2463_i5360 === true) {
                best = $t46498;
              } else {
                best = $t46499;
              }
            }
          }
        }
        {
          let over;
          {
            const $t46500 = { $: "Busted" };
            {
              const $t46501 = { $: "Nil" };
              over = ({ ...m, mode: $t46500, credits: 0, best: best, balls: $t46501, owed_balls: 0 });
            }
          }
          {
            let out;
            {
              let $t46505;
              {
                let $t46504;
                {
                  let $t46503;
                  {
                    const $t46502 = m.paid;
                    $t46503 = String($t46502);
                  }
                  {
                    const $rc_2558 = ("the reels paid " + $t46503);
                    $t46504 = $rc_2558;
                  }
                }
                $t46505 = Spin$Game$say(over, "BUSTED", $t46504, 1000000., true);
              }
              {
                const $t46506 = { $: "CueBust" };
                {
                  const $t46507 = { $: "CueStore", _0: best };
                  {
                    const $t46508 = { $: "Nil" };
                    {
                      const $t46509 = { $: "Cons", _0: $t46507, _1: $t46508 };
                      {
                        const $t46510 = { $: "Cons", _0: $t46506, _1: $t46509 };
                        out = { _0: $t46505, _1: $t46510 };
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
        const $t46511 = { $: "Nil" };
        return { _0: m, _1: $t46511 };
      }
    }
  }
}
const Spin$Game$bust$clo = { _0: ($_, m) => Spin$Game$bust(m) };

function Spin$Game$then_do(acc, f) {
  {
    const $p46514 = acc;
    {
      const m = acc._0;
      {
        const cues = acc._1;
        {
          let $p46513;
          $p46513 = f._0(f, m);
          {
            const n = $p46513._0;
            {
              const more = $p46513._1;
              {
                let $t46512;
                {
                  const xs_i12864 = cues;
                  {
                    const ys_i12865 = more;
                    switch (xs_i12864.$) {
                      case "Nil": {
                        $t46512 = more;
                        break;
                      }
                      case "Cons": {
                        const $f987_i12866 = xs_i12864._0;
                        const $f988_i12867 = xs_i12864._1;
                        {
                          const t_i12868 = $f988_i12867;
                          {
                            const h_i12869 = $f987_i12866;
                            {
                              const $trmc11_i12870 = { $: "Cons", _0: h_i12869, _1: null };
                              List$append$dps$List_Cue$List_Cue$List_Cue(t_i12868, more, $trmc11_i12870);
                              $t46512 = $trmc11_i12870;
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
                  const $rc_2560 = { _0: n, _1: $t46512 };
                  return $rc_2560;
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
    let $t46525;
    {
      let $t46519;
      {
        const $t46515 = input.left;
        {
          let $t46518;
          {
            let $t46517;
            {
              const $t46516 = m.last;
              $t46517 = $t46516.left;
            }
            $t46518 = (!$t46517);
          }
          $t46519 = ($t46515 && $t46518);
        }
      }
      {
        let $t46524;
        {
          const $t46520 = input.right;
          {
            let $t46523;
            {
              let $t46522;
              {
                const $t46521 = m.last;
                $t46522 = $t46521.right;
              }
              $t46523 = (!$t46522);
            }
            $t46524 = ($t46520 && $t46523);
          }
        }
        $t46525 = ($t46519 || $t46524);
      }
    }
    {
      let flips;
      if ($t46525 === true) {
        {
          const $t46526 = { $: "CueFlip" };
          {
            const $t46527 = { $: "Nil" };
            flips = { $: "Cons", _0: $t46526, _1: $t46527 };
          }
        }
      } else {
        flips = { $: "Nil" };
      }
      {
        let $p46544;
        $p46544 = Spin$Game$plunge(m, input, dt);
        {
          const pulled = $p46544._0;
          {
            const c1 = $p46544._1;
            {
              let $p46543;
              $p46543 = Spin$Game$auto_plunge(pulled);
              {
                const shot = $p46543._0;
                {
                  const c2 = $p46543._1;
                  {
                    let $p46542;
                    $p46542 = Spin$Game$physics(shot, input, dt);
                    {
                      const moved = $p46542._0;
                      {
                        const hits = $p46542._1;
                        {
                          let touched;
                          {
                            const $t46528 = { $: "Nil" };
                            {
                              let $t46529;
                              $t46529 = { $: "Cons", _0: c2, _1: $t46528 };
                              {
                                let $t46530;
                                $t46530 = { $: "Cons", _0: c1, _1: $t46529 };
                                {
                                  const $t46531 = { $: "Cons", _0: flips, _1: $t46530 };
                                  {
                                    let $t46532;
                                    {
                                      const prepend_reversed_i5362 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Cue", _0: prepend_reversed$apply$0_List_concat_List_List_Cue };
                                      {
                                        const go_i5363 = { $: "$Clo_go$1_List_concat_List_List_Cue", _0: go$apply$1_List_concat_List_List_Cue, _1: prepend_reversed_i5362 };
                                        {
                                          const $t1113_i5364 = { $: "Nil" };
                                          $t46532 = go$apply$1_List_concat_List_List_Cue(go_i5363, $t46531, $t1113_i5364);
                                        }
                                      }
                                    }
                                    {
                                      let $t46533;
                                      $t46533 = { _0: moved, _1: $t46532 };
                                      touched = List$fold_left$List_Hit$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_Hit_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue(hits, $t46533, Spin$Game$touch$clo);
                                    }
                                  }
                                }
                              }
                            }
                          }
                          {
                            const $p46541 = touched;
                            {
                              const m1 = touched._0;
                              {
                                const c3 = touched._1;
                                {
                                  let $p46540;
                                  {
                                    const $t46534 = m1.bank;
                                    {
                                      const $t46535 = m1.rng;
                                      $p46540 = Spin$Reels$tick($t46534, $t46535, dt);
                                    }
                                  }
                                  {
                                    const bank = $p46540._0;
                                    {
                                      const rng = $p46540._1;
                                      {
                                        const evs = $p46540._2;
                                        {
                                          let reeled;
                                          {
                                            let $t46536;
                                            $t46536 = ({ ...m1, rng: rng, bank: bank });
                                            {
                                              let $t46537;
                                              $t46537 = { _0: $t46536, _1: c3 };
                                              reeled = List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue(evs, $t46537, Spin$Game$reel_news$clo);
                                            }
                                          }
                                          {
                                            const drained = Spin$Game$then_do(reeled, Spin$Game$drains$clo);
                                            {
                                              let burned;
                                              {
                                                const $t46539 = { $: "$Clo_$lam0_Spin_Game_play$0_Spin_Game_play", _0: $lam0_Spin_Game_play$apply$0_Spin_Game_play, _1: dt };
                                                burned = Spin$Game$then_do(drained, $t46539);
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
      let $t45789_i5368;
      {
        const $t45787_i14226 = (0. >= dt0);
        if ($t45787_i14226 === true) {
          $t45789_i5368 = 0.;
        } else {
          $t45789_i5368 = dt0;
        }
      }
      {
        const $t45788_i14223 = (0.05 < $t45789_i5368);
        if ($t45788_i14223 === true) {
          dt = 0.05;
        } else {
          dt = $t45789_i5368;
        }
      }
    }
    {
      let dimmed;
      dimmed = Spin$Game$fade(m, dt);
      {
        let faded;
        {
          let $t46546;
          {
            const $t46545 = m.clock;
            $t46546 = ($t46545 + dt);
          }
          faded = ({ ...dimmed, clock: $t46546 });
        }
        {
          let pressed_start;
          {
            let $t46551;
            {
              const $t46547 = input.start;
              {
                let $t46550;
                {
                  let $t46549;
                  {
                    const $t46548 = m.last;
                    $t46549 = $t46548.start;
                  }
                  $t46550 = (!$t46549);
                }
                $t46551 = ($t46547 && $t46550);
              }
            }
            {
              let $t46556;
              {
                const $t46552 = input.launch;
                {
                  let $t46555;
                  {
                    let $t46554;
                    {
                      const $t46553 = m.last;
                      $t46554 = $t46553.launch;
                    }
                    $t46555 = (!$t46554);
                  }
                  $t46556 = ($t46552 && $t46555);
                }
              }
              pressed_start = ($t46551 || $t46556);
            }
          }
          {
            let $p46573;
            {
              const $t46557 = faded.mode;
              switch ($t46557.$) {
                case "Playing": {
                  $p46573 = Spin$Game$play(faded, input, dt);
                  break;
                }
                case "Attract": {
                  if (pressed_start === true) {
                    {
                      const $t46558 = Spin$Game$new_game(faded);
                      {
                        const $t46559 = { $: "CueStart" };
                        {
                          const $t46560 = { $: "Nil" };
                          {
                            const $t46561 = { $: "Cons", _0: $t46559, _1: $t46560 };
                            $p46573 = { _0: $t46558, _1: $t46561 };
                          }
                        }
                      }
                    }
                  } else {
                    {
                      const $t46562 = { $: "Nil" };
                      $p46573 = { _0: faded, _1: $t46562 };
                    }
                  }
                  break;
                }
                case "Busted": {
                  {
                    let $t46566;
                    {
                      let $t46565;
                      {
                        let $t46564;
                        {
                          const $t46563 = faded.banner;
                          $t46564 = $t46563.left;
                        }
                        $t46565 = ($t46564 < 999998.);
                      }
                      $t46566 = (pressed_start && $t46565);
                    }
                    if ($t46566 === true) {
                      {
                        const $t46567 = Spin$Game$new_game(faded);
                        {
                          const $t46568 = { $: "CueStart" };
                          {
                            const $t46569 = { $: "Nil" };
                            {
                              const $t46570 = { $: "Cons", _0: $t46568, _1: $t46569 };
                              $p46573 = { _0: $t46567, _1: $t46570 };
                            }
                          }
                        }
                      }
                    } else {
                      {
                        const $t46571 = { $: "Nil" };
                        $p46573 = { _0: faded, _1: $t46571 };
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
              const next = $p46573._0;
              {
                const cues = $p46573._1;
                {
                  let $t46572;
                  $t46572 = ({ ...next, last: input });
                  {
                    const $rc_2564 = { _0: $t46572, _1: cues };
                    return $rc_2564;
                  }
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
    const $t46574 = spec.rest;
    return ({ angle: $t46574, omega: 0. });
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
          const $t46575 = f.angle;
          gap = (target - $t46575);
        }
        {
          const most = (rate * h);
          {
            let moved;
            {
              const $t46576 = (-most);
              {
                let $t45789_i5372;
                {
                  const $t45787_i14232 = ($t46576 >= gap);
                  if ($t45787_i14232 === true) {
                    $t45789_i5372 = $t46576;
                  } else {
                    $t45789_i5372 = gap;
                  }
                }
                {
                  const $t45788_i14229 = (most < $t45789_i5372);
                  if ($t45788_i14229 === true) {
                    moved = most;
                  } else {
                    moved = $t45789_i5372;
                  }
                }
              }
            }
            {
              let $t46578;
              {
                const $t46577 = f.angle;
                $t46578 = ($t46577 + moved);
              }
              {
                const $t46579 = (moved / h);
                return ({ angle: $t46578, omega: $t46579 });
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
        const $t46580 = (l2 > 0.);
        if ($t46580 === true) {
          {
            let $t46585;
            {
              let $t46584;
              {
                let $t46583;
                {
                  let $t46582;
                  {
                    let $t46581;
                    $t46581 = Arcade$Vec2$sub(p, a);
                    $t46582 = Arcade$Vec2$dot($t46581, ab);
                  }
                  $t46583 = ($t46582 / l2);
                }
                {
                  let $t45789_i5376;
                  {
                    const $t45787_i14238 = (0. >= $t46583);
                    if ($t45787_i14238 === true) {
                      $t45789_i5376 = 0.;
                    } else {
                      $t45789_i5376 = $t46583;
                    }
                  }
                  {
                    const $t45788_i14235 = (1. < $t45789_i5376);
                    if ($t45788_i14235 === true) {
                      $t46584 = 1.;
                    } else {
                      $t46584 = $t45789_i5376;
                    }
                  }
                }
              }
              $t46585 = Arcade$Vec2$scale(ab, $t46584);
            }
            return Arcade$Vec2$add(a, $t46585);
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
      const $t46586 = b.pos;
      d = Arcade$Vec2$sub($t46586, q);
    }
    {
      let dist;
      dist = Arcade$Vec2$length(d);
      {
        let $t46589;
        {
          const $t46587 = (dist >= reach);
          {
            const $t46588 = (dist === 0.);
            $t46589 = ($t46587 || $t46588);
          }
        }
        if ($t46589 === true) {
          return { $: "None" };
        } else {
          {
            let n;
            {
              const $t46590 = (1. / dist);
              n = Arcade$Vec2$scale(d, $t46590);
            }
            {
              let pos;
              {
                let $t46591;
                $t46591 = Arcade$Vec2$scale(n, reach);
                pos = Arcade$Vec2$add(q, $t46591);
              }
              {
                let rel;
                {
                  const $t46592 = b.vel;
                  rel = Arcade$Vec2$sub($t46592, u);
                }
                {
                  let vn;
                  vn = Arcade$Vec2$dot(rel, n);
                  {
                    const $t46593 = (vn < 0.);
                    if ($t46593 === true) {
                      {
                        let $t46599;
                        {
                          let $t46598;
                          {
                            let $t46597;
                            {
                              let $t46596;
                              {
                                let $t46595;
                                {
                                  const $t46594 = (1. + e);
                                  $t46595 = ($t46594 * vn);
                                }
                                $t46596 = Arcade$Vec2$scale(n, $t46595);
                              }
                              $t46597 = Arcade$Vec2$sub(rel, $t46596);
                            }
                            $t46598 = Arcade$Vec2$add($t46597, u);
                          }
                          $t46599 = ({ pos: pos, vel: $t46598 });
                        }
                        {
                          const $t46600 = (-vn);
                          {
                            const $t46601 = { _0: $t46599, _1: n, _2: $t46600 };
                            return { $: "Some", _0: $t46601 };
                          }
                        }
                      }
                    } else {
                      {
                        let $t46603;
                        {
                          const $t46602 = b.vel;
                          $t46603 = ({ pos: pos, vel: $t46602 });
                        }
                        {
                          const $t46604 = { _0: $t46603, _1: n, _2: 0. };
                          return { $: "Some", _0: $t46604 };
                        }
                      }
                    }
                  }
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

function Spin$Physics$side(o, s, t) {
  {
    let $t46617;
    {
      let $t46613;
      {
        const $t46611 = s.x;
        {
          const $t46612 = o.x;
          $t46613 = ($t46611 - $t46612);
        }
      }
      {
        let $t46616;
        {
          const $t46614 = t.y;
          {
            const $t46615 = o.y;
            $t46616 = ($t46614 - $t46615);
          }
        }
        $t46617 = ($t46613 * $t46616);
      }
    }
    {
      let $t46624;
      {
        let $t46620;
        {
          const $t46618 = s.y;
          {
            const $t46619 = o.y;
            $t46620 = ($t46618 - $t46619);
          }
        }
        {
          let $t46623;
          {
            const $t46621 = t.x;
            {
              const $t46622 = o.x;
              $t46623 = ($t46621 - $t46622);
            }
          }
          $t46624 = ($t46620 * $t46623);
        }
      }
      return ($t46617 - $t46624);
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
            let $t46631;
            {
              let $t46627;
              {
                const $t46625 = (d1 > 0.);
                {
                  const $t46626 = (d2 <= 0.);
                  $t46627 = ($t46625 && $t46626);
                }
              }
              {
                let $t46630;
                {
                  const $t46628 = (d1 <= 0.);
                  {
                    const $t46629 = (d2 > 0.);
                    $t46630 = ($t46628 && $t46629);
                  }
                }
                $t46631 = ($t46627 || $t46630);
              }
            }
            {
              let $t46638;
              {
                let $t46634;
                {
                  const $t46632 = (d3 > 0.);
                  {
                    const $t46633 = (d4 <= 0.);
                    $t46634 = ($t46632 && $t46633);
                  }
                }
                {
                  let $t46637;
                  {
                    const $t46635 = (d3 <= 0.);
                    {
                      const $t46636 = (d4 > 0.);
                      $t46637 = ($t46635 && $t46636);
                    }
                  }
                  $t46638 = ($t46634 || $t46637);
                }
              }
              return ($t46631 && $t46638);
            }
          }
        }
      }
    }
  }
}
const Spin$Physics$crosses$clo = { _0: ($_, p, q, a, b) => Spin$Physics$crosses(p, q, a, b) };

function Spin$Physics$against(r, before, acc, part) {
  {
    let $p46833;
    $p46833 = acc;
    {
      const b = $p46833._0;
      {
        const hits = $p46833._1;
        switch (part.$) {
          case "Wall": {
            const $f46756 = part._0;
            const $f46757 = part._1;
            const $f46758 = part._2;
            {
              const e = $f46758;
              {
                const c = $f46757;
                {
                  const a = $f46756;
                  {
                    let $t46642;
                    {
                      let $t46640;
                      {
                        const $t46639 = b.pos;
                        $t46640 = Spin$Physics$closest(a, c, $t46639);
                      }
                      {
                        const $t46641 = ({ x: 0., y: 0. });
                        $t46642 = Spin$Physics$contact(b, $t46640, r, e, $t46641);
                      }
                    }
                    switch ($t46642.$) {
                      case "Some": {
                        const $f46646 = $t46642._0;
                        const $f46647 = $f46646._0;
                        const $f46648 = $f46646._1;
                        const $f46649 = $f46646._2;
                        {
                          const speed = $f46649;
                          {
                            const nb = $f46647;
                            {
                              let $t46644;
                              {
                                const $t46643 = { $: "Plain" };
                                $t46644 = { $: "Touched", _0: $t46643, _1: speed };
                              }
                              {
                                let $t46645;
                                $t46645 = { $: "Cons", _0: $t46644, _1: hits };
                                {
                                  const $rc_2585 = { _0: nb, _1: $t46645 };
                                  return $rc_2585;
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
            const $f46767 = part._0;
            const $f46768 = part._1;
            const $f46769 = part._2;
            {
              const e = $f46769;
              {
                const pr = $f46768;
                {
                  const c = $f46767;
                  {
                    let $t46660;
                    {
                      const $t46658 = (r + pr);
                      {
                        const $t46659 = ({ x: 0., y: 0. });
                        $t46660 = Spin$Physics$contact(b, c, $t46658, e, $t46659);
                      }
                    }
                    switch ($t46660.$) {
                      case "Some": {
                        const $f46664 = $t46660._0;
                        const $f46665 = $f46664._0;
                        const $f46666 = $f46664._1;
                        const $f46667 = $f46664._2;
                        {
                          const speed = $f46667;
                          {
                            const nb = $f46665;
                            {
                              let $t46662;
                              {
                                const $t46661 = { $: "Plain" };
                                $t46662 = { $: "Touched", _0: $t46661, _1: speed };
                              }
                              {
                                let $t46663;
                                $t46663 = { $: "Cons", _0: $t46662, _1: hits };
                                {
                                  const $rc_2587 = { _0: nb, _1: $t46663 };
                                  return $rc_2587;
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
            const $f46778 = part._0;
            const $f46779 = part._1;
            const $f46780 = part._2;
            {
              const f = $f46780;
              {
                const kr = $f46779;
                {
                  const c = $f46778;
                  {
                    let $t46678;
                    {
                      const $t46676 = (r + kr);
                      {
                        const $t46677 = ({ x: 0., y: 0. });
                        $t46678 = Spin$Physics$contact(b, c, $t46676, 0.6, $t46677);
                      }
                    }
                    switch ($t46678.$) {
                      case "Some": {
                        const $f46683 = $t46678._0;
                        const $f46684 = $f46683._0;
                        const $f46685 = $f46683._1;
                        const $f46686 = $f46683._2;
                        {
                          const speed = $f46686;
                          {
                            const n = $f46685;
                            {
                              const nb = $f46684;
                              {
                                let $t46680;
                                {
                                  const b_i12871 = nb;
                                  {
                                    const n_i12872 = n;
                                    {
                                      let vn_i12875;
                                      {
                                        const $t46605_i12874 = nb.vel;
                                        vn_i12875 = Arcade$Vec2$dot($t46605_i12874, n);
                                      }
                                      {
                                        const $t46606_i12876 = (vn_i12875 < 620.);
                                        if ($t46606_i12876 === true) {
                                          {
                                            let $t46610_i12880;
                                            {
                                              const $t46607_i12877 = nb.vel;
                                              {
                                                let $t46609_i12879;
                                                {
                                                  const $t46608_i12878 = (620. - vn_i12875);
                                                  $t46609_i12879 = Arcade$Vec2$scale(n, $t46608_i12878);
                                                }
                                                $t46610_i12880 = Arcade$Vec2$add($t46607_i12877, $t46609_i12879);
                                              }
                                            }
                                            {
                                              const $rc_2567_i12881 = ({ ...nb, vel: $t46610_i12880 });
                                              $t46680 = $rc_2567_i12881;
                                            }
                                          }
                                        } else {
                                          $t46680 = nb;
                                        }
                                      }
                                    }
                                  }
                                }
                                {
                                  const $t46681 = { $: "Touched", _0: f, _1: speed };
                                  {
                                    let $t46682;
                                    $t46682 = { $: "Cons", _0: $t46681, _1: hits };
                                    {
                                      const $rc_2589 = { _0: $t46680, _1: $t46682 };
                                      return $rc_2589;
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
          case "Face": {
            const $f46789 = part._0;
            const $f46790 = part._1;
            const $f46791 = part._2;
            const $f46792 = part._3;
            {
              const f = $f46792;
              {
                const kick = $f46791;
                {
                  const c = $f46790;
                  {
                    const a = $f46789;
                    {
                      let e;
                      {
                        const $t46695 = (kick > 0.);
                        if ($t46695 === true) {
                          e = 0.4;
                        } else {
                          e = 0.55;
                        }
                      }
                      {
                        let $t46699;
                        {
                          let $t46697;
                          {
                            const $t46696 = b.pos;
                            $t46697 = Spin$Physics$closest(a, c, $t46696);
                          }
                          {
                            const $t46698 = ({ x: 0., y: 0. });
                            $t46699 = Spin$Physics$contact(b, $t46697, r, e, $t46698);
                          }
                        }
                        switch ($t46699.$) {
                          case "Some": {
                            const $f46708 = $t46699._0;
                            const $f46709 = $f46708._0;
                            const $f46710 = $f46708._1;
                            const $f46711 = $f46708._2;
                            {
                              const speed = $f46711;
                              {
                                const n = $f46710;
                                {
                                  const nb = $f46709;
                                  {
                                    let thrown;
                                    {
                                      let $t46702;
                                      {
                                        const $t46700 = (kick > 0.);
                                        {
                                          const $t46701 = (speed > 80.);
                                          $t46702 = ($t46700 && $t46701);
                                        }
                                      }
                                      if ($t46702 === true) {
                                        {
                                          let $t46705;
                                          {
                                            const $t46703 = nb.vel;
                                            {
                                              const $t46704 = Arcade$Vec2$scale(n, kick);
                                              $t46705 = Arcade$Vec2$add($t46703, $t46704);
                                            }
                                          }
                                          {
                                            const $rc_2569 = ({ ...nb, vel: $t46705 });
                                            thrown = $rc_2569;
                                          }
                                        }
                                      } else {
                                        thrown = nb;
                                      }
                                    }
                                    {
                                      const $t46706 = { $: "Touched", _0: f, _1: speed };
                                      {
                                        let $t46707;
                                        $t46707 = { $: "Cons", _0: $t46706, _1: hits };
                                        {
                                          const $rc_2591 = { _0: thrown, _1: $t46707 };
                                          return $rc_2591;
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
            const $f46805 = part._0;
            const $f46806 = part._1;
            {
              const c = $f46806;
              {
                const a = $f46805;
                {
                  let $t46722;
                  {
                    let $t46721;
                    {
                      const $t46720 = b.vel;
                      $t46721 = $t46720.y;
                    }
                    $t46722 = ($t46721 > 0.);
                  }
                  if ($t46722 === true) {
                    {
                      let $t46726;
                      {
                        let $t46724;
                        {
                          const $t46723 = b.pos;
                          $t46724 = Spin$Physics$closest(a, c, $t46723);
                        }
                        {
                          const $t46725 = ({ x: 0., y: 0. });
                          $t46726 = Spin$Physics$contact(b, $t46724, r, 0.3, $t46725);
                        }
                      }
                      switch ($t46726.$) {
                        case "Some": {
                          const $f46730 = $t46726._0;
                          const $f46731 = $f46730._0;
                          const $f46732 = $f46730._1;
                          const $f46733 = $f46730._2;
                          {
                            const speed = $f46733;
                            {
                              const nb = $f46731;
                              {
                                let $t46728;
                                {
                                  const $t46727 = { $: "Plain" };
                                  $t46728 = { $: "Touched", _0: $t46727, _1: speed };
                                }
                                {
                                  let $t46729;
                                  $t46729 = { $: "Cons", _0: $t46728, _1: hits };
                                  {
                                    const $rc_2594 = { _0: nb, _1: $t46729 };
                                    return $rc_2594;
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
            const $f46811 = part._0;
            const $f46812 = part._1;
            const $f46813 = part._2;
            {
              const f = $f46813;
              {
                const sr = $f46812;
                {
                  const c = $f46811;
                  {
                    let $t46749;
                    {
                      let $t46745;
                      {
                        let $t46744;
                        {
                          let $t46743;
                          {
                            const $t46742 = b.pos;
                            $t46743 = Arcade$Vec2$sub($t46742, c);
                          }
                          $t46744 = Arcade$Vec2$length($t46743);
                        }
                        $t46745 = ($t46744 < sr);
                      }
                      {
                        let $t46748;
                        {
                          let $t46747;
                          {
                            const $t46746 = Arcade$Vec2$sub(before, c);
                            $t46747 = Arcade$Vec2$length($t46746);
                          }
                          $t46748 = ($t46747 >= sr);
                        }
                        $t46749 = ($t46745 && $t46748);
                      }
                    }
                    if ($t46749 === true) {
                      {
                        const $t46750 = { $: "Touched", _0: f, _1: 0. };
                        {
                          let $t46751;
                          $t46751 = { $: "Cons", _0: $t46750, _1: hits };
                          {
                            const $rc_2597 = { _0: b, _1: $t46751 };
                            return $rc_2597;
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
            const $f46822 = part._0;
            const $f46823 = part._1;
            const $f46824 = part._2;
            {
              const f = $f46824;
              {
                const c = $f46823;
                {
                  const a = $f46822;
                  {
                    let $t46753;
                    {
                      const $t46752 = b.pos;
                      $t46753 = Spin$Physics$crosses(before, $t46752, a, c);
                    }
                    if ($t46753 === true) {
                      {
                        const $t46754 = { $: "Touched", _0: f, _1: 0. };
                        {
                          let $t46755;
                          $t46755 = { $: "Cons", _0: $t46754, _1: hits };
                          {
                            const $rc_2599 = { _0: b, _1: $t46755 };
                            return $rc_2599;
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
const Spin$Physics$against$clo = { _0: ($_, r, before, acc, part) => Spin$Physics$against(r, before, acc, part) };

function Spin$Physics$against_flipper(r, spec, f, acc) {
  {
    let $p46863;
    $p46863 = acc;
    {
      const b = $p46863._0;
      {
        const hits = $p46863._1;
        {
          let q;
          {
            const $t46834 = spec.pivot;
            {
              let $t46836;
              {
                const $t46835 = f.angle;
                $t46836 = Spin$Table$tip(spec, $t46835);
              }
              {
                const $t46837 = b.pos;
                q = Spin$Physics$closest($t46834, $t46836, $t46837);
              }
            }
          }
          {
            let arm;
            {
              const $t46838 = spec.pivot;
              arm = Arcade$Vec2$sub(q, $t46838);
            }
            {
              let u;
              {
                let $t46842;
                {
                  let $t46840;
                  {
                    const $t46839 = f.omega;
                    $t46840 = (-$t46839);
                  }
                  {
                    const $t46841 = arm.y;
                    $t46842 = ($t46840 * $t46841);
                  }
                }
                {
                  let $t46845;
                  {
                    const $t46843 = f.omega;
                    {
                      const $t46844 = arm.x;
                      $t46845 = ($t46843 * $t46844);
                    }
                  }
                  u = ({ x: $t46842, y: $t46845 });
                }
              }
              {
                let $t46848;
                {
                  let $t46847;
                  {
                    const $t46846 = spec.radius;
                    $t46847 = (r + $t46846);
                  }
                  $t46848 = Spin$Physics$contact(b, q, $t46847, 0.3, u);
                }
                switch ($t46848.$) {
                  case "Some": {
                    const $f46851 = $t46848._0;
                    const $f46852 = $f46851._0;
                    const $f46853 = $f46851._1;
                    const $f46854 = $f46851._2;
                    {
                      const speed = $f46854;
                      {
                        const nb = $f46852;
                        {
                          const $t46849 = { $: "Flipped", _0: speed };
                          {
                            let $t46850;
                            $t46850 = { $: "Cons", _0: $t46849, _1: hits };
                            {
                              const $rc_2602 = { _0: nb, _1: $t46850 };
                              return $rc_2602;
                            }
                          }
                        }
                      }
                    }
                    break;
                  }
                  case "None": {
                    {
                      let $rc_2603;
                      $rc_2603 = acc;
                      return $rc_2603;
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

function Spin$Physics$step_ball(t, left, right, h, b) {
  {
    let vel;
    {
      let $t46872;
      {
        const $t46868 = b.vel;
        {
          let $t46871;
          {
            let $t46870;
            {
              const $t46869 = t.gravity;
              $t46870 = ($t46869 * h);
            }
            $t46871 = ({ x: 0., y: $t46870 });
          }
          $t46872 = Arcade$Vec2$add($t46868, $t46871);
        }
      }
      {
        const v_i12882 = $t46872;
        {
          let s_i12883;
          s_i12883 = Arcade$Vec2$length($t46872);
          {
            const $t46865_i12885 = (s_i12883 > 2400.);
            if ($t46865_i12885 === true) {
              {
                const $t46867_i12887 = (2400. / s_i12883);
                vel = Arcade$Vec2$scale($t46872, $t46867_i12887);
              }
            } else {
              vel = $t46872;
            }
          }
        }
      }
    }
    {
      let moved;
      {
        let $t46875;
        {
          const $t46873 = b.pos;
          {
            let $t46874;
            $t46874 = Arcade$Vec2$scale(vel, h);
            $t46875 = Arcade$Vec2$add($t46873, $t46874);
          }
        }
        moved = ({ pos: $t46875, vel: vel });
      }
      {
        const r = t.ball_radius;
        {
          let after_parts;
          {
            const $t46876 = t.parts;
            {
              const $t46877 = { $: "Nil" };
              {
                const $t46878 = { _0: moved, _1: $t46877 };
                {
                  const $t46881 = { $: "$Clo_$lam0_Spin_Physics_step_ball$0_Spin_Physics_step_ball", _0: $lam0_Spin_Physics_step_ball$apply$0_Spin_Physics_step_ball, _1: b, _2: r };
                  after_parts = List$fold_left$List_Part$T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_Part_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit($t46876, $t46878, $t46881);
                }
              }
            }
          }
          {
            let after_left;
            {
              const $t46882 = t.left;
              after_left = Spin$Physics$against_flipper(r, $t46882, left, after_parts);
            }
            {
              const $t46883 = t.right;
              return Spin$Physics$against_flipper(r, $t46883, right, after_left);
            }
          }
        }
      }
    }
  }
}
const Spin$Physics$step_ball$clo = { _0: ($_, t, left, right, h, b) => Spin$Physics$step_ball(t, left, right, h, b) };

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
    let $t46902;
    {
      const $t46885 = { $: "Cherry" };
      {
        const $t46886 = { $: "Blank" };
        {
          const $t46887 = { $: "Blank" };
          {
            const $t46888 = { $: "Lemon" };
            {
              const $t46889 = { $: "Blank" };
              {
                const $t46890 = { $: "Blank" };
                {
                  const $t46891 = { $: "Blank" };
                  {
                    const $t46892 = { $: "Blank" };
                    {
                      const $t46893 = { $: "Nil" };
                      {
                        const $t46894 = { $: "Cons", _0: $t46892, _1: $t46893 };
                        {
                          const $t46895 = { $: "Cons", _0: $t46891, _1: $t46894 };
                          {
                            const $t46896 = { $: "Cons", _0: $t46890, _1: $t46895 };
                            {
                              const $t46897 = { $: "Cons", _0: $t46889, _1: $t46896 };
                              {
                                const $t46898 = { $: "Cons", _0: $t46888, _1: $t46897 };
                                {
                                  const $t46899 = { $: "Cons", _0: $t46887, _1: $t46898 };
                                  {
                                    const $t46900 = { $: "Cons", _0: $t46886, _1: $t46899 };
                                    {
                                      const $t46901 = { $: "Cons", _0: $t46885, _1: $t46900 };
                                      {
                                        const $t46884_i5386 = march_int_ovf(-(1), 3);
                                        $t46902 = ({ stops: $t46901, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t46884_i5386, glow: 0. });
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
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
      let $t46920;
      {
        const $t46903 = { $: "Blank" };
        {
          const $t46904 = { $: "Cherry" };
          {
            const $t46905 = { $: "Blank" };
            {
              const $t46906 = { $: "Blank" };
              {
                const $t46907 = { $: "Blank" };
                {
                  const $t46908 = { $: "Blank" };
                  {
                    const $t46909 = { $: "Bell" };
                    {
                      const $t46910 = { $: "Blank" };
                      {
                        const $t46911 = { $: "Nil" };
                        {
                          const $t46912 = { $: "Cons", _0: $t46910, _1: $t46911 };
                          {
                            const $t46913 = { $: "Cons", _0: $t46909, _1: $t46912 };
                            {
                              const $t46914 = { $: "Cons", _0: $t46908, _1: $t46913 };
                              {
                                const $t46915 = { $: "Cons", _0: $t46907, _1: $t46914 };
                                {
                                  const $t46916 = { $: "Cons", _0: $t46906, _1: $t46915 };
                                  {
                                    const $t46917 = { $: "Cons", _0: $t46905, _1: $t46916 };
                                    {
                                      const $t46918 = { $: "Cons", _0: $t46904, _1: $t46917 };
                                      {
                                        const $t46919 = { $: "Cons", _0: $t46903, _1: $t46918 };
                                        {
                                          const $t46884_i5384 = march_int_ovf(-(1), 3);
                                          $t46920 = ({ stops: $t46919, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t46884_i5384, glow: 0. });
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
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
        let $t46938;
        {
          const $t46921 = { $: "Blank" };
          {
            const $t46922 = { $: "Blank" };
            {
              const $t46923 = { $: "Blank" };
              {
                const $t46924 = { $: "Cherry" };
                {
                  const $t46925 = { $: "Blank" };
                  {
                    const $t46926 = { $: "Blank" };
                    {
                      const $t46927 = { $: "Blank" };
                      {
                        const $t46928 = { $: "Blank" };
                        {
                          const $t46929 = { $: "Nil" };
                          {
                            const $t46930 = { $: "Cons", _0: $t46928, _1: $t46929 };
                            {
                              const $t46931 = { $: "Cons", _0: $t46927, _1: $t46930 };
                              {
                                const $t46932 = { $: "Cons", _0: $t46926, _1: $t46931 };
                                {
                                  const $t46933 = { $: "Cons", _0: $t46925, _1: $t46932 };
                                  {
                                    const $t46934 = { $: "Cons", _0: $t46924, _1: $t46933 };
                                    {
                                      const $t46935 = { $: "Cons", _0: $t46923, _1: $t46934 };
                                      {
                                        const $t46936 = { $: "Cons", _0: $t46922, _1: $t46935 };
                                        {
                                          const $t46937 = { $: "Cons", _0: $t46921, _1: $t46936 };
                                          {
                                            const $t46884_i5382 = march_int_ovf(-(1), 3);
                                            $t46938 = ({ stops: $t46937, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t46884_i5382, glow: 0. });
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
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
          const $t46939 = { $: "Nil" };
          {
            const $t46940 = { $: "Cons", _0: $t46938, _1: $t46939 };
            {
              const $t46941 = { $: "Cons", _0: $t46920, _1: $t46940 };
              {
                const $t46942 = { $: "Cons", _0: $t46902, _1: $t46941 };
                {
                  const $t46943 = { $: "Idle" };
                  return ({ reels: $t46942, armed: 0, banked: 0, phase: $t46943, nudge_left: 0., boost: 1, last_line: "", last_pay: 0 });
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
    let $t46946;
    {
      const $t46945 = Spin$Reels$wrap(i);
      $t46946 = List$nth_opt$List_Symbol$Int(xs, $t46945);
    }
    switch ($t46946.$) {
      case "Some": {
        const $f46947 = $t46946._0;
        {
          const s = $f46947;
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
    let $t46953;
    {
      const $t46952 = b.reels;
      $t46953 = List$nth_opt$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($t46952, i);
    }
    switch ($t46953.$) {
      case "Some": {
        const $f46955 = $t46953._0;
        {
          const r = $f46955;
          return r;
        }
        break;
      }
      case "None": {
        {
          const $t46954 = { $: "Nil" };
          {
            const $t46884_i5388 = march_int_ovf(-(1), 3);
            return ({ stops: $t46954, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t46884_i5388, glow: 0. });
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
    const $t46956 = b.reels;
    {
      let $t46957;
      {
        const xs_i12888 = $t46956;
        {
          let $t46948_i12894;
          {
            const $t1226_i6296_i12893 = { $: "Nil" };
            $t46948_i12894 = List$take_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t46956, i, $t1226_i6296_i12893);
          }
          {
            const $t46949_i12895 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
            {
              const $t46950_i12896 = List$drop$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($t46956, $t46949_i12895);
              {
                const $t46951_i12897 = { $: "Cons", _0: r, _1: $t46950_i12896 };
                {
                  const xs_i14436 = $t46948_i12894;
                  {
                    const ys_i14437 = $t46951_i12897;
                    switch (xs_i14436.$) {
                      case "Nil": {
                        $t46957 = $t46951_i12897;
                        break;
                      }
                      case "Cons": {
                        const $f987_i14438 = xs_i14436._0;
                        const $f988_i14439 = xs_i14436._1;
                        {
                          const t_i14440 = $f988_i14439;
                          {
                            const h_i14441 = $f987_i14438;
                            {
                              const $trmc11_i14442 = { $: "Cons", _0: h_i14441, _1: null };
                              List$append$dps$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(t_i14440, $t46951_i12897, $trmc11_i14442);
                              $t46957 = $trmc11_i14442;
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
        const $rc_2608 = ({ ...b, reels: $t46957 });
        return $rc_2608;
      }
    }
  }
}
const Spin$Reels$set_reel$clo = { _0: ($_, b, i, r) => Spin$Reels$set_reel(b, i, r) };

function Spin$Reels$on_line(b, i) {
  {
    const r = Spin$Reels$reel_at(b, i);
    {
      const $t46958 = r.stops;
      {
        const $t46959 = r.pos;
        return Spin$Reels$at($t46958, $t46959);
      }
    }
  }
}
const Spin$Reels$on_line$clo = { _0: ($_, b, i) => Spin$Reels$on_line(b, i) };

function Spin$Reels$shown(r) {
  {
    let $t46967;
    {
      const $t46966 = r.duration;
      $t46967 = ($t46966 > 0.);
    }
    if ($t46967 === true) {
      {
        let t;
        {
          let $t46970;
          {
            const $t46968 = r.elapsed;
            {
              const $t46969 = r.duration;
              $t46970 = ($t46968 / $t46969);
            }
          }
          {
            let $t45789_i5392;
            {
              const $t45787_i14244 = (0. >= $t46970);
              if ($t45787_i14244 === true) {
                $t45789_i5392 = 0.;
              } else {
                $t45789_i5392 = $t46970;
              }
            }
            {
              const $t45788_i14241 = (1. < $t45789_i5392);
              if ($t45788_i14241 === true) {
                t = 1.;
              } else {
                t = $t45789_i5392;
              }
            }
          }
        }
        {
          const left = (1. - t);
          {
            const $t46971 = r.from;
            {
              let $t46976;
              {
                const $t46972 = r.travel;
                {
                  let $t46975;
                  {
                    let $t46974;
                    {
                      const $t46973 = (left * left);
                      $t46974 = ($t46973 * left);
                    }
                    $t46975 = (1. - $t46974);
                  }
                  $t46976 = ($t46972 * $t46975);
                }
              }
              return ($t46971 + $t46976);
            }
          }
        }
      }
    } else {
      {
        const $t46977 = r.pos;
        return $t46977;
      }
    }
  }
}
const Spin$Reels$shown$clo = { _0: ($_, r) => Spin$Reels$shown(r) };

function Spin$Reels$stop(r, i) {
  {
    const $t46978 = r.stops;
    return Spin$Reels$at($t46978, i);
  }
}
const Spin$Reels$stop$clo = { _0: ($_, r, i) => Spin$Reels$stop(r, i) };

function Spin$Reels$count(xs, s) {
  {
    const $t46980 = { $: "$Clo_$lam0_Spin_Reels_count$0_Spin_Reels_count", _0: $lam0_Spin_Reels_count$apply$0_Spin_Reels_count, _1: s };
    {
      const $t46981 = List$filter$List_Symbol$Fn_Symbol_Bool(xs, $t46980);
      {
        let $rc_2609;
        {  };
        $rc_2609 = List$length_onto$List_Symbol$Int($t46981, 0);
        return $rc_2609;
      }
    }
  }
}
const Spin$Reels$count$clo = { _0: ($_, xs, s) => Spin$Reels$count(xs, s) };

function Spin$Reels$pays(xs) {
  switch (xs.$) {
    case "Cons": {
      const $f46994 = xs._0;
      const $f46995 = xs._1;
      {
        const $jp_clo47001 = { $: "$Clo_$jp2_Spin_Reels_pays$0_Spin_Reels_pays", _0: $jp2_Spin_Reels_pays$apply$0_Spin_Reels_pays };
        switch ($f46995.$) {
          case "Cons": {
            const $f47002 = $f46995._0;
            const $f47003 = $f46995._1;
            {
              const $jp_clo47009 = { $: "$Clo_$jp5_Spin_Reels_pays$1_Spin_Reels_pays", _0: $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays, _1: $jp_clo47001 };
              switch ($f47003.$) {
                case "Cons": {
                  const $f47010 = $f47003._0;
                  const $f47011 = $f47003._1;
                  switch ($f47011.$) {
                    case "Nil": {
                      {
                        const c = $f47010;
                        {
                          const b = $f47002;
                          {
                            const a = $f46994;
                            {
                              let $t46987;
                              {
                                let $t46984;
                                {
                                  const $t46982 = march_deep_eq(a, b);
                                  {
                                    let $t46983;
                                    {
                                      const $rc_2612 = march_deep_eq(b, c);
                                      $t46983 = $rc_2612;
                                    }
                                    $t46984 = ($t46982 && $t46983);
                                  }
                                }
                                {
                                  let $t46986;
                                  {
                                    const $t46985 = { $: "Blank" };
                                    {
                                      const $rc_2611 = (!march_deep_eq(a, $t46985));
                                      $t46986 = $rc_2611;
                                    }
                                  }
                                  $t46987 = ($t46984 && $t46986);
                                }
                              }
                              if ($t46987 === true) {
                                {
                                  let $rc_2610;
                                  switch (a.$) {
                                    case "Seven": {
                                      $rc_2610 = { _0: 77, _1: "JACKPOT 777" };
                                      break;
                                    }
                                    case "Bars": {
                                      $rc_2610 = { _0: 30, _1: "BAR BAR BAR" };
                                      break;
                                    }
                                    case "Bell": {
                                      $rc_2610 = { _0: 20, _1: "THREE BELLS" };
                                      break;
                                    }
                                    case "Lemon": {
                                      $rc_2610 = { _0: 12, _1: "THREE LEMONS" };
                                      break;
                                    }
                                    case "Cherry": {
                                      $rc_2610 = { _0: 10, _1: "THREE CHERRIES" };
                                      break;
                                    }
                                    case "Blank": {
                                      $rc_2610 = { _0: 0, _1: "" };
                                      break;
                                    }
                                    default: {
                                      throw new Error("non-exhaustive pattern match");
                                      break;
                                    }
                                  }
                                  return $rc_2610;
                                }
                              } else {
                                {
                                  let cherries;
                                  {
                                    const $t46988 = { $: "Cherry" };
                                    cherries = Spin$Reels$count(xs, $t46988);
                                  }
                                  {
                                    const $t46989 = (cherries >= 2);
                                    if ($t46989 === true) {
                                      return { _0: 4, _1: "TWO CHERRIES" };
                                    } else {
                                      {
                                        let $t46992;
                                        {
                                          let $t46991;
                                          {
                                            const $t46990 = { $: "Blank" };
                                            $t46991 = Spin$Reels$count(xs, $t46990);
                                          }
                                          $t46992 = ($t46991 === 0);
                                        }
                                        if ($t46992 === true) {
                                          return { _0: 3, _1: "FULL LINE" };
                                        } else {
                                          {
                                            const $t46993 = (cherries === 1);
                                            if ($t46993 === true) {
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
                      return $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays($jp_clo47009);
                    }
                  }
                  break;
                }
                default: {
                  return $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays($jp_clo47009);
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
    const $t47032 = ((8 + 1) < 4611686018427387904 && (8 + 1) >= -4611686018427387904 ? (8 + 1) : march_int_ovf((8 + 1), 0));
    {
      let ahead;
      {
        const go_i5402 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 1 };
        {
          const $t915_i5403 = (($t47032 - 1) < 4611686018427387904 && ($t47032 - 1) >= -4611686018427387904 ? ($t47032 - 1) : march_int_ovf(($t47032 - 1), 1));
          {
            const $t916_i5404 = { $: "Nil" };
            ahead = go$apply$0_List_range(go_i5402, $t915_i5403, $t916_i5404);
          }
        }
      }
      {
        let $t47038;
        {
          let $t47037;
          $t47037 = { $: "$Clo_$lam0_Spin_Reels_roll_to$0_Spin_Reels_roll_to", _0: $lam0_Spin_Reels_roll_to$apply$0_Spin_Reels_roll_to, _1: r, _2: s };
          $t47038 = List$find$List_Int$Fn_Int_Bool(ahead, $t47037);
        }
        switch ($t47038.$) {
          case "Some": {
            const $f47048 = $t47038._0;
            {
              const k = $f47048;
              return k;
            }
            break;
          }
          case "None": {
            {
              let $t47046;
              {
                const $t47045 = { $: "$Clo_$lam1_Spin_Reels_roll_to$1_Spin_Reels_roll_to", _0: $lam1_Spin_Reels_roll_to$apply$1_Spin_Reels_roll_to, _1: r, _2: s };
                {
                  const $rc_2614 = List$find$List_Int$Fn_Int_Bool(ahead, $t47045);
                  $t47046 = $rc_2614;
                }
              }
              switch ($t47046.$) {
                case "Some": {
                  const $f47047 = $t47046._0;
                  {
                    const k = $f47047;
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
        let $t47063;
        $t47063 = Spin$Reels$reel_at(b, i);
        {
          const r_i12937 = $t47063;
          {
            const s_i12938 = s;
            {
              let $t47049_i12939;
              {
                const r_i14466 = $t47063;
                {
                  const $t47021_i14467 = ((8 + 1) < 4611686018427387904 && (8 + 1) >= -4611686018427387904 ? (8 + 1) : march_int_ovf((8 + 1), 0));
                  {
                    let $t47022_i14471;
                    {
                      const go_i5397_i14468 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 1 };
                      {
                        const $t915_i5398_i14469 = (($t47021_i14467 - 1) < 4611686018427387904 && ($t47021_i14467 - 1) >= -4611686018427387904 ? ($t47021_i14467 - 1) : march_int_ovf(($t47021_i14467 - 1), 1));
                        {
                          const $t916_i5399_i14470 = { $: "Nil" };
                          $t47022_i14471 = go$apply$0_List_range(go_i5397_i14468, $t915_i5398_i14469, $t916_i5399_i14470);
                        }
                      }
                    }
                    {
                      let $t47026_i14472;
                      $t47026_i14472 = { $: "$Clo_$lam0_Spin_Reels_target_stop$0_Spin_Reels_target_stop", _0: $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop, _1: $t47063 };
                      {
                        let order_i14473;
                        {
                          const xs_i14515 = $t47022_i14471;
                          {
                            const f_i14516 = $t47026_i14472;
                            switch (xs_i14515.$) {
                              case "Nil": {
                                order_i14473 = { $: "Nil" };
                                break;
                              }
                              case "Cons": {
                                const $f995_i14517 = xs_i14515._0;
                                const $f996_i14518 = xs_i14515._1;
                                {
                                  const t_i14519 = $f996_i14518;
                                  {
                                    const h_i14520 = $f995_i14517;
                                    {
                                      let $t993_i14521;
                                      $t993_i14521 = f_i14516._0(f_i14516, h_i14520);
                                      {
                                        const $trmc15_i14522 = { $: "Cons", _0: $t993_i14521, _1: null };
                                        List$map$dps$List_Int$Fn_Int_Int$List_Int(t_i14519, f_i14516, $trmc15_i14522);
                                        order_i14473 = $trmc15_i14522;
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
                          const $t47030_i14474 = { $: "$Clo_$lam1_Spin_Reels_target_stop$1_Spin_Reels_target_stop", _0: $lam1_Spin_Reels_target_stop$apply$1_Spin_Reels_target_stop, _1: $t47063 };
                          {
                            const $rc_2613_i14475 = List$find$List_Int$Fn_Int_Bool(order_i14473, $t47030_i14474);
                            $t47049_i12939 = $rc_2613_i14475;
                          }
                        }
                      }
                    }
                  }
                }
              }
              switch ($t47049_i12939.$) {
                case "Some": {
                  const $f47052_i12940 = $t47049_i12939._0;
                  {
                    const j_i12941 = $f47052_i12940;
                    {
                      const $t47050_i12942 = $t47063.stops;
                      {
                        let $t47051_i12943;
                        {
                          const xs_i14451 = $t47050_i12942;
                          {
                            let $t46948_i14455;
                            {
                              const $t1226_i6299_i14454 = { $: "Nil" };
                              $t46948_i14455 = List$take_onto$List_Symbol$Int$List_Symbol($t47050_i12942, j_i12941, $t1226_i6299_i14454);
                            }
                            {
                              const $t46949_i14456 = ((j_i12941 + 1) < 4611686018427387904 && (j_i12941 + 1) >= -4611686018427387904 ? (j_i12941 + 1) : march_int_ovf((j_i12941 + 1), 0));
                              {
                                const $t46950_i14457 = List$drop$List_Symbol$Int($t47050_i12942, $t46949_i14456);
                                {
                                  const $t46951_i14458 = { $: "Cons", _0: s, _1: $t46950_i14457 };
                                  {
                                    const xs_i13179_i14459 = $t46948_i14455;
                                    {
                                      const ys_i13180_i14460 = $t46951_i14458;
                                      switch (xs_i13179_i14459.$) {
                                        case "Nil": {
                                          $t47051_i12943 = $t46951_i14458;
                                          break;
                                        }
                                        case "Cons": {
                                          const $f987_i13181_i14461 = xs_i13179_i14459._0;
                                          const $f988_i13182_i14462 = xs_i13179_i14459._1;
                                          {
                                            const t_i13183_i14463 = $f988_i13182_i14462;
                                            {
                                              const h_i13184_i14464 = $f987_i13181_i14461;
                                              {
                                                const $trmc11_i13185_i14465 = { $: "Cons", _0: h_i13184_i14464, _1: null };
                                                List$append$dps$List_Symbol$List_Symbol$List_Symbol(t_i13183_i14463, $t46951_i14458, $trmc11_i13185_i14465);
                                                $t47051_i12943 = $trmc11_i13185_i14465;
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
                          const $rc_2615_i12944 = ({ ...$t47063, stops: $t47051_i12943, fresh: j_i12941, glow: 1. });
                          w = $rc_2615_i12944;
                        }
                      }
                    }
                  }
                  break;
                }
                case "None": {
                  w = $t47063;
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
          let $t47065;
          {
            const $t47064 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
            $t47065 = march_int_mod_euclid($t47064, 3);
          }
          next = ({ ...b, armed: $t47065 });
        }
        {
          let $t47072;
          {
            let $t47068;
            {
              const $t47066 = b.phase;
              {
                const $t47067 = { $: "Spinning" };
                {
                  const $rc_2618 = march_deep_eq($t47066, $t47067);
                  $t47068 = $rc_2618;
                }
              }
            }
            {
              let $t47071;
              {
                const $t47069 = b.phase;
                {
                  const $t47070 = { $: "Nudging" };
                  {
                    const $rc_2617 = march_deep_eq($t47069, $t47070);
                    $t47071 = $rc_2617;
                  }
                }
              }
              $t47072 = ($t47068 || $t47071);
            }
          }
          if ($t47072 === true) {
            {
              const quiet = Spin$Reels$set_reel(next, i, w);
              {
                const $t47073 = { $: "Loaded", _0: s, _1: i };
                {
                  const $t47074 = { $: "Nil" };
                  {
                    const $t47075 = { $: "Cons", _0: $t47073, _1: $t47074 };
                    return { _0: quiet, _1: $t47075 };
                  }
                }
              }
            }
          } else {
            {
              let placed;
              {
                let $t47077;
                {
                  let $t47076;
                  $t47076 = Spin$Reels$roll_to(w, s);
                  {
                    const r_i12925 = w;
                    {
                      let $t47054_i12928;
                      {
                        const $t47053_i12927 = w.pos;
                        $t47054_i12928 = $t47053_i12927;
                      }
                      {
                        const $t47055_i12929 = $t47076;
                        {
                          let $t47058_i12932;
                          {
                            let $t47057_i12931;
                            {
                              const $t47056_i12930 = $t47076;
                              $t47057_i12931 = (0.05 * $t47056_i12930);
                            }
                            $t47058_i12932 = (0.16 + $t47057_i12931);
                          }
                          {
                            let $t47061_i12935;
                            {
                              let $t47060_i12934;
                              {
                                const $t47059_i12933 = w.pos;
                                $t47060_i12934 = (($t47059_i12933 + $t47076) < 4611686018427387904 && ($t47059_i12933 + $t47076) >= -4611686018427387904 ? ($t47059_i12933 + $t47076) : march_int_ovf(($t47059_i12933 + $t47076), 0));
                              }
                              $t47061_i12935 = Spin$Reels$wrap($t47060_i12934);
                            }
                            {
                              const $rc_2616_i12936 = ({ ...w, from: $t47054_i12928, travel: $t47055_i12929, elapsed: 0., duration: $t47058_i12932, pos: $t47061_i12935 });
                              $t47077 = $rc_2616_i12936;
                            }
                          }
                        }
                      }
                    }
                  }
                }
                placed = Spin$Reels$set_reel(next, i, $t47077);
              }
              {
                let building;
                {
                  let $t47082;
                  {
                    let $t47081;
                    {
                      let $t47079;
                      {
                        const $t47078 = b.phase;
                        {
                          const p_i12922 = $t47078;
                          switch (p_i12922.$) {
                            case "Building": {
                              const $f47062_i12923 = p_i12922._0;
                              {
                                const j_i12924 = $f47062_i12923;
                                $t47079 = j_i12924;
                              }
                              break;
                            }
                            case "Idle": {
                              $t47079 = false;
                              break;
                            }
                            case "Spinning": {
                              $t47079 = false;
                              break;
                            }
                            case "Nudging": {
                              $t47079 = false;
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
                        const $t47080 = (i === 2);
                        $t47081 = ($t47079 || $t47080);
                      }
                    }
                    $t47082 = { $: "Building", _0: $t47081 };
                  }
                  building = Spin$Reels$in_phase(placed, $t47082);
                }
                {
                  const $t47083 = { $: "Loaded", _0: s, _1: i };
                  {
                    const $t47084 = { $: "Nil" };
                    {
                      const $t47085 = { $: "Cons", _0: $t47083, _1: $t47084 };
                      return { _0: building, _1: $t47085 };
                    }
                  }
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
      let $t47087;
      {
        const $t47086 = b.banked;
        $t47087 = (($t47086 + 1) < 4611686018427387904 && ($t47086 + 1) >= -4611686018427387904 ? ($t47086 + 1) : march_int_ovf(($t47086 + 1), 0));
      }
      {
        const $t2462_i5407 = ($t47087 < 5);
        if ($t2462_i5407 === true) {
          n = $t47087;
        } else {
          n = 5;
        }
      }
    }
    {
      const $t47089 = ({ ...b, banked: n });
      {
        const $t47090 = { $: "Banked", _0: n };
        {
          const $t47091 = { $: "Nil" };
          {
            const $t47092 = { $: "Cons", _0: $t47090, _1: $t47091 };
            return { _0: $t47089, _1: $t47092 };
          }
        }
      }
    }
  }
}
const Spin$Reels$bank_spin$clo = { _0: ($_, b) => Spin$Reels$bank_spin(b) };

function Spin$Reels$start_reel(rng, r, i) {
  {
    const $t47095 = r.held;
    if ($t47095 === true) {
      return { _0: r, _1: rng };
    } else {
      {
        let $p47108;
        {
          const $p45982_i12947 = Arcade$Rng$next(rng);
          {
            const v_i12948 = $p45982_i12947._0;
            {
              const after_i12949 = $p45982_i12947._1;
              {
                let $t45981_i12950;
                {
                  const v_i14476 = v_i12948;
                  {
                    const $t45972_i14478 = (8 <= 1048576);
                    if ($t45972_i14478 === true) {
                      {
                        let $t45977_i14483;
                        {
                          let $t45975_i14481;
                          {
                            let $t45974_i14480;
                            {
                              const $t45973_i14479 = v_i12948.hi;
                              $t45974_i14480 = ($t45973_i14479 % 8);
                            }
                            $t45975_i14481 = (($t45974_i14480 * 4294967296) < 4611686018427387904 && ($t45974_i14480 * 4294967296) >= -4611686018427387904 ? ($t45974_i14480 * 4294967296) : march_int_ovf(($t45974_i14480 * 4294967296), 2));
                          }
                          {
                            const $t45976_i14482 = v_i12948.lo;
                            $t45977_i14483 = (($t45975_i14481 + $t45976_i14482) < 4611686018427387904 && ($t45975_i14481 + $t45976_i14482) >= -4611686018427387904 ? ($t45975_i14481 + $t45976_i14482) : march_int_ovf(($t45975_i14481 + $t45976_i14482), 0));
                          }
                        }
                        $t45981_i12950 = ($t45977_i14483 % 8);
                      }
                    } else {
                      {
                        let $t45979_i14485;
                        {
                          const $t45978_i14484 = v_i12948.hi;
                          $t45979_i14485 = Arcade$Rng$divide_word(0, $t45978_i14484, 31, 8);
                        }
                        {
                          const $t45980_i14486 = v_i12948.lo;
                          $t45981_i12950 = Arcade$Rng$divide_word($t45979_i14485, $t45980_i14486, 31, 8);
                        }
                      }
                    }
                  }
                }
                {
                  const $rc_2499_i12951 = { _0: $t45981_i12950, _1: after_i12949 };
                  $p47108 = $rc_2499_i12951;
                }
              }
            }
          }
        }
        {
          const target = $p47108._0;
          {
            const after = $p47108._1;
            {
              const laps = ((2 + i) < 4611686018427387904 && (2 + i) >= -4611686018427387904 ? (2 + i) : march_int_ovf((2 + i), 0));
              {
                let ahead;
                {
                  let $t47098;
                  {
                    const $t47097 = r.pos;
                    $t47098 = ((target - $t47097) < 4611686018427387904 && (target - $t47097) >= -4611686018427387904 ? (target - $t47097) : march_int_ovf((target - $t47097), 1));
                  }
                  ahead = Spin$Reels$wrap($t47098);
                }
                {
                  let travel;
                  {
                    let $t47101;
                    {
                      const $t47100 = ((laps * 8) < 4611686018427387904 && (laps * 8) >= -4611686018427387904 ? (laps * 8) : march_int_ovf((laps * 8), 2));
                      $t47101 = (($t47100 + ahead) < 4611686018427387904 && ($t47100 + ahead) >= -4611686018427387904 ? ($t47100 + ahead) : march_int_ovf(($t47100 + ahead), 0));
                    }
                    travel = $t47101;
                  }
                  {
                    let $t47107;
                    {
                      let $t47103;
                      {
                        const $t47102 = r.pos;
                        $t47103 = $t47102;
                      }
                      {
                        let $t47106;
                        {
                          let $t47105;
                          {
                            const $t47104 = i;
                            $t47105 = (0.4 * $t47104);
                          }
                          $t47106 = (0.9 + $t47105);
                        }
                        $t47107 = ({ ...r, from: $t47103, travel: travel, elapsed: 0., duration: $t47106, pos: target });
                      }
                    }
                    {
                      const $rc_2621 = { _0: $t47107, _1: after };
                      return $rc_2621;
                    }
                  }
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
    let $p47122;
    {
      let $t47109;
      $t47109 = Spin$Reels$reel_at(b, 0);
      $p47122 = Spin$Reels$start_reel(rng, $t47109, 0);
    }
    {
      const r0 = $p47122._0;
      {
        const g0 = $p47122._1;
        {
          let $p47121;
          {
            let $t47110;
            $t47110 = Spin$Reels$reel_at(b, 1);
            $p47121 = Spin$Reels$start_reel(g0, $t47110, 1);
          }
          {
            const r1 = $p47121._0;
            {
              const g1 = $p47121._1;
              {
                let $p47120;
                {
                  let $t47111;
                  $t47111 = Spin$Reels$reel_at(b, 2);
                  $p47120 = Spin$Reels$start_reel(g1, $t47111, 2);
                }
                {
                  const r2 = $p47120._0;
                  {
                    const g2 = $p47120._1;
                    {
                      let $t47119;
                      {
                        const $t47112 = { $: "Nil" };
                        {
                          let $t47113;
                          $t47113 = { $: "Cons", _0: r2, _1: $t47112 };
                          {
                            let $t47114;
                            $t47114 = { $: "Cons", _0: r1, _1: $t47113 };
                            {
                              let $t47115;
                              $t47115 = { $: "Cons", _0: r0, _1: $t47114 };
                              {
                                let $t47117;
                                {
                                  const $t47116 = b.banked;
                                  $t47117 = (($t47116 - 1) < 4611686018427387904 && ($t47116 - 1) >= -4611686018427387904 ? ($t47116 - 1) : march_int_ovf(($t47116 - 1), 1));
                                }
                                {
                                  const $t47118 = { $: "Spinning" };
                                  $t47119 = ({ ...b, reels: $t47115, banked: $t47117, phase: $t47118, nudge_left: 0. });
                                }
                              }
                            }
                          }
                        }
                      }
                      {
                        const $rc_2623 = { _0: $t47119, _1: g2 };
                        return $rc_2623;
                      }
                    }
                  }
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
      let $t47125;
      {
        let $t47124;
        {
          const $t47123 = r.glow;
          $t47124 = ($t47123 - dt);
        }
        {
          const $t45787_i5410 = ($t47124 >= 0.);
          if ($t45787_i5410 === true) {
            $t47125 = $t47124;
          } else {
            $t47125 = 0.;
          }
        }
      }
      faded = ({ ...r, glow: $t47125 });
    }
    {
      let $t47127;
      {
        const $t47126 = faded.duration;
        $t47127 = ($t47126 > 0.);
      }
      if ($t47127 === true) {
        {
          let e;
          {
            const $t47128 = faded.elapsed;
            e = ($t47128 + dt);
          }
          {
            let $t47130;
            {
              const $t47129 = faded.duration;
              $t47130 = (e >= $t47129);
            }
            if ($t47130 === true) {
              {
                const $t47131 = ({ ...faded, elapsed: 0., duration: 0., travel: 0. });
                {
                  const $t47132 = { $: "Landed", _0: i };
                  {
                    const $t47133 = { $: "Nil" };
                    {
                      const $t47134 = { $: "Cons", _0: $t47132, _1: $t47133 };
                      {
                        const $rc_2631 = { _0: $t47131, _1: $t47134 };
                        return $rc_2631;
                      }
                    }
                  }
                }
              }
            } else {
              {
                const $t47135 = ({ ...faded, elapsed: e });
                {
                  const $t47136 = { $: "Nil" };
                  {
                    const $rc_2630 = { _0: $t47135, _1: $t47136 };
                    return $rc_2630;
                  }
                }
              }
            }
          }
        }
      } else {
        {
          const $t47137 = { $: "Nil" };
          return { _0: faded, _1: $t47137 };
        }
      }
    }
  }
}
const Spin$Reels$turn$clo = { _0: ($_, r, dt, i) => Spin$Reels$turn(r, dt, i) };

function Spin$Reels$unhold(r) {
  {
    const $rc_2632 = ({ ...r, held: false });
    return $rc_2632;
  }
}
const Spin$Reels$unhold$clo = { _0: ($_, r) => Spin$Reels$unhold(r) };

function Spin$Reels$settle(b) {
  {
    let $p47162;
    {
      let $t47142;
      {
        const b_i12952 = b;
        {
          let $t46960_i12953;
          $t46960_i12953 = Spin$Reels$on_line(b, 0);
          {
            let $t46961_i12954;
            $t46961_i12954 = Spin$Reels$on_line(b, 1);
            {
              const $t46962_i12955 = Spin$Reels$on_line(b, 2);
              {
                const $t46963_i12956 = { $: "Nil" };
                {
                  const $t46964_i12957 = { $: "Cons", _0: $t46962_i12955, _1: $t46963_i12956 };
                  {
                    const $t46965_i12958 = { $: "Cons", _0: $t46961_i12954, _1: $t46964_i12957 };
                    $t47142 = { $: "Cons", _0: $t46960_i12953, _1: $t46965_i12958 };
                  }
                }
              }
            }
          }
        }
      }
      $p47162 = Spin$Reels$pays($t47142);
    }
    {
      const pay = $p47162._0;
      {
        const name = $p47162._1;
        {
          let idle;
          {
            const $t47143 = { $: "Idle" };
            idle = ({ ...b, phase: $t47143 });
          }
          {
            const $t47144 = b.phase;
            switch ($t47144.$) {
              case "Building": {
                const $f47161 = $t47144._0;
                {
                  let judge;
                  judge = $f47161;
                  {
                    let $t47146;
                    {
                      const $t47145 = (pay > 0);
                      $t47146 = (judge && $t47145);
                    }
                    if ($t47146 === true) {
                      {
                        let paid;
                        paid = ({ ...idle, last_line: name, last_pay: pay });
                        {
                          let out;
                          {
                            let $t47147;
                            $t47147 = { $: "Paid", _0: pay, _1: name };
                            {
                              const $t47148 = { $: "Nil" };
                              {
                                const $t47149 = { $: "Cons", _0: $t47147, _1: $t47148 };
                                out = { _0: paid, _1: $t47149 };
                              }
                            }
                          }
                          return out;
                        }
                      }
                    } else {
                      {
                        const $t47150 = { $: "Nil" };
                        {
                          const $rc_2642 = { _0: idle, _1: $t47150 };
                          return $rc_2642;
                        }
                      }
                    }
                  }
                }
                break;
              }
              case "Spinning": {
                {
                  const $t47151 = (pay > 0);
                  if ($t47151 === true) {
                    return Spin$Reels$spent(idle, pay, name);
                  } else {
                    {
                      let missed;
                      {
                        const $t47152 = b.reels;
                        {
                          let $t47153;
                          $t47153 = List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t47152, Spin$Reels$unhold$clo);
                          missed = ({ ...idle, reels: $t47153, boost: 1, nudge_left: 4., last_line: "NUDGE!", last_pay: 0 });
                        }
                      }
                      {
                        let out;
                        {
                          const $t47155 = { $: "Missed" };
                          {
                            const $t47156 = { $: "Nil" };
                            {
                              const $t47157 = { $: "Cons", _0: $t47155, _1: $t47156 };
                              out = { _0: missed, _1: $t47157 };
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
                  const $t47158 = (pay > 0);
                  if ($t47158 === true) {
                    return Spin$Reels$spent(idle, pay, name);
                  } else {
                    {
                      const $t47159 = { $: "Nil" };
                      {
                        const $rc_2645 = { _0: idle, _1: $t47159 };
                        return $rc_2645;
                      }
                    }
                  }
                }
                break;
              }
              case "Idle": {
                {
                  const $t47160 = { $: "Nil" };
                  {
                    const $rc_2646 = { _0: idle, _1: $t47160 };
                    return $rc_2646;
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
      const $t47163 = b.boost;
      total = ((pay * $t47163) < 4611686018427387904 && (pay * $t47163) >= -4611686018427387904 ? (pay * $t47163) : march_int_ovf((pay * $t47163), 2));
    }
    {
      let named;
      {
        let $t47165;
        {
          const $t47164 = b.boost;
          $t47165 = ($t47164 > 1);
        }
        if ($t47165 === true) {
          {
            let $t47167;
            {
              const $t47166 = b.boost;
              $t47167 = String($t47166);
            }
            {
              const $rc_2647 = march_string_concat3(name, " x", $t47167);
              named = $rc_2647;
            }
          }
        } else {
          named = name;
        }
      }
      {
        let paid;
        {
          const $t47168 = b.reels;
          {
            let $t47169;
            $t47169 = List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t47168, Spin$Reels$unhold$clo);
            paid = ({ ...b, reels: $t47169, boost: 1, nudge_left: 0., last_line: named, last_pay: total });
          }
        }
        {
          let out;
          {
            const $t47170 = { $: "Paid", _0: total, _1: named };
            {
              const $t47171 = { $: "Nil" };
              {
                const $t47172 = { $: "Cons", _0: $t47170, _1: $t47171 };
                out = { _0: paid, _1: $t47172 };
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
    let $p47213;
    {
      let $t47173;
      $t47173 = Spin$Reels$reel_at(b, 0);
      $p47213 = Spin$Reels$turn($t47173, dt, 0);
    }
    {
      const r0 = $p47213._0;
      {
        const e0 = $p47213._1;
        {
          let $p47212;
          {
            let $t47174;
            $t47174 = Spin$Reels$reel_at(b, 1);
            $p47212 = Spin$Reels$turn($t47174, dt, 1);
          }
          {
            const r1 = $p47212._0;
            {
              const e1 = $p47212._1;
              {
                let $p47211;
                {
                  let $t47175;
                  $t47175 = Spin$Reels$reel_at(b, 2);
                  $p47211 = Spin$Reels$turn($t47175, dt, 2);
                }
                {
                  const r2 = $p47211._0;
                  {
                    const e2 = $p47211._1;
                    {
                      let turned;
                      {
                        const $t47176 = { $: "Nil" };
                        {
                          let $t47177;
                          $t47177 = { $: "Cons", _0: r2, _1: $t47176 };
                          {
                            let $t47178;
                            $t47178 = { $: "Cons", _0: r1, _1: $t47177 };
                            {
                              let $t47179;
                              $t47179 = { $: "Cons", _0: r0, _1: $t47178 };
                              {
                                let $t47182;
                                {
                                  let $t47181;
                                  {
                                    const $t47180 = b.nudge_left;
                                    $t47181 = ($t47180 - dt);
                                  }
                                  {
                                    const $t45787_i5421 = ($t47181 >= 0.);
                                    if ($t45787_i5421 === true) {
                                      $t47182 = $t47181;
                                    } else {
                                      $t47182 = 0.;
                                    }
                                  }
                                }
                                turned = ({ ...b, reels: $t47179, nudge_left: $t47182 });
                              }
                            }
                          }
                        }
                      }
                      {
                        const $t47183 = { $: "Nil" };
                        {
                          let $t47184;
                          $t47184 = { $: "Cons", _0: e2, _1: $t47183 };
                          {
                            let $t47185;
                            $t47185 = { $: "Cons", _0: e1, _1: $t47184 };
                            {
                              let $t47186;
                              $t47186 = { $: "Cons", _0: e0, _1: $t47185 };
                              {
                                let landed;
                                {
                                  const prepend_reversed_i5416 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_ReelEvent", _0: prepend_reversed$apply$0_List_concat_List_List_ReelEvent };
                                  {
                                    const go_i5417 = { $: "$Clo_go$1_List_concat_List_List_ReelEvent", _0: go$apply$1_List_concat_List_List_ReelEvent, _1: prepend_reversed_i5416 };
                                    {
                                      const $t1113_i5418 = { $: "Nil" };
                                      landed = go$apply$1_List_concat_List_List_ReelEvent(go_i5417, $t47186, $t1113_i5418);
                                    }
                                  }
                                }
                                {
                                  let $p47210;
                                  {
                                    let $t47192;
                                    {
                                      let $t47189;
                                      {
                                        const $t47187 = turned.phase;
                                        {
                                          const $t47188 = { $: "Idle" };
                                          {
                                            const $rc_2655 = (!march_deep_eq($t47187, $t47188));
                                            $t47189 = $rc_2655;
                                          }
                                        }
                                      }
                                      {
                                        let $t47191;
                                        {
                                          let $t47190;
                                          {
                                            const b_i12966 = turned;
                                            {
                                              const $t47138_i12967 = turned.reels;
                                              {
                                                const $t47141_i12968 = { $: "$Clo_$lam0_Spin_Reels_turning$0_Spin_Reels_turning", _0: $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning };
                                                $t47190 = List$any$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool($t47138_i12967, $t47141_i12968);
                                              }
                                            }
                                          }
                                          $t47191 = (!$t47190);
                                        }
                                        $t47192 = ($t47189 && $t47191);
                                      }
                                    }
                                    if ($t47192 === true) {
                                      $p47210 = Spin$Reels$settle(turned);
                                    } else {
                                      {
                                        const $t47193 = { $: "Nil" };
                                        $p47210 = { _0: turned, _1: $t47193 };
                                      }
                                    }
                                  }
                                  {
                                    const settled = $p47210._0;
                                    {
                                      const paid = $p47210._1;
                                      {
                                        let $t47199;
                                        {
                                          let $t47196;
                                          {
                                            const $t47194 = settled.phase;
                                            {
                                              const $t47195 = { $: "Idle" };
                                              {
                                                const $rc_2650 = march_deep_eq($t47194, $t47195);
                                                $t47196 = $rc_2650;
                                              }
                                            }
                                          }
                                          {
                                            let $t47198;
                                            {
                                              const $t47197 = settled.banked;
                                              $t47198 = ($t47197 > 0);
                                            }
                                            $t47199 = ($t47196 && $t47198);
                                          }
                                        }
                                        if ($t47199 === true) {
                                          {
                                            let $p47208;
                                            $p47208 = Spin$Reels$start_spin(settled, rng);
                                            {
                                              const spun = $p47208._0;
                                              {
                                                const after = $p47208._1;
                                                {
                                                  const $t47200 = { $: "Started" };
                                                  {
                                                    const $t47201 = { $: "Nil" };
                                                    {
                                                      const $t47202 = { $: "Cons", _0: $t47200, _1: $t47201 };
                                                      {
                                                        const $t47203 = { $: "Nil" };
                                                        {
                                                          const $t47204 = { $: "Cons", _0: $t47202, _1: $t47203 };
                                                          {
                                                            let $t47205;
                                                            $t47205 = { $: "Cons", _0: paid, _1: $t47204 };
                                                            {
                                                              const $t47206 = { $: "Cons", _0: landed, _1: $t47205 };
                                                              {
                                                                let $t47207;
                                                                {
                                                                  const prepend_reversed_i5412 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_ReelEvent", _0: prepend_reversed$apply$0_List_concat_List_List_ReelEvent };
                                                                  {
                                                                    const go_i5413 = { $: "$Clo_go$1_List_concat_List_List_ReelEvent", _0: go$apply$1_List_concat_List_List_ReelEvent, _1: prepend_reversed_i5412 };
                                                                    {
                                                                      const $t1113_i5414 = { $: "Nil" };
                                                                      $t47207 = go$apply$1_List_concat_List_List_ReelEvent(go_i5413, $t47206, $t1113_i5414);
                                                                    }
                                                                  }
                                                                }
                                                                {
                                                                  const $rc_2649 = { _0: spun, _1: after, _2: $t47207 };
                                                                  return $rc_2649;
                                                                }
                                                              }
                                                            }
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
                                            let $t47209;
                                            {
                                              const xs_i12959 = landed;
                                              {
                                                const ys_i12960 = paid;
                                                switch (xs_i12959.$) {
                                                  case "Nil": {
                                                    $t47209 = paid;
                                                    break;
                                                  }
                                                  case "Cons": {
                                                    const $f987_i12961 = xs_i12959._0;
                                                    const $f988_i12962 = xs_i12959._1;
                                                    {
                                                      const t_i12963 = $f988_i12962;
                                                      {
                                                        const h_i12964 = $f987_i12961;
                                                        {
                                                          const $trmc11_i12965 = { $: "Cons", _0: h_i12964, _1: null };
                                                          List$append$dps$List_ReelEvent$List_ReelEvent$List_ReelEvent(t_i12963, paid, $trmc11_i12965);
                                                          $t47209 = $trmc11_i12965;
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
                                              let $rc_2653;
                                              $rc_2653 = { _0: settled, _1: rng, _2: $t47209 };
                                              return $rc_2653;
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
    const $rc_2668 = ({ ...b, phase: p });
    return $rc_2668;
  }
}
const Spin$Reels$in_phase$clo = { _0: ($_, b, p) => Spin$Reels$in_phase(b, p) };

function Spin$Reels$nudge(b, i) {
  {
    let $t47219;
    {
      let $t47215;
      {
        const $t47214 = b.nudge_left;
        $t47215 = ($t47214 > 0.);
      }
      {
        let $t47218;
        {
          const $t47216 = b.phase;
          {
            const $t47217 = { $: "Idle" };
            {
              const $rc_2671 = march_deep_eq($t47216, $t47217);
              $t47218 = $rc_2671;
            }
          }
        }
        $t47219 = ($t47215 && $t47218);
      }
    }
    if ($t47219 === true) {
      {
        let r;
        r = Spin$Reels$reel_at(b, i);
        {
          let rolled;
          {
            let $t47221;
            {
              const $t47220 = r.pos;
              $t47221 = $t47220;
            }
            {
              let $t47224;
              {
                let $t47223;
                {
                  const $t47222 = r.pos;
                  $t47223 = (($t47222 + 1) < 4611686018427387904 && ($t47222 + 1) >= -4611686018427387904 ? ($t47222 + 1) : march_int_ovf(($t47222 + 1), 0));
                }
                $t47224 = Spin$Reels$wrap($t47223);
              }
              rolled = ({ ...r, from: $t47221, travel: 1., elapsed: 0., duration: 0.16, pos: $t47224 });
            }
          }
          {
            let placed;
            {
              const $t47225 = Spin$Reels$set_reel(b, i, rolled);
              {
                const $t47226 = { $: "Nudging" };
                placed = Spin$Reels$in_phase($t47225, $t47226);
              }
            }
            {
              const $t47227 = { $: "Nudged", _0: i };
              {
                const $t47228 = { $: "Nil" };
                {
                  const $t47229 = { $: "Cons", _0: $t47227, _1: $t47228 };
                  {
                    const $rc_2670 = { _0: placed, _1: $t47229 };
                    return $rc_2670;
                  }
                }
              }
            }
          }
        }
      }
    } else {
      {
        const $t47230 = { $: "Nil" };
        return { _0: b, _1: $t47230 };
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
      const $t47231 = r.held;
      if ($t47231 === true) {
        {
          const $t47232 = { $: "Nil" };
          return { _0: b, _1: $t47232 };
        }
      } else {
        {
          let held;
          {
            const $t47233 = ({ ...r, held: true });
            held = Spin$Reels$set_reel(b, i, $t47233);
          }
          {
            let $t47237;
            {
              const $t47234 = held.reels;
              {
                const $t47236 = { $: "$Clo_$lam0_Spin_Reels_hold$0_Spin_Reels_hold", _0: $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold };
                $t47237 = List$all$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool($t47234, $t47236);
              }
            }
            if ($t47237 === true) {
              {
                let cleared;
                {
                  const $t47238 = held.reels;
                  {
                    let $t47239;
                    $t47239 = List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t47238, Spin$Reels$unhold$clo);
                    cleared = ({ ...held, reels: $t47239, boost: 2 });
                  }
                }
                {
                  const $p47245 = Spin$Reels$bank_spin(cleared);
                  {
                    const free = $p47245._0;
                    {
                      const $t47240 = { $: "Held", _0: i };
                      {
                        const $t47241 = { $: "Doubled" };
                        {
                          const $t47242 = { $: "Nil" };
                          {
                            const $t47243 = { $: "Cons", _0: $t47241, _1: $t47242 };
                            {
                              const $t47244 = { $: "Cons", _0: $t47240, _1: $t47243 };
                              {
                                const $rc_2673 = { _0: free, _1: $t47244 };
                                return $rc_2673;
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
                const $t47246 = { $: "Held", _0: i };
                {
                  const $t47247 = { $: "Nil" };
                  {
                    const $t47248 = { $: "Cons", _0: $t47246, _1: $t47247 };
                    {
                      const $rc_2678 = { _0: held, _1: $t47248 };
                      return $rc_2678;
                    }
                  }
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

function Spin$Table$arch_point(n, i) {
  {
    let a;
    {
      const $t47249 = n.pi;
      {
        let $t47253;
        {
          let $t47252;
          {
            const $t47250 = n.pi;
            {
              const $t47251 = i;
              $t47252 = ($t47250 * $t47251);
            }
          }
          $t47253 = ($t47252 / 12.);
        }
        a = ($t47249 + $t47253);
      }
    }
    {
      let $t47256;
      {
        let $t47255;
        {
          const $t47254 = Math.cos(a);
          $t47255 = (180. * $t47254);
        }
        $t47256 = (200. + $t47255);
      }
      {
        let $t47259;
        {
          let $t47258;
          {
            const $t47257 = Math.sin(a);
            $t47258 = (180. * $t47257);
          }
          $t47259 = (200. + $t47258);
        }
        return ({ x: $t47256, y: $t47259 });
      }
    }
  }
}
const Spin$Table$arch_point$clo = { _0: ($_, n, i) => Spin$Table$arch_point(n, i) };

function Spin$Table$parts(n) {
  {
    let $t47266;
    {
      let $t47260_i5558;
      {
        const go_i14369 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
        {
          const $t915_i14370 = ((12 - 1) < 4611686018427387904 && (12 - 1) >= -4611686018427387904 ? (12 - 1) : march_int_ovf((12 - 1), 1));
          {
            const $t916_i14371 = { $: "Nil" };
            $t47260_i5558 = go$apply$0_List_range(go_i14369, $t915_i14370, $t916_i14371);
          }
        }
      }
      {
        const $t47265_i5559 = { $: "$Clo_$lam0_Spin_Table_arch$0_Spin_Table_arch", _0: $lam0_Spin_Table_arch$apply$0_Spin_Table_arch, _1: n };
        {
          const xs_i14487 = $t47260_i5558;
          {
            const f_i14488 = $t47265_i5559;
            switch (xs_i14487.$) {
              case "Nil": {
                $t47266 = { $: "Nil" };
                break;
              }
              case "Cons": {
                const $f995_i14489 = xs_i14487._0;
                const $f996_i14490 = xs_i14487._1;
                {
                  const t_i14491 = $f996_i14490;
                  {
                    const h_i14492 = $f995_i14489;
                    {
                      let $t993_i14493;
                      $t993_i14493 = f_i14488._0(f_i14488, h_i14492);
                      {
                        const $trmc15_i14494 = { $: "Cons", _0: $t993_i14493, _1: null };
                        List$map$dps$List_Int$Fn_Int_Part$List_Part(t_i14491, f_i14488, $trmc15_i14494);
                        $t47266 = $trmc15_i14494;
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
      let $t47269;
      {
        const $t47267 = ({ x: 20., y: 200. });
        {
          const $t47268 = ({ x: 20., y: 568. });
          $t47269 = { $: "Wall", _0: $t47267, _1: $t47268, _2: 0.5 };
        }
      }
      {
        let $t47272;
        {
          const $t47270 = ({ x: 380., y: 200. });
          {
            const $t47271 = ({ x: 380., y: 760. });
            $t47272 = { $: "Wall", _0: $t47270, _1: $t47271, _2: 0.4 };
          }
        }
        {
          let $t47275;
          {
            const $t47273 = ({ x: 350., y: 262. });
            {
              const $t47274 = ({ x: 350., y: 760. });
              $t47275 = { $: "Wall", _0: $t47273, _1: $t47274, _2: 0.4 };
            }
          }
          {
            let $t47278;
            {
              const $t47276 = ({ x: 350., y: 700. });
              {
                const $t47277 = ({ x: 380., y: 700. });
                $t47278 = { $: "Wall", _0: $t47276, _1: $t47277, _2: 0.1 };
              }
            }
            {
              let $t47281;
              {
                const $t47279 = ({ x: 350., y: 262. });
                {
                  const $t47280 = ({ x: 380., y: 236. });
                  $t47281 = { $: "Gate", _0: $t47279, _1: $t47280 };
                }
              }
              {
                let $t47284;
                {
                  const $t47282 = ({ x: 20., y: 568. });
                  {
                    const $t47283 = ({ x: 124.5, y: 654.6 });
                    $t47284 = { $: "Wall", _0: $t47282, _1: $t47283, _2: 0.3 };
                  }
                }
                {
                  let $t47287;
                  {
                    const $t47285 = ({ x: 350., y: 568. });
                    {
                      const $t47286 = ({ x: 245.5, y: 654.6 });
                      $t47287 = { $: "Wall", _0: $t47285, _1: $t47286, _2: 0.3 };
                    }
                  }
                  {
                    let $t47290;
                    {
                      const $t47288 = ({ x: 62., y: 165. });
                      {
                        const $t47289 = ({ x: 62., y: 300. });
                        $t47290 = { $: "Wall", _0: $t47288, _1: $t47289, _2: 0.4 };
                      }
                    }
                    {
                      let $t47292;
                      {
                        const $t47291 = ({ x: 62., y: 165. });
                        $t47292 = { $: "Peg", _0: $t47291, _1: 4., _2: 0.4 };
                      }
                      {
                        let $t47294;
                        {
                          const $t47293 = ({ x: 62., y: 300. });
                          $t47294 = { $: "Peg", _0: $t47293, _1: 4., _2: 0.4 };
                        }
                        {
                          let $t47297;
                          {
                            const $t47295 = ({ x: 308., y: 165. });
                            {
                              const $t47296 = ({ x: 308., y: 300. });
                              $t47297 = { $: "Wall", _0: $t47295, _1: $t47296, _2: 0.4 };
                            }
                          }
                          {
                            let $t47299;
                            {
                              const $t47298 = ({ x: 308., y: 165. });
                              $t47299 = { $: "Peg", _0: $t47298, _1: 4., _2: 0.4 };
                            }
                            {
                              let $t47301;
                              {
                                const $t47300 = ({ x: 308., y: 300. });
                                $t47301 = { $: "Peg", _0: $t47300, _1: 4., _2: 0.4 };
                              }
                              {
                                let $t47305;
                                {
                                  const $t47302 = ({ x: 20., y: 232. });
                                  {
                                    const $t47303 = ({ x: 62., y: 232. });
                                    {
                                      const $t47304 = { $: "Spinner" };
                                      $t47305 = { $: "Tripwire", _0: $t47302, _1: $t47303, _2: $t47304 };
                                    }
                                  }
                                }
                                {
                                  let $t47308;
                                  {
                                    const $t47306 = ({ x: 133., y: 82. });
                                    {
                                      const $t47307 = ({ x: 133., y: 122. });
                                      $t47308 = { $: "Wall", _0: $t47306, _1: $t47307, _2: 0.4 };
                                    }
                                  }
                                  {
                                    let $t47311;
                                    {
                                      const $t47309 = ({ x: 168., y: 82. });
                                      {
                                        const $t47310 = ({ x: 168., y: 122. });
                                        $t47311 = { $: "Wall", _0: $t47309, _1: $t47310, _2: 0.4 };
                                      }
                                    }
                                    {
                                      let $t47314;
                                      {
                                        const $t47312 = ({ x: 203., y: 82. });
                                        {
                                          const $t47313 = ({ x: 203., y: 122. });
                                          $t47314 = { $: "Wall", _0: $t47312, _1: $t47313, _2: 0.4 };
                                        }
                                      }
                                      {
                                        let $t47317;
                                        {
                                          const $t47315 = ({ x: 238., y: 82. });
                                          {
                                            const $t47316 = ({ x: 238., y: 122. });
                                            $t47317 = { $: "Wall", _0: $t47315, _1: $t47316, _2: 0.4 };
                                          }
                                        }
                                        {
                                          let $t47320;
                                          {
                                            const $t47318 = ({ x: 150.5, y: 104. });
                                            {
                                              const $t47319 = { $: "HoldLane", _0: 0 };
                                              $t47320 = { $: "Sensor", _0: $t47318, _1: 9., _2: $t47319 };
                                            }
                                          }
                                          {
                                            let $t47323;
                                            {
                                              const $t47321 = ({ x: 185.5, y: 104. });
                                              {
                                                const $t47322 = { $: "HoldLane", _0: 1 };
                                                $t47323 = { $: "Sensor", _0: $t47321, _1: 9., _2: $t47322 };
                                              }
                                            }
                                            {
                                              let $t47326;
                                              {
                                                const $t47324 = ({ x: 220.5, y: 104. });
                                                {
                                                  const $t47325 = { $: "HoldLane", _0: 2 };
                                                  $t47326 = { $: "Sensor", _0: $t47324, _1: 9., _2: $t47325 };
                                                }
                                              }
                                              {
                                                let $t47329;
                                                {
                                                  const $t47327 = ({ x: 122., y: 228. });
                                                  {
                                                    const $t47328 = { $: "Bumper", _0: 0 };
                                                    $t47329 = { $: "Kicker", _0: $t47327, _1: 21., _2: $t47328 };
                                                  }
                                                }
                                                {
                                                  let $t47332;
                                                  {
                                                    const $t47330 = ({ x: 249., y: 228. });
                                                    {
                                                      const $t47331 = { $: "Bumper", _0: 1 };
                                                      $t47332 = { $: "Kicker", _0: $t47330, _1: 21., _2: $t47331 };
                                                    }
                                                  }
                                                  {
                                                    let $t47335;
                                                    {
                                                      const $t47333 = ({ x: 185.5, y: 300. });
                                                      {
                                                        const $t47334 = { $: "Bumper", _0: 2 };
                                                        $t47335 = { $: "Kicker", _0: $t47333, _1: 21., _2: $t47334 };
                                                      }
                                                    }
                                                    {
                                                      let $t47340;
                                                      {
                                                        const $t47336 = ({ x: 172., y: 168. });
                                                        {
                                                          const $t47337 = ({ x: 199., y: 168. });
                                                          {
                                                            let $t47339;
                                                            {
                                                              const $t47338 = { $: "Seven" };
                                                              $t47339 = { $: "Loader", _0: $t47338 };
                                                            }
                                                            $t47340 = { $: "Face", _0: $t47336, _1: $t47337, _2: 0., _3: $t47339 };
                                                          }
                                                        }
                                                      }
                                                      {
                                                        let $t47345;
                                                        {
                                                          const $t47341 = ({ x: 24., y: 352. });
                                                          {
                                                            const $t47342 = ({ x: 24., y: 392. });
                                                            {
                                                              let $t47344;
                                                              {
                                                                const $t47343 = { $: "Cherry" };
                                                                $t47344 = { $: "Loader", _0: $t47343 };
                                                              }
                                                              $t47345 = { $: "Face", _0: $t47341, _1: $t47342, _2: 0., _3: $t47344 };
                                                            }
                                                          }
                                                        }
                                                        {
                                                          let $t47350;
                                                          {
                                                            const $t47346 = ({ x: 24., y: 414. });
                                                            {
                                                              const $t47347 = ({ x: 24., y: 454. });
                                                              {
                                                                let $t47349;
                                                                {
                                                                  const $t47348 = { $: "Lemon" };
                                                                  $t47349 = { $: "Loader", _0: $t47348 };
                                                                }
                                                                $t47350 = { $: "Face", _0: $t47346, _1: $t47347, _2: 0., _3: $t47349 };
                                                              }
                                                            }
                                                          }
                                                          {
                                                            let $t47355;
                                                            {
                                                              const $t47351 = ({ x: 346., y: 352. });
                                                              {
                                                                const $t47352 = ({ x: 346., y: 392. });
                                                                {
                                                                  let $t47354;
                                                                  {
                                                                    const $t47353 = { $: "Bell" };
                                                                    $t47354 = { $: "Loader", _0: $t47353 };
                                                                  }
                                                                  $t47355 = { $: "Face", _0: $t47351, _1: $t47352, _2: 0., _3: $t47354 };
                                                                }
                                                              }
                                                            }
                                                            {
                                                              let $t47360;
                                                              {
                                                                const $t47356 = ({ x: 346., y: 414. });
                                                                {
                                                                  const $t47357 = ({ x: 346., y: 454. });
                                                                  {
                                                                    let $t47359;
                                                                    {
                                                                      const $t47358 = { $: "Bars" };
                                                                      $t47359 = { $: "Loader", _0: $t47358 };
                                                                    }
                                                                    $t47360 = { $: "Face", _0: $t47356, _1: $t47357, _2: 0., _3: $t47359 };
                                                                  }
                                                                }
                                                              }
                                                              {
                                                                let $t47364;
                                                                {
                                                                  const $t47361 = ({ x: 42., y: 478. });
                                                                  {
                                                                    const $t47362 = ({ x: 100., y: 595. });
                                                                    {
                                                                      const $t47363 = { $: "Sling" };
                                                                      $t47364 = { $: "Face", _0: $t47361, _1: $t47362, _2: 520., _3: $t47363 };
                                                                    }
                                                                  }
                                                                }
                                                                {
                                                                  let $t47367;
                                                                  {
                                                                    const $t47365 = ({ x: 42., y: 478. });
                                                                    {
                                                                      const $t47366 = ({ x: 42., y: 547. });
                                                                      $t47367 = { $: "Wall", _0: $t47365, _1: $t47366, _2: 0.3 };
                                                                    }
                                                                  }
                                                                  {
                                                                    let $t47370;
                                                                    {
                                                                      const $t47368 = ({ x: 42., y: 547. });
                                                                      {
                                                                        const $t47369 = ({ x: 100., y: 595. });
                                                                        $t47370 = { $: "Wall", _0: $t47368, _1: $t47369, _2: 0.3 };
                                                                      }
                                                                    }
                                                                    {
                                                                      let $t47374;
                                                                      {
                                                                        const $t47371 = ({ x: 328., y: 478. });
                                                                        {
                                                                          const $t47372 = ({ x: 270., y: 595. });
                                                                          {
                                                                            const $t47373 = { $: "Sling" };
                                                                            $t47374 = { $: "Face", _0: $t47371, _1: $t47372, _2: 520., _3: $t47373 };
                                                                          }
                                                                        }
                                                                      }
                                                                      {
                                                                        let $t47377;
                                                                        {
                                                                          const $t47375 = ({ x: 328., y: 478. });
                                                                          {
                                                                            const $t47376 = ({ x: 328., y: 547. });
                                                                            $t47377 = { $: "Wall", _0: $t47375, _1: $t47376, _2: 0.3 };
                                                                          }
                                                                        }
                                                                        {
                                                                          let $t47380;
                                                                          {
                                                                            const $t47378 = ({ x: 328., y: 547. });
                                                                            {
                                                                              const $t47379 = ({ x: 270., y: 595. });
                                                                              $t47380 = { $: "Wall", _0: $t47378, _1: $t47379, _2: 0.3 };
                                                                            }
                                                                          }
                                                                          {
                                                                            const $t47381 = { $: "Nil" };
                                                                            {
                                                                              const $t47382 = { $: "Cons", _0: $t47380, _1: $t47381 };
                                                                              {
                                                                                const $t47383 = { $: "Cons", _0: $t47377, _1: $t47382 };
                                                                                {
                                                                                  const $t47384 = { $: "Cons", _0: $t47374, _1: $t47383 };
                                                                                  {
                                                                                    const $t47385 = { $: "Cons", _0: $t47370, _1: $t47384 };
                                                                                    {
                                                                                      const $t47386 = { $: "Cons", _0: $t47367, _1: $t47385 };
                                                                                      {
                                                                                        const $t47387 = { $: "Cons", _0: $t47364, _1: $t47386 };
                                                                                        {
                                                                                          const $t47388 = { $: "Cons", _0: $t47360, _1: $t47387 };
                                                                                          {
                                                                                            const $t47389 = { $: "Cons", _0: $t47355, _1: $t47388 };
                                                                                            {
                                                                                              const $t47390 = { $: "Cons", _0: $t47350, _1: $t47389 };
                                                                                              {
                                                                                                const $t47391 = { $: "Cons", _0: $t47345, _1: $t47390 };
                                                                                                {
                                                                                                  const $t47392 = { $: "Cons", _0: $t47340, _1: $t47391 };
                                                                                                  {
                                                                                                    const $t47393 = { $: "Cons", _0: $t47335, _1: $t47392 };
                                                                                                    {
                                                                                                      const $t47394 = { $: "Cons", _0: $t47332, _1: $t47393 };
                                                                                                      {
                                                                                                        const $t47395 = { $: "Cons", _0: $t47329, _1: $t47394 };
                                                                                                        {
                                                                                                          const $t47396 = { $: "Cons", _0: $t47326, _1: $t47395 };
                                                                                                          {
                                                                                                            const $t47397 = { $: "Cons", _0: $t47323, _1: $t47396 };
                                                                                                            {
                                                                                                              const $t47398 = { $: "Cons", _0: $t47320, _1: $t47397 };
                                                                                                              {
                                                                                                                const $t47399 = { $: "Cons", _0: $t47317, _1: $t47398 };
                                                                                                                {
                                                                                                                  const $t47400 = { $: "Cons", _0: $t47314, _1: $t47399 };
                                                                                                                  {
                                                                                                                    const $t47401 = { $: "Cons", _0: $t47311, _1: $t47400 };
                                                                                                                    {
                                                                                                                      const $t47402 = { $: "Cons", _0: $t47308, _1: $t47401 };
                                                                                                                      {
                                                                                                                        const $t47403 = { $: "Cons", _0: $t47305, _1: $t47402 };
                                                                                                                        {
                                                                                                                          const $t47404 = { $: "Cons", _0: $t47301, _1: $t47403 };
                                                                                                                          {
                                                                                                                            const $t47405 = { $: "Cons", _0: $t47299, _1: $t47404 };
                                                                                                                            {
                                                                                                                              const $t47406 = { $: "Cons", _0: $t47297, _1: $t47405 };
                                                                                                                              {
                                                                                                                                const $t47407 = { $: "Cons", _0: $t47294, _1: $t47406 };
                                                                                                                                {
                                                                                                                                  const $t47408 = { $: "Cons", _0: $t47292, _1: $t47407 };
                                                                                                                                  {
                                                                                                                                    const $t47409 = { $: "Cons", _0: $t47290, _1: $t47408 };
                                                                                                                                    {
                                                                                                                                      const $t47410 = { $: "Cons", _0: $t47287, _1: $t47409 };
                                                                                                                                      {
                                                                                                                                        const $t47411 = { $: "Cons", _0: $t47284, _1: $t47410 };
                                                                                                                                        {
                                                                                                                                          const $t47412 = { $: "Cons", _0: $t47281, _1: $t47411 };
                                                                                                                                          {
                                                                                                                                            const $t47413 = { $: "Cons", _0: $t47278, _1: $t47412 };
                                                                                                                                            {
                                                                                                                                              const $t47414 = { $: "Cons", _0: $t47275, _1: $t47413 };
                                                                                                                                              {
                                                                                                                                                const $t47415 = { $: "Cons", _0: $t47272, _1: $t47414 };
                                                                                                                                                {
                                                                                                                                                  const $t47416 = { $: "Cons", _0: $t47269, _1: $t47415 };
                                                                                                                                                  {
                                                                                                                                                    const $t47417 = { $: "Nil" };
                                                                                                                                                    {
                                                                                                                                                      const $t47418 = { $: "Cons", _0: $t47416, _1: $t47417 };
                                                                                                                                                      {
                                                                                                                                                        const $t47419 = { $: "Cons", _0: $t47266, _1: $t47418 };
                                                                                                                                                        {
                                                                                                                                                          const prepend_reversed_i5434 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Part", _0: prepend_reversed$apply$0_List_concat_List_List_Part };
                                                                                                                                                          {
                                                                                                                                                            const go_i5435 = { $: "$Clo_go$1_List_concat_List_List_Part", _0: go$apply$1_List_concat_List_List_Part, _1: prepend_reversed_i5434 };
                                                                                                                                                            {
                                                                                                                                                              const $t1113_i5436 = { $: "Nil" };
                                                                                                                                                              return go$apply$1_List_concat_List_List_Part(go_i5435, $t47419, $t1113_i5436);
                                                                                                                                                            }
                                                                                                                                                          }
                                                                                                                                                        }
                                                                                                                                                      }
                                                                                                                                                    }
                                                                                                                                                  }
                                                                                                                                                }
                                                                                                                                              }
                                                                                                                                            }
                                                                                                                                          }
                                                                                                                                        }
                                                                                                                                      }
                                                                                                                                    }
                                                                                                                                  }
                                                                                                                                }
                                                                                                                              }
                                                                                                                            }
                                                                                                                          }
                                                                                                                        }
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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

function Spin$Table$tip(f, a) {
  {
    const $t47432 = f.pivot;
    {
      let $t47437;
      {
        let $t47435;
        {
          const $t47433 = Math.cos(a);
          {
            const $t47434 = Math.sin(a);
            $t47435 = ({ x: $t47433, y: $t47434 });
          }
        }
        {
          const $t47436 = f.length;
          $t47437 = Arcade$Vec2$scale($t47435, $t47436);
        }
      }
      return Arcade$Vec2$add($t47432, $t47437);
    }
  }
}
const Spin$Table$tip$clo = { _0: ($_, f, a) => Spin$Table$tip(f, a) };

function Spin$Table$in_lane(p) {
  {
    let $t47439;
    {
      const $t47438 = p.x;
      $t47439 = ($t47438 > 350.);
    }
    {
      let $t47441;
      {
        const $t47440 = p.y;
        $t47441 = ($t47440 > 262.);
      }
      return ($t47439 && $t47441);
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
        let $t47466;
        {
          let $t47459;
          {
            let $t47456;
            {
              const $t47455 = (6. * k);
              $t47456 = (cx - $t47455);
            }
            {
              let $t47458;
              {
                const $t47457 = (2. * k);
                $t47458 = (cy + $t47457);
              }
              $t47459 = ({ x: $t47456, y: $t47458 });
            }
          }
          {
            let $t47464;
            {
              let $t47461;
              {
                const $t47460 = (2. * k);
                $t47461 = (cx + $t47460);
              }
              {
                let $t47463;
                {
                  const $t47462 = (10. * k);
                  $t47463 = (cy - $t47462);
                }
                $t47464 = ({ x: $t47461, y: $t47463 });
              }
            }
            {
              const $t47465 = (2. * k);
              $t47466 = Spin$Draw$stick($t47459, $t47464, $t47465, "#3fbf4f");
            }
          }
        }
        {
          let $t47478;
          {
            let $t47471;
            {
              let $t47468;
              {
                const $t47467 = (6. * k);
                $t47468 = (cx + $t47467);
              }
              {
                const $t47470 = (cy + k);
                $t47471 = ({ x: $t47468, y: $t47470 });
              }
            }
            {
              let $t47476;
              {
                let $t47473;
                {
                  const $t47472 = (2. * k);
                  $t47473 = (cx + $t47472);
                }
                {
                  let $t47475;
                  {
                    const $t47474 = (10. * k);
                    $t47475 = (cy - $t47474);
                  }
                  $t47476 = ({ x: $t47473, y: $t47475 });
                }
              }
              {
                const $t47477 = (2. * k);
                $t47478 = Spin$Draw$stick($t47471, $t47476, $t47477, "#3fbf4f");
              }
            }
          }
          {
            let $t47485;
            {
              let $t47480;
              {
                const $t47479 = (6. * k);
                $t47480 = (cx - $t47479);
              }
              {
                let $t47482;
                {
                  const $t47481 = (5. * k);
                  $t47482 = (cy + $t47481);
                }
                {
                  const $t47483 = (6.5 * k);
                  {
                    const $t47484 = Spin$View$colour(s);
                    $t47485 = { $: "Disc", _0: $t47480, _1: $t47482, _2: $t47483, _3: $t47484 };
                  }
                }
              }
            }
            {
              let $t47492;
              {
                let $t47487;
                {
                  const $t47486 = (6. * k);
                  $t47487 = (cx + $t47486);
                }
                {
                  let $t47489;
                  {
                    const $t47488 = (4. * k);
                    $t47489 = (cy + $t47488);
                  }
                  {
                    const $t47490 = (6.5 * k);
                    {
                      const $t47491 = Spin$View$colour(s);
                      $t47492 = { $: "Disc", _0: $t47487, _1: $t47489, _2: $t47490, _3: $t47491 };
                    }
                  }
                }
              }
              {
                let $t47498;
                {
                  let $t47494;
                  {
                    const $t47493 = (8. * k);
                    $t47494 = (cx - $t47493);
                  }
                  {
                    let $t47496;
                    {
                      const $t47495 = (3. * k);
                      $t47496 = (cy + $t47495);
                    }
                    {
                      const $t47497 = (1.8 * k);
                      $t47498 = { $: "Disc", _0: $t47494, _1: $t47496, _2: $t47497, _3: "#ffd0d6" };
                    }
                  }
                }
                {
                  const $t47499 = { $: "Nil" };
                  {
                    const $t47500 = { $: "Cons", _0: $t47498, _1: $t47499 };
                    {
                      const $t47501 = { $: "Cons", _0: $t47492, _1: $t47500 };
                      {
                        const $t47502 = { $: "Cons", _0: $t47485, _1: $t47501 };
                        {
                          const $t47503 = { $: "Cons", _0: $t47478, _1: $t47502 };
                          return { $: "Cons", _0: $t47466, _1: $t47503 };
                        }
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
        let $t47508;
        {
          const $t47504 = (12. * k);
          {
            const $t47505 = (8.5 * k);
            {
              let $t47506;
              {
                let $t47443_i5604;
                {
                  const go_i14380 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                  {
                    const $t915_i14381 = ((12 - 1) < 4611686018427387904 && (12 - 1) >= -4611686018427387904 ? (12 - 1) : march_int_ovf((12 - 1), 1));
                    {
                      const $t916_i14382 = { $: "Nil" };
                      $t47443_i5604 = go$apply$0_List_range(go_i14380, $t915_i14381, $t916_i14382);
                    }
                  }
                }
                {
                  const $t47454_i5605 = { $: "$Clo_$lam0_Spin_View_ellipse$0_Spin_View_ellipse", _0: $lam0_Spin_View_ellipse$apply$0_Spin_View_ellipse, _1: cx, _2: cy, _3: n, _4: $t47504, _5: $t47505 };
                  {
                    const xs_i14495 = $t47443_i5604;
                    {
                      const f_i14496 = $t47454_i5605;
                      switch (xs_i14495.$) {
                        case "Nil": {
                          $t47506 = { $: "Nil" };
                          break;
                        }
                        case "Cons": {
                          const $f995_i14497 = xs_i14495._0;
                          const $f996_i14498 = xs_i14495._1;
                          {
                            const t_i14499 = $f996_i14498;
                            {
                              const h_i14500 = $f995_i14497;
                              {
                                let $t993_i14501;
                                $t993_i14501 = f_i14496._0(f_i14496, h_i14500);
                                {
                                  const $trmc15_i14502 = { $: "Cons", _0: $t993_i14501, _1: null };
                                  List$map$dps$List_Int$Fn_Int_R_x_Float_y_Float$List_R_x_Float_y_Float(t_i14499, f_i14496, $trmc15_i14502);
                                  $t47506 = $trmc15_i14502;
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
                const $t47507 = Spin$View$colour(s);
                $t47508 = { $: "Poly", _0: $t47506, _1: $t47507 };
              }
            }
          }
        }
        {
          let $t47514;
          {
            let $t47510;
            {
              const $t47509 = (4. * k);
              $t47510 = (cx - $t47509);
            }
            {
              let $t47512;
              {
                const $t47511 = (3. * k);
                $t47512 = (cy - $t47511);
              }
              {
                const $t47513 = (2. * k);
                $t47514 = { $: "Disc", _0: $t47510, _1: $t47512, _2: $t47513, _3: "#fff7c2" };
              }
            }
          }
          {
            const $t47515 = { $: "Nil" };
            {
              const $t47516 = { $: "Cons", _0: $t47514, _1: $t47515 };
              return { $: "Cons", _0: $t47508, _1: $t47516 };
            }
          }
        }
      }
      break;
    }
    case "Bell": {
      {
        let $t47555;
        {
          let $t47521;
          {
            let $t47518;
            {
              const $t47517 = (11. * k);
              $t47518 = (cx - $t47517);
            }
            {
              let $t47520;
              {
                const $t47519 = (8. * k);
                $t47520 = (cy + $t47519);
              }
              $t47521 = ({ x: $t47518, y: $t47520 });
            }
          }
          {
            let $t47526;
            {
              let $t47523;
              {
                const $t47522 = (8. * k);
                $t47523 = (cx - $t47522);
              }
              {
                const $t47525 = (cy - k);
                $t47526 = ({ x: $t47523, y: $t47525 });
              }
            }
            {
              let $t47531;
              {
                let $t47528;
                {
                  const $t47527 = (5. * k);
                  $t47528 = (cx - $t47527);
                }
                {
                  let $t47530;
                  {
                    const $t47529 = (9. * k);
                    $t47530 = (cy - $t47529);
                  }
                  $t47531 = ({ x: $t47528, y: $t47530 });
                }
              }
              {
                let $t47536;
                {
                  let $t47533;
                  {
                    const $t47532 = (5. * k);
                    $t47533 = (cx + $t47532);
                  }
                  {
                    let $t47535;
                    {
                      const $t47534 = (9. * k);
                      $t47535 = (cy - $t47534);
                    }
                    $t47536 = ({ x: $t47533, y: $t47535 });
                  }
                }
                {
                  let $t47541;
                  {
                    let $t47538;
                    {
                      const $t47537 = (8. * k);
                      $t47538 = (cx + $t47537);
                    }
                    {
                      const $t47540 = (cy - k);
                      $t47541 = ({ x: $t47538, y: $t47540 });
                    }
                  }
                  {
                    let $t47546;
                    {
                      let $t47543;
                      {
                        const $t47542 = (11. * k);
                        $t47543 = (cx + $t47542);
                      }
                      {
                        let $t47545;
                        {
                          const $t47544 = (8. * k);
                          $t47545 = (cy + $t47544);
                        }
                        $t47546 = ({ x: $t47543, y: $t47545 });
                      }
                    }
                    {
                      const $t47547 = { $: "Nil" };
                      {
                        const $t47548 = { $: "Cons", _0: $t47546, _1: $t47547 };
                        {
                          const $t47549 = { $: "Cons", _0: $t47541, _1: $t47548 };
                          {
                            const $t47550 = { $: "Cons", _0: $t47536, _1: $t47549 };
                            {
                              const $t47551 = { $: "Cons", _0: $t47531, _1: $t47550 };
                              {
                                const $t47552 = { $: "Cons", _0: $t47526, _1: $t47551 };
                                {
                                  const $t47553 = { $: "Cons", _0: $t47521, _1: $t47552 };
                                  {
                                    const $t47554 = Spin$View$colour(s);
                                    $t47555 = { $: "Poly", _0: $t47553, _1: $t47554 };
                                  }
                                }
                              }
                            }
                          }
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
          let $t47559;
          {
            let $t47557;
            {
              const $t47556 = (9. * k);
              $t47557 = (cy + $t47556);
            }
            {
              const $t47558 = (3. * k);
              $t47559 = { $: "Disc", _0: cx, _1: $t47557, _2: $t47558, _3: "#c47a00" };
            }
          }
          {
            let $t47563;
            {
              let $t47561;
              {
                const $t47560 = (11. * k);
                $t47561 = (cy - $t47560);
              }
              {
                const $t47562 = (2. * k);
                $t47563 = { $: "Disc", _0: cx, _1: $t47561, _2: $t47562, _3: "#c47a00" };
              }
            }
            {
              const $t47564 = { $: "Nil" };
              {
                const $t47565 = { $: "Cons", _0: $t47563, _1: $t47564 };
                {
                  const $t47566 = { $: "Cons", _0: $t47559, _1: $t47565 };
                  return { $: "Cons", _0: $t47555, _1: $t47566 };
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
        let $t47573;
        {
          let $t47568;
          {
            const $t47567 = (17. * k);
            $t47568 = (cx - $t47567);
          }
          {
            let $t47570;
            {
              const $t47569 = (7.5 * k);
              $t47570 = (cy - $t47569);
            }
            {
              const $t47571 = (34. * k);
              {
                const $t47572 = (15. * k);
                $t47573 = { $: "Box", _0: $t47568, _1: $t47570, _2: $t47571, _3: $t47572, _4: "#1b1b24" };
              }
            }
          }
        }
        {
          let $t47578;
          {
            let $t47575;
            {
              const $t47574 = (0.5 * k);
              $t47575 = (cy + $t47574);
            }
            {
              const $t47576 = (10. * k);
              {
                const $t47577 = Spin$View$colour(s);
                $t47578 = { $: "Label", _0: "BAR", _1: cx, _2: $t47575, _3: $t47576, _4: $t47577 };
              }
            }
          }
          {
            const $t47579 = { $: "Nil" };
            {
              const $t47580 = { $: "Cons", _0: $t47578, _1: $t47579 };
              return { $: "Cons", _0: $t47573, _1: $t47580 };
            }
          }
        }
      }
      break;
    }
    case "Seven": {
      {
        let $t47586;
        {
          const $t47582 = (cx + k);
          {
            let $t47584;
            {
              const $t47583 = (1.5 * k);
              $t47584 = (cy + $t47583);
            }
            {
              const $t47585 = (28. * k);
              $t47586 = { $: "Label", _0: "7", _1: $t47582, _2: $t47584, _3: $t47585, _4: "#5a0018" };
            }
          }
        }
        {
          let $t47589;
          {
            const $t47587 = (28. * k);
            {
              const $t47588 = Spin$View$colour(s);
              $t47589 = { $: "Label", _0: "7", _1: cx, _2: cy, _3: $t47587, _4: $t47588 };
            }
          }
          {
            const $t47590 = { $: "Nil" };
            {
              const $t47591 = { $: "Cons", _0: $t47589, _1: $t47590 };
              return { $: "Cons", _0: $t47586, _1: $t47591 };
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
    let $p47661;
    {
      const $t47592 = m.table;
      $p47661 = $t47592.reel_window;
    }
    {
      const wx = $p47661._0;
      {
        const wy = $p47661._1;
        {
          const wh = $p47661._3;
          {
            let r;
            {
              const $t47593 = m.bank;
              r = Spin$Reels$reel_at($t47593, i);
            }
            {
              let x0;
              {
                let $t47595;
                {
                  const $t47594 = i;
                  $t47595 = (60. * $t47594);
                }
                x0 = (wx + $t47595);
              }
              {
                let line_y;
                {
                  const $t47596 = (wh / 2.);
                  line_y = (wy + $t47596);
                }
                {
                  let shown;
                  shown = Spin$Reels$shown(r);
                  {
                    const base = Math.floor(shown);
                    {
                      let frac;
                      {
                        const $t47597 = base;
                        frac = (shown - $t47597);
                      }
                      {
                        const $t47598 = march_int_ovf(-(2), 3);
                        {
                          let $t47599;
                          {
                            const go_i5660 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: $t47598 };
                            {
                              const $t915_i5661 = ((3 - 1) < 4611686018427387904 && (3 - 1) >= -4611686018427387904 ? (3 - 1) : march_int_ovf((3 - 1), 1));
                              {
                                const $t916_i5662 = { $: "Nil" };
                                $t47599 = go$apply$0_List_range(go_i5660, $t915_i5661, $t916_i5662);
                              }
                            }
                          }
                          {
                            let $t47619;
                            $t47619 = { $: "$Clo_$lam0_Spin_View_reel_ops$0_Spin_View_reel_ops", _0: $lam0_Spin_View_reel_ops$apply$0_Spin_View_reel_ops, _1: base, _2: frac, _3: line_y, _4: m, _5: r, _6: x0 };
                            {
                              const $t47620 = List$map$List_Int$Fn_Int_List_Op($t47599, $t47619);
                              {
                                let cells;
                                {
                                  const prepend_reversed_i5655 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                  {
                                    const go_i5656 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5655 };
                                    {
                                      const $t1113_i5657 = { $: "Nil" };
                                      cells = go$apply$1_List_concat_List_List_Op(go_i5656, $t47620, $t1113_i5657);
                                    }
                                  }
                                }
                                {
                                  const $t47621 = r.held;
                                  {
                                    let held;
                                    if ($t47621 === true) {
                                      {
                                        let $t47625;
                                        {
                                          const $t47622 = (x0 + 2.);
                                          {
                                            let $t47624;
                                            {
                                              const $t47623 = (wy + wh);
                                              $t47624 = ($t47623 - 14.);
                                            }
                                            $t47625 = { $: "Box", _0: $t47622, _1: $t47624, _2: 56., _3: 12., _4: "rgba(40,200,90,0.85)" };
                                          }
                                        }
                                        {
                                          let $t47629;
                                          {
                                            const $t47626 = (x0 + 30.);
                                            {
                                              let $t47628;
                                              {
                                                const $t47627 = (wy + wh);
                                                $t47628 = ($t47627 - 8.);
                                              }
                                              $t47629 = { $: "Label", _0: "HELD", _1: $t47626, _2: $t47628, _3: 9., _4: "#eaffea" };
                                            }
                                          }
                                          {
                                            const $t47630 = { $: "Nil" };
                                            {
                                              const $t47631 = { $: "Cons", _0: $t47629, _1: $t47630 };
                                              held = { $: "Cons", _0: $t47625, _1: $t47631 };
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      held = { $: "Nil" };
                                    }
                                    {
                                      const $t47632 = { $: "ClipBox", _0: x0, _1: wy, _2: 60., _3: wh };
                                      {
                                        const $t47633 = { $: "Box", _0: x0, _1: wy, _2: 60., _3: wh, _4: "#f6f0e2" };
                                        {
                                          const $t47634 = { $: "Nil" };
                                          {
                                            const $t47635 = { $: "Cons", _0: $t47633, _1: $t47634 };
                                            {
                                              const $t47636 = { $: "Cons", _0: $t47632, _1: $t47635 };
                                              {
                                                const $t47637 = { $: "Box", _0: x0, _1: wy, _2: 60., _3: 14., _4: "rgba(0,0,0,0.22)" };
                                                {
                                                  let $t47640;
                                                  {
                                                    let $t47639;
                                                    {
                                                      const $t47638 = (wy + wh);
                                                      $t47639 = ($t47638 - 14.);
                                                    }
                                                    $t47640 = { $: "Box", _0: x0, _1: $t47639, _2: 60., _3: 14., _4: "rgba(0,0,0,0.22)" };
                                                  }
                                                  {
                                                    const $t47641 = { $: "Nil" };
                                                    {
                                                      const $t47642 = { $: "Cons", _0: $t47640, _1: $t47641 };
                                                      {
                                                        const $t47643 = { $: "Cons", _0: $t47637, _1: $t47642 };
                                                        {
                                                          const $t47644 = { $: "Unclip" };
                                                          {
                                                            const $t47645 = { $: "Nil" };
                                                            {
                                                              const $t47646 = { $: "Cons", _0: $t47644, _1: $t47645 };
                                                              {
                                                                const $t47647 = (i > 0);
                                                                {
                                                                  let $t47653;
                                                                  if ($t47647 === true) {
                                                                    {
                                                                      let $t47651;
                                                                      {
                                                                        const $t47648 = ({ x: x0, y: wy });
                                                                        {
                                                                          let $t47650;
                                                                          {
                                                                            const $t47649 = (wy + wh);
                                                                            $t47650 = ({ x: x0, y: $t47649 });
                                                                          }
                                                                          $t47651 = Spin$Draw$stick($t47648, $t47650, 2., "#3a2350");
                                                                        }
                                                                      }
                                                                      {
                                                                        const $t47652 = { $: "Nil" };
                                                                        $t47653 = { $: "Cons", _0: $t47651, _1: $t47652 };
                                                                      }
                                                                    }
                                                                  } else {
                                                                    $t47653 = { $: "Nil" };
                                                                  }
                                                                  {
                                                                    const $t47654 = { $: "Nil" };
                                                                    {
                                                                      const $t47655 = { $: "Cons", _0: $t47653, _1: $t47654 };
                                                                      {
                                                                        const $t47656 = { $: "Cons", _0: $t47646, _1: $t47655 };
                                                                        {
                                                                          const $t47657 = { $: "Cons", _0: held, _1: $t47656 };
                                                                          {
                                                                            const $t47658 = { $: "Cons", _0: $t47643, _1: $t47657 };
                                                                            {
                                                                              const $t47659 = { $: "Cons", _0: cells, _1: $t47658 };
                                                                              {
                                                                                const $t47660 = { $: "Cons", _0: $t47636, _1: $t47659 };
                                                                                {
                                                                                  const prepend_reversed_i5642 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                                                  {
                                                                                    const go_i5643 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5642 };
                                                                                    {
                                                                                      const $t1113_i5644 = { $: "Nil" };
                                                                                      return go$apply$1_List_concat_List_List_Op(go_i5643, $t47660, $t1113_i5644);
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
    let $p47691;
    {
      const $t47662 = m.table;
      $p47691 = $t47662.reel_window;
    }
    {
      const wx = $p47691._0;
      {
        const wy = $p47691._1;
        {
          let cx;
          {
            const $t47663 = (wx + 30.);
            {
              let $t47667;
              {
                let $t47666;
                {
                  let $t47665;
                  {
                    const $t47664 = m.bank;
                    $t47665 = $t47664.armed;
                  }
                  $t47666 = $t47665;
                }
                $t47667 = (60. * $t47666);
              }
              cx = ($t47663 + $t47667);
            }
          }
          {
            let pulse;
            {
              let $t47671;
              {
                let $t47670;
                {
                  let $t47669;
                  {
                    const $t47668 = m.clock;
                    $t47669 = ($t47668 * 6.);
                  }
                  $t47670 = Math.sin($t47669);
                }
                $t47671 = (0.4 * $t47670);
              }
              pulse = (0.6 + $t47671);
            }
            {
              let $t47685;
              {
                let $t47674;
                {
                  const $t47672 = (cx - 7.);
                  {
                    const $t47673 = (wy - 16.);
                    $t47674 = ({ x: $t47672, y: $t47673 });
                  }
                }
                {
                  let $t47677;
                  {
                    const $t47675 = (cx + 7.);
                    {
                      const $t47676 = (wy - 16.);
                      $t47677 = ({ x: $t47675, y: $t47676 });
                    }
                  }
                  {
                    let $t47679;
                    {
                      const $t47678 = (wy - 7.);
                      $t47679 = ({ x: cx, y: $t47678 });
                    }
                    {
                      const $t47680 = { $: "Nil" };
                      {
                        const $t47681 = { $: "Cons", _0: $t47679, _1: $t47680 };
                        {
                          const $t47682 = { $: "Cons", _0: $t47677, _1: $t47681 };
                          {
                            const $t47683 = { $: "Cons", _0: $t47674, _1: $t47682 };
                            {
                              const $t47684 = Spin$Draw$rgba(124, 255, 122, pulse);
                              $t47685 = { $: "Poly", _0: $t47683, _1: $t47684 };
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              {
                let $t47688;
                {
                  const $t47686 = (wy - 24.);
                  {
                    const $t47687 = Spin$Draw$rgba(124, 255, 122, pulse);
                    $t47688 = { $: "Label", _0: "LOAD", _1: cx, _2: $t47686, _3: 8., _4: $t47687 };
                  }
                }
                {
                  const $t47689 = { $: "Nil" };
                  {
                    const $t47690 = { $: "Cons", _0: $t47688, _1: $t47689 };
                    return { $: "Cons", _0: $t47685, _1: $t47690 };
                  }
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
    let $p47778;
    {
      const $t47692 = m.table;
      $p47778 = $t47692.reel_window;
    }
    {
      const wx = $p47778._0;
      {
        const wy = $p47778._1;
        {
          const ww = $p47778._2;
          {
            const wh = $p47778._3;
            {
              const b = m.bank;
              {
                let line_y;
                {
                  const $t47693 = (wh / 2.);
                  line_y = (wy + $t47693);
                }
                {
                  let $t47695;
                  {
                    const go_i5700 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                    {
                      const $t915_i5701 = ((5 - 1) < 4611686018427387904 && (5 - 1) >= -4611686018427387904 ? (5 - 1) : march_int_ovf((5 - 1), 1));
                      {
                        const $t916_i5702 = { $: "Nil" };
                        $t47695 = go$apply$0_List_range(go_i5700, $t915_i5701, $t916_i5702);
                      }
                    }
                  }
                  {
                    let $t47708;
                    $t47708 = { $: "$Clo_$lam0_Spin_View_machine_ops$0_Spin_View_machine_ops", _0: $lam0_Spin_View_machine_ops$apply$0_Spin_View_machine_ops, _1: b, _2: wh, _3: ww, _4: wx, _5: wy };
                    {
                      const spins = List$map$List_Int$Fn_Int_Op($t47695, $t47708);
                      {
                        let $t47710;
                        {
                          const $t47709 = b.nudge_left;
                          $t47710 = ($t47709 > 0.);
                        }
                        {
                          let nudge;
                          if ($t47710 === true) {
                            {
                              let f;
                              {
                                const $t47711 = b.nudge_left;
                                f = ($t47711 / 4.);
                              }
                              {
                                let $t47716;
                                {
                                  let $t47714;
                                  {
                                    const $t47713 = (wy + wh);
                                    $t47714 = ($t47713 + 26.);
                                  }
                                  {
                                    const $t47715 = (ww * f);
                                    $t47716 = { $: "Box", _0: wx, _1: $t47714, _2: $t47715, _3: 5., _4: "#ff3fa4" };
                                  }
                                }
                                {
                                  let $t47721;
                                  {
                                    let $t47718;
                                    {
                                      const $t47717 = (ww / 2.);
                                      $t47718 = (wx + $t47717);
                                    }
                                    {
                                      let $t47720;
                                      {
                                        const $t47719 = (wy + wh);
                                        $t47720 = ($t47719 + 40.);
                                      }
                                      $t47721 = { $: "Label", _0: "NUDGE", _1: $t47718, _2: $t47720, _3: 10., _4: "#ff8fcf" };
                                    }
                                  }
                                  {
                                    const $t47722 = { $: "Nil" };
                                    {
                                      const $t47723 = { $: "Cons", _0: $t47721, _1: $t47722 };
                                      nudge = { $: "Cons", _0: $t47716, _1: $t47723 };
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            nudge = { $: "Nil" };
                          }
                          {
                            let $t47725;
                            {
                              const $t47724 = b.boost;
                              $t47725 = ($t47724 > 1);
                            }
                            {
                              let boost;
                              if ($t47725 === true) {
                                {
                                  let $t47732;
                                  {
                                    let $t47728;
                                    {
                                      let $t47727;
                                      {
                                        const $t47726 = b.boost;
                                        $t47727 = String($t47726);
                                      }
                                      {
                                        const $rc_2680 = ("x" + $t47727);
                                        $t47728 = $rc_2680;
                                      }
                                    }
                                    {
                                      let $t47730;
                                      {
                                        const $t47729 = (wx + ww);
                                        $t47730 = ($t47729 + 18.);
                                      }
                                      $t47732 = { $: "Label", _0: $t47728, _1: $t47730, _2: line_y, _3: 16., _4: "#ffd36b" };
                                    }
                                  }
                                  {
                                    const $t47733 = { $: "Nil" };
                                    {
                                      const $rc_2682 = { $: "Cons", _0: $t47732, _1: $t47733 };
                                      boost = $rc_2682;
                                    }
                                  }
                                }
                              } else {
                                boost = { $: "Nil" };
                              }
                              {
                                let $t47738;
                                {
                                  const $t47734 = (wx - 8.);
                                  {
                                    const $t47735 = (wy - 8.);
                                    {
                                      const $t47736 = (ww + 16.);
                                      {
                                        const $t47737 = (wh + 16.);
                                        $t47738 = { $: "Box", _0: $t47734, _1: $t47735, _2: $t47736, _3: $t47737, _4: "#2b1645" };
                                      }
                                    }
                                  }
                                }
                                {
                                  let $t47744;
                                  {
                                    const $t47739 = (wx - 4.);
                                    {
                                      const $t47740 = (wy - 4.);
                                      {
                                        const $t47741 = (ww + 8.);
                                        {
                                          const $t47742 = (wh + 8.);
                                          $t47744 = { $: "Box", _0: $t47739, _1: $t47740, _2: $t47741, _3: $t47742, _4: "#ffd36b" };
                                        }
                                      }
                                    }
                                  }
                                  {
                                    const $t47745 = { $: "Nil" };
                                    {
                                      const $t47746 = { $: "Cons", _0: $t47744, _1: $t47745 };
                                      {
                                        const $t47747 = { $: "Cons", _0: $t47738, _1: $t47746 };
                                        {
                                          const $t47748 = { $: "Nil" };
                                          {
                                            const $t47749 = { $: "Cons", _0: 2, _1: $t47748 };
                                            {
                                              const $t47750 = { $: "Cons", _0: 1, _1: $t47749 };
                                              {
                                                const $t47751 = { $: "Cons", _0: 0, _1: $t47750 };
                                                {
                                                  let $t47753;
                                                  $t47753 = { $: "$Clo_$lam1_Spin_View_machine_ops$1_Spin_View_machine_ops", _0: $lam1_Spin_View_machine_ops$apply$1_Spin_View_machine_ops, _1: m };
                                                  {
                                                    const $t47754 = List$map$List_Int$Fn_Int_List_Op($t47751, $t47753);
                                                    {
                                                      let $t47755;
                                                      {
                                                        const prepend_reversed_i5685 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                        {
                                                          const go_i5686 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5685 };
                                                          {
                                                            const $t1113_i5687 = { $: "Nil" };
                                                            $t47755 = go$apply$1_List_concat_List_List_Op(go_i5686, $t47754, $t1113_i5687);
                                                          }
                                                        }
                                                      }
                                                      {
                                                        let $t47759;
                                                        {
                                                          const $t47756 = (wx - 6.);
                                                          {
                                                            let $t47758;
                                                            {
                                                              const $t47757 = (wx + ww);
                                                              $t47758 = ($t47757 + 6.);
                                                            }
                                                            $t47759 = { $: "Line", _0: $t47756, _1: line_y, _2: $t47758, _3: line_y, _4: 2., _5: "rgba(255,40,80,0.75)" };
                                                          }
                                                        }
                                                        {
                                                          const $t47760 = { $: "Nil" };
                                                          {
                                                            const $t47761 = { $: "Cons", _0: $t47759, _1: $t47760 };
                                                            {
                                                              const $t47762 = Spin$View$armed_ops(m);
                                                              {
                                                                let $t47766;
                                                                {
                                                                  const $t47763 = (wx - 22.);
                                                                  {
                                                                    let $t47765;
                                                                    {
                                                                      const $t47764 = (wy + wh);
                                                                      $t47765 = ($t47764 + 14.);
                                                                    }
                                                                    $t47766 = { $: "Label", _0: "SPINS", _1: $t47763, _2: $t47765, _3: 8., _4: "#5cf2ff" };
                                                                  }
                                                                }
                                                                {
                                                                  const $t47767 = { $: "Nil" };
                                                                  {
                                                                    const $t47768 = { $: "Cons", _0: $t47766, _1: $t47767 };
                                                                    {
                                                                      const $t47769 = { $: "Nil" };
                                                                      {
                                                                        const $t47770 = { $: "Cons", _0: $t47768, _1: $t47769 };
                                                                        {
                                                                          const $t47771 = { $: "Cons", _0: boost, _1: $t47770 };
                                                                          {
                                                                            const $t47772 = { $: "Cons", _0: nudge, _1: $t47771 };
                                                                            {
                                                                              const $t47773 = { $: "Cons", _0: spins, _1: $t47772 };
                                                                              {
                                                                                const $t47774 = { $: "Cons", _0: $t47762, _1: $t47773 };
                                                                                {
                                                                                  const $t47775 = { $: "Cons", _0: $t47761, _1: $t47774 };
                                                                                  {
                                                                                    const $t47776 = { $: "Cons", _0: $t47755, _1: $t47775 };
                                                                                    {
                                                                                      const $t47777 = { $: "Cons", _0: $t47747, _1: $t47776 };
                                                                                      {
                                                                                        const prepend_reversed_i5676 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                                                        {
                                                                                          const go_i5677 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5676 };
                                                                                          {
                                                                                            const $t1113_i5678 = { $: "Nil" };
                                                                                            return go$apply$1_List_concat_List_List_Op(go_i5677, $t47777, $t1113_i5678);
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
      const $f47922 = p._0;
      const $f47923 = p._1;
      const $f47924 = p._2;
      {
        const b = $f47923;
        {
          const a = $f47922;
          {
            const $t47786 = Spin$Draw$stick(a, b, 4., "#b9a6ff");
            {
              const $t47787 = { $: "Nil" };
              return { $: "Cons", _0: $t47786, _1: $t47787 };
            }
          }
        }
      }
      break;
    }
    case "Peg": {
      const $f47933 = p._0;
      const $f47934 = p._1;
      const $f47935 = p._2;
      {
        const r = $f47934;
        {
          const c = $f47933;
          {
            let $t47792;
            {
              const $t47788 = c.x;
              {
                const $t47789 = c.y;
                {
                  const $t47790 = (r + 1.);
                  $t47792 = { $: "Disc", _0: $t47788, _1: $t47789, _2: $t47790, _3: "#b9a6ff" };
                }
              }
            }
            {
              const $t47793 = { $: "Nil" };
              {
                const $rc_2686 = { $: "Cons", _0: $t47792, _1: $t47793 };
                return $rc_2686;
              }
            }
          }
        }
      }
      break;
    }
    case "Gate": {
      const $f47944 = p._0;
      const $f47945 = p._1;
      {
        const b = $f47945;
        {
          const a = $f47944;
          {
            const $t47794 = Spin$Draw$stick(a, b, 2., "#7a6aa8");
            {
              const $t47795 = { $: "Nil" };
              return { $: "Cons", _0: $t47794, _1: $t47795 };
            }
          }
        }
      }
      break;
    }
    case "Kicker": {
      const $f47950 = p._0;
      const $f47951 = p._1;
      const $f47952 = p._2;
      {
        const f = $f47952;
        {
          const r = $f47951;
          {
            const c = $f47950;
            {
              const glow = Spin$Game$light(m, f);
              {
                const $t47796 = (glow > 0.);
                {
                  let $t47803;
                  if ($t47796 === true) {
                    {
                      let $t47801;
                      {
                        const $t47797 = c.x;
                        {
                          const $t47798 = c.y;
                          {
                            const $t47799 = (r * 2.4);
                            {
                              const $t47800 = Spin$Draw$rgba(255, 63, 164, glow);
                              $t47801 = { $: "Glow", _0: $t47797, _1: $t47798, _2: $t47799, _3: $t47800 };
                            }
                          }
                        }
                      }
                      {
                        const $t47802 = { $: "Nil" };
                        $t47803 = { $: "Cons", _0: $t47801, _1: $t47802 };
                      }
                    }
                  } else {
                    $t47803 = { $: "Nil" };
                  }
                  {
                    let $t47806;
                    {
                      const $t47804 = c.x;
                      {
                        const $t47805 = c.y;
                        $t47806 = { $: "Disc", _0: $t47804, _1: $t47805, _2: r, _3: "#2a0f3a" };
                      }
                    }
                    {
                      let $t47810;
                      {
                        const $t47807 = c.x;
                        {
                          const $t47808 = c.y;
                          {
                            const $t47809 = (r - 2.);
                            $t47810 = { $: "Ring", _0: $t47807, _1: $t47808, _2: $t47809, _3: 4., _4: "#ff3fa4" };
                          }
                        }
                      }
                      {
                        let $t47816;
                        {
                          const $t47811 = c.x;
                          {
                            const $t47812 = c.y;
                            {
                              const $t47813 = (r * 0.55);
                              {
                                let $t47815;
                                {
                                  const $t47814 = (glow > 0.);
                                  if ($t47814 === true) {
                                    $t47815 = "#ffe0f2";
                                  } else {
                                    $t47815 = "#ff3fa4";
                                  }
                                }
                                $t47816 = { $: "Disc", _0: $t47811, _1: $t47812, _2: $t47813, _3: $t47815 };
                              }
                            }
                          }
                        }
                        {
                          const $t47817 = { $: "Nil" };
                          {
                            const $t47818 = { $: "Cons", _0: $t47816, _1: $t47817 };
                            {
                              const $t47819 = { $: "Cons", _0: $t47810, _1: $t47818 };
                              {
                                const $t47820 = { $: "Cons", _0: $t47806, _1: $t47819 };
                                {
                                  const $t47821 = { $: "Nil" };
                                  {
                                    const $t47822 = { $: "Cons", _0: $t47820, _1: $t47821 };
                                    {
                                      const $t47823 = { $: "Cons", _0: $t47803, _1: $t47822 };
                                      {
                                        const prepend_reversed_i5708 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                        {
                                          const go_i5709 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5708 };
                                          {
                                            const $t1113_i5710 = { $: "Nil" };
                                            return go$apply$1_List_concat_List_List_Op(go_i5709, $t47823, $t1113_i5710);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
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
      const $f47961 = p._0;
      const $f47962 = p._1;
      const $f47963 = p._2;
      const $f47964 = p._3;
      switch ($f47964.$) {
        case "Sling": {
          {
            const b = $f47962;
            {
              const a = $f47961;
              {
                let $t47827;
                {
                  let $t47826;
                  {
                    const $t47824 = { $: "Sling" };
                    {
                      const dim_i12971 = "#ff6b3d";
                      {
                        const bright_i12972 = "#ffd36b";
                        {
                          let $t47780_i12974;
                          {
                            const $t47779_i12973 = Spin$Game$light(m, $t47824);
                            $t47780_i12974 = ($t47779_i12973 > 0.);
                          }
                          if ($t47780_i12974 === true) {
                            $t47826 = "#ffd36b";
                          } else {
                            $t47826 = "#ff6b3d";
                          }
                        }
                      }
                    }
                  }
                  $t47827 = Spin$Draw$stick(a, b, 6., $t47826);
                }
                {
                  const $t47828 = { $: "Nil" };
                  return { $: "Cons", _0: $t47827, _1: $t47828 };
                }
              }
            }
          }
          break;
        }
        default: {
          switch ($f47964.$) {
            case "Loader": {
              const $f47987 = $f47964._0;
              {
                const s = $f47987;
                {
                  const b = $f47962;
                  {
                    const a = $f47961;
                    {
                      let glow;
                      {
                        let $t47829;
                        $t47829 = { $: "Loader", _0: s };
                        glow = Spin$Game$light(m, $t47829);
                      }
                      {
                        let mid;
                        {
                          let $t47830;
                          $t47830 = Arcade$Vec2$add(a, b);
                          mid = Arcade$Vec2$scale($t47830, 0.5);
                        }
                        {
                          let inward;
                          {
                            let $t47834;
                            {
                              let $t47833;
                              {
                                const $t47831 = a.x;
                                {
                                  const $t47832 = b.x;
                                  {
                                    const $t45787_i5734 = ($t47832 >= $t47831);
                                    if ($t45787_i5734 === true) {
                                      $t47833 = $t47832;
                                    } else {
                                      $t47833 = $t47831;
                                    }
                                  }
                                }
                              }
                              $t47834 = ($t47833 < 100.);
                            }
                            if ($t47834 === true) {
                              inward = ({ x: 18., y: 0. });
                            } else {
                              {
                                let $t47838;
                                {
                                  let $t47837;
                                  {
                                    const $t47835 = a.x;
                                    {
                                      const $t47836 = b.x;
                                      {
                                        const $t45788_i5729 = ($t47836 < $t47835);
                                        if ($t45788_i5729 === true) {
                                          $t47837 = $t47836;
                                        } else {
                                          $t47837 = $t47835;
                                        }
                                      }
                                    }
                                  }
                                  $t47838 = ($t47837 > 300.);
                                }
                                {
                                  const $jp1200_$t47839 = (-18.);
                                  if ($t47838 === true) {
                                    inward = ({ x: $jp1200_$t47839, y: 0. });
                                  } else {
                                    inward = ({ x: 0., y: $jp1200_$t47839 });
                                  }
                                }
                              }
                            }
                          }
                          {
                            let icon;
                            icon = Arcade$Vec2$add(mid, inward);
                            {
                              const $t47841 = (glow > 0.);
                              {
                                let $t47848;
                                if ($t47841 === true) {
                                  {
                                    let $t47846;
                                    {
                                      const $t47842 = mid.x;
                                      {
                                        const $t47843 = mid.y;
                                        {
                                          let $t47845;
                                          {
                                            const $t47844 = (glow * 0.7);
                                            $t47845 = Spin$Draw$rgba(255, 255, 255, $t47844);
                                          }
                                          $t47846 = { $: "Glow", _0: $t47842, _1: $t47843, _2: 30., _3: $t47845 };
                                        }
                                      }
                                    }
                                    {
                                      const $t47847 = { $: "Nil" };
                                      {
                                        const $rc_2689 = { $: "Cons", _0: $t47846, _1: $t47847 };
                                        $t47848 = $rc_2689;
                                      }
                                    }
                                  }
                                } else {
                                  $t47848 = { $: "Nil" };
                                }
                                {
                                  let $t47850;
                                  {
                                    const $t47849 = Spin$View$colour(s);
                                    $t47850 = Spin$Draw$stick(a, b, 8., $t47849);
                                  }
                                  {
                                    const $t47851 = { $: "Nil" };
                                    {
                                      const $t47852 = { $: "Cons", _0: $t47850, _1: $t47851 };
                                      {
                                        const $t47853 = m.num;
                                        {
                                          const $t47854 = icon.x;
                                          {
                                            const $t47855 = icon.y;
                                            {
                                              let $t47856;
                                              {
                                                let $rc_2687;
                                                $rc_2687 = Spin$View$symbol($t47853, s, $t47854, $t47855, 0.62);
                                                $t47856 = $rc_2687;
                                              }
                                              {
                                                const $t47857 = { $: "Nil" };
                                                {
                                                  const $t47858 = { $: "Cons", _0: $t47856, _1: $t47857 };
                                                  {
                                                    const $t47859 = { $: "Cons", _0: $t47852, _1: $t47858 };
                                                    {
                                                      const $t47860 = { $: "Cons", _0: $t47848, _1: $t47859 };
                                                      {
                                                        const prepend_reversed_i5720 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                        {
                                                          const go_i5721 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5720 };
                                                          {
                                                            const $t1113_i5722 = { $: "Nil" };
                                                            return go$apply$1_List_concat_List_List_Op(go_i5721, $t47860, $t1113_i5722);
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
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
                const b = $f47962;
                {
                  const a = $f47961;
                  {
                    const $t47862 = Spin$Draw$stick(a, b, 4., "#b9a6ff");
                    {
                      const $t47863 = { $: "Nil" };
                      return { $: "Cons", _0: $t47862, _1: $t47863 };
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
      const $f48004 = p._0;
      const $f48005 = p._1;
      const $f48006 = p._2;
      switch ($f48006.$) {
        case "HoldLane": {
          const $f48021 = $f48006._0;
          {
            const i = $f48021;
            {
              const r = $f48005;
              {
                const c = $f48004;
                {
                  let is_on;
                  {
                    const m_i12975 = m;
                    {
                      let $t47783_i12979;
                      {
                        const $t47781_i12977 = m.bank;
                        {
                          const $t47782_i12978 = $t47781_i12977.reels;
                          $t47783_i12979 = List$nth_opt$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($t47782_i12978, i);
                        }
                      }
                      switch ($t47783_i12979.$) {
                        case "Some": {
                          const $f47784_i12980 = $t47783_i12979._0;
                          {
                            const r_i12981 = $f47784_i12980;
                            {
                              const $rc_2684_i12982 = r_i12981.held;
                              is_on = $rc_2684_i12982;
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
                    let $t47867;
                    {
                      const $t47864 = c.x;
                      {
                        const $t47865 = c.y;
                        {
                          let $t47866;
                          if (is_on === true) {
                            $t47866 = "#7dff7a";
                          } else {
                            $t47866 = "#5a4a80";
                          }
                          $t47867 = { $: "Ring", _0: $t47864, _1: $t47865, _2: r, _3: 2., _4: $t47866 };
                        }
                      }
                    }
                    {
                      let $t47872;
                      {
                        const $t47868 = c.x;
                        {
                          const $t47869 = c.y;
                          {
                            const $t47870 = (r - 3.);
                            {
                              let $t47871;
                              if (is_on === true) {
                                $t47871 = "#7dff7a";
                              } else {
                                $t47871 = "#241640";
                              }
                              $t47872 = { $: "Disc", _0: $t47868, _1: $t47869, _2: $t47870, _3: $t47871 };
                            }
                          }
                        }
                      }
                      {
                        let $t47879;
                        {
                          let $t47874;
                          {
                            const $t47873 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
                            $t47874 = String($t47873);
                          }
                          {
                            const $t47875 = c.x;
                            {
                              let $t47877;
                              {
                                const $t47876 = c.y;
                                $t47877 = ($t47876 + 0.5);
                              }
                              {
                                let $t47878;
                                if (is_on === true) {
                                  $t47878 = "#0b2a0b";
                                } else {
                                  $t47878 = "#9a8ac0";
                                }
                                $t47879 = { $: "Label", _0: $t47874, _1: $t47875, _2: $t47877, _3: 9., _4: $t47878 };
                              }
                            }
                          }
                        }
                        {
                          const $t47880 = { $: "Nil" };
                          {
                            const $t47881 = { $: "Cons", _0: $t47879, _1: $t47880 };
                            {
                              const $t47882 = { $: "Cons", _0: $t47872, _1: $t47881 };
                              {
                                const $rc_2691 = { $: "Cons", _0: $t47867, _1: $t47882 };
                                return $rc_2691;
                              }
                            }
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
      const $f48026 = p._0;
      const $f48027 = p._1;
      const $f48028 = p._2;
      {
        const b = $f48027;
        {
          const a = $f48026;
          {
            let h;
            {
              let $t47886;
              {
                let $t47885;
                {
                  let $t47884;
                  {
                    const $t47883 = m.spinner_turn;
                    $t47884 = Math.cos($t47883);
                  }
                  $t47885 = Math.abs($t47884);
                }
                $t47886 = (7. * $t47885);
              }
              h = (2. + $t47886);
            }
            {
              let glow;
              {
                const $t47887 = { $: "Spinner" };
                glow = Spin$Game$light(m, $t47887);
              }
              {
                const $t47888 = (glow > 0.);
                {
                  let $t47898;
                  if ($t47888 === true) {
                    {
                      let $t47896;
                      {
                        let $t47892;
                        {
                          let $t47891;
                          {
                            const $t47889 = a.x;
                            {
                              const $t47890 = b.x;
                              $t47891 = ($t47889 + $t47890);
                            }
                          }
                          $t47892 = ($t47891 / 2.);
                        }
                        {
                          const $t47893 = a.y;
                          {
                            let $t47895;
                            {
                              const $t47894 = (glow * 0.8);
                              $t47895 = Spin$Draw$rgba(92, 242, 255, $t47894);
                            }
                            $t47896 = { $: "Glow", _0: $t47892, _1: $t47893, _2: 34., _3: $t47895 };
                          }
                        }
                      }
                      {
                        const $t47897 = { $: "Nil" };
                        $t47898 = { $: "Cons", _0: $t47896, _1: $t47897 };
                      }
                    }
                  } else {
                    $t47898 = { $: "Nil" };
                  }
                  {
                    let $t47908;
                    {
                      let $t47900;
                      {
                        const $t47899 = a.x;
                        $t47900 = ($t47899 + 3.);
                      }
                      {
                        let $t47903;
                        {
                          const $t47901 = a.y;
                          {
                            const $t47902 = (h / 2.);
                            $t47903 = ($t47901 - $t47902);
                          }
                        }
                        {
                          let $t47907;
                          {
                            let $t47906;
                            {
                              const $t47904 = b.x;
                              {
                                const $t47905 = a.x;
                                $t47906 = ($t47904 - $t47905);
                              }
                            }
                            $t47907 = ($t47906 - 6.);
                          }
                          $t47908 = { $: "Box", _0: $t47900, _1: $t47903, _2: $t47907, _3: h, _4: "#5cf2ff" };
                        }
                      }
                    }
                    {
                      let $t47915;
                      {
                        let $t47912;
                        {
                          let $t47911;
                          {
                            const $t47909 = a.x;
                            {
                              const $t47910 = b.x;
                              $t47911 = ($t47909 + $t47910);
                            }
                          }
                          $t47912 = ($t47911 / 2.);
                        }
                        {
                          let $t47914;
                          {
                            const $t47913 = a.y;
                            $t47914 = ($t47913 + 16.);
                          }
                          $t47915 = { $: "Label", _0: "SPIN", _1: $t47912, _2: $t47914, _3: 9., _4: "#5cf2ff" };
                        }
                      }
                      {
                        const $t47916 = { $: "Nil" };
                        {
                          const $t47917 = { $: "Cons", _0: $t47915, _1: $t47916 };
                          {
                            const $t47918 = { $: "Cons", _0: $t47908, _1: $t47917 };
                            {
                              const $t47919 = { $: "Nil" };
                              {
                                const $t47920 = { $: "Cons", _0: $t47918, _1: $t47919 };
                                {
                                  const $t47921 = { $: "Cons", _0: $t47898, _1: $t47920 };
                                  {
                                    const prepend_reversed_i5745 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                    {
                                      const go_i5746 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5745 };
                                      {
                                        const $t1113_i5747 = { $: "Nil" };
                                        return go$apply$1_List_concat_List_List_Op(go_i5746, $t47921, $t1113_i5747);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
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

function Spin$View$flipper_ops(spec, f) {
  {
    let tip;
    {
      const $t48037 = f.angle;
      tip = Spin$Table$tip(spec, $t48037);
    }
    {
      let $t48042;
      {
        const $t48038 = spec.pivot;
        {
          let $t48041;
          {
            let $t48040;
            {
              const $t48039 = spec.radius;
              $t48040 = ($t48039 * 2.);
            }
            $t48041 = ($t48040 + 3.);
          }
          $t48042 = Spin$Draw$stick($t48038, tip, $t48041, "#3b2a5c");
        }
      }
      {
        let $t48046;
        {
          const $t48043 = spec.pivot;
          {
            let $t48045;
            {
              const $t48044 = spec.radius;
              $t48045 = ($t48044 * 2.);
            }
            $t48046 = Spin$Draw$stick($t48043, tip, $t48045, "#f4f1ff");
          }
        }
        {
          let $t48051;
          {
            let $t48048;
            {
              const $t48047 = spec.pivot;
              $t48048 = $t48047.x;
            }
            {
              let $t48050;
              {
                const $t48049 = spec.pivot;
                $t48050 = $t48049.y;
              }
              $t48051 = { $: "Disc", _0: $t48048, _1: $t48050, _2: 3., _3: "#ff3fa4" };
            }
          }
          {
            const $t48052 = { $: "Nil" };
            {
              const $t48053 = { $: "Cons", _0: $t48051, _1: $t48052 };
              {
                const $t48054 = { $: "Cons", _0: $t48046, _1: $t48053 };
                return { $: "Cons", _0: $t48042, _1: $t48054 };
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$flipper_ops$clo = { _0: ($_, spec, f) => Spin$View$flipper_ops(spec, f) };

function Spin$View$ball_ops(b) {
  {
    let $t48061;
    {
      let $t48057;
      {
        let $t48056;
        {
          const $t48055 = b.pos;
          $t48056 = $t48055.x;
        }
        $t48057 = ($t48056 + 2.);
      }
      {
        let $t48060;
        {
          let $t48059;
          {
            const $t48058 = b.pos;
            $t48059 = $t48058.y;
          }
          $t48060 = ($t48059 + 3.);
        }
        $t48061 = { $: "Disc", _0: $t48057, _1: $t48060, _2: 9., _3: "rgba(0,0,0,0.35)" };
      }
    }
    {
      let $t48066;
      {
        let $t48063;
        {
          const $t48062 = b.pos;
          $t48063 = $t48062.x;
        }
        {
          let $t48065;
          {
            const $t48064 = b.pos;
            $t48065 = $t48064.y;
          }
          $t48066 = { $: "Disc", _0: $t48063, _1: $t48065, _2: 9., _3: "#cfd5e2" };
        }
      }
      {
        let $t48073;
        {
          let $t48069;
          {
            let $t48068;
            {
              const $t48067 = b.pos;
              $t48068 = $t48067.x;
            }
            $t48069 = ($t48068 - 1.);
          }
          {
            let $t48072;
            {
              let $t48071;
              {
                const $t48070 = b.pos;
                $t48071 = $t48070.y;
              }
              $t48072 = ($t48071 - 1.);
            }
            $t48073 = { $: "Disc", _0: $t48069, _1: $t48072, _2: 7., _3: "#e9edf5" };
          }
        }
        {
          let $t48080;
          {
            let $t48076;
            {
              let $t48075;
              {
                const $t48074 = b.pos;
                $t48075 = $t48074.x;
              }
              $t48076 = ($t48075 - 3.);
            }
            {
              let $t48079;
              {
                let $t48078;
                {
                  const $t48077 = b.pos;
                  $t48078 = $t48077.y;
                }
                $t48079 = ($t48078 - 3.5);
              }
              $t48080 = { $: "Disc", _0: $t48076, _1: $t48079, _2: 2.6, _3: "#ffffff" };
            }
          }
          {
            const $t48081 = { $: "Nil" };
            {
              const $t48082 = { $: "Cons", _0: $t48080, _1: $t48081 };
              {
                const $t48083 = { $: "Cons", _0: $t48073, _1: $t48082 };
                {
                  const $t48084 = { $: "Cons", _0: $t48066, _1: $t48083 };
                  return { $: "Cons", _0: $t48061, _1: $t48084 };
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$ball_ops$clo = { _0: ($_, b) => Spin$View$ball_ops(b) };

function Spin$View$launch_button_ops(m) {
  {
    let ready;
    {
      let $t48085;
      $t48085 = Spin$Game$waiting(m);
      {
        let $t48088;
        {
          const $t48086 = m.mode;
          {
            const $t48087 = { $: "Playing" };
            {
              const $rc_2692 = march_deep_eq($t48086, $t48087);
              $t48088 = $rc_2692;
            }
          }
        }
        ready = ($t48085 && $t48088);
      }
    }
    {
      let pulse;
      {
        let $t48092;
        {
          let $t48091;
          {
            let $t48090;
            {
              const $t48089 = m.clock;
              $t48090 = ($t48089 * 6.);
            }
            $t48091 = Math.sin($t48090);
          }
          $t48092 = (0.5 * $t48091);
        }
        pulse = (0.5 + $t48092);
      }
      {
        let fill;
        {
          const $t48093 = (2. * 30.);
          {
            const $t48094 = m.pull;
            fill = ($t48093 * $t48094);
          }
        }
        if (ready === true) {
          {
            let $t48099;
            {
              const $t48095 = (30. * 1.9);
              {
                let $t48098;
                {
                  let $t48097;
                  {
                    const $t48096 = (0.25 * pulse);
                    $t48097 = (0.25 + $t48096);
                  }
                  $t48098 = Spin$Draw$rgba(255, 63, 80, $t48097);
                }
                $t48099 = { $: "Glow", _0: 306., _1: 724., _2: $t48095, _3: $t48098 };
              }
            }
            {
              const $t48100 = { $: "Disc", _0: 306., _1: 724., _2: 30., _3: "#3a0d1a" };
              {
                let $t48105;
                {
                  const $t48101 = (306. - 30.);
                  {
                    let $t48103;
                    {
                      const $t48102 = (724. + 30.);
                      $t48103 = ($t48102 - fill);
                    }
                    {
                      const $t48104 = (2. * 30.);
                      $t48105 = { $: "ClipBox", _0: $t48101, _1: $t48103, _2: $t48104, _3: fill };
                    }
                  }
                }
                {
                  const $t48106 = { $: "Disc", _0: 306., _1: 724., _2: 30., _3: "#ff3b4e" };
                  {
                    const $t48107 = { $: "Unclip" };
                    {
                      let $t48111;
                      {
                        let $t48110;
                        {
                          let $t48109;
                          {
                            const $t48108 = (0.3 * pulse);
                            $t48109 = (0.7 + $t48108);
                          }
                          $t48110 = Spin$Draw$rgba(255, 211, 107, $t48109);
                        }
                        $t48111 = { $: "Ring", _0: 306., _1: 724., _2: 30., _3: 3., _4: $t48110 };
                      }
                      {
                        let $t48113;
                        {
                          const $t48112 = (724. - 4.);
                          $t48113 = { $: "Label", _0: "LAUNCH", _1: 306., _2: $t48112, _3: 10., _4: "#ffffff" };
                        }
                        {
                          let $t48119;
                          {
                            let $t48116;
                            {
                              let $t48115;
                              {
                                const $t48114 = m.pull;
                                $t48115 = ($t48114 > 0.);
                              }
                              if ($t48115 === true) {
                                $t48116 = "let go";
                              } else {
                                $t48116 = "hold";
                              }
                            }
                            {
                              const $t48117 = (724. + 9.);
                              {
                                const $t48118 = Spin$Draw$rgba(255, 230, 200, 0.9);
                                $t48119 = { $: "Label", _0: $t48116, _1: 306., _2: $t48117, _3: 8., _4: $t48118 };
                              }
                            }
                          }
                          {
                            const $t48120 = { $: "Nil" };
                            {
                              const $t48121 = { $: "Cons", _0: $t48119, _1: $t48120 };
                              {
                                const $t48122 = { $: "Cons", _0: $t48113, _1: $t48121 };
                                {
                                  const $t48123 = { $: "Cons", _0: $t48111, _1: $t48122 };
                                  {
                                    const $t48124 = { $: "Cons", _0: $t48107, _1: $t48123 };
                                    {
                                      const $t48125 = { $: "Cons", _0: $t48106, _1: $t48124 };
                                      {
                                        const $t48126 = { $: "Cons", _0: $t48105, _1: $t48125 };
                                        {
                                          const $t48127 = { $: "Cons", _0: $t48100, _1: $t48126 };
                                          {
                                            const $rc_2696 = { $: "Cons", _0: $t48099, _1: $t48127 };
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
                  }
                }
              }
            }
          }
        } else {
          {
            const $t48128 = { $: "Disc", _0: 306., _1: 724., _2: 30., _3: "rgba(58,13,26,0.5)" };
            {
              const $t48129 = { $: "Ring", _0: 306., _1: 724., _2: 30., _3: 2., _4: "rgba(255,59,78,0.25)" };
              {
                const $t48130 = { $: "Label", _0: "LAUNCH", _1: 306., _2: 724., _3: 9., _4: "rgba(255,255,255,0.22)" };
                {
                  const $t48131 = { $: "Nil" };
                  {
                    const $t48132 = { $: "Cons", _0: $t48130, _1: $t48131 };
                    {
                      const $t48133 = { $: "Cons", _0: $t48129, _1: $t48132 };
                      {
                        const $rc_2695 = { $: "Cons", _0: $t48128, _1: $t48133 };
                        return $rc_2695;
                      }
                    }
                  }
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
      let $t48136;
      {
        const $t48135 = m.pull;
        $t48136 = (26. * $t48135);
      }
      top = (702. + $t48136);
    }
    {
      let $t48137;
      {
        const go_i5819 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
        {
          const $t915_i5820 = ((6 - 1) < 4611686018427387904 && (6 - 1) >= -4611686018427387904 ? (6 - 1) : march_int_ovf((6 - 1), 1));
          {
            const $t916_i5821 = { $: "Nil" };
            $t48137 = go$apply$0_List_range(go_i5819, $t915_i5820, $t916_i5821);
          }
        }
      }
      {
        let $t48149;
        $t48149 = { $: "$Clo_$lam0_Spin_View_plunger_ops$0_Spin_View_plunger_ops", _0: $lam0_Spin_View_plunger_ops$apply$0_Spin_View_plunger_ops, _1: m, _2: top };
        {
          const coils = List$map$List_Int$Fn_Int_Op($t48137, $t48149);
          {
            let pulse;
            {
              let $t48153;
              {
                let $t48152;
                {
                  let $t48151;
                  {
                    const $t48150 = m.clock;
                    $t48151 = ($t48150 * 5.);
                  }
                  $t48152 = Math.sin($t48151);
                }
                $t48153 = (0.4 * $t48152);
              }
              pulse = (0.6 + $t48153);
            }
            {
              let $t48158;
              {
                let $t48154;
                $t48154 = Spin$Game$waiting(m);
                {
                  let $t48157;
                  {
                    const $t48155 = m.mode;
                    {
                      const $t48156 = { $: "Playing" };
                      {
                        const $rc_2697 = march_deep_eq($t48155, $t48156);
                        $t48157 = $rc_2697;
                      }
                    }
                  }
                  $t48158 = ($t48154 && $t48157);
                }
              }
              {
                let hint;
                if ($t48158 === true) {
                  if (touch === true) {
                    hint = { $: "Nil" };
                  } else {
                    {
                      let $t48160;
                      {
                        const $t48159 = Spin$Draw$rgba(255, 211, 107, pulse);
                        $t48160 = { $: "Label", _0: "HOLD SPACE", _1: 365., _2: 646., _3: 7., _4: $t48159 };
                      }
                      {
                        let $t48162;
                        {
                          const $t48161 = Spin$Draw$rgba(255, 211, 107, pulse);
                          $t48162 = { $: "Label", _0: "let go", _1: 365., _2: 655., _3: 6., _4: $t48161 };
                        }
                        {
                          const $t48163 = { $: "Nil" };
                          {
                            const $t48164 = { $: "Cons", _0: $t48162, _1: $t48163 };
                            hint = { $: "Cons", _0: $t48160, _1: $t48164 };
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
                    const $t48165 = { $: "Box", _0: 357., _1: top, _2: 16., _3: 6., _4: "#e33" };
                    {
                      let $t48167;
                      {
                        const $t48166 = (top + 6.);
                        $t48167 = { $: "Box", _0: 362., _1: $t48166, _2: 6., _3: 50., _4: "#556" };
                      }
                      {
                        const $t48168 = { $: "Nil" };
                        {
                          const $t48169 = { $: "Cons", _0: $t48167, _1: $t48168 };
                          {
                            const $t48170 = { $: "Cons", _0: $t48165, _1: $t48169 };
                            {
                              const $t48171 = { $: "Nil" };
                              {
                                const $t48172 = { $: "Cons", _0: button, _1: $t48171 };
                                {
                                  const $t48173 = { $: "Cons", _0: hint, _1: $t48172 };
                                  {
                                    const $t48174 = { $: "Cons", _0: coils, _1: $t48173 };
                                    {
                                      const $t48175 = { $: "Cons", _0: $t48170, _1: $t48174 };
                                      {
                                        const prepend_reversed_i5803 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                        {
                                          const go_i5804 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5803 };
                                          {
                                            const $t1113_i5805 = { $: "Nil" };
                                            return go$apply$1_List_concat_List_List_Op(go_i5804, $t48175, $t1113_i5805);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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

function Spin$View$banner_ops(m) {
  {
    const b = m.banner;
    {
      let $t48194;
      {
        let $t48190;
        {
          const $t48189 = b.left;
          $t48190 = ($t48189 > 0.);
        }
        {
          let $t48193;
          {
            const $t48191 = m.mode;
            {
              const $t48192 = { $: "Playing" };
              {
                const $rc_2698 = march_deep_eq($t48191, $t48192);
                $t48193 = $rc_2698;
              }
            }
          }
          $t48194 = ($t48190 && $t48193);
        }
      }
      if ($t48194 === true) {
        {
          let a;
          {
            let $t48196;
            {
              const $t48195 = b.left;
              $t48196 = ($t48195 * 3.);
            }
            {
              const $t45788_i5842 = ($t48196 < 1.);
              if ($t45788_i5842 === true) {
                a = $t48196;
              } else {
                a = 1.;
              }
            }
          }
          {
            let main;
            {
              const $t48197 = b.hot;
              if ($t48197 === true) {
                main = Spin$Draw$rgba(255, 211, 107, a);
              } else {
                main = Spin$Draw$rgba(255, 255, 255, a);
              }
            }
            {
              let $t48200;
              {
                let $t48199;
                {
                  const $t48198 = (0.8 * a);
                  $t48199 = Spin$Draw$rgba(7, 4, 15, $t48198);
                }
                $t48200 = { $: "Box", _0: 100., _1: 548., _2: 170., _3: 40., _4: $t48199 };
              }
              {
                let $t48202;
                {
                  const $t48201 = b.text;
                  $t48202 = { $: "Label", _0: $t48201, _1: 185., _2: 562., _3: 16., _4: main };
                }
                {
                  let $t48205;
                  {
                    const $t48203 = b.sub;
                    {
                      const $t48204 = Spin$Draw$rgba(200, 190, 255, a);
                      $t48205 = { $: "Label", _0: $t48203, _1: 185., _2: 579., _3: 8., _4: $t48204 };
                    }
                  }
                  {
                    const $t48206 = { $: "Nil" };
                    {
                      const $t48207 = { $: "Cons", _0: $t48205, _1: $t48206 };
                      {
                        const $t48208 = { $: "Cons", _0: $t48202, _1: $t48207 };
                        return { $: "Cons", _0: $t48200, _1: $t48208 };
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
      let $t48210;
      {
        const $t48209 = m.credits;
        $t48210 = ($t48209 <= 10);
      }
      {
        let $t48213;
        {
          const $t48211 = m.mode;
          {
            const $t48212 = { $: "Playing" };
            {
              const $rc_2701 = march_deep_eq($t48211, $t48212);
              $t48213 = $rc_2701;
            }
          }
        }
        low = ($t48210 && $t48213);
      }
    }
    {
      let blink;
      {
        let $t48217;
        {
          let $t48216;
          {
            let $t48215;
            {
              const $t48214 = m.clock;
              $t48215 = ($t48214 * 10.);
            }
            $t48216 = Math.sin($t48215);
          }
          $t48217 = ($t48216 > 0.);
        }
        blink = (low && $t48217);
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
            const $t48218 = m.alive;
            {
              let $t46154_i5886;
              {
                let $t46153_i5885;
                {
                  let $t46152_i5884;
                  {
                    const $t46151_i5883 = ($t48218 * 0.00385);
                    $t46152_i5884 = (0. - $t46151_i5883);
                  }
                  $t46153_i5885 = Math.exp($t46152_i5884);
                }
                $t46154_i5886 = (2.4 * $t46153_i5885);
              }
              {
                const $t45787_i14391 = ($t46154_i5886 >= 0.05);
                if ($t45787_i14391 === true) {
                  every = $t46154_i5886;
                } else {
                  every = 0.05;
                }
              }
            }
          }
          {
            let f;
            {
              let $t48220;
              {
                const $t48219 = m.burn_clock;
                $t48220 = ($t48219 / every);
              }
              {
                let $t45789_i5881;
                {
                  const $t45787_i14388 = (0. >= $t48220);
                  if ($t45787_i14388 === true) {
                    $t45789_i5881 = 0.;
                  } else {
                    $t45789_i5881 = $t48220;
                  }
                }
                {
                  const $t45788_i14385 = (1. < $t45789_i5881);
                  if ($t45788_i14385 === true) {
                    f = 1.;
                  } else {
                    f = $t45789_i5881;
                  }
                }
              }
            }
            {
              let $t48222;
              {
                const $t48221 = (-92.);
                $t48222 = { $: "Box", _0: 6., _1: $t48221, _2: 388., _3: 84., _4: "#140a24" };
              }
              {
                let $t48224;
                {
                  const $t48223 = (-88.);
                  $t48224 = { $: "Box", _0: 10., _1: $t48223, _2: 380., _3: 76., _4: "#1f1035" };
                }
                {
                  let $t48226;
                  {
                    const $t48225 = (-74.);
                    $t48226 = { $: "Label", _0: "CREDITS", _1: 80., _2: $t48225, _3: 9., _4: "#b9a6ff" };
                  }
                  {
                    let $t48230;
                    {
                      let $t48228;
                      {
                        const $t48227 = m.credits;
                        $t48228 = String($t48227);
                      }
                      {
                        const $t48229 = (-42.);
                        $t48230 = { $: "Label", _0: $t48228, _1: 80., _2: $t48229, _3: 38., _4: credit_colour };
                      }
                    }
                    {
                      let $t48232;
                      {
                        const $t48231 = (-74.);
                        $t48232 = { $: "Label", _0: "METER", _1: 200., _2: $t48231, _3: 9., _4: "#b9a6ff" };
                      }
                      {
                        let $t48234;
                        {
                          const $t48233 = (-54.);
                          $t48234 = { $: "Box", _0: 160., _1: $t48233, _2: 80., _3: 12., _4: "#0b0614" };
                        }
                        {
                          let $t48238;
                          {
                            const $t48235 = (-54.);
                            {
                              const $t48236 = (80. * f);
                              {
                                let $t48237;
                                if (low === true) {
                                  $t48237 = "#ff3b4e";
                                } else {
                                  $t48237 = "#ff8a3d";
                                }
                                $t48238 = { $: "Box", _0: 160., _1: $t48235, _2: $t48236, _3: 12., _4: $t48237 };
                              }
                            }
                          }
                          {
                            let $t48242;
                            {
                              let $t48240;
                              {
                                let $t48239;
                                {
                                  let t_i12985;
                                  {
                                    const $t48265_i12984 = (every * 10.);
                                    t_i12985 = march_float_round($t48265_i12984);
                                  }
                                  {
                                    let $t48267_i12987;
                                    {
                                      const $t48266_i12986 = ((t_i12985 - t_i12985 % 10) / 10);
                                      $t48267_i12987 = String($t48266_i12986);
                                    }
                                    {
                                      let $t48269_i12989;
                                      {
                                        const $t48268_i12988 = (t_i12985 % 10);
                                        $t48269_i12989 = String($t48268_i12988);
                                      }
                                      {
                                        const $rc_2702_i12990 = march_string_concat3($t48267_i12987, ".", $t48269_i12989);
                                        $t48239 = $rc_2702_i12990;
                                      }
                                    }
                                  }
                                }
                                {
                                  const $rc_2700 = march_string_concat3("1 per ", $t48239, "s");
                                  $t48240 = $rc_2700;
                                }
                              }
                              {
                                const $t48241 = (-28.);
                                $t48242 = { $: "Label", _0: $t48240, _1: 200., _2: $t48241, _3: 8., _4: "#8a7ab0" };
                              }
                            }
                            {
                              let $t48244;
                              {
                                const $t48243 = (-74.);
                                $t48244 = { $: "Label", _0: "PAID", _1: 320., _2: $t48243, _3: 9., _4: "#b9a6ff" };
                              }
                              {
                                let $t48248;
                                {
                                  let $t48246;
                                  {
                                    const $t48245 = m.paid;
                                    $t48246 = String($t48245);
                                  }
                                  {
                                    const $t48247 = (-50.);
                                    $t48248 = { $: "Label", _0: $t48246, _1: 320., _2: $t48247, _3: 22., _4: "#7dff7a" };
                                  }
                                }
                                {
                                  let $t48253;
                                  {
                                    let $t48251;
                                    {
                                      let $t48250;
                                      {
                                        const $t48249 = m.best;
                                        $t48250 = String($t48249);
                                      }
                                      {
                                        const $rc_2699 = ("BEST " + $t48250);
                                        $t48251 = $rc_2699;
                                      }
                                    }
                                    {
                                      const $t48252 = (-26.);
                                      $t48253 = { $: "Label", _0: $t48251, _1: 320., _2: $t48252, _3: 9., _4: "#8a7ab0" };
                                    }
                                  }
                                  {
                                    const $t48254 = { $: "Nil" };
                                    {
                                      const $t48255 = { $: "Cons", _0: $t48253, _1: $t48254 };
                                      {
                                        const $t48256 = { $: "Cons", _0: $t48248, _1: $t48255 };
                                        {
                                          const $t48257 = { $: "Cons", _0: $t48244, _1: $t48256 };
                                          {
                                            const $t48258 = { $: "Cons", _0: $t48242, _1: $t48257 };
                                            {
                                              const $t48259 = { $: "Cons", _0: $t48238, _1: $t48258 };
                                              {
                                                const $t48260 = { $: "Cons", _0: $t48234, _1: $t48259 };
                                                {
                                                  const $t48261 = { $: "Cons", _0: $t48232, _1: $t48260 };
                                                  {
                                                    const $t48262 = { $: "Cons", _0: $t48230, _1: $t48261 };
                                                    {
                                                      const $t48263 = { $: "Cons", _0: $t48226, _1: $t48262 };
                                                      {
                                                        const $t48264 = { $: "Cons", _0: $t48224, _1: $t48263 };
                                                        return { $: "Cons", _0: $t48222, _1: $t48264 };
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
    const $t48270 = m.mode;
    switch ($t48270.$) {
      case "Playing": {
        return { $: "Nil" };
        break;
      }
      case "Attract": {
        {
          let pulse;
          {
            let $t48274;
            {
              let $t48273;
              {
                let $t48272;
                {
                  const $t48271 = m.clock;
                  $t48272 = ($t48271 * 3.);
                }
                $t48273 = Math.sin($t48272);
              }
              $t48274 = (0.45 * $t48273);
            }
            pulse = (0.55 + $t48274);
          }
          {
            const $t48275 = { $: "Box", _0: 30., _1: 150., _2: 310., _3: 330., _4: "rgba(7,4,15,0.86)" };
            {
              const $t48276 = { $: "Label", _0: "SPIN", _1: 185., _2: 190., _3: 40., _4: "#ff3fa4" };
              {
                const $t48277 = { $: "Label", _0: "SPIN", _1: 185., _2: 232., _3: 40., _4: "#5cf2ff" };
                {
                  const $t48279 = { $: "Label", _0: "SPIN", _1: 185., _2: 274., _3: 40., _4: "#ffd36b" };
                  {
                    const $t48280 = { $: "Label", _0: "pinball that plays a slot machine", _1: 185., _2: 306., _3: 10., _4: "#d8ccff" };
                    {
                      const $t48281 = { $: "Label", _0: "TARGETS put their symbol on the line:", _1: 185., _2: 330., _3: 9., _4: "#ffffff" };
                      {
                        const $t48282 = { $: "Label", _0: "hit three, left reel to right, to spell it", _1: 185., _2: 344., _3: 9., _4: "#ffffff" };
                        {
                          const $t48283 = { $: "Label", _0: "the SPINNER spins all three", _1: 185., _2: 362., _3: 9., _4: "#5cf2ff" };
                          {
                            const $t48284 = { $: "Label", _0: "BUMPERS nudge them after a miss", _1: 185., _2: 376., _3: 9., _4: "#ff8fcf" };
                            {
                              const $t48285 = { $: "Label", _0: "TOP LANES hold a reel; all three: x2", _1: 185., _2: 390., _3: 9., _4: "#7dff7a" };
                              {
                                const $t48286 = { $: "Label", _0: "the meter eats credits. only the reels pay.", _1: 185., _2: 412., _3: 9., _4: "#ff8a3d" };
                                {
                                  let $t48288;
                                  {
                                    const $t48287 = Spin$Draw$rgba(255, 211, 107, pulse);
                                    $t48288 = { $: "Label", _0: "TAP OR PRESS SPACE", _1: 185., _2: 446., _3: 14., _4: $t48287 };
                                  }
                                  {
                                    const $t48289 = { $: "Nil" };
                                    {
                                      const $t48290 = { $: "Cons", _0: $t48288, _1: $t48289 };
                                      {
                                        const $t48291 = { $: "Cons", _0: $t48286, _1: $t48290 };
                                        {
                                          const $t48292 = { $: "Cons", _0: $t48285, _1: $t48291 };
                                          {
                                            const $t48293 = { $: "Cons", _0: $t48284, _1: $t48292 };
                                            {
                                              const $t48294 = { $: "Cons", _0: $t48283, _1: $t48293 };
                                              {
                                                const $t48295 = { $: "Cons", _0: $t48282, _1: $t48294 };
                                                {
                                                  const $t48296 = { $: "Cons", _0: $t48281, _1: $t48295 };
                                                  {
                                                    const $t48297 = { $: "Cons", _0: $t48280, _1: $t48296 };
                                                    {
                                                      const $t48298 = { $: "Cons", _0: $t48279, _1: $t48297 };
                                                      {
                                                        const $t48299 = { $: "Cons", _0: $t48277, _1: $t48298 };
                                                        {
                                                          const $t48300 = { $: "Cons", _0: $t48276, _1: $t48299 };
                                                          return { $: "Cons", _0: $t48275, _1: $t48300 };
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
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
            let $t48304;
            {
              let $t48303;
              {
                let $t48302;
                {
                  const $t48301 = m.clock;
                  $t48302 = ($t48301 * 3.);
                }
                $t48303 = Math.sin($t48302);
              }
              $t48304 = (0.45 * $t48303);
            }
            pulse = (0.55 + $t48304);
          }
          {
            const $t48305 = { $: "Box", _0: 40., _1: 230., _2: 290., _3: 190., _4: "rgba(7,4,15,0.9)" };
            {
              const $t48306 = { $: "Label", _0: "BUSTED", _1: 185., _2: 270., _3: 38., _4: "#ff3b4e" };
              {
                let $t48310;
                {
                  let $t48309;
                  {
                    let $t48308;
                    {
                      const $t48307 = m.paid;
                      $t48308 = String($t48307);
                    }
                    {
                      const $rc_2704 = ("the reels paid " + $t48308);
                      $t48309 = $rc_2704;
                    }
                  }
                  $t48310 = { $: "Label", _0: $t48309, _1: 185., _2: 312., _3: 13., _4: "#ffffff" };
                }
                {
                  let $t48315;
                  {
                    let $t48313;
                    {
                      let $t48312;
                      {
                        const $t48311 = m.best;
                        $t48312 = String($t48311);
                      }
                      {
                        const $rc_2703 = ("best " + $t48312);
                        $t48313 = $rc_2703;
                      }
                    }
                    $t48315 = { $: "Label", _0: $t48313, _1: 185., _2: 334., _3: 11., _4: "#ffd36b" };
                  }
                  {
                    let $t48321;
                    {
                      let $t48320;
                      {
                        let $t48319;
                        {
                          let $t48318;
                          {
                            let $t48317;
                            {
                              const $t48316 = m.banner;
                              $t48317 = $t48316.left;
                            }
                            $t48318 = ($t48317 < 999998.);
                          }
                          if ($t48318 === true) {
                            $t48319 = pulse;
                          } else {
                            $t48319 = 0.2;
                          }
                        }
                        $t48320 = Spin$Draw$rgba(255, 211, 107, $t48319);
                      }
                      $t48321 = { $: "Label", _0: "TAP OR PRESS SPACE", _1: 185., _2: 386., _3: 13., _4: $t48320 };
                    }
                    {
                      const $t48322 = { $: "Nil" };
                      {
                        const $t48323 = { $: "Cons", _0: $t48321, _1: $t48322 };
                        {
                          const $t48324 = { $: "Cons", _0: $t48315, _1: $t48323 };
                          {
                            const $t48325 = { $: "Cons", _0: $t48310, _1: $t48324 };
                            {
                              const $t48326 = { $: "Cons", _0: $t48306, _1: $t48325 };
                              return { $: "Cons", _0: $t48305, _1: $t48326 };
                            }
                          }
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
    const $t48332 = { $: "Clear", _0: "#07040f" };
    {
      const $t48333 = { $: "Nil" };
      {
        const $t48334 = { $: "Cons", _0: $t48332, _1: $t48333 };
        {
          let $t48335;
          {
            const _m_i13007 = m;
            {
              const $t48177_i13013 = { $: "Disc", _0: 200., _1: 200., _2: 182., _3: "#1a0c30" };
              {
                const $t48179_i13015 = { $: "Box", _0: 18., _1: 200., _2: 364., _3: 570., _4: "#1a0c30" };
                {
                  const $t48180_i13016 = { $: "Nil" };
                  {
                    const $t48181_i13017 = { $: "Cons", _0: $t48179_i13015, _1: $t48180_i13016 };
                    {
                      const $t48182_i13018 = { $: "Cons", _0: $t48177_i13013, _1: $t48181_i13017 };
                      {
                        const $t48183_i13019 = { $: "Glow", _0: 185., _1: 420., _2: 230., _3: "rgba(120,40,200,0.25)" };
                        {
                          const $t48184_i13020 = { $: "Nil" };
                          {
                            const $t48185_i13021 = { $: "Cons", _0: $t48183_i13019, _1: $t48184_i13020 };
                            {
                              const $t48186_i13022 = { $: "Nil" };
                              {
                                const $t48187_i13023 = { $: "Cons", _0: $t48185_i13021, _1: $t48186_i13022 };
                                {
                                  const $t48188_i13024 = { $: "Cons", _0: $t48182_i13018, _1: $t48187_i13023 };
                                  {
                                    const prepend_reversed_i5823_i13026 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                    {
                                      const go_i5824_i13027 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5823_i13026 };
                                      {
                                        const $t1113_i5825_i13028 = { $: "Nil" };
                                        $t48335 = go$apply$1_List_concat_List_List_Op(go_i5824_i13027, $t48188_i13024, $t1113_i5825_i13028);
                                      }
                                    }
                                  }
                                }
                              }
                            }
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
            let $t48336;
            $t48336 = Spin$View$machine_ops(m);
            {
              const $t48337 = m.table;
              {
                const $t48338 = $t48337.parts;
                {
                  let $t48340;
                  $t48340 = { $: "$Clo_$lam0_Spin_View_frame$0_Spin_View_frame", _0: $lam0_Spin_View_frame$apply$0_Spin_View_frame, _1: m };
                  {
                    let $t48341;
                    {
                      const xs_i12999 = $t48338;
                      {
                        const f_i13000 = $t48340;
                        switch (xs_i12999.$) {
                          case "Nil": {
                            $t48341 = { $: "Nil" };
                            break;
                          }
                          case "Cons": {
                            const $f995_i13001 = xs_i12999._0;
                            const $f996_i13002 = xs_i12999._1;
                            {
                              const t_i13003 = $f996_i13002;
                              {
                                const h_i13004 = $f995_i13001;
                                {
                                  let $t993_i13005;
                                  $t993_i13005 = f_i13000._0(f_i13000, h_i13004);
                                  {
                                    const $trmc15_i13006 = { $: "Cons", _0: $t993_i13005, _1: null };
                                    List$map$dps$List_Part$Fn_Part_List_Op$List_List_Op(t_i13003, f_i13000, $trmc15_i13006);
                                    $t48341 = $trmc15_i13006;
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
                      let $t48342;
                      {
                        const prepend_reversed_i5989 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                        {
                          const go_i5990 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5989 };
                          {
                            const $t1113_i5991 = { $: "Nil" };
                            $t48342 = go$apply$1_List_concat_List_List_Op(go_i5990, $t48341, $t1113_i5991);
                          }
                        }
                      }
                      {
                        let $t48343;
                        $t48343 = Spin$View$plunger_ops(m, touch);
                        {
                          let $t48345;
                          {
                            const $t48344 = m.table;
                            $t48345 = $t48344.left;
                          }
                          {
                            const $t48346 = m.left;
                            {
                              const $t48347 = Spin$View$flipper_ops($t48345, $t48346);
                              {
                                let $t48349;
                                {
                                  const $t48348 = m.table;
                                  $t48349 = $t48348.right;
                                }
                                {
                                  const $t48350 = m.right;
                                  {
                                    const $t48351 = Spin$View$flipper_ops($t48349, $t48350);
                                    {
                                      const $t48352 = m.balls;
                                      {
                                        let $t48353;
                                        {
                                          const xs_i12991 = $t48352;
                                          {
                                            const f_i12992 = Spin$View$ball_ops$clo;
                                            switch (xs_i12991.$) {
                                              case "Nil": {
                                                $t48353 = { $: "Nil" };
                                                break;
                                              }
                                              case "Cons": {
                                                const $f995_i12993 = xs_i12991._0;
                                                const $f996_i12994 = xs_i12991._1;
                                                {
                                                  const t_i12995 = $f996_i12994;
                                                  {
                                                    const h_i12996 = $f995_i12993;
                                                    {
                                                      let $t993_i12997;
                                                      $t993_i12997 = f_i12992._0(f_i12992, h_i12996);
                                                      {
                                                        const $trmc15_i12998 = { $: "Cons", _0: $t993_i12997, _1: null };
                                                        List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Op$List_List_Op(t_i12995, f_i12992, $trmc15_i12998);
                                                        $t48353 = $trmc15_i12998;
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
                                          let $t48354;
                                          {
                                            const prepend_reversed_i5985 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                            {
                                              const go_i5986 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5985 };
                                              {
                                                const $t1113_i5987 = { $: "Nil" };
                                                $t48354 = go$apply$1_List_concat_List_List_Op(go_i5986, $t48353, $t1113_i5987);
                                              }
                                            }
                                          }
                                          {
                                            let $t48355;
                                            $t48355 = Spin$View$banner_ops(m);
                                            {
                                              let $t48356;
                                              $t48356 = Spin$View$panel_ops(m);
                                              {
                                                let $t48357;
                                                if (touch === true) {
                                                  {
                                                    const $t48327_i5980 = { $: "Label", _0: "tap left · tap right to flip", _1: 140., _2: 752., _3: 9., _4: "rgba(185,166,255,0.55)" };
                                                    {
                                                      const $t48328_i5981 = { $: "Nil" };
                                                      $t48357 = { $: "Cons", _0: $t48327_i5980, _1: $t48328_i5981 };
                                                    }
                                                  }
                                                } else {
                                                  {
                                                    const $t48329_i5982 = { $: "Label", _0: "Z / ←  left    right  → / M    SPACE launch", _1: 185., _2: 752., _3: 7.5, _4: "rgba(185,166,255,0.45)" };
                                                    {
                                                      const $t48330_i5983 = { $: "Nil" };
                                                      $t48357 = { $: "Cons", _0: $t48329_i5982, _1: $t48330_i5983 };
                                                    }
                                                  }
                                                }
                                                {
                                                  const $t48358 = Spin$View$screen_ops(m);
                                                  {
                                                    const $t48359 = { $: "Nil" };
                                                    {
                                                      const $t48360 = { $: "Cons", _0: $t48358, _1: $t48359 };
                                                      {
                                                        const $t48361 = { $: "Cons", _0: $t48357, _1: $t48360 };
                                                        {
                                                          const $t48362 = { $: "Cons", _0: $t48356, _1: $t48361 };
                                                          {
                                                            const $t48363 = { $: "Cons", _0: $t48355, _1: $t48362 };
                                                            {
                                                              const $t48364 = { $: "Cons", _0: $t48354, _1: $t48363 };
                                                              {
                                                                const $t48365 = { $: "Cons", _0: $t48351, _1: $t48364 };
                                                                {
                                                                  const $t48366 = { $: "Cons", _0: $t48347, _1: $t48365 };
                                                                  {
                                                                    const $t48367 = { $: "Cons", _0: $t48343, _1: $t48366 };
                                                                    {
                                                                      const $t48368 = { $: "Cons", _0: $t48342, _1: $t48367 };
                                                                      {
                                                                        const $t48369 = { $: "Cons", _0: $t48336, _1: $t48368 };
                                                                        {
                                                                          const $t48370 = { $: "Cons", _0: $t48335, _1: $t48369 };
                                                                          {
                                                                            const $t48371 = { $: "Cons", _0: $t48334, _1: $t48370 };
                                                                            {
                                                                              const prepend_reversed_i5976 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                                              {
                                                                                const go_i5977 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5976 };
                                                                                {
                                                                                  const $t1113_i5978 = { $: "Nil" };
                                                                                  return go$apply$1_List_concat_List_List_Op(go_i5977, $t48371, $t1113_i5978);
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
      const $f48376 = c._0;
      {
        const n = $f48376;
        {
          const $t48372 = n;
          return { _0: "load", _1: $t48372 };
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
      const $f48377 = c._0;
      {
        const i = $f48377;
        {
          const $t48373 = i;
          return { _0: "reelstop", _1: $t48373 };
        }
      }
      break;
    }
    case "CueReelStart": {
      return { _0: "reelstart", _1: 0. };
      break;
    }
    case "CueWin": {
      const $f48378 = c._0;
      {
        const n = $f48378;
        {
          const $t48374 = n;
          return { _0: "win", _1: $t48374 };
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
      const $f48379 = c._0;
      {
        const n = $f48379;
        {
          const $t48375 = n;
          return { _0: "burn", _1: $t48375 };
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
      const $f48380 = c._0;
      {
        const speed = $f48380;
        return { _0: "thud", _1: speed };
      }
      break;
    }
    case "CueStore": {
      const $f48381 = c._0;
      return { _0: "", _1: 0. };
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
      const $f48383 = c._0;
      {
        const best = $f48383;
        return glue_save_best$clo._0(glue_save_best$clo, best);
      }
      break;
    }
    default: {
      {
        const $p48382 = sound(c);
        {
          const name = $p48382._0;
          {
            const x = $p48382._1;
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
      let $t48389;
      {
        const $t48388 = m.mode;
        switch ($t48388.$) {
          case "Attract": {
            $t48389 = "attract";
            break;
          }
          case "Playing": {
            $t48389 = "playing";
            break;
          }
          case "Busted": {
            $t48389 = "busted";
            break;
          }
          default: {
            throw new Error("non-exhaustive pattern match");
            break;
          }
        }
      }
      {
        const $rc_2711 = glue_mark$clo._0(glue_mark$clo, "data-mode", $t48389);
        $eff = $rc_2711;
      }
    }
  }
  {
    let $eff;
    {
      let $t48391;
      {
        const $t48390 = m.credits;
        $t48391 = String($t48390);
      }
      {
        const $rc_2710 = glue_mark$clo._0(glue_mark$clo, "data-credits", $t48391);
        $eff = $rc_2710;
      }
    }
  }
  {
    let $eff;
    {
      let $t48394;
      {
        let $t48393;
        {
          const $t48392 = m.balls;
          {  };
          $t48393 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t48392, 0);
        }
        $t48394 = String($t48393);
      }
      {
        const $rc_2709 = glue_mark$clo._0(glue_mark$clo, "data-balls", $t48394);
        $eff = $rc_2709;
      }
    }
  }
  {
    let $eff;
    {
      let $t48397;
      {
        let $t48396;
        {
          const $t48395 = m.bank;
          $t48396 = $t48395.banked;
        }
        $t48397 = String($t48396);
      }
      {
        const $rc_2708 = glue_mark$clo._0(glue_mark$clo, "data-banked", $t48397);
        $eff = $rc_2708;
      }
    }
  }
  {
    let $eff;
    {
      let $t48399;
      {
        const $t48398 = m.paid;
        $t48399 = String($t48398);
      }
      {
        const $rc_2707 = glue_mark$clo._0(glue_mark$clo, "data-paid", $t48399);
        $eff = $rc_2707;
      }
    }
  }
  {
    let $eff;
    {
      let $t48401;
      {
        const $t48400 = Spin$Game$waiting(m);
        if ($t48400 === true) {
          $t48401 = "1";
        } else {
          $t48401 = "0";
        }
      }
      {
        const $rc_2706 = glue_mark$clo._0(glue_mark$clo, "data-waiting", $t48401);
        $eff = $rc_2706;
      }
    }
  }
  {
    const $t48402 = String(flips);
    {
      const $rc_2705 = glue_mark$clo._0(glue_mark$clo, "data-flips", $t48402);
      return $rc_2705;
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
        let $t48404;
        {
          const $t48403 = s.last_t;
          $t48404 = ($t48403 > 0.);
        }
        if ($t48404 === true) {
          {
            const $t48405 = s.last_t;
            dt = (t - $t48405);
          }
        } else {
          dt = 0.;
        }
      }
      {
        let $eff;
        {
          let $t48412;
          {
            let $t48407;
            {
              const $t48406 = s.model;
              $t48407 = Spin$Game$waiting($t48406);
            }
            {
              let $t48411;
              {
                let $t48409;
                {
                  const $t48408 = s.model;
                  $t48409 = $t48408.mode;
                }
                {
                  const $t48410 = { $: "Playing" };
                  {
                    const $rc_2715 = march_deep_eq($t48409, $t48410);
                    $t48411 = $rc_2715;
                  }
                }
              }
              $t48412 = ($t48407 && $t48411);
            }
          }
          $eff = glue_launch_button$clo._0(glue_launch_button$clo, 306., 724., 30., $t48412);
        }
      }
      {
        const $p48429 = glue_input();
        {
          const l = $p48429._0;
          {
            const r = $p48429._1;
            {
              const launch = $p48429._2;
              {
                const start = $p48429._3;
                {
                  let $p48428;
                  {
                    const $t48413 = s.model;
                    {
                      const $t48414 = ({ left: l, right: r, launch: launch, start: start });
                      $p48428 = Spin$Game$tick($t48413, $t48414, dt);
                    }
                  }
                  {
                    const m = $p48428._0;
                    {
                      const cues = $p48428._1;
                      {
                        let flips;
                        {
                          const $t48415 = s.flips;
                          {
                            let $t48419;
                            {
                              const $t48417 = { $: "$Clo_$lam0_frame$0_frame", _0: $lam0_frame$apply$0_frame };
                              {
                                let $t48418;
                                $t48418 = List$filter$List_Cue$Fn_Cue_Bool(cues, $t48417);
                                {
                                  let $rc_2714;
                                  {  };
                                  $rc_2714 = List$length_onto$List_Cue$Int($t48418, 0);
                                  $t48419 = $rc_2714;
                                }
                              }
                            }
                            flips = (($t48415 + $t48419) < 4611686018427387904 && ($t48415 + $t48419) >= -4611686018427387904 ? ($t48415 + $t48419) : march_int_ovf(($t48415 + $t48419), 0));
                          }
                        }
                        {
                          let $eff;
                          {
                            let $t48420;
                            $t48420 = ({ ...s, model: m, last_t: t, flips: flips });
                            {
                              const $rc_2713 = glue_cell_put$clo._0(glue_cell_put$clo, $t48420);
                              $eff = $rc_2713;
                            }
                          }
                        }
                        {
                          let $eff;
                          {
                            const f_i5995 = perform$clo;
                            {
                              const go_i5996 = { $: "$Clo_go$0_List_each_List_Cue_Fn_Cue_T_", _0: go$apply$0_List_each_List_Cue_Fn_Cue_T_, _1: f_i5995 };
                              $eff = go$apply$0_List_each_List_Cue_Fn_Cue_T_(go_i5996, cues);
                            }
                          }
                        }
                        {
                          let $p48427;
                          {
                            const $t47442_i5993 = (-96.);
                            $p48427 = { _0: 0., _1: $t47442_i5993, _2: 400., _3: 866. };
                          }
                          {
                            const x = $p48427._0;
                            {
                              const y = $p48427._1;
                              {
                                const w = $p48427._2;
                                {
                                  const h = $p48427._3;
                                  {
                                    let $eff;
                                    {
                                      const $t48421 = s.canvas;
                                      $eff = glue_fit$clo._0(glue_fit$clo, $t48421, x, y, w, h);
                                    }
                                  }
                                  {
                                    let $eff;
                                    {
                                      const $t48422 = s.ctx;
                                      {
                                        const $t48423 = glue_touch();
                                        {
                                          let $t48424;
                                          $t48424 = Spin$View$frame(m, $t48423);
                                          {
                                            const $rc_2712 = glue_paint$clo._0(glue_paint$clo, $t48422, $t48424);
                                            $eff = $rc_2712;
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
                                    const $t48426 = { $: "$Clo_$lam1_frame$1_frame", _0: $lam1_frame$apply$1_frame };
                                    return glue_request_frame$clo._0(glue_request_frame$clo, $t48426);
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
      let $t48431;
      {
        const id_i13032 = "table";
        {
          const $rc_2409_i13033 = dom_get_element_by_id$clo._0(dom_get_element_by_id$clo, "table");
          $t48431 = $rc_2409_i13033;
        }
      }
      switch ($t48431.$) {
        case "Some": {
          const $f48432 = $t48431._0;
          {
            const node = $f48432;
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
        let $t48433;
        {
          const node_i13030 = canvas;
          {
            const $rc_2455_i13031 = canvas_get_context$clo._0(canvas_get_context$clo, canvas);
            $t48433 = $rc_2455_i13031;
          }
        }
        switch ($t48433.$) {
          case "Some": {
            const $f48434 = $t48433._0;
            {
              const c = $f48434;
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
        const $p48440 = glue_seed_limbs();
        {
          const hi = $p48440._0;
          {
            const lo = $p48440._1;
            {
              let model;
              {
                let $t48435;
                {
                  let $t45821_i6000;
                  {
                    let $t45814_i14408;
                    {
                      const $t45813_i14407 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                      $t45814_i14408 = (($t45813_i14407 - 1) < 4611686018427387904 && ($t45813_i14407 - 1) >= -4611686018427387904 ? ($t45813_i14407 - 1) : march_int_ovf(($t45813_i14407 - 1), 1));
                    }
                    $t45821_i6000 = ((hi | 0) === hi && ($t45814_i14408 | 0) === $t45814_i14408 ? (hi & $t45814_i14408) : march_int_and(hi, $t45814_i14408));
                  }
                  {
                    let $t45822_i6001;
                    {
                      let $t45814_i14405;
                      {
                        const $t45813_i14404 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                        $t45814_i14405 = (($t45813_i14404 - 1) < 4611686018427387904 && ($t45813_i14404 - 1) >= -4611686018427387904 ? ($t45813_i14404 - 1) : march_int_ovf(($t45813_i14404 - 1), 1));
                      }
                      $t45822_i6001 = ((lo | 0) === lo && ($t45814_i14405 | 0) === $t45814_i14405 ? (lo & $t45814_i14405) : march_int_and(lo, $t45814_i14405));
                    }
                    $t48435 = ({ hi: $t45821_i6000, lo: $t45822_i6001 });
                  }
                }
                {
                  const $t48436 = glue_load_best();
                  model = Spin$Game$boot($t48435, $t48436);
                }
              }
              {
                let $eff;
                {
                  let $t48437;
                  $t48437 = ({ model: model, ctx: ctx, canvas: canvas, last_t: 0., flips: 0 });
                  {
                    const $rc_2717 = glue_cell_put$clo._0(glue_cell_put$clo, $t48437);
                    $eff = $rc_2717;
                  }
                }
              }
              {
                let $eff;
                {
                  const $rc_2716 = glue_listen$clo._0(glue_listen$clo, canvas);
                  $eff = $rc_2716;
                }
              }
              {
                const $t48439 = { $: "$Clo_$lam0_launch$0_launch", _0: $lam0_launch$apply$0_launch };
                return glue_request_frame$clo._0(glue_request_frame$clo, $t48439);
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
        const $f1144 = xs._0;
        const $f1145 = xs._1;
        {
          const t = $f1145;
          {
            const h = $f1144;
            {
              let $t1143;
              $t1143 = pred._0(pred, h);
              if ($t1143 === true) {
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
        const $f1081 = xs._0;
        const $f1082 = xs._1;
        {
          const t = $f1082;
          {
            const h = $f1081;
            {
              let $t1080;
              $t1080 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t1080;
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
        const $f1025 = xs._0;
        const $f1026 = xs._1;
        {
          const t = $f1026;
          {
            const h = $f1025;
            {
              let $t1023;
              $t1023 = pred._0(pred, h);
              if ($t1023 === true) {
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

function List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue($tco_a0, $tco_a1, $tco_a2) {
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
        const $f1081 = xs._0;
        const $f1082 = xs._1;
        {
          const t = $f1082;
          {
            const h = $f1081;
            {
              let $t1080;
              $t1080 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t1080;
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
const List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$clo = { _0: ($_, xs, acc, f) => List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue(xs, acc, f) };

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
        const $f1151 = xs._0;
        const $f1152 = xs._1;
        {
          const t = $f1152;
          {
            const h = $f1151;
            {
              let $t1150;
              $t1150 = pred._0(pred, h);
              if ($t1150 === true) {
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
        const $f1025 = xs._0;
        const $f1026 = xs._1;
        {
          const t = $f1026;
          {
            const h = $f1025;
            {
              let $t1023;
              $t1023 = pred._0(pred, h);
              if ($t1023 === true) {
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

function List$fold_left$List_Hit$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_Hit_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue($tco_a0, $tco_a1, $tco_a2) {
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
        const $f1081 = xs._0;
        const $f1082 = xs._1;
        {
          const t = $f1082;
          {
            const h = $f1081;
            {
              let $t1080;
              $t1080 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t1080;
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
const List$fold_left$List_Hit$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_Hit_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$clo = { _0: ($_, xs, acc, f) => List$fold_left$List_Hit$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_Hit_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue(xs, acc, f) };

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
        const $f1081 = xs._0;
        const $f1082 = xs._1;
        {
          const t = $f1082;
          {
            const h = $f1081;
            {
              let $t1080;
              $t1080 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t1080;
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
        const $f965 = xs._0;
        const $f966 = xs._1;
        {
          const t = $f966;
          {
            const h = $f965;
            {
              const $t963 = (n === 0);
              if ($t963 === true) {
                return { $: "Some", _0: h };
              } else {
                {
                  const $t964 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                  {
                    $tco_a0 = t;
                    $tco_a1 = $t964;
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
        const $f965 = xs._0;
        const $f966 = xs._1;
        {
          const t = $f966;
          {
            const h = $f965;
            {
              const $t963 = (n === 0);
              if ($t963 === true) {
                return { $: "Some", _0: h };
              } else {
                {
                  const $t964 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                  {
                    $tco_a0 = t;
                    $tco_a1 = $t964;
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
        const $f1025 = xs._0;
        const $f1026 = xs._1;
        {
          const t = $f1026;
          {
            const h = $f1025;
            {
              let $t1023;
              $t1023 = pred._0(pred, h);
              if ($t1023 === true) {
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
        const $f1129 = xs._0;
        const $f1130 = xs._1;
        {
          const t = $f1130;
          {
            let h;
            h = $f1129;
            {
              let $t1128;
              $t1128 = pred._0(pred, h);
              if ($t1128 === true) {
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
        const $f1144 = xs._0;
        const $f1145 = xs._1;
        {
          const t = $f1145;
          {
            const h = $f1144;
            {
              let $t1143;
              $t1143 = pred._0(pred, h);
              if ($t1143 === true) {
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
      const $f995 = xs._0;
      const $f996 = xs._1;
      {
        const t = $f996;
        {
          const h = $f995;
          {
            let $t993;
            $t993 = f._0(f, h);
            {
              const $trmc15 = { $: "Cons", _0: $t993, _1: null };
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
        const $f1151 = xs._0;
        const $f1152 = xs._1;
        {
          const t = $f1152;
          {
            const h = $f1151;
            {
              let $t1150;
              $t1150 = pred._0(pred, h);
              if ($t1150 === true) {
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

function List$map$List_Int$Fn_Int_List_Op(xs, f) {
  switch (xs.$) {
    case "Nil": {
      return { $: "Nil" };
      break;
    }
    case "Cons": {
      const $f995 = xs._0;
      const $f996 = xs._1;
      {
        const t = $f996;
        {
          const h = $f995;
          {
            let $t993;
            $t993 = f._0(f, h);
            {
              const $trmc15 = { $: "Cons", _0: $t993, _1: null };
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

function List$map$List_Int$Fn_Int_Op(xs, f) {
  switch (xs.$) {
    case "Nil": {
      return { $: "Nil" };
      break;
    }
    case "Cons": {
      const $f995 = xs._0;
      const $f996 = xs._1;
      {
        const t = $f996;
        {
          const h = $f995;
          {
            let $t993;
            $t993 = f._0(f, h);
            {
              const $trmc15 = { $: "Cons", _0: $t993, _1: null };
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
        const $f1025 = xs._0;
        const $f1026 = xs._1;
        {
          const t = $f1026;
          {
            const h = $f1025;
            {
              let $t1023;
              $t1023 = pred._0(pred, h);
              if ($t1023 === true) {
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f1025 = xs._0;
        const $f1026 = xs._1;
        {
          const t = $f1026;
          {
            const h = $f1025;
            {
              let $t1023;
              $t1023 = pred._0(pred, h);
              if ($t1023 === true) {
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f972 = lst._0;
        const $f973 = lst._1;
        {
          const t = $f973;
          {
            const $t971 = ((acc + 1) < 4611686018427387904 && (acc + 1) >= -4611686018427387904 ? (acc + 1) : march_int_ovf((acc + 1), 0));
            {
              $tco_a0 = t;
              $tco_a1 = $t971;
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f987 = xs._0;
        const $f988 = xs._1;
        {
          const t = $f988;
          {
            const h = $f987;
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f1025 = xs._0;
        const $f1026 = xs._1;
        {
          const t = $f1026;
          {
            const h = $f1025;
            {
              let $t1023;
              $t1023 = pred._0(pred, h);
              if ($t1023 === true) {
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
        const $f987 = xs._0;
        const $f988 = xs._1;
        {
          const t = $f988;
          {
            const h = $f987;
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

function List$drop$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const n = $tco_a1;
    {
      const $t1236 = (n <= 0);
      if ($t1236 === true) {
        return xs;
      } else {
        switch (xs.$) {
          case "Nil": {
            return { $: "Nil" };
            break;
          }
          case "Cons": {
            const $f1238 = xs._0;
            const $f1239 = xs._1;
            {
              const t = $f1239;
              {
                const $t1237 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                {
                  $tco_a0 = t;
                  $tco_a1 = $t1237;
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
        const $f972 = lst._0;
        const $f973 = lst._1;
        {
          const t = $f973;
          {
            const $t971 = ((acc + 1) < 4611686018427387904 && (acc + 1) >= -4611686018427387904 ? (acc + 1) : march_int_ovf((acc + 1), 0));
            {
              $tco_a0 = t;
              $tco_a1 = $t971;
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
        const $f1025 = xs._0;
        const $f1026 = xs._1;
        {
          const t = $f1026;
          {
            const h = $f1025;
            {
              let $t1023;
              $t1023 = pred._0(pred, h);
              if ($t1023 === true) {
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
      const $t1236 = (n <= 0);
      if ($t1236 === true) {
        return xs;
      } else {
        switch (xs.$) {
          case "Nil": {
            return { $: "Nil" };
            break;
          }
          case "Cons": {
            const $f1238 = xs._0;
            const $f1239 = xs._1;
            {
              const t = $f1239;
              {
                const $t1237 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                {
                  $tco_a0 = t;
                  $tco_a1 = $t1237;
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f987 = xs._0;
        const $f988 = xs._1;
        {
          const t = $f988;
          {
            const h = $f987;
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f987 = xs._0;
        const $f988 = xs._1;
        {
          const t = $f988;
          {
            const h = $f987;
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f995 = xs._0;
        const $f996 = xs._1;
        {
          const t = $f996;
          {
            const h = $f995;
            {
              let $t993;
              $t993 = f._0(f, h);
              {
                const $trmc14 = { $: "Cons", _0: $t993, _1: null };
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
        const $f972 = lst._0;
        const $f973 = lst._1;
        {
          const t = $f973;
          {
            const $t971 = ((acc + 1) < 4611686018427387904 && (acc + 1) >= -4611686018427387904 ? (acc + 1) : march_int_ovf((acc + 1), 0));
            {
              $tco_a0 = t;
              $tco_a1 = $t971;
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
        const $f1025 = xs._0;
        const $f1026 = xs._1;
        {
          const t = $f1026;
          {
            const h = $f1025;
            {
              let $t1023;
              $t1023 = pred._0(pred, h);
              if ($t1023 === true) {
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
        const $f980 = lst._0;
        const $f981 = lst._1;
        {
          const t = $f981;
          {
            const h = $f980;
            {
              const $t979 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t979;
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
        const $f980 = lst._0;
        const $f981 = lst._1;
        {
          const t = $f981;
          {
            const h = $f980;
            {
              const $t979 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t979;
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
        const $f987 = xs._0;
        const $f988 = xs._1;
        {
          const t = $f988;
          {
            const h = $f987;
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
      const $t1227 = (k <= 0);
      if ($t1227 === true) {
        {
          const $t978_i7881 = { $: "Nil" };
          return List$reverse_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(acc, $t978_i7881);
        }
      } else {
        switch (lst.$) {
          case "Nil": {
            {
              const $t978_i7879 = { $: "Nil" };
              return List$reverse_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(acc, $t978_i7879);
            }
            break;
          }
          case "Cons": {
            const $f1230 = lst._0;
            const $f1231 = lst._1;
            {
              const t = $f1231;
              {
                const h = $f1230;
                {
                  const $t1228 = ((k - 1) < 4611686018427387904 && (k - 1) >= -4611686018427387904 ? (k - 1) : march_int_ovf((k - 1), 1));
                  {
                    const $t1229 = { $: "Cons", _0: h, _1: acc };
                    {
                      $tco_a0 = t;
                      $tco_a1 = $t1228;
                      $tco_a2 = $t1229;
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
        const $f987 = xs._0;
        const $f988 = xs._1;
        {
          const t = $f988;
          {
            const h = $f987;
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
      const $t1227 = (k <= 0);
      if ($t1227 === true) {
        {
          const $t978_i7885 = { $: "Nil" };
          return List$reverse_onto$List_Symbol$List_Symbol(acc, $t978_i7885);
        }
      } else {
        switch (lst.$) {
          case "Nil": {
            {
              const $t978_i7883 = { $: "Nil" };
              return List$reverse_onto$List_Symbol$List_Symbol(acc, $t978_i7883);
            }
            break;
          }
          case "Cons": {
            const $f1230 = lst._0;
            const $f1231 = lst._1;
            {
              const t = $f1231;
              {
                const h = $f1230;
                {
                  const $t1228 = ((k - 1) < 4611686018427387904 && (k - 1) >= -4611686018427387904 ? (k - 1) : march_int_ovf((k - 1), 1));
                  {
                    const $t1229 = { $: "Cons", _0: h, _1: acc };
                    {
                      $tco_a0 = t;
                      $tco_a1 = $t1228;
                      $tco_a2 = $t1229;
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
        const $f980 = lst._0;
        const $f981 = lst._1;
        {
          const t = $f981;
          {
            const h = $f980;
            {
              const $t979 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t979;
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
        const $f980 = lst._0;
        const $f981 = lst._1;
        {
          const t = $f981;
          {
            const h = $f980;
            {
              const $t979 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t979;
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
        const $f980 = lst._0;
        const $f981 = lst._1;
        {
          const t = $f981;
          {
            const h = $f980;
            {
              const $t979 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t979;
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
        const $f980 = lst._0;
        const $f981 = lst._1;
        {
          const t = $f981;
          {
            const h = $f980;
            {
              const $t979 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t979;
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
        const $f980 = lst._0;
        const $f981 = lst._1;
        {
          const t = $f981;
          {
            const h = $f980;
            {
              const $t979 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t979;
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
          const $t912 = (i < start);
          if ($t912 === true) {
            return acc;
          } else {
            {
              const $t913 = ((i - 1) < 4611686018427387904 && (i - 1) >= -4611686018427387904 ? (i - 1) : march_int_ovf((i - 1), 1));
              {
                const $t914 = { $: "Cons", _0: i, _1: acc };
                {
                  $tco_a0 = go;
                  $tco_a1 = $t913;
                  $tco_a2 = $t914;
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
    const $t46193 = Spin$Game$resting_in_lane(b);
    return (!$t46193);
  }
}
const $lam0_Spin_Game_in_play$apply$0_Spin_Game_in_play$clo = { _0: ($_, $clo, b) => $lam0_Spin_Game_in_play$apply$0_Spin_Game_in_play($clo, b) };

function $lam0_Spin_Game_light$apply$0_Spin_Game_light($clo, acc, l) {
  {
    const f = $clo._1;
    {
      const $p46198 = l;
      {
        const g = l._0;
        {
          const t = l._1;
          {
            const $t46197 = march_deep_eq(g, f);
            if ($t46197 === true) {
              {
                const $t45787_i8739 = (t >= acc);
                if ($t45787_i8739 === true) {
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
      const $p46203 = l;
      {
        const g = l._0;
        {
          const $rc_3436 = (!march_deep_eq(g, f));
          return $rc_3436;
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
      const $p46212 = l;
      {
        const g = l._0;
        {
          const t = l._1;
          {
            let $t46211;
            {
              const $t46210 = (dt * 2.5);
              $t46211 = (t - $t46210);
            }
            {
              const $rc_3438 = { _0: g, _1: $t46211 };
              return $rc_3438;
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
    const $p46207_i14057 = l;
    {
      const t_i14058 = l._1;
      return (t_i14058 > 0.);
    }
  }
}
const $lam1_Spin_Game_fade$apply$1_Spin_Game_fade$clo = { _0: ($_, $clo, l) => $lam1_Spin_Game_fade$apply$1_Spin_Game_fade($clo, l) };

function $lam0_Spin_Game_fire$apply$0_Spin_Game_fire($clo, b) {
  {
    const speed = $clo._1;
    {
      let $t46346;
      $t46346 = Spin$Game$resting_in_lane(b);
      if ($t46346 === true) {
        {
          let $t46348;
          {
            const $t46347 = (-speed);
            $t46348 = ({ x: 0., y: $t46347 });
          }
          {
            const $rc_3439 = ({ ...b, vel: $t46348 });
            return $rc_3439;
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
    let $t46383;
    {
      const $t46382 = b.pos;
      $t46383 = Spin$Table$in_lane($t46382);
    }
    return (!$t46383);
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
            const $t46412 = m.table;
            return Spin$Physics$step_ball($t46412, l, r, h, b);
          }
        }
      }
    }
  }
}
const $lam0_Spin_Game_step_balls$apply$0_Spin_Game_step_balls$clo = { _0: ($_, $clo, b) => $lam0_Spin_Game_step_balls$apply$0_Spin_Game_step_balls($clo, b) };

function $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls($clo, x) {
  {
    const $p46415 = x;
    {
      const b = x._0;
      return b;
    }
  }
}
const $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls$clo = { _0: ($_, $clo, x) => $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls($clo, x) };

function $lam2_Spin_Game_step_balls$apply$2_Spin_Game_step_balls($clo, x) {
  {
    const $p46418 = x;
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
      let $t46436;
      {
        const $t46435 = b.pos;
        $t46436 = $t46435.y;
      }
      {
        let $t46438;
        {
          const $t46437 = m.table;
          $t46438 = $t46437.drain_y;
        }
        return ($t46436 < $t46438);
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
        const $t46880 = b.pos;
        return Spin$Physics$against(r, $t46880, acc, part);
      }
    }
  }
}
const $lam0_Spin_Physics_step_ball$apply$0_Spin_Physics_step_ball$clo = { _0: ($_, $clo, acc, part) => $lam0_Spin_Physics_step_ball$apply$0_Spin_Physics_step_ball($clo, acc, part) };

function $lam0_Spin_Reels_count$apply$0_Spin_Reels_count($clo, x) {
  {
    const s = $clo._1;
    {
      const $rc_3444 = march_deep_eq(x, s);
      return $rc_3444;
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
    const $jp_clo47001 = $clo._1;
    return $jp_clo47001._0($jp_clo47001);
  }
}
const $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays$clo = { _0: ($_, $clo) => $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays($clo) };

function $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop($clo, k) {
  {
    const r = $clo._1;
    {
      let $t47025;
      {
        const $t47024 = r.pos;
        $t47025 = (($t47024 + k) < 4611686018427387904 && ($t47024 + k) >= -4611686018427387904 ? ($t47024 + k) : march_int_ovf(($t47024 + k), 0));
      }
      return Spin$Reels$wrap($t47025);
    }
  }
}
const $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop$clo = { _0: ($_, $clo, k) => $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop($clo, k) };

function $lam1_Spin_Reels_target_stop$apply$1_Spin_Reels_target_stop($clo, i) {
  {
    const r = $clo._1;
    {
      let $t47028;
      $t47028 = Spin$Reels$stop(r, i);
      {
        const $t47029 = { $: "Blank" };
        {
          const $rc_3445 = march_deep_eq($t47028, $t47029);
          return $rc_3445;
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
        let $t47036;
        {
          let $t47035;
          {
            const $t47034 = r.pos;
            $t47035 = (($t47034 + k) < 4611686018427387904 && ($t47034 + k) >= -4611686018427387904 ? ($t47034 + k) : march_int_ovf(($t47034 + k), 0));
          }
          $t47036 = Spin$Reels$stop(r, $t47035);
        }
        {
          const $rc_3446 = march_deep_eq($t47036, s);
          return $rc_3446;
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
        let $t47043;
        {
          let $t47042;
          {
            let $t47041;
            {
              const $t47040 = r.pos;
              $t47041 = (($t47040 + k) < 4611686018427387904 && ($t47040 + k) >= -4611686018427387904 ? ($t47040 + k) : march_int_ovf(($t47040 + k), 0));
            }
            $t47042 = Spin$Reels$stop(r, $t47041);
          }
          {
            const $rc_3447 = Spin$Reels$rank($t47042);
            $t47043 = $rc_3447;
          }
        }
        {
          const $t47044 = Spin$Reels$rank(s);
          return ($t47043 >= $t47044);
        }
      }
    }
  }
}
const $lam1_Spin_Reels_roll_to$apply$1_Spin_Reels_roll_to$clo = { _0: ($_, $clo, k) => $lam1_Spin_Reels_roll_to$apply$1_Spin_Reels_roll_to($clo, k) };

function $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning($clo, r) {
  {
    const $t47140 = r.duration;
    return ($t47140 > 0.);
  }
}
const $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning$clo = { _0: ($_, $clo, r) => $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning($clo, r) };

function $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold($clo, x) {
  {
    const $rc_3448 = x.held;
    return $rc_3448;
  }
}
const $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold$clo = { _0: ($_, $clo, x) => $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold($clo, x) };

function $lam0_Spin_Table_arch$apply$0_Spin_Table_arch($clo, i) {
  {
    const n = $clo._1;
    {
      let $t47262;
      $t47262 = Spin$Table$arch_point(n, i);
      {
        let $t47264;
        {
          const $t47263 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
          $t47264 = Spin$Table$arch_point(n, $t47263);
        }
        return { $: "Wall", _0: $t47262, _1: $t47264, _2: 0.5 };
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
                let $t47447;
                {
                  const $t47445 = n.tau;
                  {
                    const $t47446 = i;
                    $t47447 = ($t47445 * $t47446);
                  }
                }
                a = ($t47447 / 12.);
              }
              {
                let $t47450;
                {
                  let $t47449;
                  {
                    const $t47448 = Math.cos(a);
                    $t47449 = (rx * $t47448);
                  }
                  $t47450 = (cx + $t47449);
                }
                {
                  let $t47453;
                  {
                    let $t47452;
                    {
                      const $t47451 = Math.sin(a);
                      $t47452 = (ry * $t47451);
                    }
                    $t47453 = (cy + $t47452);
                  }
                  return ({ x: $t47450, y: $t47453 });
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
                    let $t47604;
                    {
                      let $t47602;
                      {
                        const $t47601 = k;
                        $t47602 = (frac - $t47601);
                      }
                      $t47604 = ($t47602 * 32.);
                    }
                    y = (line_y + $t47604);
                  }
                  {
                    let s;
                    s = Spin$Reels$stop(r, j);
                    {
                      let fresh;
                      {
                        let $t47608;
                        {
                          const $t47606 = march_int_mod_euclid(j, 8);
                          {
                            const $t47607 = r.fresh;
                            $t47608 = ($t47606 === $t47607);
                          }
                        }
                        {
                          let $t47610;
                          {
                            const $t47609 = r.glow;
                            $t47610 = ($t47609 > 0.);
                          }
                          fresh = ($t47608 && $t47610);
                        }
                      }
                      {
                        let halo;
                        if (fresh === true) {
                          {
                            let $t47614;
                            {
                              const $t47611 = (x0 + 30.);
                              {
                                let $t47613;
                                {
                                  const $t47612 = r.glow;
                                  $t47613 = Spin$Draw$rgba(255, 230, 120, $t47612);
                                }
                                $t47614 = { $: "Glow", _0: $t47611, _1: y, _2: 26., _3: $t47613 };
                              }
                            }
                            {
                              const $t47615 = { $: "Nil" };
                              halo = { $: "Cons", _0: $t47614, _1: $t47615 };
                            }
                          }
                        } else {
                          halo = { $: "Nil" };
                        }
                        {
                          const $t47616 = m.num;
                          {
                            const $t47617 = (x0 + 30.);
                            {
                              let $t47618;
                              {
                                let $rc_3449;
                                $rc_3449 = Spin$View$symbol($t47616, s, $t47617, y, 1.);
                                $t47618 = $rc_3449;
                              }
                              {
                                const xs_i14059 = halo;
                                {
                                  const ys_i14060 = $t47618;
                                  switch (xs_i14059.$) {
                                    case "Nil": {
                                      return $t47618;
                                      break;
                                    }
                                    case "Cons": {
                                      const $f987_i14061 = xs_i14059._0;
                                      const $f988_i14062 = xs_i14059._1;
                                      {
                                        const t_i14063 = $f988_i14062;
                                        {
                                          const h_i14064 = $f987_i14061;
                                          {
                                            const $trmc11_i14065 = { $: "Cons", _0: h_i14064, _1: null };
                                            List$append$dps$List_Op$List_Op$List_Op(t_i14063, $t47618, $trmc11_i14065);
                                            return $trmc11_i14065;
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
                let $t47698;
                {
                  const $t47697 = (ww / 2.);
                  $t47698 = (wx + $t47697);
                }
                {
                  let $t47701;
                  {
                    let $t47700;
                    {
                      const $t47699 = i;
                      $t47700 = ($t47699 - 2.);
                    }
                    $t47701 = ($t47700 * 16.);
                  }
                  cx = ($t47698 + $t47701);
                }
              }
              {
                let $t47703;
                {
                  const $t47702 = b.banked;
                  $t47703 = (i < $t47702);
                }
                if ($t47703 === true) {
                  {
                    let $t47705;
                    {
                      const $t47704 = (wy + wh);
                      $t47705 = ($t47704 + 14.);
                    }
                    return { $: "Disc", _0: cx, _1: $t47705, _2: 5., _3: "#5cf2ff" };
                  }
                } else {
                  {
                    let $t47707;
                    {
                      const $t47706 = (wy + wh);
                      $t47707 = ($t47706 + 14.);
                    }
                    return { $: "Ring", _0: cx, _1: $t47707, _2: 5., _3: 1.5, _4: "#3d4d6a" };
                  }
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

function $lam0_Spin_View_plunger_ops$apply$0_Spin_View_plunger_ops($clo, i) {
  {
    const m = $clo._1;
    {
      const top = $clo._2;
      {
        let y;
        {
          const $t48139 = (top + 6.);
          {
            let $t48145;
            {
              let $t48144;
              {
                const $t48140 = i;
                {
                  let $t48143;
                  {
                    let $t48142;
                    {
                      const $t48141 = m.pull;
                      $t48142 = (20. * $t48141);
                    }
                    $t48143 = (40. - $t48142);
                  }
                  $t48144 = ($t48140 * $t48143);
                }
              }
              $t48145 = ($t48144 / 6.);
            }
            y = ($t48139 + $t48145);
          }
        }
        {
          const $t48146 = ({ x: 356., y: y });
          {
            let $t48148;
            {
              const $t48147 = (y + 3.);
              $t48148 = ({ x: 374., y: $t48147 });
            }
            return Spin$Draw$stick($t48146, $t48148, 2., "#9aa3b5");
          }
        }
      }
    }
  }
}
const $lam0_Spin_View_plunger_ops$apply$0_Spin_View_plunger_ops$clo = { _0: ($_, $clo, i) => $lam0_Spin_View_plunger_ops$apply$0_Spin_View_plunger_ops($clo, i) };

function $lam0_Spin_View_frame$apply$0_Spin_View_frame($clo, p) {
  {
    const m = $clo._1;
    return Spin$View$part_ops(m, p);
  }
}
const $lam0_Spin_View_frame$apply$0_Spin_View_frame$clo = { _0: ($_, $clo, p) => $lam0_Spin_View_frame$apply$0_Spin_View_frame($clo, p) };

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
          const $f1100 = sub._0;
          const $f1101 = sub._1;
          {
            const rest = $f1101;
            {
              const x = $f1100;
              {
                const $t1099 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1099;
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
              const $t978_i8887 = { $: "Nil" };
              return List$reverse_onto$List_Hit$List_Hit(acc, $t978_i8887);
            }
            break;
          }
          case "Cons": {
            const $f1107 = lst._0;
            const $f1108 = lst._1;
            {
              const rest = $f1108;
              {
                const xs = $f1107;
                {
                  let $t1106;
                  $t1106 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1106;
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
          const $f1100 = sub._0;
          const $f1101 = sub._1;
          {
            const rest = $f1101;
            {
              const x = $f1100;
              {
                const $t1099 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1099;
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
              const $t978_i8889 = { $: "Nil" };
              return List$reverse_onto$List_Cue$List_Cue(acc, $t978_i8889);
            }
            break;
          }
          case "Cons": {
            const $f1107 = lst._0;
            const $f1108 = lst._1;
            {
              const rest = $f1108;
              {
                const xs = $f1107;
                {
                  let $t1106;
                  $t1106 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1106;
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
          const $f1100 = sub._0;
          const $f1101 = sub._1;
          {
            const rest = $f1101;
            {
              const x = $f1100;
              {
                const $t1099 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1099;
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
              const $t978_i8891 = { $: "Nil" };
              return List$reverse_onto$List_ReelEvent$List_ReelEvent(acc, $t978_i8891);
            }
            break;
          }
          case "Cons": {
            const $f1107 = lst._0;
            const $f1108 = lst._1;
            {
              const rest = $f1108;
              {
                const xs = $f1107;
                {
                  let $t1106;
                  $t1106 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1106;
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
          const $f1100 = sub._0;
          const $f1101 = sub._1;
          {
            const rest = $f1101;
            {
              const x = $f1100;
              {
                const $t1099 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1099;
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
              const $t978_i8893 = { $: "Nil" };
              return List$reverse_onto$List_Part$List_Part(acc, $t978_i8893);
            }
            break;
          }
          case "Cons": {
            const $f1107 = lst._0;
            const $f1108 = lst._1;
            {
              const rest = $f1108;
              {
                const xs = $f1107;
                {
                  let $t1106;
                  $t1106 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1106;
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
          const $f1100 = sub._0;
          const $f1101 = sub._1;
          {
            const rest = $f1101;
            {
              const x = $f1100;
              {
                const $t1099 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t1099;
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
              const $t978_i8895 = { $: "Nil" };
              return List$reverse_onto$List_Op$List_Op(acc, $t978_i8895);
            }
            break;
          }
          case "Cons": {
            const $f1107 = lst._0;
            const $f1108 = lst._1;
            {
              const rest = $f1108;
              {
                const xs = $f1107;
                {
                  let $t1106;
                  $t1106 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t1106;
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
            const $f1002 = lst._0;
            const $f1003 = lst._1;
            {
              const t = $f1003;
              {
                const h = $f1002;
                {
                  let $p1001;
                  $p1001 = f._0(f, h);
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
