require 'test_helper'

class ScheduledInspectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @scheduled_inspection = scheduled_inspections(:one)
  end

  test "should get index" do
    get scheduled_inspections_url
    assert_response :success
  end

  test "should get new" do
    get new_scheduled_inspection_url
    assert_response :success
  end

  test "should create scheduled_inspection" do
    assert_difference('ScheduledInspection.count') do
      post scheduled_inspections_url, params: { scheduled_inspection: {  } }
    end

    assert_redirected_to scheduled_inspection_url(ScheduledInspection.last)
  end

  test "should show scheduled_inspection" do
    get scheduled_inspection_url(@scheduled_inspection)
    assert_response :success
  end

  test "should get edit" do
    get edit_scheduled_inspection_url(@scheduled_inspection)
    assert_response :success
  end

  test "should update scheduled_inspection" do
    patch scheduled_inspection_url(@scheduled_inspection), params: { scheduled_inspection: {  } }
    assert_redirected_to scheduled_inspection_url(@scheduled_inspection)
  end

  test "should destroy scheduled_inspection" do
    assert_difference('ScheduledInspection.count', -1) do
      delete scheduled_inspection_url(@scheduled_inspection)
    end

    assert_redirected_to scheduled_inspections_url
  end
end
