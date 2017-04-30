#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'

load 'utils.rb'

def calculate_hyphenation(w, patterns)
	word = w.dup.insert(0, '.').concat('.')
	hyph_points = Array.new(word.length, 0)
	ind = 0
	included_patterns = Array.new
	patterns.each do |pattern|
		if word.include? pattern.delete('0-9')
			ind = word.index(pattern.delete('0-9'))
			included_patterns.push(pattern)
			num_i = 0
            puts pattern
			pattern.each_char_with_index do |char, index|
				if char.is_i?
					num_i = num_i + 1
					if char.to_i > hyph_points[ind+index-num_i].to_i
						hyph_points[ind+index-num_i] = char.to_i
					end
				end
			end
		end
	end
	hyph_i = 0
	hyph_points.each_with_index do |x, i|
		if hyph_points[i] > 0 && hyph_points[i].odd? && i > 1
			hyph_i = hyph_i + 1
			word.insert(i+hyph_i, '-')
		end
	end
	return word.delete('.')	
end

hyphenation_data = read_file("lists/ushyph.tex")
regex = /\{.*?\n(.*)\}.*?\{.*?\n(.*)\}/m

patterns = (hyphenation_data.match regex)[1].split(/\n/)
exceptions = (hyphenation_data.match regex)[2].split(/\n/)

input_word = ARGV[0]
result = ""

exceptions.each do |x|
	if x.delete('-').eql? input_word
		result = x
	end
end

if result.empty?
	result = calculate_hyphenation(input_word, patterns)
end

puts "Input word: #{input_word}\nHyphenation: #{result}"
