class AuthLangRelation < ActiveRecord::Base
  belongs_to :author
  belongs_to :language
end
