class Project < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  validates :name, :presence => true, :uniqueness => true
  accepts_nested_attributes_for :tasks, :allow_destroy => true
end
