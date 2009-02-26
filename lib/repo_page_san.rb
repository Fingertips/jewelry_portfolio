require 'erb'
require 'git'
require 'net/http'
require 'rubygems/specification'
require 'tempfile'
require 'yaml'

module RepoPageSan
  class ReposIndex
    attr_reader :account
    
    def initialize(account)
      @account = account
    end
    
    BRANCH = 'gh-pages'
    def branch; BRANCH end
    
    def url
      "git://github.com/#{@account}/#{repo_name}"
    end
    
    def path
      File.join(Dir.tmpdir, repo_name)
    end
    
    def repo_name
      "#{@account}.github.com.git"
    end
    
    def pages_repo
      unless @pages_repo
        if File.exist?(path)
          @pages_repo = Git.open(path)
        else
          puts "Cloning `#{url}'"
          @pages_repo = Git.clone(url, repo_name, :path => File.dirname(path))
        end
      end
      @pages_repo
    end
    
    def repos
      #@repos ||= YAML.load(get)
    end
    
    def to_yaml
      repos.to_yaml
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