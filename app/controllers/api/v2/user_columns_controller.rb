module Api
  module V2
    class UserColumnsController < V2::BaseController
      include Api::Version2
      before_action :find_user_column, :only => [:destroy, :update, :show]

      api :GET, "/user_columns", N_("List of user columns for a user")
      def index
        @user_columns = User.current.user_columns
      end

      api :GET, "/user_columns/:resource", N_("List of user columns for a resource")
      param :resource, String, :required => true
      def show
        return not_found unless ::ColumnRegistry::Manager.resources.include?(params[:resource])
        if @user_column.blank?
          @user_column = UserColumn.new(:user => User.current, :resource => params[:resource])
        end
      end

      def_param_group :user_column do
        param :user_columns, Hash, :required => true do
          param :resource, String, :required => true, :desc => N_("name of the resource")
          param :columns, Array, :desc => N_("List of user selected columns")
        end
      end

      api :POST, "/user_columns/", N_("Creates a user column for a given resource")
      param_group :user_column
      def create
        @user_column = ::ColumnRegistry::Manager.add_column_to_user(User.current,
                                                                      params[:resource],
                                                                      params[:columns])
        process_response @user_column.save
      end

      api :PUT, "/user_columns/:resource", N_("Updates a user column for a given resource")
      param_group :user_column
      def update
        return not_found if @user_column.blank?
        process_response ::ColumnRegistry::Manager.update_user_column(@user_column, params[:columns])
      end

      api :DELETE, "/user_columns/:resource/", N_("Delete columns for a resource")
      param :resource, String, :required => true, :desc => N_("name of the resource")
      def destroy
        return not_found if @user_column.blank?
        process_response @user_column.destroy
      end

      private

      def find_user_column
        @user_column = User.current.user_columns.where(:resource => params[:resource]).first
      end

      def resource_class
        UserColumn
      end
    end
  end
end
