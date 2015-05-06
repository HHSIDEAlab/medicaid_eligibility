ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'minitest/spec'
Minitest::Reporters.use!
require 'curb' 

class ActiveSupport::TestCase
	Rails.backtrace_cleaner.remove_silencers! # for messier errors

end
