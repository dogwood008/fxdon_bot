# frozen_string_literal: true

require_relative '../sqs'

class Sqs::FakeSqs < Sqs
  def initialize
    client
    create_queue
  end

  def queue_url
    "#{ENV['FAKE_SQS_ENDPOINT']}/#{queue_name}"
  end

  private

  def client
    @sqs_client ||= Aws::SQS::Client.new(
      endpoint:          ENV['FAKE_SQS_ENDPOINT'] || 'http://localhost:4568',
      secret_access_key: 'secret access key',
      access_key_id:     'access key id',
      region:            'region'
    )
  end
end
