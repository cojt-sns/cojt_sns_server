require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test 'should get new' do
    get posts_new_url
    assert_response :success
  end
end
