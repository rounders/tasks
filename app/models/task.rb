class Task < ActiveRecord::Base
  include RankedModel
  belongs_to :project
  validates :project_id, :presence => true
  validates :description, :presence => true
  scope :completed, where(:completed => true).order('updated_at desc')
  scope :active, where(:completed => false).order('position')
  
  ranks :position, :with_same => :project_id
 
end
