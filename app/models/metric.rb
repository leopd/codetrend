
class Metric
    include Mongoid::Document

    field :dataset, type: String
    field :techtag, type: String
    field :val, type: Integer
    field :day, type: Date

    validates_presence_of :dataset, :techtag, :val, :day

    index({dataset: 1, techtag: 1}, {background: true})
end
