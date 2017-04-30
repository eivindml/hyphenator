#!/usr/bin/ruby

require_relative '../lib/hyphenator/compound_splitter'
require_relative '../lib/hyphenator/hyphenation_rules'
#require_relative '../lib/hyphenator/dictionary'

SIMPLE_SPLITTED_COMPOUNDS_PATH = '../data/tests/hyphenated-non-compounds.txt'
COMPLEX_SPLITTED_COMPOUNDS_PATH = '../data/tests/hyphenated-words.txt'

class TestHyphenationRules

    def initialize
        dict    = Dictionary.new
        @hr     = HyphenationRules.new(dict)

        @simple     = read_test_data(SIMPLE_SPLITTED_COMPOUNDS_PATH)
        @complex    = read_test_data(COMPLEX_SPLITTED_COMPOUNDS_PATH)
    end

    def read_test_data(test_data)
        result = Array.new

        File.open(test_data).readlines.each_with_index do |line, indx|
            if line[0].eql? '#'
                next
            end
            entry = line.delete("\n").split("\t")
            result.push({
                word:       entry[0],
                should_be:  entry[1],
            })
        end
        return result
    end

    def simple_words
        return @simple
    end

    def complex_words
        return @complex
    end

    def run_test(words)
        result = Hash.new
        failed = 0
        passed = 0
        simple = Array.new
        complex = Array.new

        start_time = Time.now
        good = 0
        bad = 0
        missed = 0
        words.each do |item|
            result, log = @hr.hyph([item[:word]])
            status = "❌"
            g, b, m = count_gbm(result, item[:should_be])
            good = good + g
            bad = bad + b
            missed = missed + m
            if result.eql? item[:should_be]
                status = "✅"
                passed = passed + 1
            elsif
                failed = failed + 1
                if m > 0
                    puts "#{status}  Input: #{item[:word]} | Should be: #{item[:should_be]} | Got: #{result} #{g} (G) #{b} (B) #{m} (M)"
                    puts log
                end
            end
        end
        end_time = Time.now
        delta_time = end_time - start_time

        puts "#{words.length} tests took #{delta_time} s"
        puts "#{passed} passed #{failed} failed / #{words.length}"
        puts "#{good} (G) #{bad} (B) #{missed} (M)"
    end
    
    def count_gbm(is, should_be)
        good = 0
        bad = 0
        missed = 0
        
        idx = 0
        should_be.each_char_with_index do |c,i|
            if c.eql? "-"
                if is[idx].eql? "-"
                    good = good + 1
                else
                    missed = missed + 1
                end
            else
                if is[idx].eql? "-"
                    bad = bad + 1
                    idx = idx + 1
                end
            end
                    
            if c.eql? is[idx]
                idx = idx + 1
            end
        end
        
        return good, bad, missed
    end

end

tcs = TestHyphenationRules.new

tcs.run_test(tcs.simple_words)
#tcs.run_test(tcs.complex_words)
