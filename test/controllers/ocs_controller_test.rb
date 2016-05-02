require 'test_helper'

class OcsControllerTest < ActionController::TestCase
  setup do
    @oc = ocs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ocs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create oc" do
    assert_difference('Oc.count') do
      post :create, oc: { estados: @oc.estados, oc: @oc.oc }
    end

    assert_redirected_to oc_path(assigns(:oc))
  end

  test "should show oc" do
    get :show, id: @oc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @oc
    assert_response :success
  end

  test "should update oc" do
    patch :update, id: @oc, oc: { estados: @oc.estados, oc: @oc.oc }
    assert_redirected_to oc_path(assigns(:oc))
  end

  test "should destroy oc" do
    assert_difference('Oc.count', -1) do
      delete :destroy, id: @oc
    end

    assert_redirected_to ocs_path
  end
end
