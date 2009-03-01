require 'erb'

class JewelryPortfolio
  class Template
    attr_reader :template, :repos, :view_path
    
    def initialize(template, repos)
      template   = File.expand_path(template)
      @view_path = File.dirname(template)
      @template  = html_template_file(File.basename(template))
      @repos     = repos
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
    
    def repo_partial(repo, local_variables = {})
      partial 'repo', local_variables.merge(:repo => repo, :spec => repo.spec)
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