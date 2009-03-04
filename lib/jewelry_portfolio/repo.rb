class JewelryPortfolio
  class Repo
    class InvalidError < StandardError; end
    
    # The GitHub user account that this repo belongs to.
    attr_accessor :account
    
    # The name of the repo.
    #
    # Not needed when initialized with a Gem::Specification.
    attr_accessor :name
    
    # The version of the current version of the project.
    #
    # Not needed when initialized with a Gem::Specification.
    attr_accessor :version
    
    # The summary of the project.
    #
    # Not needed when initialized with a Gem::Specification.
    attr_accessor :summary
    
    # The description of the project.
    #
    # Not needed when initialized with a Gem::Specification.
    attr_accessor :description
    
    # The Time at which this Repo was last updated.
    attr_reader :updated_at
    
    def initialize(account = nil, spec = nil)
      @account = account
      @gem = !spec.nil?
      
      if spec
        @updated_at = Time.utc(spec.date.year, spec.date.month, spec.date.day)
        %w{ name version summary description }.each do |attr|
          send("#{attr}=", spec.send(attr).to_s)
        end
      end
      
      @updated_at = Time.now unless @updated_at
    end
    
    # Returns whether or not there's a Ruby gem for this repo.
    def gem?
      @gem
    end
    
    # Returns the URL to the project page on GitHub.
    def url
      "http://github.com/#{@account}/#{name}/tree/master"
    end
    
    # Returns the public clone URL.
    def clone_url
      "git://github.com/#{@account}/#{name}.git"
    end
    
    # Returns the name of the gem file from GitHub, which is made up of the
    # account name and the gem name.
    def gem_name
      "#{@account}-#{@name}"
    end
    
    # Returns the command to install the gem. This is a helper for your views.
    def gem_install_command
      "sudo gem install #{gem_name} -s http://gems.github.com"
    end
    
    # Raises a JewelryPortfolio::Repo::InvalidError if any of: account, name,
    # version, summary, or description is +nil+.
    def valid?
      @account && @name && @version && @summary && @description
    end
    
    def hash
      @name.hash
    end
    
    def <=>(other)
      if (res = @updated_at <=> other.updated_at) != 0
        res
      else
        @version.split('.') <=> other.version.split('.')
      end
    end
    
    def ==(other)
      other.is_a?(Repo) && hash == other.hash
    end
    alias_method :eql?, :==
  end
end