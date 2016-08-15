module Fae
  module Trackable
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
      return if has_parent?
      attrs = {
        changeable_id: id,
        changeable_type: self_or_super_class_name,
        user_id: Fae::Change.current_user,
        change_type: 'created'
      }
      attrs = adjust_attrs_if_fae_tracker_parent(attrs,'created')
      Fae::Change.create(attrs)
    end

    def add_update_change
      if has_parent?
        update_parent
      else
        return if legit_updated_attributes.blank?
        attrs = {
          changeable_id: id,
          changeable_type: self_or_super_class_name,
          user_id: Fae::Change.current_user,
          change_type: 'updated',
          updated_attributes: legit_updated_attributes
        }
        attrs = adjust_attrs_if_fae_tracker_parent(attrs,'updated')
        Fae::Change.create(attrs)
        clean_history
      end
    end

    def add_delete_change
      return if has_parent?
      attrs = {
        changeable_id: id,
        changeable_type: self_or_super_class_name,
        user_id: Fae::Change.current_user,
        change_type: 'deleted'
      }
      attrs = adjust_attrs_if_fae_tracker_parent(attrs,'deleted')
      Fae::Change.create(attrs)
      clean_history
    end

    def self_or_super_class_name
      self.class.superclass.name == 'Fae::StaticPage' ? 'Fae::StaticPage' : self.class.name
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

    def has_parent?
      %w(Fae::Image Fae::File Fae::TextField Fae::TextArea).include? self.class.name
    end

    def asset_name
      attached_as || self.class.name.gsub('Fae::','').underscore
    end

    def update_parent
      parent = self.try(:imageable) || self.try(:fileable) || self.try(:contentable)
      if parent.present?
        latest_change = parent.try(:tracked_changes).try(:first)
        if latest_change.present? && latest_change.change_type == 'updated' && latest_change.updated_at > 2.seconds.ago
          updated_updated_attributes = latest_change.updated_attributes << asset_name
          latest_change.update_attribute(:updated_attributes, updated_updated_attributes)
        else
          Fae::Change.create({
            changeable_id: parent.id,
            changeable_type: parent.class.name,
            user_id: Fae::Change.current_user,
            change_type: 'updated',
            updated_attributes: [asset_name]
          })
        end
      end
    end

    def adjust_attrs_if_fae_tracker_parent(attrs, change_type)
      if fae_tracker_parent
        attrs[:changeable_id] = fae_tracker_parent.id
        attrs[:changeable_type] = fae_tracker_parent.class.name
        attrs[:change_type] = "#{self.class.name.titleize} #{fae_display_field} #{change_type}"
      end
      attrs
    end

  end
end
