module Api
  module V1
    class ActivitiesController < ApplicationController
      PER_PAGE = 30

      # GET /api/v1/activities
      # クエリパラメータ: page=1, per_page=30, type=speech|sns|committee|vote|other
      def index
        page     = (params[:page] || 1).to_i
        per_page = (params[:per_page] || PER_PAGE).to_i.clamp(1, 100)

        activities = Activity.includes(:politician).recent
        activities = activities.by_type(params[:type]) if params[:type].present?

        total_count = activities.count
        activities  = activities.offset((page - 1) * per_page).limit(per_page)

        render json: {
          data: activities.map { |a| activity_with_politician_json(a) },
          meta: {
            total_count: total_count,
            page:        page,
            per_page:    per_page,
            total_pages: (total_count.to_f / per_page).ceil
          }
        }
      end

      private

      def activity_with_politician_json(activity)
        {
          id:            activity.id,
          activity_type: activity.activity_type,
          description:   activity.description,
          source_url:    activity.source_url,
          occurred_at:   activity.occurred_at,
          politician: {
            id:      activity.politician.id,
            name:    activity.politician.name,
            party:   activity.politician.party,
            chamber: activity.politician.chamber
          }
        }
      end
    end
  end
end
