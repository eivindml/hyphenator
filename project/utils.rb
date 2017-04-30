#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'

# Extend the String class with functions for iterating over characters
class String
  def each_char
    self.split("").each { |i| yield i }
  end
  def each_char_with_index
    self.split("").each_with_index { |c, i| yield c, i }
  end
	def is_i?
       		/\A[-+]?\d+\z/ === self
	end
end

class Numeric
  def percent_of(n)
	n = n.to_f * 0.01 * self.to_f
	n.round
  end
end

# Function for reading files. Skips comment lines (Starts with %)
def read_file(file_name)
  file = File.open(file_name, "r")
  data = ""
  file.each_line do |line|
	data << line.force_encoding('UTF-8') unless line[0] == '%'
  end
  file.close
  return data
end

def read_file_to_array(file_name)
  file = File.open(file_name, "r")
  data = Array.new
  file.each_line do |line|
	if line[0] != '%'
		data.push(line.force_encoding('UTF-8'))
	end
  end
  file.close
  return data
end
