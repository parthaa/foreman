module ColumnRegistry
  module Manager
    class << self
      def resources
        resource_objects.keys
      end

      def default_column_resources
        {}
      end

      def resource_objects
        column_resources = default_column_resources
        Foreman::Plugin.all.each do |plugin|
          column_resources.merge!(plugin.column_resources)
        end
        column_resources
      end

      def columns(resource)
        resource_objects[resource]
      end

      def generate_columns(&block)
        cc = ColumnGenerator.new
        if block_given?
          yield cc
        end
        cc.columns
      end

      def add_column_to_user(user, resource, param_columns)
        ensure_valid_resource_columns(resource, param_columns)
        user.user_columns.where(:resource => resource, :columns => param_columns).first_or_create!
      end

      def update_user_column(user_column, param_columns)
        ensure_valid_resource_columns(user_column.resource, param_columns)
        user_column.update_attributes!(:columns => param_columns)
      end

      private

      def ensure_valid_resource_columns(param_resource, param_columns)
        columns_from_registry = columns(param_resource)
        if columns_from_registry.blank?
          raise N_("Unable to find resource %s in the registry") % param_resource
        end

        column_names = columns_from_registry.map(&:name)

        invalid_names = param_columns - column_names
        unless invalid_names.blank?
          invalid_attrs = {
            :resource => param_resource,
            :columns => invalid_names
          }
          raise N_("Invalid column names provided %{columns} for resource  %{resource} in the registry") % invalid_attrs
        end
      end
    end

    class ColumnGenerator
      attr_accessor :columns
      def initialize
        self.columns = []
      end

      def column(name, options = {})
        self.columns << Column.new(name, options)
      end
    end

    class Column
      attr_reader :name, :path, :description, :default_enabled

      def initialize(name, options)
        invalid_args = options.keys - [:description, :path, :default_enabled]
        raise ArgumentError, "Invalid options '#{invalid_args.inspect}'' provided for column '#{name}'" unless invalid_args.blank?

        @name = name
        @path = options[:path]
        @description = options[:description] || name.to_s
        @default_enabled = ::Foreman::Cast.to_bool(options[:default_enabled]) || false
      end

      def to_hash
        { :name => name,
          :description => description,
          :path => path,
          :default_enabled => default_enabled
        }
      end
    end
  end
end
