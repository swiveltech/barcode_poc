class CreateProcessedBarcodes < ActiveRecord::Migration[5.1]
  def change
    create_table :processed_barcodes do |t|
      t.string :barcode_number, null: false
      t.string :mask_used, null: false
      t.boolean :success, default: false
      t.datetime :processed_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end

    add_index :processed_barcodes, :barcode_number
    add_index :processed_barcodes, :processed_at
  end
end
