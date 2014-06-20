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

ActiveRecord::Schema.define(version: 20140620083606) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auth_links", force: true do |t|
    t.string   "provider",         null: false
    t.string   "uid",              null: false
    t.string   "oauth_token",      null: false
    t.datetime "oauth_expires_at", null: false
    t.integer  "user_id",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "auth",             null: false
  end

  create_table "authors", force: true do |t|
    t.integer "position",   null: false
    t.text    "fullname",   null: false
    t.text    "searchterm", null: false
    t.text    "paper_uid"
  end

  add_index "authors", ["paper_uid"], name: "index_authors_on_paper_uid", using: :btree
  add_index "authors", ["position", "paper_uid"], name: "index_authors_on_position_and_paper_uid", unique: true, using: :btree
  add_index "authors", ["searchterm"], name: "index_authors_on_searchterm", using: :btree

  create_table "authorships", force: true do |t|
    t.integer  "user_id",    null: false
    t.text     "paper_uid",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.integer  "position",                                       null: false
    t.text     "feed_uid",                                       null: false
    t.text     "paper_uid"
    t.datetime "crosslist_date", default: '2014-01-16 20:06:20', null: false
  end

  add_index "categories", ["crosslist_date"], name: "index_categories_on_crosslist_date", using: :btree
  add_index "categories", ["feed_uid", "crosslist_date"], name: "index_categories_on_feed_uid_and_crosslist_date", using: :btree
  add_index "categories", ["feed_uid", "paper_uid"], name: "index_categories_on_feed_uid_and_paper_uid", unique: true, using: :btree
  add_index "categories", ["feed_uid"], name: "index_categories_on_feed_uid", using: :btree
  add_index "categories", ["paper_uid", "feed_uid", "crosslist_date"], name: "index_categories_on_paper_uid_and_feed_uid_and_crosslist_date", using: :btree
  add_index "categories", ["paper_uid"], name: "index_categories_on_paper_uid", using: :btree
  add_index "categories", ["position", "paper_uid"], name: "index_categories_on_position_and_paper_uid", unique: true, using: :btree

  create_table "comment_reports", force: true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comment_reports", ["user_id", "comment_id"], name: "index_comment_reports_on_user_id_and_comment_id", unique: true, using: :btree

  create_table "comments", force: true do |t|
    t.integer  "user_id",                            null: false
    t.integer  "score",              default: 0,     null: false
    t.integer  "cached_votes_up",    default: 0,     null: false
    t.integer  "cached_votes_down",  default: 0,     null: false
    t.boolean  "hidden",             default: false, null: false
    t.integer  "parent_id"
    t.integer  "ancestor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content",                            null: false
    t.boolean  "deleted",            default: false, null: false
    t.text     "paper_uid",          default: "",    null: false
    t.boolean  "hidden_from_recent", default: false, null: false
  end

  add_index "comments", ["ancestor_id"], name: "index_comments_on_ancestor_id", using: :btree
  add_index "comments", ["deleted"], name: "index_comments_on_deleted", using: :btree
  add_index "comments", ["hidden"], name: "index_comments_on_hidden", using: :btree
  add_index "comments", ["hidden_from_recent"], name: "index_comments_on_hidden_from_recent", using: :btree
  add_index "comments", ["id", "paper_uid", "deleted", "hidden", "hidden_from_recent"], name: "index_comments_for_recent", using: :btree
  add_index "comments", ["paper_uid"], name: "index_comments_on_paper_uid", using: :btree
  add_index "comments", ["parent_id"], name: "index_comments_on_parent_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "feed_preferences", force: true do |t|
    t.integer  "user_id"
    t.datetime "last_visited"
    t.datetime "previous_last_visited"
    t.integer  "selected_range"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "feed_uid"
  end

  create_table "feeds", force: true do |t|
    t.text     "uid",                             null: false
    t.text     "source",                          null: false
    t.text     "fullname",                        null: false
    t.integer  "position",            default: 0, null: false
    t.integer  "subscriptions_count", default: 0, null: false
    t.datetime "last_paper_date"
    t.text     "parent_uid"
  end

  add_index "feeds", ["source"], name: "index_feeds_on_source", using: :btree
  add_index "feeds", ["uid", "last_paper_date"], name: "index_feeds_on_uid_and_last_paper_date", order: {"uid"=>:desc, "last_paper_date"=>:desc}, using: :btree
  add_index "feeds", ["uid"], name: "index_feeds_on_uid", unique: true, using: :btree

  create_table "papers", force: true do |t|
    t.text     "uid",                         null: false
    t.text     "submitter"
    t.text     "title",                       null: false
    t.text     "abstract",                    null: false
    t.text     "author_comments"
    t.text     "msc_class"
    t.text     "report_no"
    t.text     "journal_ref"
    t.text     "doi"
    t.text     "proxy"
    t.text     "license"
    t.datetime "submit_date",                 null: false
    t.datetime "update_date",                 null: false
    t.text     "abs_url",                     null: false
    t.text     "pdf_url",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scites_count",    default: 0, null: false
    t.integer  "comments_count",  default: 0, null: false
    t.datetime "pubdate"
    t.text     "author_str",                  null: false
    t.integer  "versions_count",  default: 1, null: false
  end

  add_index "papers", ["abs_url"], name: "index_papers_on_abs_url", unique: true, using: :btree
  add_index "papers", ["comments_count"], name: "index_papers_on_comments_count", using: :btree
  add_index "papers", ["pdf_url"], name: "index_papers_on_pdf_url", unique: true, using: :btree
  add_index "papers", ["pubdate"], name: "index_papers_on_pubdate", using: :btree
  add_index "papers", ["scites_count", "comments_count", "submit_date"], name: "index_papers_on_scites_count_and_comments_count_and_submit_date", using: :btree
  add_index "papers", ["scites_count"], name: "index_papers_on_scites_count", using: :btree
  add_index "papers", ["submit_date"], name: "index_papers_on_submit_date", using: :btree
  add_index "papers", ["uid"], name: "index_papers_on_uid", unique: true, using: :btree

  create_table "scites", force: true do |t|
    t.integer  "user_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "paper_uid",  default: "", null: false
  end

  add_index "scites", ["paper_uid", "user_id"], name: "index_scites_on_paper_uid_and_user_id", unique: true, using: :btree
  add_index "scites", ["paper_uid"], name: "index_scites_on_paper_uid", using: :btree
  add_index "scites", ["user_id"], name: "index_scites_on_user_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "feed_uid",   default: "", null: false
  end

  add_index "subscriptions", ["feed_uid", "user_id"], name: "index_subscriptions_on_feed_uid_and_user_id", unique: true, using: :btree
  add_index "subscriptions", ["feed_uid"], name: "index_subscriptions_on_feed_uid", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "system", force: true do |t|
    t.text     "alert",      default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.text     "fullname"
    t.text     "email"
    t.text     "remember_token"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.text     "password_digest"
    t.integer  "scites_count",                     default: 0
    t.text     "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.text     "confirmation_token"
    t.boolean  "active",                           default: false
    t.integer  "comments_count",                   default: 0
    t.datetime "confirmation_sent_at"
    t.integer  "subscriptions_count",              default: 0
    t.boolean  "expand_abstracts",                 default: false
    t.text     "account_status",                   default: "user"
    t.text     "username",                                          null: false
    t.text     "organization",                     default: "",     null: false
    t.text     "about",                            default: "",     null: false
    t.text     "url",                              default: "",     null: false
    t.text     "location",                         default: "",     null: false
    t.text     "author_identifier",                default: "",     null: false
    t.integer  "papers_count",                     default: 0,      null: false
    t.boolean  "email_about_replies",              default: true
    t.boolean  "email_about_comments_on_authored", default: true
    t.boolean  "email_about_comments_on_scited",   default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.integer  "position",  null: false
    t.datetime "date",      null: false
    t.text     "size"
    t.text     "paper_uid", null: false
  end

  add_index "versions", ["paper_uid"], name: "index_versions_on_paper_uid", using: :btree
  add_index "versions", ["position", "paper_uid"], name: "index_versions_on_position_and_paper_uid", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.text     "votable_type"
    t.integer  "voter_id"
    t.text     "voter_type"
    t.boolean  "vote_flag"
    t.text     "vote_scope"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "vote_weight"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["votable_id", "votable_type", "voter_id"], name: "index_votes_on_votable_id_and_votable_type_and_voter_id", unique: true, using: :btree
  add_index "votes", ["votable_id", "votable_type"], name: "index_votes_on_votable_id_and_votable_type", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type", using: :btree

end
