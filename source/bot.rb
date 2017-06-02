require_relative './setting'
require 'dotenv/load'

class Bot
  TOOT_EXTRACT_REGEX =
    /<p><span class="h-card"><a href="https?:\/\/[\S]+" class="u-url mention">@<span>fxdon<\/span><\/a><\/span> (.+)<\/p>/

  def toot(message)
    client.create_status(message)
  end

  def user
    stream.user do |s|
      next unless s.is_a?(Mastodon::Notification)
      username = s.account.username
      content = extract_toot(s.status.content)
      toot("@#{username} #{content}")
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
end
