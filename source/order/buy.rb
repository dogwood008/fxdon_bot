# frozen_string_literal: true

require_relative '../order'

class Order::Buy < Order
  def sell_or_buy
    :buy
  end
end
