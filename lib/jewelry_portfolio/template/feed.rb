require "builder"
require "rss"

class JewelryPortfolio
  class Template
    # This class is responsible for rendering a HTML template.
    class Feed < Template
      # The Builder::XmlMarkup instance.
      attr_reader :xml
      
      # Returns the repos ordered by +updated_at+ then +version+.
      #
      # See JewelryPortfolio::Repo#<=>
      def repos
        super.sort
      end
      
      # Renders the HTML and returns the output.
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