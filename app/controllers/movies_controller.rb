class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def create
    session[:sortby] = "none"
    session[:ratings] = Hash[Movie.all_ratings.collect { |item| [item, "1"] } ]
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    if not params[:sortby] and not session[:sortby]
      if not params[:ratings]
        flash.keep
        redirect_to movies_path({sortby: "none", ratings: session[:ratings]})
      else
        flash.keep
        redirect_to movies_path({sortby: "none", ratings: params[:ratings]})
      end
    elsif not params[:sortby]
      if not params[:ratings]
        flash.keep
        redirect_to movies_path({sortby: session[:sortby], ratings: session[:ratings]})
      else
        flash.keep
        redirect_to movies_path({sortby: session[:sortby], ratings: params[:ratings]})
      end
    end
    
    @sortby = params[:sortby] if params[:sortby] != "none"
    @ratings = params[:ratings] ? params[:ratings].keys : @all_ratings
    @movies = Movie.with_ratings(@ratings).order(@sortby).all
    
    session[:sortby] = @sortby
    session[:ratings] = Hash[@ratings.collect { |item| [item, "1"] } ]
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

end
