require 'lagomorph/metadata_adapter'

module Lagomorph
  QueueAdapter = Struct.new(:queue) do

    def subscribe(options = {}, &block)
      if Lagomorph.using_bunny?
        queue.subscribe(options) do |delivery_info, properties, payload|
          metadata = MetadataAdapter.new(delivery_info, properties)
          block.call(metadata, payload)
        end
      else
        queue.subscribe(options, &block)
      end
    end

  end
end