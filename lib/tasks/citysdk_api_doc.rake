# frozen_string_literal: true

namespace :citysdk do
  desc 'Create API documentation CitySDK_API.md'
  task apidoc: :environment do
    api = [<<~API]
      # Klarschiff-CitySDK
      Implementation of CitySDK-Smart-Participation-API for Klarschiff

      ## Supported formats and encoding
      The API supports both JSON and XML. All strings are encoded with UTF-8.

      ## General info
      The Issue Reporting API is based on GeoReport API version 2, better known as the [Open311 specification](http://open311.org/).
      The interface is designed in such a way that any GeoReport v2 compatible client is able to use the interface.
      This interface is compliant with [CitySDK](http://www.citysdk.eu/) specific enhancements to Open311.
      To support some special functions there are also some additional enhancements to Open311 and CitySDK.

      ## API methods
    API
    Dir.glob('app/controllers/citysdk/**/*.rb').each { |f| api += extract_documentation(f) }
    api[-1] = "#{api.last}\n"
    File.write Rails.root.join('CitySDK_API.md'), api.join("\n")
  end

  def extract_documentation(file)
    pattern = /^ *# :apidoc: ?/
    lines = File.readlines(file).select { |line| line.match? pattern }
    lines.map! { |line| line.remove pattern }
    lines.map!(&:strip)
    lines << '' unless lines.length.zero?
    lines
  end
end
