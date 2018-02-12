module Api
  module V2
    class UserColumnsController < V2::BaseController
      include Api::Version2
      before_action :find_resource, :only => [:destroy, :update, :show]

      api :GET, "/user_columns", N_("List of user columns for a user")
      def index
        @user_columns = User.current.user_columns
      end

      api :GET, "/user_columns/:name", N_("List of user columns for a resource")
      param :name, String, :required => true
      def show
        if @user_column.blank?
          @user_column = UserColumn.new(:user => User.current, :name => params[:name])
        end
      end

      def_param_group :user_column do
        param :user_columns, Hash, :required => true do
          param :name, String, :required => true, :desc => N_("name of the resource")
          param :columns, Array, :desc => N_("List of user selected columns")
        end
      end

      api :POST, "/user_columns/", N_("Creates a user column for a given resource")
      param_group :user_column
      def create
        @user_column = User.current.user_columns.build(:name => params[:name], :columns => params[:columns])
        process_response @user_column.save
      end

      api :PUT, "/user_columns/:name", N_("Updates a user column for a given resource")
      param_group :user_column
      def update
        process_response @user_column.update_attributes(:columns => params[:columns])
      end

      api :DELETE, "/user_columns/:name/", N_("Delete columns for a resource")
      param :name, String, :required => true, :desc => N_("name of the resource")
      def destroy
        process_response @user_column.destroy
      end

      private

      def resource_class
        UserColumn
      end
    end
  end
end
