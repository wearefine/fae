module Fae
  class Change < ActiveRecord::Base

    belongs_to :user
    belongs_to :changeable, polymorphic: true

    serialize :updated_attributes

    # writing current_user to thread for thread safety
    class << self
      def current_user=(user)
        Thread.current[:current_user] = user
      end

      def current_user
        Thread.current[:current_user]
      end

      def filter(params)
        # build conditions if specific params are present
        conditions = {}
        conditions[:user_id] = params['user'] if params['user'].present?
        conditions[:change_type] = params['type'] if params['type'].present?

        # use good 'ol MySQL to seach if search param is present
        search = []
        if params['search'].present?
          search = ["fae_users.first_name LIKE ? OR fae_users.last_name LIKE ? OR fae_changes.updated_attributes LIKE ?", "%#{params['search']}%", "%#{params['search']}%", "%#{params['search']}%"]
        end

        # apply conditions and search from above to our scope
        order(id: :desc)
          .includes(:user).references(:user)
          .where(conditions).where(search)
      end
    end
  end
end
