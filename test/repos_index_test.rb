require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan::ReposIndex. in general" do
  before do
    @index = RepoPageSan::ReposIndex.new('alloy')
  end
  
  it "should return the account" do
    @index.account.should == 'alloy'
  end
  
  it "should return the url to the pages repo" do
    @index.url.should == "git://github.com/alloy/alloy.github.com.git"
  end
  
  it "should return the path to the tmp checkout of the pages repo" do
    @index.path.should == File.join(Dir.tmpdir, 'alloy.github.com.git')
  end
  
  it "should return the path to the repos YAML index file" do
    @index.repos_file.should == File.join(@index.path, 'repos.yml')
  end
end

describe "RepoPageSan::ReposIndex, when working with a pages repo" do
  before do
    @index = RepoPageSan::ReposIndex.new('alloy')
    @index.stubs(:url).returns(fixture('alloy.github.com'))
    @index.stubs(:path).returns(TMP_PAGES_REPO)
    
    @index.stubs(:puts)
  end
  
  it "should create a checkout of the pages repo if it doesn't exist yet and return it" do
    FileUtils.rm_rf(TMP_PAGES_REPO)
    
    @index.pages_repo.should.be.instance_of Git::Base
    File.should.exist File.join(TMP_PAGES_REPO, 'repos.yml')
  end
  
  it "should create a checkout of the pages repo if it doesn't exist when asking for the repos" do
    FileUtils.rm_rf(TMP_PAGES_REPO)
    
    @index.repos
    File.should.exist File.join(TMP_PAGES_REPO, 'repos.yml')
  end
  
  it "should not create a new checkout if it already exists" do
    @index.pages_repo # make sure it exists
    
    Git.expects(:clone).never
    @index.pages_repo
  end
  
  it "should create and checkout the `gh-pages' branch" do
    FileUtils.rm_rf(TMP_PAGES_REPO)
    @index.pages_repo.branch('gh-pages').should.be.current
  end
  
  it "should return the pages repo" do
    repo = @index.pages_repo
    repo.should.be.instance_of Git::Base
  end
  
  it "should return an array of repos with their gemspecs" do
    @index.repos.should == [
      RepoPageSan::Repo.new(fixture('dr-nic-magic-awesome.gemspec_')),
      RepoPageSan::Repo.new(fixture('microgem.gemspec_'))
    ]
  end
  
  it "should serialize the array of repos as YAML" do
    @index.to_yaml.should == fixture_read('repos.yml')
  end
  
  it "should push the `gh-pages' branch" do
    @index.pages_repo.expects(:push).with('origin', 'gh-pages')
    @index.push!
  end
  
  it "should commit the changes to the pages repo" do
    assert_difference('@index.pages_repo.log.size', +1) do
      File.open(@index.repos_file, 'w') { |f| f << '' }
      @index.commit!('test commit')
    end
  end
  
  it "should push the `gh-pages' branch" do
    @index.pages_repo.expects(:push).with('origin', 'gh-pages')
    @index.push!
  end
  
  private
  
  def assert_difference(eval_str, diff)
    before = eval(eval_str)
    yield
    assert_equal before + diff, eval(eval_str)
  end
end