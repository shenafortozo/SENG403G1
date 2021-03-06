class Item < ActiveRecord::Base
  # Before saving an item record, run the method..
  before_save :replace_existing_author!

  has_many :physical_items, :dependent => :destroy
  has_many :rentals, :through => :physical_items
  has_many :users, :through => :rentals
  belongs_to :author
  
  attr_accessible :title, :author_attributes, :year, :genre, :publisher, :isbn13, :isbn10

  validates_presence_of :title
  validates_presence_of :isbn13
  validates_presence_of :isbn10
  validates_presence_of :year
  validates_presence_of :publisher
  validates_presence_of :genre
  
  validates_uniqueness_of :title, :scope => [:isbn13, :isbn10, :year]
  validates_uniqueness_of :isbn13
  validates_uniqueness_of :isbn10
  
  validates :year, :numericality => { :only_integer => true }
  
  accepts_nested_attributes_for :author
  
  # Try to find an existing author rather than creating a duplicate record
  # If one if found, grab the reference.
  def replace_existing_author!
    if self.author
      author = Author.where(:given_name => self.author.given_name,
                            :surname => self.author.surname).first
      self.author = author if author 
    end
  end

end
