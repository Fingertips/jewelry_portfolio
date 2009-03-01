require File.expand_path('../test_helper', __FILE__)

describe "JewelryPortfolio::Repo" do
  before do
    @spec = fixture_eval('dr-nic-magic-awesome.gemspec_')
    @repo = JewelryPortfolio::Repo.new(@spec, 'alloy')
  end
  
  it "should return the Gem::Specification instance" do
    @repo.spec.should == @spec
  end
  
  it "should return the name of the gem it represents" do
    @repo.name.should == 'dr-nic-magic-awesome'
  end
  
  it "should return the url to the github project page" do
    @repo.url.should == 'http://github.com/alloy/dr-nic-magic-awesome/tree/master'
  end
  
  it "should return the public clone url" do
    @repo.clone_url.should == 'git://github.com/alloy/dr-nic-magic-awesome.git'
  end
  
  xit "should return itself serialized as YAML" do
    @repo.to_yaml.should == fixture_read('dr-nic-magic-awesome_repo.yml')
  end
  
  it "should be equal if the name matches" do
    JewelryPortfolio::Repo.new(fixture_eval('dr-nic-magic-awesome.gemspec_'), 'alloy').should ==
      JewelryPortfolio::Repo.new(fixture_eval('dr-nic-magic-awesome.gemspec_'), 'alloy')
    
    JewelryPortfolio::Repo.new(fixture_eval('dr-nic-magic-awesome.gemspec_'), 'alloy').should.not ==
      JewelryPortfolio::Repo.new(fixture_eval('microgem.gemspec_'), 'alloy')
  end
end