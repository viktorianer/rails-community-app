class PostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :admin_user, only: [:create]
  before_action :admin_user, :correct_user, only: [:destroy]
  include PostsHelper

  # HTTP 	    URL	            Action	    Named route	            Purpose
  # request
  # POST	    /posts	        create	    posts_path
  # DELETE	  /posts/1	      destroy	    post_path(post)

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = "Post created!"
      redirect_to root_url
    else
      @feed = feed(params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @post.destroy
    flash[:success] = "Post deleted"
    redirect_back(fallback_location: root_url)
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end

  def correct_user
    @post = current_user.posts.find_by(id: params[:id]) if logged_in?
    redirect_to root_url if @post.nil?
  end
end
