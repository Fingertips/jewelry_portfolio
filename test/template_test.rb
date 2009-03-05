require File.expand_path('../test_helper', __FILE__)

module SharedTemplateSpecs
  def self.included(klass)
    klass.class_eval do
      it "should turn the repos set into an array" do
        @template.repos.should.be.instance_of Array
      end
      
      it "should raise a JewelryPortfolio::FileMissingError if the specified template does not exist" do
        e = nil
        begin
          JewelryPortfolio::Template.new('/not/existing', 'alloy', @repos)
        rescue JewelryPortfolio::Template::FileMissingError => e
        end
        
        e.should.be.instance_of JewelryPortfolio::Template::FileMissingError
        e.message.should == "Could not find template at path `/not/existing'"
      end
      
      it "should return the path to the template file" do
        @template.file.should == @file
      end
      
      it "should return the view_path" do
        @template.view_path.should == FIXTURE_PATH
      end
    end
  end
end

describe "JewelryPortfolio::Template::HTML" do
  before do
    @repos = %w{ dr-nic-magic-awesome.gemspec_ microgem.gemspec_ }.
      map { |spec| JewelryPortfolio::Repo.new('alloy', fixture_eval(spec)) }
    
    @file = fixture('index.erb')
    @template = JewelryPortfolio::Template::HTML.new(@file, 'alloy', @repos.to_set)
  end
  
  include SharedTemplateSpecs
  
  it "should render with the specified gem repos available as `repos'" do
    File.stubs(:read).returns('<%= repos.inspect %>')
    @template.render.should == @repos.sort_by { |r| r.name }.inspect
  end
  
  it "should render the ERB template" do
    @template.render.should == File.read(fixture('index.html'))
  end
  
  it "should return the repos ordered by name" do
    @template.repos.should == @repos.sort_by { |r| r.name }
  end
end

describe "JewelryPortfolio::Template::Feed, in general" do
  before do
    @repos = %w{ dr-nic-magic-awesome.gemspec_ microgem.gemspec_ }.
      map { |spec| JewelryPortfolio::Repo.new('alloy', fixture_eval(spec)) }
    
    @file = fixture('feed_with_defaults.rb')
    @template = JewelryPortfolio::Template::Feed.new(@file, 'alloy', @repos.to_set)
  end
  
  include SharedTemplateSpecs
  
  it "should return the feed id" do
    @template.feed_id.should == 'http://alloy.github.com/'
  end
  
  it "should return the feed url" do
    @template.feed_url.should == 'http://alloy.github.com/feed.xml'
  end
  
  it "should return the repos ordered by updated_at" do
    repos = @template.repos
    
    repos.last.stubs(:updated_at).returns(Time.now)
    sleep 1.1
    repos.first.stubs(:updated_at).returns(Time.now)
    
    @template.repos.should == @repos.sort
  end
  
  it "should return the repos ordered by version if updated_at is the same" do
    repos = @template.repos
    time = Time.now
    
    repos.each { |r| r.stubs(:updated_at).returns(time) }
    
    repos.first.version = '0.11.45'
    repos.last.version = '1.2.3'
    
    @template.repos.should == @repos.sort
  end
end

describe "JewelryPortfolio::Template::Feed, with defaults" do
  before do
    @repos = %w{ dr-nic-magic-awesome.gemspec_ microgem.gemspec_ }.
      map { |spec| JewelryPortfolio::Repo.new('alloy', fixture_eval(spec)) }
    @repo = @repos.first
    
    @file = fixture('feed_with_defaults.rb')
    @template = JewelryPortfolio::Template::Feed.new(@file, 'alloy', @repos.to_set)
  end
  
  it "should return the title" do
    @template.title.should == 'Code from alloy'
  end
  
  it "should return the description" do
    @template.description.should == 'The Ruby libraries, from alloy, available as open-source projects'
  end
  
  it "should return the `id' attribute for a repo" do
    @template.id_for_repo(@repo).should == "#{@repo.url}##{@repo.version}"
  end
  
  it "should return the `updated' attribute for a repo" do
    @template.updated_for_repo(@repo).should == @repo.updated_at.iso8601
  end
  
  it "should return the `title' attribute for a repo" do
    @template.title_for_repo(@repo).should == "#{@repo.name} #{@repo.version}"
  end
  
  it "should return the `link' attribute for a repo" do
    @template.link_for_repo(@repo).should == @repo.url
  end
  
  it "should return the `summary' attribute for a repo" do
    @template.summary_for_repo(@repo).should == @repo.summary
  end
  
  it "should return the `description' attribute for a repo" do
    @template.description_for_repo(@repo).should == @repo.description
  end
  
  it "should render the template" do
    time = Time.now
    Time.stubs(:now).returns(time)
    expected = File.read(fixture('feed_with_defaults.xml')).gsub('TIME_NOW', time.iso8601)
    
    @template.render.should == expected
  end
end

describe "JewelryPortfolio::Template::Feed, with overriden options from the template" do
  before do
    @repos = %w{ dr-nic-magic-awesome.gemspec_ microgem.gemspec_ }.
      map { |spec| JewelryPortfolio::Repo.new('alloy', fixture_eval(spec)) }
    @repo = @repos.first
    
    @file = fixture('feed_with_options.rb')
    @template = JewelryPortfolio::Template::Feed.new(@file, 'alloy', @repos.to_set)
  end
  
  include SharedTemplateSpecs
  
  it "should return the title that was overriden" do
    title = 'Code from Eloy Duran (alloy)'
    @template.title = title
    @template.title.should == title
  end
  
  it "should return the description that was overriden" do
    description = 'The Ruby libraries, from Eloy Duran, available as open-source projects'
    @template.description = description
    @template.description.should == description
  end
  
  it "should return the `id' attribute for a repo" do
    @template.id_for_repo(@repo).should == "#{@repo.name}-#{@repo.version}"
  end
  
  it "should return the `updated' attribute for a repo" do
    @template.updated_for_repo(@repo).should == 'Right about NOW!'
  end
  
  it "should return the `title' attribute for a repo" do
    @template.title_for_repo(@repo).should == "#{@repo.name.capitalize} (#{@repo.version})"
  end
  
  it "should return the `link' attribute for a repo" do
    @template.link_for_repo(@repo).should == "http://google.com?q=#{@repo.name}"
  end
  
  it "should return the `summary' attribute for a repo" do
    @template.summary_for_repo(@repo).should == "#{@repo.name.capitalize} is awesome!"
  end
  
  it "should return the `description' attribute for a repo" do
    @template.description_for_repo(@repo).should == "#{@repo.name.capitalize} is awesome!"
  end
  
  it "should render the template" do
    time = Time.now
    Time.stubs(:now).returns(time)
    expected = File.read(fixture('feed_with_options.xml')).gsub('TIME_NOW', time.iso8601)
    
    @template.render.should == expected
  end
end