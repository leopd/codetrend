class Technology
    include Mongoid::Document
    include Mongoid::Taggable

    field :_id, type: String
    field :name, type: String
    field :techtag, type: String

    validates_presence_of :name, :techtag

    index({techtag: 1}, {background: true, unique: true})

    def slug
        self._id
    end

    def slug_esc
        Rack::Utils.escape( self.slug )
    end

    def to_param
        self.slug_esc
    end


    def self.slug_for_tag(tag)
        slug = tag.gsub(/[\/?]/,'_')
        #Rack::Utils.escape( slug )  # Don't store this in the data model.  This is a representation
    end


    def self.new_for_tag(tag)
        Technology.new do |t|
            t.techtag = tag
            t.name = tag.gsub("-"," ").titleize
            t._id = Technology.slug_for_tag(tag)
        end
    end
end
