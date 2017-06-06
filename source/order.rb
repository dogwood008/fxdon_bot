# frozen_string_literal: true

class Order
  attr_reader :price, :unit

  def initialize(price, unit)
    @price = price
    @unit = unit
  end
end
