require 'helper'

class TestTestSession < Test::Unit::TestCase
  should "do something" do
    TestKit::Session.new(Dir.pwd+'/test/rails_app')
  end
end
