require 'test_helper'

class WorkUnitCodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @work_unit_code = work_unit_codes(:one)
  end

  test "should get index" do
    get work_unit_codes_url
    assert_response :success
  end

  test "should get new" do
    get new_work_unit_code_url
    assert_response :success
  end

  test "should create work_unit_code" do
    assert_difference('WorkUnitCode.count') do
      post work_unit_codes_url, params: { work_unit_code: {  } }
    end

    assert_redirected_to work_unit_code_url(WorkUnitCode.last)
  end

  test "should show work_unit_code" do
    get work_unit_code_url(@work_unit_code)
    assert_response :success
  end

  test "should get edit" do
    get edit_work_unit_code_url(@work_unit_code)
    assert_response :success
  end

  test "should update work_unit_code" do
    patch work_unit_code_url(@work_unit_code), params: { work_unit_code: {  } }
    assert_redirected_to work_unit_code_url(@work_unit_code)
  end

  test "should destroy work_unit_code" do
    assert_difference('WorkUnitCode.count', -1) do
      delete work_unit_code_url(@work_unit_code)
    end

    assert_redirected_to work_unit_codes_url
  end
end
