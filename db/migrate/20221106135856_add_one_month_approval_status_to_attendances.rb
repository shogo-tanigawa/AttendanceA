class AddOneMonthApprovalStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :one_month_approval_status, :string
  end
end
