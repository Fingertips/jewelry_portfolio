require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan::Repo" do
  before do
    @spec = fixture_eval('dr-nic-magic-awesome.gemspec_')
    @repo = RepoPageSan::Repo.new(@spec)
  end
  
  it "should return the Gem::Specification instance" do
    @repo.spec.should == @spec
  end
  
  it "should return the name of the gem it represents" do
    @repo.name.should == 'dr-nic-magic-awesome'
  end
  
  xit "should return itself serialized as YAML" do
    @repo.to_yaml.should == fixture_read('dr-nic-magic-awesome_repo.yml')
  end
  
  it "should be equal if the name matches" do
    RepoPageSan::Repo.new(fixture_eval('dr-nic-magic-awesome.gemspec_')).should ==
      RepoPageSan::Repo.new(fixture_eval('dr-nic-magic-awesome.gemspec_'))
    
    RepoPageSan::Repo.new(fixture_eval('dr-nic-magic-awesome.gemspec_')).should.not ==
      RepoPageSan::Repo.new(fixture_eval('microgem.gemspec_'))
  end
end