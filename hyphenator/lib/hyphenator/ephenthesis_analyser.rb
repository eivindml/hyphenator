#!/usr/bin/ruby

require_relative 'dictionary'
require_relative('../utils/string')

class EphenthesisAnalyser
    def initialize(dict)
        @dictionary = dict
    end

    def analyze (sentence)
        result = sentence

        # Analyze of ephenethesis or not
        case rule = get_ephenthesis_rule(sentence)
        when 'p' # Ephenthesis: Letter belongs to prefix
            result = ephenthesis_in_prefix(sentence)
        else # Not ephenethesis: Letter belongs to suffix
            result = ephenthesis_in_suffix(sentence)
        end

        return result
    end

    def get_ephenthesis_rule(sentence)
        result          = 'x'
        before_eph      = get_part_before_ephenthesis(sentence)
        after_eph       = get_part_after_ephenthesis(sentence)
        first_part_pos  = @dictionary.get_pos(before_eph)
        last_part_pos   = @dictionary.get_pos(after_eph)


        case ephenthesis = ephenthesis(sentence)
        when "s"
            last_part_pos_with_eph = @dictionary.get_pos("s#{after_eph}")

            # If it's not a correct word with letter in suffix,
            # then it has to be in the prefix
            if not @dictionary.is_word?("s#{after_eph}")
                result = 'p'
                return result
            end


            # Rule 22)
            if not first_part_pos.eql?("subst")
                result = 's'
                return result
            end

            # Rule 20)
            if last_part_pos_with_eph.eql? "verb"
                result = 'p'
            end

            # Rule 25)
            if @dictionary.is_compound_word?(before_eph)
                result = 'p'
            end

            # Rule 40)
            if consonants_with_sibliants(before_eph)
                result = 's' unless @dictionary.is_compound_word?(before_eph)
            end

        when "e"
            
            if @dictionary.is_word?(before_eph)
                if @dictionary.is_word?("e#{after_eph}")
                    result = 's'
                    return result
                end
            end
            
            if not @dictionary.is_word?("e#{after_eph}")
                result = 'p'
            end

            # Rule 35)
            if @dictionary.one_syllable?(before_eph)
                result = 'p'
            end

        end

        return result

    end

    def consonants_with_sibliants(sentence)
        consonants = Array.new

        sentence.reverse.each_char do |char|
            unless VOWELS.include? char
                consonants.push char
            else
                break
            end
        end

        consonants.each do |k|
            if ["c", "s"].include? k
                return true
            end
        end

        return false
    end

    def ephenthesis_in_prefix(c)
        result = Array.new

        c.each_with_index do |x, i|
            if ["e", "s"].include? x
                result[i-1] = "#{result[i-1]}#{x}"
            else
                result.push x
            end
        end
        return result
    end

    def ephenthesis_in_suffix(c)
        result = Array.new
        eph_num = 0
        eph = ""
        num = 0

        c.each_with_index do |x, i|
            if ["e", "s"].include? x
                eph = x
                eph_num = num
            else
                num = num + 1
                result.push x
            end
        end

        result[eph_num] = "#{eph}#{result[eph_num]}"

        return result
    end

    def get_part_before_ephenthesis(c)
        c.each_with_index do |x,i|
            if ["e", "s"].include? x
                return c[0..i-1].join("")
            end
        end
        return c
    end

    def get_part_after_ephenthesis(c)
        c.each_with_index do |x,i|
            if ["e", "s"].include? x
                return c[i+1..-1].join("")
            end
        end
        return false
    end

    def ephenthesis(interpretation)
        if interpretation.include? "s"
            return "s"
        else
            return "e"
        end
    end


    def ephenthesis_s? (interpretation)
        return interpretation.include? "s"
    end

    def ephenthesis_e? (interpretation)
        return interpretation.include? "e"
    end

    def ephenthesis? (interpretation)
        return ephenthesis_s?(interpretation) || ephenthesis_e?(interpretation)
    end

    def contains_ephenthesis(interpretations)
        result = Array.new

        if interpretations.nil?
            return false
        end
        
        if not interpretations.kind_of?(Array)
            return false
        end

        interpretations.each do |part|
            if ["e", "s"].include? part
                return true
            end
        end
        return false
    end
end
