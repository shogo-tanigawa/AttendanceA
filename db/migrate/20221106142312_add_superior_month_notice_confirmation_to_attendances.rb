class AddSuperiorMonthNoticeConfirmationToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :superior_month_notice_confirmation, :string
  end
end
