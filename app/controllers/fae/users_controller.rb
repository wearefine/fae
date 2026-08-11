module Fae
  class UsersController < ApplicationController
    include Fae::InertiaRenderable

    before_action :admin_only, except: [:settings, :update]
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :set_role_collection, except: [:index, :destroy]
    before_action :set_index_path, only: [:settings, :new, :edit]

    def index
      @users = current_user.super_admin? ? Fae::User.all : Fae::User.public_users
      render inertia: 'Fae/Index', props: {
        title: t('fae.navbar.users'),
        # intro: t('fae.user.index_intro'),
        columns: [
          { key: 'name', label: t('fae.common.name') },
          { key: 'email', label: t('fae.user.email') },
          { key: 'role', label: t('fae.user.role') },
          { key: 'lastSignIn', label: t('fae.user.last_login') }
        ],
        rows: @users.map do |user|
          {
            id: user.id,
            label: user.fae_display_field.to_s,
            editPath: edit_user_path(user),
            deletePath: user_path(user),
            cells: {
              name: user.fae_display_field.to_s,
              email: user.email,
              role: user.role.name.to_s.titleize,
              lastSignIn: (user.last_sign_in_at.present? ? helpers.fae_date_format(user.last_sign_in_at) : '-')
            }
          }
        end,
        newPath: new_user_path,
        newButtonText: t('fae.user.add_user')
      }
    end

    def new
      @user = Fae::User.new
    end

    def edit
    end

    def settings
      @user = current_user
      # set index path to dashboard
      @index_path = root_path

      render inertia: 'Fae/Form', props: {
        title: t('fae.navbar.your_settings'),
        indexPath: @index_path,
        submitPath: user_path(@user),
        submitMethod: 'patch',
        paramKey: 'user',
        blocks: fae_user_settings_fields.map { |field| { kind: 'field', field: field } },
        draft: false,
        deletePath: nil
      }
    end

    def create
      authorize_role

      @user = Fae::User.new(user_params)
      @user.user_mfa_enabled = @option.site_mfa_enabled

      if @user.save
        redirect_to users_path, notice: t('fae.save_notice')
      else
        render action: 'new', error: t('fae.save_error')
      end
    end

    def update
      authorize_role

      if params[:user][:password].blank? || params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      if @user == current_user
        if @user.update(user_params)
          redirect_to fae.settings_path, notice: t('fae.save_notice')
        else
          redirect_to fae.settings_path,
                      inertia: { errors: fae_inertia_errors(@user) },
                      flash: { alert: t('fae.save_error') }
        end
        return
      end

      if @user.update(user_params)
        path = current_user.super_admin_or_admin? ? users_path : fae.root_path
        redirect_to path, notice: t('fae.save_notice')
      else
        render action: 'edit', error: t('fae.save_error')
      end
    end

    def destroy
      @user.destroy
      respond_to do |format|
        format.html { redirect_to users_url }
        format.json { head :no_content }
      end
    end

    private

      def fae_user_settings_fields
        fields = [
          { name: :first_name, type: :text },
          { name: :last_name, type: :text },
          { name: :email, type: :text },
          {
            name: :theme,
            type: :select,
            collection: Fae::User.theme_collection
          },
          {
            name: :password,
            type: :password,
            helper_text: t('fae.user.password_hint')
          },
          { name: :password_confirmation, type: :password }
        ]

        if current_user.admin? || current_user.super_admin?
          fields << {
            name: :role_id,
            type: :select,
            label: Fae::User.human_attribute_name(:role),
            collection: @role_collection.map { |role| [role.name.to_s.titleize, role.id] }
          }
        end

        fields.map { |field| fae_inertia_form_field(@user, field) }
      end

      def set_role_collection
        @role_collection = Role.all if current_user.super_admin?
        @role_collection = Role.public_roles if current_user.admin?
      end

      def set_user
        @user = Fae::User.find(params[:id])
      end

      def user_params
        if current_user.super_admin_or_admin?
          params.require(:user).permit!
        elsif @user === current_user
          params.require(:user).permit(:email, :first_name, :last_name, :theme, :password, :password_confirmation)
        end
      end

      def set_index_path
        # @index_path determines form's cancel btn path
        @index_path = users_path
      end

      def authorize_role
        return if params[:user][:role_id].blank?
        return if @role_collection.map(&:id).include?(params[:user][:role_id].to_i)
        params[:user].delete(:role_id)
      end
  end
end
