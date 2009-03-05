# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jewelry_portfolio}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eloy Duran"]
  s.date = %q{2009-03-05}
  s.description = %q{Imagine writing an erb template once and use rake portfolio:release to generate and push the index.html for your GitHub pages. If that sounds good to you, you're in luck. Because that's exactly what this gem does.}
  s.email = %q{eloy.de.enige@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["README.rdoc", "VERSION.yml", "lib/jewelry_portfolio", "lib/jewelry_portfolio/repo.rb", "lib/jewelry_portfolio/repos_index.rb", "lib/jewelry_portfolio/tasks.rb", "lib/jewelry_portfolio/template", "lib/jewelry_portfolio/template/feed.rb", "lib/jewelry_portfolio/template/html.rb", "lib/jewelry_portfolio/template.rb", "lib/jewelry_portfolio.rb", "test/fixtures", "test/fixtures/alloy.github.com", "test/fixtures/alloy.github.com/feed.rb", "test/fixtures/alloy.github.com/feed.xml", "test/fixtures/alloy.github.com/index.erb", "test/fixtures/alloy.github.com/index.html", "test/fixtures/alloy.github.com/repos.yml", "test/fixtures/alloy.github.com.tgz", "test/fixtures/dr-nic-magic-awesome.gemspec_", "test/fixtures/dr-nic-magic-awesome.html", "test/fixtures/dr-nic-magic-awesome_repo.yml", "test/fixtures/feed_with_defaults.rb", "test/fixtures/feed_with_defaults.xml", "test/fixtures/feed_with_options.rb", "test/fixtures/feed_with_options.xml", "test/fixtures/index.erb", "test/fixtures/index.html", "test/fixtures/microgem.gemspec_", "test/fixtures/repos.yml", "test/jewelry_portfolio_test.rb", "test/repo_test.rb", "test/repos_index_test.rb", "test/tasks_test.rb", "test/template_test.rb", "test/test_helper.rb", "test/tmp", "test/tmp/alloy.github.com.git", "test/tmp/alloy.github.com.git/feed.rb", "test/tmp/alloy.github.com.git/feed.xml", "test/tmp/alloy.github.com.git/index.erb", "test/tmp/alloy.github.com.git/index.html", "test/tmp/alloy.github.com.git/repos.yml", "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/alloy/repo_page_san}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A template renderer, and rake tasks, for lazy developers who would like to showcase their jewelry portfolio (libraries) on their GitHub pages.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<schacon-git>, [">= 0"])
    else
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<schacon-git>, [">= 0"])
    end
  else
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<schacon-git>, [">= 0"])
  end
end
