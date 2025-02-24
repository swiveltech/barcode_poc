# Barcode Processing System

A distributed system for processing barcodes from PDF invoices, consisting of a Ruby on Rails frontend application and a Go-based AWS Lambda function for barcode processing.

## Architecture Overview

### Frontend (Ruby on Rails)
- Handles invoice uploads and management
- Tracks barcode processing status
- Provides API endpoints for Lambda callbacks
- Manages invoice data and processing history

### Backend (Go Lambda)
- Processes PDF files from S3
- Extracts and validates barcodes
- Supports multiple barcode formats (UPC/EAN, Code128, Code39)
- Reports results back to Rails application

## System Requirements

### Frontend Requirements (Ruby)
- Ruby 2.6.6 or higher
- Rails 6.0 or higher
- SQLite3 database (development/test)

### Backend Requirements (Go Lambda)
- Go 1.19 or higher
- AWS SDK
- AWS Lambda environment

## Setup and Installation

### Frontend Setup
1. Install Ruby dependencies:
```bash
bundle install
```

2. Setup SQLite database and seed data:
```bash
# Run migrations
rails db:migrate

# Load seed data (barcode patterns and test data)
rails db:seed

# For fresh setup (reset + migrate + seed)
rails db:reset db:setup
```

Note: SQLite database will be automatically created in db/development.sqlite3

The seed data includes:
- Default barcode patterns
- Sample customer reference numbers (CRN)
- Test invoice data

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configurations
```

### Lambda Deployment
1. Build the Lambda function:
```bash
cd pdf_processor_go
go build
```

2. Create Lambda deployment package:
```bash
zip -j function.zip bootstrap
```

3. Upload and Deploy to AWS:
```bash
# Upload deployment package to S3
aws s3 cp function.zip s3://your-deployment-bucket/lambda/function.zip

# Update Lambda function code from S3
aws lambda update-function-code \
  --function-name barcode-processor \
  --s3-bucket your-deployment-bucket \
  --s3-key lambda/function.zip

# Configure Lambda settings
aws lambda update-function-configuration \
  --function-name barcode-processor \
  --timeout 60 \
  --memory-size 512

# Verify deployment
aws lambda get-function --function-name barcode-processor
```

Note: Replace `your-deployment-bucket` with your actual S3 bucket name.

Note: Lambda function is configured with:
- Timeout: 60 seconds (1 minute)
- Memory: 512 MB (recommended for PDF processing)
- Runtime: provided.al2

## Configuration

### Required Environment Variables
- Frontend (.env):
  ```
  AWS_ACCESS_KEY_ID=your_access_key
  AWS_SECRET_ACCESS_KEY=your_secret_key
  AWS_REGION=your_region
  S3_BUCKET=your-bucket-name
  LAMBDA_FUNCTION_NAME=barcode-processor
  DEPLOYMENT_BUCKET=your-deployment-bucket  # For Lambda deployments
  ```

- Lambda:
  ```
  API_ENDPOINT=your_rails_callback_url
  ```

## Processing Flow
1. Invoice Upload
   - User uploads PDF to Rails application
   - File is stored in S3
   - Processing job is created

2. Lambda Processing
   - Triggered by S3 event
   - Extracts images from PDF
   - Scans for barcodes
   - Validates barcode format

3. Result Processing
   - Lambda sends results to Rails callback endpoint
   - Rails application updates invoice status
   - User is notified of completion

## API Endpoints

### Frontend Endpoints
- POST `/api/v1/invoices`: Upload new invoice
- GET `/api/v1/invoices/:id`: Get invoice status
- POST `/api/v1/invoices/:id/barcode_result`: Lambda callback endpoint

## Monitoring and Logging
- Frontend: Rails logger and Sidekiq dashboard
- Lambda: CloudWatch logs and metrics
- Processing status tracked in database

## Error Handling
- Failed processing attempts are tracked
- Automatic retry mechanism for failed jobs
- Error notifications via Rails application

## Development

### Local Testing
1. Frontend:
```bash
rails server
```

2. Lambda (using test event):
```bash
cd pdf_processor_go
go test ./...
```

## Security
- AWS IAM roles for Lambda
- API authentication for callbacks
- Secure file handling
- Environment variable management

## Performance
- Lambda optimized for fast processing
- Memory allocation: 512MB (optimized for PDF processing)
- Quick cold starts (~100ms)
- Maximum execution time: 60 seconds
- Parallel processing capability

Note: If processing exceeds 60 seconds, the Lambda function will timeout and return an error. Ensure PDFs are optimized and not too large.

## Contributing
1. Fork the repository
2. Create your feature branch
3. Submit a pull request

## License
MIT License

