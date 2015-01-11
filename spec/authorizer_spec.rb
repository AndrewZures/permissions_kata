require_relative '../src/authorizer'
require_relative '../src/db/models/organizations'
require_relative '../src/db/models/permissions'
require_relative '../src/db/models/roles'

describe "authorizer" do
  let(:user){ { id: 10 } }

  let(:org1){            {id: 1, parent_id: 10} }
  let(:org2){            {id: 2, parent_id: 20} }
  let(:org3){            {id: 3, parent_id: 30} }
  let(:child_org1){      {id: 4, parent_id: 3} }
  let(:grandchild_org1){ {id: 5, parent_id: 4} }

  let(:permission1){
    { user_id: user[:id], org_id: org1[:id], type: DB::Roles::Types[:DENIED] } }
  let(:permission2){
    { user_id: user[:id], org_id: org2[:id], type: DB::Roles::Types[:USER] } }
  let(:permission3){
    { user_id: user[:id], org_id: org3[:id], type: DB::Roles::Types[:ADMIN] } }

  before(:each) do
    DB::Permissions.add(permission1)
    DB::Permissions.add(permission2)
    DB::Permissions.add(permission3)

    DB::Organizations.add(org1)
    DB::Organizations.add(org2)
    DB::Organizations.add(org3)
    DB::Organizations.add(child_org1)
    DB::Organizations.add(grandchild_org1)
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
    result = Authorizer.authorized?(org1, user)
    expect(result).to eq({authorized: false, status: "denied" })
  end

  it "is authorized if user permission found" do
    result = Authorizer.authorized?(org2, user)
    expect(result).to eq({authorized: true, status: "user" })
  end

  it "is authorized if admin permission found" do
    result = Authorizer.authorized?(org3, user)
    expect(result).to eq({authorized: true, status: "admin" })
  end

  it "evaluates parent permission if no other permission found" do
    result = Authorizer.authorized?(child_org1, user)
    expect(result).to eq({authorized: true, status: "admin" })
  end

  it "evaluates grandparent permission if no other permission found" do
    result = Authorizer.authorized?(grandchild_org1, user)
    expect(result).to eq({ authorized: true, status: "admin"})
  end

  it "authorizes user for org and all child orgs" do
    child_access  = Authorizer.authorized?(grandchild_org1, user)
    gchild_access = Authorizer.authorized?(child_org1, user)
    org_access    = Authorizer.authorized?(org3, user)

    admin_authorized = {authorized: true, status: "admin"}
    expect(org_access).to eq(admin_authorized)
    expect(child_access).to eq(admin_authorized)
    expect(gchild_access).to eq(admin_authorized)
  end

  context "when multiple permission for same user" do

    it "prioritizes current org permission parent permissions" do
      grandchild_permission = { org_id:  grandchild_org1[:id], user_id: user[:id],
                                type: DB::Roles::Types[:DENIED] }

      DB::Permissions.add(grandchild_permission)
      result = Authorizer.authorized?(grandchild_org1, user)

      expect(result).to eq({authorized: false, status: "denied" })
    end

    it "prioritizes parent org permission over grandparent permission" do
      child_permission = { org_id: child_org1[:id], user_id: user[:id],
                                type: DB::Roles::Types[:DENIED] }

      DB::Permissions.add(child_permission)
      result = Authorizer.authorized?(grandchild_org1, user)

      expect(result).to eq({authorized: false, status: "denied" })
    end

    it "children of org can have different privilege settings" do
      grandchild_org1_permission = { org_id: grandchild_org1[:id], user_id: user[:id],
                                type: DB::Roles::Types[:DENIED] }
      DB::Permissions.add(grandchild_org1_permission)

      grandchild_org2 = {id: 6, parent_id: 4}
      DB::Organizations.add(grandchild_org2)

      gchild1_auth = Authorizer.authorized?(grandchild_org1, user)
      gchild2_auth = Authorizer.authorized?(grandchild_org2, user)

      expect(gchild1_auth).to eq({authorized: false, status: "denied" })
      expect(gchild2_auth).to eq({authorized: true,  status: "admin" })
    end

  end

end
