require 'test_helper'

class LimitationLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @limitation_log = limitation_logs(:one)
  end

  test "should get index" do
    get limitation_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_limitation_log_url
    assert_response :success
  end

  test "should create limitation_log" do
    assert_difference('LimitationLog.count') do
      post limitation_logs_url, params: { limitation_log: {  } }
    end

    assert_redirected_to limitation_log_url(LimitationLog.last)
  end

  test "should show limitation_log" do
    get limitation_log_url(@limitation_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_limitation_log_url(@limitation_log)
    assert_response :success
  end

  test "should update limitation_log" do
    patch limitation_log_url(@limitation_log), params: { limitation_log: {  } }
    assert_redirected_to limitation_log_url(@limitation_log)
  end

  test "should destroy limitation_log" do
    assert_difference('LimitationLog.count', -1) do
      delete limitation_log_url(@limitation_log)
    end

    assert_redirected_to limitation_logs_url
  end
end
