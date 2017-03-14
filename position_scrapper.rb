require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'terminal-table'
require 'pry-byebug'

get '/' do
  erb :index
end

@asin = find_all_asin(params['asin'])

post '/result' do
  @title = "Thanks for scrapping #{params['asin']}!"
  
  @asin = find_all_asin(params['asin'])
  # erb :result
end

USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36"

# puts "What's the ASIN?"
# puts ">"
# asin = gets.chomp.to_s


def find_all_asin(given_asin)
	# given_asin = ARGV[0]

	url = "https://www.amazon.com/dp/#{given_asin}"

	doc = Nokogiri::HTML(open(url, "User-Agent" => USER_AGENT)) 

	elements = doc.css("[class='dropdownAvailable']")
	# binding.pry

	all_asins = elements.map { |element| element["value"][2..-1] }.compact

	return all_asins.unshift(given_asin)
end


def get_position(page, keywords, asin)
	
	keywords = keywords.downcase.tr(" ", "+")

	url = "https://www.amazon.com/s/ref=nb_sb_ss_c_1_9?url=search-alias%3Daps&field-keywords=#{keywords}&page=#{page}"

	doc = Nokogiri::HTML(open(url, "User-Agent" => USER_AGENT))

	element = doc.css("[data-asin='#{asin}']")
	
	unless element.empty?
		# get the ID of the element (result_1, result_2), remove 'result_' and convert it to a n interger
		id = element.attr("id").to_s.gsub("result_", '').to_i
		return id 
	else
		# if position is not returned
		return 0
	end
	
end


def get_position_in_pages(keywords, asin)

	(1..20).each do |page|

		pos = get_position(page, keywords, asin)
		
		rows = []

		if pos > 0
			rows << [asin, keywords, pos]
			table = Terminal::Table.new :rows => rows
			puts table
			break
		end

	end

end


# keywords in the CLI, remove the first word (the ASIN)
all_keywords = ARGV.drop(1)

all_keywords.each do |keyword|

	all_asins = find_all_asin

  	all_asins.each do |asin|
		get_position_in_pages(keyword, asin)
	end

end
