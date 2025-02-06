class BarcodeMask
  attr_reader :mask, :crn_start, :crn_length, :amount_start, :amount_length

  def initialize(mask_pattern)
    @mask = mask_pattern
    parse_mask
  end

  def parse_mask
    # Example mask: ####RRRRRRRRRRRR########$$$$$$$
    @crn_start = @mask.index('R')
    @crn_length = @mask.count('R')
    @amount_start = @mask.index('$')
    @amount_length = @mask.count('$')
  end

  def extract_data(barcode)
    return nil unless barcode && barcode.length == @mask.length

    {
      crn: barcode[@crn_start, @crn_length],
      amount: parse_amount(barcode[@amount_start, @amount_length])
    }
  end

  private

  def parse_amount(amount_str)
    return nil unless amount_str
    # Convert last 2 digits to decimal places
    dollars = amount_str[0..-3].to_i
    cents = amount_str[-2..-1].to_i
    dollars + (cents / 100.0)
  end
end
