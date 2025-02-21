class AddErrorMessageToProcessedBarcodes < ActiveRecord::Migration[5.1]
  def change
    add_column :processed_barcodes, :error_message, :text
  end
end
