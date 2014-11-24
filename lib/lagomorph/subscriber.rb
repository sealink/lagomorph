require 'lagomorph/json_parser'

module Lagomorph
  class Subscriber

    def initialize(worker_class)
      @worker_class = worker_class
    end

    def subscribe(queue, channel, opts={})
      subscription_opts = opts.merge(durable:    true,
                                     manual_ack: true,
                                     block:      false)
      queue.subscribe(subscription_opts) do |metadata, payload|
        response = process_request(payload)
        channel.ack(metadata.delivery_tag)
        publish_response(channel, metadata, response)
      end
    end


    private

    def process_request(request)
      method, params = parse_request(request)
      result = @worker_class.new(method, *params).work
      build_response(result)
    rescue => e
      build_error(e.message)
    end

    def publish_response(channel, metadata, payload)
      channel.default_exchange.publish(payload,
                                       routing_key:    metadata.reply_to,
                                       correlation_id: metadata.correlation_id)
    end

    def parse_request(payload)
      JsonParser.new.parse_request(payload)
    end

    def build_response(result)
      JsonParser.new.build_response(result)
    end

    def build_error(error)
      JsonParser.new.build_error(error)
    end

  end
end
