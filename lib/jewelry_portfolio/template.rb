require 'erb'

class JewelryPortfolio
  class Template
    attr_reader :template, :specs, :view_path
    
    def initialize(template, specs)
      template   = File.expand_path(template)
      @view_path = File.dirname(template)
      @template  = html_template_file(File.basename(template))
      @specs     = specs
    end
    
    def render
      erb @template, binding
    end
    
    def partial(partial_name, local_variables = {})
      for (var_name, var_value) in local_variables
        eval "#{var_name} = var_value"
      end
      erb html_template_file(partial_name), binding
    end
    
    def spec_partial(spec, local_variables = {})
      partial 'spec', local_variables.merge(:spec => spec)
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