require 'rubygems'
require 'test/spec'
require 'mocha'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'repo_page_san'

FIXTURE_PATH = File.expand_path('../fixtures', __FILE__)

class Test::Unit::TestCase
  def fixture(file)
    File.join(FIXTURE_PATH, file)
  end
  
  def fixture_read(file)
    File.read(fixture(file))
  end
end
