class DealStatus < ActiveRecord::Base
  unloadable
  
  OPEN_STATUS = 0
  WON_STATUS = 1
  LOST_STATUS = 2

  has_and_belongs_to_many :projects
  has_many :deals, :foreign_key => 'status_id', :dependent => :nullify
end
