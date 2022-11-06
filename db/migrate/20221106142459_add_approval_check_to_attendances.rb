class AddApprovalCheckToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :approval_check, :boolean
  end
end
