class ComparisonsController < ApplicationController

  def versus
    @tech1 = Technology.find_by(techtag: params[:tag1])
    @tech2 = Technology.find_by(techtag: params[:tag2])

    if ! @tech1 or ! @tech2
        raise ActionController::RoutingError.new('Not Found')
    end
  end


end
