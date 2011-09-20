require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Tag.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Tag.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Tag.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to tag_url(assigns(:tag))
  end
  
  def test_edit
    get :edit, :id => Tag.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Tag.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Tag.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Tag.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Tag.first
    assert_redirected_to tag_url(assigns(:tag))
  end
  
  def test_destroy
    tag = Tag.first
    delete :destroy, :id => tag
    assert_redirected_to tags_url
    assert !Tag.exists?(tag.id)
  end
end
