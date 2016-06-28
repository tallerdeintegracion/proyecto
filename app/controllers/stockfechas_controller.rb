class StockfechasController < ApplicationController
  before_action :set_stockfecha, only: [:show, :edit, :update, :destroy]

  # GET /stockfechas
  # GET /stockfechas.json
  def index
    @stockfechas = Stockfecha.all
  end

  # GET /stockfechas/1
  # GET /stockfechas/1.json
  def show
  end

  # GET /stockfechas/new
  def new
    @stockfecha = Stockfecha.new
  end

  # GET /stockfechas/1/edit
  def edit
  end

  # POST /stockfechas
  # POST /stockfechas.json
  def create
    @stockfecha = Stockfecha.new(stockfecha_params)

    respond_to do |format|
      if @stockfecha.save
        format.html { redirect_to @stockfecha, notice: 'Stockfecha was successfully created.' }
        format.json { render :show, status: :created, location: @stockfecha }
      else
        format.html { render :new }
        format.json { render json: @stockfecha.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stockfechas/1
  # PATCH/PUT /stockfechas/1.json
  def update
    respond_to do |format|
      if @stockfecha.update(stockfecha_params)
        format.html { redirect_to @stockfecha, notice: 'Stockfecha was successfully updated.' }
        format.json { render :show, status: :ok, location: @stockfecha }
      else
        format.html { render :edit }
        format.json { render json: @stockfecha.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stockfechas/1
  # DELETE /stockfechas/1.json
  def destroy
    @stockfecha.destroy
    respond_to do |format|
      format.html { redirect_to stockfechas_url, notice: 'Stockfecha was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stockfecha
      @stockfecha = Stockfecha.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stockfecha_params
      params.require(:stockfecha).permit(:fecha, :sku, :cantidad)
    end
end
