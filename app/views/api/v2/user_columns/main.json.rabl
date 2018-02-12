object @user_column
attributes :resource, :columns, :created_at, :updated_at, :collated
child :user do
  extends "api/v2/users/base"
end
