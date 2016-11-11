require "sinatra"
require "pg"

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
  # @teams = ["Simpson Slammers", "Jetson Jets", "Flintstone Fire", "Griffin Goats"]
  erb :'actors/index'
end

get "/actors/:id" do
  # @team_name = params[:team_name]
  # @team_data = TeamData::ROLL_CALL[@team_name.to_sym]
  erb :'actors/show'
end

get "/movies" do
  # @positions = TeamData::ROLL_CALL.values[0].keys
  erb :'movies/index'
end

get "/movies/:id" do
  # @position = params[:position]
  # @whole_league = TeamData::ROLL_CALL
  # @players_by_position = {}
  #
  # @whole_league.each_pair do |team, roster|
  #   @players_by_position[roster[@position.to_sym]] = team
  # end
  #
  erb :'movies/show'
end
