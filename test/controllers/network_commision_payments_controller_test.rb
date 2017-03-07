require 'test_helper'

class NetworkCommisionPaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get network_commision_payments_index_url
    assert_response :success
  end

  test "should get new" do
    get network_commision_payments_new_url
    assert_response :success
  end

end
