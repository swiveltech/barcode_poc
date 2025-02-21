FROM ruby:2.6.6

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y nodejs npm sqlite3 libsqlite3-dev

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy only the necessary files
COPY app/ app/
COPY bin/ bin/
COPY config/ config/
COPY db/ db/
COPY lib/ lib/
COPY public/ public/
COPY config.ru ./
COPY Rakefile ./

# Create database directory
RUN mkdir -p db
RUN chmod 777 db

# Precompile assets
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile

# Expose port 3000
EXPOSE 3000

# Start the server
CMD ["rails", "server", "-b", "0.0.0.0", "-e", "production"]