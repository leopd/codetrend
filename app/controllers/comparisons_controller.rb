class ComparisonsController < ApplicationController

  def versus
    @tech1 = Technology.find(params[:tag1])
    @tech2 = Technology.find(params[:tag2])

    if ! @tech1 or ! @tech2
        raise ActionController::RoutingError.new('Not Found')
    end

    Comparison.increment_count_obj(@tech1, @tech2)
  end


  def search
    @tech1 = Technology.find(params[:tag1])
    if ! @tech1
        raise ActionController::RoutingError.new('Not found')
    end
    @tech2 = Technology.find_by(techtag: params[:query])

    if ! @tech2
        begin
            redirect_to :back, alert: "Technology '#{params[:query]}' not found"
        rescue ActionController::RedirectBackError
            raise ActionController::RoutingError.new('Not found')
        end
    else
        redirect_to "/compare/#{@tech1._id}/vs/#{@tech2._id}"
    end
  end

end
