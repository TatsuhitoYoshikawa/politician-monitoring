module Api
  module V1
    module Scraper
      # スクレイパーマイクロサービスからのデータ受信口
      # Bearer token 認証必須
      class ActivitiesController < ApplicationController
        before_action :authenticate_scraper!

        # POST /api/v1/scraper/activities
        # Body: { activities: [{ politician_id:, activity_type:, description:, source_url:, occurred_at: }, ...] }
        def create
          items   = params.require(:activities)
          created = []
          errors  = []

          items.each_with_index do |item, idx|
            politician = Politician.find_by(id: item[:politician_id])

            unless politician
              errors << { index: idx, error: "politician_id #{item[:politician_id]} not found" }
              next
            end

            activity = politician.activities.build(
              activity_type: item[:activity_type],
              description:   item[:description],
              source_url:    item[:source_url],
              occurred_at:   item[:occurred_at]
            )

            if activity.save
              created << activity.id
            else
              errors << { index: idx, error: activity.errors.full_messages.join(", ") }
            end
          end

          render json: {
            created_count: created.size,
            created_ids:   created,
            errors:        errors
          }, status: :created
        end
      end
    end
  end
end
