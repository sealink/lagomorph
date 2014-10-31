require 'lagomorph/queue_adapter'

module Lagomorph
  class RpcCall

    def initialize(session)
      @session = session
      @results = Hash.new { |h, k| h[k] = ::Queue.new }
    end

    def dispatch(queue_name, payload = '')
      @queue_name = queue_name
      prepare_channel
      correlation_id = calculate_correlation_id
      publish_rpc_call(payload, correlation_id)
      response = block_till_receive_response(correlation_id)

      close_channel

      # response['result'] || (fail response.fetch('error'))
      response
    end


    private

    def prepare_channel
      return if @prepared_channel

      @channel = @session.create_channel(1)

      @exchange    = @channel.default_exchange
      @reply_queue = @channel.queue('', exclusive: true)

      listen_for_responses

      @prepared_channel = true
    end

    def close_channel
      @channel.close
      @prepared_channel = false
    end

    def publish_rpc_call(request, correlation_id)
      opts = {routing_key: @queue_name}
      properties =  {
        correlation_id: correlation_id,
        reply_to:       @reply_queue.name
      }

      #TODO: check if distinction needed
      if Lagomorph.using_bunny?
        opts.merge!(properties)
      else
        opts.merge!(properties: properties)
      end

      @exchange.publish(request, opts)

      puts " [.] Sent request to server..."
    end

    def calculate_correlation_id
      SecureRandom.uuid
    end

    def listen_for_responses
      QueueAdapter.new(@reply_queue).subscribe(block: false) do |metadata, payload|
        puts " [->] Received response from server..."
        @results[metadata.correlation_id].push(payload)
      end
    end

    def block_till_receive_response(correlation_id)
      raw_response = @results[correlation_id].pop # blocks until can pop
      # response     = JSON.parse(raw_response)
      response = raw_response
      @results.delete(correlation_id) # delete to avoid memory leak

      response
    end

  end
end