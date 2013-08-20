require 'rake'
require 'nokogiri'


class TagCounter
    def initialize(dataset)
        @dataset = dataset
        @cnt = {}
    end

    def count(tag,datestr)
        actual_date = Date.parse(datestr)
        rounded_date = Date.new(actual_date.year, actual_date.month, 1)
        key = [tag,rounded_date]
        if @cnt[key]
            @cnt[key] += 1
            if @cnt[key] % 500 == 0
                puts "#{key} has #{@cnt[key]}"
            end
        else
            @cnt[key] = 1
        end
    end


    def persist
        @cnt.keys.each do |key|
            m = Metric.new
            m.dataset = @dataset
            m.techtag = key[0]
            m.day = key[1]
            m.val = @cnt[key]
            m.save!
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

        counter = TagCounter.new(dataset)
        parser = Nokogiri::XML::SAX::Parser.new(StackExchangeDataDumpSaxParser.new(counter))

        parser.parse(File.open(fn))
        puts "Done parsing"

        counter.persist
        puts "Done saving"
    end
end
