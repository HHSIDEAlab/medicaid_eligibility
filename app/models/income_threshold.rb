module IncomeThreshold
  def get_income(threshold, percentage, monthly, add_disregard = true)
    if percentage == 'Y'
      return (threshold + (add_disregard ? 5 : 0)) * 0.01 * v('FPL')
    elsif percentage == 'N'
      disregard = (add_disregard ? 0.05 * v('FPL') : 0)

      if monthly == 'Y'
        return threshold * 12 + disregard
      else
        return threshold + disregard
      end
    else
      raise 'Invalid state config'
    end
  end

  def get_threshold(category)
    if category['varies_yearly'] == 'Y'
      return get_threshold(category[v('Application Year').to_s])
    end

    if category['method'] == 'standard'
      threshold = category['threshold']
    elsif category['method'] == 'household_size'
      thresholds = category['household_size']
      household_size = v('Medicaid Household').household_size
      if household_size < thresholds.length
        threshold = thresholds[household_size]
      else
        threshold = thresholds.last + (household_size - thresholds.length + 1) * category['additional person']
      end
    elsif category['method'] == 'age'
      age_group = category['age'].find { |group| v('Applicant Age') >= group['minimum'] && v('Applicant Age') <= group['maximum'] }
      if age_group
        threshold = age_group['threshold']
      else
        raise "No threshold defined for applicant age #{v('Applicant Age')}"
      end
    else
      raise "Undefined threshold method #{category['method']}"
    end

    if category['includes_disregard'] == 'Y'
      get_income(threshold, category['percentage'], category['monthly'], add_disregard = false)
    else
      get_income(threshold, category['percentage'], category['monthly'])
    end
  end
end
