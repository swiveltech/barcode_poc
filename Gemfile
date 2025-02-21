source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Core
gem 'rails', '~> 5.1.7'
gem 'sqlite3', '~> 1.4.2'
gem 'puma', '~> 3.7'

# Assets
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

# Image and PDF Processing
gem 'mini_magick'    # For image processing
gem 'pdf-reader'     # For reading PDF files

# API and Serialization
gem 'active_model_serializers' # For JSON serialization
gem 'rack-cors'               # For handling CORS

# File Upload and Storage
gem 'carrierwave'            # For file uploads

# Background Processing
gem 'sidekiq'                # For background jobs
gem 'aws-sdk-s3'
gem 'dotenv-rails'
