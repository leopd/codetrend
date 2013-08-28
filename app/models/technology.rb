# A Technology is a tag in StackOverflow.  
# Someday the set of Technologies here will likely diverge from SO, but for now they're the same.
class Technology
    include Mongoid::Document
    include Mongoid::Taggable
    include Mongoid::Timestamps
    include Mongoid::Versioning

    max_versions 1000  # Just to keep it from overflowing the mongo document

    field :_id, type: String  # the URL version of techtag, not URL-escaped.  a.k.a. slug
    field :name, type: String  # a friendly, printable name for the technology
    field :techtag, type: String  # the string used in SO for the tag.

    validates_presence_of :name, :techtag

    index({techtag: 1}, {background: true, unique: true})

    def slug
        self._id
    end

    def slug_esc
        Rack::Utils.escape( self.slug )
    end

    def to_param  # This method gives the PK to rails for URLs in resources.
        self.slug_esc
    end

    def self.slug_for_tag(tag)
        slug = tag.gsub(/[\/?]/,'_')
        #Rack::Utils.escape( slug )  # Don't store this in the data model.  This is a representation
    end


    # This will return Metatag objects that exist in the database.
    # If it's a tag that doesn't have a Metatag associated with it (e.g. pow4) then it doesn't come out here.
    def metatags
        self.tags.split(',').map do |tag|
            Metatag.find_by(tag: tag)
        end.compact
    end


    def appliable_metatags
        self.metatags.select do |mt|
            mt.user_appliable
        end
    end


    def primary_metatag
        self.appliable_metatags.first
    end


    def self.new_for_tag(tag)
        Technology.new do |t|
            t.techtag = tag
            t.name = tag.gsub("-"," ").titleize
            t._id = Technology.slug_for_tag(tag)
        end
    end
end
