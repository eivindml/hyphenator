#!/usr/bin/ruby

require_relative '../lib/hyphenator/compound_splitter'
require_relative '../lib/hyphenator/hyphenation_rule_application'
require_relative '../lib/hyphenator/dictionary'

COMPLEX_SPLITTED_COMPOUNDS_PATH = '../data/tests/hyphenated-words.txt'

class Apekatt

    def initialize
        @complex    = read_test_data(COMPLEX_SPLITTED_COMPOUNDS_PATH)
    end

    def read_test_data(test_data)
        result = Array.new

        File.open("output.txt", 'w') do |file|
            File.open(test_data).readlines.each_with_index do |line, indx|
                if line[0].eql? '#'
                    next
                end
                entry = line.delete("\n")
                word = entry.delete("-")
                file.write("#{word}\t#{entry}\n")
            end
        end
    end

end

tcs = Apekatt.new

