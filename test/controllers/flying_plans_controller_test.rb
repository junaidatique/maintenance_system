require 'test_helper'

class FlyingPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @flying_plan = flying_plans(:one)
  end

  test "should get index" do
    get flying_plans_url
    assert_response :success
  end

  test "should get new" do
    get new_flying_plan_url
    assert_response :success
  end

  test "should create flying_plan" do
    assert_difference('FlyingPlan.count') do
      post flying_plans_url, params: { flying_plan: { aircraft_id: @flying_plan.aircraft_id, flying_date: @flying_plan.flying_date } }
    end

    assert_redirected_to flying_plan_url(FlyingPlan.last)
  end

  test "should show flying_plan" do
    get flying_plan_url(@flying_plan)
    assert_response :success
  end

  test "should get edit" do
    get edit_flying_plan_url(@flying_plan)
    assert_response :success
  end

  test "should update flying_plan" do
    patch flying_plan_url(@flying_plan), params: { flying_plan: { aircraft_id: @flying_plan.aircraft_id, flying_date: @flying_plan.flying_date } }
    assert_redirected_to flying_plan_url(@flying_plan)
  end

  test "should destroy flying_plan" do
    assert_difference('FlyingPlan.count', -1) do
      delete flying_plan_url(@flying_plan)
    end

    assert_redirected_to flying_plans_url
  end
end
