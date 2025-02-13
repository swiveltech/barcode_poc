class AddOriginalFilenameToProcessedBarcodes < ActiveRecord::Migration[5.1]
  def change
    add_column :processed_barcodes, :original_filename, :string
    add_column :processed_barcodes, :s3_path, :string
  end
end
