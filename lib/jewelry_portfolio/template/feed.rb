require "builder"
require "rss"

class JewelryPortfolio
  class Template
    # This class is responsible for rendering a HTML template.
    class Feed < Template
      # The title that should be used for the feed.
      #
      # This defaults to <tt>"Code from #{@account}"</tt>.
      attr_accessor :title
      
      # The description (+subtitle+) that should be used for the feed.
      #
      # This defaults to <tt>"The Ruby libraries, from #{@account}, available
      # as open-source projects"</tt>.
      attr_accessor :description
      
      def initialize(template_file, account, repos)
        super
        @title = "Code from #{@account}"
        @description = "The Ruby libraries, from #{@account}, available as open-source projects"
        load_template!
      end
      
      # Loads the template. A local variable named `feed' is made available,
      # which holds a reference to this JewelryPortfolio::Template::Feed
      # instance.
      def load_template!
        feed = self
        eval(File.read(@file))
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
      
      # Returns the +id+ attribute to be used for the repo.
      def id_for_repo(repo)
        "#{repo.url}##{repo.version}"
      end
      
      # Returns the +updated+ attribute to be used for the repo.
      def updated_for_repo(repo)
        repo.updated_at.iso8601
      end
      
      # Returns the +title+ attribute to be used for the repo.
      def title_for_repo(repo)
        "#{repo.name} #{repo.version}"
      end
      
      # Returns the +link+ attribute to be used for the repo.
      def link_for_repo(repo)
        repo.url
      end
      
      # Returns the +summary+ attribute to be used for the repo.
      def summary_for_repo(repo)
        repo.summary
      end
      
      # Returns the +description+ attribute to be used for the repo.
      def description_for_repo(repo)
        repo.description
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
            xml.entry do
              xml.id      id_for_repo(repo)
              xml.updated updated_for_repo(repo)
              xml.title   title_for_repo(repo)
              xml.link    :href => link_for_repo(repo)
              xml.summary summary_for_repo(repo)
              xml.content description_for_repo(repo)
            end
          end
        end
      end
    end
  end
end