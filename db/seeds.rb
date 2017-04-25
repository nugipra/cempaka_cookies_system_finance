# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


WalletTransaction.delete_all
NetworkCommision.delete_all
Transaction.delete_all
Member.delete_all
User.delete_all
Region.delete_all


User.create(email: "admin@cempakacookies.com", password: "theAdmin", password_confirmation: "theAdmin")

region = Region.where(name: "Bandung").first_or_create

company = Member.create(member_id: Member::COMPANY_MEMBER_ID, fullname: "dDanus Cempaka Cookies", email: "cempaka88cookies@gmail.com", region_id: region.id)
company.update_column :the_admin, true

owner = Member.create(member_id: Member::OWNER_MEMBER_ID, fullname: "Andri Hidayatulloh / Kenni Santika", email: "andri.online@gmail.com", upline_id: company.id, region_id: region.id)
owner.update_column :the_admin, true

web_dev = Member.create(member_id: Member::WEB_DEV_MEMBER_ID, fullname: "Nugi Nugraha", email: "byakugie@gmail.com", upline_id: owner.id, region_id: region.id)
web_dev.update_column :the_admin, true

admin = Member.create(member_id: Member::ADMIN_MEMBER_ID, fullname: "Siti Nurjanah", email: "citijanah.sn@gmail.com", upline_id: web_dev.id, region_id: region.id)
admin.update_column :the_admin, true
