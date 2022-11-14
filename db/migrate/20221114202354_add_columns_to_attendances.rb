class AddColumnsToAttendances < ActiveRecord::Migration[5.1]
  def change
    # 残業申請
    add_column :attendances, :overwork_end_time, :time
    add_column :attendances, :next_day, :boolean
    add_column :attendances, :overwork_next_day, :boolean
    add_column :attendances, :overwork_status, :string
    add_column :attendances, :overwork_approval_status, :string
    add_column :attendances, :process_content, :string
    add_column :attendances, :superior_confirmation, :string
    add_column :attendances, :superior_notice_confirmation, :string
    add_column :attendances, :is_check, :boolean
  end
end
