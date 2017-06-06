# frozen_string_literal: true

require 'json'
require 'singleton'
require 'aws-sdk'

class Sqs
  include Singleton

  def initialize
    raise NotImplementedError
  end

  def create_queue
    client.create_queue(queue_name: queue_name)
  end

  def queue_url
    @queue_url ||= client.get_queue_url(queue_name: queue_name)['queue_url']
  end

  def send_message(message_body)
    client.send_message(queue_url: queue_url,
                        message_body: message_body.to_json)
  end

  def receive_message
    client.receive_message(queue_url: queue_url)
  end

  private

  def queue_name
    'default'
  end
end
