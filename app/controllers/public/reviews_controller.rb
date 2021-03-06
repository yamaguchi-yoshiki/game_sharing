class Public::ReviewsController < ApplicationController
  before_action :authenticate_admin_customer, only: [:edit, :update]
  before_action :authenticate_customer!, only: [:new, :create]
  before_action :authenticate_admin!, only: [:destroy]

  def index
    @customer = Customer.find(params[:customer_id])
    @reviews = Review.where(customer_id: @customer.id).latest.page(params[:page])
  end

  def show
    @review = Review.find(params[:id])
    @comment = ReviewComment.new
    @comments = @review.review_comments
  end

  def new
    @review = Review.new
    @game = Game.find(params[:game_id])
  end

  def create
    @review = current_customer.reviews.new(review_params)
    if @review.save
      redirect_to review_path(@review), notice: "レビューを投稿しました"
    else
      @game = @review.game
      render "new"
    end
  end

  def edit
    @review = Review.find(params[:id])
    @customer = @review.customer
    unless admin_signed_in? || @customer == current_customer
      redirect_to root_path
    end
    @game = @review.game
  end

  def update
    @review = Review.find(params[:id])
    if @review.update(review_params)
      redirect_to review_path(@review), notice: "レビューを更新しました"
    else
      @game = @review.game
      render "edit"
    end
  end

  def destroy
    @review = Review.find(params[:id])
    @game = Game.find(@review.game_id)
    @review.destroy
    flash[:alert] = 'レビューを削除しました'
    redirect_to game_path(@game)
  end

  private

  def review_params
    params.require(:review).permit(:game_id, :rate, :comment, :is_public)
  end
end
