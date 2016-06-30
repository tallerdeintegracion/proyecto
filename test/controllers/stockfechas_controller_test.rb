require 'test_helper'

class StockfechasControllerTest < ActionController::TestCase
  setup do
    @stockfecha = stockfechas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stockfechas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stockfecha" do
    assert_difference('Stockfecha.count') do
      post :create, stockfecha: { cantidad: @stockfecha.cantidad, fecha: @stockfecha.fecha, sku: @stockfecha.sku }
    end

    assert_redirected_to stockfecha_path(assigns(:stockfecha))
  end

  test "should show stockfecha" do
    get :show, id: @stockfecha
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stockfecha
    assert_response :success
  end

  test "should update stockfecha" do
    patch :update, id: @stockfecha, stockfecha: { cantidad: @stockfecha.cantidad, fecha: @stockfecha.fecha, sku: @stockfecha.sku }
    assert_redirected_to stockfecha_path(assigns(:stockfecha))
  end

  test "should destroy stockfecha" do
    assert_difference('Stockfecha.count', -1) do
      delete :destroy, id: @stockfecha
    end

    assert_redirected_to stockfechas_path
  end
end
