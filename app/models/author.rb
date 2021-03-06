class Author < ActiveRecord::Base
  has_many :items

  #attr_accessible :given_name, :surname, :id
  validates_presence_of :given_name, :surname, :on => :create, :message => "Can't be blank."
  validates_uniqueness_of :surname, :scope => [:given_name]
  #validate :surname, :presence => true, :uniqueness => {:scope => :given_name}, :allow_blank => false, :allow_nil => false
  
  def self.search(search)
    search_condition = "%" + search + "%"
    Author.all(:conditions => ['given_name LIKE ? OR surname LIKE ?', search_condition, search_condition])
  end
end
