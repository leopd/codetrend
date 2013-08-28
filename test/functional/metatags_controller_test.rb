require 'test_helper'

class MetatagsControllerTest < ActionController::TestCase
  setup do
    @metatag = metatags(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:metatags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create metatag" do
    assert_difference('Metatag.count') do
      post :create, metatag: { description: @metatag.description, tag: @metatag.tag }
    end

    assert_redirected_to metatag_path(assigns(:metatag))
  end

  test "should show metatag" do
    get :show, id: @metatag
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @metatag
    assert_response :success
  end

  test "should update metatag" do
    put :update, id: @metatag, metatag: { description: @metatag.description, tag: @metatag.tag }
    assert_redirected_to metatag_path(assigns(:metatag))
  end

  test "should destroy metatag" do
    assert_difference('Metatag.count', -1) do
      delete :destroy, id: @metatag
    end

    assert_redirected_to metatags_path
  end
end
