require File.dirname(__FILE__) + '/../test_helper'

class LeadsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:leads)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_lead
    assert_difference('Lead.count') do
      post :create, :lead => { }
    end

    assert_redirected_to lead_path(assigns(:lead))
  end

  def test_should_show_lead
    get :show, :id => leads(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => leads(:one).id
    assert_response :success
  end

  def test_should_update_lead
    put :update, :id => leads(:one).id, :lead => { }
    assert_redirected_to lead_path(assigns(:lead))
  end

  def test_should_destroy_lead
    assert_difference('Lead.count', -1) do
      delete :destroy, :id => leads(:one).id
    end

    assert_redirected_to leads_path
  end
end
