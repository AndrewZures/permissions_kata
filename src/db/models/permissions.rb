module DB
  class Permissions

    @@table = []

    REQUIRED_FIELDS = [:role, :org_id, :user_id]

    def self.add(permission)
      @@table << permission if valid_permission?(permission)
    end

    def self.valid_permission?(permission)
      REQUIRED_FIELDS.reduce(true){ |agg, f| agg && permission.key?(f) }
    end

    def self.find(org_id, user_id)
      options = { org_id: org_id, user_id: user_id }
      @@table.find{ |p| filter(p, options) }
    end

    def self.search(options)
      @@table.find_all{ |permission| filter(permission, options) }
    end


    def self.filter(permission, options)
      criteria = []
      criteria << (permission[:role] == options[:role]) if options.key?(:role)
      criteria << (permission[:org_id] == options[:org_id]) if options.key?(:org_id)
      criteria << (permission[:user_id] == options[:user_id]) if options.key?(:user_id)

      criteria.all?
    end

    def self.destroy_all
      @@table = []
    end

  end
end
