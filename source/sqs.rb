# frozen_string_literal: true

require 'json'
require 'singleton'
require 'aws-sdk'

class Sqs
  include Singleton
  # http://docs.aws.amazon.com/sdkforruby/api/Aws/SQS/Client.html#receive_message-instance_method
  MAX_NUMBER_OF_MESSAGES = 10.freeze

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

  def receive_messages(max_number_of_messages = MAX_NUMBER_OF_MESSAGES)
    client.receive_message(queue_url: queue_url,
                           max_number_of_messages: max_number_of_messages)
  end

  def purge_queue
    client.purge_queue(queue_url: queue_url)
  end

  private

  def queue_name
    'default'
  end
end
