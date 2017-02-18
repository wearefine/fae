module Fae
  module Cloneable
    extend ActiveSupport::Concern

    private

    def create_from_existing(id)
      @item = @klass.find(id)
      @cloned_item = @item.dup
      update_cloned_attributes(@cloned_item)
      @cloned_item.on_prod = false

      if @cloned_item.save
        update_cloneable_associations
        redirect_to @index_path + '/' + @cloned_item.id.to_s + '/edit'
      else
        build_assets
        flash[:alert] = @cloned_item.errors.full_messages
        render action: 'edit'
      end
    end

    # array of symbols used for setting up associations on cloned object
    def associations_for_cloning
      []
    end

    # array of symbols used for cloning only specific attributes
    def attributes_for_cloning
      @klass.column_names
    end

    def update_cloned_attributes(item)
      attribute_names = attributes_for_cloning.map(&:to_s) - ['id']
      item.attributes.each do |attribute, value|
        if attribute_names.include? attribute
          rename_unique_attribute(item, attribute, value) if attr_is_unique?(item, attribute)
        else
          item.send("#{attribute}=", nil)
        end
      end
    end

    # set cloneable attributes and associations
    def update_cloneable_associations
      associations_for_cloning.each do |association|
        type = @klass.reflect_on_association(association)
        through_record = type.through_reflection

        if through_record.present?
          clone_join_relationships(through_record.plural_name)
        else
          clone_has_one_relationship(association) if type.macro == :has_one
          clone_has_many_relationships(association) if type.macro == :has_many
        end
      end
    end

    def clone_has_one_relationship(association)
      @cloned_item.send(association) << @item.send(association).dup if @item.send(association).present?
    end

    def clone_has_many_relationships(association)
      if @item.send(association).present?
        @item.send(association).each do |record|
          new_record = association.to_s.classify.constantize.find_by_id(record.id).dup
          new_record.send("#{@klass_singular}_id" + '=', @cloned_item.id) if new_record.send("#{@klass_singular}_id").present?
          # check if associations have unique attributes
          new_record.attributes.each do |attribute, value|
            rename_unique_attribute(new_record, attribute, value) if attr_is_unique?(new_record, attribute.first)
          end

          @cloned_item.send(association) << new_record
        end
      end
    end

    def clone_join_relationships(object)
      if @item.send(object.to_sym).present?
        @item.send(object.to_sym).each do |record|
          copied_join = object.classify.constantize.find_by_id(record.id).dup
          copied_join.send("#{@klass_singular}_id" + '=', @cloned_item.id)
          @cloned_item.send(object.to_sym) << copied_join
        end
      end
    end

    def rename_unique_attribute(item, attribute, value)
      index = 2
      symbol = attribute.to_sym
      value = unique_name(item, attribute, value, index.to_s)

      begin
        record = item.class.where(symbol => value)
        unless record.empty?
          new_index = index + 1
          value = value.chomp(index.to_s) + new_index.to_s
          index = new_index
        end
      end while record.present?

      item[symbol] = value
    end

    def attr_is_unique?(item, attribute)
      item.class.validators_on(attribute.to_sym).map(&:class).include? ActiveRecord::Validations::UniquenessValidator
    end

    def unique_name(item, attribute, value, suffix)
      item.class.validators_on(attribute.to_sym).each do |validator|
        if validator.class.name.include?('LengthValidator') && validator.options[:maximum].present?
          max_length = validator.options[:maximum] - (suffix.length + 1)
          value = value[0...max_length]
          break
        end
      end

      "#{value}-#{suffix}"
    end
  end
end
