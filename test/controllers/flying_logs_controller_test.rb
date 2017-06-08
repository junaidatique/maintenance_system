require 'test_helper'

class FlyingLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @flying_log = flying_logs(:one)
  end

  test "should get index" do
    get flying_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_flying_log_url
    assert_response :success
  end

  test "should create flying_log" do
    assert_difference('FlyingLog.count') do
      post flying_logs_url, params: { flying_log: {  } }
    end

    assert_redirected_to flying_log_url(FlyingLog.last)
  end

  test "should show flying_log" do
    get flying_log_url(@flying_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_flying_log_url(@flying_log)
    assert_response :success
  end

  test "should update flying_log" do
    patch flying_log_url(@flying_log), params: { flying_log: {  } }
    assert_redirected_to flying_log_url(@flying_log)
  end

  test "should destroy flying_log" do
    assert_difference('FlyingLog.count', -1) do
      delete flying_log_url(@flying_log)
    end

    assert_redirected_to flying_logs_url
  end
end
