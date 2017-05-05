#!/usr/bin/ruby

class String
  def each_char
    self.split("").each { |i| yield i }
  end
  
  def each_char_with_index
    self.split("").each_with_index { |c, i| yield c, i }
  end
end