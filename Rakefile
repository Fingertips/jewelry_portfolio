require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "jewelry_portfolio"
    
    s.authors = ["Eloy Duran"]
    s.email = "eloy.de.enige@gmail.com"
    s.homepage = "http://github.com/alloy/repo_page_san"
    
    s.summary = %Q{ An add-on for Jeweler for lazy developers who would like to showcase their jewelry portfolio on their GitHub pages. }
    s.description = %{
      Imagine writing an erb template once and use rake release to release
      your gem with Jeweler as usual, but in addition re-generate and push the
      index.html for your GitHub pages. If that sounds good to you, you're in luck.
      Because that's exactly what this add-on for Jeweler does.
    }
  end
  
  begin
    require 'jewelry_portfolio/tasks'
    JewelryPortfolio::Tasks.new do |t|
      #t.account = 'Fingertips'
    end
  rescue LoadError
    puts "JewelryPortfolio not available. Install it with: sudo gem install Fingertips-jewelry_portfolio -s http://gems.github.com"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'Jewelry Portfolio'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = false
end

task :default => :test

desc "Generates the gzipped tarball of the alloy.github.com repo fixture"
task :generate_repo_fixture_archive do
  fixtures = File.expand_path('../test/fixtures', __FILE__)
  repo = 'alloy.github.com'
  archive = "#{repo}.tgz"
  
  rm_rf File.join(fixtures, archive)
  sh "cd '#{fixtures}' && tar czf #{archive} #{repo}"
end