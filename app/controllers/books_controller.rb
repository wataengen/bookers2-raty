class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
    @newbook =Book.new
    @tag_list = @newbook.book_tags.pluck(:name).join(',')
    @post_book_tags = @book.book_tags
  end

  def index
    @books = Book.all
    @book = Book.new

    @tag_list = @book.book_tags.pluck(:name).join(',')

    if params[:latest]
      @books = Book.latest
    elsif params[:old]
      @books = Book.old
    elsif params[:star_count]
      @books = Book.star_count
    else
      @books = Book.all
    end
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    tag_list = params[:book][:name].split(',')
    if @book.save
      @book.save_book_tags(tag_list)
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
    @tag_list = @book.book_tags.pluck(:name).join(',')
  end

  def update
    @book = Book.find(params[:id])
    tag_list=params[:book][:name].split(',')
    if @book.update(book_params)
      @book.save_book_tags(tag_list)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path
  end

  def search_tag
    @tag_list = BookTag.all
    @tag = BookTag.find(params[:book_tag_id])
    @book = @tag.books
  end


  private

  def book_params
    params.require(:book).permit(:title, :body, :star)
  end

  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end
end
