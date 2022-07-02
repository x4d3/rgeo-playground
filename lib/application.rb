require "rubygems"
require "bundler"
Bundler.require(:default)

require "singleton"
require "open-uri"

require_relative "shapefile_helper"
require_relative "cli"

raise "RGeo::Geos is not supported" unless RGeo::Geos.supported?
puts "preferred_native_interface #{RGeo::Geos.preferred_native_interface}"
puts "rgeo-proj4 version #{RGeo::Proj4::VERSION}"
raise "proj4 is not supported" unless RGeo::CoordSys::Proj4.supported?
puts "proj4 version: #{RGeo::CoordSys::Proj4.version}"
puts "RUBY_VERSION: #{RUBY_VERSION}"
puts "RUBY_PLATFORM #{RUBY_PLATFORM}"
ws84_definition = "proj=longlat +datum=WGS84 +no_defs +type=crs"
# https://epsg.io/2154
paris_lambert_definition = "+proj=lcc +lat_1=49 +lat_2=44 +lat_0=46.5 +lon_0=3 +x_0=700000 +y_0=6600000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs"

ws84_proj4 = RGeo::CoordSys::Proj4.create(ws84_definition)
raise "invalid ws84_definition" unless ws84_proj4

paris_lambert_proj4 = RGeo::CoordSys::Proj4.create(paris_lambert_definition)
raise "invalid paris_lambert_definition" unless paris_lambert_proj4

paris_lambert_factory = RGeo::Cartesian.factory(srid: 2154, proj4: paris_lambert_proj4)
ws84_factory = RGeo::Cartesian.factory(srid: 4326, proj4: ws84_proj4)

paris_lambert_to_ws84_crs = RGeo::CoordSys::CRSStore.get(paris_lambert_proj4, ws84_proj4)

path = "https://infoterre.brgm.fr/telechargements/BDCharm50/GEO050K_HARM_089.zip"
uri = URI.parse(path)

file_path = File.join(File.dirname(__FILE__), "../GEO050K_HARM_089.zip")

puts "downloading file"
ShapefileHelper.open(path: file_path, factory: paris_lambert_factory, file_filter: ->(n) { n.include?("S_FGEOL") }) do |file|
  puts "iterating file"
  file.each do |record|
    notation = record.attributes["NOTATION"]
    title = record.attributes["DESCR"]
    geometry = record.geometry
    puts "#{notation} #{title} #{geometry}"
    transformed = paris_lambert_to_ws84_crs.transform(geometry, ws84_factory)

    geo_json = {
      type: "Feature",
      geometry: RGeo::GeoJSON.encode(transformed),
      properties: {
        stroke: "#000000",
        fill: "#0B699E"
      }
    }.to_json


    puts geo_json

  end
end
