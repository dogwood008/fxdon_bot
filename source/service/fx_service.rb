# frozen_string_literal: true

require 'singleton'
require 'oanda_api'

class FxService
  include Singleton
  class TokenNotGivenError < StandardError; end
  class AccountNotGivenError < StandardError; end

  def initialize
    client
  end

  def prices
    p = client.prices(instruments: instruments).get.first
    { bid: p.bid, ask: p.ask }
  end

  def order(order)
    client.account(account)
      .order(instrument: instrument,
             type: :market,
             side: order.sell_or_buy,
             units: order.unit)
      .create
  end

  def position
    account.position(instrument).get
  end

  def close
    position.close
  end

  private

  def account
    @account ||= ENV["OANDA_#{env.upcase}_ACCOUNT"]&.to_i
    raise AccountNotGivenError unless @account
    @account
  end

  def env
    @env ||= ENV['OANDA_ENV']&.to_sym || :practice
  end

  def token
    @token ||= ENV["OANDA_#{env.upcase}_TOKEN"]
    raise TokenNotGivenError unless @token
    @token
  end

  def client
    @client ||= OandaAPI::Client::TokenClient.new(env, token)
  end

  def instruments
    [instrument]
  end

  def instrument
    'USD_JPY'
  end
end
