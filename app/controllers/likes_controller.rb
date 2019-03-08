class LikesController < ApplicationController

  def create
    like = current_user.likes.build(likable_id: params[:likable_id], likable_type: params[:likable_type])
 
    if like.save
      flash[:notice] = 'Liked.'
    end
    redirect_to root_path
  end

  def destroy
    Like.where(likable_id: params[:id]).find_by(user_id: current_user.id).destroy
    redirect_to root_path
  end
end
