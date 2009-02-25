require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan::ReposIndex" do
  before do
    @account = RepoPageSan::GitHubAccount.new('alloy', 'the_token')
    @index = RepoPageSan::ReposIndex.new(@account)
  end
  
  it "should return the account instance" do
    @index.account.should == @account
  end
  
  it "should return the url to the repos index" do
    @index.url.should == "#{@account.pages_url}/blob/gh-pages/repos.yml"
  end
end