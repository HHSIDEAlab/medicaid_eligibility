source 'https://rubygems.org'
ruby '2.3.3'

gem 'rails', '3.2.22.5'
gem 'newrelic_rpm'
gem 'rails-api'
gem 'activerecord-nulldb-adapter'
gem 'active_model_serializers'
gem 'font-awesome-rails'
gem 'uglifier', '~> 2.7.2'
gem 'gon'
gem 'httparty', '~> 0.10.0'
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
  gem 'faker'
  gem 'sqlite3'
end

# fixing a few travisCI complaints
gem 'rake', group: :test
gem 'test-unit'
