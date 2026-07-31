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
        errors[attribute] = message

        # A belongs_to presence validation reports against the association
        # name, but the field on the form is the foreign key, so publish the
        # message under both or the select would show no error.
        foreign_key = "#{attribute}_id"
        errors[foreign_key] = message if item.class.column_names.include?(foreign_key)
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
