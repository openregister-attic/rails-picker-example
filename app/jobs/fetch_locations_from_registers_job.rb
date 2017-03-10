require "openregister"

class FetchLocationsFromRegistersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    locations.each do |l|
      location = Location.find_or_initialize_by(code: l[:code])

      location.name = l[:name]
      location.start_date = l[:start_date]
      location.end_date = l[:end_date]

      if location.changed? || location.new_record?
        location.save!
      end
    end
  end

  private

  def countries
    country_register = OpenRegister.register 'country'
    country_register._all_records.map { |r|
      { code: r.country, name: r.name, start_date: r.start_date, end_date: r.end_date }
    }
  end

  def territories
    territory_register = OpenRegister.register 'territory'
    territory_register._all_records.map { |r|
      { code: r.territory, name: r.name, start_date: r.start_date, end_date: r.end_date }
    }
  end

  def locations
    countries + territories
  end
end
