module <%= options.namespace.capitalize %>
  class <%= class_name.pluralize %>Controller < Fae::ApplicationController
    before_action :set_item, only: [:show, :edit, :update, :destroy]

    layout false, except: :index
    helper Fae::ApplicationHelper

    def new
      @item = <%= class_name %>.new
<% if options.parent_model.present? -%>
      @item.<%= options.parent_model.underscore %>_id = params[:item_id]
<% else -%>
      # belongs_to_association_id should be replaced with the foreign key associated with <%= class_name %>
      # @item.belongs_to_association_id = params[:item_id]
<% end -%>
    end

    def edit
    end

    def create
      @item = <%= class_name %>.new(permitted_params)

      if @item.save
<% if options.parent_model.present? -%>
        @parent_item = @item.<%= options.parent_model.underscore %>
<% else -%>
        # 'belongs_to_association' should be replaced with the actual association name
        # @parent_item = @item.belongs_to_association
<% end -%>
        flash[:notice] = 'Item successfully created.'
        render template: '<%= options.namespace %>/<%= plural_file_name %>/table'
      else
        render action: 'new'
      end
    end

    def update
      if @item.update(permitted_params)
<% if options.parent_model.present? -%>
        @parent_item = @item.<%= options.parent_model.underscore %>
<% else -%>
        # 'belongs_to_association' should be replaced with the actual association name
        # @parent_item = @item.belongs_to_association
<% end -%>
        flash[:notice] = 'Item successfully updated.'
        render template: '<%= options.namespace %>/<%= plural_file_name %>/table'
      else
        render action: 'edit'
      end
    end

    def destroy
<% if options.parent_model.present? -%>
      @parent_item = @item.<%= options.parent_model.underscore %>
<% else -%>
      # 'belongs_to_association' should be replaced with the actual association name
      # @parent_item = @item.belongs_to_association
<% end -%>

      if @item.destroy
        flash[:notice] = 'Item successfully removed.'
      else
        flash[:alert] = 'There was a problem removing your item.'
      end
      render template: '<%= options.namespace %>/<%= plural_file_name %>/table'
    end

    private

    def set_item
      @item = <%= class_name %>.find(params[:id])
    end

    def permitted_params
      params.require(:<%= singular_table_name %>).permit!
    end

  end
end
