class UsersController < ApplicationController

  before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy, :edit_basic_info, :update_basic_info]

  def index
    unless current_user.admin?
      unless current_user.id == params[:id].to_i
        flash[:danger] = '一般ユーザはアクセスできません'
        redirect_to root_url
      end
    end
    if params[:name]
      @users = user_search(params[:name]).paginate(page: params[:page])
    else
      @users = User.paginate(page: params[:page])
    end
  end

  def show
    unless current_user.admin?
      unless current_user.id == params[:id].to_i
        flash[:danger] = '一般ユーザはアクセスできません'
        redirect_to root_url
      end
    end
    @user = User.find(params[:id])
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in(@user)
      flash[:success] = "ユーザーの新規作成に成功しました。"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    # @user = User.find(params[:id])
  end

  def update
    # @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # 更新に成功した場合の処理
      flash[:success] = 'ユーザー情報を更新しました。'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = '削除しました。'
    redirect_to users_url
  end

  def edit_basic_info
    @user = User.find(params[:id])
  end

  def update_basic_info
    @user = User.find(params[:id])
    @users = User.all
    @users.each do |user|
      unless user.update_attributes(basic_info_params)
        render 'edit_basic_info'
      end
    end
    flash[:success] = "基本情報を更新しました。"
    redirect_to @user
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_time, :work_time)
    end
    
    def user_search(name)
      @users = User.where(['name LIKE ?', "%#{name}%"])
    end

    # beforeアクション

    # ログイン済みユーザーか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless curent_user?(@user)
    end

     # 管理者かどうかを確認
    def admin_user
      redirect_to(root_url) if !current_user.admin?
    end

end