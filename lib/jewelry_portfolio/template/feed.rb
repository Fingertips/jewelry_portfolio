require "builder"
require "rss"

class JewelryPortfolio
  class Template
    # This class is responsible for rendering a HTML template.
    class Feed < Template
      DEFAULT_ENTRY_PROC = lambda do |xml, repo|
        xml.entry do
          xml.id      "#{repo.url}##{repo.version}"
          xml.updated repo.updated_at.iso8601
          xml.title   "#{repo.name} #{repo.version}"
          xml.link    :href => repo.url
          xml.summary repo.summary
          xml.content repo.description
        end
      end
      
      # The title that should be used for the feed.
      #
      # This defaults to <tt>"Code from #{@account}"</tt>.
      attr_accessor :title
      
      # The description (+subtitle+) that should be used for the feed.
      #
      # This defaults to <tt>"The Ruby libraries, from #{@account}, available
      # as open-source projects"</tt>.
      attr_accessor :description
      
      # The proc that is used to render an entry in the feed for each repo. The
      # proc gets 2 arguments; the Builder::XmlMarkup instance and the
      # JewelryPortfolio::Repo instance to render the entry for.
      #
      # This defaults to DEFAULT_ENTRY_PROC.
      attr_accessor :entry
      
      def initialize(template_file, account, repos)
        super
        @entry = DEFAULT_ENTRY_PROC
        @title = "Code from #{@account}"
        @description = "The Ruby libraries, from #{@account}, available as open-source projects"
        load_template!
      end
      
      # Returns the repos ordered by +updated_at+ then +version+.
      #
      # See JewelryPortfolio::Repo#<=>
      def repos
        super.sort
      end
      
      # Returns the +id+ to be used for the feed.
      def feed_id
        "http://#{@account}.github.com/"
      end
      
      # Returns the URL to the feed.
      def feed_url
        "http://#{@account}.github.com/feed.xml"
      end
      
      # Renders the HTML and returns the output.
      def render(&block)
        output = ''
        
        xml = Builder::XmlMarkup.new(:target => output, :indent => 2)
        xml.instruct!
        xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
          xml.id      feed_id
          xml.link    "rel" => "self", "href" => feed_url
          xml.updated Time.now.iso8601
          xml.author  { xml.name @account }
          
          xml.title    @title
          xml.subtitle @description
          
          repos.each do |repo|
            @entry.call(xml, repo)
          end
        end
      end
      
      # Loads the template. A local variable named `feed' is made available,
      # which holds a reference to this JewelryPortfolio::Template::Feed
      # instance.
      def load_template!
        feed = self
        eval(File.read(@file))
      end
    end
  end
end