class InvoicesController < ApplicationController
  def index
    @processed_barcodes = ProcessedBarcode.order(processed_at: :desc).limit(10)
  end

  def process_upload
    @processed_barcode = ProcessedBarcode.new(
      barcode_number: 'pending', # Will be updated by Go service
      mask_used: '*29581',      # Default mask
      success: false,           # Initially false until processed
      processed_at: Time.current,
      original_filename: params[:invoice][:file].original_filename,
      s3_bucket: ENV['AWS_S3_BUCKET']
    )

    if @processed_barcode.save
      upload_to_s3
      render json: { success: true, message: 'Invoice uploaded successfully', id: @processed_barcode.id }
    else
      render json: { success: false, message: @processed_barcode.errors.full_messages.join(', ') }, 
             status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error "Upload failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { success: false, message: 'Upload failed. Please try again.' }, 
           status: :internal_server_error
  end

  private

  def upload_to_s3
    s3_client = Aws::S3::Client.new(
      region: ENV['AWS_REGION'],
      credentials: Aws::Credentials.new(
        ENV['AWS_ACCESS_KEY_ID'],
        ENV['AWS_SECRET_ACCESS_KEY']
      )
    )

    s3_path = "invoices/#{@processed_barcode.id}/#{@processed_barcode.original_filename}"

    begin
      Rails.logger.info "Attempting to upload to S3: #{s3_path}"
      Rails.logger.info "Using bucket: #{ENV['AWS_BUCKET']}"
      
      s3_client.put_object(
        bucket: ENV['AWS_BUCKET'],
        key: s3_path,
        body: params[:invoice][:file].read
      )
      
      @processed_barcode.update(
        s3_path: s3_path,
        status: 'processing',
        processed_at: Time.current
      )
    rescue StandardError => e
      Rails.logger.error "S3 upload failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @processed_barcode.update(
        status: 'failed',
        error_message: e.message
      )
      raise e
    end
  end
end