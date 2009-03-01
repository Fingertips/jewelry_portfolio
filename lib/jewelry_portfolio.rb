require 'jewelry_portfolio/repo'
require 'jewelry_portfolio/repos_index'
require 'jewelry_portfolio/template'

class JewelryPortfolio
  class FileMissingError < StandardError; end
  
  attr_reader :account, :spec, :index, :template
  
  def initialize(account, options = {})
    @account  = account
    @spec     = options[:spec]
    @index    = ReposIndex.new(@account, options[:work_directory])
    @template = Template.new(File.join(@index.path, 'template'), @index.specs)
    
    @index.add(@spec) if @spec
  end
  
  def render!
    puts "Generating html"
    File.open(File.join(@index.path, 'index.html'), 'w') { |f| f << @template.render }
  end
  
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