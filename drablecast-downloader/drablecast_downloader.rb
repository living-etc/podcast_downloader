require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'uri'

def parse_sitemap(sitemap)
  Nokogiri::XML(open(sitemap)).tap do |doc|
    doc.xpath('//xmlns:loc').map(&:text).each { |links| yield links }
  end
end

def download(link)
  if link.first
    uri = URI(link.first.attributes['href'])

    begin
      puts "Downloading #{uri.to_s}"
      File.open("/Users/chriswilson/Desktop/drabblecast/#{File.basename(uri.path)}", 'wb') do |file|
        open(uri.to_s, 'rb') do |download|
          file.write(download.read)
        end
      end
    rescue Exception => e
      puts "    Retrying #{uri.to_s}"
      retry
    end
  end
end

def all_links_from(sitemap)
  parse_sitemap(sitemap) do |post|
    if post.match(/\d{4}\/\d{2}\/\d{2}/)
      Nokogiri::HTML(open(post.strip)).tap do |doc|
        doc.xpath('//a[contains(@class, "powerpress_link_d")]').tap do |link|
          download(link)
        end
      end
    end
  end
end

all_links_from('http://drabblecast.org/post-sitemap.xml')
