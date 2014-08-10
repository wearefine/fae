module Fae
  class UsersController < ApplicationController
    before_filter :super_admin_only, except: [:settings, :update]
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @users = User.all
      @page_title << " | Users"
    end

    def show
    end

    def new
      @user = User.new
      @page_title << " | New User"
    end

    def edit
      @page_title << " | Edit User"
    end

    def settings
      @user = current_user
      @page_title << " | Your Settings"
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to users_path, notice: 'User was successfully created.'
      else
        render action: 'new'
      end
    end

    def update
      params[:user].delete(:password) if params[:user][:password].blank?
      params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?

      if @user.update(user_params)
        if current_user.super_admin?
          redirect_to users_path, notice: 'User was successfully updated.'
        else
          redirect_to root_path, notice: 'User was successfully updated.'
        end
      else
        render action: 'edit'
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

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        if current_user.super_admin?
          params.require(:user).permit!
        elsif @user === current_user
          params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
        end
      end
  end
end
