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
    
    # Renders a partial specified by +partial_name+ minus the extension. You
    # can optionally specify a hash of +local_variables+ which will be
    # available while rendering the partial.
    #
    # Consider a partial named <tt>foo.html.erb</tt>, in the same directory as
    # the template, containing the following:
    #
    #   Text: <%= text %>
    #
    # This partial can now be rendered like this:
    #
    #   partial('foo', :text => 'bar') # => "Text: bar"
    def partial(partial_name, local_variables = {})
      for (var_name, var_value) in local_variables
        eval "#{var_name} = var_value"
      end
      erb html_template_file(partial_name), binding
    end
    
    # Renders a partial for the specified +repo+. This method looks for a
    # partial file named <tt>repo.html.erb</tt> in the same directory as the
    # template.
    #
    # See partial for more info.
    def repo_partial(repo, local_variables = {})
      partial 'repo', local_variables.merge(:repo => repo)
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