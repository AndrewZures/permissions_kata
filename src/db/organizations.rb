module DB
  class Organizations

    @@table = []

    REQUIRED_FIELDS = [:id, :parent_id]

    def self.find_by_id(id)
      @@table.find{ |org| org[:id] == id }
    end

    def self.find(org)
      has_fields?(org) ? find_by_id(org[:id]) : nil
    end

    def self.add(org)
      if addable?(org)
        @@table << org
        true
      else
        false
      end
    end

    def self.destroy_all
      @@table = []
    end

    def self.parent_ids_of(org)
      parent_ids = []

      found = parent_of(org)
      while !found.nil?
        parent_ids << found[:id]
        found = parent_of(found)
      end

      parent_ids
    end

    def self.parent_of(org)
      child = find(org)
      child ? find_by_id(child[:parent_id]) : nil
    end

    private

    def self.addable?(org)
      has_fields?(org) && can_add_to_tree?(org)
    end

    def self.has_fields?(org)
      return if !org.is_a?(Hash)

      REQUIRED_FIELDS.reduce(true){ |agg, f| agg && org.key?(f) }
    end

    def self.duplicate?(org)
      @@table.reduce(false){ |agg, o| agg || o[:id] == org[:id] }
    end

    def self.can_add_to_tree?(org)
      !duplicate?(org) && (valid_parent?(org) || can_be_root?(org))
    end

    def self.valid_parent?(org)
      parent = self.find_by_id(org[:parent_id])
      !parent.nil? && !child_org?(parent)
    end

    def self.child_org?(org)
      lineage = parent_ids_of(org)
      lineage.length > 1
    end

    def self.can_be_root?(org)
      !has_root && org[:id] == :root
    end

    def self.has_root
      @@table.reduce(false){ |agg, org| agg || org[:parent_id] == :root }
    end

  end
end