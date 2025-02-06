class AddFieldsToProcessedBarcodes < ActiveRecord::Migration[5.1]
  def change
    add_column :processed_barcodes, :status, :string
    add_column :processed_barcodes, :crn, :string
    add_column :processed_barcodes, :provider_name, :string
    add_column :processed_barcodes, :amount, :decimal, precision: 10, scale: 2
    
    add_index :processed_barcodes, :status
    add_index :processed_barcodes, :crn
  end
end
