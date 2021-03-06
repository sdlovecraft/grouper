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

ActiveRecord::Schema.define(version: 20150725200434) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "post_id"
    t.text     "body_html"
  end

  add_index "comments", ["post_id"], name: "index_comments_on_post_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "discussion_users", force: true do |t|
    t.integer "user_id"
    t.integer "discussion_id"
  end

  add_index "discussion_users", ["discussion_id"], name: "index_discussion_users_on_discussion_id", using: :btree
  add_index "discussion_users", ["user_id"], name: "index_discussion_users_on_user_id", using: :btree

  create_table "discussions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "last_updated"
    t.integer  "last_author_id"
  end

  add_index "discussions", ["user_id"], name: "index_discussions_on_user_id", using: :btree

  create_table "friendships", force: true do |t|
    t.integer "friend_id"
    t.integer "user_id"
  end

  create_table "likes", force: true do |t|
    t.integer  "user_id"
    t.string   "likeable_type"
    t.integer  "likeable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_users", force: true do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.boolean  "is_read"
    t.string   "placeholder"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "message_users", ["message_id"], name: "index_message_users_on_message_id", using: :btree
  add_index "message_users", ["user_id"], name: "index_message_users_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.text     "subject"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body_html"
  end

  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "notifications", force: true do |t|
    t.string   "notifiable_type"
    t.integer  "notifiable_id"
    t.boolean  "user_checked"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "posts", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discussion_id"
    t.text     "body"
  end

  add_index "posts", ["discussion_id"], name: "index_posts_on_discussion_id", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "name"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "bio"
    t.string   "time_zone"
  end

end
