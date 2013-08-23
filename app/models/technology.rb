class Technology
    include Mongoid::Document
    include Mongoid::Taggable

    field :_id, type: String
    field :name, type: String
    field :techtag, type: String

    validates_presence_of :name, :techtag

    index({techtag: 1}, {background: true, unique: true})
end
