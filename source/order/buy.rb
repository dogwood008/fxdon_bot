# frozen_string_literal: true

require_relative '../order'

class Order::Buy < Order
  VERBS = %w(buy ask 買い 買).freeze

  def sell_or_buy
    :buy
  end

  def self.verbs
    VERBS
  end

  def buy?
    true
  end

  def sell?
    false
  end
end
