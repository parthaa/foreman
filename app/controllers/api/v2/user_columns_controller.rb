module Api
  module V2
    class UserColumnsController < V2::BaseController
      include Api::Version2

      api :GET, "/user_columns/", N_("List of user columns for a user")
      def index
        render :json =>  { root_node_name => User.current.user_columns }
      end

      api :GET, "/user_columns/:resource", N_("List of user columns for a resource")
      param :resource, String, :required => true
      def columns
        render :json =>  { root_node_name => User.current.user_columns.where(:resource => params[:resource]).pluck(:columns).flatten}
      end

      api :POST, "/user_columns/", N_("Creates a user column for a given resource")
      param :resource, String, :required => true
      param :columns, Array, :desc => N_("List of user selected columns")
      def create
        column = UserColumn.where(:user => User.current.id, :resource => params[:resource]).first_or_create
        process_response column.update_attributes(:columns => params[:columns])
      end
    end
  end
end
