require_relative '../../src/db/tree_organizations'

describe DB::TreeOrganizations do
  let(:organizations){ described_class }

  let(:root_org){   {id: :root,  parent_id: nil } }
  let(:org){        {id: :org,  parent_id: :root } }
  let(:child_org){  {id: :child, parent_id: :org } }

  after(:each) do
    organizations.destroy_all
  end

  context "when building in-memory tree" do

    it "adds root org to tree" do
      organizations.add(root_org)
      expect(organizations.org_tree).to eq({ root: {} })
    end

    it "does not add more than one root" do
      added1 = organizations.add(root_org)
      added2 = organizations.add(root_org)

      expect(added1).to eq(true)
      expect(added2).to eq(false)
      expect(organizations.org_tree).to eq({ root: {} })
    end

    it "does not add duplicate org" do
      organizations.add(root_org)
      added1 = organizations.add(org)
      added2 = organizations.add(org)

      expect(added1).to eq(true)
      expect(added2).to eq(false)
      expect(organizations.org_tree).to eq({ root: { org: {} } })
    end

    it "adds org to tree" do
      organizations.add(root_org)
      organizations.add(org)
      expect(organizations.org_tree).to eq({ root: { org: {} } })
    end

    it "adds child org to tree" do
      organizations.add(root_org)
      organizations.add(org)
      organizations.add(child_org)

      expect(organizations.org_tree).to eq({ root: { org: { child: {} } } })
    end

    it "does not add an org that cannot be connected to tree" do
      organizations.add(root_org)
      organizations.add(org)

      child_org[:parent_id] = :bad_parent
      organizations.add(child_org)

      expect(organizations.org_tree).to eq({ root: { org: {} } })
    end

    it "removes an org from the tree" do
      organizations.add(root_org)
      organizations.add(org)
      organizations.add(child_org)

      organizations.remove(org)
      expect(organizations.org_tree).to eq({ root: { child: {} } })
    end

    it "returns a list of parent org ids" do
      organizations.add(root_org)
      organizations.add(org)
      organizations.add(child_org)

      lineage = organizations.parent_ids_of(child_org)
      expect(lineage).to eq([:child, :org, :root])
    end

    context "when assuring in-memory tree reflects db data" do

     it "inserts into table when inserting into tree" do
        organizations.add(root_org)
        organizations.add(org)

        table = organizations.org_table()
        expect(table).to include(root_org)
        expect(table).to include(org)
      end

      it "deletes from table when deleting from tree" do
        organizations.add(root_org)
        organizations.add(org)

        table = organizations.org_table()
        expect(table).to include(root_org)
        expect(table).to include(org)

        organizations.remove(org)

        updated_table = organizations.org_table()
        expect(updated_table).to include(root_org)
        expect(updated_table).to_not include(org)
      end

      it "builds a tree from a table" do
        table = [org, root_org, child_org]
        organizations.build_table(table)

        expect(organizations.org_tree()).to eq({ root: { org: { child: {} }}})
      end

      it "does not add unconnected orgs when building tree" do
        table = [org, root_org, child_org, {id: 134, parent_id: :unconnected } ]
        organizations.build_table(table)

        expect(organizations.org_tree()).to eq({ root: { org: { child: {} }}})
      end

    end

  end


end

