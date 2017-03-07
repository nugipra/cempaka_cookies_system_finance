class Transaction < ApplicationRecord
  belongs_to :member

  validates_presence_of :quantity, :price
  before_save :update_total

  LEVEL_FEE = [5000, 1800, 1800, 1800, 1000, 1000, 1000, 300, 300, 300]

  def update_total
    self.total = self.quantity * self.price
  end
end
