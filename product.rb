require 'nokogiri'
require 'open-uri'
require 'net/http'

class Product
  attr_accessor :link
  attr_reader :name, :price, :photo_link

  def initialize(link, name = nil, price = nil, photo_link = nil, multi_product = false)
    @link = link
    if !multi_product
      get_content
    else
      @name = name
      @price = price
      @photo_link = photo_link
    end
    p @link
    p @name
    p @price
    p @photo_link
    puts
  end

  private

  def get_content
    request = URI(@link)
    page = Nokogiri::HTML(open(request))
    get_photo(page)
    get_name(page)
    if page.css('ul.attribute_labels_lists').count > 1
      create_multi_product(page)
    else
      get_weight(page)
      get_price(page)
      @name += ' ' + @weight
    end
  end

  def get_photo(page)
    @photo_link = page.css('img#bigpic').attribute('src').value
  end

  def get_name(page)
    @name = page.css('h1.nombre_producto').children.text.delete("\n").strip
  end

  def get_weight(page)
    @weight = page.css('ul.attribute_labels_lists li span.attribute_name').children.text
  end

  def get_price(page)
    @price = page.css('ul.attribute_labels_lists li span.attribute_price').children.text.delete("\n").strip
    @price = page.css('span#our_price_display').children.text if @price.empty?
  end

  def create_multi_product(page)
    weights = []
    prices = []
    page.css('ul.attribute_labels_lists li span.attribute_name').children.each do |child|
      weights << child.text
    end

    page.css('ul.attribute_labels_lists li span.attribute_price').children.each do |child|
      prices << child.text.delete("\n").strip
    end

    weights.each_with_index do |weight, index|
      $products << Product.new(@link, @name + ' - ' + weight, prices[index], @photo_link, true)
    end
  end
end
