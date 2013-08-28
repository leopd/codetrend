class MetatagsController < ApplicationController
  # GET /metatags
  # GET /metatags.json
  def index
    @metatags = Metatag.all.order_by(tag: 1)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @metatags }
    end
  end

  # GET /metatags/1
  # GET /metatags/1.json
  def show
    @metatag = Metatag.find_by(tag: params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @metatag }
    end
  end

  # GET /metatags/new
  # GET /metatags/new.json
  def new
    @metatag = Metatag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @metatag }
    end
  end

  # GET /metatags/1/edit
  def edit
    @metatag = Metatag.find_by(tag: params[:id])
  end

  # POST /metatags
  # POST /metatags.json
  def create
    @metatag = Metatag.new(params[:metatag])

    respond_to do |format|
      if @metatag.save
        format.html { redirect_to @metatag, notice: 'Metatag was successfully created.' }
        format.json { render json: @metatag, status: :created, location: @metatag }
      else
        format.html { render action: "new" }
        format.json { render json: @metatag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /metatags/1
  # PUT /metatags/1.json
  def update
    @metatag = Metatag.find_by(tag: params[:id])

    respond_to do |format|
      if @metatag.update_attributes(params[:metatag])
        format.html { redirect_to @metatag, notice: 'Metatag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @metatag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metatags/1
  # DELETE /metatags/1.json
  def destroy
    @metatag = Metatag.find_by(tag: params[:id])
    @metatag.destroy

    respond_to do |format|
      format.html { redirect_to metatags_url }
      format.json { head :no_content }
    end
  end
end
