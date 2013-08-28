# a metatag Is a tag applied to a Technology.
# Use-applied tags help group related Technologies together.
class Metatag
    include Mongoid::Document

    field :tag, type: String
    field :description, type: String

    index({tag: 1}, {background: true, unique: true})

    def slug
        self._id
    end

    def slug_esc
        Rack::Utils.escape( self.slug )
    end

    def to_param  # This method gives the PK to rails for URLs in resources.
        self.slug_esc
    end
end
