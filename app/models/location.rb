class Location < ApplicationRecord
  validates :code, presence: true, length: { maximum: 30 }
  validates :name, presence: true, length: { maximum: 100 }
end
