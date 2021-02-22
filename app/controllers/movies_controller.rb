class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # part1: sort the list of movies based on parameter
    # @movies = Movie.order(params[:order])
    
    
    # part2: 
    # @all_ratings = ['G','PG','PG-13','R']
    # if params[:ratings].nil?
    #   @movies = Movie.order params[:order]
    # else
    #   # filter movies based on ratings
    #   array_ratings = params[:ratings].keys
    #   @chosen_ratings = array_ratings
    #   @movies = Movie.where(rating: array_ratings).order params[:order]
    
    array_ratings = params[:ratings]
    @all_ratings = Movie.all_ratings
    
    # Remember the sorting and filtering settings
    
    session[:ratings] = params[:ratings] unless params[:ratings].nil?
    session[:sort] = params[:sort] unless params[:sort].nil?

    sort_by = params[:sort]
    
    #apply settings from session when the incoming URI doesn’t have params
    if (params[:ratings].nil? and params[:commit]=="Refresh")
      @ratings_to_show = Movie.all_ratings
      @movies = Movie.with_ratings(@ratings_to_show, session[:sort])
      session[:ratings] = params[:rating]
      
    #when URI has params, the new settings should be remembered in the session.
    elsif (params[:ratings].nil? && !session[:ratings].nil?) || (params[:sort].nil? && !session[:sort].nil?)
      redirect_to movies_path("ratings" => session[:ratings], "sort" => session[:sort])
    
    else
      if !params[:ratings].nil?
        array_ratings = params[:ratings].keys
      else
        array_ratings = @all_ratings
      end
      if sort_by == 'title'
        @sort_by = sort_by
        @highlight = 'title'
      elsif sort_by=='release_date'
        @sort_by = sort_by
        @highlight = 'release_date'
      else
        @sort_by = ""
        @ratings_to_show = array_ratings
        @highlight = nil
      end
      
      @ratings_to_show = array_ratings
      @movies = Movie.with_ratings(@ratings_to_show, @sort_by)
    
      
    end
    
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end