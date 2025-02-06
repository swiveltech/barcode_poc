#!/usr/bin/env ruby

require 'pdf-reader'
require 'mini_magick'
require 'tempfile'
require 'fileutils'

class BarcodeReader
  MASK_PATTERN = {
    prefix: 1,      # * character
    ignore: 5,      # ##### (first 5 digits)
    crn: 12,        # RRRRRRRRRRRR (12 digits for CRN)
    ignore2: 8,     # ######## (8 digits to ignore)
    amount: 7       # $$$$$$$ (amount)
  }

  def self.read_barcode(pdf_path)
    puts "Reading PDF and scanning for barcodes..."
    
    temp_dir = Dir.mktmpdir
    begin
      # Convert first two pages of PDF to PNG
      reader = PDF::Reader.new(pdf_path)
      reader.pages.each_with_index do |page, index|
        break if index >= 2  # Only process first two pages
        
        begin
          # Set output filename
          png_file = File.join(temp_dir, "page_#{index + 1}.png")
          
          # Convert PDF page to PNG using ImageMagick
          MiniMagick::Tool::Convert.new do |convert|
            convert << "-density" << "600"  # Set DPI for better quality
            convert << "#{pdf_path}[#{index}]"  # Select page
            convert << png_file
          end
          
          # Enhance image with ImageMagick convert command
          enhanced_file = File.join(temp_dir, "enhanced_#{index + 1}.png")
          `convert #{png_file} -colorspace Gray -auto-level -contrast -normalize -sharpen 0x1 #{enhanced_file}`
          
          # Try to read barcode
          result = scan_barcode(enhanced_file)
          if result
            return parse_barcode(result)
          end
        rescue => e
          puts "Error processing page #{page.page}: #{e.message}"
        end
      end
      
      puts "No barcode found"
      nil
    ensure
      FileUtils.remove_entry(temp_dir) if Dir.exist?(temp_dir)
    end
  end

  private

  def self.scan_barcode(image_path)
    # Run zbarimg command
    output = `zbarimg --quiet --raw #{image_path} 2>/dev/null`
    output.strip unless output.empty?
  end



  def self.parse_barcode(barcode)
    puts "\nRaw barcode: #{barcode}"
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

    puts "\nParsed data:"
    puts "CRN: #{parts[:crn]}"
    puts "Amount: $#{sprintf('%.2f', amount)}"
    
    {
      crn: parts[:crn],
      amount: amount,
      raw_barcode: barcode
    }
  end
end

# Run if this file is being run directly
if __FILE__ == $0
  pdf_file = ARGV[0] || 'A-C6412633-79474750-1.pdf'
  pdf_path = File.expand_path(pdf_file, File.dirname(__FILE__))
  puts "Processing PDF: #{pdf_path}"
  BarcodeReader.read_barcode(pdf_path)
end
