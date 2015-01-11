require_relative 'db/models/permissions'
require_relative 'db/models/organizations'
require_relative 'db/models/roles'

class Authorizer

  def self.authorized?(org, user)
    return error_result if DB::Organizations.find(org[:id]).nil?

    org_ids = DB::Organizations.parent_ids_of(org[:id])
    org_ids.unshift(org[:id])
    permission = find_best_permission(org_ids, user)
    format_status(permission)
  end

  def self.format_status(permission)
    return { authorized: false, status: "no permission found"} if permission.nil?
    case permission[:type]
    when DB::Roles::Types[:DENIED] then return { authorized: false, status: "denied" }
    when DB::Roles::Types[:USER]   then return { authorized: true, status: "user" }
    when DB::Roles::Types[:ADMIN]  then return { authorized: true, status: "admin" }
    end
  end

  def self.error_result
    { authorized: false, status: "org not found" }
  end

  def self.find_best_permission(org_ids, user)
    found = nil

    while found.nil? && !org_ids.empty? do
      org_id = org_ids.shift()
      found = DB::Permissions.find(org_id, user[:id])
    end

    found
  end

end
