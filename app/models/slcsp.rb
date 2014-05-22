


module Slcsp

	def get_premium(state, age, county, family_size)
=begin	
		Sample code. Depending on what the algos for determining the slcp premium looks like this could be implemnted differently
		For example, depending on what makes sense to store in a db table it may not be necessary to have a case for each state+rating area,
		or it may not be necessary to use a case statement at all. If the difference state to to state or rating area to rating area ends up just being 
		some constant(s) that you multiple by then this can all be simplified. 

		case state.downcase
		when "idaho"
			case county.downcase
			when "county a", "county b", "county c"   #I imagine multiple counties can be in the same rating area?

			when "county d"

			when "county e"

			else "county f"

			end
		else

		end
=end
		
		#return some value for now
		3500
	end

end


