require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get inventarioConsultar" do
    get :inventarioConsultar
    assert_response :success
  end

  test "should get facturarRecibir" do
    get :facturarRecibir
    assert_response :success
  end

  test "should get pagoRecibir" do
    get :pagoRecibir
    assert_response :success
  end

  test "should get ocRecibir" do
    get :ocRecibir
    assert_response :success
  end

end
