class WelcomeController < ApplicationController
  def index
    @comparisons = Comparison.all.order_by({count: -1}).limit(30).map do |c|
        if c.forward?
            c
        end
    end.compact
  end
end
