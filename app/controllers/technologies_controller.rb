class TechnologiesController < ApplicationController
  # GET /technologies
  # GET /technologies.json
  def index
    if params[:all]
        @technologies = Technology.all
        @description = "All"
    else
        if params[:tag]
            @technologies = Technology.tagged_with(params[:tag])
            @description = params[:tag]
        else
            @technologies = Technology.tagged_with('pow4')
            @description = "Popular"
        end
    end
    @technologies = @technologies.order_by(techtag: 1).page(params[:page]).per(30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @technologies }
    end
  end

  # GET /technologies/1
  # GET /technologies/1.json
  def show
    @technology = Technology.find(params[:id])
    if @technology.nil?
        raise ActionController::RoutingError.new('Technology not found')
    end
    @comparisons = best_comparisons_for(@technology)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @technology }
    end
  end


  # GET /tag/java
  # GET /tag/java.json
  def bytechtag
    @technology = Technology.find_by(techtag: params[:techtag])

    respond_to do |format|
      format.html { render :show }
      format.json { render json: @technology }
    end
  end

  
  def applymetatag
    @technology = Technology.find_by(techtag: params[:id])
    @metatag = Metatag.find_by(tag: params[:metatag])
    if ! @metatag
        raise ActionController::RoutingError.new('Metatag not found')
    end
    @technology.tags_array.push( @metatag.tag ) # This would be easier if I was following mongo conventions
    @technology.save!
    redirect_to @technology, notice: 'Technology categorized. Thanks for contributing!'
  end


  # GET /technologies/new
  # GET /technologies/new.json
  def new
    @technology = Technology.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @technology }
    end
  end


  def metrics
    @technology = Technology.find(params[:id])
    @metrics = Metric.where(techtag: @technology.techtag).order_by(day: 1)
    render json: @metrics
    if Rails.env == "production"
        expires_in 2.days, :public => true
    end
  end


  def search
    #TODO: This search needs to be totally redone to include stemming and partials, etc.
    @query = params[:query].strip!
    @technology = Technology.find_by(techtag: @query)
    if @technology
        # We found it!
        redirect_to @technology
    else
        if @query.length > 0
            flash[:alert] = "No technology found by the name of '#{@query}'."
        else
            flash[:notice] = "You must enter a search term."
        end
        begin
            redirect_to :back
        rescue ActionController::RedirectBackError
            redirect_to root_path
        end
    end
  end


  # GET /technologies/1/edit
  def edit
    @technology = Technology.find(params[:id])
  end

  # POST /technologies
  # POST /technologies.json
  def create
    @technology = Technology.new(params[:technology])

    respond_to do |format|
      if @technology.save
        format.html { redirect_to @technology, notice: 'Technology was successfully created.' }
        format.json { render json: @technology, status: :created, location: @technology }
      else
        format.html { render action: "new" }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /technologies/1
  # PUT /technologies/1.json
  def update
    @technology = Technology.find(params[:id])

    respond_to do |format|
      if @technology.update_attributes(params[:technology])
        format.html { redirect_to @technology, notice: 'Technology was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /technologies/1
  # DELETE /technologies/1.json
  def destroy
    @technology = Technology.find(params[:id])
    @technology.destroy

    respond_to do |format|
      format.html { redirect_to technologies_url }
      format.json { head :no_content }
    end
  end

  protected
    def best_comparisons_for(technology)
        result = Comparison.top_for(technology)  # start with most popular
        if technology.primary_metatag
            similar_techs = technology.primary_metatag.technologies.select do |t|
                t != technology  # Remove self from list
            end
            comparisons_to_similar = similar_techs.map do |similar_tech|
                Comparison.find_or_create_by(tag1: technology.techtag, tag2: similar_tech.techtag)
            end
            result.concat(comparisons_to_similar)
            result = result.uniq
        end
        result
    end
end
