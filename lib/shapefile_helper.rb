require "zip"
require "open-uri"

# Safe version of `URI.open` that does not rely on `Kernel.open`
module SafeOpenUri
  def self.open(name, *rest, &block)
    if name.respond_to?(:open)
      name.open(*rest, &block)
    elsif name.respond_to?(:to_str) &&
        %r{\A[A-Za-z][A-Za-z0-9+\-.]*://} =~ name &&
        (uri = URI.parse(name)).respond_to?(:open)
      uri.open(*rest, &block)
    else
      File.open(name, &block)
    end
  end
end

module ShapefileHelper
  def self.open(
    path:,
    factory:,
    file_filter: ->(_) { true }
  )
    Dir.mktmpdir do |dir|
      shapefile_path = nil
      SafeOpenUri.open(path, "rb") do |f|
        Zip::File.open_buffer(f.read) do |zip_file|
          zip_file.each do |entry|
            name = entry.name
            extension = File.extname(name)
            if entry.file? && file_filter.call(name) && %w[.shp .shx .dbf .cpg].include?(extension)
              path = File.join(dir, name)
              if extension == ".shp"
                shapefile_path = path
              end
              File.open(path, "w") do |file|
                file.syswrite(entry.get_input_stream.read)
              end
            end
          end
        end
      end
      raise "Could not find shape file inside zip" unless shapefile_path && File.exist?(shapefile_path)
      RGeo::Shapefile::Reader.open(shapefile_path, factory: factory) do |file|
        yield file
      end
    end
  end
end
