require 'lagomorph/queue_adapter'
require 'lagomorph/json_parser'
require 'securerandom'

module Lagomorph
  class RpcCall

    def initialize(session)
      @session = session
      @results = {}
      @mutex = Monitor.new
    end

    def dispatch(queue_name, method, *params)
      @queue_name = queue_name

      correlation_id = calculate_correlation_id
      @mutex.synchronize do
        @results[correlation_id] = ::Queue.new
      end

      prepare_channel
      payload = prepare_payload(method, *params)
      publish_rpc_call(payload, correlation_id)
      response = block_till_receive_response(correlation_id)

      if response.key?('result')
        response['result']
      else
        fail(RpcError, response.fetch('error', 'Unknown error'))
      end
    end

    def close_channel
      return unless @prepared_channel
      @channel.close
      @prepared_channel = false
    end

    private

    def prepare_channel
      return if @prepared_channel

      @channel = @session.create_channel(1)

      @exchange    = @channel.default_exchange
      @reply_queue = QueueBuilder.new(@channel).reply_queue

      listen_for_responses

      @prepared_channel = true
    end

    def publish_rpc_call(request, correlation_id)
      @exchange.publish(request, routing_key:    @queue_name,
                                 correlation_id: correlation_id,
                                 reply_to:       @reply_queue.name
      )
    end

    def prepare_payload(method, *params)
      JsonParser.new.build_request(method, *params)
    end

    def calculate_correlation_id
      SecureRandom.uuid
    end

    def listen_for_responses
      @reply_queue.subscribe(block: false) do |metadata, payload|
        @results[metadata.correlation_id].push(payload)
      end
    end

    def block_till_receive_response(correlation_id)
      raw_response = @results[correlation_id].pop # blocks until can pop
      response = parse_response(raw_response)
      @results.delete(correlation_id)

      response
    end

    def parse_response(response)
      JsonParser.new.parse_response(response)
    end

  end
end