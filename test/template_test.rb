require File.expand_path('../test_helper', __FILE__)

describe "JewelryPortfolio::Template" do
  before do
    @repos = %w{ dr-nic-magic-awesome.gemspec_ microgem.gemspec_ }.
      map { |spec| JewelryPortfolio::Repo.new('alloy', fixture_eval(spec)) }
    
    @page = JewelryPortfolio::Template.new(fixture('template'), @repos.to_set)
  end
  
  it "should turn the repos set into an array" do
    @page.repos.should.be.instance_of Array
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