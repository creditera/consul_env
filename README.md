# ConsulEnv

ConsulEnv is a tiny ruby gem for importing variables from Consul's Key/Value store into your project's environment.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'consul_env', git: 'https://github.com/creditera/consul_env.git'
```

And then execute:
```bash
 $ bundle
```
Or install it yourself as:
```bash
 $ gem install consul_env
```
## Usage

ConsulEnv is meant to be used when your application boots. For Rails projects, put the following code in an initializer, for non-Rails projects, just make sure this code happens before anything depending on the environment variables happens.

```ruby
ConsulEnv.load_folder 'ALS', consul_url: 'http://localhost:8500'
```

This will load all of the variables under the specified `ALS/` namespace and set them in your local `ENV`.

### From YAML

Occasionally, you may not be able (or want) to connect to a running Consul instance. In these cases, you can use a formatted YAML file to obtain the same results.

```ruby
ConsulEnv.load_folder 'ALS', file_path: '/path/to/your/yaml'
```

This method of loading variables expects a YAML file with the following format:

```yaml
consul:
  ALS:
    env:
      foo: 'bar'
      baz: 'flar'
```

### Variable Naming

`ConsulEnv` will convert all variables loaded to `SCREAMING_SNAKE_CASE`. By default, it will drop the specified parent namespace (`ALS` in our examples), as well as the keyword `env` from the end variable names.

This means, in our YAML example above, the final variable names will be simply `ENV['FOO']` and `ENV['BAR']`.

Any additional namespacing after that will be collected and converted to `SCREAMING_SNAKE_CASE`. So, say we've got a variable in our Consul K/V store located at `ALS/foo/bar/baz`. `ConsulEnv` will convert that to `ENV['FOO_BAR_BAZ']`. This can be helpful if you want to specify database variables under a `db` namespace (resulting in variables like `ENV['DB_USER']`) alongside your `env` namespace, and so on.

### Dropping Prefixes

You can tell `ConsulEnv` to drop additional folder prefixes that you don't want to show up in your final variable name.

Let's again take the example variable located at `ALS/foo/bar/baz` in Consul's K/V store. If you wanted the end variable to be named `ENV['BAZ']`, you would give `ConsulEnv` a `drop_prefixes` option.

```ruby
ConsulEnv.load_folder 'ALS', consul_url: 'http://localhost:8500', drop_prefixes: ['foo', 'bar']
```