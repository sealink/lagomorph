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

    context 'with tasks of varying completion time' do
      let!(:rpc_call) { Lagomorph::RpcCall.new(session) }
      let!(:results) { [] }

      before do
        supervisor.route queue, PongWorker, subscribers: number_subscribers
        [
          Thread.new { results << rpc_call.dispatch(queue, 'nap', 2) },
          Thread.new { results << rpc_call.dispatch(queue, 'nap', 1) }
        ].each(&:join)
      end

      context 'with only one subscriber' do
        let(:number_subscribers) { 1 }
        it 'will return results in the order dispatched' do
          expect(results).to eq [2, 1]
        end
      end

      context 'with multiple subscribers' do
        let(:number_subscribers) { 2 }
        it 'will return results from the faster task first' do
          expect(results).to eq [1, 2]
        end
      end

      after do
        rpc_call.close_channel
        session.close_connection
      end
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
            calls_per_thread.times.map { |call_index|
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
