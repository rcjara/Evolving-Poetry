class Language < ActiveRecord::Base
  has_many :auth_lang_relations, :dependent => :destroy
  has_many :authors, :through => :auth_lang_relations
  has_many :poems
end
