require 'singleton'

module DB
  class Organizations
    include Singleton

    @@table = []

    MAX_LEVEL = 3
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

    def remove(org)
      @@table.delete(org)
      update_parent_ids(org[:id], org[:parent_id])
    end

    def table
      @@table
    end

    def destroy_all
      @@table = []
    end

    def lineage_for(org)
      return [] if !has_fields?(org)
      lineage = [org[:id]]

      found = parent_of(org)
      while !found.nil?
        lineage << found[:id]
        found = parent_of(found)
      end

      lineage
    end

    def parent_of(org)
      child = find(org)
      child ? find_by_id(child[:parent_id]) : nil
    end

    private

    def update_parent_ids(old_id, new_id)
      @@table.each{ |o| o[:parent_id] = new_id if o[:parent_id] == old_id }
    end

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
      lineage_for(org).length >= MAX_LEVEL
    end

    def can_be_root?(org)
      !has_root && org[:id] == :root
    end

    def has_root
      @@table.reduce(false){ |agg, org| agg || org[:parent_id] == :root }
    end

  end
end
