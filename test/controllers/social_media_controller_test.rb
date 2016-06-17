require 'test_helper'

class SocialMediaControllerTest < ActionController::TestCase
  setup do
    @social_medium = social_media(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:social_media)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create social_medium" do
    assert_difference('SocialMedium.count') do
      post :create, social_medium: {  }
    end

    assert_redirected_to social_medium_path(assigns(:social_medium))
  end

  test "should show social_medium" do
    get :show, id: @social_medium
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @social_medium
    assert_response :success
  end

  test "should update social_medium" do
    patch :update, id: @social_medium, social_medium: {  }
    assert_redirected_to social_medium_path(assigns(:social_medium))
  end

  test "should destroy social_medium" do
    assert_difference('SocialMedium.count', -1) do
      delete :destroy, id: @social_medium
    end

    assert_redirected_to social_media_path
  end
end
