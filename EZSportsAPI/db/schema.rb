# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20190420121030) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coaches", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_cards", force: :cascade do |t|
    t.integer "user_id"
    t.string  "last_4"
    t.string  "customer_id"
    t.string  "token"
  end

  add_index "credit_cards", ["user_id"], name: "index_credit_cards_on_user_id", using: :btree

  create_table "game_schedules", force: :cascade do |t|
    t.integer  "home_id"
    t.integer  "away_id"
    t.integer  "venue_id"
    t.datetime "time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_id"
    t.string   "schedule_type"
  end

  create_table "league_managers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "active_league_id"
    t.integer  "active_season_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "league_players", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "league_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leagues", force: :cascade do |t|
    t.string   "name"
    t.string   "zip"
    t.string   "age"
    t.string   "sport"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "user_id"
    t.decimal  "latitude",                precision: 10, scale: 6
    t.decimal  "longitude",               precision: 10, scale: 6
    t.boolean  "paid"
    t.string   "exemption_no"
    t.integer  "limit"
    t.string   "discount_code"
    t.integer  "cc_number",     limit: 8
    t.integer  "cvv_number"
    t.integer  "exp_month"
    t.integer  "exp_year"
    t.integer  "last_digit"
  end

  add_index "leagues", ["user_id"], name: "index_leagues_on_user_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "user_to"
    t.integer  "user_from"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "from_user_name"
    t.string   "subject"
  end

  create_table "payment_logs", force: :cascade do |t|
    t.integer  "league_id"
    t.datetime "process_date"
    t.decimal  "amount",       precision: 6, scale: 2
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "league_id"
    t.boolean  "success"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",               precision: 8, scale: 2
    t.decimal  "tax",                  precision: 8, scale: 2, default: 0.0
    t.string   "payment_method_nonce"
  end

  create_table "players", force: :cascade do |t|
    t.string   "first"
    t.string   "last"
    t.string   "gender"
    t.string   "birthday"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.boolean  "paid"
    t.integer  "user_id"
    t.string   "email"
    t.integer  "season_id"
    t.string   "phone"
    t.string   "other_contacts"
    t.string   "ec_first1"
    t.string   "ec_last1"
    t.string   "ec_email1"
    t.string   "ec_phone1"
    t.string   "ec_first2"
    t.string   "ec_last2"
    t.string   "ec_email2"
    t.string   "ec_phone2"
    t.integer  "active_season_id"
    t.integer  "league_id"
  end

  create_table "reset_passwords", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "sales_agents", force: :cascade do |t|
    t.string   "first"
    t.string   "last"
    t.string   "email"
    t.string   "zipcodes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seasons", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_id"
    t.integer  "team_size"
    t.boolean  "is_active"
  end

  create_table "sports", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "team_rosters", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "image_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_id"
    t.integer  "season_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first"
    t.string   "last"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "api_key"
    t.string   "image"
    t.boolean  "temp_password"
    t.boolean  "confirmed"
    t.integer  "cc_id"
    t.string   "customer_id"
  end

  create_table "venues", force: :cascade do |t|
    t.string   "name"
    t.string   "first"
    t.string   "last"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone"
    t.integer  "league_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.boolean  "is_available"
    t.decimal  "latitude",     precision: 10, scale: 6
    t.decimal  "longitude",    precision: 10, scale: 6
    t.string   "email"
  end

  add_foreign_key "credit_cards", "users"
end
