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
      result = ConsulEnv.load_folder folder, consul_url: "http://localhost:8500"

      assert_equal 'db_user', result['DB_USER']
    end
  end

  def test_load_folder_with_env
    HTTParty.stub :get, ALS_CONSUL_FOLDER do
      result = ConsulEnv.load_folder folder, consul_url: "http://localhost:8500"

      assert_equal 'tomcat_url', result['TOMCAT_SERVER']
    end
  end

  def test_load_folder_with_config
    HTTParty.stub :get, ALS_CONSUL_FOLDER do
      result = ConsulEnv.load_folder folder, consul_url: "http://localhost:8500"

      assert_equal 'tomcat_url', result['TOMCAT_SERVER']
    end
  end

  def test_dropped_prefixes
    HTTParty.stub :get, NAV_CONSUL_FOLDER do
      result = ConsulEnv.load_folder 'NAV', consul_url: "http://localhost:8500", drop_prefixes: ['common', 'urls']

      assert_equal 'tomcat_url', result['TOMCAT_URL']
    end
  end

  def test_multiple_folders
    HTTParty.stub :get, [*ALS_CONSUL_FOLDER, *NAV_CONSUL_FOLDER] do
      result = ConsulEnv.load_folder 'NAV', 'ALS', consul_url: "http://localhost:8500", drop_prefixes: ['common', 'urls']

      assert_equal 'tomcat_url', result['TOMCAT_URL']
    end
  end

  def test_load_from_yaml
    yaml_path = "#{`pwd`.chomp}/test/test_vars.yml"

    result = ConsulEnv.load_folder 'NAV', 'ALS', file_path: yaml_path, drop_prefixes: ['common', 'urls']
    
    assert_equal 'tomcat_url', result['TOMCAT_URL']
    assert_equal 'redis_url', result['REDIS_URL']
  end

  def test_raises_error_without_source_option
    assert_raises(ArgumentError) { ConsulEnv.load_folder 'NAV' }
  end
end