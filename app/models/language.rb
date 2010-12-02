class Language < ActiveRecord::Base
  attr_accessible :name, :total_votes, :max_poems, :created_at, :updated_at, :active
  has_many :auth_lang_relations, :dependent => :destroy
  has_many :authors, :through => :auth_lang_relations
  has_many :poems

  def add_author!(author)
    authors << author
  end

  def remove_author!(author)
    auth_lang_relations.find_by_author_id(author).destroy
  end

  def has_author?(author)
    auth_lang_relations.find_by_author_id(author)
  end

  def get_line
    language.gen_snippet
  end


  private 

  def language
    @@languages ||= {}
    return @@languages[name] if @@languages[name]
    
    reload_language
    @@languages[name]
  end

  def reload_language
    @@languages[name] = MarkovLanguage.new

    authors.each do |author|
      author.works.each do |work|
        work.content.split(/\n/).each do |line| 
          @@languages[name].add_snippet(line) 
        end
      end
    end
  end

end
