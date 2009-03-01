class JewelryPortfolio
  class Repo
    attr_accessor :spec, :account
    
    def initialize(spec, account)
      @spec, @account = spec, account
    end
    
    # Returns the name of the gem.
    def name
      @spec.name
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
      "#{@account}-#{name}"
    end
    
    # Returns the command to install the gem. This is a helper for your views.
    def gem_install_command
      "sudo gem install #{gem_name} -s http://gems.github.com"
    end
    
    def ==(other)
      other.is_a?(Repo) && name == other.name
    end
    
    def inspect
      "#<#{self.class.name} name=\"#{name}\">"
    end
  end
end