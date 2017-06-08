# frozen_string_literal: true

require_relative '../sqs'

class Sqs::FakeSqs < Sqs
  def initialize
    client
    create_queue
  end

  private

  def client
    @sqs_client ||= Aws::SQS::Client.new(
      endpoint:          'http://localhost:4568',
      secret_access_key: 'secret access key',
      access_key_id:     'access key id',
      region:            'region'
    )
  end
end
