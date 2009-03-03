Gem::Specification.new do |s|
  s.name = %q{jewelry_portfolio}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eloy Duran"]
  s.date = %q{2009-03-03}
  s.description = %q{Imagine writing an erb template once and use rake release to release your gem with Jeweler as usual, but in addition re-generate and push the index.html for your GitHub pages. If that sounds good to you, you're in luck. Because that's exactly what this add-on for Jeweler does.}
  s.email = %q{eloy.de.enige@gmail.com}
  s.files = ["README.rdoc", "VERSION.yml", "lib/jewelry_portfolio", "lib/jewelry_portfolio/repo.rb", "lib/jewelry_portfolio/repos_index.rb", "lib/jewelry_portfolio/tasks.rb", "lib/jewelry_portfolio/template.rb", "lib/jewelry_portfolio.rb", "test/fixtures", "test/fixtures/alloy.github.com", "test/fixtures/alloy.github.com/index.html", "test/fixtures/alloy.github.com/repo.html.erb", "test/fixtures/alloy.github.com/repos.yml", "test/fixtures/alloy.github.com/template.html.erb", "test/fixtures/alloy.github.com.tgz", "test/fixtures/dr-nic-magic-awesome.gemspec_", "test/fixtures/dr-nic-magic-awesome.html", "test/fixtures/dr-nic-magic-awesome_repo.yml", "test/fixtures/microgem.gemspec_", "test/fixtures/repo.html.erb", "test/fixtures/repos.yml", "test/fixtures/template.html", "test/fixtures/template.html.erb", "test/jewelry_portfolio_test.rb", "test/repo_test.rb", "test/repos_index_test.rb", "test/tasks_test.rb", "test/template_test.rb", "test/test_helper.rb", "test/tmp", "test/tmp/alloy.github.com.git", "test/tmp/alloy.github.com.git/index.html", "test/tmp/alloy.github.com.git/repo.html.erb", "test/tmp/alloy.github.com.git/repos.yml", "test/tmp/alloy.github.com.git/template.html.erb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/alloy/repo_page_san}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{An add-on for Jeweler for lazy developers who would like to showcase their jewelry portfolio on their GitHub pages.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
