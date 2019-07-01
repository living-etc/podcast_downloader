require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'uri'

def download(link)
  if link.first
    uri = URI(link.first.attributes['href'])

    begin
      if !File.exists?("/Users/chriswilson/Desktop/writingexcuses/#{File.basename(uri.path)}")

        File.open("/Users/chriswilson/Desktop/writingexcuses/#{File.basename(uri.path)}", 'wb') do |file|
          open(uri.to_s, 'rb') do |download|
            file.write(download.read)
          end
        end
      else
        puts "#{File.basename(uri.path)} exists. Skipping"
      end
    rescue StandardError => e
      puts e.message
      puts "    Retrying #{uri.to_s}"
      retry
    end
  end
end

def retrieve_sitemap(sitemap)
  begin
    Nokogiri::XML(open(sitemap))
  rescue OpenURI::HTTPError => e
    puts e.message
    puts "Unable to retrieve sitemap. Retrying"
    retry
  end
end

def parse_sitemap(sitemap)
  retrieve_sitemap(sitemap).tap do |doc|
    doc.xpath('//xmlns:loc').each do |post|
      next if post.text.match(/\d{4}\/\d{2}\/\d{2}/)

      yield Nokogiri::HTML(open(post.text.strip)).xpath('//a[contains(@class, "powerpress_link_d")]')
    end
  end
end

def all_links_from(sitemap)
  parse_sitemap(sitemap) { |link| download(link) }
end

all_links_from('http://www.writingexcuses.com/sitemap.xml')
