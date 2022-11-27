class AddColumns2ToAttendances < ActiveRecord::Migration[5.1]
  def change
    # 勤怠変更の申請と承認
    add_column :attendances, :restarted_at, :datetime
    add_column :attendances, :refinished_at, :datetime
    add_column :attendances, :attendance_change_status, :string
    add_column :attendances, :attendance_change_check_status, :string
    add_column :attendances, :superior_attendance_change_confirmation, :string
    add_column :attendances, :superior_attendance_change_approval_confirmation, :string
    add_column :attendances, :change_check, :boolean
    add_column :attendances, :begin_started, :datetime
    add_column :attendances, :begin_finished, :datetime
  end
end
