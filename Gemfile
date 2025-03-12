source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"

# Web Server
gem "puma", ">= 5.0"

# JSON API Builder
gem "jbuilder"

# Authentication & Security
gem "bcrypt", "~> 3.1.7" # Secure passwords
gem "jwt", "~> 2.0"      # Token-based authentication

# Database & Caching
gem "redis", ">= 4.0.1"  # Redis adapter for Action Cable, caching, etc.

# Environment Variables
gem "dotenv-rails"

# Timezone Data (for Windows & JRuby)
gem "tzinfo-data", platforms: %i[windows jruby]

# Performance Optimization
gem "bootsnap", require: false # Reduces boot times

group :development, :test do
  # Debugging Tools
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "byebug"

  # Testing Framework
  gem "rspec-rails"
  gem "fabrication"
  gem "faker"

  # Code Quality
  gem "rubocop"
  gem "rubocop-rails-omakase", require: false

  # Security/Vulnerability analysis
  gem "brakeman"
end

group :test do
  gem "timecop" # Freezes time for predictable test behavior
end
