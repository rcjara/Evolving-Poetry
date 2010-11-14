class User < ActiveRecord::Base
  attr_accessible :poems_evaluated, :posts, :points, :username, :email, :password, :password_confirmation

  validates :username,     :presence => true,
                           :length => { :maximum => 50 }

  acts_as_authentic

end
