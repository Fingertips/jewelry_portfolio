require File.expand_path('../test_helper', __FILE__)

describe "RepoPageSan::Page" do
  before do
    @page = RepoPageSan::Page.new(fixture('template.html.erb'))
  end
  
  it "should return the path to the template" do
    @page.template.should == fixture('template.html.erb')
  end
  
  it "should render a template with the given object available as `spec'" do
    File.stubs(:read).returns('<h1><%= spec[:name] %></h1>')
    spec = { :name => 'drnic-magic-awesome' }
    
    @page.render(spec).should == '<h1>drnic-magic-awesome</h1>'
  end
  
  it "should render the template file with the given object" do
    @page.render(:title => 'Expected Template Output').should ==
      File.read(fixture('expected_template_output.html'))
  end
end