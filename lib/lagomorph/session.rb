module Lagomorph
  class Session

    attr_reader :connection

    CONNECTION_PARAM_KEYS = [
      :host,
      :heartbeat_interval,
      :user,
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
      @mutex = Monitor.new
    end

    def open_connection
      @mutex.synchronize do
        @connection ||= if Lagomorph.using_bunny?
                          ::Bunny.new(@connection_params).tap(&:start)
                        else
                          ::MarchHare.connect(@connection_params)
                        end
      end
    end

    def close_connection
      return if @connection.nil? || @connection.closed?
      @mutex.synchronize do
        @connection.close
      end
    end

    def create_channel(prefetch = nil)
      @mutex.synchronize do
        channel = @connection.create_channel
        if Lagomorph.using_bunny?
          channel.prefetch(prefetch)
        else
          channel.prefetch = prefetch
        end
        channel
      end
    end

  end
end
