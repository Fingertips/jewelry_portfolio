require 'jewelry_portfolio'

# Add the JewelryPortfolio `portfolio:release' Rake task so it's ran after the
# original `release' Rake task if it exists.
if defined?(Rake) && Rake::Task.task_defined?('release')
  task :release do
    Rake::Task['portfolio:release'].invoke
  end
end

class JewelryPortfolio
  class Tasks
    # The GitHub user account that this repo belongs to.
    attr_accessor :account
    
    # The name of the repo.
    attr_accessor :name
    
    # The version of the current version of the project.
    attr_accessor :version
    
    # The summary of the project.
    attr_accessor :summary
    
    # The description of the project.
    attr_accessor :description
    
    # Initialize the JewelryPortfolio rake tasks. The JewelryPortfolio::Tasks
    # instance is yielded so additional configuration can be performed.
    #
    # If the repo you're working in does _not_ contain a +gemspec+ file, then
    # you'll need to assign all values to the Repo yourself.
    #
    #   JewelryPortfolio::Tasks.new do |t|
    #     t.account     = 'Fingertips'
    #     t.name        = 'passengerpane'
    #     t.version     = '1.2.0'
    #     t.summary     = 'A short summary about the project.'
    #     t.description = 'A longer description about the project.'
    #   end
    def initialize
      @account = github_username
      yield self if block_given?
      define
    end
    
    private
    
    def define
      namespace :portfolio do
        desc "Generate the HTML"
        task :generate do
          portfolio.render!
          sh "open '#{File.join(portfolio.index.path, 'index.html')}'"
        end
        
        desc "Generates the HTML and commits and pushes the new release"
        task :release do
          portfolio.release!
        end
      end
    end
    
    def portfolio
      unless @account
        raise ArgumentError, "Unable to determine `account'. Add a github user entry to your global, or local, git config. Or explicitely set the `account' on the JewelryPortfolio::Tasks instance."
      end
      @portfolio ||= JewelryPortfolio.new(@account, (repo if repo.valid?))
    end
    
    def repo
      unless @repo
        @repo = Repo.new(account, gemspec)
        %w{ account name version summary description }.each do |attr|
          if value = send(attr)
            @repo.send("#{attr}=", send(attr))
          end
        end
      end
      @repo
    end
    
    def gemspec
      if spec_file = Dir.glob('*.gemspec').first
        spec = eval(File.read(spec_file))
      end
    end
    
    def github_username
      Git.open('.').config['github.user']
    end
  end
end