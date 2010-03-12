class RackPanel::Server < Sinatra::Base
  Mapping = RackPanel::Mapping
  set :root, File.dirname(__FILE__)
  Public = File.expand_path(File.dirname(__FILE__) + '/public')

  helpers do
     include Rack::Utils
    def url(*path_parts)
      [ path_prefix, path_parts ].join("/").squeeze('/')
    end
    alias_method :u, :url

    def path_prefix
      request.env['SCRIPT_NAME']
    end
  end
  
  get('/?') do
    @mappings = Mapping.all
    haml :index
  end
  
  get('/jquery.js') do
    open(Public+'/jquery.js').read
  end
  
  post('/mappings/?') do
    mapping = Mapping.create(params[:mapping])
    Mapping.read
    haml :mapping, :locals => {:mapping => mapping}, :layout => false
  end
  
  delete('/mappings/:id/?') do |id|
    Mapping.delete(id)
    Mapping.read
    status 200
  end
  
  put('/mappings/:id/?') do |id|
    @mapping = Mapping[id.to_i]
    @mapping.url_base = params[:url_base] if params[:url_base]
    @mapping.object_path = params[:object_path] if params[:object_path]
    Mapping.persist
    Mapping.read
    status 200
  end
end