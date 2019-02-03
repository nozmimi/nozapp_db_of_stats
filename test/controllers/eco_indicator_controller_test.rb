require 'test_helper'

class EcoIndicatorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get eco_indicator_index_url
    assert_response :success
  end

end
