class BasesController < ApplicationController
  
  def index
    @bases = Base.all
  end

  def show
  end
  
  def new
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '拠点登録完了しました。'
      redirect_to bases_url
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を修正しました。"
      redirect_to basis_url
    else
      render :edit
    end
  end

  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "拠点番号#{@base.baseid}のデータを削除しました。"
    redirect_to bases_url
  end

  private

    def base_params
      params.require(:base).permit(:baseid, :basename, :basetype)
    end
end