class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found
    render json: { error: "Not found" }, status: :not_found
  end

  # スクレイパーからのリクエストを Bearer token で認証
  def authenticate_scraper!
    token = request.headers["Authorization"]&.sub(/\ABearer /, "")
    expected = ENV.fetch("SCRAPER_BEARER_TOKEN", "")

    unless token.present? && expected.present? &&
           ActiveSupport::SecurityUtils.secure_compare(token, expected)
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
