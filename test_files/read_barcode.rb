#!/usr/bin/env ruby

require 'mini_magick'
require 'tempfile'

def scan_barcode(image_path)
  puts "Reading barcode from: #{image_path}"
  
  # Create temporary file
  temp_file = Tempfile.new(['enhanced', '.png'])
  
  begin
    # Load and preprocess image
    image = MiniMagick::Image.open(image_path)
    
    # Convert to grayscale and enhance contrast
    image.combine_options do |b|
      b.colorspace 'Gray'
      b.auto_level
      b.contrast
      b.normalize
      b.sharpen '0x1'
    end
    
    # Save enhanced image
    image.write(temp_file.path)
    
    # Run zbarimg command
    output = `zbarimg --quiet --raw #{temp_file.path} 2>/dev/null`
    
    if output.empty?
      puts "\nNo barcodes found"
    else
      puts "\nFound barcodes:"
      output.each_line do |line|
        puts "Data: #{line.strip}"
      end
    end
  ensure
    temp_file.close
    temp_file.unlink
  end
end

if __FILE__ == $0
  image_file = ARGV[0] || 'page_1.png'
  scan_barcode(image_file)
end
