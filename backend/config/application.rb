require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_dispatch/railtie"

Bundler.require(*Rails.groups)

module PoliticianMonitoring
  class Application < Rails::Application
    config.load_defaults 7.1

    # API モードで動作
    config.api_only = true

    # タイムゾーン
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :utc

    # ロケール
    config.i18n.default_locale = :ja
    config.i18n.available_locales = [:ja, :en]

    # ログレベル（環境変数で上書き可）
    config.log_level = ENV.fetch("LOG_LEVEL", "info").to_sym
  end
end
