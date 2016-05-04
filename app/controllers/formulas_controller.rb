class FormulasController < ApplicationController
  before_action :set_formula, only: [:show, :edit, :update, :destroy]

  # GET /formulas
  # GET /formulas.json
  def index
    @formulas = Formula.all
  end

  # GET /formulas/1
  # GET /formulas/1.json
  def show
  end

  # GET /formulas/new
  def new
    @formula = Formula.new
  end

  # GET /formulas/1/edit
  def edit
  end

  # POST /formulas
  # POST /formulas.json
  def create
    @formula = Formula.new(formula_params)

    respond_to do |format|
      if @formula.save
        format.html { redirect_to @formula, notice: 'Formula was successfully created.' }
        format.json { render :show, status: :created, location: @formula }
      else
        format.html { render :new }
        format.json { render json: @formula.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /formulas/1
  # PATCH/PUT /formulas/1.json
  def update
    respond_to do |format|
      if @formula.update(formula_params)
        format.html { redirect_to @formula, notice: 'Formula was successfully updated.' }
        format.json { render :show, status: :ok, location: @formula }
      else
        format.html { render :edit }
        format.json { render json: @formula.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /formulas/1
  # DELETE /formulas/1.json
  def destroy
    @formula.destroy
    respond_to do |format|
      format.html { redirect_to formulas_url, notice: 'Formula was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_formula
      @formula = Formula.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def formula_params
      params.require(:formula).permit(:sku, :descripcion, :lote, :unidad, :skuIngerdiente, :ingrediente, :requerimiento, :unidadIngrediente, :precioIngrediente)
    end
end
