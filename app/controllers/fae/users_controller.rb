module Fae
  class UsersController < ApplicationController
    before_action :admin_only, except: [:settings, :update]
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :set_role_collection, except: [:index, :destroy]
    before_action :set_index_path, only: [:settings, :new, :edit]

    def index
      @users = current_user.super_admin? ? Fae::User.all : Fae::User.public_users
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

      params[:user].delete(:password) if params[:user][:password].blank?
      params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?

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
        format.html { redirect_to users_path_url }
        format.json { head :no_content }
      end
    end

    private

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
          params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
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
