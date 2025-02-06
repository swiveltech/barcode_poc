require_relative 'barcode_mask'
require_relative 'barcode_store'
require 'pdf-reader'
require 'tempfile'
require 'mini_magick'

class InvoiceProcessor
  def initialize(mask_pattern = "####RRRRRRRRRRRR########$$$$$$$")
    @mask = BarcodeMask.new(mask_pattern)
    @store = BarcodeStore.instance
  end

  def process_invoice(pdf_path)
    barcodes = scan_pdf_for_barcodes(pdf_path)
    
    # Try each barcode until we find a match
    barcodes.each do |barcode|
      # Skip if barcode length doesn't match mask
      next unless barcode.length == @mask.mask.length

      data = @mask.extract_data(barcode)
      next unless data

      if (provider_details = @store.find_by_crn(data[:crn]))
        @store.add_to_history(barcode, @mask.mask, true)
        return {
          success: true,
          crn: data[:crn],
          amount: data[:amount],
          provider_details: provider_details
        }
      end
    end

    # No valid barcode found
    @store.add_to_history(barcodes.first, @mask.mask, false) if barcodes.any?
    { success: false, error: "No valid barcode found" }
  end

  private

  def scan_pdf_for_barcodes(pdf_path)
    barcodes = []
    reader = PDF::Reader.new(pdf_path)

    # Only process first two pages
    [reader.page_count, 2].min.times do |i|
      page = reader.page(i + 1)
      
      # Convert PDF page to PNG
      image = convert_page_to_image(pdf_path, i + 1)
      
      # Enhance image for better barcode detection
      enhance_image(image)
      
      # Scan for barcodes
      result = `zbarimg -q #{image}`
      if $?.success?
        # Extract just the barcode data (remove format prefix like "CODE-128:")
        barcode = result.strip.split(':').last
        barcodes << barcode
      end
    end

    barcodes
  end

  def convert_page_to_image(pdf_path, page)
    output = Tempfile.new(['page', '.png'])
    MiniMagick::Tool::Convert.new do |convert|
      convert << "#{pdf_path}[#{page - 1}]"
      convert.density(300)
      convert << output.path
    end
    output.path
  end

  def enhance_image(image_path)
    MiniMagick::Tool::Convert.new do |convert|
      convert << image_path
      convert.colorspace('Gray')
      convert.auto_level
      convert.contrast
      convert.normalize
      convert.sharpen('0x1')
      convert << image_path
    end
  end
end
