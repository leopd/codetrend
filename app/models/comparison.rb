class Comparison
    include Mongoid::Document

    field :tag1, type: String
    field :tag2, type: String

    field :count, type: Integer, default: 0

    index({tag1: 1, tag2: 1}, {background: true, unique: true})


    def self.increment_count(tech1, tech2)
        if( tech1.techtag > tech2.techtag ) 
            t = tech1
            tech1 = tech2
            tech2 = t
        end
        #TODO: use $inc in a moped update query to make this thread-safe at mongodb.
        comp = Comparison.find_or_create_by(tag1: tech1.techtag, tag2: tech2.techtag)
        comp.count += 1
        comp.save!
    end
end
