class Work < ActiveRecord::Base
  belongs_to :author

  delegate :visible, :to => :author, :prefix => true
end
