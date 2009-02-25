require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan::GitHubAccount" do
  before do
    @account = RepoPageSan::GitHubAccount.new('alloy', 'the_token')
  end
  
  it "should have initialized with the correct data" do
    @account.login.should == 'alloy'
    @account.token.should == 'the_token'
  end
  
  it "should return the URL to the `pages' repo for this account" do
    @account.pages_url.should == 'https://github.com/alloy/alloy.github.com'
  end
end