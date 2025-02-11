require Rails.root.join('lib', 'invoice_processor').to_s
require Rails.root.join('lib', 'barcode_mask').to_s
require Rails.root.join('lib', 'barcode_store').to_s

class InvoicesController < ApplicationController
  def index
    @processed_barcodes = ProcessedBarcode.order(processed_at: :desc).limit(10)
  end

  def upload
  end

  def process_upload
    if params[:invoice].present? && params[:invoice][:file].present?
      uploaded_file = params[:invoice][:file]

      Rails.logger.debug "=== Starting Upload Process ==="
    Rails.logger.debug "Original file: #{uploaded_file.original_filename}"
    Rails.logger.debug "Temp file path: #{uploaded_file.tempfile.path}"
    Rails.logger.debug "File size: #{File.size(uploaded_file.tempfile.path)} bytes"
    
      temp_file = Tempfile.new(['invoice', '.pdf'])

      begin
      Rails.logger.debug "Created temp file: #{temp_file.path}"
      
      # Copy the uploaded file content
    FileUtils.copy_file(uploaded_file.tempfile.path, temp_file.path)
    Rails.logger.debug "Copied file. New size: #{File.size(temp_file.path)} bytes"
    Rails.logger.debug "File exists? #{File.exist?(temp_file.path)}"
    Rails.logger.debug "File permissions: #{File.stat(temp_file.path).mode.to_s(8)}"
    
    Rails.logger.debug "Testing zbarimg directly:"
    command_output = `which zbarimg`
    Rails.logger.debug "zbarimg location: #{command_output}"
    Rails.logger.debug "zbarimg test output: #{`zbarimg --version`}"
      processor = InvoiceProcessor.new
      
      result = processor.process_invoice(temp_file.path)
      
       Rails.logger.debug "Process result: #{result.inspect}"
      if result[:success]
        flash[:success] = 'Invoice processed successfully!'
        @barcode_data = result
      else
        flash[:error] = result[:error] || 'Failed to process invoice'
      end

    ensure
      temp_file.close
      temp_file.unlink
    end

      redirect_to invoices_path
    else
      flash[:error] = 'Please select a file to upload'
      redirect_to upload_invoices_path
    end
  end
end
