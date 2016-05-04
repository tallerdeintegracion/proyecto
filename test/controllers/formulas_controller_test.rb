require 'test_helper'

class FormulasControllerTest < ActionController::TestCase
  setup do
    @formula = formulas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:formulas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create formula" do
    assert_difference('Formula.count') do
      post :create, formula: { descripcion: @formula.descripcion, ingrediente: @formula.ingrediente, lote: @formula.lote, precioIngrediente: @formula.precioIngrediente, requerimiento: @formula.requerimiento, sku: @formula.sku, skuIngerdiente: @formula.skuIngerdiente, unidad: @formula.unidad, unidadIngrediente: @formula.unidadIngrediente }
    end

    assert_redirected_to formula_path(assigns(:formula))
  end

  test "should show formula" do
    get :show, id: @formula
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @formula
    assert_response :success
  end

  test "should update formula" do
    patch :update, id: @formula, formula: { descripcion: @formula.descripcion, ingrediente: @formula.ingrediente, lote: @formula.lote, precioIngrediente: @formula.precioIngrediente, requerimiento: @formula.requerimiento, sku: @formula.sku, skuIngerdiente: @formula.skuIngerdiente, unidad: @formula.unidad, unidadIngrediente: @formula.unidadIngrediente }
    assert_redirected_to formula_path(assigns(:formula))
  end

  test "should destroy formula" do
    assert_difference('Formula.count', -1) do
      delete :destroy, id: @formula
    end

    assert_redirected_to formulas_path
  end
end
