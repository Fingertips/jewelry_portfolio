require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan::Repo" do
  before do
    @spec = fixture('dr-nic-magic-awesome.gemspec_')
    @repo = RepoPageSan::Repo.new(@spec)
  end
  
  it "should return the Gem::Specification instance" do
    @repo.spec.should == eval(File.read(@spec))
  end
  
  it "should return itself serialized as YAML" do
    @repo.to_yaml.should == fixture_read('dr-nic-magic-awesome_repo.yml')
  end
end