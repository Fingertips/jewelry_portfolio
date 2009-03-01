require 'jewelry_portfolio'

if defined?(Jeweler)
  class Jeweler
    alias_method :release_before_jewelry_portfolio, :release
    def release
      release_before_jewelry_portfolio
      Rake::Task['portfolio:release'].invoke
    end
  end
end

class JewelryPortfolio
  class Tasks
    attr_accessor :account
    
    def initialize
      yield self if block_given?
      
      @account ||= github_username
      unless @account
        raise ArgumentError, "Unable to determine `account'. Add a github user entry to your global, or local, git config. Or explicitely set the `account' on the JewelryPortfolio::Tasks instance."
      end
      
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
      if @portfolio.nil?
        if spec_file = Dir.glob('*.gemspec').first
          spec = eval(File.read(spec_file))
        end
        @portfolio = JewelryPortfolio.new(@account, spec)
      end
      @portfolio
    end
    
    def github_username
      Git.open('.').config['github.user']
    end
  end
end