class JewelryPortfolio
  class Repo
    attr_accessor :spec, :account
    
    def initialize(spec, account)
      @spec, @account = spec, account
    end
    
    def name
      @spec.name
    end
    
    def url
      "http://github.com/#{@account}/#{name}/tree/master"
    end
    
    def clone_url
      "git://github.com/#{@account}/#{name}.git"
    end
    
    def gem_name
      "#{@account}-#{name}"
    end
    
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