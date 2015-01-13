require_relative 'db/permissions'
require_relative 'db/organizations'
require_relative 'db/tree_organizations'
require_relative 'db/roles'

class Authorizer

  # @@organizations = DB::TreeOrganizations
  @@organizations = DB::Organizations

  AUTHORIZED_ROLES = [
    DB::Roles::Types[:ADMIN],
    DB::Roles::Types[:USER]
  ]

  def self.authorized?(org, user)
    return default_error_status if @@organizations.find(org).nil?

    org_lineage = @@organizations.lineage_for(org)
    permission = find_best_permission(org_lineage, user)
    format_status(permission)
  end

  def self.format_status(permission)
    return { authorized: false, status: "no permission found"} if permission.nil?

    { authorized: self.permission_authorized?(permission),
      status: permission[:role].to_s }
  end

  def self.find_best_permission(org_ids, user)
    found = nil

    while found.nil? && !org_ids.empty? do
      org_id = org_ids.shift()
      found = DB::Permissions.find({ org_id: org_id, user_id: user[:id] })
    end

    found
  end

  private

  def self.permission_authorized?(permission)
    AUTHORIZED_ROLES.include?(permission[:role])
  end

  def self.default_error_status
    { authorized: false, status: "org not found" }
  end

end
