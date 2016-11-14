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
  @actors = db_connection do |conn|
     conn.exec('SELECT id, name FROM actors ORDER BY name')
  end
  erb :'actors/index'
end

get "/actors/:id" do
  @actor_id = params[:id]
  @filmography = db_connection do |conn|
    conn.exec_params('
    SELECT movies.id, movies.title, movies.year, cast_members.character, actors.name
    FROM actors
    JOIN cast_members ON actors.id = cast_members.actor_id
    JOIN movies ON cast_members.movie_id = movies.id
    WHERE actors.id = ($1) ORDER BY year', [params[:id]]
    )
  end
  erb :'actors/show'
end

get "/movies" do
  @movies = db_connection do |conn|
    conn.exec('SELECT movies.id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
        FROM movies
        JOIN genres ON movies.genre_id = genres.id
        JOIN studios ON movies.studio_id = studios.id
        ORDER BY title')
  end
  erb :'movies/index'
end

get "/movies/:id" do
  @movie_id = params[:id]
  @movie_details = db_connection do |conn|
    conn.exec_params('
    SELECT movies.id, movies.title, genres.name AS genre, studios.name AS studio
    FROM movies
    JOIN genres ON movies.genre_id = genres.id
    JOIN studios ON movies.studio_id = studios.id
    WHERE movies.id = ($1)', [params[:id]]
  )
  end
  @cast = db_connection do |conn|
    conn.exec_params('
    SELECT movies.id, actors.id, actors.name, cast_members.character
    FROM cast_members
    JOIN actors ON cast_members.actor_id = actors.id
    JOIN movies ON cast_members.movie_id = movies.id
    WHERE movies.id = ($1)', [params[:id]]
  )
  end
  erb :'movies/show'
end


set :views, File.join(File.dirname(__FILE__), "views")
set :public_folder, File.join(File.dirname(__FILE__), "public")
