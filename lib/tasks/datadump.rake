require 'rake'
require 'nokogiri'


class StackExchangeDataDump < Nokogiri::XML::SAX::Document
    def start_element name, attrs = []
        puts "starting: #{name}"
    end
 
    def end_element name
        puts "ending: #{name}"
    end
end
  

namespace :datadump do
    task :load => :environment do
        fn = ENV['FILENAME']
        dataset = ENV['DATASET']
        if (!fn) || (!dataset) 
            puts "ERROR! Must specify FILENAME=path/to/Posts.xml DATASET=stackoverflow-posts"
            return
        end
        puts "Parsing #{fn} into dataset #{dataset}..."

        parser = Nokogiri::XML::SAX::Parser.new(StackExchangeDataDump.new)
        parser.parse(File.open(fn))

        puts "Done!"
    end
end
