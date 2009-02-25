require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan::Page" do
  before do
    @page = RepoPageSan::Page.new(fixture('template.html.erb'))
  end
  
  it "should return the path to the template" do
    @page.template.should == fixture('template.html.erb')
  end
end