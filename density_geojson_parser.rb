require 'json'

def parse_headers(data)
	headers = data.shift.split("\t").map(&:strip) 
end

def convert_to_square_miles(square_meters)
	square_meters / 2589988
end

def calculate_density(units, area)
	density = units.to_f / convert_to_square_miles(area.to_f)
end

def add_density_calculations(place)
	place["Population Density"] = calculate_density(place["Population"], place["Land Area"])
	place["Housing Density"] = calculate_density(place["Population"], place["Land Area"])
	place
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

def create_geojson(data)
	geojson = data.map do |place|
		marker_color = 
		if place["Densest Population Density"]
			'#008B8B'
		elsif place["Sparsest Population Density"]
			'#00FFFF'
		else
			'#DCDCDC'
		end

		{
			type: 'Feature',
			geometry: { type: 'Point', coordinates: [place["Longitude"].to_f, place["Latitude"].to_f] },
			properties: {
				title: place["Name"],	
				description: "Population Density: #{place['Population Density'].round(2)} <br> Housing Density: #{place["Housing Density"].round(2)}",
				'marker-color' => marker_color,
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
	geojson
end

def parse(file)
	data = File.readlines(file)
	headers = parse_headers(data)

	all_places = Array.new

	data.each do |line|
		place_data = line.split("\t").map(&:strip)
		place = add_density_calculations(Hash[headers.zip(place_data)])
		all_places << place
	end

	mark_densest("Population Density", all_places)
	mark_sparsest("Population Density", all_places)

	create_geojson(all_places)
end
