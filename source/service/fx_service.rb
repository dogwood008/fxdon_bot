# frozen_string_literal: true

require 'singleton'
require 'oanda_api'
require 'json'

class FxService
  include Singleton
  class TokenNotGivenError < StandardError; end
  class AccountNotGivenError < StandardError; end

  JSON_EXTREACT_REGEX = /\n(\{.+?})/m

  def initialize
    client
  end

  def prices
    client.prices(instruments: instruments).get.first
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
    client.account(account).position(instrument).get
  rescue OandaAPI::RequestError => e
    message = parse_error_message(e.message)
    if message[:code] == 14 && message[:message] == 'Position not found'
      nil
    else
      raise RuntimeError, e.message
    end
  end

  def close
    return if position.nil?
    client.account(account).position(instrument).close
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

  def parse_error_message(message)
    json = message.match(JSON_EXTREACT_REGEX) { $1 }
    JSON.parse(json, symbolize_names: true)
  end
end
