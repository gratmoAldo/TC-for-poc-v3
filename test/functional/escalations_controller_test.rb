require 'test_helper'

class EscalationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:escalations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create escalation" do
    assert_difference('Escalation.count') do
      post :create, :escalation => { }
    end

    assert_redirected_to escalation_path(assigns(:escalation))
  end

  test "should show escalation" do
    get :show, :id => escalations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => escalations(:one).to_param
    assert_response :success
  end

  test "should update escalation" do
    put :update, :id => escalations(:one).to_param, :escalation => { }
    assert_redirected_to escalation_path(assigns(:escalation))
  end

  test "should destroy escalation" do
    assert_difference('Escalation.count', -1) do
      delete :destroy, :id => escalations(:one).to_param
    end

    assert_redirected_to escalations_path
  end
end
