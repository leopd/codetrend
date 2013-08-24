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
        "#{tech1.name} vs #{tech2.name}"
    end


    def tech1
        if ! @_tech1
            @_tech1 = Technology.find_by(techtag: self.tag1)
        end
        @_tech1
    end

    def tech2
        if ! @_tech2
            @_tech2 = Technology.find_by(techtag: self.tag2)
        end
        @_tech2
    end

    def self.increment_count_obj(tech1, tech2)  # requires Technology objects
        self.increment_count_techtag(tech1.techtag, tech2.techtag)
    end


    def self.increment_count_techtag(tag1, tag2)
        [[tag1,tag2],[tag2,tag1]].each do |t1,t2|
            #TODO: use $inc in a moped update query to make this thread-safe at mongodb.
            # This isn't a big deal right now because if we lose some logging data not the end of world.
            comp = Comparison.find_or_create_by(tag1: t1, tag2: t2)
            comp.count += 1
            comp.save!
        end
    end


    # Finds top Comparisons for a tech
    def self.top_for(tech)
        return Comparison.where(tag1: tech.techtag).order_by(count: -1).limit(10)
    end


    # Use this to dedupe the forward/backwards pairs
    def forward?
        return self.tag1 < self.tag2
    end


    def path
        "/compare/#{self.tech1.slug_esc}/vs/#{self.tech2.slug_esc}"
    end

end
