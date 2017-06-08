# frozen_string_literal: true

require_relative '../order'

class Order::Buy < Order
  def buy_or_sell
    :buy
  end
end
