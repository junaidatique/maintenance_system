require 'test_helper'

class RequestedToolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @requested_tool = requested_tools(:one)
  end

  test "should get index" do
    get requested_tools_url
    assert_response :success
  end

  test "should get new" do
    get new_requested_tool_url
    assert_response :success
  end

  test "should create requested_tool" do
    assert_difference('RequestedTool.count') do
      post requested_tools_url, params: { requested_tool: {  } }
    end

    assert_redirected_to requested_tool_url(RequestedTool.last)
  end

  test "should show requested_tool" do
    get requested_tool_url(@requested_tool)
    assert_response :success
  end

  test "should get edit" do
    get edit_requested_tool_url(@requested_tool)
    assert_response :success
  end

  test "should update requested_tool" do
    patch requested_tool_url(@requested_tool), params: { requested_tool: {  } }
    assert_redirected_to requested_tool_url(@requested_tool)
  end

  test "should destroy requested_tool" do
    assert_difference('RequestedTool.count', -1) do
      delete requested_tool_url(@requested_tool)
    end

    assert_redirected_to requested_tools_url
  end
end
