require File.expand_path('../test_helper', __FILE__)

class GemSpecMock
  attr_accessor :name, :description
  
  def initialize(name, description)
    @name, @description = name, description
  end
end

describe "RepoPageSan::Page" do
  before do
    @specs = [
      GemSpecMock.new('dr-nic-magic-awesome', 'Magically fix your projects overnight!'),
      GemSpecMock.new('microgem', 'Clean room implementation of the rubygems ‘install’ command.')
    ]
    
    @page = RepoPageSan.new(fixture('template'), @specs)
  end
  
  it "should return the path to the template" do
    @page.template.should == fixture('template.html.erb')
  end
  
  it "should return the specs" do
    @page.specs.should == @specs
  end
  
  it "should return the view_path" do
    @page.view_path.should == FIXTURE_PATH
  end
  
  it "should render with the specified gem specs available as `specs'" do
    File.stubs(:read).returns('<%= specs.inspect %>')
    @page.render.should == @specs.inspect
  end
  
  it "should render an ERB partial with the specified local variables" do
    @page.partial('spec', :spec => @specs.first).should ==
      File.read(fixture('dr-nic-magic-awesome.html'))
  end
  
  it "should render an ERB partial with the specified spec" do
    @page.spec_partial(@specs.first).should ==
      File.read(fixture('dr-nic-magic-awesome.html'))
  end
  
  it "should render an ERB partial with the specified spec and local variables" do
    File.stubs(:read).returns('<%= "#{spec} #{extra_var}" %>')
    @page.spec_partial('spec_value', :extra_var => 'extra_var_value').should == 'spec_value extra_var_value'
  end
  
  it "should render the ERB template" do
    @page.render.should == File.read(fixture('template.html'))
  end
end