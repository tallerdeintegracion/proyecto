class BoletaController < ApplicationController
  before_action :set_boletum, only: [:show, :edit, :update, :destroy]

  # GET /boleta
  # GET /boleta.json
  def index
    @boleta = Boletum.all
  end

  # GET /boleta/1
  # GET /boleta/1.json
  def show
  end

  # GET /boleta/new
  def new
    @boletum = Boletum.new
  end

  # GET /boleta/1/edit
  def edit
  end

  # POST /boleta
  # POST /boleta.json
  def create
    @boletum = Boletum.new(boletum_params)

    respond_to do |format|
      if @boletum.save
        format.html { redirect_to @boletum, notice: 'Boletum was successfully created.' }
        format.json { render :show, status: :created, location: @boletum }
      else
        format.html { render :new }
        format.json { render json: @boletum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /boleta/1
  # PATCH/PUT /boleta/1.json
  def update
    respond_to do |format|
      if @boletum.update(boletum_params)
        format.html { redirect_to @boletum, notice: 'Boletum was successfully updated.' }
        format.json { render :show, status: :ok, location: @boletum }
      else
        format.html { render :edit }
        format.json { render json: @boletum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boleta/1
  # DELETE /boleta/1.json
  def destroy
    @boletum.destroy
    respond_to do |format|
      format.html { redirect_to boleta_url, notice: 'Boletum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_boletum
      @boletum = Boletum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def boletum_params
      params.require(:boletum).permit(:boleta_id, :orden_id, :estado, :total)
    end
end
