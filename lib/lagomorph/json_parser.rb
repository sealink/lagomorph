require 'json'

module Lagomorph
  class JsonParser
    def parse_request(payload)
      request_message = JSON.parse(payload)
      method          = request_message.fetch('method')
      params          = request_message.fetch('params', [])
      return method, params
    end

    def parse_response(response)
      JSON.parse(response)
    end

    def build_request(method, *params)
      JSON.generate('method' => method, 'params' => params)
    end

    def build_response(result)
      JSON.generate('result' => result)
    end

    def build_error(error)
      JSON.generate('error' => error)
    end
  end
end
