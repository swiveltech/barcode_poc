class AddFileInfoToProcessedBarcodes < ActiveRecord::Migration[5.1]
  def change
    add_column :processed_barcodes, :pdf_file, :string
    add_column :processed_barcodes, :s3_bucket, :string
  end
end
