module RepoPageSan
  class Page
    attr_reader :template
    
    def initialize(template)
      @template = template
    end
  end
end