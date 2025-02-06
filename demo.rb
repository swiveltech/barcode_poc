require_relative 'lib/invoice_processor'
require_relative 'lib/barcode_store'

# Initialize our barcode store with some test data
store = BarcodeStore.instance
store.add_barcode('200051216188', {
  provider_id: 1,
  provider_name: "ABC Services",
  plan_number: "PLAN-123",
  gst_registered: true
})

# Initialize invoice processor with default mask
processor = InvoiceProcessor.new

# Process a sample invoice
puts "Processing invoice..."
result = processor.process_invoice('test_files/A-C6412633-79474750-1.pdf')

if result[:success]
  puts "\nBarcode successfully processed!"
  puts "CRN: #{result[:crn]}"
  puts "Amount: $#{result[:amount]}"
  puts "\nProvider Details:"
  puts "Name: #{result[:provider_details][:provider_name]}"
  puts "Plan: #{result[:provider_details][:plan_number]}"
else
  puts "\nError: #{result[:error]}"
end

# Show processing history
puts "\nProcessing History:"
store.get_history.each do |entry|
  status = entry[:success] ? "Success" : "Failed"
  puts "#{entry[:timestamp]}: #{status} - Barcode: #{entry[:barcode]}"
end
