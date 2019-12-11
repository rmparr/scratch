require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'

class Scrapper
  def self.search(search_terms, base_url)
    search_terms.each do |term|
      record_count = get_record_count(base_url, term)
      page_numbers = (1..record_count/1000)
      page_numbers.each do |page_number|
        doc = make_web_request(base_url, term, page_number)
        response = parse_doc(doc)
        write_file(response, term)
      end
    end
  end

  def self.make_web_request(url, term, page_number)
    Nokogiri::HTML(open("#{url}&PaginationPageSize=1000&PaginationCurrentPage=#{page_number}&Term=#{term}"))
  end

  def self.parse_doc(doc)
    JSON.parse(doc)
  end

  def self.write_file(response, term)
    File.open("#{term}.json", 'a') { |file| file.write(response.to_json) }
  end

  def self.get_record_count(url, term)
    doc = Nokogiri::HTML(open("#{url}&PaginationPageSize=1&PaginationCurrentPage=1&Term=#{term}"))
    response = parse_doc(doc)
    response['totalRecordCount'].to_i
  end
end

base_url = 'https://www.myco.dica.gov.mm/api/corp/SearchCorpByTerm?IsAutocomplete=false&Option=2'

# search_terms = [*('a'..'z'),*(0..9)]
search_terms = ['a']

Scrapper.search(search_terms, base_url)