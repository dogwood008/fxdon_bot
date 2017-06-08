# frozen_string_literal: true

require 'singleton'

class QueueService
  include Singleton

  def initilize
    sqs
  end

  def push(order)
    sqs.send_message(order)
  end
  alias :<< :push

  def list_queues
    sqs.list_queues
  end

  def fetch_all
    all_messages = []
    until (messages = sqs.receive_messages.messages).empty? do
      all_messages << messages
    end
    all_messages.flatten.map do |m|
      Order.create_from_json(m.body)
    end
  end

  def fetch_and_purge_all
    messages = fetch_all
    purge_all
    messages
  end

  private

  def purge_all
    sqs.purge_queue
  end

  def sqs
    @sqs ||= Sqs::FakeSqs.instance
  end
end
