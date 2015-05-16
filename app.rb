require 'sinatra'
load 'temp.rb'

get '/' do 
	erb :index
end

get '/geojson' do
	places = run('tracts.txt')
	@geojson = create_geojson(places).to_json
end