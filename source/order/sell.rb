# frozen_string_literal: true

require_relative '../order'

class Order::Sell < Order
  def buy_or_sell
    :sell
  end
end
