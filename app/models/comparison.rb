class Comparison
    include Mongoid::Document

    field :tag1, type: String
    field :tag2, type: String

    field :count, type: Integer, default: 0

    index({tag1: 1, tag2: 1}, {background: true, unique: true})
    index({tag1: 1, count: -1}, {background: true})

    def to_s
        "#{tag1} vs #{tag2}" # TODO: Use proper names from Technology model
    end

    def self.increment_count(tech1, tech2)
        [[tech1,tech2],[tech2,tech1]].each do |t1,t2|
            #TODO: use $inc in a moped update query to make this thread-safe at mongodb.
            comp = Comparison.find_or_create_by(tag1: t1.techtag, tag2: t2.techtag)
            comp.count += 1
            comp.save!
        end
    end


    def self.top_for(tech)
        return Comparison.where(tag1: tech.techtag).order_by(count: -1).limit(10)
    end

end
