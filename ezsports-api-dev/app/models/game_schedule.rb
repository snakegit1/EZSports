class GameSchedule < ActiveRecord::Base

  TYPES = ['Game', 'Practice', 'Scrimmage', 'Pre-Season Game', 'Post-Season Game', 'Team Meeting', 'Parent Meeting', 'Fundraiser'] 

  validates_presence_of :league_id, :schedule_type, :time

  validate :valid_schedule_type
  validate :home_and_away_not_same
  validate :past_date, :unless => Proc.new { |game| game.time.blank? }
  validate :duplicate, :unless => Proc.new { |game| game.time.blank? }
  validate :home_team
  validate :away_team
  validate :venue

  def info

    collect = {
      id: id,
      home: Team.where('id =' + home_id.to_s).first,
      away: Team.where('id = ' + away_id.to_s).first,
      venue: Venue.where('id = ' + venue_id.to_s).first,
      time: time,
      schedule_type: schedule_type,
      league_id: league_id
    }
    
    return collect
  end

  def self.upload(file, league_id)
    count  = 0
    errors_array = []

    return count unless file
    schedules(file).each_with_index do |row, index|

    row = {
        home_id:       Team.where("lower(name) = lower(?)", row['Home'].try(:strip)).first.try(:id),
        away_id:       Team.where("lower(name) = lower(?)", row['Away'].try(:strip)).first.try(:id), 
        time:          Chronic.parse(row['Date/Time'].try(:strip)),
        venue_id:      Venue.where("lower(name) = lower(?)", row['Venue'].try(:strip)).first.try(:id), 
        schedule_type: row['Type'].blank? ? 'Game' : row['Type'].try(:strip),
        league_id:     league_id
      }

      game = GameSchedule.new(row)

      if game.save
        count += 1
      else
        errors_array << "Row #{index + 1}: #{game.errors.full_messages.join(',')}"
      end
    end

    return count, errors_array
  end

  def self.schedules(file)
    CSV.parse(File.read(File.expand_path(file.path, __FILE__)), :headers => true).map(&:to_h)
  end

  def self.sample_csv_path
    "#{Rails.root}/public/sample_schedules.csv"
  end

  private

  def past_date
    errors.add(:time, "Past date") if time.utc < DateTime.now.utc
  end

  def valid_schedule_type
    errors.add(:schedule_type, "is not valid") unless TYPES.map(&:downcase).include? schedule_type.try(:downcase)
  end

  def duplicate
    errors.add(:base, "Duplicate schedule") if GameSchedule.where("CAST(time AS DATE) = ? AND home_id = ? AND away_id = ? AND venue_id = ?", time.to_date, home_id, away_id, venue_id).any?
  end

  def home_and_away_not_same
    errors.add(:base, "Home and away teams cannot be empty or the same team.") if (home_id == away_id)
  end

  def venue
    errors.add(:base, "Venue is not valid") if venue_id.blank?
  end

  def home_team
    errors.add(:base, "Home team is not valid") if home_id.blank?
  end

  def away_team
    errors.add(:base, "Away team is not valid") if away_id.blank?
  end

end
