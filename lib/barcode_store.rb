require 'singleton'

class BarcodeStore
  include Singleton

  MASK_PATTERN = {
    prefix: 1,      # * character
    ignore: 5,      # ##### (first 5 digits)
    crn: 12,        # RRRRRRRRRRRR (12 digits for CRN)
    ignore2: 8,     # ######## (8 digits to ignore)
    amount: 7       # $$$$$$$ (amount)
  }

  def initialize
    @history = []
  end

  def parse_barcode(barcode)
    return nil unless barcode.start_with?('*')

    # Remove the * prefix
    barcode = barcode[1..-1]
    
    # Extract parts according to mask pattern
    parts = {
      ignore1: barcode[0...MASK_PATTERN[:ignore]],
      crn: barcode[MASK_PATTERN[:ignore], MASK_PATTERN[:crn]],
      ignore2: barcode[MASK_PATTERN[:ignore] + MASK_PATTERN[:crn], MASK_PATTERN[:ignore2]],
      amount: barcode[-MASK_PATTERN[:amount]..-1]
    }

    # Convert amount to decimal (last two digits are cents)
    amount = parts[:amount].to_i / 100.0
    
    {
      crn: parts[:crn],
      amount: amount,
      raw_barcode: barcode
    }
  end

  def find_by_crn(crn)
    Rails.logger.info "Looking up CRN in database: #{crn}"
    Rails.logger.info "CRN class: #{crn.class}, length: #{crn&.length}"
    
    barcode_data = BarcodeDatum.find_by(crn: crn)
    Rails.logger.info "Found barcode_data: #{barcode_data.inspect}"
    
    if barcode_data
      Rails.logger.info "Found barcode data: #{barcode_data.attributes}"
      provider_details = {
        provider_name: barcode_data.provider_name,
        plan_number: barcode_data.plan_number,
        amount: barcode_data.amount,
        gst_amount: barcode_data.gst_amount,
        description: barcode_data.description
      }
      Rails.logger.info "Returning provider details: #{provider_details}"
      provider_details
    else
      Rails.logger.info "No barcode data found for CRN: #{crn}"
      nil
    end
  end

  def add_to_history(barcode, success, provider_details = nil)
    Rails.logger.info "\n=== Adding to History ==="
    Rails.logger.info "Barcode: #{barcode}"
    Rails.logger.info "Success: #{success}"
    Rails.logger.info "Provider Details: #{provider_details.inspect}"
    
    extracted_data = parse_barcode(barcode)
    Rails.logger.info "\nExtracted Data: #{extracted_data.inspect}"
    
    if extracted_data && success && provider_details
      Rails.logger.info "\nCreating successful record with:"
      Rails.logger.info "  CRN: #{extracted_data[:crn].inspect}"
      Rails.logger.info "  Amount: #{extracted_data[:amount].inspect}"
      Rails.logger.info "  Provider Name: #{provider_details[:provider_name].inspect}"
      
      record = ProcessedBarcode.create!(
        barcode_number: barcode,
        mask_used: ProcessedBarcode::MASK,
        status: 'success',
        processed_at: Time.current,
        crn: extracted_data[:crn],
        amount: extracted_data[:amount],
        provider_name: provider_details[:provider_name]
      )
      
      Rails.logger.info "\nSaved Record ID: #{record.id}"
      Rails.logger.info "Saved Attributes: #{record.attributes}"
      record
    else
      Rails.logger.info "\nCreating failed record"
      ProcessedBarcode.create!(
        barcode_number: barcode,
        mask_used: ProcessedBarcode::MASK,
        status: 'failed',
        processed_at: Time.current
      )
    end
  end

  private


end
