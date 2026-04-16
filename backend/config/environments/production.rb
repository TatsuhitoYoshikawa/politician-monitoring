require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  # SSL は AWS ALB / CloudFront 側で終端するため Rails では不要
  config.force_ssl = false

  config.log_level = ENV.fetch("LOG_LEVEL", "info").to_sym
  config.log_tags = [:request_id]

  # 本番環境では stdout にログ出力（ECS / CloudWatch Logs 対応）
  config.logger = ActiveSupport::Logger.new($stdout)
    .tap { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.active_record.dump_schema_after_migration = false
end
