require 'test_helper'

class UserRostersControllerTest < ActionController::TestCase
  setup do
    @user_roster = user_rosters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_rosters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_roster" do
    assert_difference('UserRoster.count') do
      post :create, user_roster: { roster_id: @user_roster.roster_id, user_id: @user_roster.user_id }
    end

    assert_redirected_to user_roster_path(assigns(:user_roster))
  end

  test "should show user_roster" do
    get :show, id: @user_roster
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_roster
    assert_response :success
  end

  test "should update user_roster" do
    patch :update, id: @user_roster, user_roster: { roster_id: @user_roster.roster_id, user_id: @user_roster.user_id }
    assert_redirected_to user_roster_path(assigns(:user_roster))
  end

  test "should destroy user_roster" do
    assert_difference('UserRoster.count', -1) do
      delete :destroy, id: @user_roster
    end

    assert_redirected_to user_rosters_path
  end
end
