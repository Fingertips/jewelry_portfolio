require File.expand_path('../test_helper', __FILE__)

class GemSpecMock
  attr_accessor :name, :description
  
  def initialize(name, description)
    @name, @description = name, description
  end
end

describe "JewelryPortfolio::Template" do
  before do
    @repos = [
      JewelryPortfolio::Repo.new(GemSpecMock.new('dr-nic-magic-awesome', "Magically fix your projects overnight!")),
      JewelryPortfolio::Repo.new(GemSpecMock.new('microgem', "MicroGem provides a simple naive replacement for the `gem install' command in the form of the `mgem' commandline utility."))
    ]
    
    @page = JewelryPortfolio::Template.new(fixture('template'), @repos)
  end
  
  it "should raise a JewelryPortfolio::FileMissingError if the specified template does not exist" do
    e = nil
    begin
      JewelryPortfolio::Template.new('/not/existing/template', @repos)
    rescue JewelryPortfolio::FileMissingError => e
    end
    
    e.should.be.instance_of JewelryPortfolio::FileMissingError
    e.message.should == "Could not find template at path `/not/existing/template.html.erb'"
  end
  
  it "should return the path to the template" do
    @page.template.should == fixture('template.html.erb')
  end
  
  it "should return the repos" do
    @page.repos.should == @repos
  end
  
  it "should return the view_path" do
    @page.view_path.should == FIXTURE_PATH
  end
  
  it "should render with the specified gem repos available as `repos'" do
    File.stubs(:read).returns('<%= repos.inspect %>')
    @page.render.should == @repos.inspect
  end
  
  it "should render an ERB partial with the specified local variables" do
    @page.partial('repo', :repo => @repos.first).should ==
      File.read(fixture('dr-nic-magic-awesome.html'))
  end
  
  it "should render an ERB partial with the specified repo" do
    @page.repo_partial(@repos.first).should ==
      File.read(fixture('dr-nic-magic-awesome.html'))
  end
  
  it "should render an ERB partial with the specified repo and local variables" do
    File.stubs(:read).returns('<%= "#{repo} #{extra_var}" %>')
    @page.repo_partial('repo_value', :extra_var => 'extra_var_value').should == 'repo_value extra_var_value'
  end
  
  it "should render an ERB partial with nested partials" do
    stubs_file_exists_and_returns('parent.html.erb', 'Hello <%= partial "nested1", :text => "world!" %>')
    stubs_file_exists_and_returns('nested1.html.erb', '<%= text %> <%= partial "nested2", :text => "Wazzup?!" %>')
    stubs_file_exists_and_returns('nested2.html.erb', '<%= text %>')
    
    @page.partial('parent').should == 'Hello world! Wazzup?!'
  end
  
  it "should render the ERB template" do
    @page.render.should == File.read(fixture('template.html'))
  end
  
  private
  
  def stubs_file_exists_and_returns(fixture_name, data)
    path = File.join(FIXTURE_PATH, fixture_name)
    File.stubs(:exist?).with(path).returns(true)
    File.stubs(:read).with(path).returns(data)
  end
end