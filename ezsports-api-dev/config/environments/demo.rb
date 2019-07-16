Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = false

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = false

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

#   config.action_mailer.smtp_settings = {
#     :address   => "smtp.mandrillapp.com",
#     :port      => 587, # ports 587 and 2525 are also supported with STARTTLS
#     :enable_starttls_auto => true, # detects and uses STARTTLS
#     :user_name => "tguthrie@ez4mylife.com",
#     :password  => "8qJ4Vpi65Dg4WEBDX1W_Jw", # SMTP password is any valid API key
#     :authentication => 'login', # Mandrill supports 'plain' or 'login'
#     :domain => 'localhost' # your domain to identify your server when connecting
#   }

  ENV['Admin_Domain'] = "http://admin-demo.ez4mysports.com/"
  ENV['Team_Domain'] = "http://team-demo.ez4mysports.com/"

  # ENV['SENDGRID'] = "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"
  ENV['SENDGRID'] = "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"
  ENV['stripe_secret'] = "sk_test_vOb4ndurTd50zIp03QyWyqoc"

  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = "bz5bcmgyv8jp332d"
  Braintree::Configuration.public_key = "6b7tqnc6vb2bh4vk"
  Braintree::Configuration.private_key = "91f5dff89662813a32bfaad4e62dc7da"
end
