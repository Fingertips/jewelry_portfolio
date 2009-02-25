require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan::ReposIndex" do
  before do
    @account = RepoPageSan::GitHubAccount.new('alloy', 'the_token')
    @index = RepoPageSan::ReposIndex.new(@account)
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
  
  it "should return the repos index yaml file contents" do
    Net::HTTP.expects(:get).with(URI.parse(@index.get_url)).returns('repos.yml contents').once
    @index.get.should == 'repos.yml contents'
  end
end