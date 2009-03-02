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