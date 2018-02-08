require 'test_helper'

class NonFlyingDaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @non_flying_day = non_flying_days(:one)
  end

  test "should get index" do
    get non_flying_days_url
    assert_response :success
  end

  test "should get new" do
    get new_non_flying_day_url
    assert_response :success
  end

  test "should create non_flying_day" do
    assert_difference('NonFlyingDay.count') do
      post non_flying_days_url, params: { non_flying_day: {  } }
    end

    assert_redirected_to non_flying_day_url(NonFlyingDay.last)
  end

  test "should show non_flying_day" do
    get non_flying_day_url(@non_flying_day)
    assert_response :success
  end

  test "should get edit" do
    get edit_non_flying_day_url(@non_flying_day)
    assert_response :success
  end

  test "should update non_flying_day" do
    patch non_flying_day_url(@non_flying_day), params: { non_flying_day: {  } }
    assert_redirected_to non_flying_day_url(@non_flying_day)
  end

  test "should destroy non_flying_day" do
    assert_difference('NonFlyingDay.count', -1) do
      delete non_flying_day_url(@non_flying_day)
    end

    assert_redirected_to non_flying_days_url
  end
end
