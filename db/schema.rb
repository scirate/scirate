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

ActiveRecord::Schema.define(version: 20140114015506) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorships", force: true do |t|
    t.integer  "paper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.text     "keyname"
    t.text     "forenames"
    t.text     "affiliation"
    t.text     "suffix"
    t.text     "searchterm"
    t.text     "fullname"
  end

  add_index "authorships", ["paper_id"], name: "index_authorships_on_paper_id", using: :btree
  add_index "authorships", ["paper_id"], name: "paper_id_idx", using: :btree

  create_table "comment_reports", force: true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "paper_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "score"
    t.integer  "cached_votes_up",   default: 0
    t.integer  "cached_votes_down", default: 0
    t.integer  "parent_id"
    t.boolean  "hidden",            default: false
    t.integer  "reply_id"
    t.integer  "ancestor_id"
  end

  add_index "comments", ["cached_votes_down"], name: "index_comments_on_cached_votes_down", using: :btree
  add_index "comments", ["cached_votes_up"], name: "index_comments_on_cached_votes_up", using: :btree
  add_index "comments", ["paper_id"], name: "index_comments_on_paper_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "cross_lists", force: true do |t|
    t.integer  "paper_id"
    t.integer  "feed_id"
    t.date     "cross_list_date"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "cross_lists", ["cross_list_date"], name: "index_cross_lists_on_cross_list_date", using: :btree
  add_index "cross_lists", ["feed_id", "cross_list_date"], name: "index_cross_lists_on_feed_id_and_cross_list_date", using: :btree
  add_index "cross_lists", ["feed_id"], name: "index_cross_lists_on_feed_id", using: :btree
  add_index "cross_lists", ["paper_id", "feed_id"], name: "index_cross_lists_on_paper_id_and_feed_id", unique: true, using: :btree
  add_index "cross_lists", ["paper_id"], name: "index_cross_lists_on_paper_id", using: :btree

  create_table "down_votes", force: true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feed_preferences", force: true do |t|
    t.integer  "user_id"
    t.integer  "feed_id"
    t.datetime "last_visited"
    t.datetime "previous_last_visited"
    t.integer  "selected_range"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "feed_type"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.date     "updated_date"
    t.integer  "subscriptions_count", default: 0
    t.date     "last_paper_date"
    t.text     "fullname"
    t.integer  "parent_id"
    t.integer  "position"
  end

  add_index "feeds", ["last_paper_date"], name: "index_feeds_on_last_paper_date", using: :btree
  add_index "feeds", ["name"], name: "index_feeds_on_name", unique: true, using: :btree

  create_table "papers", force: true do |t|
    t.text     "title"
    t.text     "authors"
    t.text     "abstract"
    t.string   "identifier"
    t.string   "url"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.date     "pubdate"
    t.date     "updated_date"
    t.integer  "scites_count",   default: 0
    t.integer  "comments_count", default: 0
    t.integer  "feed_id"
    t.string   "pdf_url"
    t.text     "author_str"
    t.boolean  "delta",          default: true, null: false
  end

  add_index "papers", ["comments_count"], name: "index_papers_on_comments_count", order: {"comments_count"=>:desc}, using: :btree
  add_index "papers", ["delta"], name: "index_papers_on_delta", using: :btree
  add_index "papers", ["feed_id"], name: "index_papers_on_feed_id", using: :btree
  add_index "papers", ["identifier"], name: "index_papers_on_identifier", unique: true, using: :btree
  add_index "papers", ["pubdate"], name: "index_papers_on_date", using: :btree
  add_index "papers", ["pubdate"], name: "index_papers_on_pubdate", using: :btree
  add_index "papers", ["scites_count", "comments_count"], name: "index_papers_on_scites_count_and_comments_count", order: {"scites_count"=>:desc, "comments_count"=>:desc}, using: :btree
  add_index "papers", ["scites_count"], name: "index_papers_on_scites_count", order: {"scites_count"=>:desc}, using: :btree

  create_table "scites", force: true do |t|
    t.integer  "sciter_id"
    t.integer  "paper_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "scites", ["paper_id"], name: "index_scites_on_paper_id", using: :btree
  add_index "scites", ["sciter_id", "paper_id"], name: "index_scites_on_sciter_id_and_paper_id", unique: true, using: :btree
  add_index "scites", ["sciter_id"], name: "index_scites_on_sciter_id", using: :btree

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id"
    t.integer  "feed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "subscriptions", ["feed_id"], name: "index_subscriptions_on_feed_id", using: :btree
  add_index "subscriptions", ["user_id", "feed_id"], name: "index_subscriptions_on_user_id_and_feed_id", unique: true, using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "up_votes", force: true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "upvotes", force: true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "remember_token"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "password_digest"
    t.integer  "scites_count",           default: 0
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "confirmation_token"
    t.boolean  "active",                 default: false
    t.integer  "comments_count",         default: 0
    t.datetime "confirmation_sent_at"
    t.integer  "subscriptions_count",    default: 0
    t.boolean  "expand_abstracts",       default: false
    t.string   "account_status",         default: "user"
    t.text     "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "vote_weight"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["votable_id", "votable_type"], name: "index_votes_on_votable_id_and_votable_type", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type", using: :btree

end
