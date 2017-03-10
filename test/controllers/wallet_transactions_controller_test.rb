require 'test_helper'

class WalletTransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get wallet_transactions_index_url
    assert_response :success
  end

  test "should get new" do
    get wallet_transactions_new_url
    assert_response :success
  end

end
