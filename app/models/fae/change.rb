module Fae
  class Change < ActiveRecord::Base
    include Fae::Sortable
    include Fae::ChangeConcern

    belongs_to :user
    belongs_to :changeable, polymorphic: true

    serialize :updated_attributes

    def main_app
      Rails.application.class.routes.url_helpers
    end

    def fae_scope
      Fae::ApplicationHelper.helpers.fae_scope
    end

    class << self
      # writing current_user to thread for thread safety
      def current_user=(user)
        Thread.current[:current_user] = user
      end

      def current_user
        Thread.current[:current_user]
      end

      def unique_changeable_types
        pluck(:changeable_type).uniq.sort.map{ |changeable_type| [changeable_type.gsub('Fae::',''), changeable_type] }
      end

      def filter(params)
        # build conditions if specific params are present
        conditions = {}
        conditions[:user_id] = params['user'] if params['user'].present?
        conditions[:changeable_type] = params['model'] if params['model'].present?
        conditions[:change_type] = params['type'] if params['type'].present?
        params['date'] ||= ''

        date_scope = []
        if params['start_date'].present? || params['end_date'].present?
          start_date = params['start_date'].present? ? CGI.unescape(params['start_date']).to_date : nil
          end_date   = params['end_date'].present? ? CGI.unescape(params['end_date']).to_date : nil
          date_scope = ['fae_changes.updated_at >= ?', start_date] if start_date.present?
          date_scope = ['fae_changes.updated_at <= ?', end_date] if end_date.present?
          date_scope = ['fae_changes.updated_at >= ? AND fae_changes.updated_at <= ?', start_date, end_date] if start_date.present? && end_date.present?
        else
          date_scope = case params['date'].downcase.gsub('%20', '-')
          when 'last-hour' then   ['fae_changes.updated_at >= ?', 60.minutes.ago]
          when 'last-day' then    ['fae_changes.updated_at >= ?', 1.day.ago]
          when 'last-week' then   ['fae_changes.updated_at >= ?', 1.week.ago]
          when 'last-month' then  ['fae_changes.updated_at >= ?', 1.month.ago]
          else
            []
          end
        end

        # use good 'ol MySQL to search if search param is present
        search = []
        if params['search'].present?
          search = ["fae_users.first_name LIKE ? OR fae_users.last_name LIKE ? OR fae_changes.updated_attributes LIKE ? OR fae_changes.changeable_type LIKE ? OR fae_changes.change_type LIKE ?", "%#{params['search']}%", "%#{params['search']}%", "%#{params['search']}%", "%#{params['search']}%", "%#{params['search']}%"]
        end

        # apply conditions and search from above to our scope
        order(id: :desc)
          .includes(:user).references(:user)
          .where(date_scope).where(conditions).where(search)
      end

    end
  end
end
