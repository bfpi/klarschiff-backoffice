# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

{
  'rvoss' => { first_name: 'Robert', last_name: 'Voß', email: 'voss@bfpi.de', password: nil,
               ldap: 'uid=rvoss,ou=users,dc=bfpi,dc=local' },
  'akruth' => { first_name: 'Alexander', last_name: 'Kruth', email: 'kruth@bfpi.de', password: 'bfpi' },
  'nbennke' => { first_name: 'Niels', last_name: 'Bennke', email: 'bennke@bfpi.de', password: 'bfpi' },
  'roest' => { first_name: 'Ricardo', last_name: 'Oest', email: 'oest@bfpi.de', password: 'bfpi' },
  'jschroeder' => { first_name: 'Jörg', last_name: 'Schröder', email: 'schroeder@bfpi.de', password: 'bfpi' }
}.each do |login, hsh|
  User.find_or_create_by!(login: login) do |user|
    user.first_name = hsh[:first_name]
    user.last_name = hsh[:last_name]
    user.email = hsh[:email]
    user.role = User.roles[:admin]
    user.password = hsh[:password]
    user.ldap = hsh[:ldap]
  end
end
