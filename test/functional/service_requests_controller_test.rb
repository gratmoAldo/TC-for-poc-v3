require 'test_helper'

class ServiceRequestsControllerTest < ActionController::TestCase
  test "should get index" do
    puts "getting SR index ######################################################"
    get :index
    assert_response :success
    assert_not_nil assigns(:service_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service_request" do
    assert_difference('ServiceRequest.count') do
      post :create, :service_request => { }
    end

    assert_redirected_to service_request_path(assigns(:service_request))
  end

  test "should show service_request" do
    get :show, :id => service_requests(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => service_requests(:one).to_param
    assert_response :success
  end

  test "should update service_request" do
    put :update, :id => service_requests(:one).to_param, :service_request => { }
    assert_redirected_to service_request_path(assigns(:service_request))
  end

  test "should destroy service_request" do
    assert_difference('ServiceRequest.count', -1) do
      delete :destroy, :id => service_requests(:one).to_param
    end

    assert_redirected_to service_requests_path
  end
end
