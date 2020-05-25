require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MedicaidEligibilityApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    config.assets.paths << Rails.root.join('app', 'assets', 'components')

    def options
      self.class.options
    end

    def self.options
      begin
        @@options ||= {
          :state_config => JSON.parse!(File.read(Rails.root.join('config/state_config.json'))),
          :system_config => JSON.parse!(File.read(Rails.root.join('config/system_config.json'))),
          :ineligibility_reasons => YAML.load_file(Rails.root.join('config/code_explanation.yml'))
        }.with_indifferent_access
      rescue JSON::ParserError
        raise JSON::ParserError, "failed to parse config file"
      end
    end
  end
end
