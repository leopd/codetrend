class ComparisonsController < ApplicationController

  def versus
    @tech1 = Technology.find(params[:tag1])
    @tech2 = Technology.find(params[:tag2])

    if ! @tech1 or ! @tech2
        raise ActionController::RoutingError.new('Not Found')
    end

    Comparison.increment_count(@tech1, @tech2)
  end


end
