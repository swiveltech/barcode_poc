# Sample barcode data
barcode_data = [
  {
    crn: '200051216188',
    provider_name: 'ABC Plumbing Services',
    plan_number: 'PLN-2023-001',
    amount: 144.53,
    gst_amount: 14.45,
    description: 'Emergency plumbing repair and maintenance'
  },
  {
    crn: '200051216189',
    provider_name: 'XYZ Electrical',
    plan_number: 'PLN-2023-002',
    amount: 275.00,
    gst_amount: 27.50,
    description: 'Electrical system upgrade'
  },
  {
    crn: '200051216190',
    provider_name: 'FastTrack Courier',
    plan_number: 'PLN-2023-003',
    amount: 89.99,
    gst_amount: 9.00,
    description: 'Express delivery service'
  },
  {
    crn: '200051216191',
    provider_name: 'Green Gardens',
    plan_number: 'PLN-2023-004',
    amount: 450.00,
    gst_amount: 45.00,
    description: 'Monthly landscape maintenance'
  },
  {
    crn: '200051216192',
    provider_name: 'SecureTech Systems',
    plan_number: 'PLN-2023-005',
    amount: 899.99,
    gst_amount: 90.00,
    description: 'Security system installation'
  }
]

# Clear existing data
BarcodeDatum.delete_all

# Insert sample data
barcode_data.each do |data|
  BarcodeDatum.create!(data)
end

puts "Created #{BarcodeDatum.count} barcode records"
