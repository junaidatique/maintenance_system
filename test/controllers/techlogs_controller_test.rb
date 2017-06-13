require 'test_helper'

class TechlogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @techlog = techlogs(:one)
  end

  test "should get index" do
    get techlogs_url
    assert_response :success
  end

  test "should get new" do
    get new_techlog_url
    assert_response :success
  end

  test "should create techlog" do
    assert_difference('Techlog.count') do
      post techlogs_url, params: { techlog: {  } }
    end

    assert_redirected_to techlog_url(Techlog.last)
  end

  test "should show techlog" do
    get techlog_url(@techlog)
    assert_response :success
  end

  test "should get edit" do
    get edit_techlog_url(@techlog)
    assert_response :success
  end

  test "should update techlog" do
    patch techlog_url(@techlog), params: { techlog: {  } }
    assert_redirected_to techlog_url(@techlog)
  end

  test "should destroy techlog" do
    assert_difference('Techlog.count', -1) do
      delete techlog_url(@techlog)
    end

    assert_redirected_to techlogs_url
  end
end
