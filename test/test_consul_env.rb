require 'test_helper'

class TestConsulEnv < MiniTest::Test
  def test_exists
    assert defined?(ConsulEnv)
  end
end