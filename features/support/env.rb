ENV['RAILS_ENV'] = 'test'
require './config/environment'
require 'pg'
require 'rspec-rails'
require 'factory_girl_rails'
require './features/steps/helpers'
require 'capybara/rspec'
require 'capybara/rails'
require 'spinach-rails'
require 'poltergeist'
require 'selenium-webdriver'


# require 'database_cleaner'
# DatabaseCleaner.strategy = :truncation
#
# Spinach.hooks.before_scenario{ DatabaseCleaner.clean }
#
# Spinach.config.save_and_open_page_on_failure = true

# disables poltergeist logging
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    extensions: [ 'features/support/logs.js' ],
    js_errors:   true
  )
end

Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 10

Spinach.hooks.on_tag("javascript") { ::Capybara.current_driver = ::Capybara.javascript_driver }
Spinach.config[:failure_exceptions] << RSpec::Expectations::ExpectationNotMetError
Spinach::FeatureSteps.include RSpec::Matchers
Spinach::FeatureSteps.include FactoryGirl::Syntax::Methods
Spinach.hooks.before_run { FactoryGirl.reload }

# disables rack logging
module Rack
  class CommonLogger
    def call(env)
      # do nothing
      @app.call(env)
    end
  end
end
