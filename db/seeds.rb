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
    "aussen_#{ix + 1}" => { name: "Außendienst #{ix + 1}", kind: Group.kinds[:field_service_team] },
    "innen_#{ix + 1}" => { name: "Intern #{ix + 1}", kind: Group.kinds[:internal] },
    "extern_#{ix + 1}" => { name: "Extern #{ix + 1}", kind: Group.kinds[:external] }
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
    { name: "Hauptkategorie Idee #{ix + 1}", kind: Category.kinds[:idea] },
    { name: "Hauptkategorie Problem #{ix + 1}", kind: Category.kinds[:problem] }
  ].each do |hsh|
    Category.find_or_create_by!(name: hsh[:name], average_turnaround_time: 7) do |category|
      category.kind = hsh[:kind]
      category.group = Group.find_by(short_name: "innen_#{ix + 1}")
    end
  end
end

Category.all.each do |main_category|
  5.times do |ix|
    Category.find_or_create_by!(name: "Unterkategorie #{main_category.id} - #{ix + 1}",
                                average_turnaround_time: 7) do |category|
      category.group = Group.find_by(short_name: "innen_#{ix + 1}")
      category.kind = main_category.kind
      main_category.children << category
    end
  end
end

if MailBlacklist.all.blank?
  50.times do |_ix|
    pattern = ((0...rand(10..20)).map { ('a'..'z').to_a[rand(26)] }).join.insert(rand(-5..-3), '.')
    MailBlacklist.create!(pattern: pattern, source: 'Erstinstallation')
  end
end

rgeo_factory = RGeo::Cartesian.preferred_factory(uses_lenient_assertions: true)
{ kreise: County, aemter: Authority, gemeinden: Community }.each do |file_name, object_class|
  next unless File.exist?("db/seeds/#{file_name}.xml")
  doc = Nokogiri::XML(File.read("db/seeds/#{file_name}.xml"))
  doc.xpath('/wfs:FeatureCollection/gml:featureMember').each do |feature|
    regional_key = feature.xpath("dvg:#{file_name}/dvg:schluessel/text()").to_s.strip
    name = feature.xpath("dvg:#{file_name}/dvg:gen/text()").to_s.strip

    polygone = []
    feature.xpath("dvg:#{file_name}/dvg:geometry/gml:MultiSurface/gml:surfaceMember/gml:Polygon/gml:exterior/"\
    'gml:LinearRing/gml:posList/text()').each do |polygon|
      tmp = []
      polygon.to_s.strip.split.each_with_index { |pol, ix| tmp << pol + (ix.even? ? ' ' : ',') }
      polygone << "(#{tmp.join[0...-1]})"
    end

    transform = false
    obj = object_class.find_or_create_by!({ regional_key: regional_key, name: name }) do |c|
      if file_name == :aemter
        c.county = County.find_by(regional_key: feature.xpath("dvg:#{file_name}/dvg:zugehoerig/text()").to_s.strip)
      end
      if file_name == :gemeinden
        c.authority = Authority.find_by(regional_key: feature.xpath("dvg:#{file_name
                                                                         }/dvg:zugehoerig/text()").to_s.strip)
      end
      c.area = rgeo_factory.parse_wkt("MULTIPOLYGON((#{polygone.join(',')}))")
      transform = true
    end
    if transform
      ActiveRecord::Base.connection.execute("update #{object_class.table_name} set " \
      "area = ST_MakeValid(ST_Transform(ST_GeomFromText(ST_AsText(area), 5650), 4326)) where id = #{obj.id}")
    end
  end
end

ActiveRecord::Base.connection.execute("insert into #{Instance.table_name} select 1, 'MV', '', "\
  "ST_GEOMFROMTEXT(st_astext(st_multi(ST_CollectionExtract(concat('SRID=4269;', st_astext("\
  'ST_Makevalid(st_astext(st_multi(ST_CollectionExtract(st_polygonize(ST_AsText(ST_Boundary('\
  'ST_GeomFromText(ST_AsText(area), 4326)))), 3)))))), 3))), 4326), '\
  "current_timestamp, current_timestamp FROM #{County.table_name}")
