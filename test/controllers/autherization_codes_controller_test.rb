require 'test_helper'

class AutherizationCodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @autherization_code = autherization_codes(:one)
  end

  test "should get index" do
    get autherization_codes_url
    assert_response :success
  end

  test "should get new" do
    get new_autherization_code_url
    assert_response :success
  end

  test "should create autherization_code" do
    assert_difference('AutherizationCode.count') do
      post autherization_codes_url, params: { autherization_code: {  } }
    end

    assert_redirected_to autherization_code_url(AutherizationCode.last)
  end

  test "should show autherization_code" do
    get autherization_code_url(@autherization_code)
    assert_response :success
  end

  test "should get edit" do
    get edit_autherization_code_url(@autherization_code)
    assert_response :success
  end

  test "should update autherization_code" do
    patch autherization_code_url(@autherization_code), params: { autherization_code: {  } }
    assert_redirected_to autherization_code_url(@autherization_code)
  end

  test "should destroy autherization_code" do
    assert_difference('AutherizationCode.count', -1) do
      delete autherization_code_url(@autherization_code)
    end

    assert_redirected_to autherization_codes_url
  end
end
