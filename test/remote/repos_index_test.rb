require File.expand_path('../../test_helper', __FILE__)

describe "RepoPageSan::ReposIndex" do
  before do
    @account = RepoPageSan::GitHubAccount.new('alloy', 'the_token')
    @index = RepoPageSan::ReposIndex.new(@account)
  end
end