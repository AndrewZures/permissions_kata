module DB
  class TreeOrganizations

    MAX_LEVEL = 3

    @@tree = {}
    @@table = []

    def self.add(org)
      if can_be_root?(org)
        add_root(org)
      else
        insert_into_tree(@@tree, org, 1)
      end
    end

    def self.find(org)
      found_id = find_id(@@tree, org)
      find_org_in_table(found_id)
    end

    def self.org_table
      @@table
    end

    def self.org_tree
      @@tree
    end

    def self.remove(org)
      remove_from_tree(@@tree, org)
    end

    def self.destroy_all
      @@tree = {}
      @@table = []
    end

    def self.parent_ids_of(org)
      lineage_ids_tree(@@tree, org)
    end

    def self.build_tree(table)
      loop do
        initial = table.dup
        table.delete_if { |o| add(o) }
        break if initial == table
      end
    end

    private

    def self.find_org_in_table(id)
      @@table.find{ |o| o[:id] == id }
    end

    def self.find_id(node, org)
      return nil if node.empty?

      node.each do |id, children|
        if id == org[:id]
          return id
        else
          status = find_id(children, org)
          return status if !status.nil?
        end
      end

      return nil
    end

    def self.lineage_ids_tree(node, org)
      return [] if node.empty?

      node.each do |id, children|
        if org[:id] == id
          return [id]
        else
          children_status = lineage_ids_tree(children, org)
          return children_status << id if !children_status.empty?
        end
      end

      return []
    end

    def self.insert_into_tree(node, org, lvl)
      return false if node.empty? || lvl >= MAX_LEVEL

      node.each do |id, children|
        if can_add_as_child?(org, id, children)
          return add_to_children(org, children)
        else
          insert_into_tree(children, org, lvl += 1)
        end
      end

      return false
    end

    def self.remove_from_tree(node, org)
      to_remove = nil

      node.each do |id, children|
        if id == org[:id]
          to_remove = { id: id, children: children}
          break;
        else
          remove_from_tree(children, org)
        end
      end

      !to_remove.nil? ? remove_node(to_remove, node, org) : false
    end

    def self.remove_node(found, node, org)
      return false if found[:id] == :root

      node.delete(found[:id])
      node.merge!(found[:children])
      @@table.delete(org)
      true
    end

    def self.can_add_as_child?(org, node_id, node_children)
      node_id == org[:parent_id] && !node_children.key?(org[:id])
    end

    def self.add_to_children(org, children)
      children[org[:id]] = {}
      @@table << org
      return true
    end

    def self.add_root(org)
      add_to_children(org, @@tree)
    end

    def self.can_be_root?(org)
      !has_root? && org[:id] == :root
    end

    def self.has_root?
      @@tree.key?(:root)
    end

  end
end
