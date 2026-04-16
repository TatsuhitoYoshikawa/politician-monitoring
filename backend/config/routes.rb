Rails.application.routes.draw do
  # ヘルスチェック（AWS ALB / ECS のヘルスチェックにも使用）
  get "/health", to: proc { [200, { "Content-Type" => "application/json" }, ['{"status":"ok"}']] }

  namespace :api do
    namespace :v1 do
      # 議員
      resources :politicians, only: [:index, :show]

      # 活動（全議員横断）
      resources :activities, only: [:index]

      # スクレイパーからのデータ受信口（Bearer token 認証）
      namespace :scraper do
        resources :activities, only: [:create]
      end
    end
  end
end
