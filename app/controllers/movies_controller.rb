class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings

    if !params[:ratings] && !session[:ratings]
      session[:ratings] = {'G' => 1,'PG'=> 1,'PG-13'=> 1,'R'=> 1}
    elsif params[:checked_ratings]
      temp = {}
      params[:checked_ratings].each  {|x| temp[x] = 1}
      session[:ratings] = temp
    end
    
    @checked_ratings = session[:ratings].keys

    if session[:sort] == "title" && params[:sort] == nil || params[:sort] == "title"
      sort = "title"
    elsif (session[:sort] == "release_date" && params[:sort] == nil) || params[:sort] == "release_date"
      sort = "release_date"
    else
      sort = 1
    end

    if params[:sort] != session[:sort] || params[:ratings] != session[:ratings]
        session[:sort] = params[:sort] || session[:sort]
        session[:ratings] = params[:ratings] || session[:ratings]
        redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings])
    end
    
    @movies = Movie.order(sort).where(rating: @checked_ratings)
    
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
