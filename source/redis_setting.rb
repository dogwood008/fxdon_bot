# frozen_string_literal: true

require 'redis'
require 'redis-objects'
require 'connection_pool'
require 'singleton'

class RedisSetting
  include Singleton

  def initialize(options = {})
    @redis_path = options[:redis_path]
    @redis_host = options[:redis_host]
    @redis_port = options[:redis_port].to_i
    @redis_db = options[:redis_db].to_i

    Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) do
      redis
    end
  end

  private

  def redis
    @redis ||= if @redis_path
                 Redis.new(path: @redis_path, db: redis_db)
               else
                 Redis.new(host: redis_host, port: redis_port, db: redis_db)
               end
  end

  def redis_host
    @redis_host ||= 'localhost'
  end

  def redis_port
    @redis_port ||= 6379
  end

  def redis_db
    @redis_port ||= 0
  end
end
