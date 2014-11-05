require 'spec_helper'
require 'lagomorph/session'
require 'lagomorph/supervisor'
require 'lagomorph/subscriber'
require 'lagomorph/rpc_call'

describe 'a Lagomorph RPC process' do

  class PongWorker
    def pong
      'pong'
    end

    def echo(request)
      request
    end
  end

  context 'when supervising a PongWorker on the ping queue' do
    let(:connection_params) {
      {
        host:     '172.28.128.3',
        username: 'elasticsearch',
        password: 'asecretpassword'
      }
    }

    let(:session) { Lagomorph::Session.connect(connection_params) }

    let(:supervisor) { Lagomorph::Supervisor.new(session) }

    let(:queue) { 'ping' }

    before do
      supervisor.route queue, PongWorker
    end

    context 'when a pong rpc call is made on the ping queue' do
      let(:result) { Lagomorph::RpcCall.new(session).dispatch(queue, 'pong') }
      it { expect(result).to eq 'pong' }
    end

    context 'when an echo rpc call is made on the ping queue' do
      let(:result) { Lagomorph::RpcCall.new(session).dispatch(queue, 'echo', 'test') }
      it { expect(result).to eq 'test' }
    end

    after do
      session.close_connection
    end
  end

end
