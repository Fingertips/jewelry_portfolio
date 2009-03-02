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
  
  it "should be equal if the gem name matches" do
    a, b = Array.new(2) { JewelryPortfolio::Repo.new('alloy') }
    
    a.name = 'dr-nic-magic-awesome'
    b.name = 'dr-nic-magic-awesome'
    a.should == b
    
    b.name = 'microgem'
    a.should.not == b
  end
end

describe "JewelryPortfolio::Repo, when initialized with a gemspec" do
  before do
    @spec = fixture_eval('dr-nic-magic-awesome.gemspec_')
    @repo = JewelryPortfolio::Repo.new('alloy', @spec)
  end
  
  include SharedRepoSpecs
  
  it "should return the gem name" do
    @repo.gem_name.should == "alloy-dr-nic-magic-awesome"
  end
  
  it "should return the gem install command" do
    @repo.gem_install_command.should == "sudo gem install #{@repo.gem_name} -s http://gems.github.com"
  end
  
  it "should be equal if the gem name matches" do
    JewelryPortfolio::Repo.new('alloy', fixture_eval('dr-nic-magic-awesome.gemspec_')).should ==
      JewelryPortfolio::Repo.new('alloy', fixture_eval('dr-nic-magic-awesome.gemspec_'))
    
    JewelryPortfolio::Repo.new('alloy', fixture_eval('dr-nic-magic-awesome.gemspec_')).should.not ==
      JewelryPortfolio::Repo.new('alloy', fixture_eval('microgem.gemspec_'))
  end
end