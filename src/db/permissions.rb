require 'singleton'

module DB
  class Permissions
    include Singleton

    @@table = []

    REQUIRED_FIELDS = [:role, :org_id, :user_id]

    def add(permission)
      @@table << permission if addable?(permission)
    end

    def addable?(permission)
      valid?(permission) && not_duplicate(permission)
    end

    def valid?(permission)
      REQUIRED_FIELDS.reduce(true){ |agg, f| agg && permission.key?(f) }
    end

    def find(criteria)
      @@table.find{ |p| match?(p, criteria) }
    end

    def search(options)
      @@table.find_all{ |permission| match?(permission, options) }
    end

    def destroy_all
      @@table = []
    end

    private

    def not_duplicate(permission)
      !find(permission)
    end

    def match?(permission, options)
      criteria = []
      criteria << (permission[:role] == options[:role]) if options.key?(:role)
      criteria << (permission[:org_id] == options[:org_id]) if options.key?(:org_id)
      criteria << (permission[:user_id] == options[:user_id]) if options.key?(:user_id)

      criteria.all?
    end

  end
end
