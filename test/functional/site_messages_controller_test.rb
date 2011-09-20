require 'test_helper'

class SiteMessagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:site_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create site_message" do
    assert_difference('SiteMessage.count') do
      post :create, :site_message => { }
    end

    assert_redirected_to site_message_path(assigns(:site_message))
  end

  test "should show site_message" do
    get :show, :id => site_messages(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => site_messages(:one).to_param
    assert_response :success
  end

  test "should update site_message" do
    put :update, :id => site_messages(:one).to_param, :site_message => { }
    assert_redirected_to site_message_path(assigns(:site_message))
  end

  test "should destroy site_message" do
    assert_difference('SiteMessage.count', -1) do
      delete :destroy, :id => site_messages(:one).to_param
    end

    assert_redirected_to site_messages_path
  end
end
