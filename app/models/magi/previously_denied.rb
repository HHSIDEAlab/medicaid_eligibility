# encoding: UTF-8

module MAGI
    class PreviouslyDenied < Ruleset
      input "Previously Denied", "From Previous Determination", "Char(1)", %w(Y N)

      # Outputs
      output "Previously Denied", "Char(1)", %w(Y N)

      rule "Passthrough previously denied" do
        o["Previously Denied"] = v("Previously Denied")
      end
    end
  end
