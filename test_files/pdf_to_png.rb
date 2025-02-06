#!/usr/bin/env ruby

require 'pdftoimage'

def convert_pdf_to_png(pdf_path)
  puts "Converting PDF: #{pdf_path}"
  
  pages = PDFToImage.open(pdf_path)
  pages.each do |page|
    output_file = "page_#{page.page}.png"
    puts "Converting page #{page.page} to #{output_file}"
    
    # Set high resolution and save
    page.r(600)  # Set resolution to 600 DPI
    page.save(output_file)
  end
  
  puts "Conversion complete!"
end

if __FILE__ == $0
  pdf_file = ARGV[0] || 'A-C6412633-79474750-1.pdf'
  convert_pdf_to_png(pdf_file)
end
