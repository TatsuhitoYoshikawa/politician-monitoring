module Api
  module V1
    class PoliticiansController < ApplicationController
      # GET /api/v1/politicians
      # クエリパラメータ: chamber=衆院|参院, party=自民党|..., q=検索文字列
      def index
        politicians = Politician.includes(:activities).all

        politicians = politicians.where(chamber: params[:chamber]) if params[:chamber].present?
        politicians = politicians.where(party: params[:party])     if params[:party].present?

        if params[:q].present?
          q = "%#{params[:q]}%"
          politicians = politicians.where("name LIKE ? OR name_kana LIKE ?", q, q)
        end

        politicians = politicians.order(:name_kana)

        render json: {
          data: politicians.map { |p| politician_list_json(p) }
        }
      end

      # GET /api/v1/politicians/:id
      # クエリパラメータ: page=1, per_page=20
      def show
        politician = Politician.find(params[:id])
        page     = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 20).to_i.clamp(1, 100)

        activities    = politician.activities.recent.offset((page - 1) * per_page).limit(per_page)
        total_count   = politician.activities.count

        render json: {
          data: {
            id:             politician.id,
            name:           politician.name,
            name_kana:      politician.name_kana,
            party:          politician.party,
            chamber:        politician.chamber,
            constituency:   politician.constituency,
            photo_url:      politician.photo_url,
            twitter_handle: politician.twitter_handle,
            homepage_url:   politician.homepage_url,
            activities:     activities.map { |a| activity_json(a) }
          },
          meta: {
            total_count: total_count,
            page:        page,
            per_page:    per_page,
            total_pages: (total_count.to_f / per_page).ceil
          }
        }
      end

      private

      def politician_list_json(politician)
        # activities は includes で読み込み済みなのでクエリ追加なし
        latest = politician.activities.max_by(&:occurred_at)
        {
          id:                          politician.id,
          name:                        politician.name,
          name_kana:                   politician.name_kana,
          party:                       politician.party,
          chamber:                     politician.chamber,
          constituency:                politician.constituency,
          photo_url:                   politician.photo_url,
          twitter_handle:              politician.twitter_handle,
          latest_activity_at:          latest&.occurred_at,
          latest_activity_description: latest&.description,
          latest_activity_type:        latest&.activity_type
        }
      end

      def activity_json(activity)
        {
          id:            activity.id,
          activity_type: activity.activity_type,
          description:   activity.description,
          source_url:    activity.source_url,
          occurred_at:   activity.occurred_at
        }
      end
    end
  end
end
