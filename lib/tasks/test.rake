desc "Run all test cases"

task :build do
  puts "Following are the Rspec tests"
  sh "rspec spec"
  puts "Following are the Unit tests"
  sh "rake test"
end

