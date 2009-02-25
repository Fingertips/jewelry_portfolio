require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan::GitHubAccount" do
  before do
    @account = RepoPageSan::GitHubAccount.new('alloy', 'the_token')
  end
  
  it "should have initialized with the correct data" do
    @account.login.should == 'alloy'
    @account.token.should == 'the_token'
  end
  
  it "should return the base URL for this account" do
    @account.base_url.should == 'https://github.com/alloy'
  end
end