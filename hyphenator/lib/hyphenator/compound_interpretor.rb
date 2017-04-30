#!/usr/bin/ruby

require_relative 'ephenthesis_analyser'
require_relative 'compound_splitter'

class CompoundInterpreter

    def initialize(dict)
        @dictionary = dict
        @eph = EphenthesisAnalyser.new(dict)
    end

    def pick(interpretations)
        # Interpretations with fewest word components
        result = interpretations_with_lowest_word_frequency(interpretations)

        # If multiple interpretations of equal length, get the one with longest last part
        if result.length > 1
            result = interpretation_with_longest_last_part(result)
        else
            result = result.first()
        end

        # If result contains ephenthesis, choose the right interpretation
        if @eph.contains_ephenthesis(result)
            result = @eph.analyze(result)
        end

        return result
    end

    def interpretations_with_lowest_word_frequency(interpretations)
        result = Array.new

        # Split word components into an array, add to result array,
        # unless it's a single word component (only interested in splitted compounds)
        interpretations.each do |interp|
            segmented = interp.split("+")
            result.push(segmented) unless segmented.length == 1
        end
        
        # If no interpretations, return original word 
        # (which is not in dictionary, or is not a compound)
        if result.empty?
            result.push(interpretations.first)
        end

        # Sort results by components length (fewest → most)
        result = result.sort_by do |sentence|
            if sentence.include? "s"
                 sentence.length-1
            elsif sentence.include? "e"
                sentence.length-1
            else
                sentence.length
            end
        end

        # Only keep results with fewest (and same) component frequency
        first_length = @eph.ephenthesis?(result.first) ? result.first.length-1 : result.first.length
        result.each_with_index do |r, i|
            this_length = @eph.ephenthesis?(r) ? r.length-1 : r.length
            if first_length < this_length
                result = result[0..i-1]
            end
        end

        return result
    end

   def interpretation_with_longest_last_part(interpretations)
        result = interpretations.first

        if interpretations.length == 1
            return result 
        end
        
        sorted = interpretations.sort_by do |interp|
            interp.last.length
        end
        
        sorted = sorted.reverse

        sorted.each do |interp|
            # Rule 30) If two analyses have the same number of members and there
            # is no ephenthesis involvd, chose the one, if any, that is a noun.
            if @dictionary.get_pos(interp.last).eql? "subst"
                result = interp
                break
            # Return ephenthesis, if the case
            elsif @eph.contains_ephenthesis(interp)
                result = interp
                break
            # Else get the result with the longest last word component
            elsif result.last.length < interp.last.length
                result = interp
            end
        end

        return result
    end
    
end
