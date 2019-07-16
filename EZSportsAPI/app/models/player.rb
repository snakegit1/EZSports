class Player < ActiveRecord::Base
  has_many :league_player

  def self.search(search)
    if search
      where('lower(first) LIKE :searchterm OR lower(last) LIKE :searchterm OR lower(email) LIKE :searchterm', searchterm: "%#{search.downcase}%")
    else
      all
    end
  end

end
