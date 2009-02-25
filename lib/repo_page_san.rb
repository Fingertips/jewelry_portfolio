require 'erb'

class RepoPageSan
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
    @template, @specs = "#{template}.html.erb", specs
  end
  
  def render
    erb @template, binding
  end
  
  def partial(name, local_variables)
    partial = File.join(view_path, "#{name}.html.erb")
    erb partial, PartialBinding.new(local_variables).binding
  end
  
  def spec_partial(spec, local_variables = {})
    partial 'spec', local_variables.merge(:spec => spec)
  end
  
  def view_path
    @view_path ||= File.dirname(File.expand_path(@template))
  end
  
  private
  
  def erb(file, binding)
    ERB.new(File.read(file)).result(binding)
  end
end