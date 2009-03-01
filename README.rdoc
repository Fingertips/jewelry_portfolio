== JewelryPortfolio

=== Usage

  begin
    require 'jeweler'
    Jeweler::Tasks.new do |s|
      # ...
    end
    
    # Add the following to your Rakefile to use JewelryPortfolio
    begin
      require 'jewelry_portfolio/tasks'
    rescue LoadError
      puts "JewelryPortfolio not available. Install it with: sudo gem install Fingertips-jewelry_portfolio -s http://gems.github.com"
    end
    
  rescue LoadError
    puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
  end

=== COPYRIGHT

Copyright (c) 2008 Eloy Duran. See LICENSE for details.