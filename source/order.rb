# frozen_string_literal: true

require 'json'

class Order
  class SellOrBuyNotGivenError < StandardError; end
  class UnitHasAlreadyGivenError < StandardError; end

  attr_reader :price, :unit

  def initialize(price, unit)
    @price = price
    @unit = unit
  end

  def to_h
    {
      price: @price,
      unit: @unit,
      sell_or_buy: sell_or_buy
    }
  end

  def to_json
    to_h.to_json
  end

  def bid_or_ask
    case sell_or_buy&.to_sym
    when :sell
      :bid
    when :buy
      :ask
    else
      raise SellOrBuyNotGivenError
    end
  end

  def buy?
    raise NotImplementedError
  end

  def sell?
    raise NotImplementedError
  end

  def unit=(units)
    raise UnitHasAlreadyGivenError if @unit
    @unit = units
  end

  class << self
    def create_from_json(json_string)
      j = JSON.parse(json_string, symbolize_names: true)
      klass = get_sell_or_buy_class_by_name(j[:sell_or_buy])
      klass.new(j[:price], j[:unit])
    end

    def verbs
      raise NotImplementedError
    end

    def all_verbs
      [Order::Buy.verbs, Order::Sell.verbs].flatten
    end

    private

    def get_sell_or_buy_class_by_name(sell_or_buy)
      case sell_or_buy&.to_sym
      when :sell
        Order::Sell
      when :buy
        Order::Buy
      else
        raise SellOrBuyNotGivenError
      end
    end
  end
end
