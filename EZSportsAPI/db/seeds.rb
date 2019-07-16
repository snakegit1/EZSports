# CREATE ROLES
# roles = ["player", "coach", "manager", "super_admin"]

# roles.each do |role|
# 	Role.create!({name: role})
# end


# NOTE: If you get an error creating seeds, first ensure that you have enough data for whatever you are trying to create.
# For example: if you don't have at least two teams for each league_id, then you can't schedule (create) games.
# As it stands, this should not be an issue. Further testing will confirm/disprove whether it's been fixed for each create below.


# CREATE ROLES
roles = ["player", "coach", "manager", "super_admin"]

sports = ['Adapted Basketball',
          'Adapted Bowling',
          'Adapted Floor Hockey',
          'Adapted Soccer',
          'Adapted Softball',
          'Adapted Track',
          'Air Riflery',
          'Archery',
          'Australian Rules Football',
          'Badminton',
          'Baseball',
          'Basketball',
          'Bowling',
          'Competitive Spirit Squad',
          'Crew',
          'Cricket',
          'Cross Country',
          'Curling',
          'DANCE',
          'Dance Team, High Kick',
          'Dance Team, Jazz',
          'Dance/Drill',
          'Decathlon',
          'Dodgeball',
          'Drill Team',
          'Equestrian',
          'Fencing',
          'Field Hockey',
          'Flag Football',
          'Football -- 11-Player',
          'Football -- 6-player',
          'Football -- 8-player',
          'Football -- 9-player',
          'Frisbee',
          'Golf',
          'Gymnastics',
          'Handball',
          'Heptathlon',
          'Ice Hockey',
          'Inline Hockey',
          'Judo',
          'Kayaking',
          'Kickball',
          'Lacrosse',
          'Mixed 6-Coed Volleyball',
          'Mt. Biking',
          'Outrigger Canoe Paddling LL',
          'Riflery',
          'Rodeo',
          'RUGBY',
          'Sailing',
          'Skiing -- Alpine',
          'Skiing -- Cross Country',
          'Snowboarding',
          'Soccer',
          'Soft Tennis',
          'Softball -- Fast Pitch',
          'Softball -- Slow Pitch',
          'Surfing',
          'Swimming & Diving',
          'Synchronized Swimming',
          'Team Tennis',
          'Tennis',
          'Track and Field -- Indoor',
          'Track and Field -- Outdoor',
          'Volleyball',
          'Water Polo',
          'Weight Lifting',
          'Wrestling']
		  

sports.each do |sport|
	Sport.find_or_create_by(name: sport)
end

roles.each do |role|
  Role.find_or_create_by(name: role)
end

p 'SEED TASK SUCCESSFUL. PRAISE HAM SANDWICHES.'
