require_relative "./consul_env/version"
require 'httparty'
require 'yaml'

module ConsulEnv
  def self.load_folder *folder, **opts
    if opts[:file_path]
      config_hash = load_from_yaml(opts[:file_path], *folder, **opts)
    elsif opts[:consul_url]
      config_hash = load_from_consul(opts[:consul_url], *folder, **opts)
    else
      raise ArgumentError, 'No data source supplied! Please supply a consul_url or file_path parameter.'
    end

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

    combined_config_hash = folder.reduce({}) do |final_hash, f|
      response = HTTParty.get("#{url}/v1/kv/#{f}?#{query_string}")

      vars_from_consul = response.map do |resp|
        {
          key: resp['Key'].gsub("#{f}/", ''),
          value: Base64.decode64(resp['Value'])
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
        key: key.gsub(/(#{folder.join('|')})\//, ''),
        value: val
      }
    end

    digest_vars(key_val_pairs, opts)
  end

  private

    def self.digest_vars variables, opts = nil
      opts ||= {}
      seed = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

      dropped_keys = ['env', *opts.fetch(:drop_prefixes, [])]

      variables.reduce(seed) do |accum, hashy|
        consul_key, val = hashy[:key].split('/'), hashy[:value]
        
        consul_key = consul_key - dropped_keys
        
        # After we drop out the prefixes we don't want (like env and the folder path)
        # we want to join them up and make it look idiomatically correct for an ENV hash
        # IE: SCREAMING_SNAKE_CASE
        accum.merge({ consul_key.join("_").upcase => val })
      end
    end
end
