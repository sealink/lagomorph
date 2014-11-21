require 'spec_helper'

require 'yaml'
require 'lagomorph/session'
require 'lagomorph/supervisor'
require 'lagomorph/subscriber'
require 'lagomorph/rpc_call'
require 'lagomorph/exceptions'

require 'pong_worker'

describe 'a Lagomorph RPC process' do

  let(:rabbitmq_config) {
    YAML.load_file(
      File.join(File.expand_path(File.dirname(__FILE__)),'rabbitmq.yml')
    )
  }

  context 'when supervising a PongWorker on the ping queue' do
    let(:connection_params) {
      {
        host:     rabbitmq_config.fetch('host'),
        username: rabbitmq_config.fetch('username'),
        password: rabbitmq_config.fetch('password')
      }
    }

    let(:session) { Lagomorph::Session.connect(connection_params) }

    let(:supervisor) { Lagomorph::Supervisor.new(session) }

    let(:queue) { 'ping' }

    before do
      supervisor.route queue, PongWorker
    end

    let!(:rpc_call) { Lagomorph::RpcCall.new(session) }

    context 'when a pong rpc call is made on the ping queue' do
      let(:result) { rpc_call.dispatch(queue, 'pong') }
      it { expect(result).to eq 'pong' }
    end

    context 'when an echo rpc call is made on the ping queue' do
      let(:result) { rpc_call.dispatch(queue, 'echo', 'test') }
      it { expect(result).to eq 'test' }
    end

    context 'when a worker for an rpc call yields a nil result' do
      let(:result) { rpc_call.dispatch(queue, 'echo', nil) }
      it { expect(result).to eq nil }
    end

    context 'when a method which fails is made on the ping queue' do
      let(:result) { rpc_call.dispatch(queue, 'generate_failure') }
      it { expect { result }.to raise_error Lagomorph::RpcError,
                                            'Could not process request' }
    end

    after do
      rpc_call.close_channel
      session.close_connection
    end
  end

end
