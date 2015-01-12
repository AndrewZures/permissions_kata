require_relative '../src/authorizer'
require_relative '../src/db/models/organizations'
require_relative '../src/db/models/permissions'
require_relative '../src/db/models/roles'

describe "authorizer" do
  let(:user){ { id: 10 } }

  let(:root_org){        { id: :root, parent_id: nil } }
  let(:org1){            { id: :org1, parent_id: :root } }
  let(:org2){            { id: :org2, parent_id: :root } }
  let(:child_org1){      { id: :child_org1, parent_id: :org1 } }
  let(:child_org2){      { id: :child_org2, parent_id: :org1 } }
  let(:child_org3){      { id: :child_org3, parent_id: :org2 } }

  let(:permission1){
    { user_id: user[:id], org_id: root_org[:id], type: DB::Roles::Types[:DENIED] } }
  let(:permission2){
    { user_id: user[:id], org_id: org1[:id], type: DB::Roles::Types[:ADMIN] } }
  let(:permission3){
    { user_id: user[:id], org_id: child_org2[:id], type: DB::Roles::Types[:USER] } }

  before(:each) do
    DB::Permissions.add(permission1)
    DB::Permissions.add(permission2)
    DB::Permissions.add(permission3)

    DB::Organizations.add(root_org)
    DB::Organizations.add(org1)
    DB::Organizations.add(org2)
    DB::Organizations.add(child_org1)
    DB::Organizations.add(child_org2)
    DB::Organizations.add(child_org3)
  end

  after(:each) do
    DB::Permissions.destroy_all
    DB::Organizations.destroy_all
  end

  it "is denied if provided organization is not found" do
    result = Authorizer.authorized?({id: -1}, user)
    expect(result).to eq({authorized: false, status: "org not found" })
  end

  it "is denied if no permission found" do
    DB::Permissions.destroy_all

    result = Authorizer.authorized?(org1, user)
    expect(result).to eq({authorized: false, status: "no permission found" })
  end

  it "is denied if denied permission found" do
    result = Authorizer.authorized?(root_org, user)
    expect(result).to eq({authorized: false, status: "denied" })
  end

  it "is authorized if user permission found" do
    result = Authorizer.authorized?(child_org2, user)
    expect(result).to eq({authorized: true, status: "user" })
  end

  it "is authorized if admin permission found" do
    result = Authorizer.authorized?(org1, user)
    expect(result).to eq({authorized: true, status: "admin" })
  end

  it "evaluates parent permission if no other permission found" do
    result = Authorizer.authorized?(child_org1, user)
    expect(result).to eq({authorized: true, status: "admin" })
  end

  it "evaluates grandparent permission if no other permission found" do
    result = Authorizer.authorized?(child_org1, user)
    expect(result).to eq({ authorized: true, status: "admin"})
  end

  context "permission interaction" do

    it "authorizes user for org and all child orgs" do
      root_access  = Authorizer.authorized?(root_org, user)
      org_access   = Authorizer.authorized?(org2, user)
      child_access = Authorizer.authorized?(child_org3, user)

      admin_authorized = {authorized: false, status: "denied"}
      expect(root_access).to eq(admin_authorized)
      expect(org_access).to eq(admin_authorized)
      expect(child_access).to eq(admin_authorized)
    end


    it "prioritizes current permission over parent permissions" do
      result = Authorizer.authorized?(child_org2, user)
      expect(result).to eq({authorized: true, status: "user" })
    end

    it "prioritizes parent permission over grandparent permission" do
      result = Authorizer.authorized?(child_org1, user)

      expect(result).to eq({authorized: true, status: "admin" })
    end

    it "children of parent can have different privilege settings" do
      child1_auth = Authorizer.authorized?(child_org1, user)
      child2_auth = Authorizer.authorized?(child_org2, user)

      expect(child1_auth).to eq({authorized: true, status: "admin" })
      expect(child2_auth).to eq({authorized: true,  status: "user" })
    end

  end

end
