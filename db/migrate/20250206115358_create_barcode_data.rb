class CreateBarcodeData < ActiveRecord::Migration[5.1]
  def change
    create_table :barcode_data do |t|
      t.string :crn, null: false
      t.string :provider_name, null: false
      t.string :plan_number
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :gst_amount, precision: 10, scale: 2
      t.text :description

      t.timestamps
    end

    add_index :barcode_data, :crn, unique: true
  end
end
