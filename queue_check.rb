require 'rufus-scheduler'
require_relative './trader'

scheduler = Rufus::Scheduler.new

scheduler.in '1m' do
  t = Trader.new
  t.fetch_and_order
end

scheduler.join
# let the current thread join the scheduler thread
