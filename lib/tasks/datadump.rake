require 'rake'
require 'nokogiri'


class TagCounter
    def initialize
        @cnt = {}
    end

    def count(tag,datestr)
        date = Date.parse(datestr)
        key = [tag,date]
        if @cnt[key]
            @cnt[key] += 1
            if @cnt[key] % 50 == 0
                puts "#{key} has #{@cnt[key]}"
            end
        else
            @cnt[key] = 1
        end
    end
end


class StackExchangeDataDumpSaxParser < Nokogiri::XML::SAX::Document

    def initialize(counter)
        @counter = counter
    end


    def attrs_to_hash(attrs)
        result = {}
        attrs.each do |k,v|
            result[k] = v
        end
        return result
    end


    def start_element name, attrs = []
        if name == "row"
            hattrs = attrs_to_hash(attrs)
            tags = hattrs['Tags']
            date = hattrs['CreationDate']
            if tags 
                tags.split(/[<>]/).each do |tag|
                    if tag.length > 0
                        @counter.count(tag,date)
                    end
                end
            end
        end
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

        counter = TagCounter.new
        parser = Nokogiri::XML::SAX::Parser.new(StackExchangeDataDumpSaxParser.new(counter))
        parser.parse(File.open(fn))

        puts "Done!"
    end
end
