#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'

# Cacluate percentage
def to_percent(numerator, denominator)
    return (numerator.to_f/denominator.to_f) * 100.000
end

# Name of output file
output_filename = 'ord_m_fuge.txt'
# URL to Edd search results, only containing words with 'bindebokstaver'
# Sometimes it is necessary to do a new search at Edd [1] with the field Fuge
# containing the phrase '%', and change the 'Resultater pr. side' to e.g. 50000 
# to get a working URL.
# [1] http://www.edd.uio.no/perl/search/search.cgi?appid=72&tabid=3174
url = 'http://www.edd.uio.no/perl/search/search.cgi?restablename=OAB_TMP_11318990440&restabpos=0&restabnum=20&tabid=3174&oid=0&vobj=0&tabpos=0&appid=72&dosearch=++++S%F8k++++&listid=&oppsettid=-1&ResultatID=-1&ResRowsNum=50000'

page = Nokogiri::HTML(open(url))
result = Hash.new(0)

## Parse page: run through each table row
page.css('.ListResult tr').each do |row|
    if !row.css('td')[1].nil?
        ## Seventh column contains the 'bindebokstav'
        fuge = row.css('td')[6].text.chomp
        result[fuge] = result[fuge] + 1
    end
end

# Get total numbers of words with 'bindebokstav'
total = 0
result.each {|k, v| total = total + v.to_i}

# Print formatted result
result.each do |key, value|
    percent = ('%.3f' % to_percent(value, total)).to_s
    puts "«#{key}»    #{percent} %"
end