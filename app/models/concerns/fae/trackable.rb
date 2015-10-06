module Fae::Trackable
  extend ActiveSupport::Concern

  included do
    after_create :add_create_change, if: :track_changes?
    before_update :add_update_change, if: :track_changes?
    before_destroy :add_delete_change, if: :track_changes?

    has_many :tracked_changes, -> { order(id: :desc) },
      as: :changeable,
      class_name: Fae::Change
  end

  def fae_tracker_blacklist
    []
  end

  def track_changes?
    Fae.track_changes && fae_tracker_blacklist != 'all'
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
    legit_attributes = changed - ignored_attributes
    if fae_tracker_blacklist.kind_of?(Array) && fae_tracker_blacklist.present?
      legit_attributes -= fae_tracker_blacklist.map(&:to_s)
    end
    legit_attributes
  end

  def ignored_attributes
    ['id', 'updated_at', 'created_at']
  end

  def clean_history
    tracked_changes.offset(Fae.tracker_history_length).destroy_all
  end

end
