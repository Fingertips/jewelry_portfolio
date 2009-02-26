require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan" do
  before do
    RepoPageSan::ReposIndex.any_instance.stubs(:url).returns(fixture('alloy.github.com'))
    RepoPageSan::ReposIndex.any_instance.stubs(:path).returns(TMP_PAGES_REPO)
    
    @instance = RepoPageSan.new('alloy')
  end
  
  it "should return the local pages repos index" do
    index = @instance.index
    index.should.be.instance_of RepoPageSan::ReposIndex
    index.repos.map { |r| r.spec.name }.should == %w{ dr-nic-magic-awesome microgem }
  end
end