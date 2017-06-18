require 'test_helper'

class ChangesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @change = changes(:one)
  end

  test "should get index" do
    get changes_url
    assert_response :success
  end

  test "should get new" do
    get new_change_url
    assert_response :success
  end

  test "should create change" do
    assert_difference('Change.count') do
      post changes_url, params: { change: {  } }
    end

    assert_redirected_to change_url(Change.last)
  end

  test "should show change" do
    get change_url(@change)
    assert_response :success
  end

  test "should get edit" do
    get edit_change_url(@change)
    assert_response :success
  end

  test "should update change" do
    patch change_url(@change), params: { change: {  } }
    assert_redirected_to change_url(@change)
  end

  test "should destroy change" do
    assert_difference('Change.count', -1) do
      delete change_url(@change)
    end

    assert_redirected_to changes_url
  end
end
