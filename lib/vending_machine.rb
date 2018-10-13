require_relative "./product"
require_relative "./machine"

def products
  snickers = Product.new(name: "Snickers", price: "€2")
  mars_bar = Product.new(name: "Mars Bar", price: "€1")
  {
    "Snickers" => {
      product: snickers,
      available: 10
    },
    "Mars Bar" => {
      product: mars_bar,
      available: 5
    }
  }
end

def change
  {
    "1c" => 100,
    "2c" => 100,
    "5c" => 100,
    "10c" => 100,
    "20c" => 100,
    "50c" => 100,
    "€1" => 100,
    "€2" => 100
  }
end

def machine
  Machine.new(products: products, available_change: change)
end
