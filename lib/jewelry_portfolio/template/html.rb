require 'erb'

class JewelryPortfolio
  class Template
    # This class is responsible for rendering a HTML template.
    class HTML < Template
      # Returns the repos ordered by name.
      def repos
        super.sort_by { |r| r.name }
      end
      
      # Renders the HTML and returns the output.
      def render
        ERB.new(File.read(@file)).result(binding)
      end
    end
  end
end