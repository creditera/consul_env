require_relative "./consul_env/version"
require 'httparty'

module ConsulEnv
  def self.load_folder folder, **opts
    url = opts.fetch(:consul_url, "http://localhost:8500")
    opts[:token] ||= ENV['CONSUL_TOKEN'] if ENV['CONSUL_TOKEN']

    request_options = {
      recurse: true
    }

    request_options[:token] = opts[:token] if opts[:token]

    query_string = request_options.map { |k, v| "#{k}=#{v}" }.join('&')

    response = HTTParty.get("#{url}/v1/kv/#{folder}?#{query_string}")

    vars_from_consul = response.map do |resp|
      {
        key: resp['Key'],
        value: Base64.decode64(resp['Value'])
      }
    end

    seed = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

    dropped_keys = [folder, 'env']

    config_hash = vars_from_consul.reduce(seed) do |accum, hashy|
      consul_key, val = hashy[:key].split('/'), hashy[:value]
      
      consul_key = consul_key - dropped_keys
      
      # After we drop out the prefixes we don't want (like env and the folder path)
      # we want to join them up and make it look idiomatically correct for an ENV hash
      # IE: SCREAMING_SNAKE_CASE
      accum.merge({ consul_key.join("_").upcase => val })
    end

    ENV.update(config_hash)

    config_hash
  end
end
