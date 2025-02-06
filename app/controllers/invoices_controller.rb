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
      file = params[:invoice][:file]
      processor = InvoiceProcessor.new
      
      result = processor.process_invoice(file.path)
      
      if result[:success]
        flash[:success] = 'Invoice processed successfully!'
        @barcode_data = result
      else
        flash[:error] = result[:error] || 'Failed to process invoice'
      end

      redirect_to invoices_path
    else
      flash[:error] = 'Please select a file to upload'
      redirect_to upload_invoices_path
    end
  end
end
