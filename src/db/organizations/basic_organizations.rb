require 'singleton'

module DB
  class Organizations
    include Singleton

    @@table = []

    REQUIRED_FIELDS = [:id, :parent_id]

    def find_by_id(id)
      @@table.find{ |org| org[:id] == id }
    end

    def find(org)
      has_fields?(org) ? find_by_id(org[:id]) : nil
    end

    def add(org)
      if addable?(org)
        @@table << org
        true
      else
        false
      end
    end

    def destroy_all
      @@table = []
    end

    def lineage_for(org)
      return [] if !has_fields?(org)
      parent_ids = [org[:id]]

      found = parent_of(org)
      while !found.nil?
        parent_ids << found[:id]
        found = parent_of(found)
      end

      parent_ids
    end

    def parent_of(org)
      child = find(org)
      child ? find_by_id(child[:parent_id]) : nil
    end

    private

    def addable?(org)
      has_fields?(org) && can_add_to_tree?(org)
    end

    def has_fields?(org)
      return if !org.is_a?(Hash)

      REQUIRED_FIELDS.reduce(true){ |agg, f| agg && org.key?(f) }
    end

    def duplicate?(org)
      @@table.reduce(false){ |agg, o| agg || o[:id] == org[:id] }
    end

    def can_add_to_tree?(org)
      !duplicate?(org) && (valid_parent?(org) || can_be_root?(org))
    end

    def valid_parent?(org)
      parent = find_by_id(org[:parent_id])
      !parent.nil? && !child_org?(parent)
    end

    def child_org?(org)
      lineage = lineage_for(org)
      lineage.length > 2
    end

    def can_be_root?(org)
      !has_root && org[:id] == :root
    end

    def has_root
      @@table.reduce(false){ |agg, org| agg || org[:parent_id] == :root }
    end

  end
end
