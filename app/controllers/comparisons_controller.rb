class ComparisonsController < ApplicationController

  def versus
    @tech1 = Technology.find(params[:slug1])
    @tech2 = Technology.find(params[:slug2])

    if ! @tech1 or ! @tech2
        raise ActionController::RoutingError.new('Comparison object not found')
    end

    Comparison.increment_count_obj(@tech1, @tech2)
  end


  def search
    @tech1 = Technology.find(params[:slug1])
    if ! @tech1
        raise ActionController::RoutingError.new('Base technology not found')
    end
    #TODO: DRY this up with technologies#search action.
    @tech2 = Technology.find_by(techtag: params[:query]).strip

    if ! @tech2
        begin
            redirect_to :back, alert: "Technology '#{params[:query]}' not found"
        rescue ActionController::RedirectBackError
            raise ActionController::RoutingError.new('Compared technology not found')
        end
    else
        c = Comparison.new do |c|
            c.tag1 = @tech1.techtag
            c.tag2 = @tech2.techtag
        end
        redirect_to c.path
    end
  end

end
