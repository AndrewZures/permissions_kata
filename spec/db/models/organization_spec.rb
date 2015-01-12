require_relative '../../../src/db/models/organizations'

describe DB::Organizations do
  let(:organizations){ described_class }

  let(:root_org){   {id: :root,  parent_id: nil } }
  let(:org){        {id: :_org,  parent_id: :root } }
  let(:child_org){  {id: :child, parent_id: :_org } }

  before(:each) do
    organizations.add(root_org)
    organizations.add(org)
    organizations.add(child_org)
  end

  after(:each) do
    organizations.destroy_all
  end

  it "adds an organization" do
    expect(organizations.find(org[:id])).to eq(org)
  end

  it "does not add root org if root org already exists" do
    second_root_org = {id: :root, parent_id: -1}
    second_root = organizations.add(second_root_org)
    expect(second_root).to eq(false)
  end

  it "does not add a duplicate organization" do
    duplicated = organizations.add(org)
    expect(duplicated).to eq(false)
  end

  it "does not add a child to existing child node (limit tree to 3 levels)" do
    great_grandchild_org = { id: 8, parent_id: child_org[:id] }
    added = organizations.add(great_grandchild_org)
    expect(added).to eq(false)
  end

  it "does not add org if cannot be connected to existing org tree structured" do
    child_org = { id: 8, parent_id: :not_connected_to_tree }
    added = organizations.add(child_org)
    expect(added).to eq(false)
  end

  it "finds a parent organization" do
    expect(organizations.parent_of(org[:id])).to eq(root_org)
    expect(organizations.parent_of(child_org[:id])).to eq(org)
  end

  it "returns nil if parent cannot be found" do
    expect(organizations.find(-100)).to be_nil
  end

  it "returns an list of parent org ids" do
    lineage = organizations.parent_ids_of(child_org[:id])
    expect(lineage).to eq([org[:id], root_org[:id]])
  end

end
