require 'erb'

module RepoPageSan
  class Page
    class PartialBinding
      instance_methods.each { |meth| undef_method(meth) unless meth =~ /\A__|instance_eval/ }
      
      def initialize(local_variables)
        @local_variables = local_variables
        
        local_variables.each do |name, value|
          instance_eval %{
            def #{name}
              @local_variables[#{name.inspect}]
            end
          }
        end
      end
      
      public :binding
    end
    
    attr_reader :template, :specs
    
    def initialize(template, specs)
      @template, @specs = template, specs
    end
    
    def render
      erb @template, binding
    end
    
    def partial(name, local_variables)
      partial = File.join(template_dir, "#{name}.html.erb")
      erb partial, PartialBinding.new(local_variables).binding
    end
    
    private
    
    def template_dir
      File.dirname(@template)
    end
    
    def erb(file, binding)
      ERB.new(File.read(file)).result(binding)
    end
  end
end