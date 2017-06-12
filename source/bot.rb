# frozen_string_literal: true

require_relative './setting'
require_relative './order/buy'
require_relative './order/sell'
require_relative './sqs/fake_sqs'
require_relative './service/fx_service'
require_relative './service/queue_service'

require 'dotenv/load'
require 'pp'

class Bot
  TOOT_EXTRACT_REGEX =
    /<p><span class="h-card"><a href="https?:\/\/[\S]+" class="u-url mention">@<span>fxdon<\/span><\/a><\/span> (.+)<\/p>/

  def toot(message, option = {})
    client.create_status(message, option)
  end

  def reply(user, message, in_reply_to_id, in_reply_to_account_id)
    content = "@#{user} #{message}"
    option = { in_reply_to_id: in_reply_to_id,
               in_reply_to_account_id: in_reply_to_account_id }
    toot(content, option)
  end

  def user
    stream.user do |s|
      next unless s.is_a?(Mastodon::Notification)
      username = s.account.username
      content = extract_toot(s.status.content)
      original_toot_id = s.status.id
      original_toot_user_id = s.status.account.id
      allocate(username, content, original_toot_id, original_toot_user_id)
    end
  end

  def hashtag(tag)
    stream.hashtag(tag) do |s|
      pp s
    end
  end

  def firehose
    stream.firehose do |s|
      pp s
    end
  end

  private

  def allocate(username, content, original_toot_id, original_toot_user_id)
    split_content = content.sub('　', ' ').split(' ')
    command = split_content.shift
    case command
    when 'echo'
      echo(username, content.sub('echo ', ''), original_toot_id, original_toot_user_id)
    when *Order.all_verbs
      order(username, command, original_toot_id, original_toot_user_id)
    else
      help(username, original_toot_id, original_toot_user_id)
    end
  end

  def help(username, original_toot_id, original_toot_user_id)
    content = "\nコマンド書式:\n　@fxdon コマンド\nコマンド一覧\n　・buy/ask/買い/買 USDを成行で購入します。\n　・sell/bid/売り/売 USDを成行で売却します。"
    reply(username, content, original_toot_id, original_toot_user_id)
  end

  def echo(username, content, original_toot_id, original_toot_user_id)
    reply(username, content, original_toot_id, original_toot_user_id)
  end

  def order(username, command, original_toot_id, original_toot_user_id)
    order = case command
            when *Order::Buy.verbs
              Order::Buy.new(nil, nil)
            when *Order::Sell.verbs
              Order::Sell.new(nil, nil)
            else
              raise Order::SellOrBuyNotGivenError
            end
    queue_service.push(order)
    reply(username, '注文します: ' + command, original_toot_id, original_toot_user_id)
  end

  def setting
    @setting ||= Setting.new
  end

  def client
    @client ||= Mastodon::REST::Client.new(base_url: setting.base_url,
                                           bearer_token: setting.access_token)
  end

  def stream
    @stream ||= Mastodon::Streaming::Client.new(base_url: setting.api_base_url,
                                                bearer_token: setting.access_token)
  end

  def extract_toot(content)
    content.match(TOOT_EXTRACT_REGEX) { $1 }
  end

  def queue_service
    QueueService.instance
  end
end
