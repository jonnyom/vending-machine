# frozen_string_literal: true

require_relative "./cash"
require_relative "./product"
require_relative "../errors/invalid_coin_error"
require_relative "../errors/more_money_error"
require_relative "../errors/no_money_error"
require_relative "../errors/out_of_money_error"
require_relative "../errors/out_of_selected_product_error"

class Machine
  attr_accessor :products, :available_change

  def initialize(products:, available_change:)
    @products = products
    @available_change = transform_keys_to_cash(available_change)
  end

  def select_product(product:, coins:)
    raise ArgumentError unless coins.is_a? Array
    raise NoMoneyError if coins.empty?
    product = products[product]
    raise OutOfSelectedProductError if product.nil? || product[:available].zero?
    find_product(product: product[:product], cash_values: Cash.cash_values(coins))
  end

  def refill_products(products)
    reload_products(product_refills: products)
  end

  def refill_cash(cash)
    reload_cash(cash_refills: cash)
  end

  private def find_product(product:, cash_values:)
    product_price = product.cash_value
    if correct_change_given?(product_price: product_price, coins: cash_values)
      available_change[product_price] += 1
      decrement_available_products(product)
      return product_and_change(product)
    end
    raise OutOfMoneyError if remaining_change.empty?
    change = change(product_price: product_price, coins: cash_values)
    coins = calculate_coin_denominations(change: change)
    decrement_available_products(product)
    product_and_change(product, Cash.string_values(coins))
  end

  private def product_and_change(product, change = nil)
    {
      product: product.name,
      change: change.nil? ? ["0"] : change
    }
  end

  private def correct_change_given?(product_price:, coins: [])
    raise ArgumentError unless coins.is_a? Array
    return true if exact_change?(coins: coins) && (product_price - coins.first).zero?
    change = change(product_price: product_price, coins: coins)
    change <= 0
  end

  private def change(product_price:, coins:)
    @change ||= calculate_change(product_price: product_price, coins: coins)
  end

  private def calculate_change(product_price:, coins:)
    sorted_coins = coins.sort.reverse!
    sorted_coins.each do |coin|
      product_price -= coin
    end
    raise MoreMoneyError if product_price.positive?
    product_price.abs
  end

  private def calculate_coin_denominations(change:)
    available_coins = remaining_change.keys.sort.reverse!
    change_array = []
    available_coins.each do |coin|
      next if (change - coin).negative?
      until (change - coin).negative?
        change -= coin
        change_array << coin
      end
    end
    decrement_available_change(change_array)
    change_array
  end

  private def reload_products(product_refills:)
    raise ArgumentError unless product_refills.is_a? Array
    raise ArgumentError unless product_refills.all? { |product_refill| product_refill[:product].is_a? Product }
    raise ArgumentError if product_refills.empty?
    product_refills.each do |product_refill|
      product_name = product_refill[:product].name
      if products[product_name].nil?
        products[product_name] = product_refill
      else
        products[product_name][:available] += product_refill[:available]
      end
    end
  end

  private def reload_cash(cash_refills:)
    raise ArgumentError if cash_refills.empty?
    raise InvalidCoinError unless (cash_refills.keys - Cash.valid_coins).empty?
    cash_value_refills = transform_keys_to_cash(cash_refills)
    cash_value_refills.each do |coin, amount|
      next if amount.negative?
      available_change[coin] += amount
    end
  end

  private def exact_change?(coins:)
    coins.length == 1
  end

  private def remaining_change
    available_change.select { |coin, remaining| remaining.positive? }
  end

  private def transform_keys_to_cash(coins)
    coins.transform_keys! { |coin| Cash.cash_value(coin) }
  end

  private def decrement_available_change(change_array)
    change_array.each { |change| available_change[change] -= 1 }
  end

  private def decrement_available_products(product)
    products[product.name][:available] -= 1
  end
end
