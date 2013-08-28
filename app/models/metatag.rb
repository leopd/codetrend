# a metatag Is a tag applied to a Technology.
# Use-applied tags help group related Technologies together.
class Metatag
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Versioning

    max_versions 1000 # To prevent it from overflowing the mongo document

    field :tag, type: String
    field :title, type: String
    field :description, type: String
    field :user_appliable, type: Boolean, default: true

    index({tag: 1}, {background: true, unique: true})
    index({user_appliable: 1, title: 1}, {background: true, unique: true})

    def slug
        self.tag
    end

    def slug_esc
        Rack::Utils.escape( self.slug )
    end

    def to_param  # This method gives the PK to rails for URLs in resources.
        self.slug_esc
    end


    def self.appliable_metatag_list
        Metatag.where({user_appliable: true}).map do |mt|
            mt.tag
        end
    end

end
