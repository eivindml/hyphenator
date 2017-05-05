#!/usr/bin/ruby

require_relative 'hyphenator/compound_splitter'
require_relative 'hyphenator/compound_interpretation_picker'
require_relative 'hyphenator/hyphenation_rule_application'

class Hyphenator
    def initialize
        @splitter = CompoundSplitter.new
        @picker = CompoundInterpretationPicker.new
        @hyphenater = HyphenationRuleApplication.new
    end

    def hyphenate(word)
        interpretations = @splitter.split(word)
        selected = @picker.pick(interpretations)
        hyphenated = @hyphenater.hyph(selected)
        
        return hyphenated
    end
end

hyphenator = Hyphenator.new
p hyphenator.hyphenate("lesesalsturer")
p hyphenator.hyphenate("løvemanke")
p hyphenator.hyphenate("hestesal")
p hyphenator.hyphenate("fagplanarbeid")
p hyphenator.hyphenate("aluminiumsnakke")