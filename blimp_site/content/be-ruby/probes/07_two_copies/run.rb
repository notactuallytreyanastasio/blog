# Two copies of a runtime, loaded from two paths, as two libraries that
# each carried their own would. Run: ruby -w run.rb
$stderr.sync = true
dir = __dir__
require File.join(dir, "a/temper_core")
first_bubble = TemperCore::Bubble
require File.join(dir, "b/temper_core")
puts "same Bubble class after the second load: #{TemperCore::Bubble.equal?(first_bubble)}"
puts "TemperCore.version is now: #{TemperCore.version}"
