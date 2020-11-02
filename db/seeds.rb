# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

{
  'rvoss' => { first_name: 'Robert', last_name: 'Voß', email: 'voss@bfpi.de', password: 'bfpi',
               role: User.roles[:admin] },
  'akruth' => { first_name: 'Alexander', last_name: 'Kruth', email: 'kruth@bfpi.de', password: 'bfpi',
                role: User.roles[:admin] },
  'nbennke' => { first_name: 'Niels', last_name: 'Bennke', email: 'bennke@bfpi.de', password: 'bfpi',
                 role: User.roles[:admin] },
  'roest' => { first_name: 'Ricardo', last_name: 'Oest', email: 'oest@bfpi.de', password: 'bfpi',
               role: User.roles[:admin] },
  'jschroeder' => { first_name: 'Jörg', last_name: 'Schröder', email: 'schroeder@bfpi.de', password: 'bfpi',
                    role: User.roles[:admin] },
  'regional_admin' => { first_name: 'Regional', last_name: 'Admin', email: 'regio_admin@bfpi.de', password: 'bfpi',
                        role: User.roles[:regional_admin] }
}.each do |login, hsh|
  User.find_or_create_by!(login: login) do |user|
    user.first_name = hsh[:first_name]
    user.last_name = hsh[:last_name]
    user.email = hsh[:email]
    user.role = hsh[:role]
    user.password = hsh[:password]
    user.ldap = hsh[:ldap]
  end
end

5.times do |ix|
  {
    "aussen_#{(ix + 1)}" => { name: "Außendienst #{(ix + 1)}", kind: Group.kinds[:field_service_team] },
    "innen_#{(ix + 1)}" => { name: "Intern #{(ix + 1)}", kind: Group.kinds[:internal] },
    "extern_#{(ix + 1)}" => { name: "Extern #{(ix + 1)}", kind: Group.kinds[:external] }
  }.each do |short_name, hsh|
    Group.find_or_create_by!(short_name: short_name) do |group|
      group.name = hsh[:name]
      group.kind = hsh[:kind]
      group.main_user = User.find_by(login: :regional_admin)
    end
  end
end

5.times do |ix|
  [
    { name: "Hauptkategorie Idee #{(ix + 1)}", kind: Category.kinds[:idea] },
    { name: "Hauptkategorie Problem #{(ix + 1)}", kind: Category.kinds[:problem] }
  ].each do |hsh|
    Category.find_or_create_by!(name: hsh[:name], average_turnaround_time: 7) do |category|
      category.kind = hsh[:kind]
      category.group = Group.find_by(short_name: "innen_#{(ix + 1)}")
    end
  end
end

Category.all.each do |main_category|
  5.times do |ix|
    Category.find_or_create_by!(name: "Unterkategorie #{main_category.id} - #{(ix + 1)}", average_turnaround_time: 7) do |category|
      category.group = Group.find_by(short_name: "innen_#{(ix + 1)}")
      category.kind = main_category.kind
      main_category.children << category
    end
  end
end

if MailBlacklist.all.blank?
  50.times do |_ix|
    pattern = ((0...rand(10..20)).map { ('a'..'z').to_a[rand(26)] }).join.insert(rand(-5..-3), '.')
    MailBlacklist.create!(pattern: pattern, source: 'Initialisation')
  end
end
