class NetworkCommision < ApplicationRecord
  belongs_to :member
  belongs_to :descendant, class_name: "Member"
end
