require 'test_helper'

class SkusControllerTest < ActionController::TestCase
  setup do
    @sku = skus(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:skus)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sku" do
    assert_difference('Sku.count') do
      post :create, sku: { costoUnitario: @sku.costoUnitario, descripcion: @sku.descripcion, grupoProyecto: @sku.grupoProyecto, loteProduccion: @sku.loteProduccion, reservado: @sku.reservado, sku: @sku.sku, tiempoProduccion: @sku.tiempoProduccion, tipo: @sku.tipo }
    end

    assert_redirected_to sku_path(assigns(:sku))
  end

  test "should show sku" do
    get :show, id: @sku
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sku
    assert_response :success
  end

  test "should update sku" do
    patch :update, id: @sku, sku: { costoUnitario: @sku.costoUnitario, descripcion: @sku.descripcion, grupoProyecto: @sku.grupoProyecto, loteProduccion: @sku.loteProduccion, reservado: @sku.reservado, sku: @sku.sku, tiempoProduccion: @sku.tiempoProduccion, tipo: @sku.tipo }
    assert_redirected_to sku_path(assigns(:sku))
  end

  test "should destroy sku" do
    assert_difference('Sku.count', -1) do
      delete :destroy, id: @sku
    end

    assert_redirected_to skus_path
  end
end
