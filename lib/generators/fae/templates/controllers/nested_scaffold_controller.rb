class <%= options.namespace.capitalize %>::<%= class_name.pluralize %>Controller < ApplicationController
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

    respond_to do |format|
      if @item.save
        format.html {
<% if options.parent_model.present? -%>
          @parent_item = @item.<%= options.parent_model.underscore %>
<% else -%>
          # 'belongs_to_association' should be replaced with the actual association name
          # @parent_item = @item.belongs_to_association
<% end -%>
          flash[:notice] = "Item successfully created."
          render template: '<%= options.namespace %>/<%= plural_file_name %>/table'
        }
        format.json { render action: 'show', status: :created, location: @item }
      else
        format.html { render action: 'new' }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @item.update(permitted_params)
        format.html {
<% if options.parent_model.present? -%>
          @parent_item = @item.<%= options.parent_model.underscore %>
<% else -%>
          # 'belongs_to_association' should be replaced with the actual association name
          # @parent_item = @item.belongs_to_association
<% end -%>
          flash[:notice] = "Item successfully updated."
          render template: '<%= options.namespace %>/<%= plural_file_name %>/table'
        }
        format.json { render action: 'show', status: :created, location: @item }
      else
        format.html { render action: 'edit' }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
<% if options.parent_model.present? -%>
    @parent_item = @item.<%= options.parent_model.underscore %>
<% else -%>
    # 'belongs_to_association' should be replaced with the actual association name
    # @parent_item = @item.belongs_to_association
<% end -%>
    @item.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = "Item successfully removed."
        render template: '<%= options.namespace %>/<%= plural_file_name %>s/table'
      }
      format.json { head :no_content }
    end
  end

private

  def set_item
    @item = <%= class_name %>.find(params[:id])
  end

  def permitted_params
    params.require(:<%= singular_table_name %>).permit!
  end

end