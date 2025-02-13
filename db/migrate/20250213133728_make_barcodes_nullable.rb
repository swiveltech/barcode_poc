class MakeBarcodesNullable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :processed_barcodes, :barcode_number, true
    change_column_null :processed_barcodes, :mask_used, true
  end
end
