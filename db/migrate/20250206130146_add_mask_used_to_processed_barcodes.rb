class AddMaskUsedToProcessedBarcodes < ActiveRecord::Migration[5.1]
  def up
    ProcessedBarcode.update_all(mask_used: '*##RRRRRRRRRRRR#######')
    change_column_null :processed_barcodes, :mask_used, false
  end

  def down
    change_column_null :processed_barcodes, :mask_used, true
  end
end
