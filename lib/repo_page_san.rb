require 'erb'
require 'net/http'
require 'yaml'
require 'rubygems/specification'

module RepoPageSan
  class GitHubAccount
    attr_reader :login, :token
    
    PAGE_URL = 'https://github.com/%s/%s.github.com'
    
    def initialize(login, token)
      @login, @token = login, token
    end
    
    def pages_url
      PAGE_URL % [@login, @login]
    end
  end
  
  class ReposIndex
    attr_reader :account
    
    def initialize(account)
      @account = account
    end
    
    BRANCH = 'gh-pages'
    def branch; BRANCH end
    
    def url
      "#{@account.pages_url}/blob/#{branch}/repos.yml"
    end
    
    def get_url
      "#{@account.pages_url}/raw/#{branch}/repos.yml"
    end
    
    def get
      @repos_yml ||= Net::HTTP.get(URI.parse(get_url))
    end
    
    def repos
      @repos ||= YAML.load(get)
    end
  end
  
  class Repo
    attr_reader :spec_path
    
    def initialize(spec_path)
      @spec_path = spec_path
    end
    
    def raw_spec
      @raw_spec ||= File.read(@spec_path)
    end
    
    def spec
      @spec ||= eval(raw_spec)
    end
    
    def ==(other)
      other.is_a?(Repo) && spec.name == other.spec.name
    end
    
    def yaml_initialize(tag, values) # :nodoc:
      @raw_spec = values['spec']
    end
    
    def to_yaml(options = {}) # :nodoc:
      YAML.quick_emit(object_id, options) do |out|
        out.map(taguri, to_yaml_style) do |map|
          map.add 'spec', raw_spec
        end
      end
    end
  end
  
  class Template
    attr_reader :template, :specs
    
    def initialize(template, specs)
      @template, @specs = html_template_filename(template), specs
    end
    
    def render
      erb @template, binding
    end
    
    def partial(partial_name, local_variables = {})
      for (var_name, var_value) in local_variables
        eval "#{var_name} = var_value"
      end
      erb html_template_file(partial_name), binding
    end
    
    def spec_partial(spec, local_variables = {})
      partial 'spec', local_variables.merge(:spec => spec)
    end
    
    def view_path
      @view_path ||= File.dirname(File.expand_path(@template))
    end
    
    private
    
    def erb(file, binding)
      ERB.new(File.read(file)).result(binding)
    end
    
    def html_template_filename(name)
      "#{name}.html.erb"
    end
    
    def html_template_file(name)
      File.join(view_path, html_template_filename(name))
    end
  end
end