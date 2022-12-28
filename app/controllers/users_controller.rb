class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :logged_in_user, only: [:edit, :update]
  before_action :admin_or_correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :attendance_user_index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :other_user, only: :show
  before_action :set_one_month, only: :show
  before_action :not_allow_admin_user, only: :show
  
  def index
    @users = User.order(:id)
    @users = User.paginate(page: params[:page])
    @users = @users.where('name LIKE ?', "%#{params[:search]}%") if params[:search].present?
  end
  
  def attendance_user_index
    @in_working_users = User.in_working_users
  end

  def import
    if params[:file].blank?
      flash[:danger] = 'ファイルを選択してください。'
      redirect_to users_url
    elsif File.extname(params[:file].original_filename) == ".csv"
      User.import(params[:file])
      flash[:success] = 'インポートしました。'
      redirect_to users_url
    else
      flash[:danger] = 'csvファイルのみ読み込み可能です。'
      redirect_to users_url
    end
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @superior = User.where(superior: true).where.not(id: @user.id)
    @attendance = @user.attendances.find_by(worked_on: @first_day)
    if current_user.superior?
      @overwork_sum = Attendance.includes(:user).where(superior_confirmation: current_user.id, overwork_status: "申請中").count
      @attendance_change_sum = Attendance.includes(:user).where(superior_attendance_change_confirmation: current_user.id, attendance_change_status: "申請中").count
      @one_month_approval_sum = Attendance.includes(:user).where(superior_month_notice_confirmation: current_user.id, one_month_approval_status: "申請中").count
    end
    # CSV出力
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendance_csv(@attendance)
      end
    end
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end

    
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end

  def update_basic_info
    @user = User.find(params[:id])
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  private
  
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email, :department, :employee_number, :uid, :basic_work_time, 
                                  :designated_work_start_time, :designated_work_end_time, :password)
    end

    def send_attendance_csv(attendances)
      # 文字化け防止
      bom = "\uFEFF"
      # CSV.genetateとは、対象データを自動的にCSV形式に変換してくれるCSVライブラリの一種
      csv_data = CSV.generate(bom, encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
        # %w()は、空白で区切って配列を返します。
        column_names = %w(日付 曜日 出社時間 退社時間)
        # csv << column_namesは表の列に入る名前を定義します。
        csv << column_names
        # column_valuesに代入するカラム値を定義します。
        @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
        @attendances.each do |day|
          column_values = [
            l(day.worked_on, format: :short),
            $days_of_the_week[day.worked_on.wday],
            if day.started_at.present? && (day.attendance_change_status == "承認").present?
              l(day.started_at.floor_to(60*15), format: :time)
            else
              ""
            end,
            if day.finished_at.present? && (day.attendance_change_status == "承認").present?
              l(day.finished_at.floor_to(60*15), format: :time)
            else
              ""
            end
          ]
        # csv << column_valuesは表の行に入る値を定義します。
          csv << column_values
        end
      end
      # csv出力のファイル名を定義します。
      send_data(csv_data, filename: "勤怠一覧.csv")
    end
    
    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "権限がありません。"
        redirect_to(root_url)
      end
    end
end
