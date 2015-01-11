require_relative '../../../src/db/models/permissions'
require_relative '../../../src/db/models/roles'

describe "permissions" do
  let(:permission1){ { user_id: 1, org_id: 1, type: DB::Roles::Types[:USER] } }
  let(:permission2){ { user_id: 2, org_id: 2, type: DB::Roles::Types[:ADMIN] } }
  let(:permission3){ { user_id: 3, org_id: 2, type: DB::Roles::Types[:DENIED] } }

  before(:each) do
    DB::Permissions.add(permission1)
    DB::Permissions.add(permission2)
    DB::Permissions.add(permission3)
  end

  after(:each) do
    DB::Permissions.reset
  end

  it "saves a permission" do
    # testing save and search == bad
    results = DB::Permissions.search({ type: DB::Roles::Types[:USER] })
    expect(results.count).to eq(1)
    expect(results.first).to eq(permission1)
  end

  it "can search by type" do
    results = DB::Permissions.search({ type: DB::Roles::Types[:USER] })
    expect(results.count).to eq(1)
    expect(results.first).to eq(permission1)
  end

  it "can search by org_id" do
    results = DB::Permissions.search({ org_id: 2 })
    expect(results.count).to eq(2)
    expect(results).to include(permission2)
    expect(results).to include(permission3)
  end

  it "can search by user_id" do
    results = DB::Permissions.search({ user_id: 3 })
    expect(results.count).to eq(1)
    expect(results).to include(permission3)
  end

  it "can search by user_id and org_id" do
    results = DB::Permissions.search({ org_id: 2, user_id: 3 })
    expect(results.count).to eq(1)
    expect(results).to include(permission3)
  end

  it "only validates if all required fields are present" do
    DB::Permissions.add({ org_id: 4 })
    results = DB::Permissions.search({ org_id: 4 })
    expect(results).to be_empty
  end

end
