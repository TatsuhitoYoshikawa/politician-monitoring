Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 開発: 全オリジン許可
    # 本番: ENV["ALLOWED_ORIGINS"] で CloudFront の URL などを指定
    origins ENV.fetch("ALLOWED_ORIGINS", "*").split(",")

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["X-Total-Count"]
  end
end
