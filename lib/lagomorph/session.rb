module Lagomorph
  class Session

    CONNECTION_PARAM_KEYS = [
      :host,
      :heartbeat_interval,
      :username,
      :password,
      :port
    ]


    def self.connect(connection_params)
      new(connection_params).tap(&:open_connection)
    end


    def initialize(connection_params)
      @connection_params = connection_params.select { |key,_|
        CONNECTION_PARAM_KEYS.include?(key)
      }
      @channels = []
    end

    def open_connection
      @connection ||= if Lagomorph.using_bunny?
                        ::Bunny.new(@connection_params).tap(&:start)
                      else
                        ::MarchHare.connect(@connection_params)
                      end
    end

    def close_connection
      @connection.close if !@connection.nil?
    end

    def create_channel(prefetch = nil)
      channel = @connection.create_channel
      @channels << channel
      if Lagomorph.using_bunny?
        channel.prefetch(prefetch)
      else
        channel.prefetch = prefetch
      end
      channel
    end

  end
end