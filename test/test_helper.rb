require 'rubygems'
require 'test/spec'
require 'mocha'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'repo_page_san'

TMP_PATH = File.expand_path('../tmp', __FILE__)
FileUtils.mkdir_p(TMP_PATH) unless File.exist?(TMP_PATH)

TMP_PAGES_REPO = File.join(TMP_PATH, 'alloy.github.com.git')

FIXTURE_PATH = File.expand_path('../fixtures', __FILE__)

`cd #{FIXTURE_PATH} && tar zxvf alloy.github.com.tgz` unless File.exist?(File.join(FIXTURE_PATH, 'alloy.github.com'))

class Test::Unit::TestCase
  def fixture(file)
    File.join(FIXTURE_PATH, file)
  end
  
  def fixture_read(file)
    File.read(fixture(file))
  end
  
  def fixture_eval(name)
    eval(fixture_read(name))
  end
end
