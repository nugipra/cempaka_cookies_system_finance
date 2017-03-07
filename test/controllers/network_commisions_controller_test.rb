require 'test_helper'

class NetworkCommisionsControllerTest < ActionDispatch::IntegrationTest
  test "should get unpaid" do
    get network_commisions_unpaid_url
    assert_response :success
  end

end
