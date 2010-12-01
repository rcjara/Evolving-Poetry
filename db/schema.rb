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

ActiveRecord::Schema.define(:version => 20101130234700) do

  create_table "auth_lang_relations", :force => true do |t|
    t.integer  "author_id"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_lang_relations", ["author_id"], :name => "index_auth_lang_relations_on_author_id"
  add_index "auth_lang_relations", ["language_id"], :name => "index_auth_lang_relations_on_language_id"

  create_table "authors", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "full_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "visible",    :default => true
  end

  add_index "authors", ["first_name"], :name => "index_authors_on_first_name"
  add_index "authors", ["full_name"], :name => "index_authors_on_full_name"

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.integer  "total_votes", :default => 0
    t.integer  "max_poems",   :default => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",      :default => true
  end

  create_table "poems", :force => true do |t|
    t.text     "full_text"
    t.text     "programmatic_text"
    t.integer  "language_id"
    t.integer  "votes_for",         :default => 0
    t.integer  "votes_against",     :default => 0
    t.integer  "score",             :default => 0
    t.boolean  "alive",             :default => true
    t.datetime "died_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_children",      :default => 0
  end

  add_index "poems", ["language_id"], :name => "index_poems_on_language_id"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.integer  "poems_evaluated",   :default => 0
    t.integer  "posts",             :default => 0
    t.integer  "points",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "works", :force => true do |t|
    t.integer  "author_id"
    t.string   "content"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "works", ["author_id"], :name => "index_works_on_author_id"

end
