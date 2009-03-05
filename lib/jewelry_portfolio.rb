require 'jewelry_portfolio/repo'
require 'jewelry_portfolio/repos_index'
require 'jewelry_portfolio/template'

class JewelryPortfolio
  attr_reader :account, :repo, :index, :html_template, :feed_template
  
  # Initializes a JewelryPortfolio instance for the specified +account+.
  #
  # If an optional +repo+ is provided it will be added to, or updated in, the
  # index. If no +repo+ is provided it is assumed you are working in a clone of
  # your GitHub pages repo. In this case no fetching and merging will be
  # performed.
  def initialize(account, repo = nil)
    raise ArgumentError, "No `account' given." unless account
    raise ArgumentError, "No valid `repo' given." if repo && !repo.valid?
    
    @account = account
    @repo    = repo
    @index   = ReposIndex.new(@account, (Dir.pwd unless @repo))
    
    @index.add(@repo) if @repo
    
    @html_template = template(Template::HTML, 'index.erb')
    @feed_template = template(Template::Feed, 'feed.rb')
  end
  
  # Renders the index.html file.
  def render!
    write_out('HTML', 'index.html', @html_template.render)
    write_out('feed', 'feed.xml', @feed_template.render)
  end
  
  # Renders the index.html file, then commits and pushes it to the remote.
  def release!
    render!
    @index.commit! commit_message
    @index.push!
  end
  
  private
  
  def template(klass, file)
    klass.new(File.join(@index.path, file), @account, @index.repos)
  end
  
  def write_out(message, file, data)
    puts "Generating #{message}"
    File.open(File.join(@index.path, file), 'w') { |f| f << data }
  end
  
  def commit_message
    if @repo
      "Updated github pages for: #{@repo.name}-#{@repo.version}"
    else
      "Re-generated github pages"
    end
  end
end