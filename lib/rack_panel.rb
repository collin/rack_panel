require 'fileutils'
require 'pathname'
require 'sinatra'
require 'haml'
module RackPanel
  def self.root
    @root ||= Pathname.new(__FILE__).dirname.expand_path
  end
  require root+'server/mapping'
  require root+'server/server'
  
  class << self
    attr_accessor :application
  end
  
  def self.boot!(builder)
    @application = Rack::URLMap.new({})
    Mapping.init
    builder.run @application
  end
end