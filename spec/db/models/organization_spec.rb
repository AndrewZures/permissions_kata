require_relative '../../../src/db/models/organizations'

describe "organizations" do
  let(:root_org){   {id: :root,  parent_id: nil } }
  let(:org){        {id: :_org,  parent_id: :root } }
  let(:child_org){  {id: :child, parent_id: :_org } }

  before(:each) do
    DB::Organizations.add(root_org)
    DB::Organizations.add(org)
    DB::Organizations.add(child_org)
  end

  after(:each) do
    DB::Organizations.destroy_all
  end

  it "adds an organization" do
    expect(DB::Organizations.find(org[:id])).to eq(org)
  end

  it "does not add root org if root org already exists" do
    second_root_org = {id: :root, parent_id: -1}
    second_root = DB::Organizations.add(second_root_org)
    expect(second_root).to eq(false)
  end

  it "does not add a duplicate organization" do
    duplicated = DB::Organizations.add(org)
    expect(duplicated).to eq(false)
  end

  it "does not add a child to existing child node (limit tree to 3 levels)" do
    expect(DB::Organizations.is_child_org(org)).to eq(false)

    child_org = { id: 8, parent_id: org[:id] }
    DB::Organizations.add(child_org)

    expect(DB::Organizations.is_child_org(child_org)).to eq(true)
  end

  it "does not add org if cannot be connected to existing org tree structured" do
    child_org = { id: 8, parent_id: :not_connected_to_tree }
    added = DB::Organizations.add(child_org)
    expect(added).to eq(false)
  end

  it "finds a parent organization" do
    expect(DB::Organizations.parent_of(org[:id])).to eq(root_org)
    expect(DB::Organizations.parent_of(child_org[:id])).to eq(org)
  end

  it "returns nil if parent cannot be found" do
    expect(DB::Organizations.find(-100)).to be_nil
  end

  it "returns an list of parent org ids" do
    lineage = DB::Organizations.parent_ids_of(child_org[:id])
    expect(lineage).to eq([org[:id], root_org[:id]])
  end

end
