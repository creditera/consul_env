require 'test_helper'

class TestConsulEnv < MiniTest::Test
  def test_exists
    assert defined?(ConsulEnv)
  end

  def folder
    'ALS'
  end

  def test_load_folder
    HTTParty.stub :get, CONSUL_RESPONSE do
      ConsulEnv.load_folder folder

      assert_equal 'db_user', ENV['DB_USER']
    end
  end

  def test_load_folder_with_env
    HTTParty.stub :get, CONSUL_RESPONSE do
      ConsulEnv.load_folder folder

      assert_equal 'tomcat_url', ENV['TOMCAT_SERVER']
    end
  end

  def test_load_folder_with_config
    HTTParty.stub :get, CONSUL_RESPONSE do
      ConsulEnv.load_folder folder, consul_url: "http://localhost:8500"

      assert_equal 'tomcat_url', ENV['TOMCAT_SERVER']
    end
  end
end