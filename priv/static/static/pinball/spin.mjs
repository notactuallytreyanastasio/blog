import { march_deep_eq, march_float_round, march_float_to_string, march_int_and, march_int_div, march_int_div_euclid, march_int_div_floor, march_int_mod, march_int_mod_euclid, march_int_mod_floor, march_int_not, march_int_or, march_int_ovf, march_int_popcount, march_int_shl, march_int_shr, march_int_wrapping_add, march_int_wrapping_mul, march_int_wrapping_sub, march_int_xor, march_string_byte_length, march_string_concat3, march_string_concat_n, march_string_contains, march_string_pad_left, march_string_to_float, march_unix_time, march_unix_time_ms } from "./march_runtime.mjs";

import { glue_mark, glue_save_best, glue_load_best, glue_seed_limbs, glue_sound, glue_paint, glue_fit, glue_input, glue_listen, glue_request_frame, glue_cell_get, glue_cell_put } from "./spin_glue.mjs";
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
                                    let $t45814_i14131;
                                    {
                                      const $t45813_i14130 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                                      $t45814_i14131 = (($t45813_i14130 - 1) < 4611686018427387904 && ($t45813_i14130 - 1) >= -4611686018427387904 ? ($t45813_i14130 - 1) : march_int_ovf(($t45813_i14130 - 1), 1));
                                    }
                                    $t45935 = (($t45919_i5264 | 0) === $t45919_i5264 && ($t45814_i14131 | 0) === $t45814_i14131 ? ($t45919_i5264 & $t45814_i14131) : march_int_and($t45919_i5264, $t45814_i14131));
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
                                    let $t45814_i14121;
                                    {
                                      const $t45813_i14120 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                                      $t45814_i14121 = (($t45813_i14120 - 1) < 4611686018427387904 && ($t45813_i14120 - 1) >= -4611686018427387904 ? ($t45813_i14120 - 1) : march_int_ovf(($t45813_i14120 - 1), 1));
                                    }
                                    $t45939 = (($t45919_i5249 | 0) === $t45919_i5249 && ($t45814_i14121 | 0) === $t45814_i14121 ? ($t45919_i5249 & $t45814_i14121) : march_int_and($t45919_i5249, $t45814_i14121));
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
            let $t45814_i14156;
            {
              const $t45813_i14155 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
              $t45814_i14156 = (($t45813_i14155 - 1) < 4611686018427387904 && ($t45813_i14155 - 1) >= -4611686018427387904 ? ($t45813_i14155 - 1) : march_int_ovf(($t45813_i14155 - 1), 1));
            }
            $t45821_i5282 = ((2654435769 | 0) === 2654435769 && ($t45814_i14156 | 0) === $t45814_i14156 ? (2654435769 & $t45814_i14156) : march_int_and(2654435769, $t45814_i14156));
          }
          {
            let $t45822_i5283;
            {
              let $t45814_i14153;
              {
                const $t45813_i14152 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                $t45814_i14153 = (($t45813_i14152 - 1) < 4611686018427387904 && ($t45813_i14152 - 1) >= -4611686018427387904 ? ($t45813_i14152 - 1) : march_int_ovf(($t45813_i14152 - 1), 1));
              }
              $t45822_i5283 = ((2135587861 | 0) === 2135587861 && ($t45814_i14153 | 0) === $t45814_i14153 ? (2135587861 & $t45814_i14153) : march_int_and(2135587861, $t45814_i14153));
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
              let $t45814_i14150;
              {
                const $t45813_i14149 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                $t45814_i14150 = (($t45813_i14149 - 1) < 4611686018427387904 && ($t45813_i14149 - 1) >= -4611686018427387904 ? ($t45813_i14149 - 1) : march_int_ovf(($t45813_i14149 - 1), 1));
              }
              $t45821_i5278 = ((3210233709 | 0) === 3210233709 && ($t45814_i14150 | 0) === $t45814_i14150 ? (3210233709 & $t45814_i14150) : march_int_and(3210233709, $t45814_i14150));
            }
            {
              let $t45822_i5279;
              {
                let $t45814_i14147;
                {
                  const $t45813_i14146 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                  $t45814_i14147 = (($t45813_i14146 - 1) < 4611686018427387904 && ($t45813_i14146 - 1) >= -4611686018427387904 ? ($t45813_i14146 - 1) : march_int_ovf(($t45813_i14146 - 1), 1));
                }
                $t45822_i5279 = ((484763065 | 0) === 484763065 && ($t45814_i14147 | 0) === $t45814_i14147 ? (484763065 & $t45814_i14147) : march_int_and(484763065, $t45814_i14147));
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
                let $t45814_i14144;
                {
                  const $t45813_i14143 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                  $t45814_i14144 = (($t45813_i14143 - 1) < 4611686018427387904 && ($t45813_i14143 - 1) >= -4611686018427387904 ? ($t45813_i14143 - 1) : march_int_ovf(($t45813_i14143 - 1), 1));
                }
                $t45821_i5274 = ((2496678331 | 0) === 2496678331 && ($t45814_i14144 | 0) === $t45814_i14144 ? (2496678331 & $t45814_i14144) : march_int_and(2496678331, $t45814_i14144));
              }
              {
                let $t45822_i5275;
                {
                  let $t45814_i14141;
                  {
                    const $t45813_i14140 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                    $t45814_i14141 = (($t45813_i14140 - 1) < 4611686018427387904 && ($t45813_i14140 - 1) >= -4611686018427387904 ? ($t45813_i14140 - 1) : march_int_ovf(($t45813_i14140 - 1), 1));
                  }
                  $t45822_i5275 = ((321982955 | 0) === 321982955 && ($t45814_i14141 | 0) === $t45814_i14141 ? (321982955 & $t45814_i14141) : march_int_and(321982955, $t45814_i14141));
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
            let k_i14443;
            {
              let $t46143_i14442;
              {
                let $t46142_i14441;
                {
                  let $t45789_i5311_i14439;
                  {
                    const $t45787_i14162_i14438 = (0. >= a);
                    if ($t45787_i14162_i14438 === true) {
                      $t45789_i5311_i14439 = 0.;
                    } else {
                      $t45789_i5311_i14439 = a;
                    }
                  }
                  {
                    const $t45788_i14159_i14440 = (1. < $t45789_i5311_i14439);
                    if ($t45788_i14159_i14440 === true) {
                      $t46142_i14441 = 1.;
                    } else {
                      $t46142_i14441 = $t45789_i5311_i14439;
                    }
                  }
                }
                $t46143_i14442 = ($t46142_i14441 * 1000.);
              }
              k_i14443 = march_float_round($t46143_i14442);
            }
            {
              const $t46144_i14444 = (k_i14443 >= 1000);
              if ($t46144_i14444 === true) {
                $t46150 = "1";
              } else {
                {
                  let $t46146_i14447;
                  {
                    const $t46145_i14445 = String(k_i14443);
                    {
                      const $rc_2505_i14446 = march_string_pad_left($t46145_i14445, 3, "0");
                      $t46146_i14447 = $rc_2505_i14446;
                    }
                  }
                  {
                    const $rc_2504_i14448 = ("0." + $t46146_i14447);
                    $t46150 = $rc_2504_i14448;
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
        const n_i14351 = n;
        {
          let $t47425_i14352;
          $t47425_i14352 = Spin$Table$parts(n);
          {
            let $t47428_i14357;
            {
              const $t47426_i14355 = ({ x: 120., y: 660. });
              {
                const $t47427_i14356 = (-0.45);
                $t47428_i14357 = ({ pivot: $t47426_i14355, length: 54., radius: 7., rest: 0.52, up: $t47427_i14356 });
              }
            }
            {
              let $t47434_i14365;
              {
                const $t47429_i14360 = ({ x: 250., y: 660. });
                {
                  let $t47431_i14362;
                  {
                    const $t47430_i14361 = n.pi;
                    $t47431_i14362 = ($t47430_i14361 - 0.52);
                  }
                  {
                    let $t47433_i14364;
                    {
                      const $t47432_i14363 = n.pi;
                      $t47433_i14364 = ($t47432_i14363 + 0.45);
                    }
                    $t47434_i14365 = ({ pivot: $t47429_i14360, length: 54., radius: 7., rest: $t47431_i14362, up: $t47433_i14364 });
                  }
                }
              }
              {
                const $t47435_i14368 = ({ x: 365., y: 690. });
                {
                  const $t47436_i14369 = { _0: 95., _1: 378., _2: 180., _3: 96. };
                  t = ({ parts: $t47425_i14352, left: $t47428_i14357, right: $t47434_i14365, ball_radius: 9., gravity: 1150., plunger_rest: $t47435_i14368, drain_y: 770., width: 400., height: 760., reel_window: $t47436_i14369 });
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
          const xs_i12760 = $t46208;
          {
            const f_i12761 = $t46213;
            switch (xs_i12760.$) {
              case "Nil": {
                dimmer = { $: "Nil" };
                break;
              }
              case "Cons": {
                const $f995_i12762 = xs_i12760._0;
                const $f996_i12763 = xs_i12760._1;
                {
                  const t_i12764 = $f996_i12763;
                  {
                    const h_i12765 = $f995_i12762;
                    {
                      let $t993_i12766;
                      $t993_i12766 = f_i12761._0(f_i12761, h_i12765);
                      {
                        const $trmc15_i12767 = { $: "Cons", _0: $t993_i12766, _1: null };
                        List$map$dps$List_T_Feature_Float$Fn_T_Feature_Float_T_Feature_Float$List_T_Feature_Float(t_i12764, f_i12761, $trmc15_i12767);
                        dimmer = $trmc15_i12767;
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

function Spin$Game$press(m, input) {
  {
    const $t46343 = Spin$Game$waiting(m);
    if ($t46343 === true) {
      {
        let $t46346;
        {
          const $t46344 = input.launch;
          {
            const $t46345 = input.right;
            $t46346 = ($t46344 || $t46345);
          }
        }
        {
          const $rc_2547 = ({ ...input, launch: $t46346 });
          return $rc_2547;
        }
      }
    } else {
      return input;
    }
  }
}
const Spin$Game$press$clo = { _0: ($_, m, input) => Spin$Game$press(m, input) };

function Spin$Game$plunge(m, input, dt) {
  {
    let now_in;
    now_in = Spin$Game$press(m, input);
    {
      let then_in;
      {
        const $t46347 = m.last;
        then_in = Spin$Game$press(m, $t46347);
      }
      {
        const held = now_in.launch;
        {
          const was = then_in.launch;
          {
            let $t46349;
            {
              let $t46348;
              $t46348 = Spin$Game$waiting(m);
              $t46349 = (held && $t46348);
            }
            if ($t46349 === true) {
              {
                let $t46354;
                {
                  let $t46353;
                  {
                    let $t46352;
                    {
                      const $t46350 = m.pull;
                      {
                        const $t46351 = (dt * 1.3);
                        $t46352 = ($t46350 + $t46351);
                      }
                    }
                    {
                      const $t45788_i5333 = ($t46352 < 1.);
                      if ($t45788_i5333 === true) {
                        $t46353 = $t46352;
                      } else {
                        $t46353 = 1.;
                      }
                    }
                  }
                  $t46354 = ({ ...m, pull: $t46353 });
                }
                {
                  const $t46355 = { $: "Nil" };
                  {
                    const $rc_2553 = { _0: $t46354, _1: $t46355 };
                    return $rc_2553;
                  }
                }
              }
            } else {
              {
                let $t46362;
                {
                  let $t46360;
                  {
                    let $t46357;
                    {
                      const $t46356 = (!held);
                      $t46357 = (was && $t46356);
                    }
                    {
                      let $t46359;
                      {
                        const $t46358 = m.pull;
                        $t46359 = ($t46358 > 0.);
                      }
                      $t46360 = ($t46357 && $t46359);
                    }
                  }
                  {
                    let $t46361;
                    $t46361 = Spin$Game$waiting(m);
                    $t46362 = ($t46360 && $t46361);
                  }
                }
                if ($t46362 === true) {
                  {
                    let speed;
                    {
                      let $t46364;
                      {
                        const $t46363 = m.pull;
                        $t46364 = (700. * $t46363);
                      }
                      speed = (1050. + $t46364);
                    }
                    {
                      const $t46365 = m.balls;
                      {
                        const $t46370 = { $: "$Clo_$lam0_Spin_Game_plunge$0_Spin_Game_plunge", _0: $lam0_Spin_Game_plunge$apply$0_Spin_Game_plunge, _1: speed };
                        {
                          let launched;
                          {
                            const xs_i12769 = $t46365;
                            {
                              const f_i12770 = $t46370;
                              switch (xs_i12769.$) {
                                case "Nil": {
                                  launched = { $: "Nil" };
                                  break;
                                }
                                case "Cons": {
                                  const $f995_i12771 = xs_i12769._0;
                                  const $f996_i12772 = xs_i12769._1;
                                  {
                                    const t_i12773 = $f996_i12772;
                                    {
                                      const h_i12774 = $f995_i12771;
                                      {
                                        let $t993_i12775;
                                        $t993_i12775 = f_i12770._0(f_i12770, h_i12774);
                                        {
                                          const $trmc15_i12776 = { $: "Cons", _0: $t993_i12775, _1: null };
                                          List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t_i12773, f_i12770, $trmc15_i12776);
                                          launched = $trmc15_i12776;
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
                            const $t46371 = ({ ...m, balls: launched, pull: 0. });
                            {
                              const $t46372 = { $: "CueLaunch" };
                              {
                                const $t46373 = { $: "Nil" };
                                {
                                  const $t46374 = { $: "Cons", _0: $t46372, _1: $t46373 };
                                  {
                                    const $rc_2552 = { _0: $t46371, _1: $t46374 };
                                    return $rc_2552;
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
                    let $t46377;
                    {
                      let $t46376;
                      {
                        let $t46375;
                        $t46375 = Spin$Game$waiting(m);
                        if ($t46375 === true) {
                          $t46376 = m.pull;
                        } else {
                          $t46376 = 0.;
                        }
                      }
                      $t46377 = ({ ...m, pull: $t46376 });
                    }
                    {
                      const $t46378 = { $: "Nil" };
                      {
                        const $rc_2551 = { _0: $t46377, _1: $t46378 };
                        return $rc_2551;
                      }
                    }
                  }
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
      const $t46379 = m.balls;
      {
        const $t46383 = { $: "$Clo_$lam0_Spin_Game_auto_plunge$0_Spin_Game_auto_plunge", _0: $lam0_Spin_Game_auto_plunge$apply$0_Spin_Game_auto_plunge };
        lane_clear = List$all$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46379, $t46383);
      }
    }
    {
      let $t46386;
      {
        let $t46385;
        {
          const $t46384 = m.owed_balls;
          $t46385 = ($t46384 > 0);
        }
        $t46386 = ($t46385 && lane_clear);
      }
      if ($t46386 === true) {
        {
          let ball;
          {
            let $t46388;
            {
              const $t46387 = m.table;
              $t46388 = $t46387.plunger_rest;
            }
            {
              let $t46390;
              {
                const $t46389 = (-1650.);
                $t46390 = ({ x: 0., y: $t46389 });
              }
              ball = ({ pos: $t46388, vel: $t46390 });
            }
          }
          {
            let out;
            {
              let $t46395;
              {
                const $t46391 = m.balls;
                {
                  let $t46392;
                  $t46392 = { $: "Cons", _0: ball, _1: $t46391 };
                  {
                    let $t46394;
                    {
                      const $t46393 = m.owed_balls;
                      $t46394 = (($t46393 - 1) < 4611686018427387904 && ($t46393 - 1) >= -4611686018427387904 ? ($t46393 - 1) : march_int_ovf(($t46393 - 1), 1));
                    }
                    $t46395 = ({ ...m, balls: $t46392, owed_balls: $t46394 });
                  }
                }
              }
              {
                const $t46396 = { $: "CueLaunch" };
                {
                  const $t46397 = { $: "Nil" };
                  {
                    const $t46398 = { $: "Cons", _0: $t46396, _1: $t46397 };
                    out = { _0: $t46395, _1: $t46398 };
                  }
                }
              }
            }
            return out;
          }
        }
      } else {
        {
          const $t46399 = { $: "Nil" };
          return { _0: m, _1: $t46399 };
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
      const $t46400 = (steps <= 0);
      if ($t46400 === true) {
        return { _0: m, _1: hits };
      } else {
        {
          let l;
          {
            let $t46402;
            {
              const $t46401 = m.table;
              $t46402 = $t46401.left;
            }
            {
              const $t46403 = m.left;
              {
                const $t46404 = input.left;
                l = Spin$Physics$turn_flipper($t46402, $t46403, $t46404, 0.0025);
              }
            }
          }
          {
            let r;
            {
              let $t46406;
              {
                const $t46405 = m.table;
                $t46406 = $t46405.right;
              }
              {
                const $t46407 = m.right;
                {
                  let $t46411;
                  {
                    const $t46408 = input.right;
                    {
                      let $t46410;
                      {
                        let $t46409;
                        $t46409 = Spin$Game$waiting(m);
                        $t46410 = (!$t46409);
                      }
                      $t46411 = ($t46408 && $t46410);
                    }
                  }
                  r = Spin$Physics$turn_flipper($t46406, $t46407, $t46411, 0.0025);
                }
              }
            }
            {
              const $t46412 = m.balls;
              {
                let $t46415;
                $t46415 = { $: "$Clo_$lam0_Spin_Game_step_balls$0_Spin_Game_step_balls", _0: $lam0_Spin_Game_step_balls$apply$0_Spin_Game_step_balls, _1: 0.0025, _2: l, _3: m, _4: r };
                {
                  let moved;
                  {
                    const xs_i12800 = $t46412;
                    {
                      const f_i12801 = $t46415;
                      switch (xs_i12800.$) {
                        case "Nil": {
                          moved = { $: "Nil" };
                          break;
                        }
                        case "Cons": {
                          const $f995_i12802 = xs_i12800._0;
                          const $f996_i12803 = xs_i12800._1;
                          {
                            const t_i12804 = $f996_i12803;
                            {
                              const h_i12805 = $f995_i12802;
                              {
                                let $t993_i12806;
                                $t993_i12806 = f_i12801._0(f_i12801, h_i12805);
                                {
                                  const $trmc15_i12807 = { $: "Cons", _0: $t993_i12806, _1: null };
                                  List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit(t_i12804, f_i12801, $trmc15_i12807);
                                  moved = $trmc15_i12807;
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
                    const $t46418 = { $: "$Clo_$lam1_Spin_Game_step_balls$1_Spin_Game_step_balls", _0: $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls };
                    {
                      let balls;
                      {
                        const xs_i12792 = moved;
                        {
                          const f_i12793 = $t46418;
                          switch (xs_i12792.$) {
                            case "Nil": {
                              balls = { $: "Nil" };
                              break;
                            }
                            case "Cons": {
                              const $f995_i12794 = xs_i12792._0;
                              const $f996_i12795 = xs_i12792._1;
                              {
                                const t_i12796 = $f996_i12795;
                                {
                                  const h_i12797 = $f995_i12794;
                                  {
                                    let $t993_i12798;
                                    $t993_i12798 = f_i12793._0(f_i12793, h_i12797);
                                    {
                                      const $trmc15_i12799 = { $: "Cons", _0: $t993_i12798, _1: null };
                                      List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float(t_i12796, f_i12793, $trmc15_i12799);
                                      balls = $trmc15_i12799;
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
                        const $t46421 = { $: "$Clo_$lam2_Spin_Game_step_balls$2_Spin_Game_step_balls", _0: $lam2_Spin_Game_step_balls$apply$2_Spin_Game_step_balls };
                        {
                          let $t46422;
                          {
                            const xs_i12784 = moved;
                            {
                              const f_i12785 = $t46421;
                              switch (xs_i12784.$) {
                                case "Nil": {
                                  $t46422 = { $: "Nil" };
                                  break;
                                }
                                case "Cons": {
                                  const $f995_i12786 = xs_i12784._0;
                                  const $f996_i12787 = xs_i12784._1;
                                  {
                                    const t_i12788 = $f996_i12787;
                                    {
                                      const h_i12789 = $f995_i12786;
                                      {
                                        let $t993_i12790;
                                        $t993_i12790 = f_i12785._0(f_i12785, h_i12789);
                                        {
                                          const $trmc15_i12791 = { $: "Cons", _0: $t993_i12790, _1: null };
                                          List$map$dps$List_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_List_Hit$List_List_Hit(t_i12788, f_i12785, $trmc15_i12791);
                                          $t46422 = $trmc15_i12791;
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
                                  new_hits = go$apply$1_List_concat_List_List_Hit(go_i5338, $t46422, $t1113_i5339);
                                }
                              }
                            }
                            {
                              const next = ({ ...m, balls: balls, left: l, right: r });
                              {
                                const $t46423 = ((steps - 1) < 4611686018427387904 && (steps - 1) >= -4611686018427387904 ? (steps - 1) : march_int_ovf((steps - 1), 1));
                                {
                                  let $t46424;
                                  {
                                    const xs_i12777 = hits;
                                    {
                                      const ys_i12778 = new_hits;
                                      switch (xs_i12777.$) {
                                        case "Nil": {
                                          $t46424 = new_hits;
                                          break;
                                        }
                                        case "Cons": {
                                          const $f987_i12779 = xs_i12777._0;
                                          const $f988_i12780 = xs_i12777._1;
                                          {
                                            const t_i12781 = $f988_i12780;
                                            {
                                              const h_i12782 = $f987_i12779;
                                              {
                                                const $trmc11_i12783 = { $: "Cons", _0: h_i12782, _1: null };
                                                List$append$dps$List_Hit$List_Hit$List_Hit(t_i12781, new_hits, $trmc11_i12783);
                                                $t46424 = $trmc11_i12783;
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
                                    $tco_a2 = $t46423;
                                    $tco_a3 = $t46424;
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
      const $t46425 = m.carry;
      total = ($t46425 + dt);
    }
    {
      let steps;
      {
        let $t46427;
        {
          const $t46426 = (total / 0.0025);
          $t46427 = Math.floor($t46426);
        }
        {
          const $t2462_i5345 = ($t46427 < 40);
          if ($t2462_i5345 === true) {
            steps = $t46427;
          } else {
            steps = 40;
          }
        }
      }
      {
        let $p46434;
        {
          const $t46428 = { $: "Nil" };
          $p46434 = Spin$Game$step_balls(m, input, steps, $t46428);
        }
        {
          const moved = $p46434._0;
          {
            const hits = $p46434._1;
            {
              let $t46433;
              {
                let $t46432;
                {
                  let $t46431;
                  {
                    let $t46430;
                    {
                      const $t46429 = steps;
                      $t46430 = ($t46429 * 0.0025);
                    }
                    $t46431 = (total - $t46430);
                  }
                  {
                    const $t45787_i5342 = ($t46431 >= 0.);
                    if ($t45787_i5342 === true) {
                      $t46432 = $t46431;
                    } else {
                      $t46432 = 0.;
                    }
                  }
                }
                $t46433 = ({ ...moved, carry: $t46432 });
              }
              {
                const $rc_2561 = { _0: $t46433, _1: hits };
                return $rc_2561;
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
    const $t46435 = m.balls;
    {
      let $t46441;
      $t46441 = { $: "$Clo_$lam0_Spin_Game_drains$0_Spin_Game_drains", _0: $lam0_Spin_Game_drains$apply$0_Spin_Game_drains, _1: m };
      {
        const kept = List$filter$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46435, $t46441);
        {
          let lost;
          {
            let $t46443;
            {
              const $t46442 = m.balls;
              {  };
              $t46443 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t46442, 0);
            }
            {
              let $t46444;
              {  };
              $t46444 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int(kept, 0);
              lost = (($t46443 - $t46444) < 4611686018427387904 && ($t46443 - $t46444) >= -4611686018427387904 ? ($t46443 - $t46444) : march_int_ovf(($t46443 - $t46444), 1));
            }
          }
          {
            const $t46445 = (lost === 0);
            if ($t46445 === true) {
              {
                const $t46446 = { $: "Nil" };
                return { _0: m, _1: $t46446 };
              }
            } else {
              {
                let $t46451;
                {
                  let $t46448;
                  {
                    let $t46447;
                    {  };
                    $t46447 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int(kept, 0);
                    $t46448 = ($t46447 > 0);
                  }
                  {
                    let $t46450;
                    {
                      const $t46449 = m.owed_balls;
                      $t46450 = ($t46449 > 0);
                    }
                    $t46451 = ($t46448 || $t46450);
                  }
                }
                if ($t46451 === true) {
                  {
                    const $t46452 = ({ ...m, balls: kept });
                    {
                      const $t46453 = { $: "CueDrain" };
                      {
                        const $t46454 = { $: "Nil" };
                        {
                          const $t46455 = { $: "Cons", _0: $t46453, _1: $t46454 };
                          return { _0: $t46452, _1: $t46455 };
                        }
                      }
                    }
                  }
                } else {
                  {
                    let fresh;
                    {
                      let $t46457;
                      {
                        const $t46456 = m.table;
                        $t46457 = Spin$Game$ball_at_plunger($t46456);
                      }
                      {
                        const $t46458 = { $: "Nil" };
                        {
                          const $t46459 = { $: "Cons", _0: $t46457, _1: $t46458 };
                          fresh = ({ ...m, balls: $t46459 });
                        }
                      }
                    }
                    {
                      let $t46461;
                      {
                        const $t46460 = m.save_left;
                        $t46461 = ($t46460 > 0.);
                      }
                      if ($t46461 === true) {
                        {
                          let $t46463;
                          {
                            const $t46462 = ({ ...fresh, save_left: 0. });
                            $t46463 = Spin$Game$say($t46462, "BALL SAVED", "on the house", 1.8, false);
                          }
                          {
                            const $t46464 = { $: "CueSaved" };
                            {
                              const $t46465 = { $: "Nil" };
                              {
                                const $t46466 = { $: "Cons", _0: $t46464, _1: $t46465 };
                                {
                                  const $rc_2566 = { _0: $t46463, _1: $t46466 };
                                  return $rc_2566;
                                }
                              }
                            }
                          }
                        }
                      } else {
                        {
                          let charged;
                          {
                            let $t46469;
                            {
                              const $t46467 = m.credits;
                              $t46469 = (($t46467 - 6) < 4611686018427387904 && ($t46467 - 6) >= -4611686018427387904 ? ($t46467 - 6) : march_int_ovf(($t46467 - 6), 1));
                            }
                            charged = ({ ...fresh, credits: $t46469, save_left: 8. });
                          }
                          {
                            let out;
                            {
                              let $t46474;
                              {
                                let $t46473;
                                {
                                  const $t46472 = String(6);
                                  {
                                    const $rc_2562 = march_string_concat3("-", $t46472, " CREDITS");
                                    $t46473 = $rc_2562;
                                  }
                                }
                                $t46474 = Spin$Game$say(charged, "DRAIN", $t46473, 1.8, false);
                              }
                              {
                                const $t46475 = { $: "CueDrain" };
                                {
                                  const $t46476 = { $: "Nil" };
                                  {
                                    const $t46477 = { $: "Cons", _0: $t46475, _1: $t46476 };
                                    out = { _0: $t46474, _1: $t46477 };
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
    let $t46478;
    {
      const m_i12808 = m;
      {
        const $t46191_i12809 = m.balls;
        {
          const $t46194_i12810 = { $: "$Clo_$lam0_Spin_Game_in_play$0_Spin_Game_in_play", _0: $lam0_Spin_Game_in_play$apply$0_Spin_Game_in_play };
          $t46478 = List$any$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_Bool($t46191_i12809, $t46194_i12810);
        }
      }
    }
    if ($t46478 === true) {
      {
        let every;
        {
          const $t46479 = m.alive;
          {
            let $t46154_i5357;
            {
              let $t46153_i5356;
              {
                let $t46152_i5355;
                {
                  const $t46151_i5354 = ($t46479 * 0.00385);
                  $t46152_i5355 = (0. - $t46151_i5354);
                }
                $t46153_i5356 = Math.exp($t46152_i5355);
              }
              $t46154_i5357 = (2.4 * $t46153_i5356);
            }
            {
              const $t45787_i14166 = ($t46154_i5357 >= 0.05);
              if ($t45787_i14166 === true) {
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
            const $t46480 = m.burn_clock;
            clock = ($t46480 + dt);
          }
          {
            let saving;
            {
              let $t46483;
              {
                let $t46482;
                {
                  const $t46481 = m.balls;
                  {  };
                  $t46482 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t46481, 0);
                }
                $t46483 = ($t46482 === 1);
              }
              if ($t46483 === true) {
                {
                  const $t46484 = m.save_left;
                  saving = ($t46484 - dt);
                }
              } else {
                saving = m.save_left;
              }
            }
            {
              let ticking;
              {
                let $t46486;
                {
                  const $t46485 = m.alive;
                  $t46486 = ($t46485 + dt);
                }
                {
                  let $t46487;
                  {
                    const $t45787_i5351 = (saving >= 0.);
                    if ($t45787_i5351 === true) {
                      $t46487 = saving;
                    } else {
                      $t46487 = 0.;
                    }
                  }
                  ticking = ({ ...m, alive: $t46486, save_left: $t46487 });
                }
              }
              {
                const $t46488 = (clock >= every);
                if ($t46488 === true) {
                  {
                    let c;
                    {
                      const $t46489 = m.credits;
                      c = (($t46489 - 1) < 4611686018427387904 && ($t46489 - 1) >= -4611686018427387904 ? ($t46489 - 1) : march_int_ovf(($t46489 - 1), 1));
                    }
                    {
                      let $t46491;
                      {
                        const $t46490 = (clock - every);
                        $t46491 = ({ ...ticking, burn_clock: $t46490, credits: c });
                      }
                      {
                        const $t46492 = { $: "CueBurn", _0: c };
                        {
                          const $t46493 = { $: "Nil" };
                          {
                            const $t46494 = { $: "Cons", _0: $t46492, _1: $t46493 };
                            {
                              const $rc_2570 = { _0: $t46491, _1: $t46494 };
                              return $rc_2570;
                            }
                          }
                        }
                      }
                    }
                  }
                } else {
                  {
                    const $t46495 = ({ ...ticking, burn_clock: clock });
                    {
                      const $t46496 = { $: "Nil" };
                      {
                        const $rc_2569 = { _0: $t46495, _1: $t46496 };
                        return $rc_2569;
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
        const $t46497 = { $: "Nil" };
        return { _0: m, _1: $t46497 };
      }
    }
  }
}
const Spin$Game$burn$clo = { _0: ($_, m, dt) => Spin$Game$burn(m, dt) };

function Spin$Game$bust(m) {
  {
    let $t46499;
    {
      const $t46498 = m.credits;
      $t46499 = ($t46498 <= 0);
    }
    if ($t46499 === true) {
      {
        let best;
        {
          const $t46500 = m.best;
          {
            const $t46501 = m.paid;
            {
              const $t2463_i5360 = ($t46500 > $t46501);
              if ($t2463_i5360 === true) {
                best = $t46500;
              } else {
                best = $t46501;
              }
            }
          }
        }
        {
          let over;
          {
            const $t46502 = { $: "Busted" };
            {
              const $t46503 = { $: "Nil" };
              over = ({ ...m, mode: $t46502, credits: 0, best: best, balls: $t46503, owed_balls: 0 });
            }
          }
          {
            let out;
            {
              let $t46507;
              {
                let $t46506;
                {
                  let $t46505;
                  {
                    const $t46504 = m.paid;
                    $t46505 = String($t46504);
                  }
                  {
                    const $rc_2571 = ("the reels paid " + $t46505);
                    $t46506 = $rc_2571;
                  }
                }
                $t46507 = Spin$Game$say(over, "BUSTED", $t46506, 1000000., true);
              }
              {
                const $t46508 = { $: "CueBust" };
                {
                  const $t46509 = { $: "CueStore", _0: best };
                  {
                    const $t46510 = { $: "Nil" };
                    {
                      const $t46511 = { $: "Cons", _0: $t46509, _1: $t46510 };
                      {
                        const $t46512 = { $: "Cons", _0: $t46508, _1: $t46511 };
                        out = { _0: $t46507, _1: $t46512 };
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
        const $t46513 = { $: "Nil" };
        return { _0: m, _1: $t46513 };
      }
    }
  }
}
const Spin$Game$bust$clo = { _0: ($_, m) => Spin$Game$bust(m) };

function Spin$Game$then_do(acc, f) {
  {
    const $p46516 = acc;
    {
      const m = acc._0;
      {
        const cues = acc._1;
        {
          let $p46515;
          $p46515 = f._0(f, m);
          {
            const n = $p46515._0;
            {
              const more = $p46515._1;
              {
                let $t46514;
                {
                  const xs_i12811 = cues;
                  {
                    const ys_i12812 = more;
                    switch (xs_i12811.$) {
                      case "Nil": {
                        $t46514 = more;
                        break;
                      }
                      case "Cons": {
                        const $f987_i12813 = xs_i12811._0;
                        const $f988_i12814 = xs_i12811._1;
                        {
                          const t_i12815 = $f988_i12814;
                          {
                            const h_i12816 = $f987_i12813;
                            {
                              const $trmc11_i12817 = { $: "Cons", _0: h_i12816, _1: null };
                              List$append$dps$List_Cue$List_Cue$List_Cue(t_i12815, more, $trmc11_i12817);
                              $t46514 = $trmc11_i12817;
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
                  const $rc_2573 = { _0: n, _1: $t46514 };
                  return $rc_2573;
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
    let $t46530;
    {
      let $t46521;
      {
        const $t46517 = input.left;
        {
          let $t46520;
          {
            let $t46519;
            {
              const $t46518 = m.last;
              $t46519 = $t46518.left;
            }
            $t46520 = (!$t46519);
          }
          $t46521 = ($t46517 && $t46520);
        }
      }
      {
        let $t46529;
        {
          let $t46526;
          {
            const $t46522 = input.right;
            {
              let $t46525;
              {
                let $t46524;
                {
                  const $t46523 = m.last;
                  $t46524 = $t46523.right;
                }
                $t46525 = (!$t46524);
              }
              $t46526 = ($t46522 && $t46525);
            }
          }
          {
            let $t46528;
            {
              let $t46527;
              $t46527 = Spin$Game$waiting(m);
              $t46528 = (!$t46527);
            }
            $t46529 = ($t46526 && $t46528);
          }
        }
        $t46530 = ($t46521 || $t46529);
      }
    }
    {
      let flips;
      if ($t46530 === true) {
        {
          const $t46531 = { $: "CueFlip" };
          {
            const $t46532 = { $: "Nil" };
            flips = { $: "Cons", _0: $t46531, _1: $t46532 };
          }
        }
      } else {
        flips = { $: "Nil" };
      }
      {
        let $p46549;
        $p46549 = Spin$Game$plunge(m, input, dt);
        {
          const pulled = $p46549._0;
          {
            const c1 = $p46549._1;
            {
              let $p46548;
              $p46548 = Spin$Game$auto_plunge(pulled);
              {
                const shot = $p46548._0;
                {
                  const c2 = $p46548._1;
                  {
                    let $p46547;
                    $p46547 = Spin$Game$physics(shot, input, dt);
                    {
                      const moved = $p46547._0;
                      {
                        const hits = $p46547._1;
                        {
                          let touched;
                          {
                            const $t46533 = { $: "Nil" };
                            {
                              let $t46534;
                              $t46534 = { $: "Cons", _0: c2, _1: $t46533 };
                              {
                                let $t46535;
                                $t46535 = { $: "Cons", _0: c1, _1: $t46534 };
                                {
                                  const $t46536 = { $: "Cons", _0: flips, _1: $t46535 };
                                  {
                                    let $t46537;
                                    {
                                      const prepend_reversed_i5362 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Cue", _0: prepend_reversed$apply$0_List_concat_List_List_Cue };
                                      {
                                        const go_i5363 = { $: "$Clo_go$1_List_concat_List_List_Cue", _0: go$apply$1_List_concat_List_List_Cue, _1: prepend_reversed_i5362 };
                                        {
                                          const $t1113_i5364 = { $: "Nil" };
                                          $t46537 = go$apply$1_List_concat_List_List_Cue(go_i5363, $t46536, $t1113_i5364);
                                        }
                                      }
                                    }
                                    {
                                      let $t46538;
                                      $t46538 = { _0: moved, _1: $t46537 };
                                      touched = List$fold_left$List_Hit$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_Hit_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue(hits, $t46538, Spin$Game$touch$clo);
                                    }
                                  }
                                }
                              }
                            }
                          }
                          {
                            const $p46546 = touched;
                            {
                              const m1 = touched._0;
                              {
                                const c3 = touched._1;
                                {
                                  let $p46545;
                                  {
                                    const $t46539 = m1.bank;
                                    {
                                      const $t46540 = m1.rng;
                                      $p46545 = Spin$Reels$tick($t46539, $t46540, dt);
                                    }
                                  }
                                  {
                                    const bank = $p46545._0;
                                    {
                                      const rng = $p46545._1;
                                      {
                                        const evs = $p46545._2;
                                        {
                                          let reeled;
                                          {
                                            let $t46541;
                                            $t46541 = ({ ...m1, rng: rng, bank: bank });
                                            {
                                              let $t46542;
                                              $t46542 = { _0: $t46541, _1: c3 };
                                              reeled = List$fold_left$List_ReelEvent$T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue$Fn_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue_ReelEvent_T_R_alive_Float_balls_List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_bank_R_armed_Int_banked_Int_boost_Int_last_line_String_last_pay_Int_nudge_left_Float_phase_Phase_reels_List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_banner_R_hot_Bool_left_Float_sub_String_text_String_best_Int_burn_clock_Float_carry_Float_clock_Float_credits_Int_last_R_launch_Bool_left_Bool_right_Bool_start_Bool_left_R_angle_Float_omega_Float_lights_List_T_Feature_Float_mode_Mode_num_R_floor_u1_Float_infinity_Float_nan_Float_pi_Float_tau_Float_unit53_Float_owed_balls_Int_paid_Int_pull_Float_right_R_angle_Float_omega_Float_rng_R_word_R_hi_Int_lo_Int_save_left_Float_spinner_rate_Float_spinner_turn_Float_table_R_ball_radius_Float_drain_y_Float_gravity_Float_height_Float_left_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_parts_List_Part_plunger_rest_R_x_Float_y_Float_reel_window_T_Float_Float_Float_Float_right_R_length_Float_pivot_R_x_Float_y_Float_radius_Float_rest_Float_up_Float_width_Float_List_Cue(evs, $t46542, Spin$Game$reel_news$clo);
                                            }
                                          }
                                          {
                                            const drained = Spin$Game$then_do(reeled, Spin$Game$drains$clo);
                                            {
                                              let burned;
                                              {
                                                const $t46544 = { $: "$Clo_$lam0_Spin_Game_play$0_Spin_Game_play", _0: $lam0_Spin_Game_play$apply$0_Spin_Game_play, _1: dt };
                                                burned = Spin$Game$then_do(drained, $t46544);
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
        const $t45787_i14173 = (0. >= dt0);
        if ($t45787_i14173 === true) {
          $t45789_i5368 = 0.;
        } else {
          $t45789_i5368 = dt0;
        }
      }
      {
        const $t45788_i14170 = (0.05 < $t45789_i5368);
        if ($t45788_i14170 === true) {
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
          let $t46551;
          {
            const $t46550 = m.clock;
            $t46551 = ($t46550 + dt);
          }
          faded = ({ ...dimmed, clock: $t46551 });
        }
        {
          let pressed_start;
          {
            let $t46556;
            {
              const $t46552 = input.start;
              {
                let $t46555;
                {
                  let $t46554;
                  {
                    const $t46553 = m.last;
                    $t46554 = $t46553.start;
                  }
                  $t46555 = (!$t46554);
                }
                $t46556 = ($t46552 && $t46555);
              }
            }
            {
              let $t46561;
              {
                const $t46557 = input.launch;
                {
                  let $t46560;
                  {
                    let $t46559;
                    {
                      const $t46558 = m.last;
                      $t46559 = $t46558.launch;
                    }
                    $t46560 = (!$t46559);
                  }
                  $t46561 = ($t46557 && $t46560);
                }
              }
              pressed_start = ($t46556 || $t46561);
            }
          }
          {
            let $p46578;
            {
              const $t46562 = faded.mode;
              switch ($t46562.$) {
                case "Playing": {
                  $p46578 = Spin$Game$play(faded, input, dt);
                  break;
                }
                case "Attract": {
                  if (pressed_start === true) {
                    {
                      const $t46563 = Spin$Game$new_game(faded);
                      {
                        const $t46564 = { $: "CueStart" };
                        {
                          const $t46565 = { $: "Nil" };
                          {
                            const $t46566 = { $: "Cons", _0: $t46564, _1: $t46565 };
                            $p46578 = { _0: $t46563, _1: $t46566 };
                          }
                        }
                      }
                    }
                  } else {
                    {
                      const $t46567 = { $: "Nil" };
                      $p46578 = { _0: faded, _1: $t46567 };
                    }
                  }
                  break;
                }
                case "Busted": {
                  {
                    let $t46571;
                    {
                      let $t46570;
                      {
                        let $t46569;
                        {
                          const $t46568 = faded.banner;
                          $t46569 = $t46568.left;
                        }
                        $t46570 = ($t46569 < 999998.);
                      }
                      $t46571 = (pressed_start && $t46570);
                    }
                    if ($t46571 === true) {
                      {
                        const $t46572 = Spin$Game$new_game(faded);
                        {
                          const $t46573 = { $: "CueStart" };
                          {
                            const $t46574 = { $: "Nil" };
                            {
                              const $t46575 = { $: "Cons", _0: $t46573, _1: $t46574 };
                              $p46578 = { _0: $t46572, _1: $t46575 };
                            }
                          }
                        }
                      }
                    } else {
                      {
                        const $t46576 = { $: "Nil" };
                        $p46578 = { _0: faded, _1: $t46576 };
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
              const next = $p46578._0;
              {
                const cues = $p46578._1;
                {
                  let $t46577;
                  $t46577 = ({ ...next, last: input });
                  {
                    const $rc_2577 = { _0: $t46577, _1: cues };
                    return $rc_2577;
                  }
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
    const $t46579 = spec.rest;
    return ({ angle: $t46579, omega: 0. });
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
          const $t46580 = f.angle;
          gap = (target - $t46580);
        }
        {
          const most = (rate * h);
          {
            let moved;
            {
              const $t46581 = (-most);
              {
                let $t45789_i5372;
                {
                  const $t45787_i14179 = ($t46581 >= gap);
                  if ($t45787_i14179 === true) {
                    $t45789_i5372 = $t46581;
                  } else {
                    $t45789_i5372 = gap;
                  }
                }
                {
                  const $t45788_i14176 = (most < $t45789_i5372);
                  if ($t45788_i14176 === true) {
                    moved = most;
                  } else {
                    moved = $t45789_i5372;
                  }
                }
              }
            }
            {
              let $t46583;
              {
                const $t46582 = f.angle;
                $t46583 = ($t46582 + moved);
              }
              {
                const $t46584 = (moved / h);
                return ({ angle: $t46583, omega: $t46584 });
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
        const $t46585 = (l2 > 0.);
        if ($t46585 === true) {
          {
            let $t46590;
            {
              let $t46589;
              {
                let $t46588;
                {
                  let $t46587;
                  {
                    let $t46586;
                    $t46586 = Arcade$Vec2$sub(p, a);
                    $t46587 = Arcade$Vec2$dot($t46586, ab);
                  }
                  $t46588 = ($t46587 / l2);
                }
                {
                  let $t45789_i5376;
                  {
                    const $t45787_i14185 = (0. >= $t46588);
                    if ($t45787_i14185 === true) {
                      $t45789_i5376 = 0.;
                    } else {
                      $t45789_i5376 = $t46588;
                    }
                  }
                  {
                    const $t45788_i14182 = (1. < $t45789_i5376);
                    if ($t45788_i14182 === true) {
                      $t46589 = 1.;
                    } else {
                      $t46589 = $t45789_i5376;
                    }
                  }
                }
              }
              $t46590 = Arcade$Vec2$scale(ab, $t46589);
            }
            return Arcade$Vec2$add(a, $t46590);
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
      const $t46591 = b.pos;
      d = Arcade$Vec2$sub($t46591, q);
    }
    {
      let dist;
      dist = Arcade$Vec2$length(d);
      {
        let $t46594;
        {
          const $t46592 = (dist >= reach);
          {
            const $t46593 = (dist === 0.);
            $t46594 = ($t46592 || $t46593);
          }
        }
        if ($t46594 === true) {
          return { $: "None" };
        } else {
          {
            let n;
            {
              const $t46595 = (1. / dist);
              n = Arcade$Vec2$scale(d, $t46595);
            }
            {
              let pos;
              {
                let $t46596;
                $t46596 = Arcade$Vec2$scale(n, reach);
                pos = Arcade$Vec2$add(q, $t46596);
              }
              {
                let rel;
                {
                  const $t46597 = b.vel;
                  rel = Arcade$Vec2$sub($t46597, u);
                }
                {
                  let vn;
                  vn = Arcade$Vec2$dot(rel, n);
                  {
                    const $t46598 = (vn < 0.);
                    if ($t46598 === true) {
                      {
                        let $t46604;
                        {
                          let $t46603;
                          {
                            let $t46602;
                            {
                              let $t46601;
                              {
                                let $t46600;
                                {
                                  const $t46599 = (1. + e);
                                  $t46600 = ($t46599 * vn);
                                }
                                $t46601 = Arcade$Vec2$scale(n, $t46600);
                              }
                              $t46602 = Arcade$Vec2$sub(rel, $t46601);
                            }
                            $t46603 = Arcade$Vec2$add($t46602, u);
                          }
                          $t46604 = ({ pos: pos, vel: $t46603 });
                        }
                        {
                          const $t46605 = (-vn);
                          {
                            const $t46606 = { _0: $t46604, _1: n, _2: $t46605 };
                            return { $: "Some", _0: $t46606 };
                          }
                        }
                      }
                    } else {
                      {
                        let $t46608;
                        {
                          const $t46607 = b.vel;
                          $t46608 = ({ pos: pos, vel: $t46607 });
                        }
                        {
                          const $t46609 = { _0: $t46608, _1: n, _2: 0. };
                          return { $: "Some", _0: $t46609 };
                        }
                      }
                    }
                  }
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
    let $t46622;
    {
      let $t46618;
      {
        const $t46616 = s.x;
        {
          const $t46617 = o.x;
          $t46618 = ($t46616 - $t46617);
        }
      }
      {
        let $t46621;
        {
          const $t46619 = t.y;
          {
            const $t46620 = o.y;
            $t46621 = ($t46619 - $t46620);
          }
        }
        $t46622 = ($t46618 * $t46621);
      }
    }
    {
      let $t46629;
      {
        let $t46625;
        {
          const $t46623 = s.y;
          {
            const $t46624 = o.y;
            $t46625 = ($t46623 - $t46624);
          }
        }
        {
          let $t46628;
          {
            const $t46626 = t.x;
            {
              const $t46627 = o.x;
              $t46628 = ($t46626 - $t46627);
            }
          }
          $t46629 = ($t46625 * $t46628);
        }
      }
      return ($t46622 - $t46629);
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
            let $t46636;
            {
              let $t46632;
              {
                const $t46630 = (d1 > 0.);
                {
                  const $t46631 = (d2 <= 0.);
                  $t46632 = ($t46630 && $t46631);
                }
              }
              {
                let $t46635;
                {
                  const $t46633 = (d1 <= 0.);
                  {
                    const $t46634 = (d2 > 0.);
                    $t46635 = ($t46633 && $t46634);
                  }
                }
                $t46636 = ($t46632 || $t46635);
              }
            }
            {
              let $t46643;
              {
                let $t46639;
                {
                  const $t46637 = (d3 > 0.);
                  {
                    const $t46638 = (d4 <= 0.);
                    $t46639 = ($t46637 && $t46638);
                  }
                }
                {
                  let $t46642;
                  {
                    const $t46640 = (d3 <= 0.);
                    {
                      const $t46641 = (d4 > 0.);
                      $t46642 = ($t46640 && $t46641);
                    }
                  }
                  $t46643 = ($t46639 || $t46642);
                }
              }
              return ($t46636 && $t46643);
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
    let $p46838;
    $p46838 = acc;
    {
      const b = $p46838._0;
      {
        const hits = $p46838._1;
        switch (part.$) {
          case "Wall": {
            const $f46761 = part._0;
            const $f46762 = part._1;
            const $f46763 = part._2;
            {
              const e = $f46763;
              {
                const c = $f46762;
                {
                  const a = $f46761;
                  {
                    let $t46647;
                    {
                      let $t46645;
                      {
                        const $t46644 = b.pos;
                        $t46645 = Spin$Physics$closest(a, c, $t46644);
                      }
                      {
                        const $t46646 = ({ x: 0., y: 0. });
                        $t46647 = Spin$Physics$contact(b, $t46645, r, e, $t46646);
                      }
                    }
                    switch ($t46647.$) {
                      case "Some": {
                        const $f46651 = $t46647._0;
                        const $f46652 = $f46651._0;
                        const $f46653 = $f46651._1;
                        const $f46654 = $f46651._2;
                        {
                          const speed = $f46654;
                          {
                            const nb = $f46652;
                            {
                              let $t46649;
                              {
                                const $t46648 = { $: "Plain" };
                                $t46649 = { $: "Touched", _0: $t46648, _1: speed };
                              }
                              {
                                let $t46650;
                                $t46650 = { $: "Cons", _0: $t46649, _1: hits };
                                {
                                  const $rc_2598 = { _0: nb, _1: $t46650 };
                                  return $rc_2598;
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
            const $f46772 = part._0;
            const $f46773 = part._1;
            const $f46774 = part._2;
            {
              const e = $f46774;
              {
                const pr = $f46773;
                {
                  const c = $f46772;
                  {
                    let $t46665;
                    {
                      const $t46663 = (r + pr);
                      {
                        const $t46664 = ({ x: 0., y: 0. });
                        $t46665 = Spin$Physics$contact(b, c, $t46663, e, $t46664);
                      }
                    }
                    switch ($t46665.$) {
                      case "Some": {
                        const $f46669 = $t46665._0;
                        const $f46670 = $f46669._0;
                        const $f46671 = $f46669._1;
                        const $f46672 = $f46669._2;
                        {
                          const speed = $f46672;
                          {
                            const nb = $f46670;
                            {
                              let $t46667;
                              {
                                const $t46666 = { $: "Plain" };
                                $t46667 = { $: "Touched", _0: $t46666, _1: speed };
                              }
                              {
                                let $t46668;
                                $t46668 = { $: "Cons", _0: $t46667, _1: hits };
                                {
                                  const $rc_2600 = { _0: nb, _1: $t46668 };
                                  return $rc_2600;
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
            const $f46783 = part._0;
            const $f46784 = part._1;
            const $f46785 = part._2;
            {
              const f = $f46785;
              {
                const kr = $f46784;
                {
                  const c = $f46783;
                  {
                    let $t46683;
                    {
                      const $t46681 = (r + kr);
                      {
                        const $t46682 = ({ x: 0., y: 0. });
                        $t46683 = Spin$Physics$contact(b, c, $t46681, 0.6, $t46682);
                      }
                    }
                    switch ($t46683.$) {
                      case "Some": {
                        const $f46688 = $t46683._0;
                        const $f46689 = $f46688._0;
                        const $f46690 = $f46688._1;
                        const $f46691 = $f46688._2;
                        {
                          const speed = $f46691;
                          {
                            const n = $f46690;
                            {
                              const nb = $f46689;
                              {
                                let $t46685;
                                {
                                  const b_i12818 = nb;
                                  {
                                    const n_i12819 = n;
                                    {
                                      let vn_i12822;
                                      {
                                        const $t46610_i12821 = nb.vel;
                                        vn_i12822 = Arcade$Vec2$dot($t46610_i12821, n);
                                      }
                                      {
                                        const $t46611_i12823 = (vn_i12822 < 620.);
                                        if ($t46611_i12823 === true) {
                                          {
                                            let $t46615_i12827;
                                            {
                                              const $t46612_i12824 = nb.vel;
                                              {
                                                let $t46614_i12826;
                                                {
                                                  const $t46613_i12825 = (620. - vn_i12822);
                                                  $t46614_i12826 = Arcade$Vec2$scale(n, $t46613_i12825);
                                                }
                                                $t46615_i12827 = Arcade$Vec2$add($t46612_i12824, $t46614_i12826);
                                              }
                                            }
                                            {
                                              const $rc_2580_i12828 = ({ ...nb, vel: $t46615_i12827 });
                                              $t46685 = $rc_2580_i12828;
                                            }
                                          }
                                        } else {
                                          $t46685 = nb;
                                        }
                                      }
                                    }
                                  }
                                }
                                {
                                  const $t46686 = { $: "Touched", _0: f, _1: speed };
                                  {
                                    let $t46687;
                                    $t46687 = { $: "Cons", _0: $t46686, _1: hits };
                                    {
                                      const $rc_2602 = { _0: $t46685, _1: $t46687 };
                                      return $rc_2602;
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
            const $f46794 = part._0;
            const $f46795 = part._1;
            const $f46796 = part._2;
            const $f46797 = part._3;
            {
              const f = $f46797;
              {
                const kick = $f46796;
                {
                  const c = $f46795;
                  {
                    const a = $f46794;
                    {
                      let e;
                      {
                        const $t46700 = (kick > 0.);
                        if ($t46700 === true) {
                          e = 0.4;
                        } else {
                          e = 0.55;
                        }
                      }
                      {
                        let $t46704;
                        {
                          let $t46702;
                          {
                            const $t46701 = b.pos;
                            $t46702 = Spin$Physics$closest(a, c, $t46701);
                          }
                          {
                            const $t46703 = ({ x: 0., y: 0. });
                            $t46704 = Spin$Physics$contact(b, $t46702, r, e, $t46703);
                          }
                        }
                        switch ($t46704.$) {
                          case "Some": {
                            const $f46713 = $t46704._0;
                            const $f46714 = $f46713._0;
                            const $f46715 = $f46713._1;
                            const $f46716 = $f46713._2;
                            {
                              const speed = $f46716;
                              {
                                const n = $f46715;
                                {
                                  const nb = $f46714;
                                  {
                                    let thrown;
                                    {
                                      let $t46707;
                                      {
                                        const $t46705 = (kick > 0.);
                                        {
                                          const $t46706 = (speed > 80.);
                                          $t46707 = ($t46705 && $t46706);
                                        }
                                      }
                                      if ($t46707 === true) {
                                        {
                                          let $t46710;
                                          {
                                            const $t46708 = nb.vel;
                                            {
                                              const $t46709 = Arcade$Vec2$scale(n, kick);
                                              $t46710 = Arcade$Vec2$add($t46708, $t46709);
                                            }
                                          }
                                          {
                                            const $rc_2582 = ({ ...nb, vel: $t46710 });
                                            thrown = $rc_2582;
                                          }
                                        }
                                      } else {
                                        thrown = nb;
                                      }
                                    }
                                    {
                                      const $t46711 = { $: "Touched", _0: f, _1: speed };
                                      {
                                        let $t46712;
                                        $t46712 = { $: "Cons", _0: $t46711, _1: hits };
                                        {
                                          const $rc_2604 = { _0: thrown, _1: $t46712 };
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
              }
            }
            break;
          }
          case "Gate": {
            const $f46810 = part._0;
            const $f46811 = part._1;
            {
              const c = $f46811;
              {
                const a = $f46810;
                {
                  let $t46727;
                  {
                    let $t46726;
                    {
                      const $t46725 = b.vel;
                      $t46726 = $t46725.y;
                    }
                    $t46727 = ($t46726 > 0.);
                  }
                  if ($t46727 === true) {
                    {
                      let $t46731;
                      {
                        let $t46729;
                        {
                          const $t46728 = b.pos;
                          $t46729 = Spin$Physics$closest(a, c, $t46728);
                        }
                        {
                          const $t46730 = ({ x: 0., y: 0. });
                          $t46731 = Spin$Physics$contact(b, $t46729, r, 0.3, $t46730);
                        }
                      }
                      switch ($t46731.$) {
                        case "Some": {
                          const $f46735 = $t46731._0;
                          const $f46736 = $f46735._0;
                          const $f46737 = $f46735._1;
                          const $f46738 = $f46735._2;
                          {
                            const speed = $f46738;
                            {
                              const nb = $f46736;
                              {
                                let $t46733;
                                {
                                  const $t46732 = { $: "Plain" };
                                  $t46733 = { $: "Touched", _0: $t46732, _1: speed };
                                }
                                {
                                  let $t46734;
                                  $t46734 = { $: "Cons", _0: $t46733, _1: hits };
                                  {
                                    const $rc_2607 = { _0: nb, _1: $t46734 };
                                    return $rc_2607;
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
            const $f46816 = part._0;
            const $f46817 = part._1;
            const $f46818 = part._2;
            {
              const f = $f46818;
              {
                const sr = $f46817;
                {
                  const c = $f46816;
                  {
                    let $t46754;
                    {
                      let $t46750;
                      {
                        let $t46749;
                        {
                          let $t46748;
                          {
                            const $t46747 = b.pos;
                            $t46748 = Arcade$Vec2$sub($t46747, c);
                          }
                          $t46749 = Arcade$Vec2$length($t46748);
                        }
                        $t46750 = ($t46749 < sr);
                      }
                      {
                        let $t46753;
                        {
                          let $t46752;
                          {
                            const $t46751 = Arcade$Vec2$sub(before, c);
                            $t46752 = Arcade$Vec2$length($t46751);
                          }
                          $t46753 = ($t46752 >= sr);
                        }
                        $t46754 = ($t46750 && $t46753);
                      }
                    }
                    if ($t46754 === true) {
                      {
                        const $t46755 = { $: "Touched", _0: f, _1: 0. };
                        {
                          let $t46756;
                          $t46756 = { $: "Cons", _0: $t46755, _1: hits };
                          {
                            const $rc_2610 = { _0: b, _1: $t46756 };
                            return $rc_2610;
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
            const $f46827 = part._0;
            const $f46828 = part._1;
            const $f46829 = part._2;
            {
              const f = $f46829;
              {
                const c = $f46828;
                {
                  const a = $f46827;
                  {
                    let $t46758;
                    {
                      const $t46757 = b.pos;
                      $t46758 = Spin$Physics$crosses(before, $t46757, a, c);
                    }
                    if ($t46758 === true) {
                      {
                        const $t46759 = { $: "Touched", _0: f, _1: 0. };
                        {
                          let $t46760;
                          $t46760 = { $: "Cons", _0: $t46759, _1: hits };
                          {
                            const $rc_2612 = { _0: b, _1: $t46760 };
                            return $rc_2612;
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
    let $p46868;
    $p46868 = acc;
    {
      const b = $p46868._0;
      {
        const hits = $p46868._1;
        {
          let q;
          {
            const $t46839 = spec.pivot;
            {
              let $t46841;
              {
                const $t46840 = f.angle;
                $t46841 = Spin$Table$tip(spec, $t46840);
              }
              {
                const $t46842 = b.pos;
                q = Spin$Physics$closest($t46839, $t46841, $t46842);
              }
            }
          }
          {
            let arm;
            {
              const $t46843 = spec.pivot;
              arm = Arcade$Vec2$sub(q, $t46843);
            }
            {
              let u;
              {
                let $t46847;
                {
                  let $t46845;
                  {
                    const $t46844 = f.omega;
                    $t46845 = (-$t46844);
                  }
                  {
                    const $t46846 = arm.y;
                    $t46847 = ($t46845 * $t46846);
                  }
                }
                {
                  let $t46850;
                  {
                    const $t46848 = f.omega;
                    {
                      const $t46849 = arm.x;
                      $t46850 = ($t46848 * $t46849);
                    }
                  }
                  u = ({ x: $t46847, y: $t46850 });
                }
              }
              {
                let $t46853;
                {
                  let $t46852;
                  {
                    const $t46851 = spec.radius;
                    $t46852 = (r + $t46851);
                  }
                  $t46853 = Spin$Physics$contact(b, q, $t46852, 0.3, u);
                }
                switch ($t46853.$) {
                  case "Some": {
                    const $f46856 = $t46853._0;
                    const $f46857 = $f46856._0;
                    const $f46858 = $f46856._1;
                    const $f46859 = $f46856._2;
                    {
                      const speed = $f46859;
                      {
                        const nb = $f46857;
                        {
                          const $t46854 = { $: "Flipped", _0: speed };
                          {
                            let $t46855;
                            $t46855 = { $: "Cons", _0: $t46854, _1: hits };
                            {
                              const $rc_2615 = { _0: nb, _1: $t46855 };
                              return $rc_2615;
                            }
                          }
                        }
                      }
                    }
                    break;
                  }
                  case "None": {
                    {
                      let $rc_2616;
                      $rc_2616 = acc;
                      return $rc_2616;
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
      let $t46877;
      {
        const $t46873 = b.vel;
        {
          let $t46876;
          {
            let $t46875;
            {
              const $t46874 = t.gravity;
              $t46875 = ($t46874 * h);
            }
            $t46876 = ({ x: 0., y: $t46875 });
          }
          $t46877 = Arcade$Vec2$add($t46873, $t46876);
        }
      }
      {
        const v_i12829 = $t46877;
        {
          let s_i12830;
          s_i12830 = Arcade$Vec2$length($t46877);
          {
            const $t46870_i12832 = (s_i12830 > 2400.);
            if ($t46870_i12832 === true) {
              {
                const $t46872_i12834 = (2400. / s_i12830);
                vel = Arcade$Vec2$scale($t46877, $t46872_i12834);
              }
            } else {
              vel = $t46877;
            }
          }
        }
      }
    }
    {
      let moved;
      {
        let $t46880;
        {
          const $t46878 = b.pos;
          {
            let $t46879;
            $t46879 = Arcade$Vec2$scale(vel, h);
            $t46880 = Arcade$Vec2$add($t46878, $t46879);
          }
        }
        moved = ({ pos: $t46880, vel: vel });
      }
      {
        const r = t.ball_radius;
        {
          let after_parts;
          {
            const $t46881 = t.parts;
            {
              const $t46882 = { $: "Nil" };
              {
                const $t46883 = { _0: moved, _1: $t46882 };
                {
                  const $t46886 = { $: "$Clo_$lam0_Spin_Physics_step_ball$0_Spin_Physics_step_ball", _0: $lam0_Spin_Physics_step_ball$apply$0_Spin_Physics_step_ball, _1: b, _2: r };
                  after_parts = List$fold_left$List_Part$T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit$Fn_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit_Part_T_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Hit($t46881, $t46883, $t46886);
                }
              }
            }
          }
          {
            let after_left;
            {
              const $t46887 = t.left;
              after_left = Spin$Physics$against_flipper(r, $t46887, left, after_parts);
            }
            {
              const $t46888 = t.right;
              return Spin$Physics$against_flipper(r, $t46888, right, after_left);
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
    let $t46907;
    {
      const $t46890 = { $: "Cherry" };
      {
        const $t46891 = { $: "Blank" };
        {
          const $t46892 = { $: "Blank" };
          {
            const $t46893 = { $: "Lemon" };
            {
              const $t46894 = { $: "Blank" };
              {
                const $t46895 = { $: "Blank" };
                {
                  const $t46896 = { $: "Blank" };
                  {
                    const $t46897 = { $: "Blank" };
                    {
                      const $t46898 = { $: "Nil" };
                      {
                        const $t46899 = { $: "Cons", _0: $t46897, _1: $t46898 };
                        {
                          const $t46900 = { $: "Cons", _0: $t46896, _1: $t46899 };
                          {
                            const $t46901 = { $: "Cons", _0: $t46895, _1: $t46900 };
                            {
                              const $t46902 = { $: "Cons", _0: $t46894, _1: $t46901 };
                              {
                                const $t46903 = { $: "Cons", _0: $t46893, _1: $t46902 };
                                {
                                  const $t46904 = { $: "Cons", _0: $t46892, _1: $t46903 };
                                  {
                                    const $t46905 = { $: "Cons", _0: $t46891, _1: $t46904 };
                                    {
                                      const $t46906 = { $: "Cons", _0: $t46890, _1: $t46905 };
                                      {
                                        const $t46889_i5386 = march_int_ovf(-(1), 3);
                                        $t46907 = ({ stops: $t46906, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t46889_i5386, glow: 0. });
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
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
      let $t46925;
      {
        const $t46908 = { $: "Blank" };
        {
          const $t46909 = { $: "Cherry" };
          {
            const $t46910 = { $: "Blank" };
            {
              const $t46911 = { $: "Blank" };
              {
                const $t46912 = { $: "Blank" };
                {
                  const $t46913 = { $: "Blank" };
                  {
                    const $t46914 = { $: "Bell" };
                    {
                      const $t46915 = { $: "Blank" };
                      {
                        const $t46916 = { $: "Nil" };
                        {
                          const $t46917 = { $: "Cons", _0: $t46915, _1: $t46916 };
                          {
                            const $t46918 = { $: "Cons", _0: $t46914, _1: $t46917 };
                            {
                              const $t46919 = { $: "Cons", _0: $t46913, _1: $t46918 };
                              {
                                const $t46920 = { $: "Cons", _0: $t46912, _1: $t46919 };
                                {
                                  const $t46921 = { $: "Cons", _0: $t46911, _1: $t46920 };
                                  {
                                    const $t46922 = { $: "Cons", _0: $t46910, _1: $t46921 };
                                    {
                                      const $t46923 = { $: "Cons", _0: $t46909, _1: $t46922 };
                                      {
                                        const $t46924 = { $: "Cons", _0: $t46908, _1: $t46923 };
                                        {
                                          const $t46889_i5384 = march_int_ovf(-(1), 3);
                                          $t46925 = ({ stops: $t46924, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t46889_i5384, glow: 0. });
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
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
        let $t46943;
        {
          const $t46926 = { $: "Blank" };
          {
            const $t46927 = { $: "Blank" };
            {
              const $t46928 = { $: "Blank" };
              {
                const $t46929 = { $: "Cherry" };
                {
                  const $t46930 = { $: "Blank" };
                  {
                    const $t46931 = { $: "Blank" };
                    {
                      const $t46932 = { $: "Blank" };
                      {
                        const $t46933 = { $: "Blank" };
                        {
                          const $t46934 = { $: "Nil" };
                          {
                            const $t46935 = { $: "Cons", _0: $t46933, _1: $t46934 };
                            {
                              const $t46936 = { $: "Cons", _0: $t46932, _1: $t46935 };
                              {
                                const $t46937 = { $: "Cons", _0: $t46931, _1: $t46936 };
                                {
                                  const $t46938 = { $: "Cons", _0: $t46930, _1: $t46937 };
                                  {
                                    const $t46939 = { $: "Cons", _0: $t46929, _1: $t46938 };
                                    {
                                      const $t46940 = { $: "Cons", _0: $t46928, _1: $t46939 };
                                      {
                                        const $t46941 = { $: "Cons", _0: $t46927, _1: $t46940 };
                                        {
                                          const $t46942 = { $: "Cons", _0: $t46926, _1: $t46941 };
                                          {
                                            const $t46889_i5382 = march_int_ovf(-(1), 3);
                                            $t46943 = ({ stops: $t46942, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t46889_i5382, glow: 0. });
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
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
          const $t46944 = { $: "Nil" };
          {
            const $t46945 = { $: "Cons", _0: $t46943, _1: $t46944 };
            {
              const $t46946 = { $: "Cons", _0: $t46925, _1: $t46945 };
              {
                const $t46947 = { $: "Cons", _0: $t46907, _1: $t46946 };
                {
                  const $t46948 = { $: "Idle" };
                  return ({ reels: $t46947, armed: 0, banked: 0, phase: $t46948, nudge_left: 0., boost: 1, last_line: "", last_pay: 0 });
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
    let $t46951;
    {
      const $t46950 = Spin$Reels$wrap(i);
      $t46951 = List$nth_opt$List_Symbol$Int(xs, $t46950);
    }
    switch ($t46951.$) {
      case "Some": {
        const $f46952 = $t46951._0;
        {
          const s = $f46952;
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
    let $t46958;
    {
      const $t46957 = b.reels;
      $t46958 = List$nth_opt$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($t46957, i);
    }
    switch ($t46958.$) {
      case "Some": {
        const $f46960 = $t46958._0;
        {
          const r = $f46960;
          return r;
        }
        break;
      }
      case "None": {
        {
          const $t46959 = { $: "Nil" };
          {
            const $t46889_i5388 = march_int_ovf(-(1), 3);
            return ({ stops: $t46959, pos: 0, from: 0., travel: 0., elapsed: 0., duration: 0., held: false, fresh: $t46889_i5388, glow: 0. });
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
    const $t46961 = b.reels;
    {
      let $t46962;
      {
        const xs_i12835 = $t46961;
        {
          let $t46953_i12841;
          {
            const $t1226_i6254_i12840 = { $: "Nil" };
            $t46953_i12841 = List$take_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t46961, i, $t1226_i6254_i12840);
          }
          {
            const $t46954_i12842 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
            {
              const $t46955_i12843 = List$drop$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($t46961, $t46954_i12842);
              {
                const $t46956_i12844 = { $: "Cons", _0: r, _1: $t46955_i12843 };
                {
                  const xs_i14370 = $t46953_i12841;
                  {
                    const ys_i14371 = $t46956_i12844;
                    switch (xs_i14370.$) {
                      case "Nil": {
                        $t46962 = $t46956_i12844;
                        break;
                      }
                      case "Cons": {
                        const $f987_i14372 = xs_i14370._0;
                        const $f988_i14373 = xs_i14370._1;
                        {
                          const t_i14374 = $f988_i14373;
                          {
                            const h_i14375 = $f987_i14372;
                            {
                              const $trmc11_i14376 = { $: "Cons", _0: h_i14375, _1: null };
                              List$append$dps$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(t_i14374, $t46956_i12844, $trmc11_i14376);
                              $t46962 = $trmc11_i14376;
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
        const $rc_2621 = ({ ...b, reels: $t46962 });
        return $rc_2621;
      }
    }
  }
}
const Spin$Reels$set_reel$clo = { _0: ($_, b, i, r) => Spin$Reels$set_reel(b, i, r) };

function Spin$Reels$on_line(b, i) {
  {
    const r = Spin$Reels$reel_at(b, i);
    {
      const $t46963 = r.stops;
      {
        const $t46964 = r.pos;
        return Spin$Reels$at($t46963, $t46964);
      }
    }
  }
}
const Spin$Reels$on_line$clo = { _0: ($_, b, i) => Spin$Reels$on_line(b, i) };

function Spin$Reels$shown(r) {
  {
    let $t46972;
    {
      const $t46971 = r.duration;
      $t46972 = ($t46971 > 0.);
    }
    if ($t46972 === true) {
      {
        let t;
        {
          let $t46975;
          {
            const $t46973 = r.elapsed;
            {
              const $t46974 = r.duration;
              $t46975 = ($t46973 / $t46974);
            }
          }
          {
            let $t45789_i5392;
            {
              const $t45787_i14191 = (0. >= $t46975);
              if ($t45787_i14191 === true) {
                $t45789_i5392 = 0.;
              } else {
                $t45789_i5392 = $t46975;
              }
            }
            {
              const $t45788_i14188 = (1. < $t45789_i5392);
              if ($t45788_i14188 === true) {
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
            const $t46976 = r.from;
            {
              let $t46981;
              {
                const $t46977 = r.travel;
                {
                  let $t46980;
                  {
                    let $t46979;
                    {
                      const $t46978 = (left * left);
                      $t46979 = ($t46978 * left);
                    }
                    $t46980 = (1. - $t46979);
                  }
                  $t46981 = ($t46977 * $t46980);
                }
              }
              return ($t46976 + $t46981);
            }
          }
        }
      }
    } else {
      {
        const $t46982 = r.pos;
        return $t46982;
      }
    }
  }
}
const Spin$Reels$shown$clo = { _0: ($_, r) => Spin$Reels$shown(r) };

function Spin$Reels$stop(r, i) {
  {
    const $t46983 = r.stops;
    return Spin$Reels$at($t46983, i);
  }
}
const Spin$Reels$stop$clo = { _0: ($_, r, i) => Spin$Reels$stop(r, i) };

function Spin$Reels$count(xs, s) {
  {
    const $t46985 = { $: "$Clo_$lam0_Spin_Reels_count$0_Spin_Reels_count", _0: $lam0_Spin_Reels_count$apply$0_Spin_Reels_count, _1: s };
    {
      const $t46986 = List$filter$List_Symbol$Fn_Symbol_Bool(xs, $t46985);
      {
        let $rc_2622;
        {  };
        $rc_2622 = List$length_onto$List_Symbol$Int($t46986, 0);
        return $rc_2622;
      }
    }
  }
}
const Spin$Reels$count$clo = { _0: ($_, xs, s) => Spin$Reels$count(xs, s) };

function Spin$Reels$pays(xs) {
  switch (xs.$) {
    case "Cons": {
      const $f46999 = xs._0;
      const $f47000 = xs._1;
      {
        const $jp_clo47006 = { $: "$Clo_$jp2_Spin_Reels_pays$0_Spin_Reels_pays", _0: $jp2_Spin_Reels_pays$apply$0_Spin_Reels_pays };
        switch ($f47000.$) {
          case "Cons": {
            const $f47007 = $f47000._0;
            const $f47008 = $f47000._1;
            {
              const $jp_clo47014 = { $: "$Clo_$jp5_Spin_Reels_pays$1_Spin_Reels_pays", _0: $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays, _1: $jp_clo47006 };
              switch ($f47008.$) {
                case "Cons": {
                  const $f47015 = $f47008._0;
                  const $f47016 = $f47008._1;
                  switch ($f47016.$) {
                    case "Nil": {
                      {
                        const c = $f47015;
                        {
                          const b = $f47007;
                          {
                            const a = $f46999;
                            {
                              let $t46992;
                              {
                                let $t46989;
                                {
                                  const $t46987 = march_deep_eq(a, b);
                                  {
                                    let $t46988;
                                    {
                                      const $rc_2625 = march_deep_eq(b, c);
                                      $t46988 = $rc_2625;
                                    }
                                    $t46989 = ($t46987 && $t46988);
                                  }
                                }
                                {
                                  let $t46991;
                                  {
                                    const $t46990 = { $: "Blank" };
                                    {
                                      const $rc_2624 = (!march_deep_eq(a, $t46990));
                                      $t46991 = $rc_2624;
                                    }
                                  }
                                  $t46992 = ($t46989 && $t46991);
                                }
                              }
                              if ($t46992 === true) {
                                {
                                  let $rc_2623;
                                  switch (a.$) {
                                    case "Seven": {
                                      $rc_2623 = { _0: 77, _1: "JACKPOT 777" };
                                      break;
                                    }
                                    case "Bars": {
                                      $rc_2623 = { _0: 30, _1: "BAR BAR BAR" };
                                      break;
                                    }
                                    case "Bell": {
                                      $rc_2623 = { _0: 20, _1: "THREE BELLS" };
                                      break;
                                    }
                                    case "Lemon": {
                                      $rc_2623 = { _0: 12, _1: "THREE LEMONS" };
                                      break;
                                    }
                                    case "Cherry": {
                                      $rc_2623 = { _0: 10, _1: "THREE CHERRIES" };
                                      break;
                                    }
                                    case "Blank": {
                                      $rc_2623 = { _0: 0, _1: "" };
                                      break;
                                    }
                                    default: {
                                      throw new Error("non-exhaustive pattern match");
                                      break;
                                    }
                                  }
                                  return $rc_2623;
                                }
                              } else {
                                {
                                  let cherries;
                                  {
                                    const $t46993 = { $: "Cherry" };
                                    cherries = Spin$Reels$count(xs, $t46993);
                                  }
                                  {
                                    const $t46994 = (cherries >= 2);
                                    if ($t46994 === true) {
                                      return { _0: 4, _1: "TWO CHERRIES" };
                                    } else {
                                      {
                                        let $t46997;
                                        {
                                          let $t46996;
                                          {
                                            const $t46995 = { $: "Blank" };
                                            $t46996 = Spin$Reels$count(xs, $t46995);
                                          }
                                          $t46997 = ($t46996 === 0);
                                        }
                                        if ($t46997 === true) {
                                          return { _0: 3, _1: "FULL LINE" };
                                        } else {
                                          {
                                            const $t46998 = (cherries === 1);
                                            if ($t46998 === true) {
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
                      return $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays($jp_clo47014);
                    }
                  }
                  break;
                }
                default: {
                  return $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays($jp_clo47014);
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
    const $t47037 = ((8 + 1) < 4611686018427387904 && (8 + 1) >= -4611686018427387904 ? (8 + 1) : march_int_ovf((8 + 1), 0));
    {
      let ahead;
      {
        const go_i5402 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 1 };
        {
          const $t915_i5403 = (($t47037 - 1) < 4611686018427387904 && ($t47037 - 1) >= -4611686018427387904 ? ($t47037 - 1) : march_int_ovf(($t47037 - 1), 1));
          {
            const $t916_i5404 = { $: "Nil" };
            ahead = go$apply$0_List_range(go_i5402, $t915_i5403, $t916_i5404);
          }
        }
      }
      {
        let $t47043;
        {
          let $t47042;
          $t47042 = { $: "$Clo_$lam0_Spin_Reels_roll_to$0_Spin_Reels_roll_to", _0: $lam0_Spin_Reels_roll_to$apply$0_Spin_Reels_roll_to, _1: r, _2: s };
          $t47043 = List$find$List_Int$Fn_Int_Bool(ahead, $t47042);
        }
        switch ($t47043.$) {
          case "Some": {
            const $f47053 = $t47043._0;
            {
              const k = $f47053;
              return k;
            }
            break;
          }
          case "None": {
            {
              let $t47051;
              {
                const $t47050 = { $: "$Clo_$lam1_Spin_Reels_roll_to$1_Spin_Reels_roll_to", _0: $lam1_Spin_Reels_roll_to$apply$1_Spin_Reels_roll_to, _1: r, _2: s };
                {
                  const $rc_2627 = List$find$List_Int$Fn_Int_Bool(ahead, $t47050);
                  $t47051 = $rc_2627;
                }
              }
              switch ($t47051.$) {
                case "Some": {
                  const $f47052 = $t47051._0;
                  {
                    const k = $f47052;
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
        let $t47068;
        $t47068 = Spin$Reels$reel_at(b, i);
        {
          const r_i12884 = $t47068;
          {
            const s_i12885 = s;
            {
              let $t47054_i12886;
              {
                const r_i14400 = $t47068;
                {
                  const $t47026_i14401 = ((8 + 1) < 4611686018427387904 && (8 + 1) >= -4611686018427387904 ? (8 + 1) : march_int_ovf((8 + 1), 0));
                  {
                    let $t47027_i14405;
                    {
                      const go_i5397_i14402 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 1 };
                      {
                        const $t915_i5398_i14403 = (($t47026_i14401 - 1) < 4611686018427387904 && ($t47026_i14401 - 1) >= -4611686018427387904 ? ($t47026_i14401 - 1) : march_int_ovf(($t47026_i14401 - 1), 1));
                        {
                          const $t916_i5399_i14404 = { $: "Nil" };
                          $t47027_i14405 = go$apply$0_List_range(go_i5397_i14402, $t915_i5398_i14403, $t916_i5399_i14404);
                        }
                      }
                    }
                    {
                      let $t47031_i14406;
                      $t47031_i14406 = { $: "$Clo_$lam0_Spin_Reels_target_stop$0_Spin_Reels_target_stop", _0: $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop, _1: $t47068 };
                      {
                        let order_i14407;
                        {
                          const xs_i14449 = $t47027_i14405;
                          {
                            const f_i14450 = $t47031_i14406;
                            switch (xs_i14449.$) {
                              case "Nil": {
                                order_i14407 = { $: "Nil" };
                                break;
                              }
                              case "Cons": {
                                const $f995_i14451 = xs_i14449._0;
                                const $f996_i14452 = xs_i14449._1;
                                {
                                  const t_i14453 = $f996_i14452;
                                  {
                                    const h_i14454 = $f995_i14451;
                                    {
                                      let $t993_i14455;
                                      $t993_i14455 = f_i14450._0(f_i14450, h_i14454);
                                      {
                                        const $trmc15_i14456 = { $: "Cons", _0: $t993_i14455, _1: null };
                                        List$map$dps$List_Int$Fn_Int_Int$List_Int(t_i14453, f_i14450, $trmc15_i14456);
                                        order_i14407 = $trmc15_i14456;
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
                          const $t47035_i14408 = { $: "$Clo_$lam1_Spin_Reels_target_stop$1_Spin_Reels_target_stop", _0: $lam1_Spin_Reels_target_stop$apply$1_Spin_Reels_target_stop, _1: $t47068 };
                          {
                            const $rc_2626_i14409 = List$find$List_Int$Fn_Int_Bool(order_i14407, $t47035_i14408);
                            $t47054_i12886 = $rc_2626_i14409;
                          }
                        }
                      }
                    }
                  }
                }
              }
              switch ($t47054_i12886.$) {
                case "Some": {
                  const $f47057_i12887 = $t47054_i12886._0;
                  {
                    const j_i12888 = $f47057_i12887;
                    {
                      const $t47055_i12889 = $t47068.stops;
                      {
                        let $t47056_i12890;
                        {
                          const xs_i14385 = $t47055_i12889;
                          {
                            let $t46953_i14389;
                            {
                              const $t1226_i6257_i14388 = { $: "Nil" };
                              $t46953_i14389 = List$take_onto$List_Symbol$Int$List_Symbol($t47055_i12889, j_i12888, $t1226_i6257_i14388);
                            }
                            {
                              const $t46954_i14390 = ((j_i12888 + 1) < 4611686018427387904 && (j_i12888 + 1) >= -4611686018427387904 ? (j_i12888 + 1) : march_int_ovf((j_i12888 + 1), 0));
                              {
                                const $t46955_i14391 = List$drop$List_Symbol$Int($t47055_i12889, $t46954_i14390);
                                {
                                  const $t46956_i14392 = { $: "Cons", _0: s, _1: $t46955_i14391 };
                                  {
                                    const xs_i13126_i14393 = $t46953_i14389;
                                    {
                                      const ys_i13127_i14394 = $t46956_i14392;
                                      switch (xs_i13126_i14393.$) {
                                        case "Nil": {
                                          $t47056_i12890 = $t46956_i14392;
                                          break;
                                        }
                                        case "Cons": {
                                          const $f987_i13128_i14395 = xs_i13126_i14393._0;
                                          const $f988_i13129_i14396 = xs_i13126_i14393._1;
                                          {
                                            const t_i13130_i14397 = $f988_i13129_i14396;
                                            {
                                              const h_i13131_i14398 = $f987_i13128_i14395;
                                              {
                                                const $trmc11_i13132_i14399 = { $: "Cons", _0: h_i13131_i14398, _1: null };
                                                List$append$dps$List_Symbol$List_Symbol$List_Symbol(t_i13130_i14397, $t46956_i14392, $trmc11_i13132_i14399);
                                                $t47056_i12890 = $trmc11_i13132_i14399;
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
                          const $rc_2628_i12891 = ({ ...$t47068, stops: $t47056_i12890, fresh: j_i12888, glow: 1. });
                          w = $rc_2628_i12891;
                        }
                      }
                    }
                  }
                  break;
                }
                case "None": {
                  w = $t47068;
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
          let $t47070;
          {
            const $t47069 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
            $t47070 = march_int_mod_euclid($t47069, 3);
          }
          next = ({ ...b, armed: $t47070 });
        }
        {
          let $t47077;
          {
            let $t47073;
            {
              const $t47071 = b.phase;
              {
                const $t47072 = { $: "Spinning" };
                {
                  const $rc_2631 = march_deep_eq($t47071, $t47072);
                  $t47073 = $rc_2631;
                }
              }
            }
            {
              let $t47076;
              {
                const $t47074 = b.phase;
                {
                  const $t47075 = { $: "Nudging" };
                  {
                    const $rc_2630 = march_deep_eq($t47074, $t47075);
                    $t47076 = $rc_2630;
                  }
                }
              }
              $t47077 = ($t47073 || $t47076);
            }
          }
          if ($t47077 === true) {
            {
              const quiet = Spin$Reels$set_reel(next, i, w);
              {
                const $t47078 = { $: "Loaded", _0: s, _1: i };
                {
                  const $t47079 = { $: "Nil" };
                  {
                    const $t47080 = { $: "Cons", _0: $t47078, _1: $t47079 };
                    return { _0: quiet, _1: $t47080 };
                  }
                }
              }
            }
          } else {
            {
              let placed;
              {
                let $t47082;
                {
                  let $t47081;
                  $t47081 = Spin$Reels$roll_to(w, s);
                  {
                    const r_i12872 = w;
                    {
                      let $t47059_i12875;
                      {
                        const $t47058_i12874 = w.pos;
                        $t47059_i12875 = $t47058_i12874;
                      }
                      {
                        const $t47060_i12876 = $t47081;
                        {
                          let $t47063_i12879;
                          {
                            let $t47062_i12878;
                            {
                              const $t47061_i12877 = $t47081;
                              $t47062_i12878 = (0.05 * $t47061_i12877);
                            }
                            $t47063_i12879 = (0.16 + $t47062_i12878);
                          }
                          {
                            let $t47066_i12882;
                            {
                              let $t47065_i12881;
                              {
                                const $t47064_i12880 = w.pos;
                                $t47065_i12881 = (($t47064_i12880 + $t47081) < 4611686018427387904 && ($t47064_i12880 + $t47081) >= -4611686018427387904 ? ($t47064_i12880 + $t47081) : march_int_ovf(($t47064_i12880 + $t47081), 0));
                              }
                              $t47066_i12882 = Spin$Reels$wrap($t47065_i12881);
                            }
                            {
                              const $rc_2629_i12883 = ({ ...w, from: $t47059_i12875, travel: $t47060_i12876, elapsed: 0., duration: $t47063_i12879, pos: $t47066_i12882 });
                              $t47082 = $rc_2629_i12883;
                            }
                          }
                        }
                      }
                    }
                  }
                }
                placed = Spin$Reels$set_reel(next, i, $t47082);
              }
              {
                let building;
                {
                  let $t47087;
                  {
                    let $t47086;
                    {
                      let $t47084;
                      {
                        const $t47083 = b.phase;
                        {
                          const p_i12869 = $t47083;
                          switch (p_i12869.$) {
                            case "Building": {
                              const $f47067_i12870 = p_i12869._0;
                              {
                                const j_i12871 = $f47067_i12870;
                                $t47084 = j_i12871;
                              }
                              break;
                            }
                            case "Idle": {
                              $t47084 = false;
                              break;
                            }
                            case "Spinning": {
                              $t47084 = false;
                              break;
                            }
                            case "Nudging": {
                              $t47084 = false;
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
                        const $t47085 = (i === 2);
                        $t47086 = ($t47084 || $t47085);
                      }
                    }
                    $t47087 = { $: "Building", _0: $t47086 };
                  }
                  building = Spin$Reels$in_phase(placed, $t47087);
                }
                {
                  const $t47088 = { $: "Loaded", _0: s, _1: i };
                  {
                    const $t47089 = { $: "Nil" };
                    {
                      const $t47090 = { $: "Cons", _0: $t47088, _1: $t47089 };
                      return { _0: building, _1: $t47090 };
                    }
                  }
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
      let $t47092;
      {
        const $t47091 = b.banked;
        $t47092 = (($t47091 + 1) < 4611686018427387904 && ($t47091 + 1) >= -4611686018427387904 ? ($t47091 + 1) : march_int_ovf(($t47091 + 1), 0));
      }
      {
        const $t2462_i5407 = ($t47092 < 5);
        if ($t2462_i5407 === true) {
          n = $t47092;
        } else {
          n = 5;
        }
      }
    }
    {
      const $t47094 = ({ ...b, banked: n });
      {
        const $t47095 = { $: "Banked", _0: n };
        {
          const $t47096 = { $: "Nil" };
          {
            const $t47097 = { $: "Cons", _0: $t47095, _1: $t47096 };
            return { _0: $t47094, _1: $t47097 };
          }
        }
      }
    }
  }
}
const Spin$Reels$bank_spin$clo = { _0: ($_, b) => Spin$Reels$bank_spin(b) };

function Spin$Reels$start_reel(rng, r, i) {
  {
    const $t47100 = r.held;
    if ($t47100 === true) {
      return { _0: r, _1: rng };
    } else {
      {
        let $p47113;
        {
          const $p45982_i12894 = Arcade$Rng$next(rng);
          {
            const v_i12895 = $p45982_i12894._0;
            {
              const after_i12896 = $p45982_i12894._1;
              {
                let $t45981_i12897;
                {
                  const v_i14410 = v_i12895;
                  {
                    const $t45972_i14412 = (8 <= 1048576);
                    if ($t45972_i14412 === true) {
                      {
                        let $t45977_i14417;
                        {
                          let $t45975_i14415;
                          {
                            let $t45974_i14414;
                            {
                              const $t45973_i14413 = v_i12895.hi;
                              $t45974_i14414 = ($t45973_i14413 % 8);
                            }
                            $t45975_i14415 = (($t45974_i14414 * 4294967296) < 4611686018427387904 && ($t45974_i14414 * 4294967296) >= -4611686018427387904 ? ($t45974_i14414 * 4294967296) : march_int_ovf(($t45974_i14414 * 4294967296), 2));
                          }
                          {
                            const $t45976_i14416 = v_i12895.lo;
                            $t45977_i14417 = (($t45975_i14415 + $t45976_i14416) < 4611686018427387904 && ($t45975_i14415 + $t45976_i14416) >= -4611686018427387904 ? ($t45975_i14415 + $t45976_i14416) : march_int_ovf(($t45975_i14415 + $t45976_i14416), 0));
                          }
                        }
                        $t45981_i12897 = ($t45977_i14417 % 8);
                      }
                    } else {
                      {
                        let $t45979_i14419;
                        {
                          const $t45978_i14418 = v_i12895.hi;
                          $t45979_i14419 = Arcade$Rng$divide_word(0, $t45978_i14418, 31, 8);
                        }
                        {
                          const $t45980_i14420 = v_i12895.lo;
                          $t45981_i12897 = Arcade$Rng$divide_word($t45979_i14419, $t45980_i14420, 31, 8);
                        }
                      }
                    }
                  }
                }
                {
                  const $rc_2499_i12898 = { _0: $t45981_i12897, _1: after_i12896 };
                  $p47113 = $rc_2499_i12898;
                }
              }
            }
          }
        }
        {
          const target = $p47113._0;
          {
            const after = $p47113._1;
            {
              const laps = ((2 + i) < 4611686018427387904 && (2 + i) >= -4611686018427387904 ? (2 + i) : march_int_ovf((2 + i), 0));
              {
                let ahead;
                {
                  let $t47103;
                  {
                    const $t47102 = r.pos;
                    $t47103 = ((target - $t47102) < 4611686018427387904 && (target - $t47102) >= -4611686018427387904 ? (target - $t47102) : march_int_ovf((target - $t47102), 1));
                  }
                  ahead = Spin$Reels$wrap($t47103);
                }
                {
                  let travel;
                  {
                    let $t47106;
                    {
                      const $t47105 = ((laps * 8) < 4611686018427387904 && (laps * 8) >= -4611686018427387904 ? (laps * 8) : march_int_ovf((laps * 8), 2));
                      $t47106 = (($t47105 + ahead) < 4611686018427387904 && ($t47105 + ahead) >= -4611686018427387904 ? ($t47105 + ahead) : march_int_ovf(($t47105 + ahead), 0));
                    }
                    travel = $t47106;
                  }
                  {
                    let $t47112;
                    {
                      let $t47108;
                      {
                        const $t47107 = r.pos;
                        $t47108 = $t47107;
                      }
                      {
                        let $t47111;
                        {
                          let $t47110;
                          {
                            const $t47109 = i;
                            $t47110 = (0.4 * $t47109);
                          }
                          $t47111 = (0.9 + $t47110);
                        }
                        $t47112 = ({ ...r, from: $t47108, travel: travel, elapsed: 0., duration: $t47111, pos: target });
                      }
                    }
                    {
                      const $rc_2634 = { _0: $t47112, _1: after };
                      return $rc_2634;
                    }
                  }
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
    let $p47127;
    {
      let $t47114;
      $t47114 = Spin$Reels$reel_at(b, 0);
      $p47127 = Spin$Reels$start_reel(rng, $t47114, 0);
    }
    {
      const r0 = $p47127._0;
      {
        const g0 = $p47127._1;
        {
          let $p47126;
          {
            let $t47115;
            $t47115 = Spin$Reels$reel_at(b, 1);
            $p47126 = Spin$Reels$start_reel(g0, $t47115, 1);
          }
          {
            const r1 = $p47126._0;
            {
              const g1 = $p47126._1;
              {
                let $p47125;
                {
                  let $t47116;
                  $t47116 = Spin$Reels$reel_at(b, 2);
                  $p47125 = Spin$Reels$start_reel(g1, $t47116, 2);
                }
                {
                  const r2 = $p47125._0;
                  {
                    const g2 = $p47125._1;
                    {
                      let $t47124;
                      {
                        const $t47117 = { $: "Nil" };
                        {
                          let $t47118;
                          $t47118 = { $: "Cons", _0: r2, _1: $t47117 };
                          {
                            let $t47119;
                            $t47119 = { $: "Cons", _0: r1, _1: $t47118 };
                            {
                              let $t47120;
                              $t47120 = { $: "Cons", _0: r0, _1: $t47119 };
                              {
                                let $t47122;
                                {
                                  const $t47121 = b.banked;
                                  $t47122 = (($t47121 - 1) < 4611686018427387904 && ($t47121 - 1) >= -4611686018427387904 ? ($t47121 - 1) : march_int_ovf(($t47121 - 1), 1));
                                }
                                {
                                  const $t47123 = { $: "Spinning" };
                                  $t47124 = ({ ...b, reels: $t47120, banked: $t47122, phase: $t47123, nudge_left: 0. });
                                }
                              }
                            }
                          }
                        }
                      }
                      {
                        const $rc_2636 = { _0: $t47124, _1: g2 };
                        return $rc_2636;
                      }
                    }
                  }
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
      let $t47130;
      {
        let $t47129;
        {
          const $t47128 = r.glow;
          $t47129 = ($t47128 - dt);
        }
        {
          const $t45787_i5410 = ($t47129 >= 0.);
          if ($t45787_i5410 === true) {
            $t47130 = $t47129;
          } else {
            $t47130 = 0.;
          }
        }
      }
      faded = ({ ...r, glow: $t47130 });
    }
    {
      let $t47132;
      {
        const $t47131 = faded.duration;
        $t47132 = ($t47131 > 0.);
      }
      if ($t47132 === true) {
        {
          let e;
          {
            const $t47133 = faded.elapsed;
            e = ($t47133 + dt);
          }
          {
            let $t47135;
            {
              const $t47134 = faded.duration;
              $t47135 = (e >= $t47134);
            }
            if ($t47135 === true) {
              {
                const $t47136 = ({ ...faded, elapsed: 0., duration: 0., travel: 0. });
                {
                  const $t47137 = { $: "Landed", _0: i };
                  {
                    const $t47138 = { $: "Nil" };
                    {
                      const $t47139 = { $: "Cons", _0: $t47137, _1: $t47138 };
                      {
                        const $rc_2644 = { _0: $t47136, _1: $t47139 };
                        return $rc_2644;
                      }
                    }
                  }
                }
              }
            } else {
              {
                const $t47140 = ({ ...faded, elapsed: e });
                {
                  const $t47141 = { $: "Nil" };
                  {
                    const $rc_2643 = { _0: $t47140, _1: $t47141 };
                    return $rc_2643;
                  }
                }
              }
            }
          }
        }
      } else {
        {
          const $t47142 = { $: "Nil" };
          return { _0: faded, _1: $t47142 };
        }
      }
    }
  }
}
const Spin$Reels$turn$clo = { _0: ($_, r, dt, i) => Spin$Reels$turn(r, dt, i) };

function Spin$Reels$unhold(r) {
  {
    const $rc_2645 = ({ ...r, held: false });
    return $rc_2645;
  }
}
const Spin$Reels$unhold$clo = { _0: ($_, r) => Spin$Reels$unhold(r) };

function Spin$Reels$settle(b) {
  {
    let $p47167;
    {
      let $t47147;
      {
        const b_i12899 = b;
        {
          let $t46965_i12900;
          $t46965_i12900 = Spin$Reels$on_line(b, 0);
          {
            let $t46966_i12901;
            $t46966_i12901 = Spin$Reels$on_line(b, 1);
            {
              const $t46967_i12902 = Spin$Reels$on_line(b, 2);
              {
                const $t46968_i12903 = { $: "Nil" };
                {
                  const $t46969_i12904 = { $: "Cons", _0: $t46967_i12902, _1: $t46968_i12903 };
                  {
                    const $t46970_i12905 = { $: "Cons", _0: $t46966_i12901, _1: $t46969_i12904 };
                    $t47147 = { $: "Cons", _0: $t46965_i12900, _1: $t46970_i12905 };
                  }
                }
              }
            }
          }
        }
      }
      $p47167 = Spin$Reels$pays($t47147);
    }
    {
      const pay = $p47167._0;
      {
        const name = $p47167._1;
        {
          let idle;
          {
            const $t47148 = { $: "Idle" };
            idle = ({ ...b, phase: $t47148 });
          }
          {
            const $t47149 = b.phase;
            switch ($t47149.$) {
              case "Building": {
                const $f47166 = $t47149._0;
                {
                  let judge;
                  judge = $f47166;
                  {
                    let $t47151;
                    {
                      const $t47150 = (pay > 0);
                      $t47151 = (judge && $t47150);
                    }
                    if ($t47151 === true) {
                      {
                        let paid;
                        paid = ({ ...idle, last_line: name, last_pay: pay });
                        {
                          let out;
                          {
                            let $t47152;
                            $t47152 = { $: "Paid", _0: pay, _1: name };
                            {
                              const $t47153 = { $: "Nil" };
                              {
                                const $t47154 = { $: "Cons", _0: $t47152, _1: $t47153 };
                                out = { _0: paid, _1: $t47154 };
                              }
                            }
                          }
                          return out;
                        }
                      }
                    } else {
                      {
                        const $t47155 = { $: "Nil" };
                        {
                          const $rc_2655 = { _0: idle, _1: $t47155 };
                          return $rc_2655;
                        }
                      }
                    }
                  }
                }
                break;
              }
              case "Spinning": {
                {
                  const $t47156 = (pay > 0);
                  if ($t47156 === true) {
                    return Spin$Reels$spent(idle, pay, name);
                  } else {
                    {
                      let missed;
                      {
                        const $t47157 = b.reels;
                        {
                          let $t47158;
                          $t47158 = List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t47157, Spin$Reels$unhold$clo);
                          missed = ({ ...idle, reels: $t47158, boost: 1, nudge_left: 4., last_line: "NUDGE!", last_pay: 0 });
                        }
                      }
                      {
                        let out;
                        {
                          const $t47160 = { $: "Missed" };
                          {
                            const $t47161 = { $: "Nil" };
                            {
                              const $t47162 = { $: "Cons", _0: $t47160, _1: $t47161 };
                              out = { _0: missed, _1: $t47162 };
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
                  const $t47163 = (pay > 0);
                  if ($t47163 === true) {
                    return Spin$Reels$spent(idle, pay, name);
                  } else {
                    {
                      const $t47164 = { $: "Nil" };
                      {
                        const $rc_2658 = { _0: idle, _1: $t47164 };
                        return $rc_2658;
                      }
                    }
                  }
                }
                break;
              }
              case "Idle": {
                {
                  const $t47165 = { $: "Nil" };
                  {
                    const $rc_2659 = { _0: idle, _1: $t47165 };
                    return $rc_2659;
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
      const $t47168 = b.boost;
      total = ((pay * $t47168) < 4611686018427387904 && (pay * $t47168) >= -4611686018427387904 ? (pay * $t47168) : march_int_ovf((pay * $t47168), 2));
    }
    {
      let named;
      {
        let $t47170;
        {
          const $t47169 = b.boost;
          $t47170 = ($t47169 > 1);
        }
        if ($t47170 === true) {
          {
            let $t47172;
            {
              const $t47171 = b.boost;
              $t47172 = String($t47171);
            }
            {
              const $rc_2660 = march_string_concat3(name, " x", $t47172);
              named = $rc_2660;
            }
          }
        } else {
          named = name;
        }
      }
      {
        let paid;
        {
          const $t47173 = b.reels;
          {
            let $t47174;
            $t47174 = List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t47173, Spin$Reels$unhold$clo);
            paid = ({ ...b, reels: $t47174, boost: 1, nudge_left: 0., last_line: named, last_pay: total });
          }
        }
        {
          let out;
          {
            const $t47175 = { $: "Paid", _0: total, _1: named };
            {
              const $t47176 = { $: "Nil" };
              {
                const $t47177 = { $: "Cons", _0: $t47175, _1: $t47176 };
                out = { _0: paid, _1: $t47177 };
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
    let $p47218;
    {
      let $t47178;
      $t47178 = Spin$Reels$reel_at(b, 0);
      $p47218 = Spin$Reels$turn($t47178, dt, 0);
    }
    {
      const r0 = $p47218._0;
      {
        const e0 = $p47218._1;
        {
          let $p47217;
          {
            let $t47179;
            $t47179 = Spin$Reels$reel_at(b, 1);
            $p47217 = Spin$Reels$turn($t47179, dt, 1);
          }
          {
            const r1 = $p47217._0;
            {
              const e1 = $p47217._1;
              {
                let $p47216;
                {
                  let $t47180;
                  $t47180 = Spin$Reels$reel_at(b, 2);
                  $p47216 = Spin$Reels$turn($t47180, dt, 2);
                }
                {
                  const r2 = $p47216._0;
                  {
                    const e2 = $p47216._1;
                    {
                      let turned;
                      {
                        const $t47181 = { $: "Nil" };
                        {
                          let $t47182;
                          $t47182 = { $: "Cons", _0: r2, _1: $t47181 };
                          {
                            let $t47183;
                            $t47183 = { $: "Cons", _0: r1, _1: $t47182 };
                            {
                              let $t47184;
                              $t47184 = { $: "Cons", _0: r0, _1: $t47183 };
                              {
                                let $t47187;
                                {
                                  let $t47186;
                                  {
                                    const $t47185 = b.nudge_left;
                                    $t47186 = ($t47185 - dt);
                                  }
                                  {
                                    const $t45787_i5421 = ($t47186 >= 0.);
                                    if ($t45787_i5421 === true) {
                                      $t47187 = $t47186;
                                    } else {
                                      $t47187 = 0.;
                                    }
                                  }
                                }
                                turned = ({ ...b, reels: $t47184, nudge_left: $t47187 });
                              }
                            }
                          }
                        }
                      }
                      {
                        const $t47188 = { $: "Nil" };
                        {
                          let $t47189;
                          $t47189 = { $: "Cons", _0: e2, _1: $t47188 };
                          {
                            let $t47190;
                            $t47190 = { $: "Cons", _0: e1, _1: $t47189 };
                            {
                              let $t47191;
                              $t47191 = { $: "Cons", _0: e0, _1: $t47190 };
                              {
                                let landed;
                                {
                                  const prepend_reversed_i5416 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_ReelEvent", _0: prepend_reversed$apply$0_List_concat_List_List_ReelEvent };
                                  {
                                    const go_i5417 = { $: "$Clo_go$1_List_concat_List_List_ReelEvent", _0: go$apply$1_List_concat_List_List_ReelEvent, _1: prepend_reversed_i5416 };
                                    {
                                      const $t1113_i5418 = { $: "Nil" };
                                      landed = go$apply$1_List_concat_List_List_ReelEvent(go_i5417, $t47191, $t1113_i5418);
                                    }
                                  }
                                }
                                {
                                  let $p47215;
                                  {
                                    let $t47197;
                                    {
                                      let $t47194;
                                      {
                                        const $t47192 = turned.phase;
                                        {
                                          const $t47193 = { $: "Idle" };
                                          {
                                            const $rc_2668 = (!march_deep_eq($t47192, $t47193));
                                            $t47194 = $rc_2668;
                                          }
                                        }
                                      }
                                      {
                                        let $t47196;
                                        {
                                          let $t47195;
                                          {
                                            const b_i12913 = turned;
                                            {
                                              const $t47143_i12914 = turned.reels;
                                              {
                                                const $t47146_i12915 = { $: "$Clo_$lam0_Spin_Reels_turning$0_Spin_Reels_turning", _0: $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning };
                                                $t47195 = List$any$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool($t47143_i12914, $t47146_i12915);
                                              }
                                            }
                                          }
                                          $t47196 = (!$t47195);
                                        }
                                        $t47197 = ($t47194 && $t47196);
                                      }
                                    }
                                    if ($t47197 === true) {
                                      $p47215 = Spin$Reels$settle(turned);
                                    } else {
                                      {
                                        const $t47198 = { $: "Nil" };
                                        $p47215 = { _0: turned, _1: $t47198 };
                                      }
                                    }
                                  }
                                  {
                                    const settled = $p47215._0;
                                    {
                                      const paid = $p47215._1;
                                      {
                                        let $t47204;
                                        {
                                          let $t47201;
                                          {
                                            const $t47199 = settled.phase;
                                            {
                                              const $t47200 = { $: "Idle" };
                                              {
                                                const $rc_2663 = march_deep_eq($t47199, $t47200);
                                                $t47201 = $rc_2663;
                                              }
                                            }
                                          }
                                          {
                                            let $t47203;
                                            {
                                              const $t47202 = settled.banked;
                                              $t47203 = ($t47202 > 0);
                                            }
                                            $t47204 = ($t47201 && $t47203);
                                          }
                                        }
                                        if ($t47204 === true) {
                                          {
                                            let $p47213;
                                            $p47213 = Spin$Reels$start_spin(settled, rng);
                                            {
                                              const spun = $p47213._0;
                                              {
                                                const after = $p47213._1;
                                                {
                                                  const $t47205 = { $: "Started" };
                                                  {
                                                    const $t47206 = { $: "Nil" };
                                                    {
                                                      const $t47207 = { $: "Cons", _0: $t47205, _1: $t47206 };
                                                      {
                                                        const $t47208 = { $: "Nil" };
                                                        {
                                                          const $t47209 = { $: "Cons", _0: $t47207, _1: $t47208 };
                                                          {
                                                            let $t47210;
                                                            $t47210 = { $: "Cons", _0: paid, _1: $t47209 };
                                                            {
                                                              const $t47211 = { $: "Cons", _0: landed, _1: $t47210 };
                                                              {
                                                                let $t47212;
                                                                {
                                                                  const prepend_reversed_i5412 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_ReelEvent", _0: prepend_reversed$apply$0_List_concat_List_List_ReelEvent };
                                                                  {
                                                                    const go_i5413 = { $: "$Clo_go$1_List_concat_List_List_ReelEvent", _0: go$apply$1_List_concat_List_List_ReelEvent, _1: prepend_reversed_i5412 };
                                                                    {
                                                                      const $t1113_i5414 = { $: "Nil" };
                                                                      $t47212 = go$apply$1_List_concat_List_List_ReelEvent(go_i5413, $t47211, $t1113_i5414);
                                                                    }
                                                                  }
                                                                }
                                                                {
                                                                  const $rc_2662 = { _0: spun, _1: after, _2: $t47212 };
                                                                  return $rc_2662;
                                                                }
                                                              }
                                                            }
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
                                            let $t47214;
                                            {
                                              const xs_i12906 = landed;
                                              {
                                                const ys_i12907 = paid;
                                                switch (xs_i12906.$) {
                                                  case "Nil": {
                                                    $t47214 = paid;
                                                    break;
                                                  }
                                                  case "Cons": {
                                                    const $f987_i12908 = xs_i12906._0;
                                                    const $f988_i12909 = xs_i12906._1;
                                                    {
                                                      const t_i12910 = $f988_i12909;
                                                      {
                                                        const h_i12911 = $f987_i12908;
                                                        {
                                                          const $trmc11_i12912 = { $: "Cons", _0: h_i12911, _1: null };
                                                          List$append$dps$List_ReelEvent$List_ReelEvent$List_ReelEvent(t_i12910, paid, $trmc11_i12912);
                                                          $t47214 = $trmc11_i12912;
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
                                              let $rc_2666;
                                              $rc_2666 = { _0: settled, _1: rng, _2: $t47214 };
                                              return $rc_2666;
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
    const $rc_2681 = ({ ...b, phase: p });
    return $rc_2681;
  }
}
const Spin$Reels$in_phase$clo = { _0: ($_, b, p) => Spin$Reels$in_phase(b, p) };

function Spin$Reels$nudge(b, i) {
  {
    let $t47224;
    {
      let $t47220;
      {
        const $t47219 = b.nudge_left;
        $t47220 = ($t47219 > 0.);
      }
      {
        let $t47223;
        {
          const $t47221 = b.phase;
          {
            const $t47222 = { $: "Idle" };
            {
              const $rc_2684 = march_deep_eq($t47221, $t47222);
              $t47223 = $rc_2684;
            }
          }
        }
        $t47224 = ($t47220 && $t47223);
      }
    }
    if ($t47224 === true) {
      {
        let r;
        r = Spin$Reels$reel_at(b, i);
        {
          let rolled;
          {
            let $t47226;
            {
              const $t47225 = r.pos;
              $t47226 = $t47225;
            }
            {
              let $t47229;
              {
                let $t47228;
                {
                  const $t47227 = r.pos;
                  $t47228 = (($t47227 + 1) < 4611686018427387904 && ($t47227 + 1) >= -4611686018427387904 ? ($t47227 + 1) : march_int_ovf(($t47227 + 1), 0));
                }
                $t47229 = Spin$Reels$wrap($t47228);
              }
              rolled = ({ ...r, from: $t47226, travel: 1., elapsed: 0., duration: 0.16, pos: $t47229 });
            }
          }
          {
            let placed;
            {
              const $t47230 = Spin$Reels$set_reel(b, i, rolled);
              {
                const $t47231 = { $: "Nudging" };
                placed = Spin$Reels$in_phase($t47230, $t47231);
              }
            }
            {
              const $t47232 = { $: "Nudged", _0: i };
              {
                const $t47233 = { $: "Nil" };
                {
                  const $t47234 = { $: "Cons", _0: $t47232, _1: $t47233 };
                  {
                    const $rc_2683 = { _0: placed, _1: $t47234 };
                    return $rc_2683;
                  }
                }
              }
            }
          }
        }
      }
    } else {
      {
        const $t47235 = { $: "Nil" };
        return { _0: b, _1: $t47235 };
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
      const $t47236 = r.held;
      if ($t47236 === true) {
        {
          const $t47237 = { $: "Nil" };
          return { _0: b, _1: $t47237 };
        }
      } else {
        {
          let held;
          {
            const $t47238 = ({ ...r, held: true });
            held = Spin$Reels$set_reel(b, i, $t47238);
          }
          {
            let $t47242;
            {
              const $t47239 = held.reels;
              {
                const $t47241 = { $: "$Clo_$lam0_Spin_Reels_hold$0_Spin_Reels_hold", _0: $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold };
                $t47242 = List$all$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_Bool($t47239, $t47241);
              }
            }
            if ($t47242 === true) {
              {
                let cleared;
                {
                  const $t47243 = held.reels;
                  {
                    let $t47244;
                    $t47244 = List$map$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Fn_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float($t47243, Spin$Reels$unhold$clo);
                    cleared = ({ ...held, reels: $t47244, boost: 2 });
                  }
                }
                {
                  const $p47250 = Spin$Reels$bank_spin(cleared);
                  {
                    const free = $p47250._0;
                    {
                      const $t47245 = { $: "Held", _0: i };
                      {
                        const $t47246 = { $: "Doubled" };
                        {
                          const $t47247 = { $: "Nil" };
                          {
                            const $t47248 = { $: "Cons", _0: $t47246, _1: $t47247 };
                            {
                              const $t47249 = { $: "Cons", _0: $t47245, _1: $t47248 };
                              {
                                const $rc_2686 = { _0: free, _1: $t47249 };
                                return $rc_2686;
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
                const $t47251 = { $: "Held", _0: i };
                {
                  const $t47252 = { $: "Nil" };
                  {
                    const $t47253 = { $: "Cons", _0: $t47251, _1: $t47252 };
                    {
                      const $rc_2691 = { _0: held, _1: $t47253 };
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
const Spin$Reels$hold$clo = { _0: ($_, b, i) => Spin$Reels$hold(b, i) };

function Spin$Table$arch_point(n, i) {
  {
    let a;
    {
      const $t47254 = n.pi;
      {
        let $t47258;
        {
          let $t47257;
          {
            const $t47255 = n.pi;
            {
              const $t47256 = i;
              $t47257 = ($t47255 * $t47256);
            }
          }
          $t47258 = ($t47257 / 12.);
        }
        a = ($t47254 + $t47258);
      }
    }
    {
      let $t47261;
      {
        let $t47260;
        {
          const $t47259 = Math.cos(a);
          $t47260 = (180. * $t47259);
        }
        $t47261 = (200. + $t47260);
      }
      {
        let $t47264;
        {
          let $t47263;
          {
            const $t47262 = Math.sin(a);
            $t47263 = (180. * $t47262);
          }
          $t47264 = (200. + $t47263);
        }
        return ({ x: $t47261, y: $t47264 });
      }
    }
  }
}
const Spin$Table$arch_point$clo = { _0: ($_, n, i) => Spin$Table$arch_point(n, i) };

function Spin$Table$parts(n) {
  {
    let $t47271;
    {
      let $t47265_i5558;
      {
        const go_i14316 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
        {
          const $t915_i14317 = ((12 - 1) < 4611686018427387904 && (12 - 1) >= -4611686018427387904 ? (12 - 1) : march_int_ovf((12 - 1), 1));
          {
            const $t916_i14318 = { $: "Nil" };
            $t47265_i5558 = go$apply$0_List_range(go_i14316, $t915_i14317, $t916_i14318);
          }
        }
      }
      {
        const $t47270_i5559 = { $: "$Clo_$lam0_Spin_Table_arch$0_Spin_Table_arch", _0: $lam0_Spin_Table_arch$apply$0_Spin_Table_arch, _1: n };
        {
          const xs_i14421 = $t47265_i5558;
          {
            const f_i14422 = $t47270_i5559;
            switch (xs_i14421.$) {
              case "Nil": {
                $t47271 = { $: "Nil" };
                break;
              }
              case "Cons": {
                const $f995_i14423 = xs_i14421._0;
                const $f996_i14424 = xs_i14421._1;
                {
                  const t_i14425 = $f996_i14424;
                  {
                    const h_i14426 = $f995_i14423;
                    {
                      let $t993_i14427;
                      $t993_i14427 = f_i14422._0(f_i14422, h_i14426);
                      {
                        const $trmc15_i14428 = { $: "Cons", _0: $t993_i14427, _1: null };
                        List$map$dps$List_Int$Fn_Int_Part$List_Part(t_i14425, f_i14422, $trmc15_i14428);
                        $t47271 = $trmc15_i14428;
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
      let $t47274;
      {
        const $t47272 = ({ x: 20., y: 200. });
        {
          const $t47273 = ({ x: 20., y: 568. });
          $t47274 = { $: "Wall", _0: $t47272, _1: $t47273, _2: 0.5 };
        }
      }
      {
        let $t47277;
        {
          const $t47275 = ({ x: 380., y: 200. });
          {
            const $t47276 = ({ x: 380., y: 760. });
            $t47277 = { $: "Wall", _0: $t47275, _1: $t47276, _2: 0.4 };
          }
        }
        {
          let $t47280;
          {
            const $t47278 = ({ x: 350., y: 262. });
            {
              const $t47279 = ({ x: 350., y: 760. });
              $t47280 = { $: "Wall", _0: $t47278, _1: $t47279, _2: 0.4 };
            }
          }
          {
            let $t47283;
            {
              const $t47281 = ({ x: 350., y: 700. });
              {
                const $t47282 = ({ x: 380., y: 700. });
                $t47283 = { $: "Wall", _0: $t47281, _1: $t47282, _2: 0.1 };
              }
            }
            {
              let $t47286;
              {
                const $t47284 = ({ x: 350., y: 262. });
                {
                  const $t47285 = ({ x: 380., y: 236. });
                  $t47286 = { $: "Gate", _0: $t47284, _1: $t47285 };
                }
              }
              {
                let $t47289;
                {
                  const $t47287 = ({ x: 20., y: 568. });
                  {
                    const $t47288 = ({ x: 124.5, y: 654.6 });
                    $t47289 = { $: "Wall", _0: $t47287, _1: $t47288, _2: 0.3 };
                  }
                }
                {
                  let $t47292;
                  {
                    const $t47290 = ({ x: 350., y: 568. });
                    {
                      const $t47291 = ({ x: 245.5, y: 654.6 });
                      $t47292 = { $: "Wall", _0: $t47290, _1: $t47291, _2: 0.3 };
                    }
                  }
                  {
                    let $t47295;
                    {
                      const $t47293 = ({ x: 62., y: 165. });
                      {
                        const $t47294 = ({ x: 62., y: 300. });
                        $t47295 = { $: "Wall", _0: $t47293, _1: $t47294, _2: 0.4 };
                      }
                    }
                    {
                      let $t47297;
                      {
                        const $t47296 = ({ x: 62., y: 165. });
                        $t47297 = { $: "Peg", _0: $t47296, _1: 4., _2: 0.4 };
                      }
                      {
                        let $t47299;
                        {
                          const $t47298 = ({ x: 62., y: 300. });
                          $t47299 = { $: "Peg", _0: $t47298, _1: 4., _2: 0.4 };
                        }
                        {
                          let $t47302;
                          {
                            const $t47300 = ({ x: 308., y: 165. });
                            {
                              const $t47301 = ({ x: 308., y: 300. });
                              $t47302 = { $: "Wall", _0: $t47300, _1: $t47301, _2: 0.4 };
                            }
                          }
                          {
                            let $t47304;
                            {
                              const $t47303 = ({ x: 308., y: 165. });
                              $t47304 = { $: "Peg", _0: $t47303, _1: 4., _2: 0.4 };
                            }
                            {
                              let $t47306;
                              {
                                const $t47305 = ({ x: 308., y: 300. });
                                $t47306 = { $: "Peg", _0: $t47305, _1: 4., _2: 0.4 };
                              }
                              {
                                let $t47310;
                                {
                                  const $t47307 = ({ x: 20., y: 232. });
                                  {
                                    const $t47308 = ({ x: 62., y: 232. });
                                    {
                                      const $t47309 = { $: "Spinner" };
                                      $t47310 = { $: "Tripwire", _0: $t47307, _1: $t47308, _2: $t47309 };
                                    }
                                  }
                                }
                                {
                                  let $t47313;
                                  {
                                    const $t47311 = ({ x: 133., y: 82. });
                                    {
                                      const $t47312 = ({ x: 133., y: 122. });
                                      $t47313 = { $: "Wall", _0: $t47311, _1: $t47312, _2: 0.4 };
                                    }
                                  }
                                  {
                                    let $t47316;
                                    {
                                      const $t47314 = ({ x: 168., y: 82. });
                                      {
                                        const $t47315 = ({ x: 168., y: 122. });
                                        $t47316 = { $: "Wall", _0: $t47314, _1: $t47315, _2: 0.4 };
                                      }
                                    }
                                    {
                                      let $t47319;
                                      {
                                        const $t47317 = ({ x: 203., y: 82. });
                                        {
                                          const $t47318 = ({ x: 203., y: 122. });
                                          $t47319 = { $: "Wall", _0: $t47317, _1: $t47318, _2: 0.4 };
                                        }
                                      }
                                      {
                                        let $t47322;
                                        {
                                          const $t47320 = ({ x: 238., y: 82. });
                                          {
                                            const $t47321 = ({ x: 238., y: 122. });
                                            $t47322 = { $: "Wall", _0: $t47320, _1: $t47321, _2: 0.4 };
                                          }
                                        }
                                        {
                                          let $t47325;
                                          {
                                            const $t47323 = ({ x: 150.5, y: 104. });
                                            {
                                              const $t47324 = { $: "HoldLane", _0: 0 };
                                              $t47325 = { $: "Sensor", _0: $t47323, _1: 9., _2: $t47324 };
                                            }
                                          }
                                          {
                                            let $t47328;
                                            {
                                              const $t47326 = ({ x: 185.5, y: 104. });
                                              {
                                                const $t47327 = { $: "HoldLane", _0: 1 };
                                                $t47328 = { $: "Sensor", _0: $t47326, _1: 9., _2: $t47327 };
                                              }
                                            }
                                            {
                                              let $t47331;
                                              {
                                                const $t47329 = ({ x: 220.5, y: 104. });
                                                {
                                                  const $t47330 = { $: "HoldLane", _0: 2 };
                                                  $t47331 = { $: "Sensor", _0: $t47329, _1: 9., _2: $t47330 };
                                                }
                                              }
                                              {
                                                let $t47334;
                                                {
                                                  const $t47332 = ({ x: 122., y: 228. });
                                                  {
                                                    const $t47333 = { $: "Bumper", _0: 0 };
                                                    $t47334 = { $: "Kicker", _0: $t47332, _1: 21., _2: $t47333 };
                                                  }
                                                }
                                                {
                                                  let $t47337;
                                                  {
                                                    const $t47335 = ({ x: 249., y: 228. });
                                                    {
                                                      const $t47336 = { $: "Bumper", _0: 1 };
                                                      $t47337 = { $: "Kicker", _0: $t47335, _1: 21., _2: $t47336 };
                                                    }
                                                  }
                                                  {
                                                    let $t47340;
                                                    {
                                                      const $t47338 = ({ x: 185.5, y: 300. });
                                                      {
                                                        const $t47339 = { $: "Bumper", _0: 2 };
                                                        $t47340 = { $: "Kicker", _0: $t47338, _1: 21., _2: $t47339 };
                                                      }
                                                    }
                                                    {
                                                      let $t47345;
                                                      {
                                                        const $t47341 = ({ x: 172., y: 168. });
                                                        {
                                                          const $t47342 = ({ x: 199., y: 168. });
                                                          {
                                                            let $t47344;
                                                            {
                                                              const $t47343 = { $: "Seven" };
                                                              $t47344 = { $: "Loader", _0: $t47343 };
                                                            }
                                                            $t47345 = { $: "Face", _0: $t47341, _1: $t47342, _2: 0., _3: $t47344 };
                                                          }
                                                        }
                                                      }
                                                      {
                                                        let $t47350;
                                                        {
                                                          const $t47346 = ({ x: 24., y: 352. });
                                                          {
                                                            const $t47347 = ({ x: 24., y: 392. });
                                                            {
                                                              let $t47349;
                                                              {
                                                                const $t47348 = { $: "Cherry" };
                                                                $t47349 = { $: "Loader", _0: $t47348 };
                                                              }
                                                              $t47350 = { $: "Face", _0: $t47346, _1: $t47347, _2: 0., _3: $t47349 };
                                                            }
                                                          }
                                                        }
                                                        {
                                                          let $t47355;
                                                          {
                                                            const $t47351 = ({ x: 24., y: 414. });
                                                            {
                                                              const $t47352 = ({ x: 24., y: 454. });
                                                              {
                                                                let $t47354;
                                                                {
                                                                  const $t47353 = { $: "Lemon" };
                                                                  $t47354 = { $: "Loader", _0: $t47353 };
                                                                }
                                                                $t47355 = { $: "Face", _0: $t47351, _1: $t47352, _2: 0., _3: $t47354 };
                                                              }
                                                            }
                                                          }
                                                          {
                                                            let $t47360;
                                                            {
                                                              const $t47356 = ({ x: 346., y: 352. });
                                                              {
                                                                const $t47357 = ({ x: 346., y: 392. });
                                                                {
                                                                  let $t47359;
                                                                  {
                                                                    const $t47358 = { $: "Bell" };
                                                                    $t47359 = { $: "Loader", _0: $t47358 };
                                                                  }
                                                                  $t47360 = { $: "Face", _0: $t47356, _1: $t47357, _2: 0., _3: $t47359 };
                                                                }
                                                              }
                                                            }
                                                            {
                                                              let $t47365;
                                                              {
                                                                const $t47361 = ({ x: 346., y: 414. });
                                                                {
                                                                  const $t47362 = ({ x: 346., y: 454. });
                                                                  {
                                                                    let $t47364;
                                                                    {
                                                                      const $t47363 = { $: "Bars" };
                                                                      $t47364 = { $: "Loader", _0: $t47363 };
                                                                    }
                                                                    $t47365 = { $: "Face", _0: $t47361, _1: $t47362, _2: 0., _3: $t47364 };
                                                                  }
                                                                }
                                                              }
                                                              {
                                                                let $t47369;
                                                                {
                                                                  const $t47366 = ({ x: 42., y: 478. });
                                                                  {
                                                                    const $t47367 = ({ x: 100., y: 595. });
                                                                    {
                                                                      const $t47368 = { $: "Sling" };
                                                                      $t47369 = { $: "Face", _0: $t47366, _1: $t47367, _2: 520., _3: $t47368 };
                                                                    }
                                                                  }
                                                                }
                                                                {
                                                                  let $t47372;
                                                                  {
                                                                    const $t47370 = ({ x: 42., y: 478. });
                                                                    {
                                                                      const $t47371 = ({ x: 42., y: 547. });
                                                                      $t47372 = { $: "Wall", _0: $t47370, _1: $t47371, _2: 0.3 };
                                                                    }
                                                                  }
                                                                  {
                                                                    let $t47375;
                                                                    {
                                                                      const $t47373 = ({ x: 42., y: 547. });
                                                                      {
                                                                        const $t47374 = ({ x: 100., y: 595. });
                                                                        $t47375 = { $: "Wall", _0: $t47373, _1: $t47374, _2: 0.3 };
                                                                      }
                                                                    }
                                                                    {
                                                                      let $t47379;
                                                                      {
                                                                        const $t47376 = ({ x: 328., y: 478. });
                                                                        {
                                                                          const $t47377 = ({ x: 270., y: 595. });
                                                                          {
                                                                            const $t47378 = { $: "Sling" };
                                                                            $t47379 = { $: "Face", _0: $t47376, _1: $t47377, _2: 520., _3: $t47378 };
                                                                          }
                                                                        }
                                                                      }
                                                                      {
                                                                        let $t47382;
                                                                        {
                                                                          const $t47380 = ({ x: 328., y: 478. });
                                                                          {
                                                                            const $t47381 = ({ x: 328., y: 547. });
                                                                            $t47382 = { $: "Wall", _0: $t47380, _1: $t47381, _2: 0.3 };
                                                                          }
                                                                        }
                                                                        {
                                                                          let $t47385;
                                                                          {
                                                                            const $t47383 = ({ x: 328., y: 547. });
                                                                            {
                                                                              const $t47384 = ({ x: 270., y: 595. });
                                                                              $t47385 = { $: "Wall", _0: $t47383, _1: $t47384, _2: 0.3 };
                                                                            }
                                                                          }
                                                                          {
                                                                            const $t47386 = { $: "Nil" };
                                                                            {
                                                                              const $t47387 = { $: "Cons", _0: $t47385, _1: $t47386 };
                                                                              {
                                                                                const $t47388 = { $: "Cons", _0: $t47382, _1: $t47387 };
                                                                                {
                                                                                  const $t47389 = { $: "Cons", _0: $t47379, _1: $t47388 };
                                                                                  {
                                                                                    const $t47390 = { $: "Cons", _0: $t47375, _1: $t47389 };
                                                                                    {
                                                                                      const $t47391 = { $: "Cons", _0: $t47372, _1: $t47390 };
                                                                                      {
                                                                                        const $t47392 = { $: "Cons", _0: $t47369, _1: $t47391 };
                                                                                        {
                                                                                          const $t47393 = { $: "Cons", _0: $t47365, _1: $t47392 };
                                                                                          {
                                                                                            const $t47394 = { $: "Cons", _0: $t47360, _1: $t47393 };
                                                                                            {
                                                                                              const $t47395 = { $: "Cons", _0: $t47355, _1: $t47394 };
                                                                                              {
                                                                                                const $t47396 = { $: "Cons", _0: $t47350, _1: $t47395 };
                                                                                                {
                                                                                                  const $t47397 = { $: "Cons", _0: $t47345, _1: $t47396 };
                                                                                                  {
                                                                                                    const $t47398 = { $: "Cons", _0: $t47340, _1: $t47397 };
                                                                                                    {
                                                                                                      const $t47399 = { $: "Cons", _0: $t47337, _1: $t47398 };
                                                                                                      {
                                                                                                        const $t47400 = { $: "Cons", _0: $t47334, _1: $t47399 };
                                                                                                        {
                                                                                                          const $t47401 = { $: "Cons", _0: $t47331, _1: $t47400 };
                                                                                                          {
                                                                                                            const $t47402 = { $: "Cons", _0: $t47328, _1: $t47401 };
                                                                                                            {
                                                                                                              const $t47403 = { $: "Cons", _0: $t47325, _1: $t47402 };
                                                                                                              {
                                                                                                                const $t47404 = { $: "Cons", _0: $t47322, _1: $t47403 };
                                                                                                                {
                                                                                                                  const $t47405 = { $: "Cons", _0: $t47319, _1: $t47404 };
                                                                                                                  {
                                                                                                                    const $t47406 = { $: "Cons", _0: $t47316, _1: $t47405 };
                                                                                                                    {
                                                                                                                      const $t47407 = { $: "Cons", _0: $t47313, _1: $t47406 };
                                                                                                                      {
                                                                                                                        const $t47408 = { $: "Cons", _0: $t47310, _1: $t47407 };
                                                                                                                        {
                                                                                                                          const $t47409 = { $: "Cons", _0: $t47306, _1: $t47408 };
                                                                                                                          {
                                                                                                                            const $t47410 = { $: "Cons", _0: $t47304, _1: $t47409 };
                                                                                                                            {
                                                                                                                              const $t47411 = { $: "Cons", _0: $t47302, _1: $t47410 };
                                                                                                                              {
                                                                                                                                const $t47412 = { $: "Cons", _0: $t47299, _1: $t47411 };
                                                                                                                                {
                                                                                                                                  const $t47413 = { $: "Cons", _0: $t47297, _1: $t47412 };
                                                                                                                                  {
                                                                                                                                    const $t47414 = { $: "Cons", _0: $t47295, _1: $t47413 };
                                                                                                                                    {
                                                                                                                                      const $t47415 = { $: "Cons", _0: $t47292, _1: $t47414 };
                                                                                                                                      {
                                                                                                                                        const $t47416 = { $: "Cons", _0: $t47289, _1: $t47415 };
                                                                                                                                        {
                                                                                                                                          const $t47417 = { $: "Cons", _0: $t47286, _1: $t47416 };
                                                                                                                                          {
                                                                                                                                            const $t47418 = { $: "Cons", _0: $t47283, _1: $t47417 };
                                                                                                                                            {
                                                                                                                                              const $t47419 = { $: "Cons", _0: $t47280, _1: $t47418 };
                                                                                                                                              {
                                                                                                                                                const $t47420 = { $: "Cons", _0: $t47277, _1: $t47419 };
                                                                                                                                                {
                                                                                                                                                  const $t47421 = { $: "Cons", _0: $t47274, _1: $t47420 };
                                                                                                                                                  {
                                                                                                                                                    const $t47422 = { $: "Nil" };
                                                                                                                                                    {
                                                                                                                                                      const $t47423 = { $: "Cons", _0: $t47421, _1: $t47422 };
                                                                                                                                                      {
                                                                                                                                                        const $t47424 = { $: "Cons", _0: $t47271, _1: $t47423 };
                                                                                                                                                        {
                                                                                                                                                          const prepend_reversed_i5434 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Part", _0: prepend_reversed$apply$0_List_concat_List_List_Part };
                                                                                                                                                          {
                                                                                                                                                            const go_i5435 = { $: "$Clo_go$1_List_concat_List_List_Part", _0: go$apply$1_List_concat_List_List_Part, _1: prepend_reversed_i5434 };
                                                                                                                                                            {
                                                                                                                                                              const $t1113_i5436 = { $: "Nil" };
                                                                                                                                                              return go$apply$1_List_concat_List_List_Part(go_i5435, $t47424, $t1113_i5436);
                                                                                                                                                            }
                                                                                                                                                          }
                                                                                                                                                        }
                                                                                                                                                      }
                                                                                                                                                    }
                                                                                                                                                  }
                                                                                                                                                }
                                                                                                                                              }
                                                                                                                                            }
                                                                                                                                          }
                                                                                                                                        }
                                                                                                                                      }
                                                                                                                                    }
                                                                                                                                  }
                                                                                                                                }
                                                                                                                              }
                                                                                                                            }
                                                                                                                          }
                                                                                                                        }
                                                                                                                      }
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
    const $t47437 = f.pivot;
    {
      let $t47442;
      {
        let $t47440;
        {
          const $t47438 = Math.cos(a);
          {
            const $t47439 = Math.sin(a);
            $t47440 = ({ x: $t47438, y: $t47439 });
          }
        }
        {
          const $t47441 = f.length;
          $t47442 = Arcade$Vec2$scale($t47440, $t47441);
        }
      }
      return Arcade$Vec2$add($t47437, $t47442);
    }
  }
}
const Spin$Table$tip$clo = { _0: ($_, f, a) => Spin$Table$tip(f, a) };

function Spin$Table$in_lane(p) {
  {
    let $t47444;
    {
      const $t47443 = p.x;
      $t47444 = ($t47443 > 350.);
    }
    {
      let $t47446;
      {
        const $t47445 = p.y;
        $t47446 = ($t47445 > 262.);
      }
      return ($t47444 && $t47446);
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
        let $t47471;
        {
          let $t47464;
          {
            let $t47461;
            {
              const $t47460 = (6. * k);
              $t47461 = (cx - $t47460);
            }
            {
              let $t47463;
              {
                const $t47462 = (2. * k);
                $t47463 = (cy + $t47462);
              }
              $t47464 = ({ x: $t47461, y: $t47463 });
            }
          }
          {
            let $t47469;
            {
              let $t47466;
              {
                const $t47465 = (2. * k);
                $t47466 = (cx + $t47465);
              }
              {
                let $t47468;
                {
                  const $t47467 = (10. * k);
                  $t47468 = (cy - $t47467);
                }
                $t47469 = ({ x: $t47466, y: $t47468 });
              }
            }
            {
              const $t47470 = (2. * k);
              $t47471 = Spin$Draw$stick($t47464, $t47469, $t47470, "#3fbf4f");
            }
          }
        }
        {
          let $t47483;
          {
            let $t47476;
            {
              let $t47473;
              {
                const $t47472 = (6. * k);
                $t47473 = (cx + $t47472);
              }
              {
                const $t47475 = (cy + k);
                $t47476 = ({ x: $t47473, y: $t47475 });
              }
            }
            {
              let $t47481;
              {
                let $t47478;
                {
                  const $t47477 = (2. * k);
                  $t47478 = (cx + $t47477);
                }
                {
                  let $t47480;
                  {
                    const $t47479 = (10. * k);
                    $t47480 = (cy - $t47479);
                  }
                  $t47481 = ({ x: $t47478, y: $t47480 });
                }
              }
              {
                const $t47482 = (2. * k);
                $t47483 = Spin$Draw$stick($t47476, $t47481, $t47482, "#3fbf4f");
              }
            }
          }
          {
            let $t47490;
            {
              let $t47485;
              {
                const $t47484 = (6. * k);
                $t47485 = (cx - $t47484);
              }
              {
                let $t47487;
                {
                  const $t47486 = (5. * k);
                  $t47487 = (cy + $t47486);
                }
                {
                  const $t47488 = (6.5 * k);
                  {
                    const $t47489 = Spin$View$colour(s);
                    $t47490 = { $: "Disc", _0: $t47485, _1: $t47487, _2: $t47488, _3: $t47489 };
                  }
                }
              }
            }
            {
              let $t47497;
              {
                let $t47492;
                {
                  const $t47491 = (6. * k);
                  $t47492 = (cx + $t47491);
                }
                {
                  let $t47494;
                  {
                    const $t47493 = (4. * k);
                    $t47494 = (cy + $t47493);
                  }
                  {
                    const $t47495 = (6.5 * k);
                    {
                      const $t47496 = Spin$View$colour(s);
                      $t47497 = { $: "Disc", _0: $t47492, _1: $t47494, _2: $t47495, _3: $t47496 };
                    }
                  }
                }
              }
              {
                let $t47503;
                {
                  let $t47499;
                  {
                    const $t47498 = (8. * k);
                    $t47499 = (cx - $t47498);
                  }
                  {
                    let $t47501;
                    {
                      const $t47500 = (3. * k);
                      $t47501 = (cy + $t47500);
                    }
                    {
                      const $t47502 = (1.8 * k);
                      $t47503 = { $: "Disc", _0: $t47499, _1: $t47501, _2: $t47502, _3: "#ffd0d6" };
                    }
                  }
                }
                {
                  const $t47504 = { $: "Nil" };
                  {
                    const $t47505 = { $: "Cons", _0: $t47503, _1: $t47504 };
                    {
                      const $t47506 = { $: "Cons", _0: $t47497, _1: $t47505 };
                      {
                        const $t47507 = { $: "Cons", _0: $t47490, _1: $t47506 };
                        {
                          const $t47508 = { $: "Cons", _0: $t47483, _1: $t47507 };
                          return { $: "Cons", _0: $t47471, _1: $t47508 };
                        }
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
        let $t47513;
        {
          const $t47509 = (12. * k);
          {
            const $t47510 = (8.5 * k);
            {
              let $t47511;
              {
                let $t47448_i5604;
                {
                  const go_i14327 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                  {
                    const $t915_i14328 = ((12 - 1) < 4611686018427387904 && (12 - 1) >= -4611686018427387904 ? (12 - 1) : march_int_ovf((12 - 1), 1));
                    {
                      const $t916_i14329 = { $: "Nil" };
                      $t47448_i5604 = go$apply$0_List_range(go_i14327, $t915_i14328, $t916_i14329);
                    }
                  }
                }
                {
                  const $t47459_i5605 = { $: "$Clo_$lam0_Spin_View_ellipse$0_Spin_View_ellipse", _0: $lam0_Spin_View_ellipse$apply$0_Spin_View_ellipse, _1: cx, _2: cy, _3: n, _4: $t47509, _5: $t47510 };
                  {
                    const xs_i14429 = $t47448_i5604;
                    {
                      const f_i14430 = $t47459_i5605;
                      switch (xs_i14429.$) {
                        case "Nil": {
                          $t47511 = { $: "Nil" };
                          break;
                        }
                        case "Cons": {
                          const $f995_i14431 = xs_i14429._0;
                          const $f996_i14432 = xs_i14429._1;
                          {
                            const t_i14433 = $f996_i14432;
                            {
                              const h_i14434 = $f995_i14431;
                              {
                                let $t993_i14435;
                                $t993_i14435 = f_i14430._0(f_i14430, h_i14434);
                                {
                                  const $trmc15_i14436 = { $: "Cons", _0: $t993_i14435, _1: null };
                                  List$map$dps$List_Int$Fn_Int_R_x_Float_y_Float$List_R_x_Float_y_Float(t_i14433, f_i14430, $trmc15_i14436);
                                  $t47511 = $trmc15_i14436;
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
                const $t47512 = Spin$View$colour(s);
                $t47513 = { $: "Poly", _0: $t47511, _1: $t47512 };
              }
            }
          }
        }
        {
          let $t47519;
          {
            let $t47515;
            {
              const $t47514 = (4. * k);
              $t47515 = (cx - $t47514);
            }
            {
              let $t47517;
              {
                const $t47516 = (3. * k);
                $t47517 = (cy - $t47516);
              }
              {
                const $t47518 = (2. * k);
                $t47519 = { $: "Disc", _0: $t47515, _1: $t47517, _2: $t47518, _3: "#fff7c2" };
              }
            }
          }
          {
            const $t47520 = { $: "Nil" };
            {
              const $t47521 = { $: "Cons", _0: $t47519, _1: $t47520 };
              return { $: "Cons", _0: $t47513, _1: $t47521 };
            }
          }
        }
      }
      break;
    }
    case "Bell": {
      {
        let $t47560;
        {
          let $t47526;
          {
            let $t47523;
            {
              const $t47522 = (11. * k);
              $t47523 = (cx - $t47522);
            }
            {
              let $t47525;
              {
                const $t47524 = (8. * k);
                $t47525 = (cy + $t47524);
              }
              $t47526 = ({ x: $t47523, y: $t47525 });
            }
          }
          {
            let $t47531;
            {
              let $t47528;
              {
                const $t47527 = (8. * k);
                $t47528 = (cx - $t47527);
              }
              {
                const $t47530 = (cy - k);
                $t47531 = ({ x: $t47528, y: $t47530 });
              }
            }
            {
              let $t47536;
              {
                let $t47533;
                {
                  const $t47532 = (5. * k);
                  $t47533 = (cx - $t47532);
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
                    const $t47537 = (5. * k);
                    $t47538 = (cx + $t47537);
                  }
                  {
                    let $t47540;
                    {
                      const $t47539 = (9. * k);
                      $t47540 = (cy - $t47539);
                    }
                    $t47541 = ({ x: $t47538, y: $t47540 });
                  }
                }
                {
                  let $t47546;
                  {
                    let $t47543;
                    {
                      const $t47542 = (8. * k);
                      $t47543 = (cx + $t47542);
                    }
                    {
                      const $t47545 = (cy - k);
                      $t47546 = ({ x: $t47543, y: $t47545 });
                    }
                  }
                  {
                    let $t47551;
                    {
                      let $t47548;
                      {
                        const $t47547 = (11. * k);
                        $t47548 = (cx + $t47547);
                      }
                      {
                        let $t47550;
                        {
                          const $t47549 = (8. * k);
                          $t47550 = (cy + $t47549);
                        }
                        $t47551 = ({ x: $t47548, y: $t47550 });
                      }
                    }
                    {
                      const $t47552 = { $: "Nil" };
                      {
                        const $t47553 = { $: "Cons", _0: $t47551, _1: $t47552 };
                        {
                          const $t47554 = { $: "Cons", _0: $t47546, _1: $t47553 };
                          {
                            const $t47555 = { $: "Cons", _0: $t47541, _1: $t47554 };
                            {
                              const $t47556 = { $: "Cons", _0: $t47536, _1: $t47555 };
                              {
                                const $t47557 = { $: "Cons", _0: $t47531, _1: $t47556 };
                                {
                                  const $t47558 = { $: "Cons", _0: $t47526, _1: $t47557 };
                                  {
                                    const $t47559 = Spin$View$colour(s);
                                    $t47560 = { $: "Poly", _0: $t47558, _1: $t47559 };
                                  }
                                }
                              }
                            }
                          }
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
          let $t47564;
          {
            let $t47562;
            {
              const $t47561 = (9. * k);
              $t47562 = (cy + $t47561);
            }
            {
              const $t47563 = (3. * k);
              $t47564 = { $: "Disc", _0: cx, _1: $t47562, _2: $t47563, _3: "#c47a00" };
            }
          }
          {
            let $t47568;
            {
              let $t47566;
              {
                const $t47565 = (11. * k);
                $t47566 = (cy - $t47565);
              }
              {
                const $t47567 = (2. * k);
                $t47568 = { $: "Disc", _0: cx, _1: $t47566, _2: $t47567, _3: "#c47a00" };
              }
            }
            {
              const $t47569 = { $: "Nil" };
              {
                const $t47570 = { $: "Cons", _0: $t47568, _1: $t47569 };
                {
                  const $t47571 = { $: "Cons", _0: $t47564, _1: $t47570 };
                  return { $: "Cons", _0: $t47560, _1: $t47571 };
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
        let $t47578;
        {
          let $t47573;
          {
            const $t47572 = (17. * k);
            $t47573 = (cx - $t47572);
          }
          {
            let $t47575;
            {
              const $t47574 = (7.5 * k);
              $t47575 = (cy - $t47574);
            }
            {
              const $t47576 = (34. * k);
              {
                const $t47577 = (15. * k);
                $t47578 = { $: "Box", _0: $t47573, _1: $t47575, _2: $t47576, _3: $t47577, _4: "#1b1b24" };
              }
            }
          }
        }
        {
          let $t47583;
          {
            let $t47580;
            {
              const $t47579 = (0.5 * k);
              $t47580 = (cy + $t47579);
            }
            {
              const $t47581 = (10. * k);
              {
                const $t47582 = Spin$View$colour(s);
                $t47583 = { $: "Label", _0: "BAR", _1: cx, _2: $t47580, _3: $t47581, _4: $t47582 };
              }
            }
          }
          {
            const $t47584 = { $: "Nil" };
            {
              const $t47585 = { $: "Cons", _0: $t47583, _1: $t47584 };
              return { $: "Cons", _0: $t47578, _1: $t47585 };
            }
          }
        }
      }
      break;
    }
    case "Seven": {
      {
        let $t47591;
        {
          const $t47587 = (cx + k);
          {
            let $t47589;
            {
              const $t47588 = (1.5 * k);
              $t47589 = (cy + $t47588);
            }
            {
              const $t47590 = (28. * k);
              $t47591 = { $: "Label", _0: "7", _1: $t47587, _2: $t47589, _3: $t47590, _4: "#5a0018" };
            }
          }
        }
        {
          let $t47594;
          {
            const $t47592 = (28. * k);
            {
              const $t47593 = Spin$View$colour(s);
              $t47594 = { $: "Label", _0: "7", _1: cx, _2: cy, _3: $t47592, _4: $t47593 };
            }
          }
          {
            const $t47595 = { $: "Nil" };
            {
              const $t47596 = { $: "Cons", _0: $t47594, _1: $t47595 };
              return { $: "Cons", _0: $t47591, _1: $t47596 };
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
    let $p47666;
    {
      const $t47597 = m.table;
      $p47666 = $t47597.reel_window;
    }
    {
      const wx = $p47666._0;
      {
        const wy = $p47666._1;
        {
          const wh = $p47666._3;
          {
            let r;
            {
              const $t47598 = m.bank;
              r = Spin$Reels$reel_at($t47598, i);
            }
            {
              let x0;
              {
                let $t47600;
                {
                  const $t47599 = i;
                  $t47600 = (60. * $t47599);
                }
                x0 = (wx + $t47600);
              }
              {
                let line_y;
                {
                  const $t47601 = (wh / 2.);
                  line_y = (wy + $t47601);
                }
                {
                  let shown;
                  shown = Spin$Reels$shown(r);
                  {
                    const base = Math.floor(shown);
                    {
                      let frac;
                      {
                        const $t47602 = base;
                        frac = (shown - $t47602);
                      }
                      {
                        const $t47603 = march_int_ovf(-(2), 3);
                        {
                          let $t47604;
                          {
                            const go_i5660 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: $t47603 };
                            {
                              const $t915_i5661 = ((3 - 1) < 4611686018427387904 && (3 - 1) >= -4611686018427387904 ? (3 - 1) : march_int_ovf((3 - 1), 1));
                              {
                                const $t916_i5662 = { $: "Nil" };
                                $t47604 = go$apply$0_List_range(go_i5660, $t915_i5661, $t916_i5662);
                              }
                            }
                          }
                          {
                            let $t47624;
                            $t47624 = { $: "$Clo_$lam0_Spin_View_reel_ops$0_Spin_View_reel_ops", _0: $lam0_Spin_View_reel_ops$apply$0_Spin_View_reel_ops, _1: base, _2: frac, _3: line_y, _4: m, _5: r, _6: x0 };
                            {
                              const $t47625 = List$map$List_Int$Fn_Int_List_Op($t47604, $t47624);
                              {
                                let cells;
                                {
                                  const prepend_reversed_i5655 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                  {
                                    const go_i5656 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5655 };
                                    {
                                      const $t1113_i5657 = { $: "Nil" };
                                      cells = go$apply$1_List_concat_List_List_Op(go_i5656, $t47625, $t1113_i5657);
                                    }
                                  }
                                }
                                {
                                  const $t47626 = r.held;
                                  {
                                    let held;
                                    if ($t47626 === true) {
                                      {
                                        let $t47630;
                                        {
                                          const $t47627 = (x0 + 2.);
                                          {
                                            let $t47629;
                                            {
                                              const $t47628 = (wy + wh);
                                              $t47629 = ($t47628 - 14.);
                                            }
                                            $t47630 = { $: "Box", _0: $t47627, _1: $t47629, _2: 56., _3: 12., _4: "rgba(40,200,90,0.85)" };
                                          }
                                        }
                                        {
                                          let $t47634;
                                          {
                                            const $t47631 = (x0 + 30.);
                                            {
                                              let $t47633;
                                              {
                                                const $t47632 = (wy + wh);
                                                $t47633 = ($t47632 - 8.);
                                              }
                                              $t47634 = { $: "Label", _0: "HELD", _1: $t47631, _2: $t47633, _3: 9., _4: "#eaffea" };
                                            }
                                          }
                                          {
                                            const $t47635 = { $: "Nil" };
                                            {
                                              const $t47636 = { $: "Cons", _0: $t47634, _1: $t47635 };
                                              held = { $: "Cons", _0: $t47630, _1: $t47636 };
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      held = { $: "Nil" };
                                    }
                                    {
                                      const $t47637 = { $: "ClipBox", _0: x0, _1: wy, _2: 60., _3: wh };
                                      {
                                        const $t47638 = { $: "Box", _0: x0, _1: wy, _2: 60., _3: wh, _4: "#f6f0e2" };
                                        {
                                          const $t47639 = { $: "Nil" };
                                          {
                                            const $t47640 = { $: "Cons", _0: $t47638, _1: $t47639 };
                                            {
                                              const $t47641 = { $: "Cons", _0: $t47637, _1: $t47640 };
                                              {
                                                const $t47642 = { $: "Box", _0: x0, _1: wy, _2: 60., _3: 14., _4: "rgba(0,0,0,0.22)" };
                                                {
                                                  let $t47645;
                                                  {
                                                    let $t47644;
                                                    {
                                                      const $t47643 = (wy + wh);
                                                      $t47644 = ($t47643 - 14.);
                                                    }
                                                    $t47645 = { $: "Box", _0: x0, _1: $t47644, _2: 60., _3: 14., _4: "rgba(0,0,0,0.22)" };
                                                  }
                                                  {
                                                    const $t47646 = { $: "Nil" };
                                                    {
                                                      const $t47647 = { $: "Cons", _0: $t47645, _1: $t47646 };
                                                      {
                                                        const $t47648 = { $: "Cons", _0: $t47642, _1: $t47647 };
                                                        {
                                                          const $t47649 = { $: "Unclip" };
                                                          {
                                                            const $t47650 = { $: "Nil" };
                                                            {
                                                              const $t47651 = { $: "Cons", _0: $t47649, _1: $t47650 };
                                                              {
                                                                const $t47652 = (i > 0);
                                                                {
                                                                  let $t47658;
                                                                  if ($t47652 === true) {
                                                                    {
                                                                      let $t47656;
                                                                      {
                                                                        const $t47653 = ({ x: x0, y: wy });
                                                                        {
                                                                          let $t47655;
                                                                          {
                                                                            const $t47654 = (wy + wh);
                                                                            $t47655 = ({ x: x0, y: $t47654 });
                                                                          }
                                                                          $t47656 = Spin$Draw$stick($t47653, $t47655, 2., "#3a2350");
                                                                        }
                                                                      }
                                                                      {
                                                                        const $t47657 = { $: "Nil" };
                                                                        $t47658 = { $: "Cons", _0: $t47656, _1: $t47657 };
                                                                      }
                                                                    }
                                                                  } else {
                                                                    $t47658 = { $: "Nil" };
                                                                  }
                                                                  {
                                                                    const $t47659 = { $: "Nil" };
                                                                    {
                                                                      const $t47660 = { $: "Cons", _0: $t47658, _1: $t47659 };
                                                                      {
                                                                        const $t47661 = { $: "Cons", _0: $t47651, _1: $t47660 };
                                                                        {
                                                                          const $t47662 = { $: "Cons", _0: held, _1: $t47661 };
                                                                          {
                                                                            const $t47663 = { $: "Cons", _0: $t47648, _1: $t47662 };
                                                                            {
                                                                              const $t47664 = { $: "Cons", _0: cells, _1: $t47663 };
                                                                              {
                                                                                const $t47665 = { $: "Cons", _0: $t47641, _1: $t47664 };
                                                                                {
                                                                                  const prepend_reversed_i5642 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                                                  {
                                                                                    const go_i5643 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5642 };
                                                                                    {
                                                                                      const $t1113_i5644 = { $: "Nil" };
                                                                                      return go$apply$1_List_concat_List_List_Op(go_i5643, $t47665, $t1113_i5644);
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
    let $p47696;
    {
      const $t47667 = m.table;
      $p47696 = $t47667.reel_window;
    }
    {
      const wx = $p47696._0;
      {
        const wy = $p47696._1;
        {
          let cx;
          {
            const $t47668 = (wx + 30.);
            {
              let $t47672;
              {
                let $t47671;
                {
                  let $t47670;
                  {
                    const $t47669 = m.bank;
                    $t47670 = $t47669.armed;
                  }
                  $t47671 = $t47670;
                }
                $t47672 = (60. * $t47671);
              }
              cx = ($t47668 + $t47672);
            }
          }
          {
            let pulse;
            {
              let $t47676;
              {
                let $t47675;
                {
                  let $t47674;
                  {
                    const $t47673 = m.clock;
                    $t47674 = ($t47673 * 6.);
                  }
                  $t47675 = Math.sin($t47674);
                }
                $t47676 = (0.4 * $t47675);
              }
              pulse = (0.6 + $t47676);
            }
            {
              let $t47690;
              {
                let $t47679;
                {
                  const $t47677 = (cx - 7.);
                  {
                    const $t47678 = (wy - 16.);
                    $t47679 = ({ x: $t47677, y: $t47678 });
                  }
                }
                {
                  let $t47682;
                  {
                    const $t47680 = (cx + 7.);
                    {
                      const $t47681 = (wy - 16.);
                      $t47682 = ({ x: $t47680, y: $t47681 });
                    }
                  }
                  {
                    let $t47684;
                    {
                      const $t47683 = (wy - 7.);
                      $t47684 = ({ x: cx, y: $t47683 });
                    }
                    {
                      const $t47685 = { $: "Nil" };
                      {
                        const $t47686 = { $: "Cons", _0: $t47684, _1: $t47685 };
                        {
                          const $t47687 = { $: "Cons", _0: $t47682, _1: $t47686 };
                          {
                            const $t47688 = { $: "Cons", _0: $t47679, _1: $t47687 };
                            {
                              const $t47689 = Spin$Draw$rgba(124, 255, 122, pulse);
                              $t47690 = { $: "Poly", _0: $t47688, _1: $t47689 };
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              {
                let $t47693;
                {
                  const $t47691 = (wy - 24.);
                  {
                    const $t47692 = Spin$Draw$rgba(124, 255, 122, pulse);
                    $t47693 = { $: "Label", _0: "LOAD", _1: cx, _2: $t47691, _3: 8., _4: $t47692 };
                  }
                }
                {
                  const $t47694 = { $: "Nil" };
                  {
                    const $t47695 = { $: "Cons", _0: $t47693, _1: $t47694 };
                    return { $: "Cons", _0: $t47690, _1: $t47695 };
                  }
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
    let $p47783;
    {
      const $t47697 = m.table;
      $p47783 = $t47697.reel_window;
    }
    {
      const wx = $p47783._0;
      {
        const wy = $p47783._1;
        {
          const ww = $p47783._2;
          {
            const wh = $p47783._3;
            {
              const b = m.bank;
              {
                let line_y;
                {
                  const $t47698 = (wh / 2.);
                  line_y = (wy + $t47698);
                }
                {
                  let $t47700;
                  {
                    const go_i5700 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
                    {
                      const $t915_i5701 = ((5 - 1) < 4611686018427387904 && (5 - 1) >= -4611686018427387904 ? (5 - 1) : march_int_ovf((5 - 1), 1));
                      {
                        const $t916_i5702 = { $: "Nil" };
                        $t47700 = go$apply$0_List_range(go_i5700, $t915_i5701, $t916_i5702);
                      }
                    }
                  }
                  {
                    let $t47713;
                    $t47713 = { $: "$Clo_$lam0_Spin_View_machine_ops$0_Spin_View_machine_ops", _0: $lam0_Spin_View_machine_ops$apply$0_Spin_View_machine_ops, _1: b, _2: wh, _3: ww, _4: wx, _5: wy };
                    {
                      const spins = List$map$List_Int$Fn_Int_Op($t47700, $t47713);
                      {
                        let $t47715;
                        {
                          const $t47714 = b.nudge_left;
                          $t47715 = ($t47714 > 0.);
                        }
                        {
                          let nudge;
                          if ($t47715 === true) {
                            {
                              let f;
                              {
                                const $t47716 = b.nudge_left;
                                f = ($t47716 / 4.);
                              }
                              {
                                let $t47721;
                                {
                                  let $t47719;
                                  {
                                    const $t47718 = (wy + wh);
                                    $t47719 = ($t47718 + 26.);
                                  }
                                  {
                                    const $t47720 = (ww * f);
                                    $t47721 = { $: "Box", _0: wx, _1: $t47719, _2: $t47720, _3: 5., _4: "#ff3fa4" };
                                  }
                                }
                                {
                                  let $t47726;
                                  {
                                    let $t47723;
                                    {
                                      const $t47722 = (ww / 2.);
                                      $t47723 = (wx + $t47722);
                                    }
                                    {
                                      let $t47725;
                                      {
                                        const $t47724 = (wy + wh);
                                        $t47725 = ($t47724 + 40.);
                                      }
                                      $t47726 = { $: "Label", _0: "NUDGE", _1: $t47723, _2: $t47725, _3: 10., _4: "#ff8fcf" };
                                    }
                                  }
                                  {
                                    const $t47727 = { $: "Nil" };
                                    {
                                      const $t47728 = { $: "Cons", _0: $t47726, _1: $t47727 };
                                      nudge = { $: "Cons", _0: $t47721, _1: $t47728 };
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            nudge = { $: "Nil" };
                          }
                          {
                            let $t47730;
                            {
                              const $t47729 = b.boost;
                              $t47730 = ($t47729 > 1);
                            }
                            {
                              let boost;
                              if ($t47730 === true) {
                                {
                                  let $t47737;
                                  {
                                    let $t47733;
                                    {
                                      let $t47732;
                                      {
                                        const $t47731 = b.boost;
                                        $t47732 = String($t47731);
                                      }
                                      {
                                        const $rc_2693 = ("x" + $t47732);
                                        $t47733 = $rc_2693;
                                      }
                                    }
                                    {
                                      let $t47735;
                                      {
                                        const $t47734 = (wx + ww);
                                        $t47735 = ($t47734 + 18.);
                                      }
                                      $t47737 = { $: "Label", _0: $t47733, _1: $t47735, _2: line_y, _3: 16., _4: "#ffd36b" };
                                    }
                                  }
                                  {
                                    const $t47738 = { $: "Nil" };
                                    {
                                      const $rc_2695 = { $: "Cons", _0: $t47737, _1: $t47738 };
                                      boost = $rc_2695;
                                    }
                                  }
                                }
                              } else {
                                boost = { $: "Nil" };
                              }
                              {
                                let $t47743;
                                {
                                  const $t47739 = (wx - 8.);
                                  {
                                    const $t47740 = (wy - 8.);
                                    {
                                      const $t47741 = (ww + 16.);
                                      {
                                        const $t47742 = (wh + 16.);
                                        $t47743 = { $: "Box", _0: $t47739, _1: $t47740, _2: $t47741, _3: $t47742, _4: "#2b1645" };
                                      }
                                    }
                                  }
                                }
                                {
                                  let $t47749;
                                  {
                                    const $t47744 = (wx - 4.);
                                    {
                                      const $t47745 = (wy - 4.);
                                      {
                                        const $t47746 = (ww + 8.);
                                        {
                                          const $t47747 = (wh + 8.);
                                          $t47749 = { $: "Box", _0: $t47744, _1: $t47745, _2: $t47746, _3: $t47747, _4: "#ffd36b" };
                                        }
                                      }
                                    }
                                  }
                                  {
                                    const $t47750 = { $: "Nil" };
                                    {
                                      const $t47751 = { $: "Cons", _0: $t47749, _1: $t47750 };
                                      {
                                        const $t47752 = { $: "Cons", _0: $t47743, _1: $t47751 };
                                        {
                                          const $t47753 = { $: "Nil" };
                                          {
                                            const $t47754 = { $: "Cons", _0: 2, _1: $t47753 };
                                            {
                                              const $t47755 = { $: "Cons", _0: 1, _1: $t47754 };
                                              {
                                                const $t47756 = { $: "Cons", _0: 0, _1: $t47755 };
                                                {
                                                  let $t47758;
                                                  $t47758 = { $: "$Clo_$lam1_Spin_View_machine_ops$1_Spin_View_machine_ops", _0: $lam1_Spin_View_machine_ops$apply$1_Spin_View_machine_ops, _1: m };
                                                  {
                                                    const $t47759 = List$map$List_Int$Fn_Int_List_Op($t47756, $t47758);
                                                    {
                                                      let $t47760;
                                                      {
                                                        const prepend_reversed_i5685 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                        {
                                                          const go_i5686 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5685 };
                                                          {
                                                            const $t1113_i5687 = { $: "Nil" };
                                                            $t47760 = go$apply$1_List_concat_List_List_Op(go_i5686, $t47759, $t1113_i5687);
                                                          }
                                                        }
                                                      }
                                                      {
                                                        let $t47764;
                                                        {
                                                          const $t47761 = (wx - 6.);
                                                          {
                                                            let $t47763;
                                                            {
                                                              const $t47762 = (wx + ww);
                                                              $t47763 = ($t47762 + 6.);
                                                            }
                                                            $t47764 = { $: "Line", _0: $t47761, _1: line_y, _2: $t47763, _3: line_y, _4: 2., _5: "rgba(255,40,80,0.75)" };
                                                          }
                                                        }
                                                        {
                                                          const $t47765 = { $: "Nil" };
                                                          {
                                                            const $t47766 = { $: "Cons", _0: $t47764, _1: $t47765 };
                                                            {
                                                              const $t47767 = Spin$View$armed_ops(m);
                                                              {
                                                                let $t47771;
                                                                {
                                                                  const $t47768 = (wx - 22.);
                                                                  {
                                                                    let $t47770;
                                                                    {
                                                                      const $t47769 = (wy + wh);
                                                                      $t47770 = ($t47769 + 14.);
                                                                    }
                                                                    $t47771 = { $: "Label", _0: "SPINS", _1: $t47768, _2: $t47770, _3: 8., _4: "#5cf2ff" };
                                                                  }
                                                                }
                                                                {
                                                                  const $t47772 = { $: "Nil" };
                                                                  {
                                                                    const $t47773 = { $: "Cons", _0: $t47771, _1: $t47772 };
                                                                    {
                                                                      const $t47774 = { $: "Nil" };
                                                                      {
                                                                        const $t47775 = { $: "Cons", _0: $t47773, _1: $t47774 };
                                                                        {
                                                                          const $t47776 = { $: "Cons", _0: boost, _1: $t47775 };
                                                                          {
                                                                            const $t47777 = { $: "Cons", _0: nudge, _1: $t47776 };
                                                                            {
                                                                              const $t47778 = { $: "Cons", _0: spins, _1: $t47777 };
                                                                              {
                                                                                const $t47779 = { $: "Cons", _0: $t47767, _1: $t47778 };
                                                                                {
                                                                                  const $t47780 = { $: "Cons", _0: $t47766, _1: $t47779 };
                                                                                  {
                                                                                    const $t47781 = { $: "Cons", _0: $t47760, _1: $t47780 };
                                                                                    {
                                                                                      const $t47782 = { $: "Cons", _0: $t47752, _1: $t47781 };
                                                                                      {
                                                                                        const prepend_reversed_i5676 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                                                        {
                                                                                          const go_i5677 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5676 };
                                                                                          {
                                                                                            const $t1113_i5678 = { $: "Nil" };
                                                                                            return go$apply$1_List_concat_List_List_Op(go_i5677, $t47782, $t1113_i5678);
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
      const $f47927 = p._0;
      const $f47928 = p._1;
      const $f47929 = p._2;
      {
        const b = $f47928;
        {
          const a = $f47927;
          {
            const $t47791 = Spin$Draw$stick(a, b, 4., "#b9a6ff");
            {
              const $t47792 = { $: "Nil" };
              return { $: "Cons", _0: $t47791, _1: $t47792 };
            }
          }
        }
      }
      break;
    }
    case "Peg": {
      const $f47938 = p._0;
      const $f47939 = p._1;
      const $f47940 = p._2;
      {
        const r = $f47939;
        {
          const c = $f47938;
          {
            let $t47797;
            {
              const $t47793 = c.x;
              {
                const $t47794 = c.y;
                {
                  const $t47795 = (r + 1.);
                  $t47797 = { $: "Disc", _0: $t47793, _1: $t47794, _2: $t47795, _3: "#b9a6ff" };
                }
              }
            }
            {
              const $t47798 = { $: "Nil" };
              {
                const $rc_2699 = { $: "Cons", _0: $t47797, _1: $t47798 };
                return $rc_2699;
              }
            }
          }
        }
      }
      break;
    }
    case "Gate": {
      const $f47949 = p._0;
      const $f47950 = p._1;
      {
        const b = $f47950;
        {
          const a = $f47949;
          {
            const $t47799 = Spin$Draw$stick(a, b, 2., "#7a6aa8");
            {
              const $t47800 = { $: "Nil" };
              return { $: "Cons", _0: $t47799, _1: $t47800 };
            }
          }
        }
      }
      break;
    }
    case "Kicker": {
      const $f47955 = p._0;
      const $f47956 = p._1;
      const $f47957 = p._2;
      {
        const f = $f47957;
        {
          const r = $f47956;
          {
            const c = $f47955;
            {
              const glow = Spin$Game$light(m, f);
              {
                const $t47801 = (glow > 0.);
                {
                  let $t47808;
                  if ($t47801 === true) {
                    {
                      let $t47806;
                      {
                        const $t47802 = c.x;
                        {
                          const $t47803 = c.y;
                          {
                            const $t47804 = (r * 2.4);
                            {
                              const $t47805 = Spin$Draw$rgba(255, 63, 164, glow);
                              $t47806 = { $: "Glow", _0: $t47802, _1: $t47803, _2: $t47804, _3: $t47805 };
                            }
                          }
                        }
                      }
                      {
                        const $t47807 = { $: "Nil" };
                        $t47808 = { $: "Cons", _0: $t47806, _1: $t47807 };
                      }
                    }
                  } else {
                    $t47808 = { $: "Nil" };
                  }
                  {
                    let $t47811;
                    {
                      const $t47809 = c.x;
                      {
                        const $t47810 = c.y;
                        $t47811 = { $: "Disc", _0: $t47809, _1: $t47810, _2: r, _3: "#2a0f3a" };
                      }
                    }
                    {
                      let $t47815;
                      {
                        const $t47812 = c.x;
                        {
                          const $t47813 = c.y;
                          {
                            const $t47814 = (r - 2.);
                            $t47815 = { $: "Ring", _0: $t47812, _1: $t47813, _2: $t47814, _3: 4., _4: "#ff3fa4" };
                          }
                        }
                      }
                      {
                        let $t47821;
                        {
                          const $t47816 = c.x;
                          {
                            const $t47817 = c.y;
                            {
                              const $t47818 = (r * 0.55);
                              {
                                let $t47820;
                                {
                                  const $t47819 = (glow > 0.);
                                  if ($t47819 === true) {
                                    $t47820 = "#ffe0f2";
                                  } else {
                                    $t47820 = "#ff3fa4";
                                  }
                                }
                                $t47821 = { $: "Disc", _0: $t47816, _1: $t47817, _2: $t47818, _3: $t47820 };
                              }
                            }
                          }
                        }
                        {
                          const $t47822 = { $: "Nil" };
                          {
                            const $t47823 = { $: "Cons", _0: $t47821, _1: $t47822 };
                            {
                              const $t47824 = { $: "Cons", _0: $t47815, _1: $t47823 };
                              {
                                const $t47825 = { $: "Cons", _0: $t47811, _1: $t47824 };
                                {
                                  const $t47826 = { $: "Nil" };
                                  {
                                    const $t47827 = { $: "Cons", _0: $t47825, _1: $t47826 };
                                    {
                                      const $t47828 = { $: "Cons", _0: $t47808, _1: $t47827 };
                                      {
                                        const prepend_reversed_i5708 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                        {
                                          const go_i5709 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5708 };
                                          {
                                            const $t1113_i5710 = { $: "Nil" };
                                            return go$apply$1_List_concat_List_List_Op(go_i5709, $t47828, $t1113_i5710);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
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
      const $f47966 = p._0;
      const $f47967 = p._1;
      const $f47968 = p._2;
      const $f47969 = p._3;
      switch ($f47969.$) {
        case "Sling": {
          {
            const b = $f47967;
            {
              const a = $f47966;
              {
                let $t47832;
                {
                  let $t47831;
                  {
                    const $t47829 = { $: "Sling" };
                    {
                      const dim_i12918 = "#ff6b3d";
                      {
                        const bright_i12919 = "#ffd36b";
                        {
                          let $t47785_i12921;
                          {
                            const $t47784_i12920 = Spin$Game$light(m, $t47829);
                            $t47785_i12921 = ($t47784_i12920 > 0.);
                          }
                          if ($t47785_i12921 === true) {
                            $t47831 = "#ffd36b";
                          } else {
                            $t47831 = "#ff6b3d";
                          }
                        }
                      }
                    }
                  }
                  $t47832 = Spin$Draw$stick(a, b, 6., $t47831);
                }
                {
                  const $t47833 = { $: "Nil" };
                  return { $: "Cons", _0: $t47832, _1: $t47833 };
                }
              }
            }
          }
          break;
        }
        default: {
          switch ($f47969.$) {
            case "Loader": {
              const $f47992 = $f47969._0;
              {
                const s = $f47992;
                {
                  const b = $f47967;
                  {
                    const a = $f47966;
                    {
                      let glow;
                      {
                        let $t47834;
                        $t47834 = { $: "Loader", _0: s };
                        glow = Spin$Game$light(m, $t47834);
                      }
                      {
                        let mid;
                        {
                          let $t47835;
                          $t47835 = Arcade$Vec2$add(a, b);
                          mid = Arcade$Vec2$scale($t47835, 0.5);
                        }
                        {
                          let inward;
                          {
                            let $t47839;
                            {
                              let $t47838;
                              {
                                const $t47836 = a.x;
                                {
                                  const $t47837 = b.x;
                                  {
                                    const $t45787_i5734 = ($t47837 >= $t47836);
                                    if ($t45787_i5734 === true) {
                                      $t47838 = $t47837;
                                    } else {
                                      $t47838 = $t47836;
                                    }
                                  }
                                }
                              }
                              $t47839 = ($t47838 < 100.);
                            }
                            if ($t47839 === true) {
                              inward = ({ x: 18., y: 0. });
                            } else {
                              {
                                let $t47843;
                                {
                                  let $t47842;
                                  {
                                    const $t47840 = a.x;
                                    {
                                      const $t47841 = b.x;
                                      {
                                        const $t45788_i5729 = ($t47841 < $t47840);
                                        if ($t45788_i5729 === true) {
                                          $t47842 = $t47841;
                                        } else {
                                          $t47842 = $t47840;
                                        }
                                      }
                                    }
                                  }
                                  $t47843 = ($t47842 > 300.);
                                }
                                {
                                  const $jp1201_$t47844 = (-18.);
                                  if ($t47843 === true) {
                                    inward = ({ x: $jp1201_$t47844, y: 0. });
                                  } else {
                                    inward = ({ x: 0., y: $jp1201_$t47844 });
                                  }
                                }
                              }
                            }
                          }
                          {
                            let icon;
                            icon = Arcade$Vec2$add(mid, inward);
                            {
                              const $t47846 = (glow > 0.);
                              {
                                let $t47853;
                                if ($t47846 === true) {
                                  {
                                    let $t47851;
                                    {
                                      const $t47847 = mid.x;
                                      {
                                        const $t47848 = mid.y;
                                        {
                                          let $t47850;
                                          {
                                            const $t47849 = (glow * 0.7);
                                            $t47850 = Spin$Draw$rgba(255, 255, 255, $t47849);
                                          }
                                          $t47851 = { $: "Glow", _0: $t47847, _1: $t47848, _2: 30., _3: $t47850 };
                                        }
                                      }
                                    }
                                    {
                                      const $t47852 = { $: "Nil" };
                                      {
                                        const $rc_2702 = { $: "Cons", _0: $t47851, _1: $t47852 };
                                        $t47853 = $rc_2702;
                                      }
                                    }
                                  }
                                } else {
                                  $t47853 = { $: "Nil" };
                                }
                                {
                                  let $t47855;
                                  {
                                    const $t47854 = Spin$View$colour(s);
                                    $t47855 = Spin$Draw$stick(a, b, 8., $t47854);
                                  }
                                  {
                                    const $t47856 = { $: "Nil" };
                                    {
                                      const $t47857 = { $: "Cons", _0: $t47855, _1: $t47856 };
                                      {
                                        const $t47858 = m.num;
                                        {
                                          const $t47859 = icon.x;
                                          {
                                            const $t47860 = icon.y;
                                            {
                                              let $t47861;
                                              {
                                                let $rc_2700;
                                                $rc_2700 = Spin$View$symbol($t47858, s, $t47859, $t47860, 0.62);
                                                $t47861 = $rc_2700;
                                              }
                                              {
                                                const $t47862 = { $: "Nil" };
                                                {
                                                  const $t47863 = { $: "Cons", _0: $t47861, _1: $t47862 };
                                                  {
                                                    const $t47864 = { $: "Cons", _0: $t47857, _1: $t47863 };
                                                    {
                                                      const $t47865 = { $: "Cons", _0: $t47853, _1: $t47864 };
                                                      {
                                                        const prepend_reversed_i5720 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                        {
                                                          const go_i5721 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5720 };
                                                          {
                                                            const $t1113_i5722 = { $: "Nil" };
                                                            return go$apply$1_List_concat_List_List_Op(go_i5721, $t47865, $t1113_i5722);
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
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
                const b = $f47967;
                {
                  const a = $f47966;
                  {
                    const $t47867 = Spin$Draw$stick(a, b, 4., "#b9a6ff");
                    {
                      const $t47868 = { $: "Nil" };
                      return { $: "Cons", _0: $t47867, _1: $t47868 };
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
      const $f48009 = p._0;
      const $f48010 = p._1;
      const $f48011 = p._2;
      switch ($f48011.$) {
        case "HoldLane": {
          const $f48026 = $f48011._0;
          {
            const i = $f48026;
            {
              const r = $f48010;
              {
                const c = $f48009;
                {
                  let is_on;
                  {
                    const m_i12922 = m;
                    {
                      let $t47788_i12926;
                      {
                        const $t47786_i12924 = m.bank;
                        {
                          const $t47787_i12925 = $t47786_i12924.reels;
                          $t47788_i12926 = List$nth_opt$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$Int($t47787_i12925, i);
                        }
                      }
                      switch ($t47788_i12926.$) {
                        case "Some": {
                          const $f47789_i12927 = $t47788_i12926._0;
                          {
                            const r_i12928 = $f47789_i12927;
                            {
                              const $rc_2697_i12929 = r_i12928.held;
                              is_on = $rc_2697_i12929;
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
                    let $t47872;
                    {
                      const $t47869 = c.x;
                      {
                        const $t47870 = c.y;
                        {
                          let $t47871;
                          if (is_on === true) {
                            $t47871 = "#7dff7a";
                          } else {
                            $t47871 = "#5a4a80";
                          }
                          $t47872 = { $: "Ring", _0: $t47869, _1: $t47870, _2: r, _3: 2., _4: $t47871 };
                        }
                      }
                    }
                    {
                      let $t47877;
                      {
                        const $t47873 = c.x;
                        {
                          const $t47874 = c.y;
                          {
                            const $t47875 = (r - 3.);
                            {
                              let $t47876;
                              if (is_on === true) {
                                $t47876 = "#7dff7a";
                              } else {
                                $t47876 = "#241640";
                              }
                              $t47877 = { $: "Disc", _0: $t47873, _1: $t47874, _2: $t47875, _3: $t47876 };
                            }
                          }
                        }
                      }
                      {
                        let $t47884;
                        {
                          let $t47879;
                          {
                            const $t47878 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
                            $t47879 = String($t47878);
                          }
                          {
                            const $t47880 = c.x;
                            {
                              let $t47882;
                              {
                                const $t47881 = c.y;
                                $t47882 = ($t47881 + 0.5);
                              }
                              {
                                let $t47883;
                                if (is_on === true) {
                                  $t47883 = "#0b2a0b";
                                } else {
                                  $t47883 = "#9a8ac0";
                                }
                                $t47884 = { $: "Label", _0: $t47879, _1: $t47880, _2: $t47882, _3: 9., _4: $t47883 };
                              }
                            }
                          }
                        }
                        {
                          const $t47885 = { $: "Nil" };
                          {
                            const $t47886 = { $: "Cons", _0: $t47884, _1: $t47885 };
                            {
                              const $t47887 = { $: "Cons", _0: $t47877, _1: $t47886 };
                              {
                                const $rc_2704 = { $: "Cons", _0: $t47872, _1: $t47887 };
                                return $rc_2704;
                              }
                            }
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
      const $f48031 = p._0;
      const $f48032 = p._1;
      const $f48033 = p._2;
      {
        const b = $f48032;
        {
          const a = $f48031;
          {
            let h;
            {
              let $t47891;
              {
                let $t47890;
                {
                  let $t47889;
                  {
                    const $t47888 = m.spinner_turn;
                    $t47889 = Math.cos($t47888);
                  }
                  $t47890 = Math.abs($t47889);
                }
                $t47891 = (7. * $t47890);
              }
              h = (2. + $t47891);
            }
            {
              let glow;
              {
                const $t47892 = { $: "Spinner" };
                glow = Spin$Game$light(m, $t47892);
              }
              {
                const $t47893 = (glow > 0.);
                {
                  let $t47903;
                  if ($t47893 === true) {
                    {
                      let $t47901;
                      {
                        let $t47897;
                        {
                          let $t47896;
                          {
                            const $t47894 = a.x;
                            {
                              const $t47895 = b.x;
                              $t47896 = ($t47894 + $t47895);
                            }
                          }
                          $t47897 = ($t47896 / 2.);
                        }
                        {
                          const $t47898 = a.y;
                          {
                            let $t47900;
                            {
                              const $t47899 = (glow * 0.8);
                              $t47900 = Spin$Draw$rgba(92, 242, 255, $t47899);
                            }
                            $t47901 = { $: "Glow", _0: $t47897, _1: $t47898, _2: 34., _3: $t47900 };
                          }
                        }
                      }
                      {
                        const $t47902 = { $: "Nil" };
                        $t47903 = { $: "Cons", _0: $t47901, _1: $t47902 };
                      }
                    }
                  } else {
                    $t47903 = { $: "Nil" };
                  }
                  {
                    let $t47913;
                    {
                      let $t47905;
                      {
                        const $t47904 = a.x;
                        $t47905 = ($t47904 + 3.);
                      }
                      {
                        let $t47908;
                        {
                          const $t47906 = a.y;
                          {
                            const $t47907 = (h / 2.);
                            $t47908 = ($t47906 - $t47907);
                          }
                        }
                        {
                          let $t47912;
                          {
                            let $t47911;
                            {
                              const $t47909 = b.x;
                              {
                                const $t47910 = a.x;
                                $t47911 = ($t47909 - $t47910);
                              }
                            }
                            $t47912 = ($t47911 - 6.);
                          }
                          $t47913 = { $: "Box", _0: $t47905, _1: $t47908, _2: $t47912, _3: h, _4: "#5cf2ff" };
                        }
                      }
                    }
                    {
                      let $t47920;
                      {
                        let $t47917;
                        {
                          let $t47916;
                          {
                            const $t47914 = a.x;
                            {
                              const $t47915 = b.x;
                              $t47916 = ($t47914 + $t47915);
                            }
                          }
                          $t47917 = ($t47916 / 2.);
                        }
                        {
                          let $t47919;
                          {
                            const $t47918 = a.y;
                            $t47919 = ($t47918 + 16.);
                          }
                          $t47920 = { $: "Label", _0: "SPIN", _1: $t47917, _2: $t47919, _3: 9., _4: "#5cf2ff" };
                        }
                      }
                      {
                        const $t47921 = { $: "Nil" };
                        {
                          const $t47922 = { $: "Cons", _0: $t47920, _1: $t47921 };
                          {
                            const $t47923 = { $: "Cons", _0: $t47913, _1: $t47922 };
                            {
                              const $t47924 = { $: "Nil" };
                              {
                                const $t47925 = { $: "Cons", _0: $t47923, _1: $t47924 };
                                {
                                  const $t47926 = { $: "Cons", _0: $t47903, _1: $t47925 };
                                  {
                                    const prepend_reversed_i5745 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                    {
                                      const go_i5746 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5745 };
                                      {
                                        const $t1113_i5747 = { $: "Nil" };
                                        return go$apply$1_List_concat_List_List_Op(go_i5746, $t47926, $t1113_i5747);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
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
      const $t48042 = f.angle;
      tip = Spin$Table$tip(spec, $t48042);
    }
    {
      let $t48047;
      {
        const $t48043 = spec.pivot;
        {
          let $t48046;
          {
            let $t48045;
            {
              const $t48044 = spec.radius;
              $t48045 = ($t48044 * 2.);
            }
            $t48046 = ($t48045 + 3.);
          }
          $t48047 = Spin$Draw$stick($t48043, tip, $t48046, "#3b2a5c");
        }
      }
      {
        let $t48051;
        {
          const $t48048 = spec.pivot;
          {
            let $t48050;
            {
              const $t48049 = spec.radius;
              $t48050 = ($t48049 * 2.);
            }
            $t48051 = Spin$Draw$stick($t48048, tip, $t48050, "#f4f1ff");
          }
        }
        {
          let $t48056;
          {
            let $t48053;
            {
              const $t48052 = spec.pivot;
              $t48053 = $t48052.x;
            }
            {
              let $t48055;
              {
                const $t48054 = spec.pivot;
                $t48055 = $t48054.y;
              }
              $t48056 = { $: "Disc", _0: $t48053, _1: $t48055, _2: 3., _3: "#ff3fa4" };
            }
          }
          {
            const $t48057 = { $: "Nil" };
            {
              const $t48058 = { $: "Cons", _0: $t48056, _1: $t48057 };
              {
                const $t48059 = { $: "Cons", _0: $t48051, _1: $t48058 };
                return { $: "Cons", _0: $t48047, _1: $t48059 };
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
    let $t48066;
    {
      let $t48062;
      {
        let $t48061;
        {
          const $t48060 = b.pos;
          $t48061 = $t48060.x;
        }
        $t48062 = ($t48061 + 2.);
      }
      {
        let $t48065;
        {
          let $t48064;
          {
            const $t48063 = b.pos;
            $t48064 = $t48063.y;
          }
          $t48065 = ($t48064 + 3.);
        }
        $t48066 = { $: "Disc", _0: $t48062, _1: $t48065, _2: 9., _3: "rgba(0,0,0,0.35)" };
      }
    }
    {
      let $t48071;
      {
        let $t48068;
        {
          const $t48067 = b.pos;
          $t48068 = $t48067.x;
        }
        {
          let $t48070;
          {
            const $t48069 = b.pos;
            $t48070 = $t48069.y;
          }
          $t48071 = { $: "Disc", _0: $t48068, _1: $t48070, _2: 9., _3: "#cfd5e2" };
        }
      }
      {
        let $t48078;
        {
          let $t48074;
          {
            let $t48073;
            {
              const $t48072 = b.pos;
              $t48073 = $t48072.x;
            }
            $t48074 = ($t48073 - 1.);
          }
          {
            let $t48077;
            {
              let $t48076;
              {
                const $t48075 = b.pos;
                $t48076 = $t48075.y;
              }
              $t48077 = ($t48076 - 1.);
            }
            $t48078 = { $: "Disc", _0: $t48074, _1: $t48077, _2: 7., _3: "#e9edf5" };
          }
        }
        {
          let $t48085;
          {
            let $t48081;
            {
              let $t48080;
              {
                const $t48079 = b.pos;
                $t48080 = $t48079.x;
              }
              $t48081 = ($t48080 - 3.);
            }
            {
              let $t48084;
              {
                let $t48083;
                {
                  const $t48082 = b.pos;
                  $t48083 = $t48082.y;
                }
                $t48084 = ($t48083 - 3.5);
              }
              $t48085 = { $: "Disc", _0: $t48081, _1: $t48084, _2: 2.6, _3: "#ffffff" };
            }
          }
          {
            const $t48086 = { $: "Nil" };
            {
              const $t48087 = { $: "Cons", _0: $t48085, _1: $t48086 };
              {
                const $t48088 = { $: "Cons", _0: $t48078, _1: $t48087 };
                {
                  const $t48089 = { $: "Cons", _0: $t48071, _1: $t48088 };
                  return { $: "Cons", _0: $t48066, _1: $t48089 };
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

function Spin$View$plunger_ops(m) {
  {
    let top;
    {
      let $t48091;
      {
        const $t48090 = m.pull;
        $t48091 = (26. * $t48090);
      }
      top = (702. + $t48091);
    }
    {
      let $t48092;
      {
        const go_i5786 = { $: "$Clo_go$0_List_range", _0: go$apply$0_List_range, _1: 0 };
        {
          const $t915_i5787 = ((6 - 1) < 4611686018427387904 && (6 - 1) >= -4611686018427387904 ? (6 - 1) : march_int_ovf((6 - 1), 1));
          {
            const $t916_i5788 = { $: "Nil" };
            $t48092 = go$apply$0_List_range(go_i5786, $t915_i5787, $t916_i5788);
          }
        }
      }
      {
        let $t48104;
        $t48104 = { $: "$Clo_$lam0_Spin_View_plunger_ops$0_Spin_View_plunger_ops", _0: $lam0_Spin_View_plunger_ops$apply$0_Spin_View_plunger_ops, _1: m, _2: top };
        {
          const coils = List$map$List_Int$Fn_Int_Op($t48092, $t48104);
          {
            let $t48109;
            {
              let $t48105;
              $t48105 = Spin$Game$waiting(m);
              {
                let $t48108;
                {
                  const $t48106 = m.mode;
                  {
                    const $t48107 = { $: "Playing" };
                    {
                      const $rc_2705 = march_deep_eq($t48106, $t48107);
                      $t48108 = $rc_2705;
                    }
                  }
                }
                $t48109 = ($t48105 && $t48108);
              }
            }
            {
              let hint;
              if ($t48109 === true) {
                {
                  let $t48116;
                  {
                    let $t48115;
                    {
                      let $t48114;
                      {
                        let $t48113;
                        {
                          let $t48112;
                          {
                            let $t48111;
                            {
                              const $t48110 = m.clock;
                              $t48111 = ($t48110 * 5.);
                            }
                            $t48112 = Math.sin($t48111);
                          }
                          $t48113 = (0.4 * $t48112);
                        }
                        $t48114 = (0.6 + $t48113);
                      }
                      $t48115 = Spin$Draw$rgba(255, 211, 107, $t48114);
                    }
                    $t48116 = { $: "Label", _0: "PULL", _1: 365., _2: 650., _3: 8., _4: $t48115 };
                  }
                  {
                    const $t48117 = { $: "Nil" };
                    hint = { $: "Cons", _0: $t48116, _1: $t48117 };
                  }
                }
              } else {
                hint = { $: "Nil" };
              }
              {
                const $t48118 = { $: "Box", _0: 357., _1: top, _2: 16., _3: 6., _4: "#e33" };
                {
                  let $t48120;
                  {
                    const $t48119 = (top + 6.);
                    $t48120 = { $: "Box", _0: 362., _1: $t48119, _2: 6., _3: 50., _4: "#556" };
                  }
                  {
                    const $t48121 = { $: "Nil" };
                    {
                      const $t48122 = { $: "Cons", _0: $t48120, _1: $t48121 };
                      {
                        const $t48123 = { $: "Cons", _0: $t48118, _1: $t48122 };
                        {
                          const $t48124 = { $: "Nil" };
                          {
                            const $t48125 = { $: "Cons", _0: hint, _1: $t48124 };
                            {
                              const $t48126 = { $: "Cons", _0: coils, _1: $t48125 };
                              {
                                const $t48127 = { $: "Cons", _0: $t48123, _1: $t48126 };
                                {
                                  const prepend_reversed_i5775 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                  {
                                    const go_i5776 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5775 };
                                    {
                                      const $t1113_i5777 = { $: "Nil" };
                                      return go$apply$1_List_concat_List_List_Op(go_i5776, $t48127, $t1113_i5777);
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$plunger_ops$clo = { _0: ($_, m) => Spin$View$plunger_ops(m) };

function Spin$View$banner_ops(m) {
  {
    const b = m.banner;
    {
      let $t48146;
      {
        let $t48142;
        {
          const $t48141 = b.left;
          $t48142 = ($t48141 > 0.);
        }
        {
          let $t48145;
          {
            const $t48143 = m.mode;
            {
              const $t48144 = { $: "Playing" };
              {
                const $rc_2706 = march_deep_eq($t48143, $t48144);
                $t48145 = $rc_2706;
              }
            }
          }
          $t48146 = ($t48142 && $t48145);
        }
      }
      if ($t48146 === true) {
        {
          let a;
          {
            let $t48148;
            {
              const $t48147 = b.left;
              $t48148 = ($t48147 * 3.);
            }
            {
              const $t45788_i5809 = ($t48148 < 1.);
              if ($t45788_i5809 === true) {
                a = $t48148;
              } else {
                a = 1.;
              }
            }
          }
          {
            let main;
            {
              const $t48149 = b.hot;
              if ($t48149 === true) {
                main = Spin$Draw$rgba(255, 211, 107, a);
              } else {
                main = Spin$Draw$rgba(255, 255, 255, a);
              }
            }
            {
              let $t48152;
              {
                let $t48151;
                {
                  const $t48150 = (0.8 * a);
                  $t48151 = Spin$Draw$rgba(7, 4, 15, $t48150);
                }
                $t48152 = { $: "Box", _0: 100., _1: 548., _2: 170., _3: 40., _4: $t48151 };
              }
              {
                let $t48154;
                {
                  const $t48153 = b.text;
                  $t48154 = { $: "Label", _0: $t48153, _1: 185., _2: 562., _3: 16., _4: main };
                }
                {
                  let $t48157;
                  {
                    const $t48155 = b.sub;
                    {
                      const $t48156 = Spin$Draw$rgba(200, 190, 255, a);
                      $t48157 = { $: "Label", _0: $t48155, _1: 185., _2: 579., _3: 8., _4: $t48156 };
                    }
                  }
                  {
                    const $t48158 = { $: "Nil" };
                    {
                      const $t48159 = { $: "Cons", _0: $t48157, _1: $t48158 };
                      {
                        const $t48160 = { $: "Cons", _0: $t48154, _1: $t48159 };
                        return { $: "Cons", _0: $t48152, _1: $t48160 };
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
      let $t48162;
      {
        const $t48161 = m.credits;
        $t48162 = ($t48161 <= 10);
      }
      {
        let $t48165;
        {
          const $t48163 = m.mode;
          {
            const $t48164 = { $: "Playing" };
            {
              const $rc_2709 = march_deep_eq($t48163, $t48164);
              $t48165 = $rc_2709;
            }
          }
        }
        low = ($t48162 && $t48165);
      }
    }
    {
      let blink;
      {
        let $t48169;
        {
          let $t48168;
          {
            let $t48167;
            {
              const $t48166 = m.clock;
              $t48167 = ($t48166 * 10.);
            }
            $t48168 = Math.sin($t48167);
          }
          $t48169 = ($t48168 > 0.);
        }
        blink = (low && $t48169);
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
            const $t48170 = m.alive;
            {
              let $t46154_i5853;
              {
                let $t46153_i5852;
                {
                  let $t46152_i5851;
                  {
                    const $t46151_i5850 = ($t48170 * 0.00385);
                    $t46152_i5851 = (0. - $t46151_i5850);
                  }
                  $t46153_i5852 = Math.exp($t46152_i5851);
                }
                $t46154_i5853 = (2.4 * $t46153_i5852);
              }
              {
                const $t45787_i14338 = ($t46154_i5853 >= 0.05);
                if ($t45787_i14338 === true) {
                  every = $t46154_i5853;
                } else {
                  every = 0.05;
                }
              }
            }
          }
          {
            let f;
            {
              let $t48172;
              {
                const $t48171 = m.burn_clock;
                $t48172 = ($t48171 / every);
              }
              {
                let $t45789_i5848;
                {
                  const $t45787_i14335 = (0. >= $t48172);
                  if ($t45787_i14335 === true) {
                    $t45789_i5848 = 0.;
                  } else {
                    $t45789_i5848 = $t48172;
                  }
                }
                {
                  const $t45788_i14332 = (1. < $t45789_i5848);
                  if ($t45788_i14332 === true) {
                    f = 1.;
                  } else {
                    f = $t45789_i5848;
                  }
                }
              }
            }
            {
              let $t48174;
              {
                const $t48173 = (-92.);
                $t48174 = { $: "Box", _0: 6., _1: $t48173, _2: 388., _3: 84., _4: "#140a24" };
              }
              {
                let $t48176;
                {
                  const $t48175 = (-88.);
                  $t48176 = { $: "Box", _0: 10., _1: $t48175, _2: 380., _3: 76., _4: "#1f1035" };
                }
                {
                  let $t48178;
                  {
                    const $t48177 = (-74.);
                    $t48178 = { $: "Label", _0: "CREDITS", _1: 80., _2: $t48177, _3: 9., _4: "#b9a6ff" };
                  }
                  {
                    let $t48182;
                    {
                      let $t48180;
                      {
                        const $t48179 = m.credits;
                        $t48180 = String($t48179);
                      }
                      {
                        const $t48181 = (-42.);
                        $t48182 = { $: "Label", _0: $t48180, _1: 80., _2: $t48181, _3: 38., _4: credit_colour };
                      }
                    }
                    {
                      let $t48184;
                      {
                        const $t48183 = (-74.);
                        $t48184 = { $: "Label", _0: "METER", _1: 200., _2: $t48183, _3: 9., _4: "#b9a6ff" };
                      }
                      {
                        let $t48186;
                        {
                          const $t48185 = (-54.);
                          $t48186 = { $: "Box", _0: 160., _1: $t48185, _2: 80., _3: 12., _4: "#0b0614" };
                        }
                        {
                          let $t48190;
                          {
                            const $t48187 = (-54.);
                            {
                              const $t48188 = (80. * f);
                              {
                                let $t48189;
                                if (low === true) {
                                  $t48189 = "#ff3b4e";
                                } else {
                                  $t48189 = "#ff8a3d";
                                }
                                $t48190 = { $: "Box", _0: 160., _1: $t48187, _2: $t48188, _3: 12., _4: $t48189 };
                              }
                            }
                          }
                          {
                            let $t48194;
                            {
                              let $t48192;
                              {
                                let $t48191;
                                {
                                  let t_i12932;
                                  {
                                    const $t48217_i12931 = (every * 10.);
                                    t_i12932 = march_float_round($t48217_i12931);
                                  }
                                  {
                                    let $t48219_i12934;
                                    {
                                      const $t48218_i12933 = ((t_i12932 - t_i12932 % 10) / 10);
                                      $t48219_i12934 = String($t48218_i12933);
                                    }
                                    {
                                      let $t48221_i12936;
                                      {
                                        const $t48220_i12935 = (t_i12932 % 10);
                                        $t48221_i12936 = String($t48220_i12935);
                                      }
                                      {
                                        const $rc_2710_i12937 = march_string_concat3($t48219_i12934, ".", $t48221_i12936);
                                        $t48191 = $rc_2710_i12937;
                                      }
                                    }
                                  }
                                }
                                {
                                  const $rc_2708 = march_string_concat3("1 per ", $t48191, "s");
                                  $t48192 = $rc_2708;
                                }
                              }
                              {
                                const $t48193 = (-28.);
                                $t48194 = { $: "Label", _0: $t48192, _1: 200., _2: $t48193, _3: 8., _4: "#8a7ab0" };
                              }
                            }
                            {
                              let $t48196;
                              {
                                const $t48195 = (-74.);
                                $t48196 = { $: "Label", _0: "PAID", _1: 320., _2: $t48195, _3: 9., _4: "#b9a6ff" };
                              }
                              {
                                let $t48200;
                                {
                                  let $t48198;
                                  {
                                    const $t48197 = m.paid;
                                    $t48198 = String($t48197);
                                  }
                                  {
                                    const $t48199 = (-50.);
                                    $t48200 = { $: "Label", _0: $t48198, _1: 320., _2: $t48199, _3: 22., _4: "#7dff7a" };
                                  }
                                }
                                {
                                  let $t48205;
                                  {
                                    let $t48203;
                                    {
                                      let $t48202;
                                      {
                                        const $t48201 = m.best;
                                        $t48202 = String($t48201);
                                      }
                                      {
                                        const $rc_2707 = ("BEST " + $t48202);
                                        $t48203 = $rc_2707;
                                      }
                                    }
                                    {
                                      const $t48204 = (-26.);
                                      $t48205 = { $: "Label", _0: $t48203, _1: 320., _2: $t48204, _3: 9., _4: "#8a7ab0" };
                                    }
                                  }
                                  {
                                    const $t48206 = { $: "Nil" };
                                    {
                                      const $t48207 = { $: "Cons", _0: $t48205, _1: $t48206 };
                                      {
                                        const $t48208 = { $: "Cons", _0: $t48200, _1: $t48207 };
                                        {
                                          const $t48209 = { $: "Cons", _0: $t48196, _1: $t48208 };
                                          {
                                            const $t48210 = { $: "Cons", _0: $t48194, _1: $t48209 };
                                            {
                                              const $t48211 = { $: "Cons", _0: $t48190, _1: $t48210 };
                                              {
                                                const $t48212 = { $: "Cons", _0: $t48186, _1: $t48211 };
                                                {
                                                  const $t48213 = { $: "Cons", _0: $t48184, _1: $t48212 };
                                                  {
                                                    const $t48214 = { $: "Cons", _0: $t48182, _1: $t48213 };
                                                    {
                                                      const $t48215 = { $: "Cons", _0: $t48178, _1: $t48214 };
                                                      {
                                                        const $t48216 = { $: "Cons", _0: $t48176, _1: $t48215 };
                                                        return { $: "Cons", _0: $t48174, _1: $t48216 };
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
    const $t48222 = m.mode;
    switch ($t48222.$) {
      case "Playing": {
        return { $: "Nil" };
        break;
      }
      case "Attract": {
        {
          let pulse;
          {
            let $t48226;
            {
              let $t48225;
              {
                let $t48224;
                {
                  const $t48223 = m.clock;
                  $t48224 = ($t48223 * 3.);
                }
                $t48225 = Math.sin($t48224);
              }
              $t48226 = (0.45 * $t48225);
            }
            pulse = (0.55 + $t48226);
          }
          {
            const $t48227 = { $: "Box", _0: 30., _1: 150., _2: 310., _3: 330., _4: "rgba(7,4,15,0.86)" };
            {
              const $t48228 = { $: "Label", _0: "SPIN", _1: 185., _2: 190., _3: 40., _4: "#ff3fa4" };
              {
                const $t48229 = { $: "Label", _0: "SPIN", _1: 185., _2: 232., _3: 40., _4: "#5cf2ff" };
                {
                  const $t48231 = { $: "Label", _0: "SPIN", _1: 185., _2: 274., _3: 40., _4: "#ffd36b" };
                  {
                    const $t48232 = { $: "Label", _0: "pinball that plays a slot machine", _1: 185., _2: 306., _3: 10., _4: "#d8ccff" };
                    {
                      const $t48233 = { $: "Label", _0: "TARGETS put their symbol on the line:", _1: 185., _2: 330., _3: 9., _4: "#ffffff" };
                      {
                        const $t48234 = { $: "Label", _0: "hit three, left reel to right, to spell it", _1: 185., _2: 344., _3: 9., _4: "#ffffff" };
                        {
                          const $t48235 = { $: "Label", _0: "the SPINNER spins all three", _1: 185., _2: 362., _3: 9., _4: "#5cf2ff" };
                          {
                            const $t48236 = { $: "Label", _0: "BUMPERS nudge them after a miss", _1: 185., _2: 376., _3: 9., _4: "#ff8fcf" };
                            {
                              const $t48237 = { $: "Label", _0: "TOP LANES hold a reel; all three: x2", _1: 185., _2: 390., _3: 9., _4: "#7dff7a" };
                              {
                                const $t48238 = { $: "Label", _0: "the meter eats credits. only the reels pay.", _1: 185., _2: 412., _3: 9., _4: "#ff8a3d" };
                                {
                                  let $t48240;
                                  {
                                    const $t48239 = Spin$Draw$rgba(255, 211, 107, pulse);
                                    $t48240 = { $: "Label", _0: "TAP OR PRESS SPACE", _1: 185., _2: 446., _3: 14., _4: $t48239 };
                                  }
                                  {
                                    const $t48241 = { $: "Nil" };
                                    {
                                      const $t48242 = { $: "Cons", _0: $t48240, _1: $t48241 };
                                      {
                                        const $t48243 = { $: "Cons", _0: $t48238, _1: $t48242 };
                                        {
                                          const $t48244 = { $: "Cons", _0: $t48237, _1: $t48243 };
                                          {
                                            const $t48245 = { $: "Cons", _0: $t48236, _1: $t48244 };
                                            {
                                              const $t48246 = { $: "Cons", _0: $t48235, _1: $t48245 };
                                              {
                                                const $t48247 = { $: "Cons", _0: $t48234, _1: $t48246 };
                                                {
                                                  const $t48248 = { $: "Cons", _0: $t48233, _1: $t48247 };
                                                  {
                                                    const $t48249 = { $: "Cons", _0: $t48232, _1: $t48248 };
                                                    {
                                                      const $t48250 = { $: "Cons", _0: $t48231, _1: $t48249 };
                                                      {
                                                        const $t48251 = { $: "Cons", _0: $t48229, _1: $t48250 };
                                                        {
                                                          const $t48252 = { $: "Cons", _0: $t48228, _1: $t48251 };
                                                          return { $: "Cons", _0: $t48227, _1: $t48252 };
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
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
            let $t48256;
            {
              let $t48255;
              {
                let $t48254;
                {
                  const $t48253 = m.clock;
                  $t48254 = ($t48253 * 3.);
                }
                $t48255 = Math.sin($t48254);
              }
              $t48256 = (0.45 * $t48255);
            }
            pulse = (0.55 + $t48256);
          }
          {
            const $t48257 = { $: "Box", _0: 40., _1: 230., _2: 290., _3: 190., _4: "rgba(7,4,15,0.9)" };
            {
              const $t48258 = { $: "Label", _0: "BUSTED", _1: 185., _2: 270., _3: 38., _4: "#ff3b4e" };
              {
                let $t48262;
                {
                  let $t48261;
                  {
                    let $t48260;
                    {
                      const $t48259 = m.paid;
                      $t48260 = String($t48259);
                    }
                    {
                      const $rc_2712 = ("the reels paid " + $t48260);
                      $t48261 = $rc_2712;
                    }
                  }
                  $t48262 = { $: "Label", _0: $t48261, _1: 185., _2: 312., _3: 13., _4: "#ffffff" };
                }
                {
                  let $t48267;
                  {
                    let $t48265;
                    {
                      let $t48264;
                      {
                        const $t48263 = m.best;
                        $t48264 = String($t48263);
                      }
                      {
                        const $rc_2711 = ("best " + $t48264);
                        $t48265 = $rc_2711;
                      }
                    }
                    $t48267 = { $: "Label", _0: $t48265, _1: 185., _2: 334., _3: 11., _4: "#ffd36b" };
                  }
                  {
                    let $t48273;
                    {
                      let $t48272;
                      {
                        let $t48271;
                        {
                          let $t48270;
                          {
                            let $t48269;
                            {
                              const $t48268 = m.banner;
                              $t48269 = $t48268.left;
                            }
                            $t48270 = ($t48269 < 999998.);
                          }
                          if ($t48270 === true) {
                            $t48271 = pulse;
                          } else {
                            $t48271 = 0.2;
                          }
                        }
                        $t48272 = Spin$Draw$rgba(255, 211, 107, $t48271);
                      }
                      $t48273 = { $: "Label", _0: "TAP OR PRESS SPACE", _1: 185., _2: 386., _3: 13., _4: $t48272 };
                    }
                    {
                      const $t48274 = { $: "Nil" };
                      {
                        const $t48275 = { $: "Cons", _0: $t48273, _1: $t48274 };
                        {
                          const $t48276 = { $: "Cons", _0: $t48267, _1: $t48275 };
                          {
                            const $t48277 = { $: "Cons", _0: $t48262, _1: $t48276 };
                            {
                              const $t48278 = { $: "Cons", _0: $t48258, _1: $t48277 };
                              return { $: "Cons", _0: $t48257, _1: $t48278 };
                            }
                          }
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

function Spin$View$frame(m) {
  {
    const $t48282 = { $: "Clear", _0: "#07040f" };
    {
      const $t48283 = { $: "Nil" };
      {
        const $t48284 = { $: "Cons", _0: $t48282, _1: $t48283 };
        {
          let $t48285;
          {
            const _m_i12954 = m;
            {
              const $t48129_i12960 = { $: "Disc", _0: 200., _1: 200., _2: 182., _3: "#1a0c30" };
              {
                const $t48131_i12962 = { $: "Box", _0: 18., _1: 200., _2: 364., _3: 570., _4: "#1a0c30" };
                {
                  const $t48132_i12963 = { $: "Nil" };
                  {
                    const $t48133_i12964 = { $: "Cons", _0: $t48131_i12962, _1: $t48132_i12963 };
                    {
                      const $t48134_i12965 = { $: "Cons", _0: $t48129_i12960, _1: $t48133_i12964 };
                      {
                        const $t48135_i12966 = { $: "Glow", _0: 185., _1: 420., _2: 230., _3: "rgba(120,40,200,0.25)" };
                        {
                          const $t48136_i12967 = { $: "Nil" };
                          {
                            const $t48137_i12968 = { $: "Cons", _0: $t48135_i12966, _1: $t48136_i12967 };
                            {
                              const $t48138_i12969 = { $: "Nil" };
                              {
                                const $t48139_i12970 = { $: "Cons", _0: $t48137_i12968, _1: $t48138_i12969 };
                                {
                                  const $t48140_i12971 = { $: "Cons", _0: $t48134_i12965, _1: $t48139_i12970 };
                                  {
                                    const prepend_reversed_i5790_i12973 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                    {
                                      const go_i5791_i12974 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5790_i12973 };
                                      {
                                        const $t1113_i5792_i12975 = { $: "Nil" };
                                        $t48285 = go$apply$1_List_concat_List_List_Op(go_i5791_i12974, $t48140_i12971, $t1113_i5792_i12975);
                                      }
                                    }
                                  }
                                }
                              }
                            }
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
            let $t48286;
            $t48286 = Spin$View$machine_ops(m);
            {
              const $t48287 = m.table;
              {
                const $t48288 = $t48287.parts;
                {
                  let $t48290;
                  $t48290 = { $: "$Clo_$lam0_Spin_View_frame$0_Spin_View_frame", _0: $lam0_Spin_View_frame$apply$0_Spin_View_frame, _1: m };
                  {
                    let $t48291;
                    {
                      const xs_i12946 = $t48288;
                      {
                        const f_i12947 = $t48290;
                        switch (xs_i12946.$) {
                          case "Nil": {
                            $t48291 = { $: "Nil" };
                            break;
                          }
                          case "Cons": {
                            const $f995_i12948 = xs_i12946._0;
                            const $f996_i12949 = xs_i12946._1;
                            {
                              const t_i12950 = $f996_i12949;
                              {
                                const h_i12951 = $f995_i12948;
                                {
                                  let $t993_i12952;
                                  $t993_i12952 = f_i12947._0(f_i12947, h_i12951);
                                  {
                                    const $trmc15_i12953 = { $: "Cons", _0: $t993_i12952, _1: null };
                                    List$map$dps$List_Part$Fn_Part_List_Op$List_List_Op(t_i12950, f_i12947, $trmc15_i12953);
                                    $t48291 = $trmc15_i12953;
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
                      let $t48292;
                      {
                        const prepend_reversed_i5948 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                        {
                          const go_i5949 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5948 };
                          {
                            const $t1113_i5950 = { $: "Nil" };
                            $t48292 = go$apply$1_List_concat_List_List_Op(go_i5949, $t48291, $t1113_i5950);
                          }
                        }
                      }
                      {
                        let $t48293;
                        $t48293 = Spin$View$plunger_ops(m);
                        {
                          let $t48295;
                          {
                            const $t48294 = m.table;
                            $t48295 = $t48294.left;
                          }
                          {
                            const $t48296 = m.left;
                            {
                              const $t48297 = Spin$View$flipper_ops($t48295, $t48296);
                              {
                                let $t48299;
                                {
                                  const $t48298 = m.table;
                                  $t48299 = $t48298.right;
                                }
                                {
                                  const $t48300 = m.right;
                                  {
                                    const $t48301 = Spin$View$flipper_ops($t48299, $t48300);
                                    {
                                      const $t48302 = m.balls;
                                      {
                                        let $t48303;
                                        {
                                          const xs_i12938 = $t48302;
                                          {
                                            const f_i12939 = Spin$View$ball_ops$clo;
                                            switch (xs_i12938.$) {
                                              case "Nil": {
                                                $t48303 = { $: "Nil" };
                                                break;
                                              }
                                              case "Cons": {
                                                const $f995_i12940 = xs_i12938._0;
                                                const $f996_i12941 = xs_i12938._1;
                                                {
                                                  const t_i12942 = $f996_i12941;
                                                  {
                                                    const h_i12943 = $f995_i12940;
                                                    {
                                                      let $t993_i12944;
                                                      $t993_i12944 = f_i12939._0(f_i12939, h_i12943);
                                                      {
                                                        const $trmc15_i12945 = { $: "Cons", _0: $t993_i12944, _1: null };
                                                        List$map$dps$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Fn_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float_List_Op$List_List_Op(t_i12942, f_i12939, $trmc15_i12945);
                                                        $t48303 = $trmc15_i12945;
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
                                          let $t48304;
                                          {
                                            const prepend_reversed_i5944 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                            {
                                              const go_i5945 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5944 };
                                              {
                                                const $t1113_i5946 = { $: "Nil" };
                                                $t48304 = go$apply$1_List_concat_List_List_Op(go_i5945, $t48303, $t1113_i5946);
                                              }
                                            }
                                          }
                                          {
                                            let $t48305;
                                            $t48305 = Spin$View$banner_ops(m);
                                            {
                                              let $t48306;
                                              $t48306 = Spin$View$panel_ops(m);
                                              {
                                                let $t48307;
                                                {
                                                  const $t48279_i5941 = { $: "Label", _0: "Z / ←  left    right  → / M    SPACE launch", _1: 185., _2: 752., _3: 7.5, _4: "rgba(185,166,255,0.45)" };
                                                  {
                                                    const $t48280_i5942 = { $: "Nil" };
                                                    $t48307 = { $: "Cons", _0: $t48279_i5941, _1: $t48280_i5942 };
                                                  }
                                                }
                                                {
                                                  const $t48308 = Spin$View$screen_ops(m);
                                                  {
                                                    const $t48309 = { $: "Nil" };
                                                    {
                                                      const $t48310 = { $: "Cons", _0: $t48308, _1: $t48309 };
                                                      {
                                                        const $t48311 = { $: "Cons", _0: $t48307, _1: $t48310 };
                                                        {
                                                          const $t48312 = { $: "Cons", _0: $t48306, _1: $t48311 };
                                                          {
                                                            const $t48313 = { $: "Cons", _0: $t48305, _1: $t48312 };
                                                            {
                                                              const $t48314 = { $: "Cons", _0: $t48304, _1: $t48313 };
                                                              {
                                                                const $t48315 = { $: "Cons", _0: $t48301, _1: $t48314 };
                                                                {
                                                                  const $t48316 = { $: "Cons", _0: $t48297, _1: $t48315 };
                                                                  {
                                                                    const $t48317 = { $: "Cons", _0: $t48293, _1: $t48316 };
                                                                    {
                                                                      const $t48318 = { $: "Cons", _0: $t48292, _1: $t48317 };
                                                                      {
                                                                        const $t48319 = { $: "Cons", _0: $t48286, _1: $t48318 };
                                                                        {
                                                                          const $t48320 = { $: "Cons", _0: $t48285, _1: $t48319 };
                                                                          {
                                                                            const $t48321 = { $: "Cons", _0: $t48284, _1: $t48320 };
                                                                            {
                                                                              const prepend_reversed_i5938 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_Op", _0: prepend_reversed$apply$0_List_concat_List_List_Op };
                                                                              {
                                                                                const go_i5939 = { $: "$Clo_go$1_List_concat_List_List_Op", _0: go$apply$1_List_concat_List_List_Op, _1: prepend_reversed_i5938 };
                                                                                {
                                                                                  const $t1113_i5940 = { $: "Nil" };
                                                                                  return go$apply$1_List_concat_List_List_Op(go_i5939, $t48321, $t1113_i5940);
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Spin$View$frame$clo = { _0: ($_, m) => Spin$View$frame(m) };

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
      const $f48326 = c._0;
      {
        const n = $f48326;
        {
          const $t48322 = n;
          return { _0: "load", _1: $t48322 };
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
      const $f48327 = c._0;
      {
        const i = $f48327;
        {
          const $t48323 = i;
          return { _0: "reelstop", _1: $t48323 };
        }
      }
      break;
    }
    case "CueReelStart": {
      return { _0: "reelstart", _1: 0. };
      break;
    }
    case "CueWin": {
      const $f48328 = c._0;
      {
        const n = $f48328;
        {
          const $t48324 = n;
          return { _0: "win", _1: $t48324 };
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
      const $f48329 = c._0;
      {
        const n = $f48329;
        {
          const $t48325 = n;
          return { _0: "burn", _1: $t48325 };
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
      const $f48330 = c._0;
      {
        const speed = $f48330;
        return { _0: "thud", _1: speed };
      }
      break;
    }
    case "CueStore": {
      const $f48331 = c._0;
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
      const $f48333 = c._0;
      {
        const best = $f48333;
        return glue_save_best$clo._0(glue_save_best$clo, best);
      }
      break;
    }
    default: {
      {
        const $p48332 = sound(c);
        {
          const name = $p48332._0;
          {
            const x = $p48332._1;
            return glue_sound$clo._0(glue_sound$clo, name, x);
          }
        }
      }
    }
  }
}
const perform$clo = { _0: ($_, c) => perform(c) };

function mark(m) {
  {
    let $eff;
    {
      let $t48339;
      {
        const $t48338 = m.mode;
        switch ($t48338.$) {
          case "Attract": {
            $t48339 = "attract";
            break;
          }
          case "Playing": {
            $t48339 = "playing";
            break;
          }
          case "Busted": {
            $t48339 = "busted";
            break;
          }
          default: {
            throw new Error("non-exhaustive pattern match");
            break;
          }
        }
      }
      {
        const $rc_2717 = glue_mark$clo._0(glue_mark$clo, "data-mode", $t48339);
        $eff = $rc_2717;
      }
    }
  }
  {
    let $eff;
    {
      let $t48341;
      {
        const $t48340 = m.credits;
        $t48341 = String($t48340);
      }
      {
        const $rc_2716 = glue_mark$clo._0(glue_mark$clo, "data-credits", $t48341);
        $eff = $rc_2716;
      }
    }
  }
  {
    let $eff;
    {
      let $t48344;
      {
        let $t48343;
        {
          const $t48342 = m.balls;
          {  };
          $t48343 = List$length_onto$List_R_pos_R_x_Float_y_Float_vel_R_x_Float_y_Float$Int($t48342, 0);
        }
        $t48344 = String($t48343);
      }
      {
        const $rc_2715 = glue_mark$clo._0(glue_mark$clo, "data-balls", $t48344);
        $eff = $rc_2715;
      }
    }
  }
  {
    let $eff;
    {
      let $t48347;
      {
        let $t48346;
        {
          const $t48345 = m.bank;
          $t48346 = $t48345.banked;
        }
        $t48347 = String($t48346);
      }
      {
        const $rc_2714 = glue_mark$clo._0(glue_mark$clo, "data-banked", $t48347);
        $eff = $rc_2714;
      }
    }
  }
  {
    let $t48349;
    {
      const $t48348 = m.paid;
      $t48349 = String($t48348);
    }
    {
      const $rc_2713 = glue_mark$clo._0(glue_mark$clo, "data-paid", $t48349);
      return $rc_2713;
    }
  }
}
const mark$clo = { _0: ($_, m) => mark(m) };

function frame(t) {
  {
    const s = glue_cell_get();
    {
      let dt;
      {
        let $t48351;
        {
          const $t48350 = s.last_t;
          $t48351 = ($t48350 > 0.);
        }
        if ($t48351 === true) {
          {
            const $t48352 = s.last_t;
            dt = (t - $t48352);
          }
        } else {
          dt = 0.;
        }
      }
      {
        const $p48363 = glue_input();
        {
          const l = $p48363._0;
          {
            const r = $p48363._1;
            {
              const launch = $p48363._2;
              {
                const start = $p48363._3;
                {
                  let $p48362;
                  {
                    const $t48353 = s.model;
                    {
                      const $t48354 = ({ left: l, right: r, launch: launch, start: start });
                      $p48362 = Spin$Game$tick($t48353, $t48354, dt);
                    }
                  }
                  {
                    const m = $p48362._0;
                    {
                      const cues = $p48362._1;
                      {
                        let $eff;
                        {
                          let $t48355;
                          $t48355 = ({ ...s, model: m, last_t: t });
                          {
                            const $rc_2719 = glue_cell_put$clo._0(glue_cell_put$clo, $t48355);
                            $eff = $rc_2719;
                          }
                        }
                      }
                      {
                        let $eff;
                        {
                          const f_i5954 = perform$clo;
                          {
                            const go_i5955 = { $: "$Clo_go$0_List_each_List_Cue_Fn_Cue_T_", _0: go$apply$0_List_each_List_Cue_Fn_Cue_T_, _1: f_i5954 };
                            $eff = go$apply$0_List_each_List_Cue_Fn_Cue_T_(go_i5955, cues);
                          }
                        }
                      }
                      {
                        let $p48361;
                        {
                          const $t47447_i5952 = (-96.);
                          $p48361 = { _0: 0., _1: $t47447_i5952, _2: 400., _3: 866. };
                        }
                        {
                          const x = $p48361._0;
                          {
                            const y = $p48361._1;
                            {
                              const w = $p48361._2;
                              {
                                const h = $p48361._3;
                                {
                                  let $eff;
                                  {
                                    const $t48356 = s.canvas;
                                    $eff = glue_fit$clo._0(glue_fit$clo, $t48356, x, y, w, h);
                                  }
                                }
                                {
                                  let $eff;
                                  {
                                    const $t48357 = s.ctx;
                                    {
                                      let $t48358;
                                      $t48358 = Spin$View$frame(m);
                                      {
                                        const $rc_2718 = glue_paint$clo._0(glue_paint$clo, $t48357, $t48358);
                                        $eff = $rc_2718;
                                      }
                                    }
                                  }
                                }
                                {
                                  let $eff;
                                  $eff = mark(m);
                                }
                                {
                                  const $t48360 = { $: "$Clo_$lam0_frame$0_frame", _0: $lam0_frame$apply$0_frame };
                                  return glue_request_frame$clo._0(glue_request_frame$clo, $t48360);
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
      let $t48364;
      {
        const id_i12979 = "table";
        {
          const $rc_2409_i12980 = dom_get_element_by_id$clo._0(dom_get_element_by_id$clo, "table");
          $t48364 = $rc_2409_i12980;
        }
      }
      switch ($t48364.$) {
        case "Some": {
          const $f48365 = $t48364._0;
          {
            const node = $f48365;
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
        let $t48366;
        {
          const node_i12977 = canvas;
          {
            const $rc_2455_i12978 = canvas_get_context$clo._0(canvas_get_context$clo, canvas);
            $t48366 = $rc_2455_i12978;
          }
        }
        switch ($t48366.$) {
          case "Some": {
            const $f48367 = $t48366._0;
            {
              const c = $f48367;
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
        const $p48373 = glue_seed_limbs();
        {
          const hi = $p48373._0;
          {
            const lo = $p48373._1;
            {
              let model;
              {
                let $t48368;
                {
                  let $t45821_i5958;
                  {
                    let $t45814_i14350;
                    {
                      const $t45813_i14349 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                      $t45814_i14350 = (($t45813_i14349 - 1) < 4611686018427387904 && ($t45813_i14349 - 1) >= -4611686018427387904 ? ($t45813_i14349 - 1) : march_int_ovf(($t45813_i14349 - 1), 1));
                    }
                    $t45821_i5958 = ((hi | 0) === hi && ($t45814_i14350 | 0) === $t45814_i14350 ? (hi & $t45814_i14350) : march_int_and(hi, $t45814_i14350));
                  }
                  {
                    let $t45822_i5959;
                    {
                      let $t45814_i14347;
                      {
                        const $t45813_i14346 = ((65536 * 65536) < 4611686018427387904 && (65536 * 65536) >= -4611686018427387904 ? (65536 * 65536) : march_int_ovf((65536 * 65536), 2));
                        $t45814_i14347 = (($t45813_i14346 - 1) < 4611686018427387904 && ($t45813_i14346 - 1) >= -4611686018427387904 ? ($t45813_i14346 - 1) : march_int_ovf(($t45813_i14346 - 1), 1));
                      }
                      $t45822_i5959 = ((lo | 0) === lo && ($t45814_i14347 | 0) === $t45814_i14347 ? (lo & $t45814_i14347) : march_int_and(lo, $t45814_i14347));
                    }
                    $t48368 = ({ hi: $t45821_i5958, lo: $t45822_i5959 });
                  }
                }
                {
                  const $t48369 = glue_load_best();
                  model = Spin$Game$boot($t48368, $t48369);
                }
              }
              {
                let $eff;
                {
                  let $t48370;
                  $t48370 = ({ model: model, ctx: ctx, canvas: canvas, last_t: 0. });
                  {
                    const $rc_2721 = glue_cell_put$clo._0(glue_cell_put$clo, $t48370);
                    $eff = $rc_2721;
                  }
                }
              }
              {
                let $eff;
                {
                  const $rc_2720 = glue_listen$clo._0(glue_listen$clo, canvas);
                  $eff = $rc_2720;
                }
              }
              {
                const $t48372 = { $: "$Clo_$lam0_launch$0_launch", _0: $lam0_launch$apply$0_launch };
                return glue_request_frame$clo._0(glue_request_frame$clo, $t48372);
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
          const $t978_i7839 = { $: "Nil" };
          return List$reverse_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(acc, $t978_i7839);
        }
      } else {
        switch (lst.$) {
          case "Nil": {
            {
              const $t978_i7837 = { $: "Nil" };
              return List$reverse_onto$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float$List_R_duration_Float_elapsed_Float_fresh_Int_from_Float_glow_Float_held_Bool_pos_Int_stops_List_Symbol_travel_Float(acc, $t978_i7837);
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
          const $t978_i7843 = { $: "Nil" };
          return List$reverse_onto$List_Symbol$List_Symbol(acc, $t978_i7843);
        }
      } else {
        switch (lst.$) {
          case "Nil": {
            {
              const $t978_i7841 = { $: "Nil" };
              return List$reverse_onto$List_Symbol$List_Symbol(acc, $t978_i7841);
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
                const $t45787_i8697 = (t >= acc);
                if ($t45787_i8697 === true) {
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
          const $rc_3440 = (!march_deep_eq(g, f));
          return $rc_3440;
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
              const $rc_3442 = { _0: g, _1: $t46211 };
              return $rc_3442;
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
    const $p46207_i14004 = l;
    {
      const t_i14005 = l._1;
      return (t_i14005 > 0.);
    }
  }
}
const $lam1_Spin_Game_fade$apply$1_Spin_Game_fade$clo = { _0: ($_, $clo, l) => $lam1_Spin_Game_fade$apply$1_Spin_Game_fade($clo, l) };

function $lam0_Spin_Game_plunge$apply$0_Spin_Game_plunge($clo, b) {
  {
    const speed = $clo._1;
    {
      let $t46367;
      $t46367 = Spin$Game$resting_in_lane(b);
      if ($t46367 === true) {
        {
          let $t46369;
          {
            const $t46368 = (-speed);
            $t46369 = ({ x: 0., y: $t46368 });
          }
          {
            const $rc_3443 = ({ ...b, vel: $t46369 });
            return $rc_3443;
          }
        }
      } else {
        return b;
      }
    }
  }
}
const $lam0_Spin_Game_plunge$apply$0_Spin_Game_plunge$clo = { _0: ($_, $clo, b) => $lam0_Spin_Game_plunge$apply$0_Spin_Game_plunge($clo, b) };

function $lam0_Spin_Game_auto_plunge$apply$0_Spin_Game_auto_plunge($clo, b) {
  {
    let $t46382;
    {
      const $t46381 = b.pos;
      $t46382 = Spin$Table$in_lane($t46381);
    }
    return (!$t46382);
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
            const $t46414 = m.table;
            return Spin$Physics$step_ball($t46414, l, r, h, b);
          }
        }
      }
    }
  }
}
const $lam0_Spin_Game_step_balls$apply$0_Spin_Game_step_balls$clo = { _0: ($_, $clo, b) => $lam0_Spin_Game_step_balls$apply$0_Spin_Game_step_balls($clo, b) };

function $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls($clo, x) {
  {
    const $p46417 = x;
    {
      const b = x._0;
      return b;
    }
  }
}
const $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls$clo = { _0: ($_, $clo, x) => $lam1_Spin_Game_step_balls$apply$1_Spin_Game_step_balls($clo, x) };

function $lam2_Spin_Game_step_balls$apply$2_Spin_Game_step_balls($clo, x) {
  {
    const $p46420 = x;
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
      let $t46438;
      {
        const $t46437 = b.pos;
        $t46438 = $t46437.y;
      }
      {
        let $t46440;
        {
          const $t46439 = m.table;
          $t46440 = $t46439.drain_y;
        }
        return ($t46438 < $t46440);
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
        const $t46885 = b.pos;
        return Spin$Physics$against(r, $t46885, acc, part);
      }
    }
  }
}
const $lam0_Spin_Physics_step_ball$apply$0_Spin_Physics_step_ball$clo = { _0: ($_, $clo, acc, part) => $lam0_Spin_Physics_step_ball$apply$0_Spin_Physics_step_ball($clo, acc, part) };

function $lam0_Spin_Reels_count$apply$0_Spin_Reels_count($clo, x) {
  {
    const s = $clo._1;
    {
      const $rc_3448 = march_deep_eq(x, s);
      return $rc_3448;
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
    const $jp_clo47006 = $clo._1;
    return $jp_clo47006._0($jp_clo47006);
  }
}
const $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays$clo = { _0: ($_, $clo) => $jp5_Spin_Reels_pays$apply$1_Spin_Reels_pays($clo) };

function $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop($clo, k) {
  {
    const r = $clo._1;
    {
      let $t47030;
      {
        const $t47029 = r.pos;
        $t47030 = (($t47029 + k) < 4611686018427387904 && ($t47029 + k) >= -4611686018427387904 ? ($t47029 + k) : march_int_ovf(($t47029 + k), 0));
      }
      return Spin$Reels$wrap($t47030);
    }
  }
}
const $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop$clo = { _0: ($_, $clo, k) => $lam0_Spin_Reels_target_stop$apply$0_Spin_Reels_target_stop($clo, k) };

function $lam1_Spin_Reels_target_stop$apply$1_Spin_Reels_target_stop($clo, i) {
  {
    const r = $clo._1;
    {
      let $t47033;
      $t47033 = Spin$Reels$stop(r, i);
      {
        const $t47034 = { $: "Blank" };
        {
          const $rc_3449 = march_deep_eq($t47033, $t47034);
          return $rc_3449;
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
        let $t47041;
        {
          let $t47040;
          {
            const $t47039 = r.pos;
            $t47040 = (($t47039 + k) < 4611686018427387904 && ($t47039 + k) >= -4611686018427387904 ? ($t47039 + k) : march_int_ovf(($t47039 + k), 0));
          }
          $t47041 = Spin$Reels$stop(r, $t47040);
        }
        {
          const $rc_3450 = march_deep_eq($t47041, s);
          return $rc_3450;
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
        let $t47048;
        {
          let $t47047;
          {
            let $t47046;
            {
              const $t47045 = r.pos;
              $t47046 = (($t47045 + k) < 4611686018427387904 && ($t47045 + k) >= -4611686018427387904 ? ($t47045 + k) : march_int_ovf(($t47045 + k), 0));
            }
            $t47047 = Spin$Reels$stop(r, $t47046);
          }
          {
            const $rc_3451 = Spin$Reels$rank($t47047);
            $t47048 = $rc_3451;
          }
        }
        {
          const $t47049 = Spin$Reels$rank(s);
          return ($t47048 >= $t47049);
        }
      }
    }
  }
}
const $lam1_Spin_Reels_roll_to$apply$1_Spin_Reels_roll_to$clo = { _0: ($_, $clo, k) => $lam1_Spin_Reels_roll_to$apply$1_Spin_Reels_roll_to($clo, k) };

function $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning($clo, r) {
  {
    const $t47145 = r.duration;
    return ($t47145 > 0.);
  }
}
const $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning$clo = { _0: ($_, $clo, r) => $lam0_Spin_Reels_turning$apply$0_Spin_Reels_turning($clo, r) };

function $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold($clo, x) {
  {
    const $rc_3452 = x.held;
    return $rc_3452;
  }
}
const $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold$clo = { _0: ($_, $clo, x) => $lam0_Spin_Reels_hold$apply$0_Spin_Reels_hold($clo, x) };

function $lam0_Spin_Table_arch$apply$0_Spin_Table_arch($clo, i) {
  {
    const n = $clo._1;
    {
      let $t47267;
      $t47267 = Spin$Table$arch_point(n, i);
      {
        let $t47269;
        {
          const $t47268 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
          $t47269 = Spin$Table$arch_point(n, $t47268);
        }
        return { $: "Wall", _0: $t47267, _1: $t47269, _2: 0.5 };
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
                let $t47452;
                {
                  const $t47450 = n.tau;
                  {
                    const $t47451 = i;
                    $t47452 = ($t47450 * $t47451);
                  }
                }
                a = ($t47452 / 12.);
              }
              {
                let $t47455;
                {
                  let $t47454;
                  {
                    const $t47453 = Math.cos(a);
                    $t47454 = (rx * $t47453);
                  }
                  $t47455 = (cx + $t47454);
                }
                {
                  let $t47458;
                  {
                    let $t47457;
                    {
                      const $t47456 = Math.sin(a);
                      $t47457 = (ry * $t47456);
                    }
                    $t47458 = (cy + $t47457);
                  }
                  return ({ x: $t47455, y: $t47458 });
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
                    let $t47609;
                    {
                      let $t47607;
                      {
                        const $t47606 = k;
                        $t47607 = (frac - $t47606);
                      }
                      $t47609 = ($t47607 * 32.);
                    }
                    y = (line_y + $t47609);
                  }
                  {
                    let s;
                    s = Spin$Reels$stop(r, j);
                    {
                      let fresh;
                      {
                        let $t47613;
                        {
                          const $t47611 = march_int_mod_euclid(j, 8);
                          {
                            const $t47612 = r.fresh;
                            $t47613 = ($t47611 === $t47612);
                          }
                        }
                        {
                          let $t47615;
                          {
                            const $t47614 = r.glow;
                            $t47615 = ($t47614 > 0.);
                          }
                          fresh = ($t47613 && $t47615);
                        }
                      }
                      {
                        let halo;
                        if (fresh === true) {
                          {
                            let $t47619;
                            {
                              const $t47616 = (x0 + 30.);
                              {
                                let $t47618;
                                {
                                  const $t47617 = r.glow;
                                  $t47618 = Spin$Draw$rgba(255, 230, 120, $t47617);
                                }
                                $t47619 = { $: "Glow", _0: $t47616, _1: y, _2: 26., _3: $t47618 };
                              }
                            }
                            {
                              const $t47620 = { $: "Nil" };
                              halo = { $: "Cons", _0: $t47619, _1: $t47620 };
                            }
                          }
                        } else {
                          halo = { $: "Nil" };
                        }
                        {
                          const $t47621 = m.num;
                          {
                            const $t47622 = (x0 + 30.);
                            {
                              let $t47623;
                              {
                                let $rc_3453;
                                $rc_3453 = Spin$View$symbol($t47621, s, $t47622, y, 1.);
                                $t47623 = $rc_3453;
                              }
                              {
                                const xs_i14006 = halo;
                                {
                                  const ys_i14007 = $t47623;
                                  switch (xs_i14006.$) {
                                    case "Nil": {
                                      return $t47623;
                                      break;
                                    }
                                    case "Cons": {
                                      const $f987_i14008 = xs_i14006._0;
                                      const $f988_i14009 = xs_i14006._1;
                                      {
                                        const t_i14010 = $f988_i14009;
                                        {
                                          const h_i14011 = $f987_i14008;
                                          {
                                            const $trmc11_i14012 = { $: "Cons", _0: h_i14011, _1: null };
                                            List$append$dps$List_Op$List_Op$List_Op(t_i14010, $t47623, $trmc11_i14012);
                                            return $trmc11_i14012;
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
                let $t47703;
                {
                  const $t47702 = (ww / 2.);
                  $t47703 = (wx + $t47702);
                }
                {
                  let $t47706;
                  {
                    let $t47705;
                    {
                      const $t47704 = i;
                      $t47705 = ($t47704 - 2.);
                    }
                    $t47706 = ($t47705 * 16.);
                  }
                  cx = ($t47703 + $t47706);
                }
              }
              {
                let $t47708;
                {
                  const $t47707 = b.banked;
                  $t47708 = (i < $t47707);
                }
                if ($t47708 === true) {
                  {
                    let $t47710;
                    {
                      const $t47709 = (wy + wh);
                      $t47710 = ($t47709 + 14.);
                    }
                    return { $: "Disc", _0: cx, _1: $t47710, _2: 5., _3: "#5cf2ff" };
                  }
                } else {
                  {
                    let $t47712;
                    {
                      const $t47711 = (wy + wh);
                      $t47712 = ($t47711 + 14.);
                    }
                    return { $: "Ring", _0: cx, _1: $t47712, _2: 5., _3: 1.5, _4: "#3d4d6a" };
                  }
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
          const $t48094 = (top + 6.);
          {
            let $t48100;
            {
              let $t48099;
              {
                const $t48095 = i;
                {
                  let $t48098;
                  {
                    let $t48097;
                    {
                      const $t48096 = m.pull;
                      $t48097 = (20. * $t48096);
                    }
                    $t48098 = (40. - $t48097);
                  }
                  $t48099 = ($t48095 * $t48098);
                }
              }
              $t48100 = ($t48099 / 6.);
            }
            y = ($t48094 + $t48100);
          }
        }
        {
          const $t48101 = ({ x: 356., y: y });
          {
            let $t48103;
            {
              const $t48102 = (y + 3.);
              $t48103 = ({ x: 374., y: $t48102 });
            }
            return Spin$Draw$stick($t48101, $t48103, 2., "#9aa3b5");
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

function $lam0_frame$apply$0_frame($clo, next) {
  return frame(next);
}
const $lam0_frame$apply$0_frame$clo = { _0: ($_, $clo, next) => $lam0_frame$apply$0_frame($clo, next) };

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
              const $t978_i8845 = { $: "Nil" };
              return List$reverse_onto$List_Hit$List_Hit(acc, $t978_i8845);
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
              const $t978_i8847 = { $: "Nil" };
              return List$reverse_onto$List_Cue$List_Cue(acc, $t978_i8847);
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
              const $t978_i8849 = { $: "Nil" };
              return List$reverse_onto$List_ReelEvent$List_ReelEvent(acc, $t978_i8849);
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
              const $t978_i8851 = { $: "Nil" };
              return List$reverse_onto$List_Part$List_Part(acc, $t978_i8851);
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
              const $t978_i8853 = { $: "Nil" };
              return List$reverse_onto$List_Op$List_Op(acc, $t978_i8853);
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
