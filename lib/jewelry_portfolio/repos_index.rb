require 'git'
require 'rubygems/specification'
require 'tempfile'
require 'yaml'

class JewelryPortfolio
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
      specs.map { |spec| Repo.new(spec, @account) }
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
        @pages_repo.fetch('origin')
        @pages_repo.merge('origin/gh-pages')
      end
    end
    
    def open_new_repo!
      puts "Cloning `#{url}'"
      @pages_repo = Git.clone(url, repo_name, :path => File.dirname(path))
      @pages_repo.checkout('origin/gh-pages')
      branch = @pages_repo.branch('gh-pages')
      branch.create
      branch.checkout
    end
  end
end