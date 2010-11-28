class AuthorLanguageRelation < ActiveRecord::Base
  belongs_to :author
  belongs_to :language

  validates :author_id, :presence => true
  validates :language_id, :presence => true
end
