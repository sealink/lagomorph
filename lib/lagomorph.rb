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
  puts "Using bunnies in an obscene way"
  require 'bunny'
else
  puts "Marching hares"
  require 'march_hare'
end
