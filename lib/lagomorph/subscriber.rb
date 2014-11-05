require 'lagomorph/json_parser'

module Lagomorph
  class Subscriber

    def initialize(worker_class)
      @worker_class = worker_class
    end

    def subscribe(queue, channel)
      queue.subscribe(manual_ack: true, block: false) do |metadata, payload|
        result   = process_request(payload)
        response = build_response(result)
        channel.ack(metadata.delivery_tag)
        publish_response(channel, metadata, response)
      end
    end


    private

    def process_request(request)
      method, params = parse_request(request)
      @worker_class.new.send(method, *params)
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

  end
end