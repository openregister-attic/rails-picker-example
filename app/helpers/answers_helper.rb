module AnswersHelper
  def locations_for_select
    JSON.parse(File.read('public/location-picker-canonical-list.json'))
  end

  def location_code_to_name(location_code)
    locations_for_select.find{|l| l[1] == location_code}.first
  end
end
