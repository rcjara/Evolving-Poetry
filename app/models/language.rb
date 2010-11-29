class Language < ActiveRecord::Base
  has_many :auth_lang_relations
  has_many :authors, :through => :author_language_relations
  has_many :poems
end
