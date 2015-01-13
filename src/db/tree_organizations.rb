module DB
  class TreeOrganizations

    @@tree = {}
    @@table = []

    def self.add(org)
      if can_be_root?(org)
        add_root(org)
        true
      else
        _add(org)
      end
    end

    def self.add_root(org)
      @@tree[org[:id]] = {}
    end

    def self._add(org)
      insert(@@tree, org)
    end

    def self.destroy_all
      @@tree = {}
      @@table = []
    end

    def self.org_tree
      @@tree
    end

    def self.addable?(org)
      can_be_added?(org)
    end

    def self.can_be_added?(org)
      existing_org_ids.include?(org[:parent_id])
    end

    def self.existing_org_ids
      _existing_org_id(@@tree).flatten
    end

    def self.insert(node, org)
      node.each do |k, v|
        if k == org[:parent_id] && !v.key?(org[:id])
          v[org[:id]] = {}
          return true
        else
          insert(v, org)
        end
      end

      return false
    end

    def self.remove(org)
      _remove(@@tree, org)
    end


    def self._remove(node, org)
      found = nil

      node.each do |k, v|
        if k == org[:id]
          found = {key: k, values: v}
          break;
        else
          _remove(v, org)
        end
      end

      if !found.nil?
        node.delete(found[:key])
        node.merge!(found[:values])
        true
      else
        false
      end

    end

    def remove_node(parent, node)

    end

    private

    def self.can_be_root?(org)
      !has_root? && org[:id] == :root
    end

    def self.has_root?
      @@tree.key?(:root)
    end

  end
end
