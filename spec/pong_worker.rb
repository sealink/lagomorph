class PongWorker < Lagomorph::Worker
  def pong
    'pong'
  end

  def echo(request)
    request
  end

  def nap(how_long)
    sleep how_long
    how_long
  end

  def generate_failure
    fail 'Could not process request'
  end
end

