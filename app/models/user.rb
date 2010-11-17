class User < ActiveRecord::Base
  attr_accessible :poems_evaluated, :posts, :points, :username, :email, :password, :password_confirmation

  validates :username,     :presence => true,
                           :length => { :maximum => 50 },
                           :format => { :with => /^[^@]+$/}

  acts_as_authentic

  def self.find_by_username_or_email(login)
    find_by_username(login) || find_by_email(login)
  end
end
