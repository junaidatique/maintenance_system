require 'test_helper'

class AddlLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @addl_log = addl_logs(:one)
  end

  test "should get index" do
    get addl_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_addl_log_url
    assert_response :success
  end

  test "should create addl_log" do
    assert_difference('AddlLog.count') do
      post addl_logs_url, params: { addl_log: {  } }
    end

    assert_redirected_to addl_log_url(AddlLog.last)
  end

  test "should show addl_log" do
    get addl_log_url(@addl_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_addl_log_url(@addl_log)
    assert_response :success
  end

  test "should update addl_log" do
    patch addl_log_url(@addl_log), params: { addl_log: {  } }
    assert_redirected_to addl_log_url(@addl_log)
  end

  test "should destroy addl_log" do
    assert_difference('AddlLog.count', -1) do
      delete addl_log_url(@addl_log)
    end

    assert_redirected_to addl_logs_url
  end
end
