module Api
  module V2
    class UserColumnsController < V2::BaseController
      include Api::Version2
      before_action :find_user_column, :only => [:columns, :reset]

      api :GET, "/user_columns/", N_("List of user columns for a user")
      def index
        @user_columns = User.current.user_columns
      end

      api :GET, "/user_columns/:resource", N_("List of user columns for a resource")
      param :resource, String, :required => true
      def columns
        columns = @user_column.map { |uc| uc.columns }
        render :json =>  { root_node_name => columns.flatten }
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
        @user_column = UserColumn.where(:user => User.current.id, :resource => params[:resource]).first_or_create
        @user_column.columns = params[:columns]
        process_response @user_column.save
      end

      api :DELETE, "/user_columns", N_("Delete columns for a resource")
      param :resource, String, :required => true, :desc => N_("name of the resource")
      def reset
        process_response @user_column.destroy_all
      end

      api :DELETE, "/user_columns", N_("Delete all columns for the user")
      def destroy_all
        @user_column = User.current.user_columns
        process_response @user_column.destroy_all
      end

      private

      def find_user_column
        @user_column = User.current.user_columns.where(:resource => params[:resource])
      end

      def resource_class
        UserColumn
      end
    end
  end
end
