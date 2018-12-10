# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CommunityApp
  # Top level Application class
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Include the authenticity token in remote forms.
    config.action_view.embed_authenticity_token_in_remote_forms = true

    # set to false is deprecated
    # (SQLite databases have used 't' and 'f' to serialize boolean values)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end
