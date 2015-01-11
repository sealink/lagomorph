module Lagomorph
  MetadataAdapter = Struct.new(:delivery_info, :properties) do
    def delivery_tag
      delivery_info.delivery_tag
    end

    def reply_to
      properties.reply_to
    end

    def correlation_id
      properties.correlation_id
    end
  end
end
