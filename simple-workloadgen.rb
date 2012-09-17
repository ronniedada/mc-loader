#!/usr/bin/env ruby

count = ARGV[0] ? ARGV[0].to_i : 1000000
size = ARGV[1] ? ARGV[1].to_i : 1024
randomize = (ARGV[2] == "randomize")

srand(0x34343434)

(size*3).times {rand(256)}

value = [size.times.map {rand(256).chr}.join('')].pack('m').gsub("\n",'')
LF = "\n"
SP = " "

srand(0x5555)

if randomize
  while true
    coprime = 3 + rand(count-4)
    break if coprime.gcd(count) == 1
  end
  # STDERR.puts "coprime: #{coprime}"
end

count.times do |i|
  if randomize
    print i * coprime % count
  else
    print i
  end
  print SP
  print value
  print LF
end
