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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120320094847) do

  create_table "feed_days", :force => true do |t|
    t.date     "pubdate"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "feed_days", ["pubdate"], :name => "index_feed_days_on_pubdate", :unique => true

  create_table "papers", :force => true do |t|
    t.string   "title"
    t.text     "authors"
    t.text     "abstract"
    t.string   "identifier"
    t.string   "url"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.date     "pubdate"
    t.date     "updated_date"
    t.integer  "scites_count", :default => 0
  end

  add_index "papers", ["identifier"], :name => "index_papers_on_identifier", :unique => true
  add_index "papers", ["pubdate"], :name => "index_papers_on_date"

  create_table "scites", :force => true do |t|
    t.integer  "sciter_id"
    t.integer  "paper_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "scites", ["paper_id"], :name => "index_scites_on_paper_id"
  add_index "scites", ["sciter_id", "paper_id"], :name => "index_scites_on_sciter_id_and_paper_id", :unique => true
  add_index "scites", ["sciter_id"], :name => "index_scites_on_sciter_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "remember_token"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "password_digest"
    t.integer  "scites_count",    :default => 0
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
