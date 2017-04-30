#!/usr/bin/ruby

require_relative 'dictionary'
require_relative 'compound_splitter'
require_relative 'compound_interpretor'
require_relative '../utils/string'

# Consonant sequences which should not be hyphenated
ONE_CONSONANT_EXCEPTIONS = ["dh", "gh", "gj", "kj", "sc", "sch", "sh", "sj", "skj"]#, "sk"]

class HyphenationRules

    def initialize(dict)
        @dictionary = dict
    end
    
    def hyph(word_segments)
        # Hyphenate each segment
        # result = word_segments.map {|word| hyphenate(word)}
        log = ""
        result = Array.new
        word_segments.each do |word|
            word, l = hyphenate(word)
            result.push(word)
            log = log + l
        end
        log = log + "\n     #{word_segments}"
        # Return result with hyphens between segments
        return result.join("-"), log
    end

    def hyphenate(word)
        hyphenations = Array.new(word.length, "")
        interm_word = word
        length = word.length
        log = ""
        
        if exception?(interm_word)
            log = " Exception: #{interm_word}"
            result = interm_word
            return result, log
        end
        
        if derivation_prefix = @dictionary.get_derivation_prefix(interm_word)
            log = log + "   Derivation_prefix: #{derivation_prefix}"
            interm_word, hyphenations = derivation_prefix_rule(interm_word, derivation_prefix, hyphenations)
            length = interm_word.length
        end
        
        if derivation_suffix = @dictionary.get_derivation_suffix(interm_word)
            log = log + "\n   Derivation_suffix: #{derivation_suffix}"
            interm_word, hyphenations = derivation_suffix_rule(interm_word, derivation_suffix, hyphenations)
        end
        
        if inflection = @dictionary.get_inflection(word)
            log = log + "\n   Inflection: #{inflection}"
            hyphenations, log = inflection_rule(word, inflection, hyphenations, log)
        end
        
        hyphenations, log = rule_of_one_consonant(interm_word, hyphenations, length, log)
        
        result = hyphenate_word(word, hyphenations)
        
        log = log + "\n     #{hyphenations}"
        
        return result, log
    end
    
    def derivation_prefix_rule(word, prefix, hyphenations)
        
        if word.length > prefix.length && include_vowel?(word[prefix.length..-1])
            puts "DERRRR PREFFF: #{word[prefix.length..-1]}"
            hyphenations[prefix.length] = "-"
            word = word[prefix.length..-1]
        end
       
       return word, hyphenations            
    end
    
    def derivation_suffix_rule(word, suffix, hyphenations)
        if word.length > suffix.length && include_vowel?(word[0..-suffix.length-1])
            puts "DERRRR SUFFF: #{word[0..-suffix.length-1]}"
            hyphenations[-suffix.length] = "-"
            if include_consonant?(suffix[0])
                word = word[0..-suffix.length-1]
            end
        end
        
        return word, hyphenations            
    end
    
    def exception?(word)
        return !all_letters?(word) || @dictionary.get_pos(word).eql?("fork")
    end
    
    def inflection_rule(word, inflection, hyphenations, log)
        if inflection.length >= word.length || !include_vowel?(word[0..-inflection.length-1])
            return hyphenations, log
        end
        
        if all_letters?(inflection)
            if include_vowel?(inflection) && include_consonant?(inflection)
                hyphenations[-inflection.length] = "-"
            else
                if desc = @dictionary.get_paradigm_description(word)
                    if desc.include?("på_E") && word.include?("e")
                        hyphenations[-word.reverse.index('e')-1] = "-"
                    elsif desc.include? "på_IG"
                    end
                end
            end
        else
            log = log + "\n     #{inflection}"
            if inflection.include? "+%"
                if split_length = inflection.reverse.index("+%")
                    log = log + "\n %-split: #{word[-split_length..-1]}"
                    if include_vowel?(word[-split_length..-1]) && include_consonant?(word[-split_length..-1])
                        hyphenations[-split_length] = "-"
                    end
                end
            elsif inflection.include? "%"
                if split_length = inflection.reverse.index('%')
                    log = log + "\n prosent-split: #{word[-split_length-1..-1]}"
                    if include_vowel?(word[-split_length-1..-1]) && include_consonant?(word[-split_length-1..-1])
                        hyphenations[-split_length-1] = "-"
                    end
                end
            elsif inflection.include? "++"
                split = inflection.split("++")
                if include_vowel?(split[1]) && include_consonant?(split[1])
                    hyphenations[-split[1].length] = "-"
                end
            end
        end
        
        return hyphenations, log
    end
    
    def hyphenate_word(word, hyphenations)
        result = ""
        
        word.each_char_with_index do |c, i|
            if hyphenations[i].eql? "-"
                result = "#{result}-#{c}"
            else
                result = "#{result}#{c}"
            end
        end
                            
        return result     
    end
    
    def rule_of_one_consonant(word, hyphenations, length, log)
        l = hyphenations.length - length
        log = log + "\n     Rule of one consonant: #{word}"
        word.each_char_with_index do |current_letter, i|
            prefix = i == 0 ? nil : word[0..i-1]
            suffix = i == word.length-1 ? nil : word[i+1..-1]

            # Can't have hyphenation at the beginning or at the end of a word :)
            next if prefix.nil? || suffix.nil?

            # Check if seen: One vowel in prefix, current letter is consonant and prefix is starts on a vowel
            if include_vowel?(prefix) && include_consonant?(current_letter) && include_vowel?(suffix[0])
                # Check for exception to one consonant rule: If the case, hyphenate before consonant group
                log = log + "\n         #{prefix} #{current_letter} #{suffix}"
                if exception = get_one_consonant_exception(prefix+current_letter)
                    hyphenations[l+i-exception.length+1] = "-"
                    log = log + "\n         if"
                else
                    # Else, hyphenate, except if 'x': X always belongs to previous syllable
                    hyphenations[l+i] = "-" unless current_letter.eql?('x')
                end
            end
            
        end
        
        return hyphenations, log
    end
    
    def get_one_consonant_exception(word)
        ONE_CONSONANT_EXCEPTIONS.each do |exception|
            if word[-exception.length..-1].eql? exception
                return exception
            end
        end
        
        return nil
    end
    
    def include_vowel?(word)
        return false if word.nil?
        
        word.each_char do |char|
            if VOWELS.include?(char)
                return true
            end
        end
        
        return false
    end
    
    def include_consonant?(word)
        return false if word.nil?
        
        word.each_char do |char|
            if CONSONANTS.include?(char)
                return true
            end
        end
        
        return false
    end        
    
    def all_letters?(str)
        str[/[[:alpha:]]+/]  == str
    end
    
end