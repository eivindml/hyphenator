#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'

load 'utils.rb'

word_list = read_file("ordliste.txt").force_encoding('UTF-8').split(/\n/)

left_table = Hash.new(0)
right_table = Hash.new(0)

def analyze_word(word, table, direction) 
	word.each_char_with_index do |c, i|
		if i > 3 
			next
		end
		w = word[0..i]
		if direction
			w = w.reverse!
		end	
		table[w] = table[w] + 1
	end
end

word_list.each do |word|
	if !word.include? '-'
		next
	end
	left, right = word.split(/-/)
	analyze_word(left.reverse, left_table, true)
	analyze_word(right, right_table, false)
end

puts "Writing LEFT TABLE\n"
File.open('left.txt', 'w') do |file|
	left_table.sort_by {|k, v| v}.reverse.each do |w, k|
		file.write "#{k}	#{w}\n"
	end
end

puts "Writing RIGHT TABLE\n"
File.open('right.txt', 'w') do |file|
	right_table.sort_by {|k, v| v}.reverse.each do |w, k|
		file.write "#{k}	#{w}\n"
	end
end
