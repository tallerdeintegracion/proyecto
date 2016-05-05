require 'test_helper'

class SentOrdersControllerTest < ActionController::TestCase
  setup do
    @sent_order = sent_orders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sent_orders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sent_order" do
    assert_difference('SentOrder.count') do
      post :create, sent_order: { cantidad: @sent_order.cantidad, estado: @sent_order.estado, fechaEntrega: @sent_order.fechaEntrega, oc: @sent_order.oc, sku: @sent_order.sku }
    end

    assert_redirected_to sent_order_path(assigns(:sent_order))
  end

  test "should show sent_order" do
    get :show, id: @sent_order
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sent_order
    assert_response :success
  end

  test "should update sent_order" do
    patch :update, id: @sent_order, sent_order: { cantidad: @sent_order.cantidad, estado: @sent_order.estado, fechaEntrega: @sent_order.fechaEntrega, oc: @sent_order.oc, sku: @sent_order.sku }
    assert_redirected_to sent_order_path(assigns(:sent_order))
  end

  test "should destroy sent_order" do
    assert_difference('SentOrder.count', -1) do
      delete :destroy, id: @sent_order
    end

    assert_redirected_to sent_orders_path
  end
end
