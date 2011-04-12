class Work < ActiveRecord::Base
  belongs_to :author

  delegate :visible, :full_name, :to => :author, :prefix => true
end
