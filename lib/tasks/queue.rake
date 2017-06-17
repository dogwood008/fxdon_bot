# frozen_string_literal: true

namespace :queue do
  task :check do
    require_relative './trader'
    t = Trader.new
    t.fetch_and_order
  end
end
