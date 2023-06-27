require_relative "boot"

require "rails/all"
require 'aws-sdk-secretsmanager'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


module PersonalSite
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1


    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    

    # Setup Aurora DB connection details getting credential and host info from AWS secrets manager
    # TODO: move this to a seperate method

     client = Aws::SecretsManager::Client.new(region: 'us-east-1')
    
      begin
        get_secret_value_response = client.get_secret_value(secret_id: 'Profile-DB-Server-User')
      rescue StandardError => e
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e
      end
    
      secret_data = JSON.parse(get_secret_value_response.secret_string)
      Rails.configuration.aurora_user = secret_data['username']
      Rails.configuration.aurora_password = secret_data['password']  
      Rails.configuration.aurora_host = secret_data['host']
      Rails.configuration.aurora_port = '3306'
      
  end
end
