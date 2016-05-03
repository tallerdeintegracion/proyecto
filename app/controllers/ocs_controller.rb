class OcsController < ApplicationController
  before_action :set_oc, only: [:show, :edit, :update, :destroy]

  # GET /ocs
  # GET /ocs.json
  def index
    @ocs = Oc.all
  end

  # GET /ocs/1
  # GET /ocs/1.json
  def show
  end

  # GET /ocs/new
  def new
    @oc = Oc.new
  end

  # GET /ocs/1/edit
  def edit
  end

  # POST /ocs
  # POST /ocs.json
  def create
    @oc = Oc.new(oc_params)

    respond_to do |format|
      if @oc.save
        format.html { redirect_to @oc, notice: 'Oc was successfully created.' }
        format.json { render :show, status: :created, location: @oc }
      else
        format.html { render :new }
        format.json { render json: @oc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ocs/1
  # PATCH/PUT /ocs/1.json
  def update
    respond_to do |format|
      if @oc.update(oc_params)
        format.html { redirect_to @oc, notice: 'Oc was successfully updated.' }
        format.json { render :show, status: :ok, location: @oc }
      else
        format.html { render :edit }
        format.json { render json: @oc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ocs/1
  # DELETE /ocs/1.json
  def destroy
    @oc.destroy
    respond_to do |format|
      format.html { redirect_to ocs_url, notice: 'Oc was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_oc
      @oc = Oc.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def oc_params
      params.require(:oc).permit(:oc, :estados)
    end
end
