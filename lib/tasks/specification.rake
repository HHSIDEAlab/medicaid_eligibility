namespace :specification do
  desc "Generate initial inputs"
  task :variables => :environment do 
    Dir[Rails.root + 'app/models/**/*.rb'].each do |path|
      require path
    end

    rulesets = Ruleset.subclasses

    base_variables = {
      "Applicant Number" => {
        :name => "Applicant Number", 
        :type => "Integer"
      }, 
      "State" => {
        :name => "State", 
        :type => "Char(2)"
      }
    }

    configs = rulesets.inject({}){|h, r| h.merge r.configs}
    outputs = base_variables.merge(rulesets.inject({}){|h, r| h.merge r.outputs})
    inputs = base_variables.merge(rulesets.inject({}){|h, r| h.merge r.inputs}.select{|k,_| !(outputs.member? k)})
    
    default_configs = configs.select{|_,v| v.has_key? :default}.inject({}){|new_hash, (k,v)| new_hash.merge({k => v[:default]})}

    File.open(Rails.root + 'config/specification/configs.json', 'w') {|f| f.write(JSON.pretty_generate configs)}
    File.open(Rails.root + 'config/specification/outputs.json', 'w') {|f| f.write(JSON.pretty_generate outputs)}
    File.open(Rails.root + 'config/specification/inputs.json', 'w') {|f| f.write(JSON.pretty_generate inputs)}
    File.open(Rails.root + 'config/specification/config_default.json', "w") {|f| f.write(JSON.pretty_generate default_configs)}
  end
end
