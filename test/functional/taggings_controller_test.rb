require 'test_helper'

class TaggingsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Tagging.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Tagging.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Tagging.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to tagging_url(assigns(:tagging))
  end
  
  def test_edit
    get :edit, :id => Tagging.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Tagging.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Tagging.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Tagging.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Tagging.first
    assert_redirected_to tagging_url(assigns(:tagging))
  end
  
  def test_destroy
    tagging = Tagging.first
    delete :destroy, :id => tagging
    assert_redirected_to taggings_url
    assert !Tagging.exists?(tagging.id)
  end
end
