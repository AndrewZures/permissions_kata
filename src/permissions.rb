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
      return @@list.keep_if{ |el| filter(el, options) }
    end


    def self.filter(record, options)
      criteria = []
      criteria << (record[:type] == options[:type]) if options.key?(:type)
      criteria << (record[:org_id] == options[:org_id]) if options.key?(:org_id)
      criteria << (record[:user_id] == options[:user_id]) if options.key?(:user_id)

      return criteria.all?
    end

    def self.reset
      @@list = []
    end

  end
end
