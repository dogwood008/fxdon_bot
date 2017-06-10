# frozen_string_literal: true

require_relative '../order'

class Order::Sell < Order
  def sell_or_buy
    :sell
  end
end
