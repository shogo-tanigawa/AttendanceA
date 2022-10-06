class BasesController < ApplicationController
  
  def index
    @bases = Base.all
  end

  def new
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '拠点情報を追加しました。'
      redirect_to bases_index
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

    def base_params
      params.require(:base).permit(:baseid, :basename, :basetype)
    end
end