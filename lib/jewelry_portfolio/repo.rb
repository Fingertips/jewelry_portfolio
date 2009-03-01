class JewelryPortfolio
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
    
    def inspect
      "#<#{self.class.name} name=\"#{name}\">"
    end
  end
end