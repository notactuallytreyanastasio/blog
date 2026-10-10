# The method names a Temper module function must not take: every method a
# module already answers to (public, private and protected, from Module,
# Object and Kernel), which a `def self.name` would override for that
# module. Run: ruby 10_taken_names.rb   (prints them, one per line, sorted)
m = Module.new
names = m.methods + m.private_methods + m.protected_methods
plain = names.map(&:to_s).grep(/\A[a-z_][a-z0-9_]*[?!=]?\z/).uniq.sort
puts plain
warn "#{plain.size} names (ruby #{RUBY_VERSION})"
