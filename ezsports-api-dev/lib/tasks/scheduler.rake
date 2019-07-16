desc "This task is called by the Heroku scheduler add-on"

task :send_reminders => :environment do
  test = EmailController.new
  test.set_game_reminders
end