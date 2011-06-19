class User < ActiveRecord::Base
  attr_accessible :poems_evaluated, :posts, :points, :username, :email, :email_confirmation, :password, :password_confirmation

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
end
