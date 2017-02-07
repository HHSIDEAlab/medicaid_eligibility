require 'erb'
require 'csv'
template_string = File.open('config.erb', "rb").read

class RowHolder
   attr_accessor :row
end
CSV.foreach('ffmconfig.txt' , :headers => true, :col_sep => "\t", :quote_char => '"') do |row|
    template = ERB.new template_string
    print template.result(binding) + "\n"
end
