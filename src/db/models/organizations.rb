module DB
  class Organizations

    @@list = []
    @@tree = nil

    REQUIRED_FIELDS = [:org_id, :parent_id]

    def self.add(org)
      @@list << org
    end

    def self.insert(org)
    end

    def self.find_parents_of(org)
      parents = []
      while parent[:parent_id] != :root
        parent = self.find_parent(org)
        parents << parent
        org = parent
      end

      parents
    end

    def find(options)
      @@list.each{ |el| return el if el[:org_id] == options[:org_id] }
      nil
    end

  end
end
