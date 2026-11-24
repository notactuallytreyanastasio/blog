import { march_float_round, march_float_to_string, march_int_and, march_int_div, march_int_div_euclid, march_int_div_floor, march_int_mod, march_int_mod_euclid, march_int_mod_floor, march_int_not, march_int_or, march_int_ovf, march_int_popcount, march_int_shl, march_int_shr, march_int_wrapping_add, march_int_wrapping_mul, march_int_wrapping_sub, march_int_xor, march_string_byte_length, march_string_ends_with, march_string_to_float, march_unix_time, march_unix_time_ms } from "./march_runtime.mjs";

import { synth_cell_put, synth_cell_get } from "./skee_synth_cell.mjs";
import { worklet_register } from "./skee_worklet.mjs";


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
const synth_cell_get$clo = { _0: ($_, ) => synth_cell_get() };
const synth_cell_put$clo = { _0: ($_, p0) => synth_cell_put(p0) };
const worklet_register$clo = { _0: ($_, p0, p1) => worklet_register(p0, p1) };

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

function __eq_Skee$App$Intent(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TapStart": {
      return true;
    }
    case "TapHowToPlay": {
      return true;
    }
    case "TapPickRoom": {
      if (!__eq_Room(a._0, b._0)) return false;
      return true;
    }
    case "TapOpenShop": {
      return true;
    }
    case "TapCloseShop": {
      return true;
    }
    case "TapBuyPrize": {
      if (!__eq_Prize(a._0, b._0)) return false;
      return true;
    }
    case "TapOpenGuide": {
      return true;
    }
    case "TapCloseGuide": {
      return true;
    }
    case "TapReplayLesson": {
      return true;
    }
    case "TapArrivalNext": {
      return true;
    }
    case "TapOpenHost": {
      return true;
    }
    case "TapCloseHost": {
      return true;
    }
    case "TapGotIt": {
      return true;
    }
    case "TapSkipWalkthrough": {
      return true;
    }
    case "TapPull": {
      return true;
    }
    case "TapSetBet": {
      if (!__eq_Bet(a._0, b._0)) return false;
      return true;
    }
    case "TapChooseBall": {
      if (!__eq_BallKind(a._0, b._0)) return false;
      return true;
    }
    case "TapArm": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TapSelectOffer": {
      if (!__eq_Option(a._0, b._0)) return false;
      return true;
    }
    case "TapBuyOffer": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TapReroll": {
      return true;
    }
    case "TapLeaveCounter": {
      return true;
    }
    case "TapCharm": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TapAskNewGame": {
      return true;
    }
    case "TapKeepPlaying": {
      return true;
    }
    case "TapNewRun": {
      return true;
    }
    case "TapHostNudge": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TapHostSend": {
      return true;
    }
    case "TapHostDeal": {
      return true;
    }
    case "TapHostRetry": {
      return true;
    }
    case "TapHostConsent": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TapHostReconsider": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$App$CallKey(a, b) {
  if (a.key_table !== b.key_table) return false;
  if (a.key_call !== b.key_call) return false;
  return true;
}

function __eq_Skee$App$Msg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "MsgTick": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "MsgPointerDown": {
      if (!__eq_FlickSample(a._0, b._0)) return false;
      return true;
    }
    case "MsgPointerMove": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "MsgPointerUp": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "MsgPointerCancel": {
      return true;
    }
    case "MsgTap": {
      if (!__eq_Intent(a._0, b._0)) return false;
      return true;
    }
    case "MsgResize": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "MsgVisible": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "MsgAutoplay": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "MsgHostDraft": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "MsgHostReply": {
      if (!__eq_CallKey(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "MsgHostFailed": {
      if (!__eq_CallKey(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$App$SaveKey(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "KeyWallet": {
      return true;
    }
    case "KeyRun": {
      return true;
    }
    case "KeyTips": {
      return true;
    }
    case "KeyWalkthroughDone": {
      return true;
    }
    case "KeyArrivalDone": {
      return true;
    }
    case "KeyHostConsent": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$App$Impact(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ImpactLight": {
      return true;
    }
    case "ImpactHeavy": {
      return true;
    }
    case "ImpactRigid": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$App$Notice(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NoticeWarning": {
      return true;
    }
    case "NoticeError": {
      return true;
    }
    case "NoticeSuccess": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$App$Haptic(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HapticImpact": {
      if (!__eq_Impact(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "HapticNotify": {
      if (!__eq_Notice(a._0, b._0)) return false;
      return true;
    }
    case "HapticBuzz": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "HapticBuzzStop": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$App$Effect(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "FxSound": {
      if (!__eq_Skee$Synth$Sound(a._0, b._0)) return false;
      return true;
    }
    case "FxRumble": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "FxDrum": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "FxSave": {
      if (!__eq_SaveKey(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "FxHaptic": {
      if (!__eq_Haptic(a._0, b._0)) return false;
      return true;
    }
    case "FxHostPost": {
      if (!__eq_CallKey(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$App$SavedStrings(a, b) {
  if (!__eq_Option(a.saved_wallet, b.saved_wallet)) return false;
  if (!__eq_Option(a.saved_run, b.saved_run)) return false;
  if (!__eq_Option(a.saved_tips, b.saved_tips)) return false;
  if (!__eq_Option(a.saved_walk_done, b.saved_walk_done)) return false;
  if (!__eq_Option(a.saved_arrival_done, b.saved_arrival_done)) return false;
  if (!__eq_Option(a.saved_host_consent, b.saved_host_consent)) return false;
  return true;
}

function __eq_Skee$App$Parked(a, b) {
  if (!__eq_Skee$U64$U64(a.parked_seed, b.parked_seed)) return false;
  if (!__eq_List(a.parked_actions, b.parked_actions)) return false;
  if (!__eq_RunState(a.parked_run, b.parked_run)) return false;
  return true;
}

function __eq_Skee$App$TrailPoint(a, b) {
  if (a.trail_x !== b.trail_x) return false;
  if (a.trail_y !== b.trail_y) return false;
  if (a.trail_t !== b.trail_t) return false;
  return true;
}

function __eq_Skee$App$BallMark(a, b) {
  if (a.mark_along !== b.mark_along) return false;
  if (a.mark_t !== b.mark_t) return false;
  return true;
}

function __eq_Skee$App$Model(a, b) {
  if (!__eq_Skee$Consts$Consts(a.k, b.k)) return false;
  if (!__eq_Skee$World$World(a.world, b.world)) return false;
  if (!__eq_Skee$Rooms$CabinetPalette(a.palette, b.palette)) return false;
  if (!__eq_Skee$Camera$Rig(a.rig, b.rig)) return false;
  if (!__eq_Skee$Camera$Viewport(a.viewport, b.viewport)) return false;
  if (!__eq_Skee$Scene$Keep(a.keep, b.keep)) return false;
  if (!__eq_Skee$Scene$Scenery(a.scenery, b.scenery)) return false;
  if (!__eq_Skee$Presentation$Presentation(a.pres, b.pres)) return false;
  if (!__eq_RunState(a.run, b.run)) return false;
  if (!__eq_Skee$U64$U64(a.run_seed, b.run_seed)) return false;
  if (!__eq_List(a.actions_rev, b.actions_rev)) return false;
  if (!__eq_Tickets(a.extra, b.extra)) return false;
  if (!__eq_Wallet(a.wallet, b.wallet)) return false;
  if (!__eq_HudScreen(a.screen, b.screen)) return false;
  if (!__eq_Option(a.selected_offer, b.selected_offer)) return false;
  if (!__eq_Option(a.selected_charm, b.selected_charm)) return false;
  if (a.fold !== b.fold) return false;
  if (a.shop_open !== b.shop_open) return false;
  if (a.confirm_new !== b.confirm_new) return false;
  if (a.guide_open !== b.guide_open) return false;
  if (!__eq_Option(a.walk, b.walk)) return false;
  if (!__eq_Option(a.arrival, b.arrival)) return false;
  if (!__eq_TipTracker(a.tips, b.tips)) return false;
  if (!__eq_Option(a.parked, b.parked)) return false;
  if (a.walk_done !== b.walk_done) return false;
  if (a.arrival_done !== b.arrival_done) return false;
  if (!__eq_Option(a.host, b.host)) return false;
  if (a.host_tables !== b.host_tables) return false;
  if (!__eq_Skee$Host$HostConsent(a.consent, b.consent)) return false;
  if (a.draft !== b.draft) return false;
  if (!__eq_Bet(a.bet, b.bet)) return false;
  if (!__eq_List(a.autoplay, b.autoplay)) return false;
  if (!__eq_List(a.flick, b.flick)) return false;
  if (!__eq_List(a.trail, b.trail)) return false;
  if (a.line !== b.line) return false;
  if (a.aiming !== b.aiming) return false;
  if (!__eq_Option(a.held, b.held)) return false;
  if (!__eq_Option(a.last_render, b.last_render)) return false;
  if (a.now !== b.now) return false;
  if (!__eq_Option(a.last_ball, b.last_ball)) return false;
  if (a.rumble_sent !== b.rumble_sent) return false;
  if (a.drum_sent !== b.drum_sent) return false;
  if (!__eq_Option(a.buzz, b.buzz)) return false;
  if (!__eq_Skee$Rng$Rng(a.seeds, b.seeds)) return false;
  if (!__eq_List(a.out, b.out)) return false;
  return true;
}

function __eq_Skee$App$Layer(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LayerBase": {
      return true;
    }
    case "LayerCoachBlock": {
      return true;
    }
    case "LayerConfirmNew": {
      return true;
    }
    case "LayerShop": {
      return true;
    }
    case "LayerGuide": {
      return true;
    }
    case "LayerArrival": {
      return true;
    }
    case "LayerHost": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$App$TrailDot(a, b) {
  if (!__eq_ScreenPoint(a.dot, b.dot)) return false;
  if (a.dot_age !== b.dot_age) return false;
  return true;
}

function __eq_Skee$App$HostShown(a, b) {
  if (!__eq_Skee$Host$HostSession(a.table, b.table)) return false;
  if (a.ai_chat !== b.ai_chat) return false;
  if (a.asking !== b.asking) return false;
  if (a.host_draft !== b.host_draft) return false;
  return true;
}

function __eq_Skee$App$AppHud(a, b) {
  if (!__eq_HudState(a.app_hud, b.app_hud)) return false;
  if (!__eq_Wallet(a.app_wallet, b.app_wallet)) return false;
  if (!__eq_Option(a.coach, b.coach)) return false;
  if (a.shop_open_now !== b.shop_open_now) return false;
  if (a.confirm_new_now !== b.confirm_new_now) return false;
  if (a.guide_open_now !== b.guide_open_now) return false;
  if (!__eq_List(a.guide_topics, b.guide_topics)) return false;
  if (!__eq_Option(a.arrival_line, b.arrival_line)) return false;
  if (!__eq_List(a.known, b.known)) return false;
  if (!__eq_List(a.guide_line, b.guide_line)) return false;
  if (a.aiming_now !== b.aiming_now) return false;
  if (!__eq_List(a.trail_dots, b.trail_dots)) return false;
  if (!__eq_Option(a.host_shown, b.host_shown)) return false;
  if (!__eq_Layer(a.top, b.top)) return false;
  return true;
}

function __eq_Skee$App$Opening(a, b) {
  if (!__eq_RunState(a.open_run, b.open_run)) return false;
  if (!__eq_Skee$U64$U64(a.open_seed, b.open_seed)) return false;
  if (!__eq_Tickets(a.open_extra, b.open_extra)) return false;
  if (!__eq_List(a.open_actions, b.open_actions)) return false;
  if (!__eq_Wallet(a.open_wallet, b.open_wallet)) return false;
  if (!__eq_List(a.open_saves, b.open_saves)) return false;
  return true;
}

function __eq_Skee$App$Carry(a, b) {
  if (!__eq_Wallet(a.carry_wallet, b.carry_wallet)) return false;
  if (!__eq_List(a.carry_tips, b.carry_tips)) return false;
  if (a.carry_walk_done !== b.carry_walk_done) return false;
  if (a.carry_arrival_done !== b.carry_arrival_done) return false;
  if (!__eq_Skee$Camera$Viewport(a.carry_viewport, b.carry_viewport)) return false;
  if (!__eq_Skee$Rng$Rng(a.carry_seeds, b.carry_seeds)) return false;
  if (a.carry_now !== b.carry_now) return false;
  if (!__eq_Skee$Host$HostConsent(a.carry_consent, b.carry_consent)) return false;
  if (a.carry_tables !== b.carry_tables) return false;
  return true;
}

function __eq_Skee$Maths$Vec2(a, b) {
  if (a.x !== b.x) return false;
  if (a.y !== b.y) return false;
  return true;
}

function __eq_Skee$World$Vec3(a, b) {
  if (a.x !== b.x) return false;
  if (a.y !== b.y) return false;
  if (a.z !== b.z) return false;
  return true;
}

function __eq_Skee$World$World(a, b) {
  if (!__eq_Table(a.table, b.table)) return false;
  if (a.board_tilt !== b.board_tilt) return false;
  if (a.hump_height !== b.hump_height) return false;
  if (a.lane_scale !== b.lane_scale) return false;
  if (a.board_scale !== b.board_scale) return false;
  if (a.incline_sin !== b.incline_sin) return false;
  if (a.incline_cos !== b.incline_cos) return false;
  if (a.tilt_sin !== b.tilt_sin) return false;
  if (a.tilt_cos !== b.tilt_cos) return false;
  return true;
}

function __eq_Skee$Camera$Rig(a, b) {
  if (!__eq_Vec3(a.eye, b.eye)) return false;
  if (!__eq_Vec3(a.target, b.target)) return false;
  if (a.fov !== b.fov) return false;
  return true;
}

function __eq_Skee$Camera$Viewport(a, b) {
  if (a.width !== b.width) return false;
  if (a.height !== b.height) return false;
  return true;
}

function __eq_Skee$Camera$Framing(a, b) {
  if (!__eq_Vec3(a.near_point, b.near_point)) return false;
  if (!__eq_Vec3(a.hump_point, b.hump_point)) return false;
  if (!__eq_Vec3(a.top_point, b.top_point)) return false;
  return true;
}

function __eq_Skee$Camera$Lens(a, b) {
  if (!__eq_Vec3(a.eye, b.eye)) return false;
  if (!__eq_Vec3(a.forward, b.forward)) return false;
  if (!__eq_Vec3(a.right, b.right)) return false;
  if (!__eq_Vec3(a.up, b.up)) return false;
  if (a.tan_half !== b.tan_half) return false;
  if (a.aspect !== b.aspect) return false;
  if (a.width !== b.width) return false;
  if (a.height !== b.height) return false;
  return true;
}

function __eq_Skee$Camera$Seen(a, b) {
  if (a.across !== b.across) return false;
  if (a.rise !== b.rise) return false;
  if (a.depth !== b.depth) return false;
  return true;
}

function __eq_Skee$Camera$Sighting(a, b) {
  if (a.near_rise !== b.near_rise) return false;
  if (a.near_depth !== b.near_depth) return false;
  if (a.hump_rise !== b.hump_rise) return false;
  if (a.hump_depth !== b.hump_depth) return false;
  if (a.top_rise !== b.top_rise) return false;
  if (a.top_depth !== b.top_depth) return false;
  return true;
}

function __eq_Skee$Camera$Best(a, b) {
  if (a.err !== b.err) return false;
  if (a.fi !== b.fi) return false;
  if (a.hi !== b.hi) return false;
  if (a.zi !== b.zi) return false;
  if (a.li !== b.li) return false;
  return true;
}

function __eq_Skee$Consts$Consts(a, b) {
  if (a.pi !== b.pi) return false;
  if (a.tau !== b.tau) return false;
  if (a.dt !== b.dt) return false;
  if (a.unit53 !== b.unit53) return false;
  if (a.floor_u1 !== b.floor_u1) return false;
  if (a.infinity !== b.infinity) return false;
  if (a.nan !== b.nan) return false;
  if (a.marshmallow_drawn !== b.marshmallow_drawn) return false;
  return true;
}

function __eq_Skee$SwiftText$SwiftChar(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SwiftChar": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$SwiftText$BreakState(a, b) {
  if (a.prev_class !== b.prev_class) return false;
  if (a.pict_run !== b.pict_run) return false;
  if (a.ri_run !== b.ri_run) return false;
  if (a.conjunct !== b.conjunct) return false;
  return true;
}

function __eq_Skee$HostGuard$Concern(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ConcernCrisis": {
      return true;
    }
    case "ConcernPersonalInfo": {
      return true;
    }
    case "ConcernAdult": {
      return true;
    }
    case "ConcernRealMoney": {
      return true;
    }
    case "ConcernOffTopic": {
      return true;
    }
    case "ConcernTrickery": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Host$HostPerson(a, b) {
  if (a.host_name !== b.host_name) return false;
  if (a.manner !== b.manner) return false;
  return true;
}

function __eq_Skee$Host$ChatRole(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "RoleSystem": {
      return true;
    }
    case "RoleUser": {
      return true;
    }
    case "RoleAssistant": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Host$ChatMessage(a, b) {
  if (!__eq_ChatRole(a.chat_role, b.chat_role)) return false;
  if (a.content !== b.content) return false;
  return true;
}

function __eq_Skee$Host$Speaker(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SpeakerHost": {
      return true;
    }
    case "SpeakerPlayer": {
      return true;
    }
    case "SpeakerStage": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Host$HostTerms(a, b) {
  if (a.terms_nights !== b.terms_nights) return false;
  if (a.terms_tickets !== b.terms_tickets) return false;
  if (a.terms_credit !== b.terms_credit) return false;
  return true;
}

function __eq_Skee$Host$HostReply(a, b) {
  if (a.say !== b.say) return false;
  if (!__eq_HostTerms(a.reply_terms, b.reply_terms)) return false;
  if (a.mood !== b.mood) return false;
  if (a.walk !== b.walk) return false;
  if (!__eq_Option(a.off_topic, b.off_topic)) return false;
  return true;
}

function __eq_Skee$Host$HaggleLine(a, b) {
  if (!__eq_Speaker(a.speaker, b.speaker)) return false;
  if (a.line_text !== b.line_text) return false;
  if (!__eq_Option(a.line_reply, b.line_reply)) return false;
  return true;
}

function __eq_Skee$Host$HaggleStatus(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HaggleOpen": {
      return true;
    }
    case "HaggleSigned": {
      return true;
    }
    case "HaggleWalked": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Host$Haggle(a, b) {
  if (!__eq_Room(a.haggle_room, b.haggle_room)) return false;
  if (!__eq_HostPerson(a.haggle_host, b.haggle_host)) return false;
  if (!__eq_Skee$Rooms$HostVisit(a.haggle_visit, b.haggle_visit)) return false;
  if (a.budget !== b.budget) return false;
  if (!__eq_Skee$U64$U64(a.haggle_seed, b.haggle_seed)) return false;
  if (!__eq_Comp(a.haggle_offer, b.haggle_offer)) return false;
  if (a.patience !== b.patience) return false;
  if (!__eq_List(a.lines, b.lines)) return false;
  if (!__eq_HaggleStatus(a.haggle_status, b.haggle_status)) return false;
  return true;
}

function __eq_Skee$Host$ReplyFault(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "FaultNotJson": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "FaultField": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "FaultEmptySay": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Host$Perk(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PerkNights": {
      return true;
    }
    case "PerkTickets": {
      return true;
    }
    case "PerkCredit": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Host$HostConsent(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ConsentUnasked": {
      return true;
    }
    case "ConsentGiven": {
      return true;
    }
    case "ConsentRefused": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Host$HostAsk(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "AskGreeting": {
      return true;
    }
    case "AskReply": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Host$HostCall(a, b) {
  if (a.call_id !== b.call_id) return false;
  if (!__eq_HostAsk(a.call_ask, b.call_ask)) return false;
  if (a.attempt !== b.attempt) return false;
  if (!__eq_List(a.base_messages, b.base_messages)) return false;
  if (!__eq_List(a.call_messages, b.call_messages)) return false;
  return true;
}

function __eq_Skee$Host$HostFailure(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "FailNetwork": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "FailHttp": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "FailTruncated": {
      return true;
    }
    case "FailMalformed": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "FailUnreadable": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Host$HostWait(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "WaitNothing": {
      return true;
    }
    case "WaitFor": {
      if (!__eq_HostCall(a._0, b._0)) return false;
      return true;
    }
    case "WaitFailed": {
      if (!__eq_HostFailure(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Host$HostSession(a, b) {
  if (!__eq_Haggle(a.session_haggle, b.session_haggle)) return false;
  if (!__eq_HostConsent(a.consent, b.consent)) return false;
  if (!__eq_HostWait(a.pending, b.pending)) return false;
  if (a.greeting_hidden !== b.greeting_hidden) return false;
  if (!__eq_Option(a.greeting_failed, b.greeting_failed)) return false;
  if (a.next_call !== b.next_call) return false;
  return true;
}

function __eq_Skee$Host$NumberToken(a, b) {
  if (a.negative !== b.negative) return false;
  if (a.int_digits !== b.int_digits) return false;
  if (a.frac_digits !== b.frac_digits) return false;
  if (!__eq_Option(a.exp_text, b.exp_text)) return false;
  return true;
}

function __eq_Skee$Host$DecodedInt(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ReadsAsDouble": {
      return true;
    }
    case "ReadsBig": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "DecoderRefuses": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$HudState$ScreenPoint(a, b) {
  if (a.sx !== b.sx) return false;
  if (a.sy !== b.sy) return false;
  return true;
}

function __eq_Skee$HudState$HudScreen(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TitleScreen": {
      return true;
    }
    case "GameScreen": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$HudState$HostSeam(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "HostClosed": {
      return true;
    }
    case "HostAtTable": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$HudState$Machine(a, b) {
  if (!__eq_Three(a.positions, b.positions)) return false;
  if (!__eq_Bet(a.machine_bet, b.machine_bet)) return false;
  if (!__eq_List(a.affordable, b.affordable)) return false;
  if (a.can_pull !== b.can_pull) return false;
  if (a.machine_free !== b.machine_free) return false;
  if (a.free_left !== b.free_left) return false;
  if (!__eq_List(a.wins, b.wins)) return false;
  if (a.machine_teasing !== b.machine_teasing) return false;
  if (!__eq_Room(a.machine_room, b.machine_room)) return false;
  if (!__eq_Progressive(a.machine_progressive, b.machine_progressive)) return false;
  if (a.show_bets !== b.show_bets) return false;
  return true;
}

function __eq_Skee$HudState$HudTally(a, b) {
  if (!__eq_Chips(a.tally_chips, b.tally_chips)) return false;
  if (a.tally_mult !== b.tally_mult) return false;
  if (a.label !== b.label) return false;
  return true;
}

function __eq_Skee$HudState$HudBanner(a, b) {
  if (a.title !== b.title) return false;
  if (a.sub !== b.sub) return false;
  if (a.progress !== b.progress) return false;
  return true;
}

function __eq_Skee$HudState$ScreenPopup(a, b) {
  if (a.screen_text !== b.screen_text) return false;
  if (!__eq_PopupKind(a.screen_kind, b.screen_kind)) return false;
  if (!__eq_ScreenPoint(a.at, b.at)) return false;
  if (a.screen_age !== b.screen_age) return false;
  return true;
}

function __eq_Skee$HudState$Hint(a, b) {
  if (a.hint_text !== b.hint_text) return false;
  if (!__eq_Option(a.hint_symbol, b.hint_symbol)) return false;
  if (a.after !== b.after) return false;
  if (a.hint_hot !== b.hint_hot) return false;
  return true;
}

function __eq_Skee$HudState$RunOver(a, b) {
  if (a.won !== b.won) return false;
  if (!__eq_RunStats(a.over_stats, b.over_stats)) return false;
  return true;
}

function __eq_Skee$HudState$TallyFold(a, b) {
  if (!__eq_Chips(a.folded_chips, b.folded_chips)) return false;
  if (a.folded_mult !== b.folded_mult) return false;
  return true;
}

function __eq_Skee$HudState$HudInputs(a, b) {
  if (!__eq_PerHole(a.hole_on_screen, b.hole_on_screen)) return false;
  if (!__eq_ScreenPoint(a.center, b.center)) return false;
  if (!__eq_Option(a.selected_offer, b.selected_offer)) return false;
  if (!__eq_Option(a.selected_charm, b.selected_charm)) return false;
  if (!__eq_HudScreen(a.screen, b.screen)) return false;
  if (!__eq_Bet(a.bet, b.bet)) return false;
  return true;
}

function __eq_Skee$HudState$HudState(a, b) {
  if (!__eq_HudScreen(a.hud_screen, b.hud_screen)) return false;
  if (a.hud_ante !== b.hud_ante) return false;
  if (a.antes !== b.antes) return false;
  if (a.round_title !== b.round_title) return false;
  if (a.is_boss !== b.is_boss) return false;
  if (a.boss_name !== b.boss_name) return false;
  if (a.boss_blurb !== b.boss_blurb) return false;
  if (!__eq_Points(a.score, b.score)) return false;
  if (!__eq_Points(a.hud_target, b.hud_target)) return false;
  if (!__eq_Tickets(a.hud_tickets, b.hud_tickets)) return false;
  if (a.hud_heat !== b.hud_heat) return false;
  if (a.heat_max !== b.heat_max) return false;
  if (a.hud_fever !== b.hud_fever) return false;
  if (!__eq_Three(a.targets, b.targets)) return false;
  if (a.hud_combo !== b.hud_combo) return false;
  if (!__eq_Option(a.machine, b.machine)) return false;
  if (!__eq_Three(a.frame, b.frame)) return false;
  if (a.frame_number !== b.frame_number) return false;
  if (a.frames_total !== b.frames_total) return false;
  if (a.balls_left !== b.balls_left) return false;
  if (!__eq_List(a.hud_charms, b.hud_charms)) return false;
  if (!__eq_List(a.hud_power_ups, b.hud_power_ups)) return false;
  if (!__eq_Option(a.hud_armed, b.hud_armed)) return false;
  if (!__eq_Option(a.counter, b.counter)) return false;
  if (!__eq_Option(a.over, b.over)) return false;
  if (!__eq_Option(a.tally, b.tally)) return false;
  if (!__eq_Option(a.hud_banner, b.hud_banner)) return false;
  if (!__eq_List(a.hud_popups, b.hud_popups)) return false;
  if (!__eq_Option(a.hud_selected_offer, b.hud_selected_offer)) return false;
  if (!__eq_Option(a.hud_selected_charm, b.hud_selected_charm)) return false;
  if (a.busy !== b.busy) return false;
  if (a.first_throw !== b.first_throw) return false;
  if (!__eq_Option(a.hint, b.hint)) return false;
  if (!__eq_List(a.throws_meter, b.throws_meter)) return false;
  if (!__eq_BallKind(a.hud_ball, b.hud_ball)) return false;
  if (a.rack !== b.rack) return false;
  if (!__eq_Option(a.hot_at, b.hot_at)) return false;
  if (a.hud_clock !== b.hud_clock) return false;
  if (a.shower !== b.shower) return false;
  if (!__eq_HostSeam(a.host, b.host)) return false;
  return true;
}

function __eq_Skee$HudView$Prop(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Prop": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$HudView$Html(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Tag": {
      if (a._0 !== b._0) return false;
      if (!__eq_List(a._1, b._1)) return false;
      if (!__eq_List(a._2, b._2)) return false;
      return true;
    }
    case "Words": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$HudView$HudAction(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ActIntent": {
      if (!__eq_Intent(a._0, b._0)) return false;
      return true;
    }
    case "ActTopic": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ActPageBack": {
      return true;
    }
    case "ActPageNext": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$HudView$GuideAt(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "GuideContents": {
      return true;
    }
    case "GuideReading": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$HudView$LeverGrip(a, b) {
  if (a.grip_x !== b.grip_x) return false;
  if (a.grip_y !== b.grip_y) return false;
  if (a.grip_drag !== b.grip_drag) return false;
  if (a.grip_moved !== b.grip_moved) return false;
  return true;
}

function __eq_Skee$HudView$LeverLetGo(a, b) {
  if (a.letgo_from !== b.letgo_from) return false;
  if (a.letgo_at !== b.letgo_at) return false;
  return true;
}

function __eq_Skee$HudView$LeverHold(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LeverRest": {
      return true;
    }
    case "LeverHeld": {
      if (!__eq_LeverGrip(a._0, b._0)) return false;
      return true;
    }
    case "LeverSpring": {
      if (!__eq_LeverLetGo(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$HudView$LeverTouch(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LeverDown": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "LeverMove": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "LeverUp": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "LeverLost": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$HudView$HudLocal(a, b) {
  if (!__eq_GuideAt(a.guide_at, b.guide_at)) return false;
  if (!__eq_LeverHold(a.lever, b.lever)) return false;
  return true;
}

function __eq_Skee$HudView$Pane(a, b) {
  if (a.pane_id !== b.pane_id) return false;
  if (!__eq_Html(a.pane, b.pane)) return false;
  return true;
}

function __eq_Skee$HudView$OpenClip(a, b) {
  if (!__eq_List(a.before_rev, b.before_rev)) return false;
  if (a.clip_id !== b.clip_id) return false;
  if (!__eq_Shape(a.clip_shape, b.clip_shape)) return false;
  return true;
}

function __eq_Skee$HudView$Built(a, b) {
  if (!__eq_List(a.made_rev, b.made_rev)) return false;
  if (!__eq_List(a.open_clips, b.open_clips)) return false;
  if (!__eq_List(a.left, b.left)) return false;
  if (a.next_clip !== b.next_clip) return false;
  return true;
}

function __eq_Skee$HudView$PrizePen(a, b) {
  if (!__eq_Skee$Consts$Consts(a.k, b.k)) return false;
  if (a.silhouette !== b.silhouette) return false;
  if (a.prefix !== b.prefix) return false;
  return true;
}

function __eq_Skee$HudView$Seg(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SegMove": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "SegLine": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "SegQuad": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
    case "SegCubic": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (a._5 !== b._5) return false;
      return true;
    }
    case "SegArc": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "SegClose": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$HudView$Box(a, b) {
  if (a.bx0 !== b.bx0) return false;
  if (a.by0 !== b.by0) return false;
  if (a.bx1 !== b.bx1) return false;
  if (a.by1 !== b.by1) return false;
  return true;
}

function __eq_Skee$HudView$Section(a, b) {
  if (a.section_id !== b.section_id) return false;
  if (a.section_html !== b.section_html) return false;
  return true;
}

function __eq_Skee$Painter$FillRule(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "RuleNonZero": {
      return true;
    }
    case "RuleEvenOdd": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Painter$ColourStop(a, b) {
  if (a.stop_at !== b.stop_at) return false;
  if (a.stop_css !== b.stop_css) return false;
  return true;
}

function __eq_Skee$Painter$CanvasCall(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "CvSave": {
      return true;
    }
    case "CvRestore": {
      return true;
    }
    case "CvSetTransform": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (a._5 !== b._5) return false;
      return true;
    }
    case "CvComposite": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CvBeginPath": {
      return true;
    }
    case "CvMoveTo": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "CvLineTo": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "CvQuadTo": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
    case "CvCubicTo": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (a._5 !== b._5) return false;
      return true;
    }
    case "CvClosePath": {
      return true;
    }
    case "CvArc": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
    case "CvFillStyle": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CvRadialStyle": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      if (a._4 !== b._4) return false;
      if (a._5 !== b._5) return false;
      if (!__eq_List(a._6, b._6)) return false;
      return true;
    }
    case "CvFill": {
      if (!__eq_FillRule(a._0, b._0)) return false;
      return true;
    }
    case "CvClip": {
      if (!__eq_FillRule(a._0, b._0)) return false;
      return true;
    }
    case "CvFillRect": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
    case "CvStrokeStyle": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CvLineWidth": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CvLineCap": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CvLineJoin": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CvStroke": {
      return true;
    }
    case "CvFont": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CvTextCentred": {
      return true;
    }
    case "CvFillText": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "CvStrokeText": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Painter$Painting(a, b) {
  if (!__eq_List(a.rev, b.rev)) return false;
  if (a.open_clips !== b.open_clips) return false;
  if (a.dpr !== b.dpr) return false;
  if (a.view_w !== b.view_w) return false;
  if (a.view_h !== b.view_h) return false;
  if (a.sweep !== b.sweep) return false;
  return true;
}

function __eq_Skee$Palette$Tint(a, b) {
  if (a.red !== b.red) return false;
  if (a.green !== b.green) return false;
  if (a.blue !== b.blue) return false;
  return true;
}

function __eq_Skee$Palette$ArtStyle(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Cel": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Three(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Three": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$PerHole(a, b) {
  if (a.gutter !== b.gutter) return false;
  if (a.ring10 !== b.ring10) return false;
  if (a.ring20 !== b.ring20) return false;
  if (a.ring30 !== b.ring30) return false;
  if (a.ring40 !== b.ring40) return false;
  if (a.ring50 !== b.ring50) return false;
  if (a.pocket_left !== b.pocket_left) return false;
  if (a.pocket_right !== b.pocket_right) return false;
  return true;
}

function __eq_Skee$Types$PerReel(a, b) {
  if (a.reel10 !== b.reel10) return false;
  if (a.reel20 !== b.reel20) return false;
  if (a.reel30 !== b.reel30) return false;
  if (a.reel40 !== b.reel40) return false;
  if (a.reel50 !== b.reel50) return false;
  if (a.reel_left !== b.reel_left) return false;
  if (a.reel_right !== b.reel_right) return false;
  return true;
}

function __eq_Skee$Types$PerRound(a, b) {
  if (a.warmup !== b.warmup) return false;
  if (a.feature !== b.feature) return false;
  if (a.boss_round !== b.boss_round) return false;
  return true;
}

function __eq_Skee$Types$PerTier(a, b) {
  if (a.mini !== b.mini) return false;
  if (a.minor !== b.minor) return false;
  if (a.major !== b.major) return false;
  if (a.grand !== b.grand) return false;
  return true;
}

function __eq_Skee$Types$PerRoom(a, b) {
  if (a.boardwalk !== b.boardwalk) return false;
  if (a.neon_lounge !== b.neon_lounge) return false;
  if (a.high_roller !== b.high_roller) return false;
  if (a.penthouse !== b.penthouse) return false;
  return true;
}

function __eq_Skee$Types$Chips(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Chips": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Points(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Points": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Tickets(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Tickets": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Winnings(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Winnings": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Hole(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Gutter": {
      return true;
    }
    case "Ring10": {
      return true;
    }
    case "Ring20": {
      return true;
    }
    case "Ring30": {
      return true;
    }
    case "Ring40": {
      return true;
    }
    case "Ring50": {
      return true;
    }
    case "PocketLeft": {
      return true;
    }
    case "PocketRight": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$ShotEvent(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ShotDud": {
      return true;
    }
    case "ShotRail": {
      return true;
    }
    case "ShotLaunched": {
      return true;
    }
    case "ShotLanded": {
      return true;
    }
    case "ShotLip": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "ShotBackwall": {
      return true;
    }
    case "ShotHop": {
      return true;
    }
    case "ShotDropped": {
      if (!__eq_Hole(a._0, b._0)) return false;
      return true;
    }
    case "ShotSettled": {
      if (!__eq_Hole(a._0, b._0)) return false;
      return true;
    }
    case "ShotGutter": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$TimedEvent(a, b) {
  if (!__eq_ShotEvent(a.event, b.event)) return false;
  if (a.at !== b.at) return false;
  return true;
}

function __eq_Skee$Types$PathPhase(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "OnLane": {
      return true;
    }
    case "InAir": {
      return true;
    }
    case "OnBoard": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$PathSample(a, b) {
  if (a.t !== b.t) return false;
  if (!__eq_PathPhase(a.phase, b.phase)) return false;
  if (a.px !== b.px) return false;
  if (a.along !== b.along) return false;
  if (a.height !== b.height) return false;
  return true;
}

function __eq_Skee$Types$Launch(a, b) {
  if (a.power !== b.power) return false;
  if (a.speed !== b.speed) return false;
  if (a.from !== b.from) return false;
  if (a.aim !== b.aim) return false;
  if (a.start !== b.start) return false;
  if (a.fold !== b.fold) return false;
  if (a.spin !== b.spin) return false;
  if (a.skid !== b.skid) return false;
  return true;
}

function __eq_Skee$Types$ShotResult(a, b) {
  if (!__eq_Launch(a.launch, b.launch)) return false;
  if (!__eq_Hole(a.hole, b.hole)) return false;
  if (!__eq_List(a.events, b.events)) return false;
  if (!__eq_List(a.path, b.path)) return false;
  if (!__eq_Option(a.hinge_speed, b.hinge_speed)) return false;
  if (!__eq_Option(a.first_landing, b.first_landing)) return false;
  if (a.peak_height !== b.peak_height) return false;
  if (a.duration !== b.duration) return false;
  return true;
}

function __eq_Skee$Types$LaneSpec(a, b) {
  if (a.length !== b.length) return false;
  if (a.width !== b.width) return false;
  if (a.incline !== b.incline) return false;
  if (a.rolling_friction !== b.rolling_friction) return false;
  if (a.rail_restitution !== b.rail_restitution) return false;
  if (a.min_speed !== b.min_speed) return false;
  if (a.scoring_speed !== b.scoring_speed) return false;
  if (a.max_speed !== b.max_speed) return false;
  if (a.knee !== b.knee) return false;
  if (a.max_aim_angle !== b.max_aim_angle) return false;
  if (a.hook !== b.hook) return false;
  if (a.skid_loss !== b.skid_loss) return false;
  return true;
}

function __eq_Skee$Types$HingeSpec(a, b) {
  if (a.base_angle !== b.base_angle) return false;
  if (a.fold_gain !== b.fold_gain) return false;
  if (a.carry !== b.carry) return false;
  return true;
}

function __eq_Skee$Types$Pocket(a, b) {
  if (!__eq_Hole(a.pocket_hole, b.pocket_hole)) return false;
  if (!__eq_Vec2(a.center, b.center)) return false;
  if (a.radius !== b.radius) return false;
  return true;
}

function __eq_Skee$Types$Pockets(a, b) {
  if (!__eq_Pocket(a.left, b.left)) return false;
  if (!__eq_Pocket(a.right, b.right)) return false;
  return true;
}

function __eq_Skee$Types$RingWalls(a, b) {
  if (a.wall40 !== b.wall40) return false;
  if (a.wall30 !== b.wall30) return false;
  if (a.wall20 !== b.wall20) return false;
  if (a.wall10 !== b.wall10) return false;
  return true;
}

function __eq_Skee$Types$BoardSpec(a, b) {
  if (a.board_width !== b.board_width) return false;
  if (a.board_height !== b.board_height) return false;
  if (a.tilt !== b.tilt) return false;
  if (!__eq_Vec2(a.ring_center, b.ring_center)) return false;
  if (!__eq_Vec2(a.center_hole_offset, b.center_hole_offset)) return false;
  if (a.center_hole_radius !== b.center_hole_radius) return false;
  if (a.capture_speed !== b.capture_speed) return false;
  if (a.pockets_need_flight !== b.pockets_need_flight) return false;
  if (a.lip_min_fall !== b.lip_min_fall) return false;
  if (!__eq_RingWalls(a.ring_walls, b.ring_walls)) return false;
  if (!__eq_Pockets(a.pockets, b.pockets)) return false;
  if (a.lip_height !== b.lip_height) return false;
  if (a.ball_radius !== b.ball_radius) return false;
  if (a.lip_band !== b.lip_band) return false;
  if (a.bounce !== b.bounce) return false;
  if (a.lip_bounce !== b.lip_bounce) return false;
  if (a.lip_kick !== b.lip_kick) return false;
  if (a.wall_restitution !== b.wall_restitution) return false;
  if (a.backwall_restitution !== b.backwall_restitution) return false;
  if (a.board_rolling_friction !== b.board_rolling_friction) return false;
  if (a.landing_grip !== b.landing_grip) return false;
  if (!__eq_Vec2(a.wind, b.wind)) return false;
  if (a.ring_hole_radius !== b.ring_hole_radius) return false;
  return true;
}

function __eq_Skee$Types$Table(a, b) {
  if (!__eq_LaneSpec(a.lane, b.lane)) return false;
  if (!__eq_HingeSpec(a.hinge, b.hinge)) return false;
  if (!__eq_BoardSpec(a.board, b.board)) return false;
  if (a.gravity !== b.gravity) return false;
  if (a.dt !== b.dt) return false;
  if (a.max_duration !== b.max_duration) return false;
  return true;
}

function __eq_Skee$Types$Symbol(a, b) {
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
    case "BarSym": {
      return true;
    }
    case "Seven": {
      return true;
    }
    case "Diamond": {
      return true;
    }
    case "Clover": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Payline(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NoLine": {
      return true;
    }
    case "Pair": {
      if (!__eq_Symbol(a._0, b._0)) return false;
      return true;
    }
    case "Triple": {
      if (!__eq_Symbol(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$ReelSymbol(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ReelCherry": {
      return true;
    }
    case "ReelLemon": {
      return true;
    }
    case "ReelBell": {
      return true;
    }
    case "ReelBar": {
      return true;
    }
    case "ReelSeven": {
      return true;
    }
    case "ReelDiamond": {
      return true;
    }
    case "ReelWild": {
      return true;
    }
    case "ReelX2": {
      return true;
    }
    case "ReelX3": {
      return true;
    }
    case "ReelBonus": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Bet(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "BetOne": {
      return true;
    }
    case "BetThree": {
      return true;
    }
    case "BetFive": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$JackpotTier(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Mini": {
      return true;
    }
    case "Minor": {
      return true;
    }
    case "Major": {
      return true;
    }
    case "Grand": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$LineWin(a, b) {
  if (a.line !== b.line) return false;
  if (!__eq_ReelSymbol(a.symbol, b.symbol)) return false;
  if (!__eq_Chips(a.line_chips, b.line_chips)) return false;
  if (a.multiplier !== b.multiplier) return false;
  return true;
}

function __eq_Skee$Types$Room(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Boardwalk": {
      return true;
    }
    case "NeonLounge": {
      return true;
    }
    case "HighRoller": {
      return true;
    }
    case "Penthouse": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Pull(a, b) {
  if (!__eq_Three(a.stops, b.stops)) return false;
  if (!__eq_Bet(a.bet, b.bet)) return false;
  if (a.free !== b.free) return false;
  if (!__eq_Room(a.pull_room, b.pull_room)) return false;
  return true;
}

function __eq_Skee$Types$Progressive(a, b) {
  if (!__eq_PerTier(a.meters, b.meters)) return false;
  return true;
}

function __eq_Skee$Types$BoardSetup(a, b) {
  if (!__eq_PerReel(a.reels, b.reels)) return false;
  if (!__eq_PerReel(a.gild, b.gild)) return false;
  return true;
}

function __eq_Skee$Types$TopSlot(a, b) {
  if (!__eq_Three(a.targets, b.targets)) return false;
  return true;
}

function __eq_Skee$Types$BallKind(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Marshmallow": {
      return true;
    }
    case "ClassicBall": {
      return true;
    }
    case "JumpingBean": {
      return true;
    }
    case "Wobbler": {
      return true;
    }
    case "Comet": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$BallRecord(a, b) {
  if (!__eq_Hole(a.record_hole, b.record_hole)) return false;
  if (!__eq_Symbol(a.record_symbol, b.record_symbol)) return false;
  if (!__eq_Chips(a.record_chips, b.record_chips)) return false;
  if (a.rattles !== b.rattles) return false;
  if (a.record_fold !== b.record_fold) return false;
  if (a.foul !== b.foul) return false;
  if (a.slot_hits !== b.slot_hits) return false;
  if (a.record_combo !== b.record_combo) return false;
  if (!__eq_BallKind(a.record_ball, b.record_ball)) return false;
  if (a.hot !== b.hot) return false;
  return true;
}

function __eq_Skee$Types$Charm(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "LuckyPenny": {
      return true;
    }
    case "HotStreak": {
      return true;
    }
    case "HeavyHand": {
      return true;
    }
    case "GutterRat": {
      return true;
    }
    case "EvenSteven": {
      return true;
    }
    case "Ladder": {
      return true;
    }
    case "CornerOffice": {
      return true;
    }
    case "NearMiss": {
      return true;
    }
    case "MultBall": {
      return true;
    }
    case "GlassCannon": {
      return true;
    }
    case "TicketMuncher": {
      return true;
    }
    case "HingeWhisperer": {
      return true;
    }
    case "BellRinger": {
      return true;
    }
    case "SevenSeas": {
      return true;
    }
    case "ExtraBall": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$ScoringContext(a, b) {
  if (!__eq_List(a.context_charms, b.context_charms)) return false;
  if (a.streak_before !== b.streak_before) return false;
  if (a.context_fever !== b.context_fever) return false;
  if (a.pairs_pay !== b.pairs_pay) return false;
  if (!__eq_Option(a.context_pull, b.context_pull)) return false;
  return true;
}

function __eq_Skee$Types$ScoreSource(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "FromBase": {
      return true;
    }
    case "FromPull": {
      return true;
    }
    case "FromBall": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "FromSlot": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "FromPayline": {
      return true;
    }
    case "FromCharm": {
      if (!__eq_Charm(a._0, b._0)) return false;
      return true;
    }
    case "FromFever": {
      return true;
    }
    case "FromFreeGame": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$ScoreEffect(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SetBase": {
      if (!__eq_Chips(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "AddChips": {
      if (!__eq_Chips(a._0, b._0)) return false;
      return true;
    }
    case "AddMult": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "TimesMult": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "AddTickets": {
      if (!__eq_Tickets(a._0, b._0)) return false;
      return true;
    }
    case "Note": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$ScoreStep(a, b) {
  if (!__eq_ScoreSource(a.source, b.source)) return false;
  if (!__eq_ScoreEffect(a.effect, b.effect)) return false;
  return true;
}

function __eq_Skee$Types$FrameScore(a, b) {
  if (!__eq_List(a.balls, b.balls)) return false;
  if (!__eq_Payline(a.payline, b.payline)) return false;
  if (!__eq_List(a.steps, b.steps)) return false;
  if (!__eq_Chips(a.frame_chips, b.frame_chips)) return false;
  if (a.mult !== b.mult) return false;
  if (!__eq_Tickets(a.frame_tickets, b.frame_tickets)) return false;
  if (a.streak_after !== b.streak_after) return false;
  return true;
}

function __eq_Skee$Types$FrameView(a, b) {
  if (!__eq_List(a.view_balls, b.view_balls)) return false;
  if (!__eq_Payline(a.view_payline, b.view_payline)) return false;
  if (a.view_streak_after !== b.view_streak_after) return false;
  return true;
}

function __eq_Skee$Types$PowerUp(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "GoldenBall": {
      return true;
    }
    case "Feather": {
      return true;
    }
    case "Magnet": {
      return true;
    }
    case "WildBall": {
      return true;
    }
    case "Hold": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Offer(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "OfferCharm": {
      if (!__eq_Charm(a._0, b._0)) return false;
      return true;
    }
    case "OfferStamp": {
      if (!__eq_Symbol(a._0, b._0)) return false;
      return true;
    }
    case "OfferGild": {
      return true;
    }
    case "OfferPurge": {
      return true;
    }
    case "OfferPowerUp": {
      if (!__eq_PowerUp(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$PrizeCounter(a, b) {
  if (!__eq_List(a.offers, b.offers)) return false;
  if (!__eq_Tickets(a.reroll_cost, b.reroll_cost)) return false;
  return true;
}

function __eq_Skee$Types$Boss(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TallLips": {
      return true;
    }
    case "SlickLane": {
      return true;
    }
    case "Crosswind": {
      return true;
    }
    case "Miser": {
      return true;
    }
    case "ShortHand": {
      return true;
    }
    case "TightPockets": {
      return true;
    }
    case "TheHouse": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$RoundKind(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Warmup": {
      return true;
    }
    case "Feature": {
      return true;
    }
    case "BossRound": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$RunConfig(a, b) {
  if (a.antes !== b.antes) return false;
  if (a.frames_per_round !== b.frames_per_round) return false;
  if (a.balls_per_frame !== b.balls_per_frame) return false;
  if (!__eq_Tickets(a.start_tickets, b.start_tickets)) return false;
  if (a.charm_slots !== b.charm_slots) return false;
  if (a.power_up_slots !== b.power_up_slots) return false;
  if (a.fever_heat !== b.fever_heat) return false;
  if (!__eq_List(a.ante_base, b.ante_base)) return false;
  if (a.target_scale !== b.target_scale) return false;
  if (!__eq_PerRound(a.kind_scale, b.kind_scale)) return false;
  if (!__eq_PerRound(a.round_tickets, b.round_tickets)) return false;
  if (a.overkill_step !== b.overkill_step) return false;
  if (a.overkill_cap !== b.overkill_cap) return false;
  if (a.interest_per !== b.interest_per) return false;
  if (a.interest_cap !== b.interest_cap) return false;
  if (a.offer_count !== b.offer_count) return false;
  return true;
}

function __eq_Skee$Types$RoundState(a, b) {
  if (!__eq_RoundKind(a.kind, b.kind)) return false;
  if (!__eq_Points(a.target, b.target)) return false;
  if (a.frames_total !== b.frames_total) return false;
  if (!__eq_List(a.frames, b.frames)) return false;
  if (!__eq_List(a.current_balls, b.current_balls)) return false;
  if (a.streak !== b.streak) return false;
  if (a.combo !== b.combo) return false;
  if (!__eq_Option(a.armed, b.armed)) return false;
  if (!__eq_Option(a.round_pull, b.round_pull)) return false;
  if (a.free_left !== b.free_left) return false;
  if (!__eq_Option(a.round_hot, b.round_hot)) return false;
  if (!__eq_Bet(a.last_bet, b.last_bet)) return false;
  return true;
}

function __eq_Skee$Types$Phase(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Throwing": {
      return true;
    }
    case "AtCounter": {
      if (!__eq_PrizeCounter(a._0, b._0)) return false;
      return true;
    }
    case "Lost": {
      return true;
    }
    case "Won": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$RunStats(a, b) {
  if (a.stat_balls !== b.stat_balls) return false;
  if (!__eq_PerHole(a.stat_holes, b.stat_holes)) return false;
  if (a.jackpots !== b.jackpots) return false;
  if (a.stat_rattles !== b.stat_rattles) return false;
  if (!__eq_Points(a.best_frame, b.best_frame)) return false;
  if (a.pulls !== b.pulls) return false;
  if (a.free_games !== b.free_games) return false;
  if (!__eq_PerTier(a.jackpot_tiers, b.jackpot_tiers)) return false;
  if (!__eq_Points(a.points, b.points)) return false;
  if (a.rounds_cleared !== b.rounds_cleared) return false;
  return true;
}

function __eq_Skee$Types$RunState(a, b) {
  if (!__eq_RunConfig(a.config, b.config)) return false;
  if (!__eq_BallKind(a.ball, b.ball)) return false;
  if (!__eq_Room(a.room, b.room)) return false;
  if (!__eq_Skee$Rng$Rng(a.rng, b.rng)) return false;
  if (!__eq_Skee$U64$U64(a.seed, b.seed)) return false;
  if (a.ante !== b.ante) return false;
  if (!__eq_Boss(a.boss, b.boss)) return false;
  if (!__eq_RoundState(a.round, b.round)) return false;
  if (!__eq_Phase(a.phase, b.phase)) return false;
  if (!__eq_BoardSetup(a.setup, b.setup)) return false;
  if (!__eq_PerReel(a.reel_stops, b.reel_stops)) return false;
  if (!__eq_TopSlot(a.top_slot, b.top_slot)) return false;
  if (!__eq_List(a.charms, b.charms)) return false;
  if (!__eq_List(a.power_ups, b.power_ups)) return false;
  if (!__eq_Tickets(a.tickets, b.tickets)) return false;
  if (a.heat !== b.heat) return false;
  if (a.fever !== b.fever) return false;
  if (!__eq_RunStats(a.stats, b.stats)) return false;
  return true;
}

function __eq_Skee$Types$Action(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PullLever": {
      if (!__eq_Bet(a._0, b._0)) return false;
      return true;
    }
    case "ThrowBall": {
      if (!__eq_Launch(a._0, b._0)) return false;
      return true;
    }
    case "CommitFoul": {
      return true;
    }
    case "ChooseBall": {
      if (!__eq_BallKind(a._0, b._0)) return false;
      return true;
    }
    case "Arm": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Buy": {
      if (a._0 !== b._0) return false;
      if (!__eq_Option(a._1, b._1)) return false;
      return true;
    }
    case "Reroll": {
      return true;
    }
    case "Sell": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "LeaveCounter": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$ActionError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "WrongPhase": {
      return true;
    }
    case "NoSuchOffer": {
      return true;
    }
    case "NoSuchItem": {
      return true;
    }
    case "CantAfford": {
      return true;
    }
    case "SlotsFull": {
      return true;
    }
    case "NeedsTarget": {
      return true;
    }
    case "AlreadyArmed": {
      return true;
    }
    case "ReelTooShort": {
      return true;
    }
    case "NeedsPull": {
      return true;
    }
    case "AlreadyPulled": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Payout(a, b) {
  if (!__eq_Tickets(a.base, b.base)) return false;
  if (!__eq_Tickets(a.overkill, b.overkill)) return false;
  if (!__eq_Tickets(a.interest, b.interest)) return false;
  return true;
}

function __eq_Skee$Types$GameEvent(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Pulled": {
      if (!__eq_Pull(a._0, b._0)) return false;
      return true;
    }
    case "FreeGamesWon": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "JackpotHit": {
      if (!__eq_JackpotTier(a._0, b._0)) return false;
      return true;
    }
    case "Shot": {
      if (!__eq_ShotResult(a._0, b._0)) return false;
      if (!__eq_BallRecord(a._1, b._1)) return false;
      return true;
    }
    case "Fouled": {
      return true;
    }
    case "FrameScored": {
      if (!__eq_FrameScore(a._0, b._0)) return false;
      return true;
    }
    case "FeverLit": {
      return true;
    }
    case "RoundCleared": {
      if (!__eq_Points(a._0, b._0)) return false;
      if (!__eq_Points(a._1, b._1)) return false;
      if (!__eq_Payout(a._2, b._2)) return false;
      return true;
    }
    case "RoundFailed": {
      if (!__eq_Points(a._0, b._0)) return false;
      if (!__eq_Points(a._1, b._1)) return false;
      return true;
    }
    case "CounterOpened": {
      return true;
    }
    case "Bought": {
      if (!__eq_Offer(a._0, b._0)) return false;
      return true;
    }
    case "Sold": {
      if (!__eq_Charm(a._0, b._0)) return false;
      return true;
    }
    case "Rerolled": {
      return true;
    }
    case "Armed": {
      if (!__eq_PowerUp(a._0, b._0)) return false;
      return true;
    }
    case "BallChosen": {
      if (!__eq_BallKind(a._0, b._0)) return false;
      return true;
    }
    case "RoundStarted": {
      if (!__eq_RoundKind(a._0, b._0)) return false;
      if (!__eq_Points(a._1, b._1)) return false;
      return true;
    }
    case "AnteStarted": {
      if (a._0 !== b._0) return false;
      if (!__eq_Boss(a._1, b._1)) return false;
      return true;
    }
    case "RunWon": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Step(a, b) {
  if (!__eq_RunState(a.run, b.run)) return false;
  if (!__eq_List(a.step_events, b.step_events)) return false;
  return true;
}

function __eq_Skee$Types$Prize(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Sticker": {
      return true;
    }
    case "RubberDuck": {
      return true;
    }
    case "Kazoo": {
      return true;
    }
    case "Yoyo": {
      return true;
    }
    case "Slinky": {
      return true;
    }
    case "PlushFrog": {
      return true;
    }
    case "LavaLamp": {
      return true;
    }
    case "Robot": {
      return true;
    }
    case "GiantBear": {
      return true;
    }
    case "Trophy": {
      return true;
    }
    case "GlowSticks": {
      return true;
    }
    case "RollerSkates": {
      return true;
    }
    case "DiscoBall": {
      return true;
    }
    case "NeonSign": {
      return true;
    }
    case "Jukebox": {
      return true;
    }
    case "ArcadeCabinet": {
      return true;
    }
    case "Cufflinks": {
      return true;
    }
    case "Champagne": {
      return true;
    }
    case "PearlNecklace": {
      return true;
    }
    case "GoldWatch": {
      return true;
    }
    case "Chandelier": {
      return true;
    }
    case "SportsCar": {
      return true;
    }
    case "GoldenFlamingo": {
      return true;
    }
    case "HotTub": {
      return true;
    }
    case "GrandPiano": {
      return true;
    }
    case "Yacht": {
      return true;
    }
    case "PrivateJet": {
      return true;
    }
    case "DiamondCrown": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$ShopError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ShopCantAfford": {
      return true;
    }
    case "AlreadyOwned": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$Comp(a, b) {
  if (!__eq_Room(a.comp_room, b.comp_room)) return false;
  if (a.nights !== b.nights) return false;
  if (!__eq_Tickets(a.comp_tickets, b.comp_tickets)) return false;
  if (!__eq_Winnings(a.credit, b.credit)) return false;
  return true;
}

function __eq_Skee$Types$Wallet(a, b) {
  if (!__eq_Winnings(a.balance, b.balance)) return false;
  if (!__eq_Winnings(a.lifetime, b.lifetime)) return false;
  if (!__eq_List(a.owned, b.owned)) return false;
  if (!__eq_Progressive(a.progressive, b.progressive)) return false;
  if (!__eq_PerRoom(a.rooms, b.rooms)) return false;
  if (!__eq_Room(a.wallet_room, b.wallet_room)) return false;
  if (!__eq_PerRoom(a.comps, b.comps)) return false;
  if (a.games_since_host !== b.games_since_host) return false;
  if (a.host_visits !== b.host_visits) return false;
  return true;
}

function __eq_Skee$Types$FlickSample(a, b) {
  if (a.sample_t !== b.sample_t) return false;
  if (a.sample_x !== b.sample_x) return false;
  if (a.sample_y !== b.sample_y) return false;
  return true;
}

function __eq_Skee$Types$FlickGeometry(a, b) {
  if (a.crease_y !== b.crease_y) return false;
  if (a.lane_center_x !== b.lane_center_x) return false;
  if (a.lane_half_width !== b.lane_half_width) return false;
  if (a.foul_give !== b.foul_give) return false;
  return true;
}

function __eq_Skee$Types$StrokeOutcome(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NoThrow": {
      return true;
    }
    case "StrokeFoul": {
      return true;
    }
    case "Release": {
      if (!__eq_Launch(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$FlickTuning(a, b) {
  if (a.slowest !== b.slowest) return false;
  if (a.fastest !== b.fastest) return false;
  if (a.release_weight !== b.release_weight) return false;
  if (a.snap_gain !== b.snap_gain) return false;
  if (a.full_aim_angle !== b.full_aim_angle) return false;
  if (a.smooth_jerk !== b.smooth_jerk) return false;
  if (a.skid_per_jerk !== b.skid_per_jerk) return false;
  if (a.line_reach !== b.line_reach) return false;
  return true;
}

function __eq_Skee$Types$Skill(a, b) {
  if (a.skill_name !== b.skill_name) return false;
  if (a.power_sigma !== b.power_sigma) return false;
  if (a.aim_sigma !== b.aim_sigma) return false;
  return true;
}

function __eq_Skee$Types$WalkthroughStep(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "WalkWelcome": {
      return true;
    }
    case "WalkPull": {
      return true;
    }
    case "WalkFlick": {
      return true;
    }
    case "WalkSymbols": {
      return true;
    }
    case "WalkLine": {
      return true;
    }
    case "WalkScore": {
      return true;
    }
    case "WalkPullAgain": {
      return true;
    }
    case "WalkTopSlot": {
      return true;
    }
    case "WalkLastPull": {
      return true;
    }
    case "WalkFinish": {
      return true;
    }
    case "WalkCounter": {
      return true;
    }
    case "WalkPrizes": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$CoachCard(a, b) {
  if (a.coach_title !== b.coach_title) return false;
  if (a.coach_body !== b.coach_body) return false;
  if (a.coach_needs_tap !== b.coach_needs_tap) return false;
  if (a.coach_high !== b.coach_high) return false;
  return true;
}

function __eq_Skee$Types$Walkthrough(a, b) {
  if (!__eq_WalkthroughStep(a.walk_step, b.walk_step)) return false;
  if (a.walk_finished !== b.walk_finished) return false;
  if (a.walk_last_foul !== b.walk_last_foul) return false;
  if (a.walk_pulled_ahead !== b.walk_pulled_ahead) return false;
  return true;
}

function __eq_Skee$Types$Tip(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TipCombo": {
      return true;
    }
    case "TipHotSpot": {
      return true;
    }
    case "TipCharm": {
      return true;
    }
    case "TipSpecialty": {
      return true;
    }
    case "TipBoardEdit": {
      return true;
    }
    case "TipBoss": {
      return true;
    }
    case "TipBets": {
      return true;
    }
    case "TipBalls": {
      return true;
    }
    case "TipFever": {
      return true;
    }
    case "TipFreeGames": {
      return true;
    }
    case "TipJackpot": {
      return true;
    }
    case "TipGameOver": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$SinceTip(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NoTipYet": {
      return true;
    }
    case "BallsSince": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Types$TipTracker(a, b) {
  if (!__eq_List(a.tips_seen, b.tips_seen)) return false;
  if (!__eq_SinceTip(a.since_tip, b.since_tip)) return false;
  if (!__eq_Option(a.tip_showing, b.tip_showing)) return false;
  return true;
}

function __eq_Skee$Types$GuideTopic(a, b) {
  if (a.topic_title !== b.topic_title) return false;
  if (!__eq_List(a.topic_pages, b.topic_pages)) return false;
  if (!__eq_List(a.topic_unlocks, b.topic_unlocks)) return false;
  return true;
}

function __eq_Skee$Physics$SavedLaunch(a, b) {
  if (a.saved_power !== b.saved_power) return false;
  if (a.saved_aim !== b.saved_aim) return false;
  if (!__eq_Option(a.saved_start, b.saved_start)) return false;
  if (!__eq_Option(a.saved_fold, b.saved_fold)) return false;
  if (!__eq_Option(a.saved_spin, b.saved_spin)) return false;
  if (!__eq_Option(a.saved_skid, b.saved_skid)) return false;
  if (!__eq_Option(a.saved_speed, b.saved_speed)) return false;
  if (!__eq_Option(a.saved_from, b.saved_from)) return false;
  return true;
}

function __eq_Skee$Physics$SinCos(a, b) {
  if (a.sine !== b.sine) return false;
  if (a.cosine !== b.cosine) return false;
  return true;
}

function __eq_Skee$Physics$SineBook(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "NoSines": {
      return true;
    }
    case "SineNode": {
      if (!__eq_SineBook(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_SineBook(a._3, b._3)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Physics$ShotTrig(a, b) {
  if (!__eq_SinCos(a.aim_angle, b.aim_angle)) return false;
  if (!__eq_SinCos(a.incline, b.incline)) return false;
  if (!__eq_SinCos(a.tilt, b.tilt)) return false;
  if (!__eq_SinCos(a.hinge_angle, b.hinge_angle)) return false;
  if (!__eq_SineBook(a.sines, b.sines)) return false;
  return true;
}

function __eq_Skee$Physics$ShotSetup(a, b) {
  if (!__eq_Skee$Consts$Consts(a.k, b.k)) return false;
  if (!__eq_ShotTrig(a.trig, b.trig)) return false;
  if (!__eq_Launch(a.throw, b.throw)) return false;
  if (!__eq_Table(a.table, b.table)) return false;
  if (!__eq_BallKind(a.ball, b.ball)) return false;
  if (a.half_lane !== b.half_lane) return false;
  if (a.hook_pull !== b.hook_pull) return false;
  if (a.slope_pull !== b.slope_pull) return false;
  if (a.lane_friction !== b.lane_friction) return false;
  if (!__eq_Vec2(a.in_plane, b.in_plane)) return false;
  if (a.normal_pull !== b.normal_pull) return false;
  if (a.half_board !== b.half_board) return false;
  if (a.back !== b.back) return false;
  if (!__eq_List(a.walls, b.walls)) return false;
  return true;
}

function __eq_Skee$Physics$ShotSim(a, b) {
  if (a.t !== b.t) return false;
  if (a.step !== b.step) return false;
  if (!__eq_List(a.events, b.events)) return false;
  if (!__eq_List(a.path, b.path)) return false;
  if (!__eq_Option(a.hinge_speed, b.hinge_speed)) return false;
  if (!__eq_Option(a.first_landing, b.first_landing)) return false;
  if (a.peak !== b.peak) return false;
  if (a.touched_wall !== b.touched_wall) return false;
  if (!__eq_Skee$Rng$Rng(a.rng, b.rng)) return false;
  if (a.next_hop !== b.next_hop) return false;
  if (a.hop_until !== b.hop_until) return false;
  if (a.hops !== b.hops) return false;
  if (a.sway_phase !== b.sway_phase) return false;
  return true;
}

function __eq_Skee$Physics$LaneBall(a, b) {
  if (a.lx !== b.lx) return false;
  if (a.ls !== b.ls) return false;
  if (a.lvx !== b.lvx) return false;
  if (a.lvs !== b.lvs) return false;
  if (a.dud !== b.dud) return false;
  return true;
}

function __eq_Skee$Physics$BoardMode(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "BallAirborne": {
      return true;
    }
    case "BallRolling": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Physics$BoardBall(a, b) {
  if (!__eq_Vec2(a.p, b.p)) return false;
  if (!__eq_Vec2(a.v, b.v)) return false;
  if (a.z !== b.z) return false;
  if (a.vz !== b.vz) return false;
  if (!__eq_BoardMode(a.mode, b.mode)) return false;
  if (a.resting !== b.resting) return false;
  if (a.nudges !== b.nudges) return false;
  return true;
}

function __eq_Skee$Physics$BoardTurn(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "KeepGoing": {
      if (!__eq_ShotSim(a._0, b._0)) return false;
      if (!__eq_BoardBall(a._1, b._1)) return false;
      return true;
    }
    case "StopHere": {
      if (!__eq_ShotSim(a._0, b._0)) return false;
      if (!__eq_BoardBall(a._1, b._1)) return false;
      return true;
    }
    case "ShotOver": {
      if (!__eq_ShotResult(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Presentation$Beat(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "BeatRoll": {
      if (!__eq_ShotResult(a._0, b._0)) return false;
      if (!__eq_BallRecord(a._1, b._1)) return false;
      return true;
    }
    case "BeatSpin": {
      if (!__eq_PerReel(a._0, b._0)) return false;
      return true;
    }
    case "BeatPull": {
      if (!__eq_Pull(a._0, b._0)) return false;
      return true;
    }
    case "BeatTally": {
      if (!__eq_FrameScore(a._0, b._0)) return false;
      return true;
    }
    case "BeatBanner": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
    case "BeatCommit": {
      if (!__eq_RunState(a._0, b._0)) return false;
      return true;
    }
    case "BeatRestyle": {
      if (!__eq_ArtStyle(a._0, b._0)) return false;
      if (!__eq_ArtStyle(a._1, b._1)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Presentation$Cue(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "CueLaunch": {
      return true;
    }
    case "CueRail": {
      return true;
    }
    case "CueHump": {
      return true;
    }
    case "CueLip": {
      return true;
    }
    case "CueBackwall": {
      return true;
    }
    case "CueLanded": {
      return true;
    }
    case "CueDrop": {
      if (!__eq_Hole(a._0, b._0)) return false;
      return true;
    }
    case "CueGutter": {
      return true;
    }
    case "CueHop": {
      return true;
    }
    case "CueWhoosh": {
      return true;
    }
    case "CueHotSpot": {
      return true;
    }
    case "CueLever": {
      return true;
    }
    case "CuePullWin": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueReelTick": {
      return true;
    }
    case "CueReelStop": {
      return true;
    }
    case "CueCombo": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueTallyChips": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueTallyMult": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueFrameDone": {
      return true;
    }
    case "CueLineWon": {
      return true;
    }
    case "CueJackpot": {
      return true;
    }
    case "CueBanner": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CueFoul": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Presentation$ThrowMark(a, b) {
  if (a.mark_power !== b.mark_power) return false;
  if (!__eq_Hole(a.mark_hole, b.mark_hole)) return false;
  return true;
}

function __eq_Skee$Presentation$PopupAnchor(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "AnchorHole": {
      if (!__eq_Hole(a._0, b._0)) return false;
      return true;
    }
    case "AnchorCenter": {
      return true;
    }
    case "AnchorHud": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Presentation$PopupKind(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "PopupChips": {
      return true;
    }
    case "PopupMult": {
      return true;
    }
    case "PopupTickets": {
      return true;
    }
    case "PopupBad": {
      return true;
    }
    case "PopupJackpot": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Presentation$Popup(a, b) {
  if (a.popup_text !== b.popup_text) return false;
  if (!__eq_PopupAnchor(a.anchor, b.anchor)) return false;
  if (!__eq_PopupKind(a.popup_kind, b.popup_kind)) return false;
  if (a.life !== b.life) return false;
  if (a.age !== b.age) return false;
  return true;
}

function __eq_Skee$Presentation$RestingBall(a, b) {
  if (!__eq_PathSample(a.rest_sample, b.rest_sample)) return false;
  if (a.until !== b.until) return false;
  return true;
}

function __eq_Skee$Presentation$Presentation(a, b) {
  if (!__eq_RunState(a.shown, b.shown)) return false;
  if (!__eq_List(a.beats, b.beats)) return false;
  if (a.beat_time !== b.beat_time) return false;
  if (a.clock !== b.clock) return false;
  if (!__eq_PerReel(a.reel_positions, b.reel_positions)) return false;
  if (!__eq_PerReel(a.spin_from, b.spin_from)) return false;
  if (!__eq_Three(a.pull_positions, b.pull_positions)) return false;
  if (!__eq_Three(a.pull_from, b.pull_from)) return false;
  if (a.pull_stopped !== b.pull_stopped) return false;
  if (!__eq_Option(a.last_pull, b.last_pull)) return false;
  if (!__eq_List(a.popups, b.popups)) return false;
  if (!__eq_List(a.trail, b.trail)) return false;
  if (a.flash !== b.flash) return false;
  if (a.shake !== b.shake) return false;
  if (a.celebration !== b.celebration) return false;
  if (!__eq_Option(a.resting_ball, b.resting_ball)) return false;
  if (!__eq_ArtStyle(a.style, b.style)) return false;
  if (!__eq_List(a.recent_throws, b.recent_throws)) return false;
  if (!__eq_Points(a.tallied_bonus, b.tallied_bonus)) return false;
  if (!__eq_List(a.finished, b.finished)) return false;
  if (!__eq_List(a.cues, b.cues)) return false;
  if (a.last_tick !== b.last_tick) return false;
  if (a.shown_steps !== b.shown_steps) return false;
  return true;
}

function __eq_Skee$Presentation$Restyling(a, b) {
  if (!__eq_ArtStyle(a.restyle_from, b.restyle_from)) return false;
  if (!__eq_ArtStyle(a.restyle_to, b.restyle_to)) return false;
  if (a.restyle_progress !== b.restyle_progress) return false;
  return true;
}

function __eq_Skee$Presentation$TallyShown(a, b) {
  if (!__eq_FrameScore(a.tally_frame, b.tally_frame)) return false;
  if (a.revealed !== b.revealed) return false;
  return true;
}

function __eq_Skee$Presentation$BannerShown(a, b) {
  if (a.banner_title !== b.banner_title) return false;
  if (a.banner_sub !== b.banner_sub) return false;
  if (a.banner_progress !== b.banner_progress) return false;
  return true;
}

function __eq_Skee$U64$U64(a, b) {
  if (a.hi !== b.hi) return false;
  if (a.lo !== b.lo) return false;
  return true;
}

function __eq_Skee$Rng$Rng(a, b) {
  if (!__eq_U64(a.word, b.word)) return false;
  return true;
}

function __eq_Skee$Rooms$HostVisit(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "VisitArrival": {
      return true;
    }
    case "VisitNewRoom": {
      return true;
    }
    case "VisitReturning": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Rooms$Rgb(a, b) {
  if (a.packed !== b.packed) return false;
  return true;
}

function __eq_Skee$Rooms$ZoneColours(a, b) {
  if (!__eq_Rgb(a.zone40, b.zone40)) return false;
  if (!__eq_Rgb(a.zone30, b.zone30)) return false;
  if (!__eq_Rgb(a.zone20, b.zone20)) return false;
  if (!__eq_Rgb(a.zone10, b.zone10)) return false;
  return true;
}

function __eq_Skee$Rooms$CabinetPalette(a, b) {
  if (!__eq_Rgb(a.backdrop, b.backdrop)) return false;
  if (!__eq_Rgb(a.rail, b.rail)) return false;
  if (!__eq_Rgb(a.rail_dark, b.rail_dark)) return false;
  if (!__eq_Rgb(a.cabinet_body, b.cabinet_body)) return false;
  if (!__eq_ZoneColours(a.zones, b.zones)) return false;
  if (!__eq_Rgb(a.lip, b.lip)) return false;
  if (!__eq_Rgb(a.hole_colour, b.hole_colour)) return false;
  if (!__eq_Rgb(a.felt, b.felt)) return false;
  if (!__eq_Rgb(a.floor, b.floor)) return false;
  return true;
}

function __eq_Skee$Save$SaveError(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SaveNotJson": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SaveTooDeep": {
      return true;
    }
    case "SaveMissing": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SaveWrongType": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SaveUnknownName": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "SaveOutOfRange": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Save$RunFile(a, b) {
  if (!__eq_Skee$U64$U64(a.file_seed, b.file_seed)) return false;
  if (!__eq_Option(a.file_room, b.file_room)) return false;
  if (!__eq_Option(a.file_extra, b.file_extra)) return false;
  if (!__eq_List(a.file_actions, b.file_actions)) return false;
  return true;
}

function __eq_Skee$Save$Replayed(a, b) {
  if (!__eq_RunState(a.replayed_run, b.replayed_run)) return false;
  if (!__eq_Skee$U64$U64(a.replayed_seed, b.replayed_seed)) return false;
  if (!__eq_Tickets(a.replayed_extra, b.replayed_extra)) return false;
  if (!__eq_List(a.replayed_actions, b.replayed_actions)) return false;
  return true;
}

function __eq_Skee$Save$StartedRun(a, b) {
  if (!__eq_RunState(a.started_run, b.started_run)) return false;
  if (!__eq_RunFile(a.started_file, b.started_file)) return false;
  if (!__eq_Wallet(a.started_wallet, b.started_wallet)) return false;
  return true;
}

function __eq_Skee$Save$JsonWant(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "WantTop": {
      return true;
    }
    case "WantEnd": {
      return true;
    }
    case "WantArrayValue": {
      return true;
    }
    case "WantKey": {
      return true;
    }
    case "WantColon": {
      return true;
    }
    case "WantObjectValue": {
      return true;
    }
    case "WantAfter": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Save$JsonScan(a, b) {
  if (a.scan_at !== b.scan_at) return false;
  if (!__eq_JsonWant(a.want, b.want)) return false;
  if (!__eq_List(a.open, b.open)) return false;
  if (a.depth !== b.depth) return false;
  if (a.pruned_at !== b.pruned_at) return false;
  if (!__eq_List(a.pieces, b.pieces)) return false;
  if (a.copy_from !== b.copy_from) return false;
  if (a.comma !== b.comma) return false;
  return true;
}

function __eq_Skee$Scene$Rgba(a, b) {
  if (a.red !== b.red) return false;
  if (a.green !== b.green) return false;
  if (a.blue !== b.blue) return false;
  if (a.alpha !== b.alpha) return false;
  return true;
}

function __eq_Skee$Scene$LineEnd(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ButtEnd": {
      return true;
    }
    case "RoundEnd": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Corner(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "MitreCorner": {
      return true;
    }
    case "RoundCorner": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Blend(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Over": {
      return true;
    }
    case "Lighter": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$PathStep(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "MoveTo": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      return true;
    }
    case "LineTo": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      return true;
    }
    case "QuadTo": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (!__eq_Vec2(a._1, b._1)) return false;
      return true;
    }
    case "CubicTo": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (!__eq_Vec2(a._1, b._1)) return false;
      if (!__eq_Vec2(a._2, b._2)) return false;
      return true;
    }
    case "ClosePath": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Shape(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Poly": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "Holed": {
      if (!__eq_List(a._0, b._0)) return false;
      if (!__eq_List(a._1, b._1)) return false;
      return true;
    }
    case "Polys": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
    case "Disc": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Outline": {
      if (!__eq_List(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Affine(a, b) {
  if (a.a !== b.a) return false;
  if (a.b !== b.b) return false;
  if (a.c !== b.c) return false;
  if (a.d !== b.d) return false;
  if (a.e !== b.e) return false;
  if (a.f !== b.f) return false;
  return true;
}

function __eq_Skee$Scene$GradientStop(a, b) {
  if (a.offset !== b.offset) return false;
  if (!__eq_Rgba(a.colour, b.colour)) return false;
  return true;
}

function __eq_Skee$Scene$Radial(a, b) {
  if (!__eq_Vec2(a.inner, b.inner)) return false;
  if (a.inner_radius !== b.inner_radius) return false;
  if (!__eq_Vec2(a.outer, b.outer)) return false;
  if (a.outer_radius !== b.outer_radius) return false;
  if (!__eq_List(a.stops, b.stops)) return false;
  if (!__eq_Affine(a.frame, b.frame)) return false;
  return true;
}

function __eq_Skee$Scene$Paint(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Flat": {
      if (!__eq_Rgba(a._0, b._0)) return false;
      return true;
    }
    case "RadialPaint": {
      if (!__eq_Radial(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Pen(a, b) {
  if (!__eq_Rgba(a.ink, b.ink)) return false;
  if (a.width !== b.width) return false;
  if (!__eq_LineEnd(a.ends, b.ends)) return false;
  if (!__eq_Corner(a.corners, b.corners)) return false;
  return true;
}

function __eq_Skee$Scene$Lettering(a, b) {
  if (a.words !== b.words) return false;
  if (a.font !== b.font) return false;
  if (!__eq_Vec2(a.middle, b.middle)) return false;
  if (!__eq_Rgba(a.fill, b.fill)) return false;
  if (!__eq_Option(a.edge, b.edge)) return false;
  if (!__eq_Affine(a.frame, b.frame)) return false;
  return true;
}

function __eq_Skee$Scene$DrawOp(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "ClearTo": {
      if (!__eq_Rgba(a._0, b._0)) return false;
      return true;
    }
    case "FillShape": {
      if (!__eq_Shape(a._0, b._0)) return false;
      if (!__eq_Paint(a._1, b._1)) return false;
      if (!__eq_Blend(a._2, b._2)) return false;
      return true;
    }
    case "StrokeShape": {
      if (!__eq_Shape(a._0, b._0)) return false;
      if (!__eq_Pen(a._1, b._1)) return false;
      if (!__eq_Blend(a._2, b._2)) return false;
      return true;
    }
    case "DrawText": {
      if (!__eq_Lettering(a._0, b._0)) return false;
      return true;
    }
    case "PushClip": {
      if (!__eq_Shape(a._0, b._0)) return false;
      return true;
    }
    case "PopClip": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Frame(a, b) {
  if (!__eq_Vec3(a.ax, b.ax)) return false;
  if (!__eq_Vec3(a.ay, b.ay)) return false;
  if (!__eq_Vec3(a.az, b.az)) return false;
  if (!__eq_Vec3(a.at, b.at)) return false;
  return true;
}

function __eq_Skee$Scene$Solid(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Slab": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (a._3 !== b._3) return false;
      return true;
    }
    case "Drum": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Orb": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "Hoop": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Card": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "Band": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "LipArc": {
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

function __eq_Skee$Scene$Skin(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Painted": {
      return true;
    }
    case "LaneWood": {
      return true;
    }
    case "BallSkin": {
      if (!__eq_BallKind(a._0, b._0)) return false;
      return true;
    }
    case "PitSkin": {
      return true;
    }
    case "BadgeSkin": {
      if (a._0 !== b._0) return false;
      if (a._1 !== b._1) return false;
      return true;
    }
    case "CoinSkin": {
      if (!__eq_Symbol(a._0, b._0)) return false;
      return true;
    }
    case "BlobSkin": {
      return true;
    }
    case "HaloSkin": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Role(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "FloorPart": {
      return true;
    }
    case "LaneSlab": {
      return true;
    }
    case "RailPart": {
      return true;
    }
    case "RailCap": {
      return true;
    }
    case "BodyPart": {
      return true;
    }
    case "HumpPart": {
      return true;
    }
    case "PanelPart": {
      return true;
    }
    case "ZonePart": {
      return true;
    }
    case "LipPart": {
      return true;
    }
    case "PitPart": {
      return true;
    }
    case "RimPart": {
      return true;
    }
    case "BadgePart": {
      return true;
    }
    case "CoinPart": {
      if (!__eq_Hole(a._0, b._0)) return false;
      return true;
    }
    case "HaloPart": {
      if (!__eq_Hole(a._0, b._0)) return false;
      return true;
    }
    case "SideWall": {
      return true;
    }
    case "BackCap": {
      return true;
    }
    case "BulbPart": {
      return true;
    }
    case "TroughPart": {
      return true;
    }
    case "WaitingBall": {
      return true;
    }
    case "ShadowPart": {
      return true;
    }
    case "BallPart": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Emit(a, b) {
  if (a.glow_r !== b.glow_r) return false;
  if (a.glow_g !== b.glow_g) return false;
  if (a.glow_b !== b.glow_b) return false;
  return true;
}

function __eq_Skee$Scene$Part(a, b) {
  if (!__eq_Solid(a.solid, b.solid)) return false;
  if (!__eq_Frame(a.frame, b.frame)) return false;
  if (!__eq_Role(a.role, b.role)) return false;
  if (!__eq_Option(a.colour, b.colour)) return false;
  if (!__eq_Skin(a.skin, b.skin)) return false;
  if (a.outline !== b.outline) return false;
  if (a.hidden !== b.hidden) return false;
  if (a.opacity !== b.opacity) return false;
  if (!__eq_Emit(a.emission, b.emission)) return false;
  return true;
}

function __eq_Skee$Scene$Quat(a, b) {
  if (a.qw !== b.qw) return false;
  if (a.qx !== b.qx) return false;
  if (a.qy !== b.qy) return false;
  if (a.qz !== b.qz) return false;
  return true;
}

function __eq_Skee$Scene$BallPlace(a, b) {
  if (!__eq_Vec3(a.centre, b.centre)) return false;
  if (a.scale !== b.scale) return false;
  if (!__eq_Vec3(a.normal, b.normal)) return false;
  if (a.airborne !== b.airborne) return false;
  if (a.visible !== b.visible) return false;
  if (a.sink !== b.sink) return false;
  if (a.over_board !== b.over_board) return false;
  return true;
}

function __eq_Skee$Scene$ShadowPlace(a, b) {
  if (!__eq_Vec3(a.spot, b.spot)) return false;
  if (!__eq_Vec3(a.facing, b.facing)) return false;
  if (a.size !== b.size) return false;
  if (a.fade !== b.fade) return false;
  if (a.shown !== b.shown) return false;
  return true;
}

function __eq_Skee$Scene$BallCue(a, b) {
  if (!__eq_Option(a.sample, b.sample)) return false;
  if (a.busy !== b.busy) return false;
  if (a.beat_is_roll !== b.beat_is_roll) return false;
  if (!__eq_Option(a.resting, b.resting)) return false;
  if (a.clock !== b.clock) return false;
  if (a.throwing !== b.throwing) return false;
  if (!__eq_Option(a.held, b.held)) return false;
  return true;
}

function __eq_Skee$Scene$Motion(a, b) {
  if (!__eq_Quat(a.orientation, b.orientation)) return false;
  if (!__eq_Option(a.last, b.last)) return false;
  if (!__eq_Vec3(a.spin, b.spin)) return false;
  if (a.pop !== b.pop) return false;
  return true;
}

function __eq_Skee$Scene$Spark(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SparkHump": {
      return true;
    }
    case "SparkLip": {
      return true;
    }
    case "SparkHop": {
      return true;
    }
    case "SparkLanded": {
      return true;
    }
    case "SparkBackwall": {
      return true;
    }
    case "SparkRail": {
      return true;
    }
    case "SparkDrop": {
      if (!__eq_Hole(a._0, b._0)) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Wave(a, b) {
  if (!__eq_Vec3(a.spot, b.spot)) return false;
  if (!__eq_Vec3(a.facing, b.facing)) return false;
  if (a.age !== b.age) return false;
  if (a.size !== b.size) return false;
  return true;
}

function __eq_Skee$Scene$ReelLook(a, b) {
  if (!__eq_Symbol(a.symbol, b.symbol)) return false;
  if (a.turn !== b.turn) return false;
  if (a.glow !== b.glow) return false;
  if (a.slot_match !== b.slot_match) return false;
  if (a.pulse !== b.pulse) return false;
  return true;
}

function __eq_Skee$Scene$ReelCue(a, b) {
  if (!__eq_BoardSetup(a.setup, b.setup)) return false;
  if (!__eq_PerReel(a.positions, b.positions)) return false;
  if (!__eq_List(a.have, b.have)) return false;
  if (!__eq_Option(a.slot, b.slot)) return false;
  return true;
}

function __eq_Skee$Scene$FrameCue(a, b) {
  if (!__eq_BallCue(a.ball_cue, b.ball_cue)) return false;
  if (!__eq_List(a.sparks, b.sparks)) return false;
  if (!__eq_BallKind(a.kind, b.kind)) return false;
  if (a.anticipation !== b.anticipation) return false;
  if (a.shake !== b.shake) return false;
  if (a.balls_left !== b.balls_left) return false;
  if (a.excited !== b.excited) return false;
  if (!__eq_ReelCue(a.reel_cue, b.reel_cue)) return false;
  return true;
}

function __eq_Skee$Scene$Keep(a, b) {
  if (!__eq_Motion(a.motion, b.motion)) return false;
  if (a.lean !== b.lean) return false;
  if (!__eq_List(a.waves, b.waves)) return false;
  if (!__eq_PerReel(a.flash_age, b.flash_age)) return false;
  return true;
}

function __eq_Skee$Scene$BulbLight(a, b) {
  if (a.chase !== b.chase) return false;
  if (a.level !== b.level) return false;
  return true;
}

function __eq_Skee$Scene$BallView(a, b) {
  if (!__eq_BallPlace(a.place, b.place)) return false;
  if (!__eq_Motion(a.motion, b.motion)) return false;
  if (!__eq_BallKind(a.kind, b.kind)) return false;
  if (!__eq_ShadowPlace(a.shadow, b.shadow)) return false;
  return true;
}

function __eq_Skee$Scene$Scenery(a, b) {
  if (!__eq_World(a.world, b.world)) return false;
  if (!__eq_Skee$Rooms$CabinetPalette(a.palette, b.palette)) return false;
  if (!__eq_Skee$Camera$Viewport(a.viewport, b.viewport)) return false;
  if (!__eq_Skee$Camera$Rig(a.camera, b.camera)) return false;
  if (!__eq_BallView(a.ball, b.ball)) return false;
  if (a.waiting !== b.waiting) return false;
  if (!__eq_PerReel(a.reels, b.reels)) return false;
  if (!__eq_BulbLight(a.bulbs, b.bulbs)) return false;
  if (!__eq_List(a.waves, b.waves)) return false;
  return true;
}

function __eq_Skee$Scene$Light(a, b) {
  if (a.lr !== b.lr) return false;
  if (a.lg !== b.lg) return false;
  if (a.lb !== b.lb) return false;
  if (a.rim !== b.rim) return false;
  if (a.er !== b.er) return false;
  if (a.eg !== b.eg) return false;
  if (a.eb !== b.eb) return false;
  return true;
}

function __eq_Skee$Scene$ReelLayout(a, b) {
  if (!__eq_Hole(a.reel_hole, b.reel_hole)) return false;
  if (!__eq_Vec2(a.centre, b.centre)) return false;
  if (a.radius !== b.radius) return false;
  if (a.count !== b.count) return false;
  if (a.size !== b.size) return false;
  if (a.phase !== b.phase) return false;
  if (a.band_in !== b.band_in) return false;
  if (a.band_out !== b.band_out) return false;
  return true;
}

function __eq_Skee$Scene$Coin(a, b) {
  if (!__eq_Vec3(a.local, b.local)) return false;
  if (a.coin_hidden !== b.coin_hidden) return false;
  if (a.swell !== b.swell) return false;
  return true;
}

function __eq_Skee$Scene$Brush(a, b) {
  if (!__eq_Skee$Consts$Consts(a.k, b.k)) return false;
  if (!__eq_Skee$Camera$Lens(a.lens, b.lens)) return false;
  if (!__eq_Vec3(a.eye, b.eye)) return false;
  if (a.ink_px !== b.ink_px) return false;
  return true;
}

function __eq_Skee$Scene$BoxFace(a, b) {
  if (!__eq_List(a.corners, b.corners)) return false;
  if (!__eq_Vec3(a.outward, b.outward)) return false;
  return true;
}

function __eq_Skee$Scene$Plank(a, b) {
  if (a.tone !== b.tone) return false;
  if (!__eq_List(a.streaks, b.streaks)) return false;
  return true;
}

function __eq_Skee$Scene$Mark(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "MarkFill": {
      if (!__eq_List(a._0, b._0)) return false;
      if (!__eq_Rgba(a._1, b._1)) return false;
      return true;
    }
    case "MarkLines": {
      if (!__eq_List(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Rgba(a._2, b._2)) return false;
      return true;
    }
    case "MarkEdge": {
      if (!__eq_List(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (!__eq_Rgba(a._2, b._2)) return false;
      return true;
    }
    case "MarkRing": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (a._1 !== b._1) return false;
      if (a._2 !== b._2) return false;
      if (!__eq_Rgba(a._3, b._3)) return false;
      return true;
    }
    case "Undrawn": {
      if (!__eq_Vec2(a._0, b._0)) return false;
      if (!__eq_Vec2(a._1, b._1)) return false;
      if (a._2 !== b._2) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Texel(a, b) {
  if (a.tr !== b.tr) return false;
  if (a.tg !== b.tg) return false;
  if (a.tb !== b.tb) return false;
  if (a.ta !== b.ta) return false;
  if (a.clean !== b.clean) return false;
  if (a.top !== b.top) return false;
  return true;
}

function __eq_Skee$Scene$Placed(a, b) {
  if (!__eq_Mark(a.mark, b.mark)) return false;
  if (a.index !== b.index) return false;
  if (!__eq_Vec2(a.lo, b.lo)) return false;
  if (!__eq_Vec2(a.hi, b.hi)) return false;
  return true;
}

function __eq_Skee$Scene$Cover(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "DeepIn": {
      return true;
    }
    case "DeepOut": {
      return true;
    }
    case "NearEdge": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scene$Square(a, b) {
  if (a.x0 !== b.x0) return false;
  if (a.y0 !== b.y0) return false;
  if (a.side !== b.side) return false;
  if (!__eq_Light(a.lit, b.lit)) return false;
  return true;
}

function __eq_Skee$Scene$Ranked(a, b) {
  if (a.rank !== b.rank) return false;
  if (a.index !== b.index) return false;
  if (!__eq_Part(a.ranked, b.ranked)) return false;
  return true;
}

function __eq_Skee$Scoring$WindowRow(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "TopRow": {
      return true;
    }
    case "CentreRow": {
      return true;
    }
    case "BottomRow": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scoring$WindowReel(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "Reel0": {
      return true;
    }
    case "Reel1": {
      return true;
    }
    case "Reel2": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Scoring$FrameTally(a, b) {
  if (!__eq_Chips(a.chips, b.chips)) return false;
  if (a.mult !== b.mult) return false;
  if (!__eq_Tickets(a.tickets, b.tickets)) return false;
  return true;
}

function __eq_Skee$Stroke$FlickMetrics(a, b) {
  if (a.peak_speed !== b.peak_speed) return false;
  if (a.release_speed !== b.release_speed) return false;
  if (a.flick_duration !== b.flick_duration) return false;
  if (a.jerk !== b.jerk) return false;
  if (a.snap !== b.snap) return false;
  if (a.side !== b.side) return false;
  if (a.flick_speed !== b.flick_speed) return false;
  return true;
}

function __eq_Skee$Stroke$FlickTrack(a, b) {
  if (a.tt !== b.tt) return false;
  if (a.tx !== b.tx) return false;
  if (a.ty !== b.ty) return false;
  return true;
}

function __eq_Skee$Synth$Sound(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "SndLaunch": {
      return true;
    }
    case "SndRail": {
      return true;
    }
    case "SndHump": {
      return true;
    }
    case "SndLip": {
      return true;
    }
    case "SndBackwall": {
      return true;
    }
    case "SndLanded": {
      return true;
    }
    case "SndDrop": {
      if (!__eq_Hole(a._0, b._0)) return false;
      return true;
    }
    case "SndGutter": {
      return true;
    }
    case "SndHop": {
      return true;
    }
    case "SndWhoosh": {
      return true;
    }
    case "SndHotSpot": {
      return true;
    }
    case "SndLever": {
      return true;
    }
    case "SndPullWin": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SndReelTick": {
      return true;
    }
    case "SndReelStop": {
      return true;
    }
    case "SndCombo": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SndTallyChips": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SndTallyMult": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SndFrameDone": {
      return true;
    }
    case "SndLineWon": {
      return true;
    }
    case "SndJackpot": {
      return true;
    }
    case "SndBanner": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "SndFoul": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Synth$SynthWave(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "WaveSine": {
      return true;
    }
    case "WaveSquare": {
      return true;
    }
    case "WaveTri": {
      return true;
    }
    case "WaveNoise": {
      return true;
    }
  }
  return true;
}

function __eq_Skee$Synth$SynthVoice(a, b) {
  if (!__eq_SynthWave(a.wave, b.wave)) return false;
  if (a.freq !== b.freq) return false;
  if (a.freq_end !== b.freq_end) return false;
  if (a.glide_floor !== b.glide_floor) return false;
  if (a.amp !== b.amp) return false;
  if (a.decay !== b.decay) return false;
  if (a.life !== b.life) return false;
  if (a.delay !== b.delay) return false;
  if (a.t !== b.t) return false;
  if (a.phase !== b.phase) return false;
  return true;
}

function __eq_Skee$Synth$SynthConsts(a, b) {
  if (a.split !== b.split) return false;
  if (a.tiny !== b.tiny) return false;
  if (a.subnormal_shift !== b.subnormal_shift) return false;
  if (a.overflow !== b.overflow) return false;
  if (a.infinity !== b.infinity) return false;
  if (a.dt !== b.dt) return false;
  if (a.pi !== b.pi) return false;
  if (a.rumble_follow !== b.rumble_follow) return false;
  if (a.lowpass_follow !== b.lowpass_follow) return false;
  if (a.rumble_gain !== b.rumble_gain) return false;
  if (a.drum_step !== b.drum_step) return false;
  if (a.min_glide !== b.min_glide) return false;
  if (a.attack_time !== b.attack_time) return false;
  if (a.square_level !== b.square_level) return false;
  if (a.default_glide !== b.default_glide) return false;
  return true;
}

function __eq_Skee$Synth$Synth(a, b) {
  if (!__eq_List(a.voices, b.voices)) return false;
  if (a.lowpass !== b.lowpass) return false;
  if (a.rumble !== b.rumble) return false;
  if (a.drum_clock !== b.drum_clock) return false;
  if (a.seed !== b.seed) return false;
  if (a.rumble_target !== b.rumble_target) return false;
  if (a.drum !== b.drum) return false;
  if (!__eq_SynthConsts(a.c, b.c)) return false;
  return true;
}

function __eq_Skee$Synth$Mix(a, b) {
  if (a.level !== b.level) return false;
  if (a.mix_seed !== b.mix_seed) return false;
  if (!__eq_List(a.kept, b.kept)) return false;
  return true;
}

function __eq_Skee$SynthFeed$AudioCmd(a, b) {
  if (a.$ !== b.$) return false;
  switch (a.$) {
    case "CmdPlay": {
      if (!__eq_Sound(a._0, b._0)) return false;
      return true;
    }
    case "CmdRumble": {
      if (a._0 !== b._0) return false;
      return true;
    }
    case "CmdDrum": {
      if (a._0 !== b._0) return false;
      return true;
    }
  }
  return true;
}

function __eq_Skee$SynthFeed$Levels(a, b) {
  if (a.lvl_rumble !== b.lvl_rumble) return false;
  if (a.lvl_drum !== b.lvl_drum) return false;
  return true;
}

function __eq_Audio$AudioHandle(a, b) {
  if (a.audio_started !== b.audio_started) return false;
  return true;
}

function __eq_Game$ShellState(a, b) {
  if (!__eq_Skee$App$Model(a.model, b.model)) return false;
  if (!__eq_Skee$Consts$Consts(a.k, b.k)) return false;
  if (!__eq_Js$Dom$Node(a.canvas, b.canvas)) return false;
  if (!__eq_Js$Canvas$Context(a.ctx, b.ctx)) return false;
  if (!__eq_Hud$HudHandle(a.hud, b.hud)) return false;
  if (!__eq_Audio$AudioHandle(a.audio, b.audio)) return false;
  if (a.width !== b.width) return false;
  if (a.height !== b.height) return false;
  if (a.dpr !== b.dpr) return false;
  return true;
}

function __eq_Hud$HudHandle(a, b) {
  if (!__eq_Js$Dom$Node(a.hud_root, b.hud_root)) return false;
  return true;
}

function Skee$Consts$parse(text) {
  {
    const $t48980 = march_string_to_float(text);
    switch ($t48980.$) {
      case "Some": {
        const $f48981 = $t48980._0;
        {
          const x = $f48981;
          return x;
        }
        break;
      }
      case "None": {
        undefined;
        return unreachable();
        break;
      }
      default: {
        return (() => { throw new Error("non-exhaustive pattern match"); })();
      }
    }
  }
}
const Skee$Consts$parse$clo = { _0: ($_, text) => Skee$Consts$parse(text) };

function Skee$Synth$pow2($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const e = $tco_a0;
    const acc = $tco_a1;
    {
      const $t76368 = (e > 0);
      if ($t76368 === true) {
        {
          const $t76369 = ((e - 1) < 4611686018427387904 && (e - 1) >= -4611686018427387904 ? (e - 1) : march_int_ovf((e - 1), 1));
          {
            const $t76370 = (acc * 2.);
            {
              $tco_a0 = $t76369;
              $tco_a1 = $t76370;
              continue __tco;
            }
          }
        }
      } else {
        {
          const $t76371 = (e < 0);
          if ($t76371 === true) {
            {
              const $t76372 = ((e + 1) < 4611686018427387904 && (e + 1) >= -4611686018427387904 ? (e + 1) : march_int_ovf((e + 1), 0));
              {
                const $t76373 = (acc * 0.5);
                {
                  $tco_a0 = $t76372;
                  $tco_a1 = $t76373;
                  continue __tco;
                }
              }
            }
          } else {
            return acc;
          }
        }
      }
    }
    return undefined;
  }
}
const Skee$Synth$pow2$clo = { _0: ($_, e, acc) => Skee$Synth$pow2(e, acc) };

function Skee$Synth$consts() {
  {
    let r;
    {
      let $t76375_i12382;
      {
        const $t76374_i12381 = march_int_ovf(-(126), 3);
        $t76375_i12382 = Skee$Synth$pow2($t76374_i12381, 1.);
      }
      {
        let $t76377_i12384;
        {
          const $t76376_i12383 = march_int_ovf(-(97), 3);
          $t76377_i12384 = Skee$Synth$pow2($t76376_i12383, 1.5);
        }
        {
          let $t76380_i12387;
          {
            const $t76378_i12385 = Skee$Synth$pow2(128, 1.);
            {
              const $t76379_i12386 = Skee$Synth$pow2(103, 1.);
              $t76380_i12387 = ($t76378_i12385 - $t76379_i12386);
            }
          }
          {
            let $t76382_i12389;
            {
              const $t76381_i12388 = Skee$Synth$pow2(1023, 1.);
              $t76382_i12389 = ($t76381_i12388 * 2.);
            }
            r = ({ split: 536870913., tiny: $t76375_i12382, subnormal_shift: $t76377_i12384, overflow: $t76380_i12387, infinity: $t76382_i12389, dt: 0., pi: 0., rumble_follow: 0., lowpass_follow: 0., rumble_gain: 0., drum_step: 0., min_glide: 0., attack_time: 0., square_level: 0., default_glide: 0. });
          }
        }
      }
    }
    {
      let k;
      {
        const $t48982_i12372 = Skee$Consts$parse("3.141592653589793");
        {
          const $t48983_i12373 = Skee$Consts$parse("6.283185307179586");
          {
            const $t48984_i12374 = Skee$Consts$parse("0.004166666666666667");
            {
              const $t48985_i12375 = Skee$Consts$parse("1.1102230246251565e-16");
              {
                let $t48987_i12377;
                {
                  const $t48986_i12376 = Skee$Consts$parse("1e308");
                  $t48987_i12377 = ($t48986_i12376 * 10.);
                }
                {
                  let $t48989_i12379;
                  {
                    const $t48988_i12378 = (-1.);
                    $t48989_i12379 = Math.sqrt($t48988_i12378);
                  }
                  {
                    const $t48990_i12380 = Skee$Consts$parse("1.2999999523162842");
                    k = ({ pi: $t48982_i12372, tau: $t48983_i12373, dt: $t48984_i12374, unit53: $t48985_i12375, floor_u1: 1e-12, infinity: $t48987_i12377, nan: $t48989_i12379, marshmallow_drawn: $t48990_i12380 });
                  }
                }
              }
            }
          }
        }
      }
      {
        let $t76388;
        {
          const $t76387 = (1. / 44100.);
          $t76388 = Skee$Synth$f32(r, $t76387);
        }
        {
          let $t76390;
          {
            const $t76389 = k.pi;
            {
              const nearest_i12368 = Skee$Synth$f32(r, $t76389);
              {
                const $t76383_i12369 = (nearest_i12368 > $t76389);
                if ($t76383_i12369 === true) {
                  {
                    let $t76385_i12371;
                    {
                      const $t76384_i12370 = march_int_ovf(-(22), 3);
                      $t76385_i12371 = Skee$Synth$pow2($t76384_i12370, 1.);
                    }
                    $t76390 = (nearest_i12368 - $t76385_i12371);
                  }
                } else {
                  $t76390 = nearest_i12368;
                }
              }
            }
          }
          {
            let $t76391;
            $t76391 = Skee$Synth$f32(r, 0.0008);
            {
              let $t76392;
              $t76392 = Skee$Synth$f32(r, 0.035);
              {
                let $t76393;
                $t76393 = Skee$Synth$f32(r, 0.9);
                {
                  let $t76394;
                  $t76394 = Skee$Synth$f32(r, 0.055);
                  {
                    let $t76395;
                    $t76395 = Skee$Synth$f32(r, 0.0001);
                    {
                      let $t76396;
                      $t76396 = Skee$Synth$f32(r, 0.003);
                      {
                        let $t76397;
                        $t76397 = Skee$Synth$f32(r, 0.6);
                        {
                          let $t76398;
                          $t76398 = Skee$Synth$f32(r, 0.1);
                          {
                            const $rc_3719 = ({ ...r, dt: $t76388, pi: $t76390, rumble_follow: $t76391, lowpass_follow: $t76392, rumble_gain: $t76393, drum_step: $t76394, min_glide: $t76395, attack_time: $t76396, square_level: $t76397, default_glide: $t76398 });
                            return $rc_3719;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$consts$clo = { _0: ($_) => Skee$Synth$consts() };

function Skee$Synth$f32(c, x) {
  {
    let ax;
    {
      const $t76399 = (x < 0.);
      if ($t76399 === true) {
        ax = (0. - x);
      } else {
        ax = x;
      }
    }
    {
      let $t76401;
      {
        const $t76400 = c.overflow;
        $t76401 = (ax >= $t76400);
      }
      if ($t76401 === true) {
        {
          const $t76402 = (x < 0.);
          if ($t76402 === true) {
            {
              const $t76403 = c.infinity;
              return (0. - $t76403);
            }
          } else {
            {
              const $rc_3722 = c.infinity;
              return $rc_3722;
            }
          }
        }
      } else {
        {
          let $t76405;
          {
            const $t76404 = c.tiny;
            $t76405 = (ax < $t76404);
          }
          if ($t76405 === true) {
            {
              let r;
              {
                let $t76407;
                {
                  const $t76406 = c.subnormal_shift;
                  $t76407 = (x + $t76406);
                }
                {
                  const $t76408 = c.subnormal_shift;
                  r = ($t76407 - $t76408);
                }
              }
              {
                const $t76409 = (r === 0.);
                if ($t76409 === true) {
                  return (x * 0.);
                } else {
                  return r;
                }
              }
            }
          } else {
            {
              let p;
              {
                const $t76410 = c.split;
                p = (x * $t76410);
              }
              {
                const $t76411 = (p - x);
                return (p - $t76411);
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$f32$clo = { _0: ($_, c, x) => Skee$Synth$f32(c, x) };

function Skee$Synth$voice(c, w, f, to, glide, amp, decay, delay) {
  {
    let d;
    d = Skee$Synth$f32(c, decay);
    {
      let $t76420;
      $t76420 = Skee$Synth$f32(c, f);
      {
        let $t76421;
        $t76421 = Skee$Synth$f32(c, to);
        {
          let $t76424;
          {
            let $t76422;
            $t76422 = Skee$Synth$f32(c, glide);
            {
              const $t76423 = c.min_glide;
              {
                const $t48414_i12397 = ($t76423 >= $t76422);
                if ($t48414_i12397 === true) {
                  $t76424 = $t76423;
                } else {
                  $t76424 = $t76422;
                }
              }
            }
          }
          {
            let $t76425;
            $t76425 = Skee$Synth$f32(c, amp);
            {
              let $t76427;
              {
                const $t76426 = (d * 6.);
                $t76427 = Skee$Synth$f32(c, $t76426);
              }
              {
                const $t76428 = Skee$Synth$f32(c, delay);
                return ({ wave: w, freq: $t76420, freq_end: $t76421, glide_floor: $t76424, amp: $t76425, decay: d, life: $t76427, delay: $t76428, t: 0., phase: 0. });
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$voice$clo = { _0: ($_, c, w, f, to, glide, amp, decay, delay) => Skee$Synth$voice(c, w, f, to, glide, amp, decay, delay) };

function Skee$Synth$times(c, i, x) {
  {
    let $t76434;
    {
      const $t76432 = i;
      {
        let $t76433;
        $t76433 = Skee$Synth$f32(c, x);
        $t76434 = ($t76432 * $t76433);
      }
    }
    return Skee$Synth$f32(c, $t76434);
  }
}
const Skee$Synth$times$clo = { _0: ($_, c, i, x) => Skee$Synth$times(c, i, x) };

function Skee$Synth$after(c, start, i, step) {
  {
    let $t76437;
    {
      let $t76435;
      $t76435 = Skee$Synth$f32(c, start);
      {
        let $t76436;
        $t76436 = Skee$Synth$times(c, i, step);
        $t76437 = ($t76435 + $t76436);
      }
    }
    return Skee$Synth$f32(c, $t76437);
  }
}
const Skee$Synth$after$clo = { _0: ($_, c, start, i, step) => Skee$Synth$after(c, start, i, step) };

function Skee$Synth$arpeggio_from($tco_a0, $tco_a1, $tco_a2, $tco_a3, $tco_a4, $tco_a5, $tco_a6, $tco_a7) {
  __tco: for (;;) {
    const c = $tco_a0;
    const notes = $tco_a1;
    const i = $tco_a2;
    const step = $tco_a3;
    const amp = $tco_a4;
    const decay = $tco_a5;
    const w = $tco_a6;
    const acc = $tco_a7;
    switch (notes.$) {
      case "Nil": {
        {
          const $t2509_i12399 = { $: "Nil" };
          return List$reverse_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(acc, $t2509_i12399);
        }
        break;
      }
      case "Cons": {
        const $f76442 = notes._0;
        const $f76443 = notes._1;
        {
          const rest = $f76443;
          {
            const f = $f76442;
            {
              const $t76438 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
              {
                let $t76440;
                {
                  let $t76439;
                  $t76439 = Skee$Synth$times(c, i, step);
                  {
                    const $t76430_i12406 = c.default_glide;
                    $t76440 = Skee$Synth$voice(c, w, f, f, $t76430_i12406, amp, decay, $t76439);
                  }
                }
                {
                  const $t76441 = { $: "Cons", _0: $t76440, _1: acc };
                  {
                    $tco_a0 = c;
                    $tco_a1 = rest;
                    $tco_a2 = $t76438;
                    $tco_a3 = step;
                    $tco_a4 = amp;
                    $tco_a5 = decay;
                    $tco_a6 = w;
                    $tco_a7 = $t76441;
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
const Skee$Synth$arpeggio_from$clo = { _0: ($_, c, notes, i, step, amp, decay, w, acc) => Skee$Synth$arpeggio_from(c, notes, i, step, amp, decay, w, acc) };

function Skee$Synth$bell(c, pitch, loudness, delay) {
  {
    let f;
    f = Skee$Synth$f32(c, pitch);
    {
      let amp;
      amp = Skee$Synth$f32(c, loudness);
      {
        let $t76450;
        {
          const $t76449 = { $: "WaveSine" };
          {
            const $t76430_i12427 = c.default_glide;
            $t76450 = Skee$Synth$voice(c, $t76449, f, f, $t76430_i12427, amp, 0.5, delay);
          }
        }
        {
          let $t76456;
          {
            const $t76451 = { $: "WaveSine" };
            {
              let $t76453;
              {
                let $t76452;
                $t76452 = Skee$Synth$f32(c, 2.76);
                $t76453 = (f * $t76452);
              }
              {
                let $t76455;
                {
                  let $t76454;
                  $t76454 = Skee$Synth$f32(c, 0.35);
                  $t76455 = (amp * $t76454);
                }
                {
                  const $t76430_i12420 = c.default_glide;
                  $t76456 = Skee$Synth$voice(c, $t76451, $t76453, $t76453, $t76430_i12420, $t76455, 0.25, delay);
                }
              }
            }
          }
          {
            let $t76462;
            {
              const $t76457 = { $: "WaveSine" };
              {
                let $t76459;
                {
                  let $t76458;
                  $t76458 = Skee$Synth$f32(c, 5.4);
                  $t76459 = (f * $t76458);
                }
                {
                  let $t76461;
                  {
                    let $t76460;
                    $t76460 = Skee$Synth$f32(c, 0.15);
                    $t76461 = (amp * $t76460);
                  }
                  {
                    const $t76430_i12413 = c.default_glide;
                    $t76462 = Skee$Synth$voice(c, $t76457, $t76459, $t76459, $t76430_i12413, $t76461, 0.12, delay);
                  }
                }
              }
            }
            {
              const $t76463 = { $: "Nil" };
              {
                const $t76464 = { $: "Cons", _0: $t76462, _1: $t76463 };
                {
                  const $t76465 = { $: "Cons", _0: $t76456, _1: $t76464 };
                  return { $: "Cons", _0: $t76450, _1: $t76465 };
                }
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$bell$clo = { _0: ($_, c, pitch, loudness, delay) => Skee$Synth$bell(c, pitch, loudness, delay) };

function Skee$Synth$upto_from($tco_a0, $tco_a1, $tco_a2, $tco_a3) {
  __tco: for (;;) {
    const i = $tco_a0;
    const n = $tco_a1;
    const f = $tco_a2;
    const acc = $tco_a3;
    {
      const $t76467 = (i < n);
      if ($t76467 === true) {
        {
          const $t76468 = ((i + 1) < 4611686018427387904 && (i + 1) >= -4611686018427387904 ? (i + 1) : march_int_ovf((i + 1), 0));
          {
            let $t76469;
            $t76469 = f._0(f, i);
            {
              const $t76470 = { $: "Cons", _0: $t76469, _1: acc };
              {
                $tco_a0 = $t76468;
                $tco_a1 = n;
                $tco_a2 = f;
                $tco_a3 = $t76470;
                continue __tco;
              }
            }
          }
        }
      } else {
        {
          const $t2509_i12429 = { $: "Nil" };
          return List$reverse_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(acc, $t2509_i12429);
        }
      }
    }
    return undefined;
  }
}
const Skee$Synth$upto_from$clo = { _0: ($_, i, n, f, acc) => Skee$Synth$upto_from(i, n, f, acc) };

function Skee$Synth$drop_voices(c, h) {
  {
    let $p76475;
    switch (h.$) {
      case "Ring10": {
        $p76475 = { _0: 523., _1: false };
        break;
      }
      case "Ring20": {
        $p76475 = { _0: 587., _1: false };
        break;
      }
      case "Ring30": {
        $p76475 = { _0: 659., _1: false };
        break;
      }
      case "Ring40": {
        $p76475 = { _0: 784., _1: false };
        break;
      }
      case "Ring50": {
        $p76475 = { _0: 1046., _1: true };
        break;
      }
      case "PocketLeft": {
        $p76475 = { _0: 1318., _1: true };
        break;
      }
      case "PocketRight": {
        $p76475 = { _0: 1318., _1: true };
        break;
      }
      case "Gutter": {
        $p76475 = { _0: 220., _1: false };
        break;
      }
      default: {
        throw new Error("non-exhaustive pattern match");
        break;
      }
    }
    {
      const pitch = $p76475._0;
      {
        const big = $p76475._1;
        {
          let thud;
          {
            const $t76471 = { $: "WaveSine" };
            thud = Skee$Synth$voice(c, $t76471, 120., 50., 0.25, 0.6, 0.2, 0.);
          }
          {
            let $t76472;
            $t76472 = Skee$Synth$bell(c, pitch, 0.3, 0.04);
            {
              const ring = { $: "Cons", _0: thud, _1: $t76472 };
              if (big === true) {
                {
                  const $t76473 = (pitch * 1.5);
                  {
                    const $t76474 = Skee$Synth$bell(c, $t76473, 0.2, 0.12);
                    return List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(ring, $t76474);
                  }
                }
              } else {
                return ring;
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$drop_voices$clo = { _0: ($_, c, h) => Skee$Synth$drop_voices(c, h) };

function Skee$Synth$combo_voices(c, n) {
  {
    let k;
    {
      let $t76479;
      $t76479 = Skee$Synth$f32(c, 1.0595);
      {
        let $t76482;
        {
          let $t76481;
          {
            let $t76480;
            {
              const $t3993_i12456 = (n < 6);
              if ($t3993_i12456 === true) {
                $t76480 = n;
              } else {
                $t76480 = 6;
              }
            }
            $t76481 = ((2 * $t76480) < 4611686018427387904 && (2 * $t76480) >= -4611686018427387904 ? (2 * $t76480) : march_int_ovf((2 * $t76480), 2));
          }
          $t76482 = $t76481;
        }
        {
          const $t76414_i12453 = Math.pow($t76479, $t76482);
          k = Skee$Synth$f32(c, $t76414_i12453);
        }
      }
    }
    {
      let $t76485;
      {
        const $t76483 = { $: "WaveSquare" };
        {
          const $t76484 = (659. * k);
          {
            const $t76429_i12449 = c.default_glide;
            $t76485 = Skee$Synth$voice(c, $t76483, $t76484, $t76484, $t76429_i12449, 0.1, 0.08, 0.);
          }
        }
      }
      {
        let $t76488;
        {
          const $t76486 = { $: "WaveSquare" };
          {
            const $t76487 = (988. * k);
            {
              const $t76430_i12443 = c.default_glide;
              $t76488 = Skee$Synth$voice(c, $t76486, $t76487, $t76487, $t76430_i12443, 0.1, 0.14, 0.07);
            }
          }
        }
        {
          const $t76489 = { $: "Nil" };
          {
            const $t76490 = { $: "Cons", _0: $t76488, _1: $t76489 };
            {
              const $t76491 = { $: "Cons", _0: $t76485, _1: $t76490 };
              {
                const $t76492 = (1318. * k);
                {
                  const $t76493 = Skee$Synth$bell(c, $t76492, 0.15, 0.14);
                  return List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($t76491, $t76493);
                }
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$combo_voices$clo = { _0: ($_, c, n) => Skee$Synth$combo_voices(c, n) };

function Skee$Synth$tally_step(c, i) {
  {
    let $t76494;
    $t76494 = Skee$Synth$f32(c, 1.06);
    {
      const $t76495 = i;
      {
        const $t76414_i12460 = Math.pow($t76494, $t76495);
        return Skee$Synth$f32(c, $t76414_i12460);
      }
    }
  }
}
const Skee$Synth$tally_step$clo = { _0: ($_, c, i) => Skee$Synth$tally_step(c, i) };

function Skee$Synth$hot_spot_voices(c) {
  {
    let $t76504;
    $t76504 = { $: "$Clo_$lam0_Skee_Synth_hot_spot_voices$0_Skee_Synth_hot_spot_voices", _0: $lam0_Skee_Synth_hot_spot_voices$apply$0_Skee_Synth_hot_spot_voices, _1: c };
    {
      let sparkle;
      {
        const f_i12473 = $t76504;
        {
          const $t76466_i12474 = { $: "Nil" };
          sparkle = Skee$Synth$upto_from(0, 14, f_i12473, $t76466_i12474);
        }
      }
      {
        const $t76505 = { $: "Nil" };
        {
          const $t76506 = { $: "Cons", _0: 2093., _1: $t76505 };
          {
            const $t76507 = { $: "Cons", _0: 1568., _1: $t76506 };
            {
              const $t76508 = { $: "Cons", _0: 1318., _1: $t76507 };
              {
                const $t76509 = { $: "Cons", _0: 1046., _1: $t76508 };
                {
                  const $t76510 = { $: "WaveTri" };
                  {
                    let $t76511;
                    {
                      const $t76448_i12471 = { $: "Nil" };
                      $t76511 = Skee$Synth$arpeggio_from(c, $t76509, 0, 0.05, 0.2, 0.3, $t76510, $t76448_i12471);
                    }
                    {
                      const $t76512 = Skee$Synth$bell(c, 2093., 0.22, 0.2);
                      {
                        const $t76513 = { $: "Nil" };
                        {
                          const $t76514 = { $: "Cons", _0: sparkle, _1: $t76513 };
                          {
                            const $t76515 = { $: "Cons", _0: $t76512, _1: $t76514 };
                            {
                              const $t76516 = { $: "Cons", _0: $t76511, _1: $t76515 };
                              {
                                const prepend_reversed_i12462 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave", _0: prepend_reversed$apply$0_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave };
                                {
                                  const go_i12463 = { $: "$Clo_go$1_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave", _0: go$apply$1_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave, _1: prepend_reversed_i12462 };
                                  {
                                    const $t2644_i12464 = { $: "Nil" };
                                    return go$apply$1_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(go_i12463, $t76516, $t2644_i12464);
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$hot_spot_voices$clo = { _0: ($_, c) => Skee$Synth$hot_spot_voices(c) };

function Skee$Synth$jackpot_voices(c) {
  {
    let $t76524;
    $t76524 = { $: "$Clo_$lam0_Skee_Synth_jackpot_voices$0_Skee_Synth_jackpot_voices", _0: $lam0_Skee_Synth_jackpot_voices$apply$0_Skee_Synth_jackpot_voices, _1: c };
    {
      let sparkle;
      {
        const f_i12487 = $t76524;
        {
          const $t76466_i12488 = { $: "Nil" };
          sparkle = Skee$Synth$upto_from(0, 20, f_i12487, $t76466_i12488);
        }
      }
      {
        const $t76525 = { $: "Nil" };
        {
          const $t76526 = { $: "Cons", _0: 2093., _1: $t76525 };
          {
            const $t76527 = { $: "Cons", _0: 1568., _1: $t76526 };
            {
              const $t76528 = { $: "Cons", _0: 1318., _1: $t76527 };
              {
                const $t76529 = { $: "Cons", _0: 1046., _1: $t76528 };
                {
                  const $t76530 = { $: "Cons", _0: 784., _1: $t76529 };
                  {
                    const $t76531 = { $: "Cons", _0: 659., _1: $t76530 };
                    {
                      const $t76532 = { $: "Cons", _0: 523., _1: $t76531 };
                      {
                        const $t76533 = { $: "WaveTri" };
                        {
                          let $t76534;
                          {
                            const $t76448_i12485 = { $: "Nil" };
                            $t76534 = Skee$Synth$arpeggio_from(c, $t76532, 0, 0.055, 0.25, 0.3, $t76533, $t76448_i12485);
                          }
                          {
                            let $t76535;
                            $t76535 = Skee$Synth$bell(c, 1046., 0.35, 0.4);
                            {
                              const $t76536 = Skee$Synth$bell(c, 1568., 0.25, 0.45);
                              {
                                const $t76537 = { $: "Nil" };
                                {
                                  const $t76538 = { $: "Cons", _0: sparkle, _1: $t76537 };
                                  {
                                    const $t76539 = { $: "Cons", _0: $t76536, _1: $t76538 };
                                    {
                                      const $t76540 = { $: "Cons", _0: $t76535, _1: $t76539 };
                                      {
                                        const $t76541 = { $: "Cons", _0: $t76534, _1: $t76540 };
                                        {
                                          const prepend_reversed_i12476 = { $: "$Clo_prepend_reversed$0_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave", _0: prepend_reversed$apply$0_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave };
                                          {
                                            const go_i12477 = { $: "$Clo_go$1_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave", _0: go$apply$1_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave, _1: prepend_reversed_i12476 };
                                            {
                                              const $t2644_i12478 = { $: "Nil" };
                                              return go$apply$1_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(go_i12477, $t76541, $t2644_i12478);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$jackpot_voices$clo = { _0: ($_, c) => Skee$Synth$jackpot_voices(c) };

function Skee$Synth$lever_voices(c) {
  {
    let $t76548;
    $t76548 = { $: "$Clo_$lam0_Skee_Synth_lever_voices$0_Skee_Synth_lever_voices", _0: $lam0_Skee_Synth_lever_voices$apply$0_Skee_Synth_lever_voices, _1: c };
    {
      let ratchet;
      {
        const f_i12497 = $t76548;
        {
          const $t76466_i12498 = { $: "Nil" };
          ratchet = Skee$Synth$upto_from(0, 6, f_i12497, $t76466_i12498);
        }
      }
      {
        let $t76550;
        {
          const $t76549 = { $: "WaveSine" };
          $t76550 = Skee$Synth$voice(c, $t76549, 90., 60., 0.1, 0.45, 0.12, 0.16);
        }
        {
          let $t76552;
          {
            const $t76551 = { $: "WaveNoise" };
            {
              const $t76430_i12495 = c.default_glide;
              $t76552 = Skee$Synth$voice(c, $t76551, 0., 0., $t76430_i12495, 0.08, 0.05, 0.16);
            }
          }
          {
            const $t76553 = { $: "Nil" };
            {
              const $t76554 = { $: "Cons", _0: $t76552, _1: $t76553 };
              {
                const $t76555 = { $: "Cons", _0: $t76550, _1: $t76554 };
                return List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(ratchet, $t76555);
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$lever_voices$clo = { _0: ($_, c) => Skee$Synth$lever_voices(c) };

function Skee$Synth$pull_win_voices(c, chips) {
  {
    let n;
    {
      let $t76557;
      {
        let $t76556;
        {
          const $t76476_i23231 = (chips < 0);
          if ($t76476_i23231 === true) {
            {
              let $t76478_i23233;
              {
                const $t76477_i23232 = ((0 - chips) < 4611686018427387904 && (0 - chips) >= -4611686018427387904 ? (0 - chips) : march_int_ovf((0 - chips), 1));
                $t76478_i23233 = (($t76477_i23232 - $t76477_i23232 % 15) / 15);
              }
              $t76556 = ((0 - $t76478_i23233) < 4611686018427387904 && (0 - $t76478_i23233) >= -4611686018427387904 ? (0 - $t76478_i23233) : march_int_ovf((0 - $t76478_i23233), 1));
            }
          } else {
            $t76556 = ((chips - chips % 15) / 15);
          }
        }
        $t76557 = ((6 + $t76556) < 4611686018427387904 && (6 + $t76556) >= -4611686018427387904 ? (6 + $t76556) : march_int_ovf((6 + $t76556), 0));
      }
      {
        const $t3993_i12511 = (30 < $t76557);
        if ($t3993_i12511 === true) {
          n = 30;
        } else {
          n = $t76557;
        }
      }
    }
    {
      let $t76566;
      $t76566 = { $: "$Clo_$lam0_Skee_Synth_pull_win_voices$0_Skee_Synth_pull_win_voices", _0: $lam0_Skee_Synth_pull_win_voices$apply$0_Skee_Synth_pull_win_voices, _1: c };
      {
        let rattle;
        {
          const f_i12507 = $t76566;
          {
            const $t76466_i12508 = { $: "Nil" };
            rattle = Skee$Synth$upto_from(0, n, f_i12507, $t76466_i12508);
          }
        }
        {
          const $t76567 = { $: "Nil" };
          {
            const $t76568 = { $: "Cons", _0: 1175., _1: $t76567 };
            {
              const $t76569 = { $: "Cons", _0: 988., _1: $t76568 };
              {
                const $t76570 = { $: "Cons", _0: 784., _1: $t76569 };
                {
                  const $t76571 = { $: "WaveSine" };
                  {
                    let $t76572;
                    {
                      const $t76448_i12505 = { $: "Nil" };
                      $t76572 = Skee$Synth$arpeggio_from(c, $t76570, 0, 0.07, 0.2, 0.12, $t76571, $t76448_i12505);
                    }
                    return List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($t76572, rattle);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$pull_win_voices$clo = { _0: ($_, c, chips) => Skee$Synth$pull_win_voices(c, chips) };

function Skee$Synth$banner_voices(c, text) {
  {
    const $t76573 = (text === "CLEARED");
    if ($t76573 === true) {
      {
        let $t76577;
        $t76577 = { $: "$Clo_$lam0_Skee_Synth_banner_voices$0_Skee_Synth_banner_voices", _0: $lam0_Skee_Synth_banner_voices$apply$0_Skee_Synth_banner_voices, _1: c };
        {
          let ticks;
          {
            const f_i12553 = $t76577;
            {
              const $t76466_i12554 = { $: "Nil" };
              ticks = Skee$Synth$upto_from(0, 16, f_i12553, $t76466_i12554);
            }
          }
          {
            const $t76578 = { $: "Nil" };
            {
              const $t76579 = { $: "Cons", _0: 1046., _1: $t76578 };
              {
                const $t76580 = { $: "Cons", _0: 784., _1: $t76579 };
                {
                  const $t76581 = { $: "Cons", _0: 659., _1: $t76580 };
                  {
                    const $t76582 = { $: "Cons", _0: 523., _1: $t76581 };
                    {
                      const $t76583 = { $: "Cons", _0: 392., _1: $t76582 };
                      {
                        const $t76584 = { $: "WaveSine" };
                        {
                          let $t76585;
                          {
                            const $t76448_i12551 = { $: "Nil" };
                            $t76585 = Skee$Synth$arpeggio_from(c, $t76583, 0, 0.08, 0.22, 0.25, $t76584, $t76448_i12551);
                          }
                          return List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($t76585, ticks);
                        }
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
        const $t76586 = (text === "FREE GAMES");
        if ($t76586 === true) {
          {
            const $t76587 = { $: "Nil" };
            {
              const $t76588 = { $: "Cons", _0: 1568., _1: $t76587 };
              {
                const $t76589 = { $: "Cons", _0: 1318., _1: $t76588 };
                {
                  const $t76590 = { $: "Cons", _0: 1046., _1: $t76589 };
                  {
                    const $t76591 = { $: "Cons", _0: 784., _1: $t76590 };
                    {
                      const $t76592 = { $: "Cons", _0: 1046., _1: $t76591 };
                      {
                        const $t76593 = { $: "Cons", _0: 784., _1: $t76592 };
                        {
                          const $t76594 = { $: "Cons", _0: 659., _1: $t76593 };
                          {
                            const $t76595 = { $: "Cons", _0: 523., _1: $t76594 };
                            {
                              const $t76596 = { $: "WaveSquare" };
                              {
                                const $t76448_i12544 = { $: "Nil" };
                                return Skee$Synth$arpeggio_from(c, $t76595, 0, 0.07, 0.22, 0.2, $t76596, $t76448_i12544);
                              }
                            }
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
            const $t76597 = march_string_ends_with(text, "JACKPOT");
            if ($t76597 === true) {
              {
                let $t76605;
                $t76605 = { $: "$Clo_$lam1_Skee_Synth_banner_voices$1_Skee_Synth_banner_voices", _0: $lam1_Skee_Synth_banner_voices$apply$1_Skee_Synth_banner_voices, _1: c };
                {
                  let shower;
                  {
                    const f_i12534 = $t76605;
                    {
                      const $t76466_i12535 = { $: "Nil" };
                      shower = Skee$Synth$upto_from(0, 40, f_i12534, $t76466_i12535);
                    }
                  }
                  {
                    const $t76606 = { $: "Nil" };
                    {
                      const $t76607 = { $: "Cons", _0: 2637., _1: $t76606 };
                      {
                        const $t76608 = { $: "Cons", _0: 2093., _1: $t76607 };
                        {
                          const $t76609 = { $: "Cons", _0: 1568., _1: $t76608 };
                          {
                            const $t76610 = { $: "Cons", _0: 1318., _1: $t76609 };
                            {
                              const $t76611 = { $: "Cons", _0: 1046., _1: $t76610 };
                              {
                                const $t76612 = { $: "Cons", _0: 784., _1: $t76611 };
                                {
                                  const $t76613 = { $: "Cons", _0: 659., _1: $t76612 };
                                  {
                                    const $t76614 = { $: "Cons", _0: 523., _1: $t76613 };
                                    {
                                      const $t76615 = { $: "WaveTri" };
                                      {
                                        let $t76616;
                                        {
                                          const $t76448_i12532 = { $: "Nil" };
                                          $t76616 = Skee$Synth$arpeggio_from(c, $t76614, 0, 0.06, 0.25, 0.35, $t76615, $t76448_i12532);
                                        }
                                        return List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($t76616, shower);
                                      }
                                    }
                                  }
                                }
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
                const $t76617 = (text === "GAME OVER");
                if ($t76617 === true) {
                  {
                    const $t76618 = { $: "Nil" };
                    {
                      const $t76619 = { $: "Cons", _0: 294., _1: $t76618 };
                      {
                        const $t76620 = { $: "Cons", _0: 349., _1: $t76619 };
                        {
                          const $t76621 = { $: "Cons", _0: 370., _1: $t76620 };
                          {
                            const $t76622 = { $: "Cons", _0: 392., _1: $t76621 };
                            {
                              const $t76623 = { $: "WaveSquare" };
                              {
                                const $t76448_i12525 = { $: "Nil" };
                                return Skee$Synth$arpeggio_from(c, $t76622, 0, 0.3, 0.15, 0.4, $t76623, $t76448_i12525);
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                } else {
                  {
                    const $t76624 = (text === "FEVER");
                    if ($t76624 === true) {
                      {
                        let $t76626;
                        {
                          const $t76625 = { $: "WaveSquare" };
                          $t76626 = Skee$Synth$voice(c, $t76625, 300., 1200., 0.5, 0.1, 0.4, 0.);
                        }
                        {
                          const $t76627 = Skee$Synth$bell(c, 1568., 0.2, 0.5);
                          return { $: "Cons", _0: $t76626, _1: $t76627 };
                        }
                      }
                    } else {
                      return Skee$Synth$bell(c, 784., 0.18, 0.);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$banner_voices$clo = { _0: ($_, c, text) => Skee$Synth$banner_voices(c, text) };

function Skee$Synth$hump_voices(c) {
  {
    let $t76635;
    {
      const $t76634 = { $: "WaveSine" };
      $t76635 = Skee$Synth$voice(c, $t76634, 170., 120., 0.08, 0.55, 0.07, 0.);
    }
    {
      let $t76637;
      {
        const $t76636 = { $: "WaveTri" };
        {
          const $t76429_i12580 = c.default_glide;
          $t76637 = Skee$Synth$voice(c, $t76636, 950., 950., $t76429_i12580, 0.18, 0.015, 0.);
        }
      }
      {
        let $t76639;
        {
          const $t76638 = { $: "WaveNoise" };
          {
            const $t76429_i12574 = c.default_glide;
            $t76639 = Skee$Synth$voice(c, $t76638, 0., 0., $t76429_i12574, 0.08, 0.02, 0.);
          }
        }
        {
          const $t76640 = { $: "Nil" };
          {
            const $t76641 = { $: "Cons", _0: $t76639, _1: $t76640 };
            {
              const $t76642 = { $: "Cons", _0: $t76637, _1: $t76641 };
              return { $: "Cons", _0: $t76635, _1: $t76642 };
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$hump_voices$clo = { _0: ($_, c) => Skee$Synth$hump_voices(c) };

function Skee$Synth$voices_for(c, snd) {
  switch (snd.$) {
    case "SndLaunch": {
      {
        let $t76644;
        {
          const $t76643 = { $: "WaveNoise" };
          {
            const $t76429_i12600 = c.default_glide;
            $t76644 = Skee$Synth$voice(c, $t76643, 0., 0., $t76429_i12600, 0.12, 0.08, 0.);
          }
        }
        {
          let $t76646;
          {
            const $t76645 = { $: "WaveSine" };
            $t76646 = Skee$Synth$voice(c, $t76645, 180., 320., 0.12, 0.15, 0.08, 0.);
          }
          {
            const $t76647 = { $: "Nil" };
            {
              const $t76648 = { $: "Cons", _0: $t76646, _1: $t76647 };
              return { $: "Cons", _0: $t76644, _1: $t76648 };
            }
          }
        }
      }
      break;
    }
    case "SndWhoosh": {
      {
        let $t76650;
        {
          const $t76649 = { $: "WaveNoise" };
          {
            const $t76429_i12613 = c.default_glide;
            $t76650 = Skee$Synth$voice(c, $t76649, 0., 0., $t76429_i12613, 0.16, 0.3, 0.);
          }
        }
        {
          let $t76652;
          {
            const $t76651 = { $: "WaveSine" };
            $t76652 = Skee$Synth$voice(c, $t76651, 900., 180., 0.5, 0.2, 0.3, 0.);
          }
          {
            const $t76653 = { $: "Nil" };
            {
              const $t76654 = { $: "Cons", _0: $t76652, _1: $t76653 };
              return { $: "Cons", _0: $t76650, _1: $t76654 };
            }
          }
        }
      }
      break;
    }
    case "SndHotSpot": {
      return Skee$Synth$hot_spot_voices(c);
      break;
    }
    case "SndHop": {
      {
        const c_i27707 = c;
        {
          let $t76629_i27709;
          {
            const $t76628_i27708 = { $: "WaveSine" };
            $t76629_i27709 = Skee$Synth$voice(c, $t76628_i27708, 220., 780., 0.09, 0.3, 0.12, 0.);
          }
          {
            let $t76631_i27711;
            {
              const $t76630_i27710 = { $: "WaveTri" };
              $t76631_i27711 = Skee$Synth$voice(c, $t76630_i27710, 440., 1100., 0.09, 0.1, 0.08, 0.);
            }
            {
              const $t76632_i27712 = { $: "Nil" };
              {
                const $t76633_i27713 = { $: "Cons", _0: $t76631_i27711, _1: $t76632_i27712 };
                return { $: "Cons", _0: $t76629_i27709, _1: $t76633_i27713 };
              }
            }
          }
        }
      }
      break;
    }
    case "SndRail": {
      {
        let $t76656;
        {
          const $t76655 = { $: "WaveTri" };
          {
            const $t76429_i12619 = c.default_glide;
            $t76656 = Skee$Synth$voice(c, $t76655, 900., 900., $t76429_i12619, 0.15, 0.03, 0.);
          }
        }
        {
          const $t76657 = { $: "Nil" };
          return { $: "Cons", _0: $t76656, _1: $t76657 };
        }
      }
      break;
    }
    case "SndHump": {
      return Skee$Synth$hump_voices(c);
      break;
    }
    case "SndLip": {
      {
        let $t76659;
        {
          const $t76658 = { $: "WaveTri" };
          {
            const $t76429_i12632 = c.default_glide;
            $t76659 = Skee$Synth$voice(c, $t76658, 1900., 1900., $t76429_i12632, 0.2, 0.02, 0.);
          }
        }
        {
          let $t76661;
          {
            const $t76660 = { $: "WaveTri" };
            {
              const $t76430_i12626 = c.default_glide;
              $t76661 = Skee$Synth$voice(c, $t76660, 2300., 2300., $t76430_i12626, 0.16, 0.02, 0.035);
            }
          }
          {
            const $t76662 = { $: "Nil" };
            {
              const $t76663 = { $: "Cons", _0: $t76661, _1: $t76662 };
              return { $: "Cons", _0: $t76659, _1: $t76663 };
            }
          }
        }
      }
      break;
    }
    case "SndBackwall": {
      {
        let $t76665;
        {
          const $t76664 = { $: "WaveSine" };
          {
            const $t76431_i12645 = c.default_glide;
            $t76665 = Skee$Synth$voice(c, $t76664, 110., 80., $t76431_i12645, 0.4, 0.12, 0.);
          }
        }
        {
          let $t76667;
          {
            const $t76666 = { $: "WaveNoise" };
            {
              const $t76429_i12638 = c.default_glide;
              $t76667 = Skee$Synth$voice(c, $t76666, 0., 0., $t76429_i12638, 0.06, 0.04, 0.);
            }
          }
          {
            const $t76668 = { $: "Nil" };
            {
              const $t76669 = { $: "Cons", _0: $t76667, _1: $t76668 };
              return { $: "Cons", _0: $t76665, _1: $t76669 };
            }
          }
        }
      }
      break;
    }
    case "SndLanded": {
      {
        let $t76671;
        {
          const $t76670 = { $: "WaveSine" };
          {
            const $t76431_i12652 = c.default_glide;
            $t76671 = Skee$Synth$voice(c, $t76670, 140., 100., $t76431_i12652, 0.3, 0.06, 0.);
          }
        }
        {
          const $t76672 = { $: "Nil" };
          return { $: "Cons", _0: $t76671, _1: $t76672 };
        }
      }
      break;
    }
    case "SndDrop": {
      const $f76718 = snd._0;
      {
        const h = $f76718;
        {
          const $rc_3728 = Skee$Synth$drop_voices(c, h);
          return $rc_3728;
        }
      }
      break;
    }
    case "SndGutter": {
      {
        let $t76674;
        {
          const $t76673 = { $: "WaveSine" };
          $t76674 = Skee$Synth$voice(c, $t76673, 220., 70., 0.45, 0.35, 0.35, 0.);
        }
        {
          let $t76676;
          {
            const $t76675 = { $: "WaveNoise" };
            {
              const $t76429_i12658 = c.default_glide;
              $t76676 = Skee$Synth$voice(c, $t76675, 0., 0., $t76429_i12658, 0.05, 0.1, 0.);
            }
          }
          {
            const $t76677 = { $: "Nil" };
            {
              const $t76678 = { $: "Cons", _0: $t76676, _1: $t76677 };
              return { $: "Cons", _0: $t76674, _1: $t76678 };
            }
          }
        }
      }
      break;
    }
    case "SndReelTick": {
      {
        let $t76680;
        {
          const $t76679 = { $: "WaveTri" };
          {
            const $t76429_i12671 = c.default_glide;
            $t76680 = Skee$Synth$voice(c, $t76679, 2600., 2600., $t76429_i12671, 0.07, 0.012, 0.);
          }
        }
        {
          const $t76681 = { $: "Nil" };
          return { $: "Cons", _0: $t76680, _1: $t76681 };
        }
      }
      break;
    }
    case "SndReelStop": {
      {
        let $t76683;
        {
          const $t76682 = { $: "WaveTri" };
          {
            const $t76429_i12683 = c.default_glide;
            $t76683 = Skee$Synth$voice(c, $t76682, 1500., 1500., $t76429_i12683, 0.18, 0.05, 0.);
          }
        }
        {
          let $t76685;
          {
            const $t76684 = { $: "WaveSine" };
            {
              const $t76429_i12677 = c.default_glide;
              $t76685 = Skee$Synth$voice(c, $t76684, 750., 750., $t76429_i12677, 0.12, 0.08, 0.);
            }
          }
          {
            const $t76686 = { $: "Nil" };
            {
              const $t76687 = { $: "Cons", _0: $t76685, _1: $t76686 };
              return { $: "Cons", _0: $t76683, _1: $t76687 };
            }
          }
        }
      }
      break;
    }
    case "SndCombo": {
      const $f76719 = snd._0;
      {
        const n = $f76719;
        return Skee$Synth$combo_voices(c, n);
      }
      break;
    }
    case "SndTallyChips": {
      const $f76720 = snd._0;
      {
        const i = $f76720;
        {
          let $t76691;
          {
            const $t76688 = { $: "WaveSine" };
            {
              let $t76690;
              {
                let $t76689;
                $t76689 = Skee$Synth$tally_step(c, i);
                $t76690 = (440. * $t76689);
              }
              {
                const $t76429_i12689 = c.default_glide;
                $t76691 = Skee$Synth$voice(c, $t76688, $t76690, $t76690, $t76429_i12689, 0.22, 0.07, 0.);
              }
            }
          }
          {
            const $t76692 = { $: "Nil" };
            return { $: "Cons", _0: $t76691, _1: $t76692 };
          }
        }
      }
      break;
    }
    case "SndTallyMult": {
      const $f76721 = snd._0;
      {
        const i = $f76721;
        {
          let $t76696;
          {
            const $t76693 = { $: "WaveSquare" };
            {
              let $t76695;
              {
                let $t76694;
                $t76694 = Skee$Synth$tally_step(c, i);
                $t76695 = (587. * $t76694);
              }
              {
                const $t76429_i12701 = c.default_glide;
                $t76696 = Skee$Synth$voice(c, $t76693, $t76695, $t76695, $t76429_i12701, 0.1, 0.09, 0.);
              }
            }
          }
          {
            let $t76700;
            {
              const $t76697 = { $: "WaveSine" };
              {
                let $t76699;
                {
                  let $t76698;
                  $t76698 = Skee$Synth$tally_step(c, i);
                  $t76699 = (1174. * $t76698);
                }
                {
                  const $t76429_i12695 = c.default_glide;
                  $t76700 = Skee$Synth$voice(c, $t76697, $t76699, $t76699, $t76429_i12695, 0.08, 0.06, 0.);
                }
              }
            }
            {
              const $t76701 = { $: "Nil" };
              {
                const $t76702 = { $: "Cons", _0: $t76700, _1: $t76701 };
                return { $: "Cons", _0: $t76696, _1: $t76702 };
              }
            }
          }
        }
      }
      break;
    }
    case "SndFrameDone": {
      {
        let $t76704;
        {
          const $t76703 = { $: "WaveSine" };
          {
            const $t76429_i12707 = c.default_glide;
            $t76704 = Skee$Synth$voice(c, $t76703, 392., 392., $t76429_i12707, 0.2, 0.15, 0.);
          }
        }
        {
          const $t76705 = { $: "Nil" };
          return { $: "Cons", _0: $t76704, _1: $t76705 };
        }
      }
      break;
    }
    case "SndLineWon": {
      {
        const $t76706 = { $: "Nil" };
        {
          const $t76707 = { $: "Cons", _0: 1046., _1: $t76706 };
          {
            const $t76708 = { $: "Cons", _0: 784., _1: $t76707 };
            {
              const $t76709 = { $: "Cons", _0: 659., _1: $t76708 };
              {
                const $t76710 = { $: "Cons", _0: 523., _1: $t76709 };
                {
                  const $t76711 = { $: "WaveSine" };
                  {
                    const $t76448_i12714 = { $: "Nil" };
                    return Skee$Synth$arpeggio_from(c, $t76710, 0, 0.06, 0.22, 0.18, $t76711, $t76448_i12714);
                  }
                }
              }
            }
          }
        }
      }
      break;
    }
    case "SndJackpot": {
      return Skee$Synth$jackpot_voices(c);
      break;
    }
    case "SndBanner": {
      const $f76722 = snd._0;
      {
        const text = $f76722;
        {
          const $rc_3729 = Skee$Synth$banner_voices(c, text);
          return $rc_3729;
        }
      }
      break;
    }
    case "SndLever": {
      return Skee$Synth$lever_voices(c);
      break;
    }
    case "SndPullWin": {
      const $f76723 = snd._0;
      {
        const chips = $f76723;
        return Skee$Synth$pull_win_voices(c, chips);
      }
      break;
    }
    case "SndFoul": {
      {
        let $t76713;
        {
          const $t76712 = { $: "WaveSquare" };
          {
            const $t76429_i12726 = c.default_glide;
            $t76713 = Skee$Synth$voice(c, $t76712, 110., 110., $t76429_i12726, 0.25, 0.3, 0.);
          }
        }
        {
          let $t76715;
          {
            const $t76714 = { $: "WaveSquare" };
            {
              const $t76429_i12720 = c.default_glide;
              $t76715 = Skee$Synth$voice(c, $t76714, 104., 104., $t76429_i12720, 0.2, 0.3, 0.);
            }
          }
          {
            const $t76716 = { $: "Nil" };
            {
              const $t76717 = { $: "Cons", _0: $t76715, _1: $t76716 };
              return { $: "Cons", _0: $t76713, _1: $t76717 };
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
const Skee$Synth$voices_for$clo = { _0: ($_, c, snd) => Skee$Synth$voices_for(c, snd) };

function Skee$Synth$next_seed(seed) {
  {
    let $t76732;
    {
      const $t76731 = ((seed * 1664525) < 4611686018427387904 && (seed * 1664525) >= -4611686018427387904 ? (seed * 1664525) : march_int_ovf((seed * 1664525), 2));
      $t76732 = (($t76731 + 1013904223) < 4611686018427387904 && ($t76731 + 1013904223) >= -4611686018427387904 ? ($t76731 + 1013904223) : march_int_ovf(($t76731 + 1013904223), 0));
    }
    return ($t76732 % 4294967296);
  }
}
const Skee$Synth$next_seed$clo = { _0: ($_, seed) => Skee$Synth$next_seed(seed) };

function Skee$Synth$noise_of(seed) {
  {
    let $t76736;
    {
      let $t76735;
      {
        let $t76734;
        {
          const $t76733 = ((seed - seed % 512) / 512);
          $t76734 = $t76733;
        }
        $t76735 = ($t76734 / 8388608.);
      }
      $t76736 = ($t76735 * 2.);
    }
    return ($t76736 - 1.);
  }
}
const Skee$Synth$noise_of$clo = { _0: ($_, seed) => Skee$Synth$noise_of(seed) };

function Skee$Synth$oscillate(c, w, phase, seed) {
  switch (w.$) {
    case "WaveSine": {
      {
        let $t76741;
        {
          let $t76740;
          {
            let $t76739;
            {
              const $t76737 = (phase * 2.);
              {
                const $t76738 = c.pi;
                $t76739 = ($t76737 * $t76738);
              }
            }
            $t76740 = Skee$Synth$f32(c, $t76739);
          }
          {
            const $t76412_i12730 = Math.sin($t76740);
            $t76741 = Skee$Synth$f32(c, $t76412_i12730);
          }
        }
        return { _0: $t76741, _1: seed };
      }
      break;
    }
    case "WaveSquare": {
      {
        let $t76744;
        {
          const $t76742 = (phase < 0.5);
          if ($t76742 === true) {
            $t76744 = c.square_level;
          } else {
            {
              const $t76743 = c.square_level;
              $t76744 = (0. - $t76743);
            }
          }
        }
        return { _0: $t76744, _1: seed };
      }
      break;
    }
    case "WaveTri": {
      {
        let centred;
        {
          const $t76745 = (phase - 0.5);
          centred = Skee$Synth$f32(c, $t76745);
        }
        {
          let folded;
          {
            const $t76746 = (centred < 0.);
            if ($t76746 === true) {
              folded = (0. - centred);
            } else {
              folded = centred;
            }
          }
          {
            let $t76750;
            {
              let $t76749;
              {
                let $t76748;
                {
                  const $t76747 = (4. * folded);
                  $t76748 = Skee$Synth$f32(c, $t76747);
                }
                $t76749 = ($t76748 - 1.);
              }
              $t76750 = Skee$Synth$f32(c, $t76749);
            }
            return { _0: $t76750, _1: seed };
          }
        }
      }
      break;
    }
    case "WaveNoise": {
      {
        const next = Skee$Synth$next_seed(seed);
        {
          const $t76751 = Skee$Synth$noise_of(next);
          return { _0: $t76751, _1: next };
        }
      }
      break;
    }
    default: {
      return (() => { throw new Error("non-exhaustive pattern match"); })();
    }
  }
}
const Skee$Synth$oscillate$clo = { _0: ($_, c, w, phase, seed) => Skee$Synth$oscillate(c, w, phase, seed) };

function Skee$Synth$sound_voice(c, v, m) {
  {
    let f;
    {
      let $t76764;
      {
        const $t76752 = v.freq;
        {
          let $t76763;
          {
            let $t76762;
            {
              let $t76756;
              {
                let $t76755;
                {
                  const $t76753 = v.freq_end;
                  {
                    const $t76754 = v.freq;
                    $t76755 = ($t76753 - $t76754);
                  }
                }
                $t76756 = Skee$Synth$f32(c, $t76755);
              }
              {
                let $t76761;
                {
                  let $t76760;
                  {
                    let $t76759;
                    {
                      const $t76757 = v.t;
                      {
                        const $t76758 = v.glide_floor;
                        $t76759 = ($t76757 / $t76758);
                      }
                    }
                    $t76760 = Skee$Synth$f32(c, $t76759);
                  }
                  {
                    const $t48415_i12739 = ($t76760 < 1.);
                    if ($t48415_i12739 === true) {
                      $t76761 = $t76760;
                    } else {
                      $t76761 = 1.;
                    }
                  }
                }
                $t76762 = ($t76756 * $t76761);
              }
            }
            $t76763 = Skee$Synth$f32(c, $t76762);
          }
          $t76764 = ($t76752 + $t76763);
        }
      }
      f = Skee$Synth$f32(c, $t76764);
    }
    {
      let stepped;
      {
        let $t76769;
        {
          const $t76765 = v.phase;
          {
            let $t76768;
            {
              let $t76767;
              {
                const $t76766 = c.dt;
                $t76767 = (f * $t76766);
              }
              $t76768 = Skee$Synth$f32(c, $t76767);
            }
            $t76769 = ($t76765 + $t76768);
          }
        }
        stepped = Skee$Synth$f32(c, $t76769);
      }
      {
        let phase;
        {
          const $t76770 = (stepped > 1.);
          if ($t76770 === true) {
            {
              const $t76771 = (stepped - 1.);
              phase = Skee$Synth$f32(c, $t76771);
            }
          } else {
            phase = stepped;
          }
        }
        {
          let $p76799;
          {
            const $t76772 = v.wave;
            {
              const $t76773 = m.mix_seed;
              $p76799 = Skee$Synth$oscillate(c, $t76772, phase, $t76773);
            }
          }
          {
            const osc = $p76799._0;
            {
              const seed = $p76799._1;
              {
                let attack;
                {
                  let $t76777;
                  {
                    let $t76776;
                    {
                      const $t76774 = v.t;
                      {
                        const $t76775 = c.attack_time;
                        $t76776 = ($t76774 / $t76775);
                      }
                    }
                    $t76777 = Skee$Synth$f32(c, $t76776);
                  }
                  {
                    const $t48415_i12736 = ($t76777 < 1.);
                    if ($t48415_i12736 === true) {
                      attack = $t76777;
                    } else {
                      attack = 1.;
                    }
                  }
                }
                {
                  let envelope;
                  {
                    let $t76782;
                    {
                      let $t76781;
                      {
                        let $t76779;
                        {
                          const $t76778 = v.t;
                          $t76779 = (0. - $t76778);
                        }
                        {
                          const $t76780 = v.decay;
                          $t76781 = ($t76779 / $t76780);
                        }
                      }
                      $t76782 = Skee$Synth$f32(c, $t76781);
                    }
                    {
                      const $t76413_i12733 = Math.exp($t76782);
                      envelope = Skee$Synth$f32(c, $t76413_i12733);
                    }
                  }
                  {
                    let level;
                    {
                      let $t76791;
                      {
                        const $t76783 = m.level;
                        {
                          let $t76790;
                          {
                            let $t76789;
                            {
                              let $t76788;
                              {
                                let $t76787;
                                {
                                  let $t76786;
                                  {
                                    let $t76785;
                                    {
                                      const $t76784 = v.amp;
                                      $t76785 = (osc * $t76784);
                                    }
                                    $t76786 = Skee$Synth$f32(c, $t76785);
                                  }
                                  $t76787 = ($t76786 * attack);
                                }
                                $t76788 = Skee$Synth$f32(c, $t76787);
                              }
                              $t76789 = ($t76788 * envelope);
                            }
                            $t76790 = Skee$Synth$f32(c, $t76789);
                          }
                          $t76791 = ($t76783 + $t76790);
                        }
                      }
                      level = Skee$Synth$f32(c, $t76791);
                    }
                    {
                      let t;
                      {
                        let $t76794;
                        {
                          const $t76792 = v.t;
                          {
                            const $t76793 = c.dt;
                            $t76794 = ($t76792 + $t76793);
                          }
                        }
                        t = Skee$Synth$f32(c, $t76794);
                      }
                      {
                        let $t76796;
                        {
                          const $t76795 = v.life;
                          $t76796 = (t > $t76795);
                        }
                        {
                          let kept;
                          if ($t76796 === true) {
                            {
                              const $rc_3731 = m.kept;
                              kept = $rc_3731;
                            }
                          } else {
                            {
                              const $t76797 = ({ ...v, t: t, phase: phase });
                              {
                                const $t76798 = m.kept;
                                kept = { $: "Cons", _0: $t76797, _1: $t76798 };
                              }
                            }
                          }
                          {
                            const $rc_3733 = ({ level: level, mix_seed: seed, kept: kept });
                            return $rc_3733;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$sound_voice$clo = { _0: ($_, c, v, m) => Skee$Synth$sound_voice(c, v, m) };

function Skee$Synth$mix_voices($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const c = $tco_a0;
    const vs = $tco_a1;
    const m = $tco_a2;
    switch (vs.$) {
      case "Nil": {
        return m;
        break;
      }
      case "Cons": {
        const $f76811 = vs._0;
        const $f76812 = vs._1;
        {
          const rest = $f76812;
          {
            const v = $f76811;
            {
              let $t76801;
              {
                const $t76800 = v.delay;
                $t76801 = ($t76800 > 0.);
              }
              if ($t76801 === true) {
                {
                  let $t76809;
                  {
                    let $t76806;
                    {
                      let $t76805;
                      {
                        let $t76804;
                        {
                          const $t76802 = v.delay;
                          {
                            const $t76803 = c.dt;
                            $t76804 = ($t76802 - $t76803);
                          }
                        }
                        $t76805 = Skee$Synth$f32(c, $t76804);
                      }
                      $t76806 = ({ ...v, delay: $t76805 });
                    }
                    {
                      const $t76807 = m.kept;
                      {
                        let $t76808;
                        $t76808 = { $: "Cons", _0: $t76806, _1: $t76807 };
                        $t76809 = ({ ...m, kept: $t76808 });
                      }
                    }
                  }
                  {
                    $tco_a0 = c;
                    $tco_a1 = rest;
                    $tco_a2 = $t76809;
                    continue __tco;
                  }
                }
              } else {
                {
                  let $t76810;
                  $t76810 = Skee$Synth$sound_voice(c, v, m);
                  {
                    $tco_a0 = c;
                    $tco_a1 = rest;
                    $tco_a2 = $t76810;
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
const Skee$Synth$mix_voices$clo = { _0: ($_, c, vs, m) => Skee$Synth$mix_voices(c, vs, m) };

function Skee$Synth$drum_roll(s) {
  {
    const $t76817 = s.drum;
    if ($t76817 === true) {
      {
        const c = s.c;
        {
          let clock;
          {
            let $t76820;
            {
              const $t76818 = s.drum_clock;
              {
                const $t76819 = c.dt;
                $t76820 = ($t76818 + $t76819);
              }
            }
            clock = Skee$Synth$f32(c, $t76820);
          }
          {
            let $t76822;
            {
              const $t76821 = c.drum_step;
              $t76822 = (clock > $t76821);
            }
            if ($t76822 === true) {
              {
                const $t76823 = s.voices;
                {
                  let $t76825;
                  {
                    const $t76824 = { $: "WaveNoise" };
                    $t76825 = Skee$Synth$voice(c, $t76824, 0., 0., 1., 0.13, 0.03, 0.);
                  }
                  {
                    const $t76826 = { $: "Nil" };
                    {
                      const $t76827 = { $: "Cons", _0: $t76825, _1: $t76826 };
                      {
                        let $t76828;
                        $t76828 = List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($t76823, $t76827);
                        {
                          const $rc_3735 = ({ ...s, drum_clock: 0., voices: $t76828 });
                          return $rc_3735;
                        }
                      }
                    }
                  }
                }
              }
            } else {
              {
                const $rc_3734 = ({ ...s, drum_clock: clock });
                return $rc_3734;
              }
            }
          }
        }
      }
    } else {
      return s;
    }
  }
}
const Skee$Synth$drum_roll$clo = { _0: ($_, s) => Skee$Synth$drum_roll(s) };

function Skee$Synth$next_sample(s) {
  {
    const c = s.c;
    {
      let rumble;
      {
        let $t76838;
        {
          const $t76830 = s.rumble;
          {
            let $t76837;
            {
              let $t76836;
              {
                let $t76834;
                {
                  let $t76833;
                  {
                    const $t76831 = s.rumble_target;
                    {
                      const $t76832 = s.rumble;
                      $t76833 = ($t76831 - $t76832);
                    }
                  }
                  $t76834 = Skee$Synth$f32(c, $t76833);
                }
                {
                  const $t76835 = c.rumble_follow;
                  $t76836 = ($t76834 * $t76835);
                }
              }
              $t76837 = Skee$Synth$f32(c, $t76836);
            }
            $t76838 = ($t76830 + $t76837);
          }
        }
        rumble = Skee$Synth$f32(c, $t76838);
      }
      {
        let seed;
        {
          const $t76839 = s.seed;
          seed = Skee$Synth$next_seed($t76839);
        }
        {
          let lowpass;
          {
            let $t76848;
            {
              const $t76840 = s.lowpass;
              {
                let $t76847;
                {
                  let $t76846;
                  {
                    let $t76844;
                    {
                      let $t76843;
                      {
                        const $t76841 = Skee$Synth$noise_of(seed);
                        {
                          const $t76842 = s.lowpass;
                          $t76843 = ($t76841 - $t76842);
                        }
                      }
                      $t76844 = Skee$Synth$f32(c, $t76843);
                    }
                    {
                      const $t76845 = c.lowpass_follow;
                      $t76846 = ($t76844 * $t76845);
                    }
                  }
                  $t76847 = Skee$Synth$f32(c, $t76846);
                }
                $t76848 = ($t76840 + $t76847);
              }
            }
            lowpass = Skee$Synth$f32(c, $t76848);
          }
          {
            let level;
            {
              let $t76853;
              {
                let $t76852;
                {
                  let $t76850;
                  {
                    const $t76849 = (lowpass * rumble);
                    $t76850 = Skee$Synth$f32(c, $t76849);
                  }
                  {
                    const $t76851 = c.rumble_gain;
                    $t76852 = ($t76850 * $t76851);
                  }
                }
                $t76853 = Skee$Synth$f32(c, $t76852);
              }
              {
                const $t76829_i12749 = ($t76853 === 0.);
                if ($t76829_i12749 === true) {
                  level = 0.;
                } else {
                  level = $t76853;
                }
              }
            }
            {
              let drummed;
              {
                const $t76854 = ({ ...s, rumble: rumble, lowpass: lowpass, seed: seed });
                drummed = Skee$Synth$drum_roll($t76854);
              }
              {
                let m;
                {
                  const $t76855 = drummed.voices;
                  {
                    let $t76857;
                    {
                      const $t76856 = { $: "Nil" };
                      $t76857 = ({ level: level, mix_seed: seed, kept: $t76856 });
                    }
                    m = Skee$Synth$mix_voices(c, $t76855, $t76857);
                  }
                }
                {
                  let out;
                  {
                    const $t76858 = (-1.);
                    {
                      let $t76860;
                      {
                        const $t76859 = m.level;
                        {
                          const $t48415_i12747 = ($t76859 < 1.);
                          if ($t48415_i12747 === true) {
                            $t76860 = $t76859;
                          } else {
                            $t76860 = 1.;
                          }
                        }
                      }
                      {
                        const $t48414_i12744 = ($t76860 >= $t76858);
                        if ($t48414_i12744 === true) {
                          out = $t76860;
                        } else {
                          out = $t76858;
                        }
                      }
                    }
                  }
                  {
                    let $t76864;
                    {
                      const $t76861 = m.mix_seed;
                      {
                        const $t76862 = m.kept;
                        {
                          let $t76863;
                          {
                            const $t2509_i12741 = { $: "Nil" };
                            $t76863 = List$reverse_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($t76862, $t2509_i12741);
                          }
                          $t76864 = ({ ...drummed, seed: $t76861, voices: $t76863 });
                        }
                      }
                    }
                    {
                      const $rc_3737 = { _0: out, _1: $t76864 };
                      return $rc_3737;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
const Skee$Synth$next_sample$clo = { _0: ($_, s) => Skee$Synth$next_sample(s) };

function Skee$Synth$render_into($tco_a0, $tco_a1, $tco_a2) {
  __tco: for (;;) {
    const s = $tco_a0;
    const n = $tco_a1;
    const acc = $tco_a2;
    {
      const $t76865 = (n > 0);
      if ($t76865 === true) {
        {
          const $p76868 = Skee$Synth$next_sample(s);
          {
            const x = $p76868._0;
            {
              const next = $p76868._1;
              {
                const $t76866 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                {
                  const $t76867 = { $: "Cons", _0: x, _1: acc };
                  {
                    $tco_a0 = next;
                    $tco_a1 = $t76866;
                    $tco_a2 = $t76867;
                    continue __tco;
                  }
                }
              }
            }
          }
        }
      } else {
        {
          let $t76869;
          {
            const $t2509_i12751 = { $: "Nil" };
            $t76869 = List$reverse_onto$List_Float$List_Float(acc, $t2509_i12751);
          }
          return { _0: $t76869, _1: s };
        }
      }
    }
    return undefined;
  }
}
const Skee$Synth$render_into$clo = { _0: ($_, s, n, acc) => Skee$Synth$render_into(s, n, acc) };

function SynthEngine$reset() {
  {
    let $t77591;
    {
      const $t76415_i13100 = { $: "Nil" };
      {
        const $t76416_i13101 = Skee$Synth$consts();
        $t77591 = ({ voices: $t76415_i13100, lowpass: 0., rumble: 0., drum_clock: 0., seed: 22222, rumble_target: 0., drum: false, c: $t76416_i13101 });
      }
    }
    {
      const $rc_3829 = synth_cell_put$clo._0(synth_cell_put$clo, $t77591);
      return $rc_3829;
    }
  }
}
const SynthEngine$reset$clo = { _0: ($_) => SynthEngine$reset() };

function SynthEngine$serve(cmds) {
  {
    let $p77594;
    {
      const $t77592 = synth_cell_get();
      {
        let $t76876_i13105;
        {
          const $t76875_i27010 = { $: "$Clo_$lam0_Skee_SynthFeed_obey_all$0_Skee_SynthFeed_obey_all", _0: $lam0_Skee_SynthFeed_obey_all$apply$0_Skee_SynthFeed_obey_all };
          $t76876_i13105 = List$fold_left$List_AudioCmd$R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Fn_R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave_AudioCmd_R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(cmds, $t77592, $t76875_i27010);
        }
        {
          const $t76870_i27007 = { $: "Nil" };
          $p77594 = Skee$Synth$render_into($t76876_i13105, 128, $t76870_i27007);
        }
      }
    }
    {
      const out = $p77594._0;
      {
        const next = $p77594._1;
        synth_cell_put$clo._0(synth_cell_put$clo, next);
        return out;
      }
    }
  }
}
const SynthEngine$serve$clo = { _0: ($_, cmds) => SynthEngine$serve(cmds) };

function main(_f) {
  {
    const $t77596 = { $: "$Clo_$lam0_main$0_main", _0: $lam0_main$apply$0_main };
    {
      const $t77598 = { $: "$Clo_$lam1_main$1_main", _0: $lam1_main$apply$1_main };
      return worklet_register$clo._0(worklet_register$clo, $t77596, $t77598);
    }
  }
}
const main$clo = { _0: ($_, _f) => main(_f) };

function panic(msg) {
  return (() => { throw new Error(msg); })();
}
const panic$clo = { _0: ($_, msg) => panic(msg) };

function unreachable() {
  return (() => { throw new Error("panic"); })();
}
const unreachable$clo = { _0: ($_) => unreachable() };

function List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(xs, ys) {
  switch (xs.$) {
    case "Nil": {
      return ys;
      break;
    }
    case "Cons": {
      const $f2518 = xs._0;
      const $f2519 = xs._1;
      {
        const t = $f2519;
        {
          const h = $f2518;
          {
            const $trmc11 = { $: "Cons", _0: h, _1: null };
            List$append$dps$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(t, ys, $trmc11);
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
const List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$clo = { _0: ($_, xs, ys) => List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(xs, ys) };

function List$drop$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const xs = $tco_a0;
    const n = $tco_a1;
    {
      const $t2767 = (n <= 0);
      if ($t2767 === true) {
        return xs;
      } else {
        switch (xs.$) {
          case "Nil": {
            return { $: "Nil" };
            break;
          }
          case "Cons": {
            const $f2769 = xs._0;
            const $f2770 = xs._1;
            {
              const t = $f2770;
              {
                const $t2768 = ((n - 1) < 4611686018427387904 && (n - 1) >= -4611686018427387904 ? (n - 1) : march_int_ovf((n - 1), 1));
                {
                  $tco_a0 = t;
                  $tco_a1 = $t2768;
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
const List$drop$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Int$clo = { _0: ($_, xs, n) => List$drop$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Int(xs, n) };

function List$fold_left$List_AudioCmd$R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Fn_R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave_AudioCmd_R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($tco_a0, $tco_a1, $tco_a2) {
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
        const $f2612 = xs._0;
        const $f2613 = xs._1;
        {
          const t = $f2613;
          {
            const h = $f2612;
            {
              let $t2611;
              $t2611 = f._0(f, acc, h);
              {
                $tco_a0 = t;
                $tco_a1 = $t2611;
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
const List$fold_left$List_AudioCmd$R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Fn_R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave_AudioCmd_R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$clo = { _0: ($_, xs, acc, f) => List$fold_left$List_AudioCmd$R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Fn_R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave_AudioCmd_R_c_R_attack_time_Float_default_glide_Float_drum_step_Float_dt_Float_infinity_Float_lowpass_follow_Float_min_glide_Float_overflow_Float_pi_Float_rumble_follow_Float_rumble_gain_Float_split_Float_square_level_Float_subnormal_shift_Float_tiny_Float_drum_Bool_drum_clock_Float_lowpass_Float_rumble_Float_rumble_target_Float_seed_Int_voices_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(xs, acc, f) };

function List$reverse_onto$List_Float$List_Float($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f2511 = lst._0;
        const $f2512 = lst._1;
        {
          const t = $f2512;
          {
            const h = $f2511;
            {
              const $t2510 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t2510;
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
const List$reverse_onto$List_Float$List_Float$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_Float$List_Float(lst, acc) };

function List$length_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Int($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f2503 = lst._0;
        const $f2504 = lst._1;
        {
          const t = $f2504;
          {
            const $t2502 = ((acc + 1) < 4611686018427387904 && (acc + 1) >= -4611686018427387904 ? (acc + 1) : march_int_ovf((acc + 1), 0));
            {
              $tco_a0 = t;
              $tco_a1 = $t2502;
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
const List$length_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Int$clo = { _0: ($_, lst, acc) => List$length_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Int(lst, acc) };

function List$reverse_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($tco_a0, $tco_a1) {
  __tco: for (;;) {
    const lst = $tco_a0;
    const acc = $tco_a1;
    switch (lst.$) {
      case "Nil": {
        return acc;
        break;
      }
      case "Cons": {
        const $f2511 = lst._0;
        const $f2512 = lst._1;
        {
          const t = $f2512;
          {
            const h = $f2511;
            {
              const $t2510 = { $: "Cons", _0: h, _1: acc };
              {
                $tco_a0 = t;
                $tco_a1 = $t2510;
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
const List$reverse_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$clo = { _0: ($_, lst, acc) => List$reverse_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(lst, acc) };

function List$append$dps$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($tco_a0, $tco_a1, $tco_a2) {
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
        const $f2518 = xs._0;
        const $f2519 = xs._1;
        {
          const t = $f2519;
          {
            const h = $f2518;
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
const List$append$dps$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$clo = { _0: ($_, xs, ys, $dst) => List$append$dps$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(xs, ys, $dst) };

function $lam0_Skee_Synth_hot_spot_voices$apply$0_Skee_Synth_hot_spot_voices($clo, i) {
  {
    const c = $clo._1;
    {
      const $t76497 = { $: "WaveTri" };
      {
        let $t76502;
        {
          let $t76501;
          {
            let $t76500;
            {
              let $t76499;
              {
                const $t76498 = ((i * 7) < 4611686018427387904 && (i * 7) >= -4611686018427387904 ? (i * 7) : march_int_ovf((i * 7), 2));
                $t76499 = ($t76498 % 5);
              }
              $t76500 = (($t76499 * 300) < 4611686018427387904 && ($t76499 * 300) >= -4611686018427387904 ? ($t76499 * 300) : march_int_ovf(($t76499 * 300), 2));
            }
            $t76501 = ((2600 + $t76500) < 4611686018427387904 && (2600 + $t76500) >= -4611686018427387904 ? (2600 + $t76500) : march_int_ovf((2600 + $t76500), 0));
          }
          $t76502 = $t76501;
        }
        {
          let $t76503;
          $t76503 = Skee$Synth$after(c, 0.25, i, 0.04);
          {
            const $t76430_i16276 = c.default_glide;
            return Skee$Synth$voice(c, $t76497, $t76502, $t76502, $t76430_i16276, 0.06, 0.025, $t76503);
          }
        }
      }
    }
  }
}
const $lam0_Skee_Synth_hot_spot_voices$apply$0_Skee_Synth_hot_spot_voices$clo = { _0: ($_, $clo, i) => $lam0_Skee_Synth_hot_spot_voices$apply$0_Skee_Synth_hot_spot_voices($clo, i) };

function $lam0_Skee_Synth_jackpot_voices$apply$0_Skee_Synth_jackpot_voices($clo, i) {
  {
    const c = $clo._1;
    {
      const $t76518 = { $: "WaveTri" };
      {
        let $t76522;
        {
          let $t76521;
          {
            let $t76520;
            {
              const $t76519 = (i % 5);
              $t76520 = (($t76519 * 400) < 4611686018427387904 && ($t76519 * 400) >= -4611686018427387904 ? ($t76519 * 400) : march_int_ovf(($t76519 * 400), 2));
            }
            $t76521 = ((3000 + $t76520) < 4611686018427387904 && (3000 + $t76520) >= -4611686018427387904 ? (3000 + $t76520) : march_int_ovf((3000 + $t76520), 0));
          }
          $t76522 = $t76521;
        }
        {
          let $t76523;
          $t76523 = Skee$Synth$after(c, 0.4, i, 0.04);
          {
            const $t76430_i16283 = c.default_glide;
            return Skee$Synth$voice(c, $t76518, $t76522, $t76522, $t76430_i16283, 0.05, 0.03, $t76523);
          }
        }
      }
    }
  }
}
const $lam0_Skee_Synth_jackpot_voices$apply$0_Skee_Synth_jackpot_voices$clo = { _0: ($_, $clo, i) => $lam0_Skee_Synth_jackpot_voices$apply$0_Skee_Synth_jackpot_voices($clo, i) };

function $lam0_Skee_Synth_lever_voices$apply$0_Skee_Synth_lever_voices($clo, i) {
  {
    const c = $clo._1;
    {
      const $t76543 = { $: "WaveTri" };
      {
        let $t76546;
        {
          let $t76545;
          {
            const $t76544 = ((i * 60) < 4611686018427387904 && (i * 60) >= -4611686018427387904 ? (i * 60) : march_int_ovf((i * 60), 2));
            $t76545 = ((1200 - $t76544) < 4611686018427387904 && (1200 - $t76544) >= -4611686018427387904 ? (1200 - $t76544) : march_int_ovf((1200 - $t76544), 1));
          }
          $t76546 = $t76545;
        }
        {
          let $t76547;
          $t76547 = Skee$Synth$times(c, i, 0.025);
          {
            const $t76430_i16290 = c.default_glide;
            return Skee$Synth$voice(c, $t76543, $t76546, $t76546, $t76430_i16290, 0.1, 0.012, $t76547);
          }
        }
      }
    }
  }
}
const $lam0_Skee_Synth_lever_voices$apply$0_Skee_Synth_lever_voices$clo = { _0: ($_, $clo, i) => $lam0_Skee_Synth_lever_voices$apply$0_Skee_Synth_lever_voices($clo, i) };

function $lam0_Skee_Synth_pull_win_voices$apply$0_Skee_Synth_pull_win_voices($clo, i) {
  {
    const c = $clo._1;
    {
      const $t76559 = { $: "WaveTri" };
      {
        let $t76564;
        {
          let $t76563;
          {
            let $t76562;
            {
              let $t76561;
              {
                const $t76560 = ((i * 7) < 4611686018427387904 && (i * 7) >= -4611686018427387904 ? (i * 7) : march_int_ovf((i * 7), 2));
                $t76561 = ($t76560 % 5);
              }
              $t76562 = (($t76561 * 300) < 4611686018427387904 && ($t76561 * 300) >= -4611686018427387904 ? ($t76561 * 300) : march_int_ovf(($t76561 * 300), 2));
            }
            $t76563 = ((2400 + $t76562) < 4611686018427387904 && (2400 + $t76562) >= -4611686018427387904 ? (2400 + $t76562) : march_int_ovf((2400 + $t76562), 0));
          }
          $t76564 = $t76563;
        }
        {
          let $t76565;
          $t76565 = Skee$Synth$after(c, 0.2, i, 0.035);
          {
            const $t76430_i16297 = c.default_glide;
            return Skee$Synth$voice(c, $t76559, $t76564, $t76564, $t76430_i16297, 0.06, 0.02, $t76565);
          }
        }
      }
    }
  }
}
const $lam0_Skee_Synth_pull_win_voices$apply$0_Skee_Synth_pull_win_voices$clo = { _0: ($_, $clo, i) => $lam0_Skee_Synth_pull_win_voices$apply$0_Skee_Synth_pull_win_voices($clo, i) };

function $lam0_Skee_Synth_banner_voices$apply$0_Skee_Synth_banner_voices($clo, i) {
  {
    const c = $clo._1;
    {
      const $t76575 = { $: "WaveTri" };
      {
        let $t76576;
        $t76576 = Skee$Synth$after(c, 0.5, i, 0.045);
        {
          const $t76430_i16304 = c.default_glide;
          return Skee$Synth$voice(c, $t76575, 1800., 1800., $t76430_i16304, 0.08, 0.012, $t76576);
        }
      }
    }
  }
}
const $lam0_Skee_Synth_banner_voices$apply$0_Skee_Synth_banner_voices$clo = { _0: ($_, $clo, i) => $lam0_Skee_Synth_banner_voices$apply$0_Skee_Synth_banner_voices($clo, i) };

function $lam1_Skee_Synth_banner_voices$apply$1_Skee_Synth_banner_voices($clo, i) {
  {
    const c = $clo._1;
    {
      const $t76599 = { $: "WaveTri" };
      {
        let $t76603;
        {
          let $t76602;
          {
            let $t76601;
            {
              const $t76600 = (i % 6);
              $t76601 = (($t76600 * 350) < 4611686018427387904 && ($t76600 * 350) >= -4611686018427387904 ? ($t76600 * 350) : march_int_ovf(($t76600 * 350), 2));
            }
            $t76602 = ((2600 + $t76601) < 4611686018427387904 && (2600 + $t76601) >= -4611686018427387904 ? (2600 + $t76601) : march_int_ovf((2600 + $t76601), 0));
          }
          $t76603 = $t76602;
        }
        {
          let $t76604;
          $t76604 = Skee$Synth$after(c, 0.5, i, 0.04);
          {
            const $t76430_i16311 = c.default_glide;
            return Skee$Synth$voice(c, $t76599, $t76603, $t76603, $t76430_i16311, 0.05, 0.03, $t76604);
          }
        }
      }
    }
  }
}
const $lam1_Skee_Synth_banner_voices$apply$1_Skee_Synth_banner_voices$clo = { _0: ($_, $clo, i) => $lam1_Skee_Synth_banner_voices$apply$1_Skee_Synth_banner_voices($clo, i) };

function $lam0_Skee_SynthFeed_obey_all$apply$0_Skee_SynthFeed_obey_all($clo, acc, cmd) {
  {
    const s_i25345 = acc;
    {
      const cmd_i25346 = cmd;
      switch (cmd_i25346.$) {
        case "CmdPlay": {
          const $f76871_i25347 = cmd_i25346._0;
          {
            const snd_i25348 = $f76871_i25347;
            {
              const $t76729_i27934 = acc.c;
              {
                const $t76730_i27935 = Skee$Synth$voices_for($t76729_i27934, snd_i25348);
                {
                  const s_i23234_i27936 = acc;
                  {
                    const $t76724_i23236_i27937 = acc.voices;
                    {
                      let all_voices_i23237_i27938;
                      all_voices_i23237_i27938 = List$append$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($t76724_i23236_i27937, $t76730_i27935);
                      {
                        let over_i23241_i27940;
                        {
                          let $t76725_i23239_i27939;
                          {  };
                          $t76725_i23239_i27939 = List$length_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Int(all_voices_i23237_i27938, 0);
                          over_i23241_i27940 = (($t76725_i23239_i27939 - 48) < 4611686018427387904 && ($t76725_i23239_i27939 - 48) >= -4611686018427387904 ? ($t76725_i23239_i27939 - 48) : march_int_ovf(($t76725_i23239_i27939 - 48), 1));
                        }
                        {
                          const $t76727_i23242_i27941 = (over_i23241_i27940 > 0);
                          {
                            let $t76728_i23243_i27942;
                            if ($t76727_i23242_i27941 === true) {
                              $t76728_i23243_i27942 = List$drop$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$Int(all_voices_i23237_i27938, over_i23241_i27940);
                            } else {
                              $t76728_i23243_i27942 = all_voices_i23237_i27938;
                            }
                            {
                              const $rc_3730_i23244_i27943 = ({ ...acc, voices: $t76728_i23243_i27942 });
                              return $rc_3730_i23244_i27943;
                            }
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
        case "CmdRumble": {
          const $f76872_i25349 = cmd_i25346._0;
          {
            const level_i25350 = $f76872_i25349;
            {
              const s_i27944 = acc;
              {
                let $t76418_i27947;
                {
                  const $t76417_i27946 = acc.c;
                  $t76418_i27947 = Skee$Synth$f32($t76417_i27946, level_i25350);
                }
                {
                  const $rc_3723_i27948 = ({ ...acc, rumble_target: $t76418_i27947 });
                  return $rc_3723_i27948;
                }
              }
            }
          }
          break;
        }
        case "CmdDrum": {
          const $f76873_i25351 = cmd_i25346._0;
          {
            const on__i25352 = $f76873_i25351;
            {
              const s_i27949 = acc;
              {
                const $rc_3724_i27951 = ({ ...acc, drum: on__i25352 });
                return $rc_3724_i27951;
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
const $lam0_Skee_SynthFeed_obey_all$apply$0_Skee_SynthFeed_obey_all$clo = { _0: ($_, $clo, acc, cmd) => $lam0_Skee_SynthFeed_obey_all$apply$0_Skee_SynthFeed_obey_all($clo, acc, cmd) };

function $lam0_main$apply$0_main($clo) {
  return SynthEngine$reset();
}
const $lam0_main$apply$0_main$clo = { _0: ($_, $clo) => $lam0_main$apply$0_main($clo) };

function $lam1_main$apply$1_main($clo, cmds) {
  return SynthEngine$serve(cmds);
}
const $lam1_main$apply$1_main$clo = { _0: ($_, $clo, cmds) => $lam1_main$apply$1_main($clo, cmds) };

function prepend_reversed$apply$0_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($tco_a0, $tco_a1, $tco_a2) {
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
          const $f2631 = sub._0;
          const $f2632 = sub._1;
          {
            const rest = $f2632;
            {
              const x = $f2631;
              {
                const $t2630 = { $: "Cons", _0: x, _1: acc };
                {
                  $tco_a0 = $clo;
                  $tco_a1 = rest;
                  $tco_a2 = $t2630;
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
const prepend_reversed$apply$0_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$clo = { _0: ($_, $clo, sub, acc) => prepend_reversed$apply$0_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($clo, sub, acc) };

function go$apply$1_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($tco_a0, $tco_a1, $tco_a2) {
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
              const $t2509_i16564 = { $: "Nil" };
              return List$reverse_onto$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave(acc, $t2509_i16564);
            }
            break;
          }
          case "Cons": {
            const $f2638 = lst._0;
            const $f2639 = lst._1;
            {
              const rest = $f2639;
              {
                const xs = $f2638;
                {
                  let $t2637;
                  $t2637 = prepend_reversed._0(prepend_reversed, xs, acc);
                  {
                    $tco_a0 = go;
                    $tco_a1 = rest;
                    $tco_a2 = $t2637;
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
const go$apply$1_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave$clo = { _0: ($_, $clo, lst, acc) => go$apply$1_List_concat_List_List_R_amp_Float_decay_Float_delay_Float_freq_Float_freq_end_Float_glide_floor_Float_life_Float_phase_Float_t_Float_wave_SynthWave($clo, lst, acc) };

export { main };
main();
//# sourceMappingURL=skee_synth_worklet.mjs.map
