require 'test_helper'

class Api::V2::UserColumnsControllerTest < ActionController::TestCase
  def setup
    setup_users
  end

  test "should get index with json result" do
    get :index
    assert_response :success
    columns = ActiveSupport::JSON.decode(@response.body)["results"]
    assert_equal(columns.length, 0)
  end

  test "should have glossary" do
    expected_columns =  ["1","2", "3"]
    resource = "subscriptions"
    UserColumn.create!(user: User.current,
                       resource: resource, columns: expected_columns)
    get :columns, params: { resource: resource}
    assert_response :success
    columns = ActiveSupport::JSON.decode(@response.body)["results"]
    assert_equal(expected_columns, columns)
  end

  test "should create correctly" do
    expected_columns =  ["1","2", "32"]
    resource = "subscriptions"
    post :create, params: {resource: resource, columns: expected_columns}
    assert_response :success
    columns = User.current.user_columns.first
    assert_equal(expected_columns, columns.columns)
  end
end
