require File.expand_path('../test_helper', __FILE__)

describe "JewelryPortfolio::ReposIndex, in general" do
  before do
    @index = JewelryPortfolio::ReposIndex.new('alloy')
  end
  
  it "should return the account" do
    @index.account.should == 'alloy'
  end
  
  it "should return the repo name" do
    @index.repo_name.should == 'alloy.github.com.git'
  end
  
  it "should return the url to the pages repo" do
    @index.url.should == "git@github.com:alloy/alloy.github.com.git"
  end
  
  it "should return the path to the tmp checkout of the pages repo" do
    @index.path.should == File.join(Dir.tmpdir, 'alloy.github.com.git')
  end
  
  it "should return the path to the repos YAML index file" do
    @index.repos_file.should == File.join(@index.path, 'repos.yml')
  end
end

describe "JewelryPortfolio::ReposIndex, in general, when the user specified a work directory" do
  before do
    @index = JewelryPortfolio::ReposIndex.new('alloy', '/path/to/repo')
    File.stubs(:exist?).with(@index.path).returns(true)
  end
  
  it "should return the path to the tmp checkout of the pages repo" do
    @index.path.should == '/path/to/repo'
  end
  
  it "should return the path to the repos YAML index file" do
    @index.repos_file.should == File.join(@index.path, 'repos.yml')
  end
  
  it "should not pull from the remote pages repo when opening the repo" do
    @index.instance_variable_set("@pages_repo", nil)
    
    Git.expects(:open).with(@index.path)
    Git::Base.any_instance.expects(:pull).never
    @index.pages_repo
  end
end

describe "JewelryPortfolio::ReposIndex, when working with a pages repo" do
  before do
    @index = JewelryPortfolio::ReposIndex.new('alloy')
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
  
  it "should not create a new checkout if it already exists, but do a pull" do
    @index.pages_repo # make sure it exists
    @index.instance_variable_set("@pages_repo", nil)
    
    Git.expects(:clone).never
    Git::Base.any_instance.expects(:checkout).with('gh-pages')
    Git::Base.any_instance.expects(:fetch).with('origin')
    Git::Base.any_instance.expects(:merge).with('origin/gh-pages')
    @index.pages_repo
  end
  
  it "should create and checkout the `gh-pages' branch" do
    FileUtils.rm_rf(TMP_PAGES_REPO)
    @index.pages_repo.branch('gh-pages').should.be.current
    @index.pages_repo.config('branch.gh-pages.remote').should == 'origin'
    @index.pages_repo.config('branch.gh-pages.merge').should == 'refs/heads/gh-pages'
  end
  
  it "should return the pages repo" do
    repo = @index.pages_repo
    repo.should.be.instance_of Git::Base
  end
  
  it "should return an array of specs" do
    FileUtils.rm_rf(TMP_PAGES_REPO)
    
    @index.specs.each { |s| s.should.be.instance_of Gem::Specification }
    @index.specs.map { |s| s.name }.should == %w{ dr-nic-magic-awesome microgem }
  end
  
  it "should return an empty array if the repos.yml file does not exist yet" do
    FileUtils.rm(@index.repos_file)
    @index.specs.should == []
  end
  
  it "should return an array of repos with their gemspecs" do
    FileUtils.rm_rf(TMP_PAGES_REPO)
    
    @index.repos.should == [
      JewelryPortfolio::Repo.new(fixture_eval('dr-nic-magic-awesome.gemspec_'), 'alloy'),
      JewelryPortfolio::Repo.new(fixture_eval('microgem.gemspec_'), 'alloy')
    ]
  end
  
  xit "should serialize the array of repos as YAML" do
    @index.to_yaml.should == fixture_read('repos.yml')
  end
  
  it "should push the `gh-pages' branch" do
    @index.pages_repo.expects(:push).with('origin', 'gh-pages')
    @index.push!
  end
  
  it "should commit the changes to the pages repo" do
    assert_difference('pages_repo_commits', +1) do
      File.open(@index.repos_file, 'w') { |f| f << 'foo' }
      @index.commit!('test commit')
    end
  end
  
  it "should also commit new files to the pages repo" do
    assert_difference('pages_repo_commits', +1) do
      File.open(File.join(@index.path, 'foo'), 'w') { |f| f << 'foo' }
      @index.commit!('test commit')
    end
  end
  
  it "should push the `gh-pages' branch" do
    @index.pages_repo.expects(:push).with('origin', 'gh-pages')
    @index.push!
  end
  
  it "should add a new spec to the repos.yml" do
    FileUtils.rm_rf(TMP_PAGES_REPO)
    @index.repos # make sure its loaded
    
    spec = eval(fixture_read('dr-nic-magic-awesome.gemspec_').
      gsub('dr-nic-magic-awesome', 'dr-nic-magic-awesome-v2'))
    
    assert_difference('repos_from_file.length', +1) do
      @index.add(spec)
    end
    
    repos_from_file.last.name.should == 'dr-nic-magic-awesome-v2'
  end
  
  it "should update an existing spec in the repos.yml" do
    FileUtils.rm_rf(TMP_PAGES_REPO)
    @index.repos # make sure its loaded
    
    spec = eval(fixture_read('dr-nic-magic-awesome.gemspec_').gsub('1.0.0', '1.1.1'))
    
    assert_no_difference('repos_from_file.length') do
      @index.add(spec)
    end
    
    repos_from_file.first.version.to_s.should == '1.1.1'
  end
  
  it "should re-raise Git::GitExecuteErrors with the repo path prepended" do
    message = nil
    @index.commit! 'clean'
    
    begin
      @index.commit! 'error'
    rescue Git::GitExecuteError => e
      message = e.message
    end
    
    message.should.match /^\[#{@index.path}\]/
  end
  
  private
  
  def repos_from_file
    YAML.load(File.read(@index.repos_file))
  end
  
  def pages_repo_commits
    @index.pages_repo.log.size
  end
  
  def assert_difference(eval_str, diff)
    before = eval(eval_str)
    yield
    assert_equal before + diff, eval(eval_str)
  end
  
  def assert_no_difference(eval_str, &block)
    assert_difference(eval_str, 0, &block)
  end
end