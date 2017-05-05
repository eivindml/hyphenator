#!/usr/bin/ruby

require_relative '../lib/hyphenator/compound_splitter'
require_relative '../lib/hyphenator/dictionary'

SIMPLE_SPLITTED_COMPOUNDS_PATH = '../data/tests/simple-splitted-compounds.txt'
COMPLEX_SPLITTED_COMPOUNDS_PATH = '../data/tests/complex-splitted-compounds.txt'

class TestCompoundSplitter

    def initialize
        dict    = Dictionary.new
        @cs     = CompoundSplitter.new(dict)

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
                compound:   entry[0],
                should_be:  entry[1],
            })
        end
        return result
    end

    def simple_compounds
        return @simple
    end

    def complex_compounds
        return @complex
    end

    def write_to_complex_file(data)
        File.open("../data/tests/complex-interpreted-compounds.txt", 'a') do |file|
            data.each do |line|
                file.write(line)
                file.write("\n")
            end
        end
    end

    def write_to_simple_file(data)
        File.open("../data/tests/simple-interpreted-compounds.txt", 'a') do |file|
            data.each do |line|
                file.write(line)
                file.write("\n")
            end
        end
    end

    def run_test(compounds)
        result = Hash.new
        failed = 0
        passed = 0
        simple = Array.new
        complex = Array.new

        start_time = Time.now
        compounds.each do |item|
            result = @cs.split(item[:compound])
            status = "❌"
            if result.include? item[:should_be]
                status = "✅"
                passed = passed + 1
                simple_line = ""
                complex_line = ""
                if contains_eph?(result)
                    result.each do |x|
                        complex_line = "#{x}\t#{complex_line}"
                    end
                    complex_line = "#{item[:should_be]}\t#{complex_line}"
                    complex.push(complex_line)
                elsif
                    result.each do |x|
                        simple_line = "#{x}\t#{simple_line}"
                    end
                    simple_line = "#{item[:should_be]}\t#{simple_line}"
                    simple.push(simple_line)
                end
            elsif
                failed = failed + 1
            end
            puts "#{status}  Input: #{item[:compound]} | Should be: #{item[:should_be]}\nGot: #{result}"
        end
        end_time = Time.now
        delta_time = end_time - start_time

        write_to_simple_file(simple)
        write_to_complex_file(complex)

        puts "#{compounds.length} tests took #{delta_time} s"
        puts "#{passed} passed #{failed} failed / #{compounds.length}"
        puts "#{good} (G) #{bad} (B) #{missed} (M)"
    end

    def contains_eph?(list)
        list.each do |x|
            if x.include? "+s+"
                return true
            elsif x.include? "+e+"
                return true
            end
        end

        return false
    end

end

tcs = TestCompoundSplitter.new

#tcs.run_test(tcs.simple_compounds)
tcs.run_test(tcs.complex_compounds)
