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
      temp_file = Tempfile.new(['invoice', '.pdf'])

      begin
      Rails.logger.debug "Created temp file: #{temp_file.path}"
      
      # Copy the uploaded file content
    FileUtils.copy_file(uploaded_file.tempfile.path, temp_file.path)
    Rails.logger.debug "Copied content from #{uploaded_file.tempfile.path} to #{temp_file.path}"
    

      processor = InvoiceProcessor.new
      
      result = processor.process_invoice(temp_file.path)
      
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
