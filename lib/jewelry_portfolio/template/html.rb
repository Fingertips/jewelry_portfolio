require 'erb'

class JewelryPortfolio
  class Template
    # This class is responsible for rendering a HTML template.
    class HTML < Template
      # Renders the HTML and returns the output.
      def render
        ERB.new(File.read(@file)).result(binding)
      end
    end
  end
end