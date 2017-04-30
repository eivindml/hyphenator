#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'

load 'utils.rb'

def find_right_weight(word, right)
	result = Array.new(word.length, 0)
	total_length = right.length
	right.each do |line|
		pattern = line.split('	')
		pattern[1].delete!("\n")
		if word.include? pattern[1]
			index = word.index(pattern[1])
			length = pattern[1].length
			pattern_weight = pattern[0].to_i
			if pattern_weight != 0 && index != 0
				result[index] = result[index] + length*(total_length/pattern_weight)
			end
		end
	end
	return result
end


def find_left_weight(word, left)
	result = Array.new(word.length, 0)
	total_length = left.length
	left.each do |line|
		pattern = line.split('	')
		pattern[1].delete!("\n")
		if word.include? pattern[1]
			index = word.index(pattern[1])
			length = pattern[1].length
			pattern_weight = pattern[0].to_i
			if pattern_weight != 0
				result[index] = result[index] + length*(total_length/pattern_weight)
			end
		end
	end
	return result
end

def find_total_weight(left, right, word)
	result = Array.new(word.length, 0)
	right_index = 1
	word.each_char_with_index do |c, i|
		if right_index >= word.length
			break
		end
		result[i] = left[i] + right[right_index]
		right_index = right_index + 1
	end
	return result
end

left = read_file_to_array('left.txt')
right = read_file_to_array('right.txt')

input_word = ARGV[0]

left_weight = find_left_weight(input_word, left)
right_weight = find_right_weight(input_word, right)

p left_weight
p right_weight

weight = find_total_weight(left_weight, right_weight, input_word)
p weight

pos = weight.index(weight.max)

word = input_word.dup

if weight.max > 30000
	puts word.insert(pos, '-')
else puts word
end
