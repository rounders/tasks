class Project < ActiveRecord::Base
  has_many :tasks, :order => 'position', :dependent => :destroy
  belongs_to :user
  validates :name, :presence => true, :uniqueness => true
  validates :user_id, :presence => true
  accepts_nested_attributes_for :tasks, :allow_destroy => true
  
  attr_protected :user_id
  

end
