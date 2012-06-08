#!/usr/bin/env ruby

count = ARGV[0] ? ARGV[0].to_i : 1000000
size = ARGV[1] ? ARGV[1].to_i : 1024
randomize = (ARGV[2] == "randomize")

value = "".ljust(size, "a")
LF = "\n"
SP = " "

count.times do |i|
  if randomize
    print i * 4908534053 % count
  else
    print i
  end
  print SP
  print value
  print LF
end
