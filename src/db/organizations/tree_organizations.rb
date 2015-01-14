require 'singleton'

module DB
  class TreeOrganizations
    include Singleton

    FIRST_LEVEL = 1
    MAX_LEVEL   = 3

    @@tree = {}
    @@table = []

    def add(org)
      if can_be_root?(org)
        add_root(org)
      else
        insert_into_tree(@@tree, org, FIRST_LEVEL)
      end
    end

    def find(org)
      found_id = find_id(@@tree, org)
      find_by_id(found_id)
    end

    def find_by_id(id)
      @@table.find{ |o| o[:id] == id }
    end

    def remove(org)
      remove_from_tree(@@tree, org)
    end

    def destroy_all
      @@tree = {}
      @@table = []
    end

    def lineage_for(org)
      lineage_ids_tree(@@tree, org)
    end

    def build_tree(table)
      loop do
        initial = table.dup
        table.delete_if { |o| add(o) }
        break if initial == table
      end
    end

    def table
      @@table
    end

    def tree
      @@tree
    end

    private

    def find_id(node, org)
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

    def lineage_ids_tree(node, org)
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

    def insert_into_tree(node, org, lvl)
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

    def remove_from_tree(node, org, parent_id=nil)
      to_remove = nil

      node.each do |id, children|
        if id == org[:id]
          to_remove = { id: id, children: children}
          break;
        else
          remove_from_tree(children, org, id)
        end
      end

      !to_remove.nil? ? remove_node(to_remove, node, org, parent_id) : false
    end

    def remove_node(found, node, org, parent_id)
      return false if found[:id] == :root

      delete_from_tree(node, found)
      delete_from_table(org, found, parent_id)
    end

    def delete_from_tree(node, found)
      node.delete(found[:id])
      node.merge!(found[:children])
    end

    def delete_from_table(org, found, parent_id)
      @@table.delete(org)
      update_parent_ids(found[:id], parent_id)
      true
    end

    def update_parent_ids(old_id, new_id)
      @@table.each { |o| o[:parent_id] = new_id if o[:parent_id] == old_id }
    end

    def can_add_as_child?(org, node_id, node_children)
      node_id == org[:parent_id] && !node_children.key?(org[:id])
    end

    def add_to_children(org, children)
      children[org[:id]] = {}
      @@table << org
      return true
    end

    def add_root(org)
      add_to_children(org, @@tree)
    end

    def can_be_root?(org)
      !has_root? && org[:id] == :root
    end

    def has_root?
      @@tree.key?(:root)
    end

  end
end
