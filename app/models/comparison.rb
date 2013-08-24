class Comparison
    include Mongoid::Document

    field :tag1, type: String
    field :tag2, type: String

    field :count, type: Integer, default: 0

    validate :check_tags_different
    def check_tags_different
        errors.add(:tag2, "technologies must be different") if tag1 == tag2
    end

    index({tag1: 1, tag2: 1}, {background: true, unique: true})
    index({tag1: 1, count: -1}, {background: true})
    index({count: -1}, {background: true})

    def to_s
        "#{tag1} vs #{tag2}" # TODO: Use proper names from Technology model
    end

    def self.increment_count_obj(tech1, tech2)  # requires Technology objects
        self.increment_count_techtag(tech1.techtag, tech2.techtag)
    end


    def self.increment_count_techtag(tag1, tag2)
        [[tag1,tag2],[tag2,tag1]].each do |t1,t2|
            #TODO: use $inc in a moped update query to make this thread-safe at mongodb.
            comp = Comparison.find_or_create_by(tag1: t1, tag2: t2)
            comp.count += 1
            comp.save!
        end
    end


    def self.top_for(tech)
        return Comparison.where(tag1: tech.techtag).order_by(count: -1).limit(10)
    end


    # an easy way to de-dupe
    def forward?
        return self.tag1 < self.tag2
    end


    def url
        #TODO: use rails routes for this
        "/compare/#{self.tag1}/vs/#{self.tag2}"
    end

end
