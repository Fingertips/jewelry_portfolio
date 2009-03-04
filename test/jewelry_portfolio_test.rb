require File.expand_path('../test_helper', __FILE__)

describe "JewelryPortfolio" do
  before do
    JewelryPortfolio::ReposIndex.any_instance.stubs(:url).returns(fixture('alloy.github.com'))
    JewelryPortfolio::ReposIndex.any_instance.stubs(:path).returns(TMP_PAGES_REPO)
    JewelryPortfolio::ReposIndex.any_instance.stubs(:puts)
    FileUtils.rm_rf(TMP_PAGES_REPO)
    
    @repo = JewelryPortfolio::Repo.new('alloy', eval(fixture_read('dr-nic-magic-awesome.gemspec_')))
    @portfolio = JewelryPortfolio.new('alloy', @repo)
    
    @portfolio.stubs(:puts)
  end
  
  it "should raise an ArgumentError if no account is given" do
    lambda {
      JewelryPortfolio.new(nil, @repo)
    }.should.raise ArgumentError
  end
  
  it "should raise a JewelryPortfolio::Repo::InvalidError if the given repo isn't valid" do
    @repo.version = nil
    lambda {
      JewelryPortfolio.new('alloy', @repo)
    }.should.raise ArgumentError
  end
  
  it "should add the spec to the index" do
    JewelryPortfolio::ReposIndex.any_instance.expects(:add).with(@repo)
    JewelryPortfolio.new('alloy', @repo)
  end
  
  it "should also initialize without gemspec" do
    JewelryPortfolio::ReposIndex.any_instance.expects(:add).never
    JewelryPortfolio.new('alloy')
  end
  
  it "should return the local pages repos index" do
    index = @portfolio.index
    index.should.be.instance_of JewelryPortfolio::ReposIndex
    index.repos.map { |r| r.name }.should == %w{ dr-nic-magic-awesome microgem }
  end
  
  it "should return the template" do
    template = @portfolio.template
    template.should.be.instance_of JewelryPortfolio::Template::HTML
    template.file.should == File.join(@portfolio.index.path, 'template.html.erb')
    template.repos.should == @portfolio.index.repos.to_a
  end
  
  it "should write out the template" do
    @portfolio.render!
    File.read(File.join(@portfolio.index.path, 'index.html')).should == File.read(fixture('template.html'))
  end
  
  it "should render, commit, and push the master branch" do
    @portfolio.expects(:render!)
    @portfolio.index.expects(:commit!).with("Updated github pages for: dr-nic-magic-awesome-1.0.0")
    @portfolio.index.expects(:push!)
    
    @portfolio.release!
  end
end

describe "JewelryPortfolio, with a custom work_directory" do
  before do
    JewelryPortfolio::ReposIndex.any_instance.stubs(:load_pages_repo!)
    JewelryPortfolio::Template::HTML.stubs(:new)
    @portfolio = JewelryPortfolio.new('alloy')
  end
  
  it "should initialize the index with the current work directory if no spec is given" do
    @portfolio.index.instance_variable_get("@custom_work_directory").should == Dir.pwd
  end
  
  it "should render, commit, and push the master branch" do
    @portfolio.expects(:render!)
    @portfolio.index.expects(:commit!).with("Re-generated github pages")
    @portfolio.index.expects(:push!)
    
    @portfolio.release!
  end
end