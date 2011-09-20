require 'test_helper'

class TopTagsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => TopTag.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    TopTag.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    TopTag.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to top_tag_url(assigns(:top_tag))
  end
  
  def test_edit
    get :edit, :id => TopTag.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    TopTag.any_instance.stubs(:valid?).returns(false)
    put :update, :id => TopTag.first
    assert_template 'edit'
  end
  
  def test_update_valid
    TopTag.any_instance.stubs(:valid?).returns(true)
    put :update, :id => TopTag.first
    assert_redirected_to top_tag_url(assigns(:top_tag))
  end
  
  def test_destroy
    top_tag = TopTag.first
    delete :destroy, :id => top_tag
    assert_redirected_to top_tags_url
    assert !TopTag.exists?(top_tag.id)
  end
end
