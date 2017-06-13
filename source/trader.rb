# frozen_string_literal: true

require_relative './order/buy'
require_relative './order/sell'
require_relative './sqs/fake_sqs'
require_relative './service/fx_service'
require_relative './service/queue_service'

class Trader
  UNITS_LIMIT = 10_000.freeze

  def fetch_and_order
    buy_orders_size, sell_orders_size = fetch_and_check_queue
    order_units = resize_units(order_units(buy_orders_size, sell_orders_size))
    return if order_units <= 0
    klass = order_class(buy_orders_size, sell_orders_size)
    return if klass.nil?
    klass.unit = order_units
    fx_service.order(klass)
  end

  private

  def resize_units(order_units)
    [UNITS_LIMIT - holding_units, order_units].min
  end

  def fetch_and_check_queue
    queue = queue_service.fetch_and_purge_all
    buy_orders_size = queue.find_all { |q| q.buy? }.size
    sell_orders_size = queue.find_all { |q| q.sell? }.size
    [buy_orders_size, sell_orders_size]
  end

  def order_units(buy_orders_size, sell_orders_size)
    order_class_size = if buy_orders_size > sell_orders_size
                         buy_orders_size.to_f
                       elsif buy_orders_size < sell_orders_size
                         sell_orders_size.to_f
                       else
                         0
                       end
    return if order_class_size == 0
    all_orders_size = (buy_orders_size + sell_orders_size).to_f
    (UNITS_LIMIT * order_class_size / all_orders_size).to_i
  end

  def order_class(buy_orders_size, sell_orders_size)
    if buy_orders_size > sell_orders_size
      Order::Buy.new(nil, nil)
    elsif buy_orders_size < sell_orders_size
      Order::Sell.new(nil, nil)
    else
      nil
    end
  end

  def holding_units
    position = fx_service.position
    return 0 if position.nil?
    position.units
  end

  def queue_service
    QueueService.instance
  end

  def fx_service
    FxService.instance
  end
end
