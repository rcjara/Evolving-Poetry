class Author < ActiveRecord::Base
  has_many :author_language_relations, :dependent => destroy
  has_many :languages, :through => :author_language_relations
  has_many :works
end
