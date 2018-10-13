class Cash

  class << self
    def cash_values(coins)
      coins.map { |coin| coin_map[coin] }
    end

    def string_values(coins)
      coins.map { |coin| to_string[coin] }
    end

    def cash_value(coin)
      coin_map[coin]
    end

    def string_value(coin)
      to_string[coin]
    end

    def valid_coins
      coin_map.keys
    end

    private def coin_map
      {
        "1c" => 1,
        "2c" => 2,
        "5c" => 5,
        "10c" => 10,
        "20c" => 20,
        "50c" => 50,
        "€1" => 100,
        "€2" => 200
      }
    end

    private def to_string
      {
        1 => "1c",
        2 => "2c",
        5 => "5c",
        10 => "10c",
        20 => "20c",
        50 => "50c",
        100 => "€1",
        200 => "€2"
      }
    end
  end

end
