#!/usr/bin/ruby

require 'rubygems'
require 'open-uri'
require 'algorithms'
require_relative('../utils/string')

WORD_LIST_PATH = "#{File.dirname(__FILE__)}/../../data/ordbank_bm/fullform_bm-utf8.txt"
PARADIGM_PATH = "#{File.dirname(__FILE__)}/../../data/ordbank_bm/paradigme_bm-utf8.txt"
TRIE_PATH = "#{File.dirname(__FILE__)}/../../data/ordbank_bm/fullform_bm_trie.txt"

# Vowels and consonants
VOWELS = ["a", "e", "i", "o", "u", "y", "æ", "ø", "å"]
CONSONANTS = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z"]

# Prefixes
NOR_PREFIXES = ["u", "mis", "van", "be", "for", "fore", "føre", "der", "sam"]
GER_PREFIXES = ["an", "bi", "er", "ge", "unn"]
FOR_PREFIXES = ["a", "ad", "an", "andro", "ante", "anti", "antro", "bi", "bio", "centi", "de", "des", "di", "dia", "dis", "dys", "eks", "erke", "eu", "ev", "geo", "giga", "hetero", "homo", "hyper", "hypo", "il", "im", "in", "inter", "intra", "iso", "ko", "kon", "kontra", "kvasi", "makro", "maksi", "mega", "meta", "midi", "mikro", "milli", "mini", "mono", "multi", "non", "orto", "pan", "para", "poly", "post", "pre", "pro", "proto", "pseudo", "psevdo", "re", "retro", "semi", "sub", "super", "syn", "tele", "trans", "ultra", "uni", "vara", "vise", "øko"]
# Suffixes
NOR_SUFFIXES = ["ing", "ning", "ling", "else", "sel", "nad", "sjon", "dom", "skap", "het", "itet", "isk", "lig", "som", "logi", "vis", "isme", "ig"]#, "er", "ar"]
# Prefix and suffix short definitions
PREFIXES = NOR_PREFIXES + GER_PREFIXES + FOR_PREFIXES
SUFFIXES = NOR_SUFFIXES

class Dictionary

    def initialize  
        @paradigm = read_paradigm(PARADIGM_PATH)
        @dictionary = read_dictionary(WORD_LIST_PATH)
    end

    # Returns word from dictionary, if not present returns nil
    def get(word)
        return @dictionary.get(word)
    end

    def get_paradigm(code)
        result = Array.new
        @paradigm.each do |entry|
            if code == entry[:id]
                result.push entry
            end
        end
        return result
    end

    def get_paradigm_inflection_entry(entries, number)
        entries.each do |entry|
            if entry[:paradigm_number] == number
                return entry
            end
        end
    end

    def is_atomic_word?(word)
        @dictionary.each do |entry|
            if word.eql? entry[:full_form]
                return true
            end
        end
        return false
    end

    def is_compound_word?(compound)
        cs = CompoundSplitter.new(self)
        result = cs.split(compound)
        ret_val = false
        result.each do |t|
            if t.include? "+"
                ret_val = true
            end
        end

        return ret_val
    end

    def is_word?(word)
        return false if (word.length == 1)
        if entry = @dictionary.get(word)
            if abbreviation?(word)
                return false
            elsif entry[0][:morphology].include?("prep")
                return false
            # elsif entry[0][:morphology].include?("symb")
            #     return false
            end
            return true
        end
        return false
    end

 
    def get_pos(word)
        entry = get(word)
        return nil if entry.nil?
        return entry[0][:morphology].partition(" ")[0]
    end

    def get_inflection(word)
        w_entry = get(word)
        p_entries = get_paradigm(w_entry[0][:paradigm_code]) unless w_entry.nil?
        i_entry = get_paradigm_inflection_entry(p_entries, w_entry[0][:paradigm_number]) unless p_entries.nil?

        return nil if i_entry.nil?

        return i_entry.empty? ? nil : i_entry[:inflection]
    end
    
    def get_paradigm_description(word)
        w_entry = get(word)
        p_entries = get_paradigm(w_entry[0][:paradigm_code]) unless w_entry.nil?
        i_entry = get_paradigm_inflection_entry(p_entries, w_entry[0][:paradigm_number]) unless p_entries.nil?

        return nil if i_entry.nil?

        return i_entry.empty? ? nil : i_entry[:paradigm_des]
    end

    def word_stem(word)
        w_entry = get(word)

        if w_entry.nil?
            return nil
        elsif w_entry.empty?
            return nil
        end

        return w_entry[:basic_form]
    end

    def abbreviation?(word)
        w_entry = get(word)

        return nil if w_entry.nil?

        if w_entry[0][:morphology].include?("fork")
            return true
        elsif w_entry[0][:morphology].include?("henv")
            return true
        end

        return false
    end

    def get_derivation_suffix(word)
        suff = SUFFIXES.sort_by {|x| x.length}
        suff.reverse.each do |suffix|
            if suffix.eql?(word[-suffix.length..-1]) && !word[0..-suffix.length-1].nil?
                return suffix
            end
        end
        
        return nil
    end

    def get_derivation_prefix(word)
        pref = PREFIXES.sort_by {|x| x.length}
        pref.reverse.each_with_index do |prefix, index|
           if prefix.eql?(word[0..prefix.length-1]) && !word[prefix.length..-1].nil?
               if is_word?(word[prefix.length..-1])    
                   return prefix
               end
           end
       end

       return nil
    end

    # TODO: Ikke god nok. F.eks. kai regnes som to
    def one_syllable?(word)
        string = ""
        word.downcase.each_char do |char|
            if VOWELS.include? char
                string = string + "v"
            else
                string = string + "c"
            end
        end
        return string.scan(/v+/).size <= 1
    end

    def read_dictionary(path)

        if File.exist?(TRIE_PATH)
            File.open(TRIE_PATH) do|file|
                @dictionary = Marshal::load(file)
                return @dictionary
            end
        else
            @dictionary = read_dictionary_from_file(WORD_LIST_PATH)
            File.open(TRIE_PATH, 'w') do |file|
                file.puts Marshal::dump(@dictionary)
            end
            return @dictionary
        end
    end

    def read_dictionary_from_file(dictionary)
        dict = Containers::Trie.new
        File.open(dictionary).readlines.each_with_index do |line, indx|
            if line[0].eql? '*'
                next
            end
            entry = line.delete("\n").split("\t")
            
            e = {
                id:              entry[0],
                basic_form:      entry[1],
                full_form:       entry[2],
                morphology:      entry[3],
                paradigm_code:   entry[4],
                paradigm_number: entry[5]
            }
            
            if dict.has_key?(entry[2])
                t = dict.get(entry[2])
                t.push(e)
                dict.push(entry[2], t)
            else
                a = Array.new
                a.push(e)
                dict.push(entry[2], a)
            end
        end
        return dict
    end

    def read_paradigm(paradigm)
        paradigms = Array.new
        File.open(paradigm).readlines.each do |line|
            if line[0].eql? '*'
                next
            end
            t = line.delete("\n").split("\t")
            entry = {
                id:                 t[0],
                pos:                t[1],
                paradigm_des:       t[2],
                full_or_not:        t[3],
                paradigm_number:    t[5],
                morph_desc:         t[6],
                inflection:         t[7]
            }
            paradigms.push entry
        end
        return paradigms
    end
end