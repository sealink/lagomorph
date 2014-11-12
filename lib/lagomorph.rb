require 'lagomorph/version'

module Lagomorph

  def self.using_march_hare?
    using? 'march_hare'
  end


  def self.using_bunny?
    using? 'bunny'
  end


  private

  def self.using?(gem_name)
    !Gem.loaded_specs[gem_name].nil?
  end

end

if Lagomorph.using_bunny?
  require 'bunny'
else
  require 'march_hare'
end

require 'lagomorph/session'
require 'lagomorph/subscriber'
require 'lagomorph/supervisor'
require 'lagomorph/worker'
require 'lagomorph/rpc_call'
require 'lagomorph/exceptions'
