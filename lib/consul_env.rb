require_relative "./consul_env/version"
require 'httparty'
require 'yaml'
require "net/http"
require "uri"


module ConsulEnv
  def self.load *folder, **opts
    file_path = opts[:file_path]

    if consul_available?
      config_hash = load_from_consul(consul_url, *folder, **opts)
    else
      config_hash = load_from_yaml(file_path, *folder, **opts)
    end

    # Remove any key that is already defined in the environment
    config_hash.delete_if { | key | ENV.has_key? key }

    ENV.update(config_hash)

    config_hash
  end

  def self.load_from_consul url, *folder, **opts
    opts[:token] ||= ENV['CONSUL_TOKEN'] if ENV['CONSUL_TOKEN']

    request_options = {
      recurse: true
    }

    request_options[:token] = opts[:token] if opts[:token]

    query_string = request_options.map { |k, v| "#{k}=#{v}" }.join('&')

    folder.reduce({}) do |final_hash, f|
      response = HTTParty.get("#{url}/v1/kv/#{f}?#{query_string}")

      vars_from_consul = response.map do |resp|
        value = resp['Value']
        value = Base64.decode64(value) if value

        {
          key: resp['Key'],
          value: value
        }
      end

      config_hash = digest_vars(vars_from_consul, opts)

      final_hash.merge(config_hash)
    end
  end

  def self.load_from_yaml yaml_path, *folder, **opts
    file = File.read(yaml_path)
    vars = YAML.load(file)

    reducer = -> (hashy, key_arr = [], accum = {}) do
      return accum.merge!( { key_arr.join('/') => hashy } ) unless hashy.is_a?(Hash)

      hashy.each_pair do |key, val|
        reducer.call(val, key_arr + [key], accum)
      end

      accum
    end

    consul_vars = reducer.call(vars['consul'].select { |k, v| folder.include?(k) })

    key_val_pairs = consul_vars.map do |key, val|
      {
        key: key,
        value: val
      }
    end

    digest_vars(key_val_pairs, opts)
  rescue Errno::ENOENT
    raise ArgumentError, 'Consul is not available and there is no yaml file at the specifed path.'
  end

  private

  def self.consul_url
    ENV.fetch('CONSUL_URL', 'http://localhost:8500')
  end

  def self.digest_vars variables, opts = nil
    opts ||= {}
    seed = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

    dropped_keys = [*opts.fetch(:drop_prefixes, [])]

    variables.reduce(seed) do |accum, hashy|
      consul_key, val = hashy[:key].split('/'), hashy[:value]

      consul_key = consul_key - dropped_keys

      # After we drop out the prefixes we don't want (like env and the folder path)
      # we want to join them up and make it look idiomatically correct for an ENV hash
      # IE: SCREAMING_SNAKE_CASE
      accum.merge({ consul_key.join("_").upcase => val })
    end
  end

  def self.consul_available?
    @@consul_available ||= begin
      # Checks to see if consul is available
      consul_uri = URI.parse("#{consul_url}/v1/agent/self")
      Net::HTTP.start(consul_uri.host, consul_uri.port) {|http|
        http.head(consul_uri.path)
      }
      true
    rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL
      false
    end
  end
end
