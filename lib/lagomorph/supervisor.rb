require 'lagomorph/queue_builder'
require 'lagomorph/json_parser'

module Lagomorph
  class Supervisor
    def initialize(session)
      @session = session
    end

    def route(queue_name, worker_class, options = {})
      prefetch    = options.fetch :prefetch,    1
      durable     = options.fetch :durable,     false
      subscribers = options.fetch :subscribers, 1

      subscribers.times.map do
        channel = @session.create_channel(prefetch)
        queue   = QueueBuilder.new(channel).queue(queue_name, durable: durable)

        Subscriber.new(worker_class).subscribe(queue, channel)
      end
    end
  end
end
