# frozen_string_literal: true

require 'json'

class Order
  attr_reader :price, :unit

  def initialize(price, unit)
    @price = price
    @unit = unit
  end

  def to_h
    {
      price: @price,
      unit: @unit,
      buy_or_sell: buy_or_sell
    }
  end

  def to_json
    to_h.to_json
  end

  class << self
    def create_from_json(json_string)
      j = JSON.parse(json_string, symbolize_names: true)
      klass = get_buy_or_sell_class_by_name(j[:buy_or_sell])
      klass.new(j[:price], j[:unit])
    end

    private

    def get_buy_or_sell_class_by_name(buy_or_sell)
      case buy_or_sell&.to_sym
      when :buy
        Order::Buy
      when :sell
        Order::Sell
      else
        raise ArgumentError
      end
    end
  end
end
