require 'openregister'

module AnswersHelper
  def locations_for_select
    Location.pluck(:name, :code)
  end

  def location_code_to_name(location_code)
    locations_for_select.find{|l| l[1] == location_code}.first
  end
end
