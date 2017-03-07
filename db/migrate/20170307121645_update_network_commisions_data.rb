class UpdateNetworkCommisionsData < ActiveRecord::Migration[5.0]
  def up
    Member.all.each do |member|
      member.generate_network_commisions
    end
  end

  def down
  end
end
