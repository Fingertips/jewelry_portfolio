require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan::ReposIndex, in general" do
  before do
    @account = RepoPageSan::GitHubAccount.new('alloy', 'the_token')
    @index = RepoPageSan::ReposIndex.new(@account)
    @index.stubs(:get).returns(fixture_read('repos.yml'))
  end
  
  it "should return the account instance" do
    @index.account.should == @account
  end
  
  it "should return the url to the repos index yaml file" do
    @index.url.should == "#{@account.pages_url}/blob/gh-pages/repos.yml"
  end
  
  it "should return the url to the repos index yaml file for a GET request" do
    @index.get_url.should == "#{@account.pages_url}/raw/gh-pages/repos.yml"
  end
  
  it "should return the url to the repos index yaml file for a POST request" do
    @index.post_url.should == "#{@account.pages_url}/tree-save/gh-pages/repos.yml"
  end
  
  it "should be equal if the name matches" do
    RepoPageSan::Repo.new(fixture('dr-nic-magic-awesome.gemspec_')).should ==
      RepoPageSan::Repo.new(fixture('dr-nic-magic-awesome.gemspec_'))
    
    RepoPageSan::Repo.new(fixture('dr-nic-magic-awesome.gemspec_')).should.not ==
      RepoPageSan::Repo.new(fixture('microgem.gemspec_'))
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
end

describe "RepoPageSan::ReposIndex, when making a connection" do
  before do
    @account = RepoPageSan::GitHubAccount.new('alloy', 'the_token')
    @index = RepoPageSan::ReposIndex.new(@account)
  end
  
  it "should return the repos index yaml file contents" do
    Net::HTTP.expects(:get).with(URI.parse(@index.get_url)).returns('repos.yml contents').once
    @index.get.should == 'repos.yml contents'
  end
  
  it "should post the repos index yaml file to the remote branch" do
    Net::HTTP.expects(:post_form).with(@index.post_url,
      'commit'  => 'gh-pages',
      'value'   => @index.to_yaml,
      'message' => 'commit message'
    )
    
    @index.post!
  end
end