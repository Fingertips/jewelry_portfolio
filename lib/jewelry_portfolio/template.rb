require 'jewelry_portfolio/template/feed'
require 'jewelry_portfolio/template/html'

class JewelryPortfolio
  # This class is responsible for rendering a template.
  class Template
    class FileMissingError < StandardError; end
    class NotImplemented < StandardError; end
    
    # The full path to the template file.
    attr_reader :file
    
    # The directory in which the template resides.
    attr_reader :view_path
    
    # The account name on GitHub.
    attr_reader :account
    
    # The array of JewelryPortfolio::Repo instances.
    attr_reader :repos
    
    # Initialize with the path to the +template+, minus the extensions, and an
    # array of JewelryPortfolio::Repo instances as +repos+.
    def initialize(template_file, account, repos)
      @file = template_file
      verify_template!
      
      @view_path = File.dirname(@file)
      @account   = account
      @repos     = repos.to_a
    end
    
    def render
      raise NotImplemented, 'Needs to be implemented by the subclass.'
    end
    
    private
    
    def verify_template!
      raise FileMissingError, "Could not find template at path `#{@file}'" unless File.exist?(@file)
    end
  end
end