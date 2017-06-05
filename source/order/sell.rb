# frozen_string_literal: true

require_relative '../order'

class Order::Sell < Order
  include Redis::Objects

  value   :buy_or_sell

  def buy_or_sell
    :sell
  end
end
