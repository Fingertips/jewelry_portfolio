require File.expand_path('../test_helper', __FILE__)

module SharedRepoSpecs
  def self.included(klass)
    klass.class_eval do
      it "should return the name of the repo it represents" do
        @repo.name.should == 'dr-nic-magic-awesome'
      end
      
      it "should return the version of the project" do
        @repo.version.should == '1.0.0'
      end
      
      it "should return the summary of the project" do
        @repo.summary.should == 'Magically fix your projects overnight!'
      end
      
      it "should return the description of the project" do
        @repo.description.should == 'A gem which summons Dr. Nic to fix all your projects while you are cuddled underneath your blankie.'
      end
      
      it "should return the url to the github project page" do
        @repo.url.should == 'http://github.com/alloy/dr-nic-magic-awesome/tree/master'
      end
      
      it "should return the public clone url" do
        @repo.clone_url.should == 'git://github.com/alloy/dr-nic-magic-awesome.git'
      end
      
      it "should be equal if the name and version match" do
        other = JewelryPortfolio::Repo.new('alloy')
        other.name = @repo.name
        other.version = @repo.version
        
        @repo.should == other
      end
      
      it "should not be equal if the name doesn't match" do
        other = JewelryPortfolio::Repo.new('alloy')
        other.name = 'other-gem'
        other.version = @repo.version
        
        @repo.should.not == other
      end
      
      it "should not be equal if the version doesn't match" do
        other = JewelryPortfolio::Repo.new('alloy')
        other.name = @repo.name
        other.version = '9.9.9'
        
        @repo.should.not == other
      end
      
      it "should return itself serialized as YAML" do
        loaded_repo = YAML.load(@repo.to_yaml)
        
        loaded_repo.name.should == @repo.name
        loaded_repo.version.should == @repo.version
        loaded_repo.summary.should == @repo.summary
        loaded_repo.description.should == @repo.description
      end
    end
  end
end

describe "JewelryPortfolio::Repo, when initialized without a gemspec" do
  before do
    @repo = JewelryPortfolio::Repo.new('alloy')
    @repo.name = 'dr-nic-magic-awesome'
    @repo.version = '1.0.0'
    @repo.summary = 'Magically fix your projects overnight!'
    @repo.description = 'A gem which summons Dr. Nic to fix all your projects while you are cuddled underneath your blankie.'
  end
  
  include SharedRepoSpecs
  
  it "should return that there's _no_ a gem for the repo" do
    @repo.should.not.be.gem
  end
end

describe "JewelryPortfolio::Repo, when initialized with a gemspec" do
  before do
    @spec = fixture_eval('dr-nic-magic-awesome.gemspec_')
    @repo = JewelryPortfolio::Repo.new('alloy', @spec)
  end
  
  include SharedRepoSpecs
  
  it "should return that there's a gem for the repo" do
    @repo.should.be.gem
  end
  
  it "should return the gem name" do
    @repo.gem_name.should == "alloy-dr-nic-magic-awesome"
  end
  
  it "should return the gem install command" do
    @repo.gem_install_command.should == "sudo gem install #{@repo.gem_name} -s http://gems.github.com"
  end
end