class ProgressesController < ApplicationController

  before_action :authenticate

  def new
    now = Time.zone.now
    @progress = current_user.progresses.build
    @progress.progress_at = now - now.sec
    @still_sicks = Sick.where(:owner_id => current_user.id, :status => 0)
  end

  def create
    
    permited_params = progress_params
    sick = if permited_params[:sick_id]
      Sick.find(permited_params[:sick_id])
    else
      Sick.create(:owner_id => current_user.id)
    end

    @progress = sick.progresses.build(permited_params) do |p|
      p.user_id = current_user.id
      p.parts.each do |part|
        part.user_id = current_user.id
        part.sick_id = sick.id
      end
    end

    if @progress.save
      redirect_to @progress, notice: '登録しました'
    else
      render :new
    end
  end

  def show
    @progress = Progress.find(params[:id])
  end

  private

  def progress_params
    params.require(:progress).permit(:sick_id, :progress_at, :parts_attributes => [:part, :kind, :level, :x, :y, :_destroy])
  end

end
