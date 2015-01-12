module DB
  class Organizations

    @@list = []

    REQUIRED_FIELDS = [:id, :parent_id]

    def self.add(org)
      if valid?(org)
        @@list << org
        true
      else
        false
      end
    end

    def self.valid?(org)
      has_fields?(org) && !duplicate_id?(org) && can_add_to_tree?(org)
    end

    def self.has_fields?(org)
      REQUIRED_FIELDS.reduce(true){ |agg, f| agg && org.key?(f) }
    end

    def self.duplicate_id?(org)
      @@list.reduce(false){ |agg, o| agg || o[:id] == org[:id] }
    end

    def self.is_child_org(org)
      lineage = parent_ids_of(org[:id])
      lineage.length > 1
    end

    def self.can_add_to_tree?(org)
      valid_parent?(org) || can_be_root?(org)
    end

    def self.valid_parent?(org)
      parent = self.find(org[:parent_id])
      !parent.nil?
    end

    def self.can_be_root?(org)
      !has_root && org[:id] == :root
    end

    def self.has_root
      @@list.reduce(false){ |agg, org| agg || org[:parent_id] == :root }
    end

    def self.find(id)
      @@list.find{ |org| org[:id] == id }
    end

    def self.parent_of(id)
      child = find(id)
      if child
        find(child[:parent_id])
      else
        nil
      end
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
