require_relative '../../../src/db/models/permissions'
require_relative '../../../src/db/models/roles'

describe DB::Permissions do
  let(:permissions){ described_class }
  let(:role_types){ DB::Roles::Types }

  let(:permission1){ { user_id: 1, org_id: 1, role: role_types[:USER] } }
  let(:permission2){ { user_id: 2, org_id: 2, role: role_types[:ADMIN] } }
  let(:permission3){ { user_id: 3, org_id: 2, role: role_types[:DENIED] } }

  before(:each) do
    permissions.add(permission1)
    permissions.add(permission2)
    permissions.add(permission3)
  end

  after(:each) do
    permissions.destroy_all
  end

  it "saves a permission" do
    # testing save and search == bad
    results = permissions.search({ role: role_types[:USER] })
    expect(results.count).to eq(1)
    expect(results.first).to eq(permission1)
  end

  it "can search by role" do
    results = permissions.search({ role: role_types[:USER] })
    expect(results.count).to eq(1)
    expect(results.first).to eq(permission1)
  end

  it "can search by org_id" do
    results = permissions.search({ org_id: 2 })
    expect(results.count).to eq(2)
    expect(results).to include(permission2)
    expect(results).to include(permission3)
  end

  it "can search by user_id" do
    results = permissions.search({ user_id: 3 })
    expect(results.count).to eq(1)
    expect(results).to include(permission3)
  end

  it "can search by user_id and org_id" do
    results = permissions.search({ org_id: 2, user_id: 3 })
    expect(results.count).to eq(1)
    expect(results).to include(permission3)
  end

  it "only validates if all required fields are present" do
    permissions.add({ org_id: 4 })
    results = permissions.search({ org_id: 4 })
    expect(results).to be_empty
  end

end
