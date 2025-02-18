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

ActiveRecord::Schema.define(version: 20250213133728) do

  create_table "barcode_data", force: :cascade do |t|
    t.string "crn", null: false
    t.string "provider_name", null: false
    t.string "plan_number"
    t.decimal "amount", precision: 10, scale: 2
    t.decimal "gst_amount", precision: 10, scale: 2
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crn"], name: "index_barcode_data_on_crn", unique: true
  end

  create_table "processed_barcodes", force: :cascade do |t|
    t.string "barcode_number"
    t.string "mask_used"
    t.boolean "success", default: false
    t.datetime "processed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "crn"
    t.string "provider_name"
    t.decimal "amount", precision: 10, scale: 2
    t.string "original_filename"
    t.string "s3_path"
    t.index ["barcode_number"], name: "index_processed_barcodes_on_barcode_number"
    t.index ["crn"], name: "index_processed_barcodes_on_crn"
    t.index ["processed_at"], name: "index_processed_barcodes_on_processed_at"
    t.index ["status"], name: "index_processed_barcodes_on_status"
  end

end
