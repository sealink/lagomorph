module Lagomorph
  class Worker
    def initialize(method, *params)
      @method = method
      @params = params
    end

    def work
      send(@method, *@params)
    end
  end
end
