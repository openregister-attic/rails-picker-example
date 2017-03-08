require 'openregister'

module AnswersHelper
  def locations_for_select
    country_register = OpenRegister.register 'country'
    territory_register = OpenRegister.register 'territory'
    countries = country_register._records.map { |r| [r.name, r.country]}
    territories = territory_register._records.map { |r| [r.name, r.territory]}
    locations = countries + territories
    locations.sort { |x, y| x[0] <=> y[0] }
  end

  def location_code_to_name(location_code)
    locations_for_select.find{|l| l[1] == location_code}.first
  end
end
