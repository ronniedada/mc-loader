#!/usr/bin/ruby

require 'rubygems'
require 'trollop'

$opts = Trollop::options do
  opt :keys, "keyset size", :type => :int, :required => true
  opt :value_size, "size of values", :type => :int, :default => 1024
  opt :value, "value", :type => :string
end

def generate_value
  @value ||= begin
               "a" * $opts[:value_size]
             end
end

# value = generate_value()

# (0...$opts[:keys]).each do |i|
#   print("%08d %s\n" % [i, value])
# end

i = $opts[:keys]-1

value = $opts[:value] || generate_value

STDERR.puts "value is: #{value.inspect}"

suffix = " #{value}\n"
while i >= 0
  STDOUT << sprintf("%08d", i) << suffix
  i -= 1
end
