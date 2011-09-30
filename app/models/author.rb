class Author < ActiveRecord::Base
  has_many :auth_lang_relations, :dependent => :destroy
  has_many :languages, :through => :auth_lang_relations
  has_many :works

  scope :visible, where('visible = ?', true)
end
