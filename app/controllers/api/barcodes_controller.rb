# app/controllers/api/barcodes_controller.rb
module Api
  class BarcodesController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      barcode_params = params.permit(:barcode, :bucket, :timestamp, :filename)
      
      # Find existing record by filename
      processed = ProcessedBarcode.find_by(original_filename: barcode_params[:filename])
      
      unless processed
        render json: { 
          status: 'error', 
          message: 'No pending record found for this file' 
        }, status: :not_found
        return
      end

      # Extract CRN from barcode by removing the mask prefix
      crn = barcode_params[:barcode].gsub(/^\*\d{5}/, '').first(12)
      amount = barcode_params[:barcode].gsub(/^\*\d{5}/, '')[12..-1].to_i / 100.0
      
      # Look up the barcode data from our database
      barcode_data = BarcodeDatum.find_by(crn: crn)

      if barcode_data
        # Update the record with barcode data
        processed.update!(
          barcode_number: barcode_params[:barcode],
          mask_used: barcode_params[:barcode][0..5], # Store the mask (*29581)
          success: true,
          processed_at: Time.current,
          crn: crn,
          amount: amount,
          provider_name: barcode_data.provider_name,
          s3_bucket: barcode_params[:bucket]
        )

        render json: { 
          status: 'success', 
          barcode: processed.barcode_number,
          details: {
            crn: barcode_data.crn,
            provider_name: barcode_data.provider_name,
            plan_number: barcode_data.plan_number,
            amount: barcode_data.amount,
            gst_amount: barcode_data.gst_amount,
            description: barcode_data.description
          }
        }, status: :ok
      else
        # Update the record as failed
        processed.update!(
          barcode_number: barcode_params[:barcode],
          mask_used: barcode_params[:barcode][0..5],
          success: false,
          processed_at: Time.current,
          crn: crn,
          amount: amount,
          s3_bucket: barcode_params[:bucket],
          error_message: 'Barcode not found in database'
        )

        render json: { 
          status: 'error', 
          message: 'Barcode not found in database',
          barcode: barcode_params[:barcode],
          extracted_crn: crn,
          extracted_amount: amount
        }, status: :not_found
      end
    rescue => e
      Rails.logger.error("Error processing barcode: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      
      render json: { 
        status: 'error', 
        message: e.message 
      }, status: :unprocessable_entity
    end
  end
end