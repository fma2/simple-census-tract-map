require 'json'


def parse_headers(data)
	headers = data.shift.split("\t").map(&:strip) 
end

def convert_to_hash(headers, data)
	data_hash = Array.new
	data.each do |line|
		place = line.split("\t").map(&:strip)
		place_hsh = Hash[headers.zip(place)]
		place_hsh["Population Density"] = calculate_density(place_hsh["Population"], place_hsh["Land Area"])
		place_hsh["Housing Density"] = calculate_density(place_hsh["Housing Units"], place_hsh["Land Area"])
		data_hash << place_hsh
	end
	data_hash
end


def convert_to_square_miles(square_meters)
	square_meters / 2589988
end

def calculate_density(units, area)
	density = units.to_f / convert_to_square_miles(area.to_f)
end

def find_densest(field, places)
	values = places.map do |place|
		place[field].to_f
	end
	places.select {|place| place[field] == values.max}
end

def find_sparsest(field, places)
	values = places.map do |place|
		place[field].to_f
	end
	places.select {|place| place[field] == values.min}
end

def mark_densest(field, places)
	densest_places = find_densest(field, places)
	densest_places.each {|place| place["Densest #{field}"] = true}
end

def mark_sparsest(field, places)
	sparsest_places = find_sparsest(field, places)
	sparsest_places.each {|place| place["Sparsest #{field}"] = true}
end

def run(file)
	data = File.readlines(file)
	headers = parse_headers(data)
	places = convert_to_hash(headers, data)
	mark_densest("Population Density", places)
	mark_sparsest("Population Density", places)
	places
end

def create_geojson(data)
	geojson = data.map do |place|
		if place["Densest Population Density"]
			{
				type: 'Feature',
				geometry: {
					type: 'Point',
					coordinates: [place["Longitude"].to_f, place["Latitude"].to_f]
				},
				properties: {	
					title: place["Name"],	
					description: "Population Density: #{place['Population Density']} <br> Housing Density: #{place["Housing Density"]}",
					# 'marker-size' => 'large',
					'marker-color' => '#008B8B',
					'marker-symbol' => 'star',

					tract: place["Tract"],		
					tract_name:	place["Name"],							
					land_area:	place["Land Area"],						
					water_area:	place["Water Area"],	
					population:	place["Population"],						
					housing_units:	place["Housing Units"],			
					population_density:	place["Population Density"],						
					housing_density:	place["Housing Density"],
					densest: true,
					sparsest: false
					}
			}
		elsif place["Sparsest Population Density"]
			{
				type: 'Feature',
				geometry: {
					type: 'Point',
					coordinates: [place["Longitude"].to_f, place["Latitude"].to_f]
				},
				properties: {	
					title: place["Name"],	
					description: "Population Density: #{place['Population Density']} <br> Housing Density: #{place["Housing Density"]}",
					'marker-color' => '#00FFFF',
					'marker-symbol' => 'star',
					tract: place["Tract"],		
					tract_name:	place["Name"],							
					land_area:	place["Land Area"],						
					water_area:	place["Water Area"],	
					population:	place["Population"],						
					housing_units:	place["Housing Units"],			
					population_density:	place["Population Density"],						
					housing_density:	place["Housing Density"],
					densest: false,
					sparsest: true
					}
			}
		else
			{
				type: 'Feature',
				geometry: {
					type: 'Point',
					coordinates: [place["Longitude"].to_f, place["Latitude"].to_f]
				},
				properties: {
					title: place["Name"],	
					description: "Population Density: #{place['Population Density']} <br> Housing Density: #{place["Housing Density"]}",
					# 'marker-size' => 'large',
					'marker-color' => '#DCDCDC',
					tract: place["Tract"],		
					tract_name:	place["Name"],							
					land_area:	place["Land Area"],						
					water_area:	place["Water Area"],	
					population:	place["Population"],						
					housing_units:	place["Housing Units"],			
					population_density:	place["Population Density"],						
					housing_density:	place["Housing Density"],
					densest: false,
					sparsest: false
				}
			}
		end
	end
	geojson
end

