class Transaction < ApplicationRecord
  belongs_to :member

  validates_presence_of :quantity, :price
  before_save :update_total

  def update_total
    self.total = self.quantity * self.price
  end
end
