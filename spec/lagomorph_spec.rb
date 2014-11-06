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

    context 'and we have an rpc call manager thingy' do
      let!(:rpc_call) { Lagomorph::RpcCall.new(session) }

      context 'when a pong rpc call is made on the ping queue' do
        let(:result) { rpc_call.dispatch(queue, 'pong') }
        it { expect(result).to eq 'pong' }
      end

      context 'when an echo rpc call is made on the ping queue' do
        let(:result) { rpc_call.dispatch(queue, 'echo', 'test') }
        it { expect(result).to eq 'test' }
      end
      after { rpc_call.close_channel }
    end

    context 'when using 8 threads, with one instance per thread' do
      let(:number_of_threads) { 8 }
      let(:total_calls) { 800 }
      let(:calls_per_thread) { (total_calls / number_of_threads).ceil }

      let(:rpc_calls) {
        1.upto(number_of_threads).map { Lagomorph::RpcCall.new(session) }
      }

      specify 'each thread will get the expected response' do
        rpc_calls.map do |rpc_call|
          Thread.new do
            thread_results = calls_per_thread.times.map { |call_index|
              rpc_call.dispatch(queue, 'echo', call_index).tap { |result|
                expect(result).to eq call_index
              }
            }
          end
        end.each(&:join)

        rpc_calls.each(&:close_channel)
      end
    end

    after do
      session.close_connection
    end
  end

end
