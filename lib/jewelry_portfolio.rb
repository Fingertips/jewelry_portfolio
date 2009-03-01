require 'erb'
require 'git'
require 'rubygems/specification'
require 'tempfile'
require 'yaml'

class JewelryPortfolio
  class FileMissingError < StandardError; end
  
  attr_reader :account, :spec, :index, :template
  
  def initialize(account, options = {})
    @account  = account
    @spec     = options[:spec]
    @index    = ReposIndex.new(@account, options[:work_directory])
    @template = Template.new(File.join(@index.path, 'template'), @index.specs)
    
    @index.add(@spec) if @spec
  end
  
  def render!
    puts "Generating html"
    File.open(File.join(@index.path, 'index.html'), 'w') { |f| f << @template.render }
  end
  
  def release!
    render!
    @index.commit! commit_message
    @index.push!
  end
  
  private
  
  def commit_message
    if @spec
      "Updated github pages for: #{@spec.name}-#{@spec.version}"
    else
      "Re-generated github pages"
    end
  end
  
  class ReposIndex
    attr_reader :account
    
    def initialize(account, custom_work_directory = nil)
      @account, @custom_work_directory = account, custom_work_directory
    end
    
    def url
      "git@github.com:#{@account}/#{repo_name}"
    end
    
    def path
      @path ||= @custom_work_directory || File.join(Dir.tmpdir, repo_name)
    end
    
    def repo_name
      @repo_name ||= "#{@account}.github.com.git"
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
      puts "Pushing branch `gh-pages' to remote `#{url}'"
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
      (File.exist?(path) ? open_existing_repo! : open_new_repo!) unless @pages_repo
    end
    
    def open_existing_repo!
      @pages_repo = Git.open(path)
      unless @custom_work_directory
        puts "Pulling `#{url}'"
        @pages_repo.checkout('gh-pages')
        @pages_repo.pull('origin', 'gh-pages')
      end
    end
    
    def open_new_repo!
      puts "Cloning `#{url}'"
      @pages_repo = Git.clone(url, repo_name, :path => File.dirname(path))
      @pages_repo.checkout('origin/gh-pages')
      branch = @pages_repo.branch('gh-pages')
      branch.create
      branch.checkout
      @pages_repo.config('branch.gh-pages.remote', 'origin')
      @pages_repo.config('branch.gh-pages.merge', 'refs/heads/gh-pages')
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
    attr_reader :template, :specs, :view_path
    
    def initialize(template, specs)
      template   = File.expand_path(template)
      @view_path = File.dirname(template)
      @template  = html_template_file(File.basename(template))
      @specs     = specs
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
    
    private
    
    def erb(file, binding)
      ERB.new(File.read(file)).result(binding)
    end
    
    def html_template_file(name)
      path = File.join(view_path, "#{name}.html.erb")
      raise FileMissingError, "Could not find template at path `#{path}'" unless File.exist?(path)
      path
    end
  end
end