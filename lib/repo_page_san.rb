require 'erb'

module RepoPageSan
  class Page
    attr_reader :template
    
    def initialize(template)
      @template = template
    end
    
    def render(spec)
      ERB.new(File.read(@template)).result(binding)
    end
  end
end