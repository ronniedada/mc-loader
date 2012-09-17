#!/usr/bin/env ruby

times = ARGV[0] && ARGV[0].to_i || 1000000

times.times do |i|
  puts(sprintf("{\"doc\":{\"_id\":\"%08x\"}}", i))
end
