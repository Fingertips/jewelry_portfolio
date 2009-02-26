require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan" do
  before do
    RepoPageSan::ReposIndex.any_instance.stubs(:url).returns(fixture('alloy.github.com'))
    RepoPageSan::ReposIndex.any_instance.stubs(:path).returns(TMP_PAGES_REPO)
    RepoPageSan::ReposIndex.any_instance.stubs(:puts)
    FileUtils.rm_rf(TMP_PAGES_REPO)
    
    @instance = RepoPageSan.new('alloy')
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
  
  it "should commit the changes to the pages repo" do
    assert_difference('@instance.index.pages_repo.log.size', +1) do
      @instance.render!
      @instance.commit!
    end
  end
  
  private
  
  def assert_difference(eval_str, diff)
    before = eval(eval_str)
    yield
    assert_equal before + diff, eval(eval_str)
  end
end