class BasesController < ApplicationController
  
  def index
    @bases = Base.all
    base = Base.find_by(id: params[:id])
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
    @base = Base.find(params[:id])
  end

  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を修正しました。"
      redirect_to bases_url
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

    def set_base
      @base = Base.find(params[:id])
    end
end