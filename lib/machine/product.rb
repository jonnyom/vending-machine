require_relative "./cash"

class Product
  attr_reader :name, :price

  def initialize(name:, price:)
    @name = name
    @price = price
  end

  def cash_value
    Cash.cash_value(price)
  end
end
