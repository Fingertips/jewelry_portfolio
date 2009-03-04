require "builder"
require "rss"

class JewelryPortfolio
  class Template
    # This class is responsible for rendering a HTML template.
    class Feed < Template
      attr_reader :xml
      
      # Renders the HTML and returns the output.0
      def render(&block)
        output = ''
        
        @xml = Builder::XmlMarkup.new(:target => output, :indent => 2)
        @xml.instruct!
        @xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
          @xml.id      "http://fingertips.github.com"
          @xml.link    "rel" => "self", "href" => "http://fingertips.github.com"
          @xml.updated Time.now.iso8601
          @xml.author  { @xml.name "Fingertips" }
          
          @xml.title    "Code from Fingertips"
          @xml.subtitle "The Ruby libraries we have available as open-source projects"
          
          instance_eval(File.read(@file))
        end
      end
    end
  end
end