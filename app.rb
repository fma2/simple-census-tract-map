require 'sinatra'
load 'density_geojson_parser.rb'

get '/' do 
	erb :index
end

get '/geojson' do
	@geojson = parse('tracts.txt').to_json
end