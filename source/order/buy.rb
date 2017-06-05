# frozen_string_literal: true

require_relative '../order'

class Order::Buy < Order
  include Redis::Objects

  value   :buy_or_sell

  def buy_or_sell
    :buy
  end
end
