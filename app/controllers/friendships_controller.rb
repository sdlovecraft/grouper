class FriendshipsController < ApplicationController
  before_action :require_user

  def index
    @friendships = Friendship
    .joins(:friend)
    .where(user: current_user)
    .order('LOWER(name)').page params[:page]
    @friends = @friendships.map(&:friend)
  end

  def create
    @friendship = current_user.friendships.build(friend_id: params[:friend_id])
    @user = User.find(params[:friend_id])
    if @friendship.save
      flash[:success] = "you have added a friend!"
      redirect_to user_path(@user)
    else
      @posts = @user.posts
      flash[:danger] = "you were unable to add friend!"
      render 'users/show'
    end
  end

  def destroy
    @friendship = Friendship.find_by(id: params[:id])
    if current_user == @friendship.user
      @friendship.destroy
      flash[:success] = "you have deleted friend!"
    end
    redirect_to user_path(@friendship.friend)
  end



end
