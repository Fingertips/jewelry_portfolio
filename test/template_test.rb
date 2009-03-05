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
    
    @file = fixture('template.html.erb')
    @template = JewelryPortfolio::Template::HTML.new(@file, 'alloy', @repos.to_set)
  end
  
  include SharedTemplateSpecs
  
  it "should render with the specified gem repos available as `repos'" do
    File.stubs(:read).returns('<%= repos.inspect %>')
    @template.render.should == @repos.sort_by { |r| r.name }.inspect
  end
  
  it "should render the ERB template" do
    @template.render.should == File.read(fixture('template.html'))
  end
  
  it "should return the repos ordered by name" do
    @template.repos.should == @repos.sort_by { |r| r.name }
  end
end

describe "JewelryPortfolio::Template::Feed" do
  before do
    @repos = %w{ dr-nic-magic-awesome.gemspec_ microgem.gemspec_ }.
      map { |spec| JewelryPortfolio::Repo.new('alloy', fixture_eval(spec)) }
    
    @file = fixture('feed.xml.builder')
    @template = JewelryPortfolio::Template::Feed.new(@file, 'alloy', @repos.to_set)
  end
  
  include SharedTemplateSpecs
  
  it "should return the feed id" do
    @template.feed_id.should == 'http://alloy.github.com/'
  end
  
  it "should return the feed url" do
    @template.feed_url.should == 'http://alloy.github.com/feed.xml'
  end
  
  it "should render the Builder template" do
    time = Time.now
    Time.stubs(:now).returns(time)
    expected = File.read(fixture('feed.xml')).gsub('TIME_NOW', time.iso8601)
    
    @template.render.should == expected
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