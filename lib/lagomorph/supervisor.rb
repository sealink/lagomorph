require 'lagomorph/queue_builder'
require 'lagomorph/json_parser'

module Lagomorph
  class Supervisor

    def initialize(session)
      @session = session
    end

    def route(queue_name, worker_class, options = {})
      prefetch    = options.fetch :prefetch,    10
      durable     = options.fetch :durable,     false
      subscribers = options.fetch :subscribers, 1

      channel = @session.create_channel(prefetch)
      queue   = QueueBuilder.new(channel).queue(queue_name, durable: durable)

      subscribers.times.map do
        Subscriber.new(worker_class).subscribe(queue, channel)
      end
    end

  end
end
