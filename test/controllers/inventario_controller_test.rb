require 'test_helper'

class InventarioControllerTest < ActionController::TestCase
  test "should get run" do
    get :run
    assert_response :success
  end

end
