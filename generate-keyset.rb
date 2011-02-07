#!/usr/bin/ruby


raise "Need size argument" unless ARGV[0]
size = ARGV[0].to_i

(0...size).each do |i|
  print("%08d a\n" % [i])
end
