[kata]: http://www.adomokos.com/2012/10/the-organizations-users-roles-kata.html

# Permissions Kata

The repo is my solution to the "Organizations, Users, Roles" Kata found [here](kata)

### To Build
* run `bundle install`

### To Test
* run `rspec` at root directory

##### To Run Separate Organization Strats
* there are two organization strategies: (1) basic and (2) tree
* authorizer_spec.rb has a tree_organization instance commented out that can be substituted for the basic_organization instance

### Design Notes
* I used ruby maps and arrays for records instead of objects since my solution only requires me to read/write to record key/value pairs and I wanted to take a more functional approach to the problem.

* class @@tables are meant to represent the entity's underlying DB table

* There are <b>two</b> separate implementations of the organization entity in my solution.  Both solutions implement the same interface:
  * Basic:
      * org traversals reach into the table for each parent/child lookup
      * This is more table (DB) intensive but the code is simpler and cleaner
  * Tree:
    * An in-memory org tree is kept up-to-date in the org singleton instance
    * This strategy is more complicated, since the org tree must be kept up-to-date and must keep the table up-to-date, but it reduces interactions with the underlying table, so it is likely to be less DB intensive.
    * Requires the in-memory tree to be built from an existing table when instantiated
