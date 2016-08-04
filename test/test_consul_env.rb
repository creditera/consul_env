require 'test_helper'

class TestConsulEnv < MiniTest::Test
  def test_exists
    assert defined?(ConsulEnv)
  end

  def folder
    'ALS'
  end

  def test_load_folder
    HTTParty.stub :get, ALS_CONSUL_FOLDER do
      ConsulEnv.load_folder folder

      assert_equal 'db_user', ENV['DB_USER']
    end
  end

  def test_load_folder_with_env
    HTTParty.stub :get, ALS_CONSUL_FOLDER do
      ConsulEnv.load_folder folder

      assert_equal 'tomcat_url', ENV['TOMCAT_SERVER']
    end
  end

  def test_load_folder_with_config
    HTTParty.stub :get, ALS_CONSUL_FOLDER do
      ConsulEnv.load_folder folder, consul_url: "http://localhost:8500"

      assert_equal 'tomcat_url', ENV['TOMCAT_SERVER']
    end
  end

  def test_dropped_prefixes
    HTTParty.stub :get, NAV_CONSUL_FOLDER do
      ConsulEnv.load_folder 'NAV', consul_url: "http://localhost:8500", drop_prefixes: ['common', 'urls']

      assert_equal 'tomcat_url', ENV['TOMCAT_URL']
    end
  end

  def test_multiple_folders
    HTTParty.stub :get, [*ALS_CONSUL_FOLDER, *NAV_CONSUL_FOLDER] do
      ConsulEnv.load_folder 'NAV', 'ALS', consul_url: "http://localhost:8500", drop_prefixes: ['common', 'urls']

      assert_equal 'tomcat_url', ENV['TOMCAT_URL']
    end
  end
end