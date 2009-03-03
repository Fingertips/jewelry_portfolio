require File.expand_path('../test_helper', __FILE__)
require 'jewelry_portfolio/tasks'

module RakeTaskTestHelper
  class Namespace
    attr_reader :tasks
    
    def initialize(tasks_helper)
      @tasks = {}
      @tasks_helper = tasks_helper
    end
    
    def task(name, &block)
      @tasks[name] = block
    end
    
    def desc(title)
      # nothing
    end
    
    def method_missing(method, *args, &block)
      @tasks_helper.send(method, *args, &block)
    end
  end
  
  def namespace(name, &block)
    @namespaces ||= {}
    (@namespaces[name] = Namespace.new(self)).instance_eval(&block)
  end
  
  def namespaces
    @namespaces
  end
end

JewelryPortfolio::Tasks.send(:include, RakeTaskTestHelper)

describe "JewelryPortfolio::Tasks" do
  before do
    @tasks_helper = JewelryPortfolio::Tasks.new
    @tasks_helper.stubs(:portfolio).returns(stub('JewelryPortfolio instance'))
  end
  
  it "should define a portfolio namespace" do
    @tasks_helper.namespaces.should.has_key :portfolio
  end
  
  it "should define a portfolio:generate task which calls render! on the portfolio instance and opens the index.html file" do
    @tasks_helper.portfolio.stubs(:index).returns(stub('JewelryPortfolio::ReposIndex', :path => '/path/to/repo'))
    
    @tasks_helper.portfolio.expects(:render!)
    @tasks_helper.expects(:sh).with("open '/path/to/repo/index.html'")
    
    @tasks_helper.namespaces[:portfolio].tasks[:generate].call
  end
  
  it "should define a portfolio:release task which calls release! on the portfolio instance" do
    @tasks_helper.portfolio.expects(:release!)
    @tasks_helper.namespaces[:portfolio].tasks[:release].call
  end
end

describe "JewelryPortfolio::Tasks, in general" do
  before do
    Git.stubs(:open).with('.').returns(stub('Git config', :config => { 'github.user' => 'joe_the_plumber' }))
    
    @tasks_helper = JewelryPortfolio::Tasks.new
    @tasks_helper.stubs(:portfolio).returns(stub('JewelryPortfolio instance'))
  end
  
  it "should yield a JewelryPortfolio::Repo when initializing" do
    repo = nil
    @tasks_helper = JewelryPortfolio::Tasks.new { |t| repo = t }
    
    repo.should.be.instance_of JewelryPortfolio::Repo
    @tasks_helper.repo.should.be repo
  end
  
  it "should assign the account to use on the repo, from the local/global git config if the user didn't specify one" do
    @tasks_helper.repo.account.should == 'joe_the_plumber'
  end
  
  it "should raise an ArgumentError if no account could be resolved" do
    Git.stubs(:open).with('.').returns(stub('Git config', :config => {}))
    @tasks_helper = JewelryPortfolio::Tasks.new
    
    lambda { @tasks_helper.send(:portfolio) }.should.raise ArgumentError
  end
  
  it "should try to find a gemspec file in the current work directory and return a JewelryPortfolio instance with that spec" do
    Dir.expects(:glob).with('*.gemspec').returns([fixture('dr-nic-magic-awesome.gemspec_')])
    @tasks_helper = JewelryPortfolio::Tasks.new
    
    JewelryPortfolio.expects(:new).with('joe_the_plumber',
      JewelryPortfolio::Repo.new('joe_the_plumber', fixture_eval('dr-nic-magic-awesome.gemspec_'))).
        returns('JewelryPortfolio')
    
    @tasks_helper.send(:portfolio).should == 'JewelryPortfolio'
  end
  
  it "should not pass the Repo instance if it's not valid" do
    Dir.stubs(:glob).with('*.gemspec').returns([])
    @tasks_helper = JewelryPortfolio::Tasks.new
    
    JewelryPortfolio.expects(:new).with('joe_the_plumber', nil).returns('JewelryPortfolio')
    @tasks_helper.send(:portfolio).should == 'JewelryPortfolio'
  end
end