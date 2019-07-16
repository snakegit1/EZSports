require 'test_helper'

class GameSchedulesControllerTest < ActionController::TestCase
  setup do
    @game_schedule = game_schedules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:game_schedules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game_schedule" do
    assert_difference('GameSchedule.count') do
      post :create, game_schedule: { away_id: @game_schedule.away_id, home_id: @game_schedule.home_id, time: @game_schedule.time, venue_id: @game_schedule.venue_id }
    end

    assert_redirected_to game_schedule_path(assigns(:game_schedule))
  end

  test "should show game_schedule" do
    get :show, id: @game_schedule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @game_schedule
    assert_response :success
  end

  test "should update game_schedule" do
    patch :update, id: @game_schedule, game_schedule: { away_id: @game_schedule.away_id, home_id: @game_schedule.home_id, time: @game_schedule.time, venue_id: @game_schedule.venue_id }
    assert_redirected_to game_schedule_path(assigns(:game_schedule))
  end

  test "should destroy game_schedule" do
    assert_difference('GameSchedule.count', -1) do
      delete :destroy, id: @game_schedule
    end

    assert_redirected_to game_schedules_path
  end
end
