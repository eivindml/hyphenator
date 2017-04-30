#!/usr/bin/ruby

require_relative '../lib/hyphenator/compound_interpretation_picker'
require_relative '../lib/hyphenator/dictionary'

SIMPLE_INTERPRETED_COMPOUNDS_PATH = '../data/tests/simple-interpreted-compounds.txt'
COMPLEX_INTERPRETED_COMPOUNDS_PATH = '../data/tests/complex-interpreted-compounds.txt'

class TestCompoundInterpreter

    def initialize
        @simple = read_test_data(SIMPLE_INTERPRETED_COMPOUNDS_PATH)
        @complex = read_test_data(COMPLEX_INTERPRETED_COMPOUNDS_PATH)
    end

    def read_test_data(test_data)
        result = Array.new
        File.open(test_data).readlines.each_with_index do |line, indx|
            if line[0].eql? '#'
                next
            end
            entry = line.delete("\n").split("\t")
            result.push({
                should_be:   entry[0],
                splits:  entry[1..entry.length-1],
            })
        end
        return result
    end

    def test_simple
        return @simple
    end

    def test_complex
        return @complex
    end

end

failed = 0
passed = 0

dict = Dictionary.new
tci = TestCompoundInterpreter.new
ci = CompoundInterpreter.new(dict)

list = tci.test_complex()

t1 = Time.now
list.each do |item|
    result = ci.pick(item[:splits])
    result = result.join("+") if result.kind_of?(Array)
    emoji = "❌"
    if result.eql? item[:should_be]
        emoji = "✅"
        passed = passed + 1
    elsif
        failed = failed + 1
    end
    puts "#{emoji}  Should be: #{item[:should_be]} | Got: #{result}"
end
t2 = Time.now
delta = t2-t1
puts "Time: #{delta} s, failed: #{failed}, passed: #{passed} of #{list.length}"
