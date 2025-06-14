extends Node

class_name ProceduralGen
static var cavern : FastNoiseLite# = $cavern.texture.noise
static var altitude : FastNoiseLite# = $altitude.texture.noise
static var temperature : FastNoiseLite# = $temperature.texture.noise
static var humidite : FastNoiseLite# = $humidite.texture.noise
static var abyss : FastNoiseLite
static var TILES : Dictionary = Tiles.TILES

func get_cavern_noise() -> FastNoiseLite: return $cavern.texture.noise
	
func get_altitude_noise() -> FastNoiseLite: return $altitude.texture.noise

func get_temperature_noise() -> FastNoiseLite: return $temperature.texture.noise

func get_humidite_noise() -> FastNoiseLite: return $humidite.texture.noise
	

static func init_noise(SEED : int) -> void:
	print("generation procedural init noise")
	var PGInstance : ProceduralGen = preload("res://world_gen/procedural_generation.tscn").instantiate()
	cavern = PGInstance.get_cavern_noise()
	altitude = PGInstance.get_altitude_noise()
	temperature = PGInstance.get_temperature_noise()
	humidite = PGInstance.get_humidite_noise()
	altitude.seed=SEED
	temperature.seed=SEED
	humidite.seed=SEED
	cavern.seed=SEED
	
	abyss = FastNoiseLite.new() #altitude.duplicate() ??
	abyss.seed = SEED
	abyss.noise_type = FastNoiseLite.TYPE_SIMPLEX
	abyss.frequency = 0.1
	abyss.fractal_type = FastNoiseLite.FRACTAL_RIDGED
	abyss.fractal_lacunarity = 5
	abyss.domain_warp_enabled = true
	
	PGInstance.queue_free()
	is_initialised = true
	
static var is_initialised : bool = false

static func _generate_til2e(coord: Vector2i) -> Tile:	
	var y: int = coord.y
	var cav : float = cavern.get_noise_2dv(coord)
	var alt : float = altitude.get_noise_2dv(coord)
	var temp : float = temperature.get_noise_2dv(coord)
	var humid : float = humidite.get_noise_2dv(coord)	
	var ab : float = abyss.get_noise_2dv(coord)

	# Montagnes !!!!!!
	if y < line_level:
		var altitude_factor : float = abs(alt) + abs(y / mountain_height)
		if altitude_factor < 1.0:
			#trou
			#if cav<-0.2:
				#return TILES.air
			
			# Neige
			if temp <= snow_temp:
				if temp<=snow_temp-0.2:
					return TILES.ice
				return TILES.snow
			# Désert
			elif temp >= desert_temp:
				if temp>=desert_temp+0.15:
					return TILES.sand_stone
				return TILES.sand
			# Prairie
			else:
				if humid >0.4: return TILES.sakura_grass
				if humid <-0.4: return TILES.red_grass
				if humid <0: return TILES.autumn_grass
				return TILES.grass
				

	if y > 40:
		if cav > 0.3:
			# =========================
			# 4. ABYSS
			# =========================
			

			
			if y < abyss_depth:
				var abyss_factor : float = abs(ab) + abs(y /50.0)
				if abyss_factor < 2.0:
					return TILES.gold
				else:
					if abyss_factor > 0 and abyss_factor < 5.0:
						return TILES.greencore
					return TILES.abyss
				return TILES.log



			if y < abyss_depth and y > abyss_depth - 50:
				if cav>0.5:
					return TILES.deepstone
				return TILES.compact_stone

					
		elif cav > 0.1:
			if y > abyss_depth:
				return TILES.abyss
			return TILES.stone	
		
				
	return TILES.air



const sky_height : int = -270
const ocean_level : int = 0
const snow_temp : float = -0.4
const desert_temp : float = 0.4
const mountain_height : float = 150.0#69.0
const abyss_depth : int = 250#700  # Profondeur des abysses
const line_level : int = 0 #ligne invisible horizontal entre les montagnes et les biomes
const surface_size : float = 1.3
const white_floor_ceiling : int = 400
const white_floor : int = 500


static func _generate_tile(coord: Vector2i) -> Tile:
	assert (is_initialised==true, "GEN PROCEDURAL DOIT ETRE INIT")
	var y: int = coord.y
	var cav : float = cavern.get_noise_2dv(coord)
	var alt : float = altitude.get_noise_2dv(Vector2i(coord.x, coord.y*0.000000001))
	
	#alt frequency
	#0.010
	#0.009
	#0.005
	#0.001 (plat)
	
	var temp : float = temperature.get_noise_2dv(coord)
	var humid : float = humidite.get_noise_2dv(coord)	
	var layer : float = humidite.get_noise_2dv(Vector2i(coord.x, coord.y*6))
	var ab : float = abyss.get_noise_2dv(coord)
	
	
	# -- DEBUG -- #
	#if coord.x<0:
		#if y==0:
			#if randf()<0.5:
				#return TILES.grass
		#if y>0:
			#
			#return TILES.grass
		#return TILES.air
	#
	#
	
	
	
	# -- ILES CELESTES -- #
	if y <=sky_height:
		if alt > 0.4:
			#if (abs(alt)+abs(coord.y/160))>0:
			return TILES.cloud
		if cav < -0.4:
			return TILES.dark_cloud
		
		if y<sky_height-140 and cav<-0.2 and alt <0.3 and abs(temp) < 0.3:
			return TILES.gold #météortites avec filons d'or
			
			

	# -- MONTAGNE -- #
	var generate_in_moutain = false
	if y < line_level:
		var altitude_factor : float = abs(alt) + abs(y / mountain_height)
		if altitude_factor < surface_size:
			generate_in_moutain = true
		
	elif y >= line_level:
		var altitude_factor : float = abs(alt) + abs(y / 40.0)
	
		#biomes en surface juste sous la montagne
		if altitude_factor < surface_size:
			generate_in_moutain = true

		# -- CAVERNES -- #
		elif altitude_factor > 0 and altitude_factor < 5.0:
			if cav > 0.3:
				if layer<-0.5:
					return TILES.fuel
				if layer<-0.2:
					return TILES.ore
				if layer>0.5:
					return TILES.abyss_fuel
				if layer>0.2:
					return TILES.autumn_leaf
	
	
				# Neige
				if temp <= snow_temp:
					if temp<=snow_temp-0.2:
						return TILES.compact_stone
					return TILES.ice
				
				# Sakura
				elif temp <= -0.2:
					if temp<=-0.3:
						return TILES.white_stone
					return TILES.sakura_grass
					
				# Désert
				elif temp >= desert_temp:
					if temp>=desert_temp+0.15:
						return TILES.sand_stone
					return TILES.sand
					
					
				# Prairie
				else:
					if abs(temp) < 0.1:
						return TILES.compact_stone
					if abs(temp) < 0.2:
						return TILES.dirt
					return TILES.stone
	
	# -- MONTAGNE -- #
	if generate_in_moutain:
		#trou
		#if cav<-0.2:
			#return TILES.air
		
		# Froid
		if temp <= snow_temp:
			if temp<=snow_temp-0.2:
				return TILES.ice
			return TILES.snow
		
		# Sakura
		elif temp <= -0.25:
			if abs(temp)<0.15:
				return TILES.white_stone	
			return TILES.sakura_grass
			
		elif temp <=-0.15:
			return TILES.log
			
		# Chaud
		elif temp >= desert_temp:
			if temp>=desert_temp+0.15:
				return TILES.sand_stone
			return TILES.sand
				
		elif temp >= 0.25:
			return TILES.autumn_grass
		elif temp >=0.15:
			return TILES.red_grass
		
		# Prairie
		else:
			return TILES.grass
	
	# -- Océan / Lacs -- #
	if y<-80 and y>-145:
		return TILES.water
	
	# -- BEDROCK -- #
	if abs(y - abyss_depth) <= 5:
		return TILES.deepstone
	
	# -- WHITE FLOOR -- #
	if y > white_floor_ceiling and y < white_floor:
		return TILES.air
	if y > white_floor:
		return TILES.white_stone

	if y > 40:
		# -- ABYSS -- #
		if y < abyss_depth:
			if cav > 0.3:
				var abyss_factor : float = abs(ab) + abs(y /50.0)
				if abyss_factor < 2.0:
					return TILES.gold
				else:
					if abyss_factor > 0 and abyss_factor < 5.0:
						return TILES.greencore
					return TILES.abyss
				return TILES.log
			else:	
				if cav>0.1:
					return TILES.gold#compact_stone
				return TILES.stone


		if cav > 0.5:

			# -- PRE ABYSS -- #
			if y < abyss_depth and y > abyss_depth - 50:
				if cav>0.5:
					return TILES.deepstone
				return TILES.compact_stone
			
			if layer<-0.5:
				return TILES.fuel
			if layer<-0.25:
				return TILES.ore
			if layer>0.5:
				return TILES.abyss_fuel
			if layer>0.25:
				return TILES.grass

		# -- Couches externes des cavernes -- #		
		elif cav > 0.3:
			if y > abyss_depth:
				return TILES.deepstone#abyss
			return TILES.compact_stone

	return TILES.air
