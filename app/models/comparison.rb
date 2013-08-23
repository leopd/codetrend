class Comparison
    include Mongoid::Document

    field :tag1, type: String
    field :tag2, type: String

    field :count, type: Integer

    index({tag1: 1, tag2: 1}, {background: true, unique: true})
end
