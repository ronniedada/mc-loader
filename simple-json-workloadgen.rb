#!/usr/bin/env ruby

1000000.times do |i|
  puts(sprintf("{\"doc\":{\"_id\":\"%d\"}}", i))
end
