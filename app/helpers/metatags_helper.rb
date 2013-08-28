module MetatagsHelper

    def appliable_metatags_select
        Metatag.where({user_appliable: true}).order_by({title: 1}).map do |mt|
            [mt.title, mt.tag]
        end
    end
end
