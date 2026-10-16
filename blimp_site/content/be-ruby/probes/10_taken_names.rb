# The method names translated code must not take, as Ruby itself reports
# them. Run: ruby 10_taken_names.rb module|object|class
#
#   module  every method a module answers to: a module function is
#           `def self.name` on the library's module and would override it
#   object  every method an object answers to: a Temper class's instance
#           method would override it (`hash`, `freeze`, `class`...)
#   class   every method a class answers to: a static method would
#           override it (`new`, `allocate`...)
#
# Public, private and protected, plain names only, one per line, sorted.
subject = case ARGV.fetch(0, "module")
          when "module" then Module.new
          when "object" then Object.new
          when "class" then Class.new
          end
names = subject.methods + subject.private_methods + subject.protected_methods
plain = names.map(&:to_s).grep(/\A[a-z_][a-z0-9_]*[?!=]?\z/).uniq.sort
puts plain
warn "#{ARGV.fetch(0, "module")}: #{plain.size} names (ruby #{RUBY_VERSION})"
