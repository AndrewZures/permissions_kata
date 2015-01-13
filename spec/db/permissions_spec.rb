require_relative '../../src/db/permissions'
require_relative '../../src/db/roles'

describe DB::Permissions do
  let(:permissions){ DB::Permissions.instance }
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
    results = permissions.search({})

    expect(results.count).to eq(3)
    expect(results).to include(permission1)
    expect(results).to include(permission2)
    expect(results).to include(permission3)
  end

  it "determines if permission is valid" do
    valid_permission = { user_id: 8, org_id: 3, role: role_types[:USER] }
    validated = permissions.valid?(valid_permission)
    expect(validated).to eq(true)

    invalid_permission = { user_id: :just_an_id }
    validated = permissions.valid?(invalid_permission)
    expect(validated).to eq(false)
  end

  it "determines if permission is addable" do
    addable_permission = { user_id: 8, org_id: 3, role: role_types[:USER]}
    addable = permissions.addable?(addable_permission)
    expect(addable).to eq(true)

    added = permissions.addable?(permission1)
    expect(added).to eq(false)
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

end
