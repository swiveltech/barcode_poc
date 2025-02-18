#!/bin/bash

# Generate production secret
export SECRET_KEY_BASE=$(bundle exec rails secret)

# Build and run
docker build -t barcode-app .
docker run -d \
  -p 80:3000 \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=$SECRET_KEY_BASE \
  -e AWS_ACCESS_KEY_ID=your_access_key \
  -e AWS_SECRET_ACCESS_KEY=your_secret_key \
  -e AWS_REGION=ap-south-1 \
  -e AWS_BUCKET=your_bucket_name \
  -v $(pwd)/db:/app/db \
  --name barcode-app \
  barcode-app