require_relative 'parser'
require_relative 'product'

link = ENV['LINK']
outfile = ENV['OUTFILE']

start_time = Time.now
puts "Start time: #{start_time}"
products = Parser.get_products(link)
Parser.export_to_csv(products, outfile)
end_time = Time.now
puts end_time
total = end_time - start_time
puts "Total time:  #{total}"
