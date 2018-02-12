require 'test_helper'

class Api::V2::UserColumnsControllerTest < ActionController::TestCase
  def resources
    ["test_subscriptions_resource", "test_organizations_resource"]
  end

  def enabled_columns
    ["1", "2", "3"]
  end

  def non_enabled_columns
    ["non1", "non2", "non3"]
  end

  def setup_user_columns
    unless (resources - ::ColumnRegistry::Manager.resources).blank?
      resource_map = {}
      resources.each do |resource|
        resource_map[resource] = ::ColumnRegistry::Manager.generate_columns do |res|
          enabled_columns.each do |column|
            res.column column, :description => "#{column} description",
                               :path => "#{column}_path",
                               :default_enabled => true
          end
          non_enabled_columns.each do |column|
            res.column column, :description => "#{column} description",
                               :path => "#{column}_path",
                               :default_enabled => false
          end
        end
      end
      ColumnRegistry::Manager.stubs(:default_column_resources).returns(resource_map)
    end
  end

  def setup
    setup_users
    setup_user_columns
  end

  def test_should_get_index_with_json_result
    get :index
    assert_response :success
    columns = ActiveSupport::JSON.decode(@response.body)["results"]
    assert_equal(columns.length, 0)
  end

  def test_should_show_columns_correctly
    expected_columns =  enabled_columns
    resource = resources.first
    UserColumn.create!(user: User.current,
                       resource: resource, columns: expected_columns)
    get :show, params: { resource: resource}
    assert_response :success
    actual_columns = ActiveSupport::JSON.decode(@response.body)["collated"]
    assert_equal(expected_columns.size + non_enabled_columns.size, actual_columns.size)

    expected_columns.each do |col|
      val = actual_columns.find {|ac| ac["name"] == col}
      assert val["enabled"]
    end

    non_enabled_columns.each do |col|
      val = actual_columns.find {|ac| ac["name"] == col}
      refute val["enabled"]
    end
  end

  def test_should_create_correctly
    expected_columns =  enabled_columns
    resource = resources.first
    current_user = User.current
    post :create, params: {resource: resource, columns: expected_columns}
    assert_response :success
    columns = current_user.reload.user_columns.first
    assert_equal(expected_columns, columns.columns)
  end

  def test_should_update_correctly
    expected_columns =  enabled_columns
    resource = resources.first
    current_user = User.current
    UserColumn.create!(user: User.current,
                       resource: resource, columns: expected_columns)

    put :update, params: {resource: resource, columns: expected_columns}
    assert_response :success
    columns = current_user.reload.user_columns.first
    assert_equal(expected_columns, columns.columns)
  end

  def test_should_destroy_correctly
    expected_columns =  enabled_columns
    resource1 = resources[0]
    resource2 = resources[1]
    current_user = User.current
    UserColumn.create!(user: User.current,
                       resource: resource1, columns: expected_columns)
    UserColumn.create!(user: User.current,
                       resource: resource2, columns: expected_columns)

    delete :destroy, params: { resource: resource1}
    assert_response :success

    columns = current_user.reload.user_columns
    assert_equal(1, columns.size)
    assert_equal(resource2, columns.first.resource)
  end
end
