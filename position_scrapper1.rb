require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pry-byebug'
# terminal table

USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36"

def find_position(page)
	
	asin = ARGV[0]
	keywords = ARGV[1].downcase.tr(" ", "+")

	binding.pry
	url = "https://www.amazon.com/s/ref=nb_sb_ss_c_1_9?url=search-alias%3Daps&field-keywords=#{keywords}&page=#{page}"

	doc = Nokogiri::HTML(open(url, "User-Agent" => USER_AGENT))

	element = doc.css("[data-asin='#{asin}']")
	# binding.pry
	unless element.empty?
		id = element.attr("id").to_s.gsub("result_", '').to_i
		return id
	else
		# if position is not returned
		return 0
	end
	
end


(1..20).each do |page|
	pos = find_position(page)
	if pos > 0
		puts pos
		break
	end
end