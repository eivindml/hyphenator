#!/usr/bin/ruby

require_relative '../utils/string'
require_relative 'dictionary'

class CompoundSplitter

    def initialize(dict)
        @dictionary = dict
    end

    # Returns an array containing all possible decompositions of a given word.
    def split(word)
        result = Array.new
        
        if word.length < 7 && @dictionary.is_word?(word)
            result.push(word)
            return result
        end
        
        result = possible_splits(word)
        
        if result.empty?
            result.push word
        end
        
        return result
    end

    def possible_splits(word, intermediate = "", possibilities = Array.new)
        if word.nil?
            return
        end

        # Check all substrings of the word
        for char_pos in 1..word.length
            prefix = word[0..char_pos]

            # Is the prefix a legal word?
            if @dictionary.is_word?(prefix)
                # If we are at the end of the string, we have a possible solution
                if char_pos == word.length
                    possibilities.push intermediate.empty? ? prefix : "#{intermediate}+#{prefix}"
                    next
                end

                # Recursivly check suffix
                suffix = word[char_pos+1..-1]
                possible_splits(suffix,
                                intermediate.empty? ? prefix : "#{intermediate}+#{prefix}",
                                possibilities)

                # Check for possible tripple consonant
                # if prefix[-1] == prefix[-2]
 #                    suffix = word[char_pos..-1]
 #                    possible_splits(suffix,
 #                                    intermediate.empty? ? prefix : "#{intermediate}+#{prefix}",
 #                                    possibilities)
 #                end

                # Check if word can be analyzed with ephenthetic s or e, recursivly
                if ['s', 'e'].include? suffix[0]
                    prefix = "#{prefix}+#{suffix[0]}"
                    suffix = word[char_pos+2..-1]

                    possible_splits(suffix,
                                    intermediate.empty? ? prefix : "#{intermediate}+#{prefix}",
                                    possibilities)
                end

            end
        end

        # Return all possible word interpretations
        return possibilities
    end
end
