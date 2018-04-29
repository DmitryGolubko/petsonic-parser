require 'nokogiri'
require 'open-uri'
require 'net/http'
require_relative 'product'
require 'csv'

class Parser
  def self.get_products(link)
    page_number = 1
    get_content = true
    $products = []
    threads = []
    request = URI(link)
    while get_content
      request.query = URI.encode_www_form(p: page_number)
      if Net::HTTP.get_response(request).code == '200'
        page = Nokogiri::HTML(open(request))
        page.xpath('//div[starts-with(@id, "product-container")]').each do |element|
          threads << Thread.new do
            $products << Product.new(element.css('a').attribute('href').value)
          end
        end
        threads.each(&:join)
        page_number += 1
      else
        get_content = false
      end
    end
    $products.delete_if { |element| element.price.nil? }
    $products
  end

  def self.export_to_csv(products, file)
    CSV.open(file, 'wb') do |csv|
      csv << ['Name', 'Price', 'Photo Link', 'Product link']
      products.each do |product|
        csv << [product.name, product.price, product.photo_link, product.link]
      end
    end
  end
end
