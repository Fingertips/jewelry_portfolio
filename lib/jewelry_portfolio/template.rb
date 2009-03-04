require 'erb'

class JewelryPortfolio
  # This class is responsible for rendering a template.
  class Template
    # The full path to the template file.
    attr_reader :template
    
    # The directory in which the template resides.
    attr_reader :view_path
    
    # The array of JewelryPortfolio::Repo instances.
    attr_reader :repos
    
    # Initialize with the path to the +template+, minus the extensions, and an
    # array of JewelryPortfolio::Repo instances as +repos+.
    def initialize(template, repos)
      template   = File.expand_path(template)
      @view_path = File.dirname(template)
      @template  = html_template_file(File.basename(template))
      @repos     = repos.to_a
    end
    
    # Renders the template and returns the output.
    def render
      erb @template, binding
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