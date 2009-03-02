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
    @tasks_helper = JewelryPortfolio::Tasks.new
    @tasks_helper.stubs(:portfolio).returns(stub('JewelryPortfolio instance'))
  end
  
  it "should yield itself when initializing" do
    yielded_instance = nil
    returned_instance = JewelryPortfolio::Tasks.new { |t| yielded_instance = t }
    returned_instance.should.be yielded_instance
  end
  
  it "should return the account name to use from the local/global git config if the user didn't specify one" do
    Git.expects(:open).with('.').returns(stub('Git config', :config => { 'github.user' => 'joe_the_plumber' }))
    @tasks_helper.account.should == 'joe_the_plumber'
  end
  
  it "should return the account explicitely defined by the user" do
    @tasks_helper.account = 'joe_the_plumber'
    @tasks_helper.account.should == 'joe_the_plumber'
  end
  
  it "should raise an ArgumentError if no account could be resolved" do
    Git.expects(:open).with('.').returns(stub('Git config', :config => {}))
    lambda {
      @tasks_helper.account
    }.should.raise ArgumentError
  end
  
  it "should try to find a gemspec file in the current work directory and return a JewelryPortfolio instance with that spec" do
    @tasks_helper = JewelryPortfolio::Tasks.new
    @tasks_helper.account = 'alloy'
    
    Dir.expects(:glob).with('*.gemspec').returns([fixture('dr-nic-magic-awesome.gemspec_')])
    JewelryPortfolio.expects(:new).with('alloy', fixture_eval('dr-nic-magic-awesome.gemspec_')).returns('JewelryPortfolio')
    @tasks_helper.portfolio.should == 'JewelryPortfolio'
  end
  
  it "should return a JewelryPortfolio instance without spec if none was found in the current work directory" do
    @tasks_helper = JewelryPortfolio::Tasks.new
    @tasks_helper.account = 'alloy'
    
    Dir.stubs(:glob).with('*.gemspec').returns([])
    
    JewelryPortfolio.expects(:new).with('alloy', nil).returns('JewelryPortfolio')
    @tasks_helper.portfolio.should == 'JewelryPortfolio'
  end
end