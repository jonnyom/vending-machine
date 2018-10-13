require "spec_helper"
require_relative "../lib/machine/machine"
require_relative '../lib/machine/product'

RSpec.describe Machine do
  let(:snickers) { Product.new(name: "snickers", price: "€1") }
  let(:mars_bar) { Product.new(name: "mars bar", price: "€2") }
  let(:change) do
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
  let(:products) do
    {
      "snickers" => {
        product: snickers,
        available: 10
      },
      "mars bar" => {
        product: mars_bar,
        available: 5
      }
    }
  end
  subject(:machine) { Machine.new(products: products, available_change: change) }

  describe ".select_product" do

    context "with the exact amount of money" do
      it "returns the chosen product" do
        product_and_change = machine.select_product(product: "snickers", coins: ["€1"])
        expect(product_and_change[:product]).to eq(snickers.name)
        expect(product_and_change[:change]).to eq(["0"])
      end
    end

    context "with different denominations" do
      it "returns the chosen product" do
        product_and_change = machine.select_product(product: "mars bar", coins: ["1c", "€1", "50c", "10c", "50c"])
        expect(product_and_change[:product]).to eq (mars_bar.name)
        expect(product_and_change[:change]).to eq(["10c", "1c"])
      end
    end

    context "without enough money" do
      it "gives out" do
        expect { machine.select_product(product: "mars bar", coins: ["€1"]) }.to raise_error MoreMoneyError
      end
    end

    context "without any money" do
      it "raises a NoMoneyError" do
        expect { machine.select_product(product: "snickers", coins: []) }.to raise_error NoMoneyError
      end
    end

    context "without any available money left in the machine" do
      let(:change) do
        {
          "1c" => 0,
          "2c" => 0,
          "5c" => 0,
          "10c" => 0,
          "20c" => 0,
          "50c" => 0,
          "€1" => 0,
          "€2" => 0
        }
      end
      it "raises an OutOfMoneyError if exact change isn't given" do
        expect { machine.select_product(product: "snickers", coins: ["20c", "€1"]) }.to raise_error OutOfMoneyError
      end

      it "increments the amount of available change" do
        machine.select_product(product: "snickers", coins: ["€1"])
        expect(machine.available_change[100]).to eq(1)
      end
    end

    context "with missing products" do
      let(:products) do
        {
          "snickers" => {
            product: snickers,
            available: 0
          }
        }
      end
      it "raises a OutOfSelectedProductError" do
        expect { machine.select_product(product: "snickers", coins: ["€1"]) }.to raise_error OutOfSelectedProductError
        expect { machine.select_product(product: "milky bar", coins: ["25c"]) }.to raise_error OutOfSelectedProductError
      end
    end

    it "decrements the amount of change" do
      machine.select_product(product: "snickers", coins: ["€1", "1c"])
      expect(machine.available_change[1]).to eq(100)
      expect(machine.available_change[100]).to eq(101)
      expect(machine.products["snickers"][:available]).to eq(9)
    end
  end

  describe ".refill_products" do
    context "when passed an array of products and the amount of products given" do
      let(:milky_bar) { Product.new(name: "milky bar", price: "60c") }
      let(:product_refills) do
        [
          {
            product: snickers,
            available: 10
          },{
            product: milky_bar,
            available: 5
          }
        ]
      end
      it "successfully refills existing products" do
        machine.refill_products(product_refills)
        expect(machine.products["snickers"][:available]).to eq(20)
      end

      it "successfully adds new products" do
        machine.refill_products(product_refills)
        expect(machine.products["milky bar"]).to eq(product_refills[1])
      end
    end
  end

  describe ".refill_cash" do
    context "with valid coins" do
      let(:cash_refill) do
        {
          "1c" => 100
        }
      end
      it "refills the existing change" do
        machine.refill_cash(cash_refill)
        expect(machine.available_change[1]).to eq(200)
      end
    end

    context "with invalid coins" do
      let(:cash_refill) do
        {
          "hoogabooga" => 100
        }
      end
      it "raises an InvalidCoin error" do
        expect { machine.refill_cash(cash_refill) }.to raise_error InvalidCoinError
      end
    end
  end

end
