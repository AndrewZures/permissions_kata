require_relative 'db/permissions'
require_relative 'db/organizations'
require_relative 'db/tree_organizations'
require_relative 'db/roles'

class Authorizer

  AUTHORIZED_ROLES = [
    DB::Roles::Types[:ADMIN],
    DB::Roles::Types[:USER]
  ]

  def initialize(organizations, permissions)
    @organizations = organizations
    @permissions = permissions
  end

  def authorized?(org, user)
    return default_error_status if @organizations.find(org).nil?

    org_lineage = @organizations.lineage_for(org)
    permission = find_best_permission(org_lineage, user)
    format_status(permission)
  end

  def format_status(permission)
    return { authorized: false, status: "no permission found"} if permission.nil?

    { authorized: permission_authorized?(permission),
      status: permission[:role].to_s }
  end

  def find_best_permission(org_ids, user)
    found = nil

    while found.nil? && !org_ids.empty? do
      org_id = org_ids.shift()
      found = @permissions.find({ org_id: org_id, user_id: user[:id] })
    end

    found
  end

  private

  def permission_authorized?(permission)
    AUTHORIZED_ROLES.include?(permission[:role])
  end

  def default_error_status
    { authorized: false, status: "org not found" }
  end

end
