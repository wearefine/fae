module Fae::Trackable
  extend ActiveSupport::Concern

  included do
    after_create :add_create_change
    before_update :add_update_change
    before_destroy :add_delete_change

    has_many :tracked_changes, -> { order(id: :desc) },
      as: :changeable,
      class_name: Fae::Change
  end

  private

  def add_create_change
    Fae::Change.create({
      changeable_id: id,
      changeable_type: self.class.name,
      user_id: Fae::Change.current_user,
      change_type: 'created'
    })
  end

  def add_update_change
    return if legit_updated_attributes.blank?
    Fae::Change.create({
      changeable_id: id,
      changeable_type: self.class.name,
      user_id: Fae::Change.current_user,
      change_type: 'updated',
      updated_attributes: legit_updated_attributes
    })
    clean_history
  end

  def add_delete_change
    Fae::Change.create({
      changeable_id: id,
      changeable_type: self.class.name,
      user_id: Fae::Change.current_user,
      change_type: 'deleted'
    })
    clean_history
  end

  def legit_updated_attributes
    changed - ['id', 'updated_at', 'created_at']
  end

  def clean_history
    tracked_changes.offset(Fae.tracker_history_length).destroy_all
  end

end
