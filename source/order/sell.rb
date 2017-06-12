# frozen_string_literal: true

require_relative '../order'

class Order::Sell < Order
  VERBS = %w(sell bid 売り 売).freeze

  def sell_or_buy
    :sell
  end

  def self.verbs
    VERBS
  end
end
