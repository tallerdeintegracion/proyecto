require 'test_helper'

class ReceiveOrdersControllerTest < ActionController::TestCase
  test "should get receive" do
    get :receive
    assert_response :success
  end

end
