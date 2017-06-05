# frozen_string_literal: true

require_relative './redis_setting'

class Order
  RedisSetting.instance
  include Redis::Objects

  value   :price
  value   :unit

  def initialize(price, unit)
    @price = price
    @unit = unit
  end
end
