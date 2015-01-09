require 'lagomorph/queue_adapter'
require 'lagomorph/metadata_adapter'

module Lagomorph
  QueueBuilder = Struct.new(:channel) do
    def queue(name, opts = {})
      QueueAdapter.new(channel.queue(name, opts))
    end

    # Build a reply queue
    def reply_queue
      queue('', exclusive: true)
    end
  end
end
