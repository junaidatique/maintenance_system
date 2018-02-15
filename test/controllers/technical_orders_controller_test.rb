require 'test_helper'

class TechnicalOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @technical_order = technical_orders(:one)
  end

  test "should get index" do
    get technical_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_technical_order_url
    assert_response :success
  end

  test "should create technical_order" do
    assert_difference('TechnicalOrder.count') do
      post technical_orders_url, params: { technical_order: {  } }
    end

    assert_redirected_to technical_order_url(TechnicalOrder.last)
  end

  test "should show technical_order" do
    get technical_order_url(@technical_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_technical_order_url(@technical_order)
    assert_response :success
  end

  test "should update technical_order" do
    patch technical_order_url(@technical_order), params: { technical_order: {  } }
    assert_redirected_to technical_order_url(@technical_order)
  end

  test "should destroy technical_order" do
    assert_difference('TechnicalOrder.count', -1) do
      delete technical_order_url(@technical_order)
    end

    assert_redirected_to technical_orders_url
  end
end
