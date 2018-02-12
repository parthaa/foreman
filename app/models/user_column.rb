class UserColumn < ApplicationRecord
  include Exportable
  belongs_to :user
  validates :user_id, :resource, :presence => true
  serialize :columns
  attr_exportable :resource, :columns
  scope :resource, ->(name) { where(:resource => name)}

  def collated
    self.class.collate(resource, columns)
  end

  def self.collate(resource, current_user_columns = nil)
    registry_columns = ColumnRegistry::Manager.columns(resource)
    return [] if registry_columns.blank?

    registry_columns.map do |column|
      formatted_column = column.to_hash
      formatted_column[:enabled] = if current_user_columns.nil?
                                     column.default_enabled
                                   else
                                     current_user_columns.include? column.name
                                   end
      formatted_column
    end
  end
end
