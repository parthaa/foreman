class UserColumn < ApplicationRecord
  include Exportable
  belongs_to :user
  validates :user_id, :resource, :presence => true
  serialize :columns
  attr_exportable :resource, :columns
end
