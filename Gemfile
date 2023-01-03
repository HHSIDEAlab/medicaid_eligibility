source 'https://rubygems.org'
ruby '~> 2.3.0'

gem 'rails', '~> 4.0'
gem 'newrelic_rpm'
gem 'rails-api'
gem 'activerecord-nulldb-adapter'
gem 'active_model_serializers', '~> 0.8.0'
gem 'font-awesome-rails'
gem 'uglifier', '~> 2.7.2'
gem 'gon'
gem 'httparty', '~> 0.21.0'
gem 'rails_12factor'

# Use unicorn as the app server
gem 'unicorn'

group :development do
  gem 'rails_best_practices', require: false
  gem 'brakeman', require: false
  gem 'rubocop', require: false
  gem 'bundler-audit', require: false
  # Deploy with Capistrano
  gem 'capistrano'
end

group :development, :test do
  gem 'jasmine'
  gem 'spring'
end

group :test do
  gem 'minitest-rails', '~> 1.0'
  gem 'minitest-reporters'
  # gem 'mini_backtrace'
end

# fixing a few travisCI complaints
gem 'rake', group: :test
gem 'test-unit'
