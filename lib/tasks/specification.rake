namespace :specification do
  desc "Generate initial inputs"
  task :variables => :environment do
    Dir[Rails.root + 'app/models/**/*.rb'].each do |path|
      require path
    end

    rulesets = Ruleset.subclasses

    base_variables = {
      "State" => {
        :name => "State",
        :type => "Char(2)"
      }
    }

    configs = rulesets.inject({}){|h, r| h.merge r.configs}
    outputs = base_variables.merge(rulesets.inject({}){|h, r| h.merge r.outputs})
    inputs = base_variables.merge(rulesets.inject({}){|h, r| h.merge r.inputs}.select{|k,_| !(outputs.member? k)})

    configs, outputs, inputs = [configs, outputs, inputs].map{|vars| Hash[*(vars.to_a.sort{|a,b| a.first <=> b.first}.flatten)]}

    File.open(Rails.root + 'config/specification/configs.json', 'w') {|f| f.write(JSON.pretty_generate configs)}
    File.open(Rails.root + 'config/specification/outputs.json', 'w') {|f| f.write(JSON.pretty_generate outputs)}
    File.open(Rails.root + 'config/specification/inputs.json', 'w') {|f| f.write(JSON.pretty_generate inputs)}
  end

  task :inputs => :environment do
    File.open(Rails.root + 'config/specification/input_list.json', 'w') {|f|
      inputs = {:person => []}
      for input in ApplicationVariables::PERSON_INPUTS
        if input[:xml_group] == :applicant
          xpath = "/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/" + input[:xpath]
        elsif input[:xml_group] == :person
          xpath = "/exch:AccountTransferRequest/hix-core:Person/" + input[:xpath]
        else
          xpath = "Undefined"
        end

        input_hash = {
          :name   => input[:name],
          :type   => input[:type],
          :xpath  => xpath
        }
        if input[:values]
          input_hash[:valid_values] = input[:values]
        end
        inputs[:person] << input_hash
      end

      f.write(JSON.pretty_generate inputs)
    }
  end
end
