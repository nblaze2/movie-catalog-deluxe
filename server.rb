require "sinatra"
require "pg"
require "pry"

set :bind, '0.0.0.0'  # bind to all interfaces

configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get "/actors" do
  db_connection do |conn|
    @actors = conn.exec('SELECT name FROM actors ORDER BY name')
    erb :'actors/index'
  end
end

get "/actors/:actor_name" do
  @actor_name = params[:actor_name]
  db_connection do |conn|
    @filmography = conn.exec_params('
    SELECT movies.title, movies.year, cast_members.character
    FROM actors
    JOIN cast_members ON actors.id = cast_members.actor_id
    JOIN movies ON cast_members.movie_id = movies.id
    WHERE actors.name = ($1) ORDER BY year', [params[:actor_name]]
    )
    erb :'actors/show'
  end
end

get "/movies" do
  db_connection do |conn|
    @movies = conn.exec('SELECT movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
        FROM movies
        JOIN genres ON movies.genre_id = genres.id
        JOIN studios ON movies.studio_id = studios.id
        ORDER BY title')
    erb :'movies/index'
  end
end

get "/movies/:movie_name" do
  @movie = params[:movie_name]
  db_connection do |conn|
    @movie_details = conn.exec_params('
    SELECT movies.title, genres.name AS genre, studios.name AS studio
    FROM movies
    JOIN genres ON movies.genre_id = genres.id
    JOIN studios ON movies.studio_id = studios.id
    WHERE movies.title = ($1)', [params[:movie_name]]
    )

    @cast = conn.exec_params('
    SELECT actors.name, cast_members.character
    FROM cast_members
    JOIN actors ON cast_members.actor_id = actors.id
    JOIN movies ON cast_members.movie_id = movies.id
    WHERE movies.title = ($1)', [params[:movie_name]]
    )
  erb :'movies/show'
  end
end


set :views, File.join(File.dirname(__FILE__), "views")
set :public_folder, File.join(File.dirname(__FILE__), "public")
