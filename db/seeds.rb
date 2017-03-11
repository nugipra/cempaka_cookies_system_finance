# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(email: "admin@cempakacookies.com", password: "theAdmin", password_confirmation: "theAdmin")

company = Member.create(member_id: Member::COMPANY_MEMBER_ID, fullname: "dDanus Cempaka Cookies", email: "cempaka88cookies@gmail.com")
owner = Member.create(member_id: Member::OWNER_MEMBER_ID, fullname: "Andri Hidayatulloh / Kenni Santika", email: "andri.online@gmail.com", upline_id: company.id)
web_dev = Member.create(member_id: Member::WEB_DEV_MEMBER_ID, fullname: "Nugi Nugraha", email: "byakugie@gmail.com", upline_id: owner.id)
admin = Member.create(member_id: Member::ADMIN_MEMBER_ID, fullname: "Siti Nurjanah", email: "citijanah.sn@gmail.com", upline_id: web_dev.id)
