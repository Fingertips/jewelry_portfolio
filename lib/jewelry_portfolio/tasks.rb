require 'jewelry_portfolio'

namespace :portfolio do
  desc "Generate the HTML"
  task :generate do
    portfolio.render!
    sh "open '#{File.join(portfolio.index.path, 'index.html')}'"
  end
  
  desc "Generates the HTML and commits and pushes the new release"
  task :release do
    portfolio.release!
  end
  
  private
  
  def portfolio
    if @portfolio.nil?
      if spec_file = Dir.glob('*.gemspec').first
        spec = eval(File.read(spec_file))
      end
      @portfolio = JewelryPortfolio.new('alloy', spec)
    end
    @portfolio
  end
end