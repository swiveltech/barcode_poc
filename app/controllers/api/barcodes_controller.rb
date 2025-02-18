# app/controllers/api/barcodes_controller.rb
module Api
  class BarcodesController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      barcode_data = params.permit(:barcode, :pdf_file, :bucket, :timestamp)
      
      # Create a record in your database
      barcode = Barcode.create!(
        code: barcode_data[:barcode],
        pdf_file: barcode_data[:pdf_file],
        s3_bucket: barcode_data[:bucket],
        scanned_at: barcode_data[:timestamp]
      )

      render json: { status: 'success', barcode: barcode.code }, status: :ok
    rescue => e
      render json: { status: 'error', message: e.message }, status: :unprocessable_entity
    end
  end
end