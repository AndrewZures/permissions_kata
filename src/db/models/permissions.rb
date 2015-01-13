module DB
  class Permissions

    @@table = []

    REQUIRED_FIELDS = [:role, :org_id, :user_id]

    def self.add(permission)
      @@table << permission if addable?(permission)
    end

    def self.addable?(permission)
      valid?(permission) && not_duplicate(permission)
    end

    def self.valid?(permission)
      REQUIRED_FIELDS.reduce(true){ |agg, f| agg && permission.key?(f) }
    end

    def self.find(criteria)
      @@table.find{ |p| match?(p, criteria) }
    end

    def self.search(options)
      @@table.find_all{ |permission| match?(permission, options) }
    end

    def self.destroy_all
      @@table = []
    end

    private

    def self.not_duplicate(permission)
      !find(permission)
    end

    def self.match?(permission, options)
      criteria = []
      criteria << (permission[:role] == options[:role]) if options.key?(:role)
      criteria << (permission[:org_id] == options[:org_id]) if options.key?(:org_id)
      criteria << (permission[:user_id] == options[:user_id]) if options.key?(:user_id)

      criteria.all?
    end

  end
end
