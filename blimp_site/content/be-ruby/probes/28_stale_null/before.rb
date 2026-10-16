# frozen_string_literal: true
require("temper_core")
module Temper
  module StaleNull
    @i = 0
    while @i < 3
      if @i == 0
        x = 5
      else
      end
      if x.nil?()
        t = -1
      else
        t = TemperCore.not_null(x)
      end
      TemperCore.console_log("x is " + TemperCore.int_to_string(t))
      @i = TemperCore.int32(@i + 1)
    end
  end
end
