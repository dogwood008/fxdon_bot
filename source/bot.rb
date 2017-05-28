require_relative './client'
require 'dotenv/load'

client = Client.new
client = Mastodon::REST::Client.new(base_url: ENV['MASTODON_URL'],
                                    bearer_token: ENV['MASTODON_ACCESS_TOKEN'])


## messageに定期トゥートする文言を設定
message = ("test toot")
response = client.create_status(message)

## 結果の出力
pp response
