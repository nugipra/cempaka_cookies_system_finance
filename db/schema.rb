# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170312231304) do

  create_table "members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "member_id"
    t.string   "fullname"
    t.string   "email"
    t.integer  "upline_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "lft",                                             null: false
    t.integer  "rgt",                                             null: false
    t.integer  "network_depth",                default: 0,        null: false
    t.integer  "children_count",               default: 0,        null: false
    t.text     "address",        limit: 65535
    t.string   "telephone"
    t.integer  "wallet_balance",               default: 0
    t.string   "package",                      default: "silver"
  end

  create_table "network_commision_payments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "total_payment"
    t.string   "payment_method"
    t.integer  "member_id"
    t.text     "note",           limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["member_id"], name: "index_network_commision_payments_on_member_id", using: :btree
  end

  create_table "network_commisions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "member_id"
    t.integer  "descendant_id"
    t.integer  "commision"
    t.boolean  "paid",                         default: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "network_commision_payment_id"
    t.index ["descendant_id"], name: "index_network_commisions_on_descendant_id", using: :btree
    t.index ["member_id"], name: "index_network_commisions_on_member_id", using: :btree
  end

  create_table "transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "member_id"
    t.string   "product_name"
    t.integer  "price"
    t.integer  "quantity"
    t.text     "note",               limit: 65535
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "total"
    t.string   "payment_type",                     default: "cash"
    t.boolean  "referral",                         default: false
    t.integer  "referral_commision",               default: 0
    t.index ["member_id"], name: "index_transactions_on_member_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "wallet_transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "member_id"
    t.text     "remarks",             limit: 65535
    t.integer  "amount"
    t.integer  "balance"
    t.string   "transaction_type"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "remarks_object_id"
    t.string   "remarks_object_type"
    t.index ["member_id"], name: "index_wallet_transactions_on_member_id", using: :btree
  end

  add_foreign_key "network_commision_payments", "members"
  add_foreign_key "network_commisions", "members"
  add_foreign_key "transactions", "members"
  add_foreign_key "wallet_transactions", "members"
end
