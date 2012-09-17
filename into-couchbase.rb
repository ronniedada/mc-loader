#!/usr/bin/env ruby

require 'rubygems'
require 'yajl'
require 'couchbase'
require 'pp'

class JSONDocStreamReader
  attr_reader :path

  def initialize(path, io = nil)
    @path = path
    @io = io || File.open(path, "rb")
    @last_pos = 0
  end

  def self.open(path)
    inst = self.new(path)
    begin
      yield inst
    ensure
      inst.close rescue nil
    end
  end

  def close
    @io.close
  end

  def next
    begin
      line = @io.gets
      return unless line
      line.chomp!
      line.chomp!(",")
      return self.next() if line == "]}"
    end while line.getbyte(-1) == 91 # "["
    Yajl::Parser.new.parse(line)
  end

  def next_doc_id
    doc = self.next
    return unless doc
    unless ((real_doc = doc["doc"]))
      puts "Warning: no real doc\n#{doc.pretty_inspect}"
      return
    end
    id = real_doc["_id"]
    real_doc.delete("_id")
    # print "."; STDOUT.flush
    [id, real_doc]
  end
end

class MCLoaderStreamReader
  def initialize _ignore, io
    @io = io
  end
  def next_doc_id
    line = @io.gets
    return unless line
    line.split(" ", 2)
  end
end

host = ARGV[0]
raise "need host (http)" unless host

$db = Couchbase.new(host)

def ($db).set_and_retry(*args)
  begin
    self.set(*args)
  rescue Couchbase::Error::TemporaryFail
    print "f"; STDOUT.flush
    sleep 0.5
    retry
  end
end

# $db = Object.new
# class <<$db
#   def set(*args)
#   end
#   def run
#     yield
#   end
# end


if ARGV[1] == 'mcloader'
  stream_klass = MCLoaderStreamReader
elsif ARGV[1] == "alldocs"
  stream_klass = JSONDocStreamReader
end

unless stream_klass
  ch = STDIN.getbyte
  if ch == ?{.getbyte(-1)
    stream_klass = JSONDocStreamReader
  else
    stream_klass = MCLoaderStreamReader
  end
  STDIN.ungetbyte ch
end

stream = stream_klass.new('-', STDIN)

# def extract_doc(doc)
#   unless ((real_doc = doc["doc"]))
#     puts "Warning: no real doc\n#{doc.pretty_inspect}"
#     return
#   end
#   id = real_doc["_id"]
#   real_doc.delete("_id")
#   yield id, real_doc
# end

def save_doc(id, real_doc, no_retry = false)
  if no_retry
    $db.set(id, real_doc)
  else
    $db.set_and_retry(id, real_doc)
    print "."; STDOUT.flush
  end
end

# class CouchbaseLoader
#   def initialize(db)
#     @db = db
#     @work_fiber = Fiber.new(self.method(:inside_fiber))
#   end
#   def inside_fiber
#   end
#   def []=(k, v)
#   end
# end

catch :break_higher do
  while true
    id, real_doc = stream.next_doc_id
    break unless real_doc
    begin
      $db.run do
        500.times do
          save_doc id, real_doc, true
          id, real_doc = stream.next_doc_id
          throw :break_higher unless real_doc
        end
      end
    rescue Couchbase::Error::TemporaryFail
      print "F"; STDOUT.flush
      save_doc id, real_doc, false
    end
  end
end
