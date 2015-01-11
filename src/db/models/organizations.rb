module DB
  class Organizations

    @@list = []

    REQUIRED_FIELDS = [:id, :parent_id]

    def self.add(org)
      @@list << org if valid?(org)
    end

    def self.valid?(org)
      REQUIRED_FIELDS.reduce(true){ |agg, f| agg && org.key?(f) }
    end

    def self.find(id)
      @@list.find{ |org| org[:id] == id }
    end

    def self.parent_of(id)
      child = find(id)
      find(child[:parent_id])
    end

    def self.parent_ids_of(id)
      parent_ids = []

      found = parent_of(id)
      while !found.nil?
        parent_ids << found[:id]
        found = parent_of(found[:id])
      end

      parent_ids
    end

    def self.destroy_all
      @@list = []
    end

  end
end
