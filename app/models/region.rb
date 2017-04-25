class Region < ApplicationRecord
  has_many :members

  validates_presence_of :name
  validates_uniqueness_of :name, if: Proc.new{|r| r.name.present?}
end
