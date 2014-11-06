# Lagomorph

RPC Messaging pattern using RabbitMQ

Lagomorph is a mammal of the order Lagomorpha, which comprises the hares, rabbits, and pikas.

It's also a gem that implements the RPC pattern over AMPQ using RabbitMQ.
In this case, it can work with either MRI (through the bunny gem) or jRuby 
(via the march_hare gem).

## Installation

Add this to your application's Gemfile if you're on jruby:

```ruby
gem 'march_hare'
gem 'lagomorph'
```

...and if you're on MRI, or rubinius:

```ruby
gem 'bunny'
gem 'lagomorph'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lagomorph

## Usage

Lagomorph tries to maintain a healthy distance from your code. It wants
you to be in control.

Let's say you have a complicated bit of work, that looks like this:

```ruby
  class PongWorker
    def ponger
      'pong'
    end
  end
```

Then, you could set it going in a super micro-service type of way with
this bootup:

```ruby
  connection_params = {} # passed along to RabbitMQ connect
  session    = Lagomorph::Session.connect(connection_params)
  supervisor = Lagomorph::Supervisor.new(session)
  supervisor.route 'ping', PongWorker

  trap("SIGINT") { puts "Bye!"; exit! }

  # Let the supervisor run in the background,
  # while the main thread does nothing
  sleep
```

Now to utilise this amazing service, we would use the rpc call client:

```ruby
  connection_params = {} # passed along to RabbitMQ connect
  session    = Lagomorph::Session.connect(connection_params)

  rpc_call = Lagomorph::RpcCall.new(session)
  result   = rpc_call.dispatch(queue, 'ponger')

  puts "The result should be 'pong'.  Is it: #{result}?"
```

## Contributing

1. Fork it ( https://bitbucket.org/team-sealink/lagomorph/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
