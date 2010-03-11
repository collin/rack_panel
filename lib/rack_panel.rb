require 'fileutils'
Bundler.require
module RackPanel  
  # require 'lib/application/application'
  require 'lib/server/mapping'
  require 'lib/server/server'
  
  class << self
    attr_accessor :application
  end
  
  def self.boot!(builder)
    @application = Rack::URLMap.new({})
    Mapping.init
    builder.run @application
  end
end