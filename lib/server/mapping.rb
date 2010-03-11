require 'enumerator'

class RackPanel::Mapping
  attr_accessor :url_base, :object_path, :id

  class << self; 
    attr_reader :mappings 
    alias all mappings
  end

  def self.config_file_path
    "rack_panel.urlmap.yml"
  end

  def self.read
    raw = YAML.load(open(config_file_path).read)
    
    @mappings = {}
    raw.each do |id, (url_base, object_path)|
      @mappings[id] = new(url_base, object_path, id)
    end
    remap
  end
  
  def self.[](id)
    @mappings[id]
  end
  
  def self.init
    unless File.exist?(config_file_path)
      FileUtils.touch(config_file_path) 
      File.open(config_file_path, 'w+') do |file|
        file.write({Time.now.to_i.to_s => ['/rack_panel/url_map', RackPanel::Server.to_s]}.to_yaml)
      end
    end
    read
  end
  
  def self.remap
    map = {}
    each do |id, mapping|
      map[mapping.url_base] = eval(mapping.object_path)
    end
    RackPanel.application.remap(map)
  end
  
  def self.each(&block)
    @mappings.each(&block)
  end
  
  def self.persist
    hash = {}
    @mappings.each do |id, mapping|
      hash[id] = mapping.to_yaml
    end
    File.open(config_file_path, 'w+') do |file|
      file.write(hash.to_yaml)
    end
  end
  
  def self.delete(id)
    @mappings.delete(id.to_i); persist
    self
  end
    
  def self.create(params={})
    new("/url_base", "nil").save
  end
    
  def initialize(url_base, object_path, id=Time.now.to_i)
    @url_base, @object_path, @id = url_base, object_path, id
  end
  
  def to_yaml
    [url_base, object_path]
  end
  
  def save
    self.class.mappings[id] = self
    self.class.persist
    self.class.remap
    self
  end
  
end