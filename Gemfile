# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.3', '>= 7.1.3.4'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem 'tailwindcss-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '>= 4.0.1'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

################################################################################
# Application gems
################################################################################

# Pretty print Ruby objects with style
gem 'awesome_print'

# Ancestry is a gem that allows rails ActiveRecord models to be organized as a tree structure (or hierarchy).
gem 'ancestry'

# Flexible authentication solution for Rails with Warden
gem 'devise'

# Soft deletes for ActiveRecord done right
gem 'discard'

# Build ActiveRecord named scopes to use PostgreSQL's full-text search
gem 'pg_search'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]

  # A Ruby gem to load environment variables from .env
  gem 'dotenv-rails'

  # Factory Bot for Rails
  gem 'factory_bot_rails'

  # A library for generating fake data
  gem 'faker'

  # RSpec for Rails 6+
  gem 'rspec-rails'
end

group :development do
  # Annotate Rails classes with schema and routes info
  gem 'annotate'

  # Better error page for Rack apps
  gem 'better_errors'

  # Retrieve the binding of a method's caller
  gem 'binding_of_caller'

  # Kill N+1 queries and unused eager loading
  gem 'bullet'

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  # Format ERB files with speed and precision
  gem 'erb-formatter', require: false

  # Lint your ERB or HTML files
  gem 'erb_lint', require: false

  # Add speed badges
  # gem 'rack-mini-profiler'

  # Static Ruby code analyzer and formatter, based on the community style guide
  gem 'rubocop', require: false

  # Code style checking for Capybara files
  gem 'rubocop-capybara', require: false

  # Code style checking for factory_bot files
  gem 'rubocop-factory_bot', require: false

  # An extension of RuboCop focused on code performance checks
  gem 'rubocop-performance', require: false

  # Code style checking for Rails applications
  gem 'rubocop-rails', require: false

  # Code style checking for RSpec files
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false

  # The Ruby formatter
  gem 'rufo', require: false
end
