#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  header = noko.xpath('//tr[contains(.,"CONSTITUENCY REPRESENTED")]').last
  header.xpath('following-sibling::tr').each do |tr|
    tds = tr.css('td')
    next if tds.count < 4

    # Don't need anything extra from this yet...
    source = tds[0].css('a/@href').text
    next if source.to_s.empty?
    source = URI.join(url, source).to_s 

    data = { 
      id: source.split('/').last.split('-').first,
      name: tds[0].text.sub('Hon. ','').tidy,
      constituency: tds[1].text.tidy,
      party: tds[2].text.tidy,
      image: tds[3].css('img/@src').text,
      term: 2012,
      source: source,
    }
    data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?

    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

scrape_list('http://nationalassembly.gov.bz/index.php/hor-lowerhouse/present-members-house')
