# frozen_string_literal: true

require 'csv'

{
  'admin' => { first_name: 'Admin', last_name: 'Admin', email: 'admin@bfpi.de', password: 'bfpi',
               role: User.roles[:admin] },
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
  User.find_or_create_by!(login:) do |user|
    user.first_name = hsh[:first_name]
    user.last_name = hsh[:last_name]
    user.email = hsh[:email]
    user.role = hsh[:role]
    user.password = hsh[:password]
    user.ldap = hsh[:ldap]
  end
end

unless MailBlacklist.exists?
  50.times do
    pattern = ((0...rand(10..20)).map { ('a'..'z').to_a[rand(26)] }).join.insert(rand(-5..-3), '.')
    MailBlacklist.find_or_create_by! pattern:, source: 'Erstinstallation'
  end
end

# Datenherkunft:
# http://www.geodaten-mv.de/dienste/dvg_laiv_wfs?SERVICE=WFS&VERSION=1.1.0&REQUEST=GetFeature&TYPENAME=dvg:aemter&OUTPUTFORMAT=gml3&srsName=EPSG:4326
# http://www.geodaten-mv.de/dienste/dvg_laiv_wfs?SERVICE=WFS&VERSION=1.1.0&REQUEST=GetFeature&TYPENAME=dvg:kreise&OUTPUTFORMAT=gml3&srsName=EPSG:4326
# http://www.geodaten-mv.de/dienste/dvg_laiv_wfs?SERVICE=WFS&VERSION=1.1.0&REQUEST=GetFeature&TYPENAME=dvg:gemeinden&OUTPUTFORMAT=gml3&srsName=EPSG:4326
#
rgeo_factory = RGeo::Cartesian.preferred_factory(srid: 4326, uses_lenient_assertions: true)
{ kreise: County, aemter: Authority, gemeinden: District }.each do |xml_key, object_class|
  file = "db/seeds/#{object_class.to_s.downcase.pluralize}.xml"
  next unless File.exist?(file)
  doc = Nokogiri::XML(File.read(file))
  doc.xpath('/wfs:FeatureCollection/gml:featureMember').each do |feature|
    regional_key = feature.xpath("dvg:#{xml_key}/dvg:schluessel/text()").to_s.strip
    name = feature.xpath("dvg:#{xml_key}/dvg:gen/text()").to_s.strip

    condition = <<~XPATH.strip
      dvg:#{xml_key}/dvg:geometry/gml:MultiSurface/gml:surfaceMember/gml:Polygon/gml:exterior/gml:LinearRing/gml:posList/text()
    XPATH
    polygons = feature.xpath(condition).map do |polygon|
      tmp = polygon.to_s.strip.split.reverse.map.with_index { |p, ix| p + (ix.even? ? ' ' : ',') }
      "((#{tmp.join[0...-1]}))"
    end

    obj = object_class.find_or_create_by!(regional_key:, name:) do |c|
      options = { regional_key: feature.xpath("dvg:#{xml_key}/dvg:zugehoerig/text()").to_s.strip }
      c.county = County.find_by(options) if xml_key == :aemter
      c.authority = Authority.find_by(options) if xml_key == :gemeinden
      c.area = rgeo_factory.parse_wkt("MULTIPOLYGON(#{polygons.join(',')})")
    end
    { kreise: CountyGroup, aemter: AuthorityGroup }.each do |type, group_model|
      next unless type == xml_key
      group_model.find_or_create_by! main_user: User.first, name: "Standardzuständigkeit - #{name}",
        short_name: "SZ #{name}", kind: :internal, reference_default: true,
        reference_id: obj.id
      next unless Rails.env.development?
      2.times do |ix|
        {
          "aussen_#{ix + 1}": { name: "Außendienst #{ix + 1} #{name}", kind: :field_service_team },
          "innen_#{ix + 1}": { name: "Intern #{ix + 1} #{name}", kind: :internal },
          "extern_#{ix + 1}": { name: "Extern #{ix + 1} #{name}", kind: :external }
        }.each do |short_name, values|
          group_model.find_or_create_by! values.merge(short_name:, reference_id: obj.id,
            main_user: User.find_by(login: :regional_admin))
        end
      end
    end
  end
  ActiveRecord::Base.connection.execute <<~SQL.squish
    update #{object_class.table_name} set area = ST_CollectionExtract(ST_MakeValid(ST_SetSRID(area, 4326)), 3)
      where ST_IsValidReason(area) like '%Self-intersection%';
  SQL
end

if Instance.where(id: 1).blank?
  ActiveRecord::Base.connection.execute <<~SQL.squish
    INSERT INTO #{Instance.table_name}
    SELECT 1, 'MV', '', ST_Multi(ST_CollectionExtract(st_polygonize(ST_Boundary(area)), 3)),
      current_timestamp, current_timestamp
    FROM #{County.table_name}
  SQL
end

InstanceGroup.find_or_create_by! main_user: User.first, name: 'Standardzuständigkeit - MV', short_name: 'SZ MV',
  kind: :internal, reference_default: true, reference_id: 1
if Rails.env.development?
  2.times do |ix|
    {
      "aussen_#{ix + 1}": { name: "Außendienst #{ix + 1} MV", kind: :field_service_team },
      "innen_#{ix + 1}": { name: "Intern #{ix + 1} MV", kind: :internal },
      "extern_#{ix + 1}": { name: "Extern #{ix + 1} MV", kind: :external }
    }.each do |short_name, values|
      InstanceGroup.find_or_create_by! values.merge(short_name:, reference_id: 1,
        main_user: User.find_by(login: :regional_admin))
    end
  end
end

current_main_category = nil
CSV.table('db/seeds/categories.csv').each do |row|
  if (name = row[0]).present?
    current_main_category = MainCategory.find_or_create_by!(kind: row[1], name: name.strip)
  elsif (name = row[2]).present?
    sub_category = SubCategory.find_or_create_by!(name: name.strip)
    Category.find_or_create_by! main_category: current_main_category, sub_category:
  end
end

current_main_category = nil
Dir.glob('db/seeds/responsibilities_*.csv').each do |file_name|
  class_name, name = File.basename(file_name, '.csv').split('_')[1..2]
  model = class_name.classify.constantize
  target = model.find_by!(name:)
  CSV.table(file_name).each do |row|
    if (name = row[0]&.strip).present?
      current_main_category = MainCategory.find_by!(kind: row[1], name:)
    elsif (name = row[2]&.strip).present? && (group_name = row[3]&.strip).present?
      target.groups.where(short_name: "SZ #{target}").update(active: false)
      sub_category = SubCategory.find_by!(name:)
      category = Category.find_by!(main_category: current_main_category, sub_category:)
      group = target.groups.find_or_create_by!(name: group_name, main_user: User.find_by(login: :regional_admin))
      Responsibility.find_or_create_by! category:, group:
    end
  end
end

# rubocop:disable Rails/Output
Dir.glob('db/seeds/users_*.csv').each do |file_name|
  class_name, name = File.basename(file_name, '.csv').split('_')[1..2]
  model = class_name.classify.constantize
  puts "Amt: #{name}"
  target = model.find_by!(name:)
  CSV.table(file_name).each do |row|
    next if row[0].blank?
    user = User.find_or_create_by!(email: row[1].strip,
      login: row[2].downcase.strip,
      last_name: row[3].strip,
      first_name: row[4].strip)
    group = target.groups.find_by!(name: row[0].strip)
    group.users << user unless group.user_ids.include? user.id
    next if user.password_digest.present?
    new_password = SecureRandom.base64(8)[0..-2]
    puts "#{user.login} : '#{new_password}'"
    user.update! password: new_password
  end
  puts '=' * 50
end
# rubocop:enable Rails/Output

CSV.table('db/seeds/default_responsibilities.csv').each do |row|
  group = Group.find_by(name: "Standardzuständigkeit - #{row[1]}")
  group.update! email: row[2] if group.present?
end
