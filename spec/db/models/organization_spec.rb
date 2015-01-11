require_relative '../../../src/db/models/organizations'

describe "organizations" do
  let(:parent_org){ {id: 2, parent_id: 1} }
  let(:org){ {id: 3, parent_id: 2} }

  before(:each) do
    DB::Organizations.add(org)
    DB::Organizations.add(parent_org)
  end

  after(:each) do
    DB::Organizations.destroy_all
  end

  it "adds an organization" do
    expect(DB::Organizations.find(org[:id])).to eq(org)
  end

  xit "does not add a duplication organization" do

  end

  it "returns nil if parent cannot be found" do
    expect(DB::Organizations.find(-100)).to be_nil
  end

  it "finds a parent organization" do
    expect(DB::Organizations.parent_of(org[:id])).to eq(parent_org)
  end

  it "returns an list of parent org ids" do
    parent_of_parent_org = { id: 1, parent_id: 0 }
    DB::Organizations.add(parent_of_parent_org)

    expected = [parent_org[:id], parent_of_parent_org[:id]]
    expect(DB::Organizations.parent_ids_of(org[:id])).to eq(expected)
  end

end
