module Fae
  # Validation errors, in the shape Inertia's Vue adapter expects.
  #
  # Shared by the top-level and nested renderers: both hand their failures back
  # through `redirect_to ..., inertia: { errors: }`, and a nested save has to
  # produce the same shape as a top-level one so one form component can render
  # either.
  module InertiaErrors
    extend ActiveSupport::Concern

    private

    # ActiveModel::Errors#to_hash yields arrays of bare messages; Inertia's Vue
    # adapter expects one already-humanized string per field, so join the
    # full_messages instead.
    def fae_inertia_errors(item)
      item.errors.to_hash.keys.each_with_object({}) do |attribute, errors|
        message = item.errors.full_messages_for(attribute).to_sentence
        # Keys are stringified because the derived ones below are strings, and
        # a mix would collide once the hash is serialized to JSON.
        errors[attribute.to_s] = message

        # A belongs_to presence validation reports against the association
        # name, but the field on the form is the foreign key, so publish the
        # message under both or the select would show no error.
        foreign_key = "#{attribute}_id"
        errors[foreign_key] = message if item.class.column_names.include?(foreign_key)

        # accepts_nested_attributes_for copies a child's failures up as
        # "logo.asset"; the form's field is the association, so it needs the
        # message under "logo" too. First one wins, so a message reported
        # directly against the association is not overwritten.
        association, _, nested = attribute.to_s.partition('.')
        errors[association] ||= message if nested.present?
      end
    end

    # Inertia's error-bag protocol: a form names a bag in the request header
    # and expects its errors nested under that key, so several forms can share
    # a page without one's failures marking up another's fields. inertia_rails
    # does not implement the server half, so honour the header here.
    def fae_inertia_scoped_errors(item)
      errors = fae_inertia_errors(item)
      bag = request.headers['X-Inertia-Error-Bag']

      bag.present? ? { bag => errors } : errors
    end
  end
end
