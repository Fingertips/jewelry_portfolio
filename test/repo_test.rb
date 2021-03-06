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
      
      it "should return a custom #hash" do
        @repo.hash.should == 'dr-nic-magic-awesome'.hash
      end
      
      it "should be equal if the name is equal" do
        other = JewelryPortfolio::Repo.new('alloy')
        other.name = @repo.name
        
        @repo.should == other
        @repo.should.eql other
      end
      
      it "should not be equal if the name doesn't match" do
        other = JewelryPortfolio::Repo.new('alloy')
        other.name = 'other-gem'
        
        @repo.should.not == other
        @repo.should.not.eql other
      end
      
      it "should return itself serialized as YAML" do
        loaded_repo = YAML.load(@repo.to_yaml)
        
        loaded_repo.name.should        == @repo.name
        loaded_repo.version.should     == @repo.version
        loaded_repo.summary.should     == @repo.summary
        loaded_repo.description.should == @repo.description
        loaded_repo.updated_at.should  == @repo.updated_at
      end
      
      it "should be valid with all necessary attributes set" do
        @repo.should.be.valid
      end
      
      it "should not be valid with any of its attributes missing" do
        %w{ account name version summary description }.each do |attr|
          repo = @repo.dup
          repo.send("#{attr}=", nil)
          
          repo.should.not.be.valid
        end
      end
    end
  end
end

describe "JewelryPortfolio::Repo, when initialized without a gemspec" do
  before do
    @time = Time.now
    Time.stubs(:now).returns(@time)
    
    @repo = JewelryPortfolio::Repo.new
    @repo.account = 'alloy'
    @repo.name = 'dr-nic-magic-awesome'
    @repo.version = '1.0.0'
    @repo.summary = 'Magically fix your projects overnight!'
    @repo.description = 'A gem which summons Dr. Nic to fix all your projects while you are cuddled underneath your blankie.'
  end
  
  include SharedRepoSpecs
  
  it "should return that there's _no_ a gem for the repo" do
    @repo.gem?.should.be false
  end
  
  it "should return a new updated_at Time instance if there was no updated_at yet" do
    @repo.updated_at.should == @time
    @repo.instance_variable_get("@updated_at").should == @time
  end
end

describe "JewelryPortfolio::Repo, when initialized with a gemspec" do
  before do
    @spec = fixture_eval('dr-nic-magic-awesome.gemspec_')
    @repo = JewelryPortfolio::Repo.new('alloy', @spec)
  end
  
  include SharedRepoSpecs
  
  it "should return the date from the gemspec" do
    @repo.updated_at.should == Time.utc(@spec.date.year, @spec.date.month, @spec.date.day)
  end
  
  it "should return that there's a gem for the repo" do
    @repo.gem?.should.be true
  end
  
  it "should return the gem name" do
    @repo.gem_name.should == "alloy-dr-nic-magic-awesome"
  end
  
  it "should return the gem install command" do
    @repo.gem_install_command.should == "sudo gem install #{@repo.gem_name} -s http://gems.github.com"
  end
end

describe "JewelryPortfolio::Repo, when initialized from YAML" do
  before do
    @repo = YAML.load(fixture_read('repos.yml')).first
  end
  
  include SharedRepoSpecs
  
  it "should return the date as it was serialized in the yaml" do
    YAML.load(@repo.to_yaml).updated_at.should == @repo.updated_at
  end
end