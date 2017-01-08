#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class MembersPage < Scraped::HTML
  field :members do
    noko.xpath('//h4[@class="title-heading"]/../..').map do |node|
      fragment node => MemberSection
    end
  end
end

class MemberSection < Scraped::HTML
  field :name do
    noko.css('h4').text.sub(/(Rt. )?Hon. /, '').tidy
  end

  field :constituency do
    noko.xpath('.//h5/text()').first.text.tidy
  end

  field :party do
    noko.xpath('.//h5/text()').last.text.tidy
  end

  field :image do
    noko.css('img/@src').text
  end

  field :source do
    url
  end
end

url = 'http://www.nationalassembly.gov.bz/house-of-representatives/'
page = MembersPage.new(response: Scraped::Request.new(url: url).response)
data = page.members.map(&:to_h)
# puts data

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
ScraperWiki.save_sqlite(%i(name constituency party), data)
