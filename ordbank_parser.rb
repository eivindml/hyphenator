#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'

output_filename = 'ordliste.txt'
url = 'http://www.edd.uio.no/perl/search/search.cgi?restablename=OAB_TMP_11428137172&restabpos=0&restabnum=20&tabid=3174&oid=0&vobj=0&tabpos=0&appid=72&dosearch=++++S%F8k++++&listid=&oppsettid=-1&ResultatID=-1&ResRowsNum=50000'

result = Array.new
page = Nokogiri::HTML(open(url))

page.css('.ListResult tr').each do |row|
    if !row.css('td')[1].nil?
	if !row.css('td')[1].text.empty?
	    if !row.css('td')[1].text.include? '-'
		result.push(row.css('td')[1].text.gsub('*', '-').gsub('\n', ''))
	    end
    	end
    end
end

File.open(output_filename, 'w') do |file|
    result.each do |element|
        file.puts(element)
    end
end

puts "Extracted #{result.size} compound words from Norsk ordbank"
puts "Written to file #{output_filename}"
