require 'json'
require 'net/http'
require 'uri'
require 'awesome_print'

# Assume all dimensions are given in cm
def self.calculate_cubic_weigth(conversion_factor, width, length, height)
  cubic_meters = ( width * length * height ) / 1_000_000 
  cubic_weight = cubic_meters * conversion_factor
end

def self.average_cubic_weigth(array)
  array.reduce(:+) / array.length
end

CONVERSION_FACTOR = 250
URL = 'http://wp8m3he1wt.s3-website-ap-southeast-2.amazonaws.com'
CATEGORY = 'air conditioners'

######### MAIN 
path = '/api/products/1'
products_cubic_weigth = []

until ( path.nil? )
  uri = URI.parse(URL + path)
  response = Net::HTTP.get_response(uri)
  response_body = JSON.parse(response.body)

  response_body['objects'].each do |product|
    next unless product['category'].downcase == CATEGORY
    next if product['size'].empty?
    
    cubic_weigth = calculate_cubic_weigth(CONVERSION_FACTOR, product['size']['width'], product['size']['length'], product['size']['height'])
    products_cubic_weigth << cubic_weigth
  end

  path = response_body['next']
end

puts "Average cubic weight for all products in the 'Air Conditioners' category"
puts "#{average_cubic_weigth(products_cubic_weigth)} kg"
