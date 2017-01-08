#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//h4[@class="title-heading"]/../..').each do |mem|
    data = {
      name:         mem.css('h4').text.sub(/(Rt. )?Hon. /, '').tidy,
      constituency: mem.xpath('.//h5/text()').first.text.tidy,
      party:        mem.xpath('.//h5/text()').last.text.tidy,
      image:        mem.css('img/@src').text,
      source:       url,
    }
    # puts data
    ScraperWiki.save_sqlite(%i(name constituency party), data)
  end
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_list('http://www.nationalassembly.gov.bz/house-of-representatives/')
