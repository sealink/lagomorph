module Lagomorph
  class Supervisor

    def initialize(session)
      @session = session
    end

    def route(queue_name, worker_class, options = {})
      prefetch          = 1
      durable           = false

      channel = @session.create_channel(prefetch)
      queue   = channel.queue(queue_name, durable: durable)

      call = options.fetch(:call)

      puts "Listening with #{prefetch} prefetch on <#{queue_name}>."

      # Bunny block params => |delivery_info, properties, payload|
      # March Hare block params => |metadata, payload|
      QueueAdapter.new(queue).subscribe(manual_ack: true, block: false) do |metadata, payload|
        puts "Got message. Q: #{queue_name} => #{payload}"
        worker = worker_class.new
        response = worker.send(call)
        channel.ack(metadata.delivery_tag)
        publish_response(channel, metadata, response)
      end
    end

    def publish_response(channel, metadata, payload)
      channel.default_exchange.publish(payload,
                                       routing_key:    metadata.reply_to,
                                       correlation_id: metadata.correlation_id)
    end

    def dismiss

    end

  end
end