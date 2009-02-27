require 'erb'
require 'git'
require 'rubygems/specification'
require 'tempfile'
require 'yaml'

class RepoPageSan
  class FileMissingError < StandardError; end
  
  attr_reader :account, :spec, :index, :template
  
  def initialize(account, spec)
    @account  = account
    @spec     = spec
    @index    = ReposIndex.new(@account)
    @template = Template.new(File.join(@index.path, 'template'), @index.specs)
  end
  
  def render!
    File.open(File.join(@index.path, 'index.html'), 'w') { |f| f << @template.render }
  end
  
  def release!
    render!
    @index.commit! "Updated github pages for `#{@spec.name} #{@spec.version}'"
    @index.push!
  end
  
  class ReposIndex
    attr_reader :account
    
    def initialize(account)
      @account = account
    end
    
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
      load_pages_repo!
      @pages_repo
    end
    
    def repos_file
      File.join(path, 'repos.yml')
    end
    
    def specs
      unless @specs
        load_pages_repo!
        @specs = File.exist?(repos_file) ? YAML.load(File.read(repos_file)) : []
      end
      @specs
    end
    
    def repos
      specs.map { |spec| Repo.new(spec) }
    end
    
    def add(spec)
      if old_spec = specs.find { |s| s.name == spec.name }
        specs[specs.index(old_spec)] = spec
      else
        specs << spec
      end
      update_repos_file!
    end
    
    def commit!(message)
      pages_repo.add
      pages_repo.commit(message)
    end
    
    def push!
      pages_repo.push('origin', 'gh-pages')
    end
    
    def to_yaml
      specs.to_yaml
    end
    
    private
    
    def update_repos_file!
      File.open(repos_file, 'w') { |f| f << to_yaml }
    end
    
    def load_pages_repo!
      unless @pages_repo
        if File.exist?(path)
          @pages_repo = Git.open(path)
          @pages_repo.checkout('gh-pages')
          @pages_repo.pull('origin', 'gh-pages')
        else
          puts "Cloning `#{url}'"
          @pages_repo = Git.clone(url, repo_name, :path => File.dirname(path))
          @pages_repo.checkout('origin/gh-pages')
          branch = @pages_repo.branch('gh-pages')
          branch.create
          branch.checkout
        end
      end
    end
  end
  
  class Repo
    attr_accessor :spec
    
    def initialize(spec)
      @spec = spec
    end
    
    def name
      @spec.name
    end
    
    def ==(other)
      other.is_a?(Repo) && name == other.name
    end
  end
  
  class Template
    attr_reader :template, :specs
    
    def initialize(template, specs)
      @template, @specs = html_template_filename(template), specs
      raise FileMissingError, "Could not find template at path `#{@template}'" unless File.exist?(@template)
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