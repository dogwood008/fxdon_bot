# frozen_string_literal: true
# ref: http://qiita.com/fjustin/items/afe21c00dc50c23cd109
require 'bundler/setup'
Bundler.require(:default)

require 'mastodon'
require 'highline/import'
require 'oauth2'
require 'dotenv'
require 'uri'

class Setting
  ##デフォルト環境の設定
  FULL_ACCESS_SCOPES = 'read write follow'.freeze

  def initialize
    Dotenv.load
    setup_env if env_already_set?
  end

  def app_name
    ENV['APP_NAME'] || 'fxdon'
  end

  def base_url
    ENV['MASTODON_URL']
  end

  def api_base_url
    ENV['MASTODON_API_URL']
  end

  def host
    URI.parse(base_url).host
  end

  def access_token
    ENV['MASTODON_ACCESS_TOKEN']
  end

  private

  def scopes
    ENV['MASTODON_SCOPES'] || FULL_ACCESS_SCOPES
  end

  def base_url=(base_url)
    ENV['MASTODON_URL'] = base_url
  end

  def env_already_set?
    !ENV['MASTODON_URL']&.empty? && !ENV['MASTODON_ACCESS_TOKEN']&.empty? &&
      !ENV['MASTODON_CLIENT_ID']&.empty? && !ENV['MASTODON_CLIENT_SECRET']&.empty?
  end

  def setup_env
    check_instance_and_url
    check_client_id
    check_access_token
  end

  def check_instance_and_url
    ##インスタンスとURLの確認
    if !base_url
      base_url = ask('Instance URL: ')
      File.open(".env","a+") do |f|
        f.write "MASTODON_URL = '#{base_url}'\n"
      end
    end
  end

  def check_client_id
    ##クライアントIDの確認
    if !ENV['MASTODON_CLIENT_ID'] || !ENV['MASTODON_CLIENT_SECRET']
      client = Mastodon::REST::Client.new(base_url: ENV['MASTODON_URL'])
      app = client.create_app(app_name, "urn:ietf:wg:oauth:2.0:oob", scopes)
      ENV['MASTODON_CLIENT_ID'] = app.client_id
      ENV['MASTODON_CLIENT_SECRET'] = app.client_secret
      File.open(".env","a+") do |f|
        f.write "MASTODON_CLIENT_ID = '#{ENV['MASTODON_CLIENT_ID']}'\n"
        f.write "MASTODON_CLIENT_SECRET = '#{ENV['MASTODON_CLIENT_SECRET']}'\n"
      end
    end
  end

  def check_access_token
    ##アクセストークンの確認（アカウントとパスワード）
    if !ENV['MASTODON_ACCESS_TOKEN']
      client = OAuth2::Client.new(ENV['MASTODON_CLIENT_ID'],
                                  ENV['MASTODON_CLIENT_SECRET'],
                                  site: ENV['MASTODON_URL'])
      login_id = ask('Your Account: ')
      password = ask('Your Password: ')
      token = client.password.get_token(login_id,password, scope: scopes)
      ENV['MASTODON_ACCESS_TOKEN'] = token.token
      File.open('.env','a+') do |f|
        f.write "MASTODON_ACCESS_TOKEN = '#{ENV['MASTODON_ACCESS_TOKEN']}'\n"
      end
    end
  end
end
