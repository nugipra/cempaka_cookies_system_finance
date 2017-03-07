class NetworkCommisionPayment < ApplicationRecord
  belongs_to :member
  has_many :network_commisions
end
