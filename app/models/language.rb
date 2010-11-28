class Language < ActiveRecord::Base
  has_many :author_language_relations
  has_many :authors, :through => :author_language_relations
  has_many :poems
end
