require 'spec_helper'
require 'lagomorph/supervisor'
require 'lagomorph/session'
require 'lagomorph/rpc_call'

describe 'a Lagomorph RPC process' do

  class PongWorker
    attr_reader :calls

    def self.calls
      @calls ||= 0
    end

    def self.record_call
      @calls = calls + 1
    end

    def pong
      self.class.record_call
      'pong'
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

    let(:session) { Lagomorph::Session.new(connection_params) }

    let(:supervisor) { Lagomorph::Supervisor.new(session) }

    let(:queue) { 'ping' }

    before do
      supervisor.route queue, PongWorker, call: :pong
    end

    context 'when an rpc call is made on the ping queue' do
      let(:result) { Lagomorph::RpcCall.new(session).dispatch('ping') }
      it { expect(result).to eq 'pong' }
      it { expect(PongWorker.calls).to eq 1 }
    end

    after do
      supervisor.dismiss
    end
  end

end
