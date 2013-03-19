class ChangeDealStatusesIsClosed < ActiveRecord::Migration
  def up
    change_column :deal_statuses, :is_closed, :integer
    rename_column :deal_statuses, :is_closed, :status_type
  end

  def down
    change_column :deal_statuses, :is_closed, :boolean
    rename_column :deal_statuses, :status_type, :is_closed
  end
end
