# Vending Machine [![Build Status](https://travis-ci.org/jonnyom/vending_machine.svg?branch=master)](https://travis-ci.org/jonnyom/vending_machine)
This is a Ruby gem which emulates a vending machine.

Provided with the name of a product and an array of coins (in string values), 
the machine will either return the correct product, 
or inform you of the relevant error.

### Installing the machine
```
gem install vending_machine
```

### The machine
The machine itself contains a hash of products, and its available change,
in denominations of €2 to 1c inclusive.

For example
```ruby
change = {
             "1c" => 100,
             "2c" => 100,
             "5c" => 100,
             "10c" => 100,
             "20c" => 100,
             "50c" => 100,
             "€1" => 100,
             "€2" => 100
           }
snickers = Product.new(name: "Snickers", price: "€2")
mars_bar = Product.new(name: "Mars Bar", price: "€1")
products = {
             "Snickers" => {
                product: snickers,
                available: 10
             },
             "mars bar" => {
                product: mars_bar,
                available: 5
               }
             }
machine = Machine.new(products: products, available_change: change)

machine.select_product(product: "Mars Bar", coins: ["20c", "50c", "10c", "20c"])
=> {:product=>"Mars Bar", :change=>["0"]}
```

If not enough money is given, the machine raises a MoreMoneyError and exits

```ruby
machine.select_product(product: "Snickers", coins: ["20c", "50c", "10c", "20c"])
MoreMoneyError: MoreMoneyError
```

The machine can be refilled with both products and change
```ruby
machine = Machine.new(products: [Product.new(name: "snickers", price: "€2")], available_change: available_change)
=> #<Machine:0x00007fb3ac086440 @available_change={1=>100, 2=>100, 5=>100, 10=>100, 20=>100, 50=>100, 100=>100, 200=>100}, @products=[#<Product:0x00007fb3ac0864e0 @name="snickers", @price="€2">]>
cash_refill = { "1c" => 100 }
machine.refill_cash(cash_refill)
=> {1=>100}
machine.available_change
=> {1=>200, 2=>100, 5=>100, 10=>100, 20=>100, 50=>100, 100=>100, 200=>100}

milky_bar = Product.new(name: "milky bar", price: "60c")
=> #<Product:0x00007fb81297fc30 @name="milky bar", @price="60c">
snickers = Product.new(name: "Snickers", price: "€2")
=> #<Product:0x00007fb8121e76a8 @name="Snickers", @price="€2">
machine.refill_products([{ product: milky_bar, available: 10 }, { product: snickers, available: 15 }])
=> [{:product=>#<Product:0x00007fb81297fc30 @name="milky bar", @price="60c">, :available=>10}, {:product=>#<Product:0x00007fb8121e76a8 @name="Snickers", @price="€2">, :available=>15}]
machine.products
=> {"Snickers"=>{:product=>#<Product:0x00007fb8121a54b0 @name="Snickers", @price="€2">, :available=>25},
 "Mars Bar"=>{:product=>#<Product:0x00007fb8121a53e8 @name="Mars Bar", @price="€1">, :available=>5},
 "milky bar"=>{:product=>#<Product:0x00007fb81297fc30 @name="milky bar", @price="60c">, :available=>20}}
```

### How does it find the correct change
The algorithm behind finding the correct change is a simple greedy algorithm which 
constantly asks for the largest coin denomination that can be returned without
the change going below 0.

For example
```ruby
available_coins = [1, 3, 4], change = 2
2 - 4 = -2: less than 0, moving on
2 - 3 = -1: less than 0, moving on
2 - 1 = 1: greater than 0, adding 1 to change array and checking if 1 still works with new change of 1
1 - 1 = 0: greater than 0, adding 1 to change array and checking if 1 still works with new change of 0
0 - 1 = -1: less than 0, moving on and breaking out as we have come to the end of the array
```

If the exact change for a product's price is given and no change needs to be calculated,
the machine simply returns the product and 0 change.

```ruby
machine.select_product(product: "Snickers", coins: ["€2"])
=> {:product=>"Snickers", :change=>["0"]}
```

### Running the machine locally
Simply run `gem install vending_machine`.

Then call a Ruby console of your choice (for example `pry` or `irb`)

Requiring the installed gem will then let you interact with it. 

This machine comes preloaded with some change and products for testing.


```
~/vending_machine ❯❯❯ pry                                                                                                                                                                                                    
[1] pry(main)> require "vending_machine"
=> true
[2] pry(main)> machine = Machine.new(products: products, available_change: change)
=> #<Machine:0x00007f8867a59280
 @available_change={1=>100, 2=>100, 5=>100, 10=>100, 20=>100, 50=>100, 100=>100, 200=>100},
 @products={"Snickers"=>{:product=>#<Product:0x00007f8867a59460 @name="Snickers", @price="€2">, :available=>10}, "Mars Bar"=>{:product=>#<Product:0x00007f8867a59398 @name="Mars Bar", @price="€1">, :available=>5}}>
```

### Tests
To run the tests simply `cd` into the root of the directory and run `rake`
