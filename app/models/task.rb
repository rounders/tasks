class Task < ActiveRecord::Base
  # make sure this before_save filter is before the include RankedModel as including RankedModel introduces
  # a before_filter that needs to run after set_position
  before_save :set_position, :if => Proc.new { |task| task.completed_changed? || task.new_record? }
  include RankedModel

  belongs_to :project
  
  validates :project_id, :presence => true
  validates :description, :presence => true
  
  scope :completed, where(:completed => true).order('updated_at desc')
  scope :active, where(:completed => false).order('position')
  
  ranks :position, :with_same => :project_id

  # if a task record is new, move it to the bottom of the list
  # if a task is moving from completed to active, move it to the bottom of the list
  # if a task is moving from active to completed, movie it to the top of the list
  def set_position
    self.position_position = (new_record? || completed_was) ? :last : :first 
  end
  
end
