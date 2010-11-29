class Author < ActiveRecord::Base
  has_many :auth_lang_relations, :dependent => destroy
  has_many :languages, :through => :author_language_relations
  has_many :works
end
