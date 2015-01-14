require 'singleton'

module DB
  class Roles
    include Singleton

    Types = { USER: :user, ADMIN: :admin, DENIED: :denied }
  end
end
