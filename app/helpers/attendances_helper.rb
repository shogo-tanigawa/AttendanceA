module AttendancesHelper
  
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish, next_day)
    if next_day && (start >= finish)
      format("%.2f", (((finish - start) / 60) / 60.0) + 24)
    else
      format("%.2f", (((finish - start) / 60) / 60.0))
    end
  end
  
  def format_hour(time)
    format("%.d", (time.hour))
  end
  
  def format_min(time)
    format("%.2d", (((time.min) / 15) * 15))
  end
  
  # 不正な値があるか確認する
  def attendances_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].blank? && item[:finished_at].blank?
        next
      elsif item[:started_at].blank? || item[:finished_at].blank?
        attendances = false
        break
      elsif item[:started_at] > item[:finished_at]
        attendances = false
        break
      end
    end
    return attendances
  end

  def working_overwork_times(designated_work_end_time, overwork_end_time, overwork_next_day)
    if overwork_next_day
      format("%.2f", (overwork_end_time.hour - designated_work_end_time.hour) + ((overwork_end_time.min - designated_work_end_time.min) / 60.0) + 24)
    else
      format("%.2f", (overwork_end_time.hour - designated_work_end_time.hour) + ((overwork_end_time.min - designated_work_end_time.min) / 60.0))
    end
  end

  # 勤怠変更申請のステータス
  def attendance_change_status_text(status)
    case status
    when "申請中"
      "申請中"
    when "否認"
      "勤怠変更否認"
    when "承認"
      "勤怠変更承認済"
    when "なし"
    else
    end
  end

  # 残業申請のステータス
  def overwork_status_text(status)
    case status
    when "申請中"
      "申請中"
    when "否認"
      "残業否認"
    when "承認"
      "残業承認済"
    when "なし"
      "残業なし"
    else
    end
  end

  # １か月分の申請のステータス
  def one_month_approval_status_text(status)
    case status
    when "申請中"
      "１か月分の勤怠申請中"
    when "否認"
      "１か月分の勤怠否認"
    when "承認"
      "勤怠変更承認"
    when "なし"
    else
    end
  end
end
