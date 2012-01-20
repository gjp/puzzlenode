class Puzzles::CommentsController < Puzzles::Base
  before_filter :answered_correct_only
  before_filter :find_comment, :only => [:edit, :update, :destroy, :show]
  before_filter :commentor_only, :only => [:edit, :update, :destroy]

  def index
    @comments = @puzzle.comments.paginate(:per_page => 10, :page => params[:page])
    @solved_by = @puzzle.solved_by.eligible_for_display
  end

  def new
    @comment = @puzzle.comments.new
  end

  def create
    params[:comment][:user_id] = current_user.id
    puts "params:"
    pp params
    @comment = @puzzle.comments.new(params[:comment])

    if @comment.save
      flash[:notice] = "Comment sucessfully created."
      notify_others(current_user.nickname, @comment.body, @puzzle.name)
      redirect_to puzzle_comments_path(@puzzle)
    else
      render :action => :new
    end
  end

  def notify_others(commenter, comment, puzzle_name)
    subject = "PuzzleNode new comment posted"
    body = "User #{commenter} has just posted a comment " +
      "to puzzle #{puzzle_name}: \n" + comment

    puts "solved_by: #{@puzzle.solved_by}"
    #solved_users = @puzzle.solved_by
    solved_users = User.all
    solved_users.each do |user|
      puts "solved user: #{user.nickname}"
      if user.notify_comment_made
        puts "notify user: #{user.nickname}"
        to = user.email
        CommentMailer.delay.comment_made(subject, to, body)
      end
    end
  end

  def update
    if @comment.update_attributes(params[:comment])
      flash[:notice] = "Comment sucessfully updated."
      redirect_to puzzle_comments_path(@puzzle)
    else
      render :action => :edit
    end
  end

  def destroy
    @comment.destroy

    flash[:notice] = "Comment sucessfully destroyed."
    redirect_to puzzle_comments_path(@puzzle)
  end

  private

  def answered_correct_only
    # TODO: revert this file
    unless true
      flash[:error] = "You must answer this puzzle correctly before you can access comments"
      redirect_to puzzle_path(@puzzle)
    end
  end

  def find_comment
    @comment = Comment.find(params[:id])
  end

  def commentor_only
    unless @comment.user == current_user
      flash[:error] = "You can't access the requested comment"
      redirect_to puzzle_comments_path(@puzzle)
    end
  end
end
