require 'rake'
require 'nokogiri'


class TagCounter
    def initialize(dataset)
        @dataset = dataset
        @cnt = {}
    end

    def count_one(tag,datestr)
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


    def count(tags,date,attrs)
        tags.each do |tag|
            self.count_one(tag,date)
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


class VersusCounter
    def count(tags, date, attrs)
        if attrs['Title'] =~ /\bvs\b/i
            (0..(tags.length-1)).each do |i|
                (0..(i-1)).each do |j|
                    t1 = tags[i]
                    t2 = tags[j]
                    #puts "Compare #{t1} vs #{t2}"
                    Comparison.increment_count_techtag(t1,t2)  
                end
            end
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


    def tagstr_to_tags(tagstr)
        if !tagstr
            return []
        end
        tagstr.split(/[<>]/).map do |tag|
            tag.length > 0 ? tag : nil
        end.compact
    end

    def start_element name, attrs = []
        if name == "row"
            hattrs = attrs_to_hash(attrs)
            tagstr = hattrs['Tags']
            date = hattrs['CreationDate']
            @counter.count(tagstr_to_tags(tagstr),date,hattrs)
        end
    end

end
  

namespace :datadump do

    desc "Reads a Posts.xml file from stackexchange dump and loads into Metric model"
    task :load => :environment do
        #TODO: This could be made a lot faster by parallelizing 
        # One straightforward way would be to convert to a map/reduce job through hadoop or similar.
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

    # Doesn't currently check for existing ones.
    desc "Creates a Technology object for each kind of :techtag in Metrics."
    task :create_all_technologies => :environment do
        Metric.distinct('techtag').each do |tag|
            t = Technology.new_for_tag(tag)
            add_popularity_tags = true  # Easily disable for quick testing
            if add_popularity_tags
                #NOTE: This is slow.  Faster to aggregate on server, but it's a one-time load.
                sum_metrics = Metric.where(techtag: t.techtag).reduce(0) do |tot, m|
                    tot + m.val
                end
                tags = []
                (2..10).each do |x|
                    if sum_metrics >= 10**x
                        tags.push("pow#{x}")
                    end
                end
                t.tags = tags.join(",")
            end
            t.save!
        end
    end


    desc "Mine Posts.xml for posts with 'vs' in the title. Count them in comparisons"
    task :mine_vs => :environment do
        #NOTE: not currently in use. 
        # This in fact makes a lot of comparisons between same-stack technologies.
        fn = ENV['FILENAME']
        if (!fn) 
            puts "ERROR! Must specify FILENAME=path/to/Posts.xml"
            return
        end
        puts "Parsing #{fn} for vs posts"

        counter = VersusCounter.new()
        parser = Nokogiri::XML::SAX::Parser.new(StackExchangeDataDumpSaxParser.new(counter))

        parser.parse(File.open(fn))
        puts "Done parsing"
    end
end


