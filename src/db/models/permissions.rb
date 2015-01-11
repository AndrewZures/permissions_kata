module DB
  class Permissions

    @@list = []

    REQUIRED_FIELDS = [:type, :org_id, :user_id]

    def self.add(permission)
      @@list << permission if valid_permission?(permission)
    end

    def self.valid_permission?(permission)
      REQUIRED_FIELDS.reduce(true){ |agg, f| agg && permission.key?(f) }
    end

    def self.search(options)
      return @@list.keep_if{ |permission| filter(permission, options) }
    end


    def self.filter(permission, options)
      criteria = []
      criteria << (permission[:type] == options[:type]) if options.key?(:type)
      criteria << (permission[:org_id] == options[:org_id]) if options.key?(:org_id)
      criteria << (permission[:user_id] == options[:user_id]) if options.key?(:user_id)

      return criteria.all?
    end

    def self.reset
      @@list = []
    end

  end
end