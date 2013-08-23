class Technology
    include Mongoid::Document

    field :_id, type: String
    field :name, type: String
    field :techtag, type: String

    validates_presence_of :name, :techtag

    index({techtag: 1}, {background: true, unique: true})

    def self.new_for_techtag(tag)
        Technology.new do |t|
            t.techtag = tag
            t.name = tag.gsub("-"," ").titleize
            t._id = tag.gsub(/[^a-zA-Z0-9\-]/,'_')
        end
    end
end
