require_relative '../../src/db/tree_organizations'

describe DB::TreeOrganizations do
  let(:organizations){ described_class }

  let(:root_org){   {id: :root,  parent_id: nil } }
  let(:org){        {id: :_org,  parent_id: :root } }
  let(:child_org){  {id: :child, parent_id: :_org } }

  before(:each) do
    # organizations.add(root_org)
    # organizations.add(org)
    # organizations.add(child_org)
  end

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
      expect(organizations.org_tree).to eq({ root: { _org: {} } })
    end

    it "adds org to tree" do
      organizations.add(root_org)
      organizations.add(org)
      expect(organizations.org_tree).to eq({ root: { _org: {} } })
    end

    it "adds child org to tree" do
      organizations.add(root_org)
      organizations.add(org)
      organizations.add(child_org)

      expect(organizations.org_tree).to eq({ root: { _org: { child: {} } } })
    end

    it "removes an org from the tree" do
      organizations.add(root_org)
      organizations.add(org)
      organizations.add(child_org)

      organizations.remove(org)
      expect(organizations.org_tree).to eq({ root: { child: {} } })
    end

  end

  # it "does not add root org if root org already exists" do
  #   second_root_org = {id: :root, parent_id: -1}
  #   second_root = organizations.add(second_root_org)
  #   expect(second_root).to eq(false)
  # end
  #
  # it "does not add a duplicate organization" do
  #   duplicated = organizations.add(org)
  #   expect(duplicated).to eq(false)
  # end
  #
  # it "does not add a child to existing child node (limit tree to 3 levels)" do
  #   great_grandchild_org = { id: 8, parent_id: child_org[:id] }
  #   added = organizations.add(great_grandchild_org)
  #   expect(added).to eq(false)
  # end
  #
  # it "does not add org if cannot be connected to existing org tree structured" do
  #   child_org = { id: 8, parent_id: :not_connected_to_tree }
  #   added = organizations.add(child_org)
  #   expect(added).to eq(false)
  # end
  #
  # it "finds a parent organization" do
  #   expect(organizations.parent_of(root_org)).to eq(nil)
  #   expect(organizations.parent_of(org)).to eq(root_org)
  #   expect(organizations.parent_of(child_org)).to eq(org)
  # end
  #
  # it "returns an list of parent org ids" do
  #   lineage = organizations.parent_ids_of(child_org)
  #   expect(lineage).to eq([org[:id], root_org[:id]])
  # end

end

