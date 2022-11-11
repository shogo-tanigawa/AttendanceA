class AttendancesController < ApplicationController
  include AttendancesHelper
  before_action :set_user, only: [:edit_one_month, :update_one_month, :update_month_request, :edit_one_month_approval]
  before_action :set_user_user_id, only: [:update_one_month_approval]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :other_user, only: [:edit_one_month, :update_one_month]
  before_action :set_superior, only: [:update_month_request]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      if attendances_invalid?
        attendances_params.each do |id, item|
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
        end
        flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        redirect_to user_url(date: params[:date])
      else
        flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
        redirect_to attendances_edit_one_month_user_url(date: params[:date])
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  # 残業申請
  def edit_overwork
  end

  def update_overwork
  end

  # １か月分の勤怠申請
  def edit_month_request
  end

  def update_month_request
    @attendance = @user.attendances.find_by(worked_on: params[:attendance][:day])
    if month_request_params[:superior_month_notice_confirmation].present?
      @attendance.update(month_request_params)
      flash[:success] = "#{@user.name}の１か月分の申請をしました。"
    else
      flash[:danger] = "所属長を選択してください。"
    end
    redirect_to user_url(@user)
  end

  # １か月分の勤怠所属長承認
  def edit_one_month_approval
    @month_attendances = Attendance.where(superior_month_notice_confirmation: @user.id, one_month_approval_status: "申請中").order(:user_id, :worked_on).group_by(&:user_id)
  end

  def update_one_month_approval
    month_approval_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:approval_check]
        if item[:one_month_approval_status] == "なし"
          item[:one_month_approval_status] = nil
          item[:approval_check] = nil
        end
        attendance.update(item)
        flash[:success] = "勤怠申請の承認結果を送信しました。"
      else
        flash[:danger] = "承認確認のチェックを入れてください。"
      end
    end
    redirect_to user_url(@user)
  end

  private

    def set_attendance
      @attendance = Attendance.find(params[:id])
    end

    def set_superior
      @superior = User.where(superior:true).where.not(id:current_user.id)
    end

    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

    def month_request_params
      params.require(:attendance).permit(:superior_month_notice_confirmation, :one_month_approval_status)
    end

    def month_approval_params
      params.require(:user).permit(attendances: [:approval_check, :one_month_approval_status])[:attendances]
    end
    
    # beforeフィルター
    
    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end
    end
end
