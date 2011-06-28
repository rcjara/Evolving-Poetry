class User < ActiveRecord::Base
  attr_accessible :poems_evaluated, :posts, :total_points, :points_used, :username, :email, :email_confirmation, :password, :password_confirmation

  validates :username, :presence => true,
                       :uniqueness => true,
                       :length => { :maximum => 50 },
                       :format => { :with => /^[^@]+$/}

  validates :email,    :confirmation => true,
                       :format => { :with => /@/ }

  acts_as_authentic

  def self.find_by_username_or_email(login)
    find_by_username(login) || find_by_email(login)
  end

  def award_point!(num = 1)
    increment(:total_points, num)
    save
  end

  def spend_point!(num = 1)
    return false unless available_points >= num
    increment(:points_used, num)
    save
    true
  end

  def available_points
    total_points - points_used
  end

  alias :award_points! :award_point!
  alias :spend_points! :spend_point!
end
