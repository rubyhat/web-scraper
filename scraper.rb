require 'nokogiri'
require 'httparty'
require 'byebug'

# Реализовано исключительно в образовательных целях.
# 2020. https://github.com/rubyhat

def scraper
  url = 'https://siteexample.kz/search/vacancy?L_is_autosearch=false&area=40&clusters=true&enable_snippets=true&page=0'
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)
  jobs = Array.new
  job_listings = parsed_page.css('div.vacancy-serp-item') #50 jobs

  per_page = job_listings.count
  total = parsed_page.css('h1.bloko-header-1').text.split(' ')[1].gsub(/[[:space:]]/, '').gsub(',','').to_i
  page = 0
  last_page = (total.to_f / per_page.to_f ).round
  while page <= last_page
    pagination_url = "https://siteexample.kz/search/vacancy?L_is_autosearch=false&area=40&clusters=true&enable_snippets=true&page=#{page}"
    pagination_unparsed_page = HTTParty.get(pagination_url)
    pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
    pagination_job_listings = pagination_parsed_page.css('div.vacancy-serp-item')

    # puts pagination_url
    # puts "Page #{page}"
    # puts ''

    pagination_job_listings.each do |job_listing|
      job = {
        title: job_listing.css('span.resume-search-item__name').text,
        company: job_listing.css('div.vacancy-serp-item__meta-info').text,
        location: job_listing.css('span.vacancy-serp-item__meta-info').text,
        # salary: job_listing.css('span.bloko-section-header-3')[].children.text,
        url: job_listing.css('a.bloko-link')[0].attributes['href'].value
      }
      jobs << job
      # puts "Added #{job[:title]}"
      # puts ""
    end
    page += 1
  end
  byebug
end

scraper