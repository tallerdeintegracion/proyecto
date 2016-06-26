require 'test_helper'

class SaldosControllerTest < ActionController::TestCase
  setup do
    @saldo = saldos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:saldos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create saldo" do
    assert_difference('Saldo.count') do
      post :create, saldo: { fecha: @saldo.fecha, monto: @saldo.monto }
    end

    assert_redirected_to saldo_path(assigns(:saldo))
  end

  test "should show saldo" do
    get :show, id: @saldo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @saldo
    assert_response :success
  end

  test "should update saldo" do
    patch :update, id: @saldo, saldo: { fecha: @saldo.fecha, monto: @saldo.monto }
    assert_redirected_to saldo_path(assigns(:saldo))
  end

  test "should destroy saldo" do
    assert_difference('Saldo.count', -1) do
      delete :destroy, id: @saldo
    end

    assert_redirected_to saldos_path
  end
end
