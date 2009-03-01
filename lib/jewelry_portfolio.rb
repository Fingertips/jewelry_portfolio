require 'jewelry_portfolio/repo'
require 'jewelry_portfolio/repos_index'
require 'jewelry_portfolio/template'

class JewelryPortfolio
  class FileMissingError < StandardError; end
  
  attr_reader :account, :spec, :index, :template
  
  # Initializes a JewelryPortfolio instance for the specified +account+.
  #
  # If an optional +spec+ is provided it will be added to, or updated in, the
  # index. If no +spec+ is provided it is assumed you are working in a clone of
  # your GitHub pages repo. In this case no fetching and merging will be
  # performed.
  def initialize(account, spec = nil)
    @account  = account
    @spec     = spec
    @index    = ReposIndex.new(@account, (Dir.pwd unless @spec))
    @template = Template.new(File.join(@index.path, 'template'), @index.repos)
    
    @index.add(@spec) if @spec
  end
  
  # Renders the index.html file.
  def render!
    puts "Generating html"
    File.open(File.join(@index.path, 'index.html'), 'w') { |f| f << @template.render }
  end
  
  # Renders the index.html file, then commits and pushes it to the remote.
  def release!
    render!
    @index.commit! commit_message
    @index.push!
  end
  
  private
  
  def commit_message
    if @spec
      "Updated github pages for: #{@spec.name}-#{@spec.version}"
    else
      "Re-generated github pages"
    end
  end
end