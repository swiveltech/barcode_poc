class BarcodeMask
  PATTERN = {
    prefix: 1,      # * character
    ignore: 5,      # ##### (first 5 digits)
    crn: 12,        # RRRRRRRRRRRR (12 digits for CRN)
    ignore2: 8,     # ######## (8 digits to ignore)
    amount: 7       # $$$$$$$ (amount)
  }

  attr_reader :mask

  def initialize(mask_pattern)
    @mask = mask_pattern
  end

  def extract_data(barcode)
    return nil unless barcode && barcode.start_with?('*')

    # Example: *29581200051216188000014453
    # Parts:    *29581|200051216188|18800001|4453
    #           P IGNOR|    CRN     |IGNORE2 |AMNT
    barcode = barcode[1..-1]  # Remove * prefix
    return nil unless barcode.length >= total_length

    # Extract parts according to mask pattern
    parts = {
      ignore1: barcode[0...PATTERN[:ignore]],
      crn: barcode[PATTERN[:ignore], PATTERN[:crn]],
      ignore2: barcode[PATTERN[:ignore] + PATTERN[:crn], PATTERN[:ignore2]],
      amount: barcode[-PATTERN[:amount]..-1]
    }

    Rails.logger.info "Barcode parts:"
    Rails.logger.info "Full barcode: #{barcode}"
    Rails.logger.info "Ignore1: #{parts[:ignore1]}"
    Rails.logger.info "CRN: #{parts[:crn]}"
    Rails.logger.info "Ignore2: #{parts[:ignore2]}"
    Rails.logger.info "Amount: #{parts[:amount]}"

    {
      crn: parts[:crn],
      amount: parse_amount(parts[:amount])
    }
  end

  private

  def total_length
    PATTERN.values.sum - 1  # -1 because we remove the * prefix
  end

  def parse_amount(amount_str)
    return nil unless amount_str
    # Convert amount to decimal (last two digits are cents)
    amount = amount_str.to_i / 100.0
    Rails.logger.info "Parsed amount: $#{sprintf('%.2f', amount)} from #{amount_str}"
    amount
  end
end
