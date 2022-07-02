require "optparse"

class Cli
  def self.parse
    options = {}
    OptionParser.new { |opts|
      opts.on("-v", "--verbose", "Show extra information") do
        options[:verbose] = true
      end
      opts.on("-c", "--color", "Enable syntax highlighting") do
        options[:syntax_highlighting] = true
      end
    }.parse!
    options
  end
end
