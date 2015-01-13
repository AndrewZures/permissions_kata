require_relative '../../src/db/organizations'

describe DB::Organizations do
  let(:organizations){ DB::Organizations.instance() }

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
    expect(organizations.find(org)).to eq(org)
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
    expect(organizations.parent_of(root_org)).to eq(nil)
    expect(organizations.parent_of(org)).to eq(root_org)
    expect(organizations.parent_of(child_org)).to eq(org)
  end

  it "returns an org lineage" do
    lineage = organizations.lineage_for(child_org)
    expect(lineage).to eq([child_org[:id], org[:id], root_org[:id]])
  end

end
