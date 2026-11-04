# frozen_string_literal: true

# Ruby's Date against Temper's: a {year, month, day} in the proleptic
# Gregorian calendar, months 1 to 12, ISO weekdays 1 (Monday) to 7.
require "date"

def show(label, &blk)
  value = begin
    blk.call.inspect
  rescue StandardError => e
    "#{e.class}: #{e.message}"
  end
  puts format("%-52s %s", label, value)
end

show("Date.new(12, 11, 10).cwday") { Date.new(12, 11, 10).cwday }
show("Date.new(12, 11, 10, Date::GREGORIAN).cwday") { Date.new(12, 11, 10, Date::GREGORIAN).cwday }
show("Date.new(1500, 2, 29) (Julian leap day)") { Date.new(1500, 2, 29).to_s }
show("Date.new(1500, 2, 29, Date::GREGORIAN)") { Date.new(1500, 2, 29, Date::GREGORIAN).to_s }
show("Date.new(1582, 10, 10) (in the gap)") { Date.new(1582, 10, 10).to_s }
show("Date.new(1582, 10, 10, Date::GREGORIAN)") { Date.new(1582, 10, 10, Date::GREGORIAN).to_s }
show("Date.new(2023, 6, -1)") { Date.new(2023, 6, -1).to_s }
show("Date.new(2023, -1, 1)") { Date.new(2023, -1, 1).to_s }
show("Date.new(2023, 2, 30)") { Date.new(2023, 2, 30).to_s }
show("Date.new(12, 11, 10).to_s") { Date.new(12, 11, 10, Date::GREGORIAN).to_s }
show("Date.new(12345, 1, 2).to_s") { Date.new(12_345, 1, 2, Date::GREGORIAN).to_s }
show("Date.new(-5, 1, 2).to_s") { Date.new(-5, 1, 2, Date::GREGORIAN).to_s }
show("Date.iso8601(\"15960331\")") { Date.iso8601("15960331").to_s }
show("Date.iso8601(\"1596-091\") (ordinal)") { Date.iso8601("1596-091").to_s }
show("Date.iso8601(\"96-03-31\")") { Date.iso8601("96-03-31").to_s }
show("Date.iso8601(\" 1596-03-31\")") { Date.iso8601(" 1596-03-31").to_s }
show("Date.today.start == Date::ITALY") { Date.today.start == Date::ITALY }
show("Date.new(2000,1,1,Date::GREGORIAN) == Date.new(2000,1,1)") { Date.new(2000, 1, 1, Date::GREGORIAN) == Date.new(2000, 1, 1) }
show("Date.new(2000, 1, 1).frozen?") { Date.new(2000, 1, 1).frozen? }
