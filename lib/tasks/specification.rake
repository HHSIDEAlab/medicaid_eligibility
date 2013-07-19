namespace :specification do
  desc "Generate initial inputs"
  task :variables => :environment do 
    Dir[Rails.root + 'app/models/**/*.rb'].each do |path|
      require path
    end

    rulesets = Ruleset.subclasses

    configs = rulesets.inject({}){|h, r| h.merge r.configs}
    outputs = rulesets.inject({}){|h, r| h.merge r.outputs}
    inputs = rulesets.inject({}){|h, r| h.merge r.inputs}.select{|k,_| !(outputs.member? k)}

    File.open(Rails.root + 'config/specification/configs.json', 'w') {|f| f.write(JSON.pretty_generate configs)}
    File.open(Rails.root + 'config/specification/outputs.json', 'w') {|f| f.write(JSON.pretty_generate outputs)}
    File.open(Rails.root + 'config/specification/inputs.json', 'w') {|f| f.write(JSON.pretty_generate inputs)}
  end
end
