require 'test_helper'

class InboxSrsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:inbox_srs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create inbox_sr" do
    assert_difference('InboxSr.count') do
      post :create, :inbox_sr => { }
    end

    assert_redirected_to inbox_sr_path(assigns(:inbox_sr))
  end

  test "should show inbox_sr" do
    get :show, :id => inbox_srs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => inbox_srs(:one).to_param
    assert_response :success
  end

  test "should update inbox_sr" do
    put :update, :id => inbox_srs(:one).to_param, :inbox_sr => { }
    assert_redirected_to inbox_sr_path(assigns(:inbox_sr))
  end

  test "should destroy inbox_sr" do
    assert_difference('InboxSr.count', -1) do
      delete :destroy, :id => inbox_srs(:one).to_param
    end

    assert_redirected_to inbox_srs_path
  end
end
