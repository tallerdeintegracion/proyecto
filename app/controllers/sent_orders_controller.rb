class SentOrdersController < ApplicationController
  before_action :set_sent_order, only: [:show, :edit, :update, :destroy]

  # GET /sent_orders
  # GET /sent_orders.json
  def index
    @sent_orders = SentOrder.all
  end

  # GET /sent_orders/1
  # GET /sent_orders/1.json
  def show
  end

  # GET /sent_orders/new
  def new
    @sent_order = SentOrder.new
  end

  # GET /sent_orders/1/edit
  def edit
  end

  # POST /sent_orders
  # POST /sent_orders.json
  def create
    @sent_order = SentOrder.new(sent_order_params)

    respond_to do |format|
      if @sent_order.save
        format.html { redirect_to @sent_order, notice: 'Sent order was successfully created.' }
        format.json { render :show, status: :created, location: @sent_order }
      else
        format.html { render :new }
        format.json { render json: @sent_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sent_orders/1
  # PATCH/PUT /sent_orders/1.json
  def update
    respond_to do |format|
      if @sent_order.update(sent_order_params)
        format.html { redirect_to @sent_order, notice: 'Sent order was successfully updated.' }
        format.json { render :show, status: :ok, location: @sent_order }
      else
        format.html { render :edit }
        format.json { render json: @sent_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sent_orders/1
  # DELETE /sent_orders/1.json
  def destroy
    @sent_order.destroy
    respond_to do |format|
      format.html { redirect_to sent_orders_url, notice: 'Sent order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sent_order
      @sent_order = SentOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sent_order_params
      params.require(:sent_order).permit(:oc, :sku, :cantidad, :estado, :fechaEntrega)
    end
end
