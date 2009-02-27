require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan" do
  before do
    RepoPageSan::ReposIndex.any_instance.stubs(:url).returns(fixture('alloy.github.com'))
    RepoPageSan::ReposIndex.any_instance.stubs(:path).returns(TMP_PAGES_REPO)
    RepoPageSan::ReposIndex.any_instance.stubs(:puts)
    FileUtils.rm_rf(TMP_PAGES_REPO)
    
    @spec = eval(fixture_read('dr-nic-magic-awesome.gemspec_'))
    @instance = RepoPageSan.new('alloy', @spec)
  end
  
  it "should return the local pages repos index" do
    index = @instance.index
    index.should.be.instance_of RepoPageSan::ReposIndex
    index.repos.map { |r| r.spec.name }.should == %w{ dr-nic-magic-awesome microgem }
  end
  
  it "should return the template" do
    template = @instance.template
    template.should.be.instance_of RepoPageSan::Template
    template.template.should == File.join(@instance.index.path, 'template.html.erb')
    template.specs.should == @instance.index.repos.map { |r| r.spec }
  end
  
  it "should write out the template" do
    @instance.render!
    File.read(File.join(@instance.index.path, 'index.html')).should == File.read(fixture('template.html'))
  end
  
  it "should render, commit, and push the `gh-pages' branch" do
    @instance.expects(:render!)
    @instance.index.expects(:commit!).with("Updated github pages for: dr-nic-magic-awesome-1.0.0")
    @instance.index.expects(:push!)
    
    @instance.release!
  end
end