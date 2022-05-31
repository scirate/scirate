# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_05_31_170900) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auth_links", id: :serial, force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "oauth_token", null: false
    t.datetime "oauth_expires_at", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "auth", null: false
  end

  create_table "authors", id: :serial, force: :cascade do |t|
    t.integer "position", null: false
    t.text "fullname", null: false
    t.text "searchterm", null: false
    t.text "paper_uid"
    t.index ["paper_uid"], name: "index_authors_on_paper_uid"
    t.index ["position", "paper_uid"], name: "index_authors_on_position_and_paper_uid", unique: true
    t.index ["searchterm"], name: "index_authors_on_searchterm"
  end

  create_table "authorships", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "paper_uid", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.integer "position", null: false
    t.text "feed_uid", null: false
    t.text "paper_uid"
    t.datetime "crosslist_date", default: "2014-01-16 20:06:20", null: false
    t.index ["crosslist_date"], name: "index_categories_on_crosslist_date"
    t.index ["feed_uid", "crosslist_date"], name: "index_categories_on_feed_uid_and_crosslist_date"
    t.index ["feed_uid", "paper_uid"], name: "index_categories_on_feed_uid_and_paper_uid", unique: true
    t.index ["feed_uid"], name: "index_categories_on_feed_uid"
    t.index ["paper_uid", "feed_uid", "crosslist_date"], name: "index_categories_on_paper_uid_and_feed_uid_and_crosslist_date"
    t.index ["paper_uid"], name: "index_categories_on_paper_uid"
    t.index ["position", "paper_uid"], name: "index_categories_on_position_and_paper_uid", unique: true
  end

  create_table "comment_changes", id: :serial, force: :cascade do |t|
    t.integer "comment_id", null: false
    t.integer "user_id", null: false
    t.text "event", null: false
    t.text "reason", default: "", null: false
    t.text "content", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["comment_id"], name: "index_comment_changes_on_comment_id"
    t.index ["user_id"], name: "index_comment_changes_on_user_id"
  end

  create_table "comment_reports", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "comment_id"], name: "index_comment_reports_on_user_id_and_comment_id", unique: true
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "score", default: 0, null: false
    t.integer "cached_votes_up", default: 0, null: false
    t.integer "cached_votes_down", default: 0, null: false
    t.boolean "hidden", default: false, null: false
    t.integer "parent_id"
    t.integer "ancestor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "content", null: false
    t.boolean "deleted", default: false, null: false
    t.text "paper_uid", default: "", null: false
    t.boolean "hidden_from_recent", default: false, null: false
    t.integer "last_change_id"
    t.index ["ancestor_id"], name: "index_comments_on_ancestor_id"
    t.index ["deleted"], name: "index_comments_on_deleted"
    t.index ["hidden"], name: "index_comments_on_hidden"
    t.index ["hidden_from_recent"], name: "index_comments_on_hidden_from_recent"
    t.index ["id", "paper_uid", "deleted", "hidden", "hidden_from_recent"], name: "index_comments_for_recent"
    t.index ["last_change_id"], name: "index_comments_on_last_change_id"
    t.index ["paper_uid"], name: "index_comments_on_paper_uid"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "feed_preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "last_visited"
    t.datetime "previous_last_visited"
    t.integer "selected_range"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "feed_uid"
  end

  create_table "feeds", id: :serial, force: :cascade do |t|
    t.text "uid", null: false
    t.text "source", null: false
    t.text "fullname", null: false
    t.integer "position", default: 0, null: false
    t.integer "subscriptions_count", default: 0, null: false
    t.datetime "last_paper_date"
    t.text "parent_uid"
    t.index ["source"], name: "index_feeds_on_source"
    t.index ["uid", "last_paper_date"], name: "index_feeds_on_uid_and_last_paper_date", order: :desc
    t.index ["uid"], name: "index_feeds_on_uid", unique: true
  end

  create_table "papers", id: :serial, force: :cascade do |t|
    t.text "uid", null: false
    t.text "submitter"
    t.text "title", null: false
    t.text "abstract", null: false
    t.text "author_comments"
    t.text "msc_class"
    t.text "report_no"
    t.text "journal_ref"
    t.text "doi"
    t.text "proxy"
    t.text "license"
    t.datetime "submit_date", null: false
    t.datetime "update_date", null: false
    t.text "abs_url", null: false
    t.text "pdf_url", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "scites_count", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.datetime "pubdate"
    t.text "author_str", null: false
    t.integer "versions_count", default: 1, null: false
    t.boolean "locked", default: false, null: false
    t.index ["abs_url"], name: "index_papers_on_abs_url", unique: true
    t.index ["comments_count"], name: "index_papers_on_comments_count"
    t.index ["pdf_url"], name: "index_papers_on_pdf_url", unique: true
    t.index ["pubdate"], name: "index_papers_on_pubdate"
    t.index ["scites_count", "comments_count", "submit_date"], name: "index_papers_on_scites_count_and_comments_count_and_submit_date"
    t.index ["scites_count"], name: "index_papers_on_scites_count"
    t.index ["submit_date"], name: "index_papers_on_submit_date"
    t.index ["uid"], name: "index_papers_on_uid", unique: true
  end

  create_table "scites", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "paper_uid", default: "", null: false
    t.index ["paper_uid", "user_id"], name: "index_scites_on_paper_uid_and_user_id", unique: true
    t.index ["paper_uid"], name: "index_scites_on_paper_uid"
    t.index ["user_id"], name: "index_scites_on_user_id"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "feed_uid", default: "", null: false
    t.index ["feed_uid", "user_id"], name: "index_subscriptions_on_feed_uid_and_user_id", unique: true
    t.index ["feed_uid"], name: "index_subscriptions_on_feed_uid"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "system", id: :serial, force: :cascade do |t|
    t.text "alert", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "arxiv_sync_dt", default: "2020-12-25 00:00:00", null: false
    t.datetime "arxiv_author_sync_dt", default: "2020-12-25 00:00:00", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.text "fullname"
    t.text "email"
    t.text "remember_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "password_digest"
    t.integer "scites_count", default: 0
    t.text "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.text "confirmation_token"
    t.boolean "active", default: false
    t.integer "comments_count", default: 0
    t.datetime "confirmation_sent_at"
    t.integer "subscriptions_count", default: 0
    t.boolean "expand_abstracts", default: false
    t.text "account_status", default: "user"
    t.text "username", null: false
    t.text "organization", default: "", null: false
    t.text "about", default: "", null: false
    t.text "url", default: "", null: false
    t.text "location", default: "", null: false
    t.text "author_identifier", default: "", null: false
    t.integer "papers_count", default: 0, null: false
    t.boolean "email_about_replies", default: true
    t.boolean "email_about_comments_on_authored", default: true
    t.boolean "email_about_comments_on_scited", default: false
    t.boolean "email_about_reported_comments", default: false
    t.integer "range_preference", default: 0
    t.boolean "show_jobs", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token"
    t.index ["remember_token"], name: "index_users_on_remember_token"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.integer "position", null: false
    t.datetime "date", null: false
    t.text "size"
    t.text "paper_uid", null: false
    t.index ["paper_uid"], name: "index_versions_on_paper_uid"
    t.index ["position", "paper_uid"], name: "index_versions_on_position_and_paper_uid", unique: true
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "votable_id"
    t.text "votable_type"
    t.integer "voter_id"
    t.text "voter_type"
    t.boolean "vote_flag"
    t.text "vote_scope"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vote_weight"
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["votable_id", "votable_type", "voter_id"], name: "index_votes_on_votable_id_and_votable_type_and_voter_id", unique: true
    t.index ["votable_id", "votable_type"], name: "index_votes_on_votable_id_and_votable_type"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
    t.index ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type"
  end

end
