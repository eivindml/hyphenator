#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'

load 'utils.rb'

array = read_file_to_array('ordliste.txt')

random = array.shuffle!
percent = 20.percent_of(random.size)

first = random.slice(0, percent)
second = random.slice(percent, random.size)

File.open('ordliste_20.txt', 'w') do |file|
    first.each do |element|
        file.puts(element)
    end
end

File.open('ordliste_80.txt', 'w') do |file|
    second.each do |element|
        file.puts(element)
    end
end

puts "List randomized and slit into two lists (20% and 80% size)"
puts first.size
puts second.size
puts first.size+second.size
puts random.size
