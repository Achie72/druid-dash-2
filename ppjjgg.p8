pico-8 cartridge // http://www.pico-8.com
version 42
__lua__


-- map loading
-- switchable blocks

function unload_map()
	-- empty all the arrays
	characters = {}
	particleCollection = {}
	mushroomCollection = {}
	stepsTaken = 0
	-- reset all the tiles on the 
	-- screen
	for x=0,15 do
		for y=0,15 do
			mset(x,y,0)
		end
	end
end


-- load map from a string. This string is stored in map-collection
-- and mapIndex is the passed level counter number.
function load_map(mapIndex)

	-- fetch the mapIndex-th element of the map collection
	local mapString = map_collection[mapIndex]
	-- init x,y
	local x,y = 0,0
	-- split the fetched string into numbers, so now it is {1,2,3,4,5} array
	-- instead of "1,2,3,4,5" string
	for tileId in all(split(mapString,",")) do
		-- iterate through each tileId (1,2,34, etc..)
		-- and handle them correctly
		-- the only tiles which we use as specials
		-- are gonna be the spirits = 12
		-- the mushrooms and the flips for the mushrooms
		if tileId == SPIRIT_TILE then
			-- if it is a spirit, spawn one on the coords
			-- and reset the tile to a grass (entities)
			-- I draw with sprites instead of tiles
			add_character(x, y)
			mset(x, y, 18)
		elseif tileId == MUSHROOM_ON_TILE then
			-- spawn a grown mushroom
			add_mushroom(x, y, true)
			mset(x, y, 18)
		elseif tileId == MUSHROOM_OFF_TILE then
			-- spawn an ungrown mushroom
			add_mushroom(x, y, false)
			mset(x, y, 18)
		else
			-- just set the tile accordingly
			mset(x, y, tileId)
		end
		-- iterate y first because most double for
		-- cycles read in as column by column
		y+=1
		if y > 15 then
			y = 0
			x += 1
		end
	end
end

-- export the currently drawn map to the clipboard
-- I used this in copied .p8 files to draw levels,
-- run them and copy the given string into this main
-- file's map collection
function export_map()
	-- start with empty string
	local mapString = ""
	-- loop over the map tile by tile
	-- and append tile numbers by , after each other
	-- this will give back a string similar to what
	-- you can see later in the map collection
	for x=0,15 do
		for y=0,15 do
			mapString = mapString..mget(x,y)..","
		end
	end
	-- paste the string onto the clipboard
	printh(mapString, '@clip')
end


-- function to add characters to the game
-- at any point on the map
function add_character(_x, _y)
	local p = {
		x = _x,
		y = _y,
		direction = 5,
		doReplaceOldTile = false,
		replaceTileId = 0,
		reachedGoal = false
	}
	-- set it's tile to the player tile
	-- mset(p.x, p.y, 4)
	-- add it to the collection
	add(characters, p)
end

-- add mushrooms to x, y. They are on-off
-- block that are triggered to flip their 
-- state when character steps on specific
-- tiles
function add_mushroom(_x, _y, _isOn)
	local m = {
		x = _x,
		y = _y,
		isOn = _isOn
	}
	add(mushroomCollection, m)
end

function add_particle(_x, _y, _sx, _sy, _lifetime, _color, _radius, _type)
	local part = {
		x = _x,
		y = _y,
		sx = _sx,
		sy = _sy,
		lifetime = _lifetime,
		color = _color,
		radius = _radius,
		type = _type
	}

	add(particleCollection, part)
end

function _init()
	map_collection = {
		"0,0,0,0,0,0,36,0,0,21,18,45,14,18,47,14,0,36,0,0,0,0,0,0,0,21,61,18,18,45,18,18,0,0,0,1,19,14,14,0,0,0,5,5,18,18,14,14,0,0,0,2,12,19,18,0,36,0,0,0,18,18,18,18,0,0,0,14,19,62,18,0,0,0,0,4,18,18,61,18,0,37,0,62,19,19,18,0,0,0,21,18,45,18,18,47,0,0,0,2,19,14,18,0,0,0,21,18,47,18,45,18,0,0,0,14,19,14,18,0,0,0,21,18,18,18,18,14,0,0,0,2,19,19,18,0,0,36,21,18,14,18,18,18,0,0,0,2,14,19,18,0,0,0,21,18,18,18,18,61,0,36,0,45,19,19,14,0,0,0,21,18,14,18,14,18,0,0,0,2,14,30,18,0,0,0,6,18,14,14,18,18,0,0,0,3,45,19,14,0,0,21,18,14,18,18,14,14,0,0,0,0,0,0,0,0,0,21,18,18,18,61,18,14,0,0,0,0,0,0,0,0,0,21,47,18,18,45,18,14,0,0,37,0,0,0,0,36,0,21,18,18,14,18,18,18,",
		"0,0,0,0,0,0,36,0,0,21,18,45,14,18,47,14,0,36,0,0,0,0,0,0,0,21,61,18,18,45,18,18,0,0,0,0,0,0,0,0,0,0,5,5,18,18,14,14,0,0,0,18,18,30,14,0,36,0,0,0,18,18,18,18,0,0,0,2,14,2,14,0,0,0,0,4,18,18,61,18,0,37,0,2,12,2,18,0,0,0,21,18,45,18,18,47,0,0,0,14,19,19,14,0,0,0,21,18,47,18,45,18,0,0,0,0,0,0,0,0,0,0,21,18,18,18,18,14,0,0,0,0,36,0,0,0,0,36,21,18,14,18,18,18,0,0,0,0,0,0,0,0,0,0,21,18,18,18,18,61,0,36,0,14,14,18,30,0,0,0,21,18,14,18,14,18,0,0,0,14,2,14,2,0,0,0,6,18,14,14,18,18,0,0,0,2,12,18,62,0,0,21,18,14,18,18,14,14,0,0,0,14,19,45,18,0,0,21,18,18,18,61,18,14,0,0,0,0,0,0,0,0,0,21,47,18,18,45,18,14,0,0,37,0,0,0,0,36,0,21,18,18,14,18,18,18,",
		"18,18,18,14,14,14,14,18,14,18,18,14,18,62,18,47,18,62,14,18,47,18,18,14,18,14,14,18,18,18,18,18,18,14,18,14,18,18,30,18,14,18,14,18,14,18,14,18,62,14,18,14,18,14,18,18,14,14,18,14,18,18,18,62,18,18,14,14,18,47,18,18,14,14,14,18,18,62,18,18,14,18,14,12,18,18,46,18,14,18,47,18,14,18,18,47,18,18,14,18,18,18,18,14,62,14,18,14,18,18,14,18,14,18,18,14,14,14,14,18,18,14,14,18,18,18,18,18,18,14,62,18,14,14,18,14,14,18,14,14,62,18,18,18,18,18,18,18,18,14,14,18,18,14,18,14,18,14,62,18,35,0,0,0,3,62,14,18,47,18,18,14,18,18,18,18,0,0,0,0,0,18,18,14,12,14,30,14,14,18,47,18,0,0,37,0,0,18,14,18,18,14,18,14,18,18,18,18,0,0,0,0,0,18,14,14,14,18,14,18,18,47,18,18,0,0,0,0,1,18,18,18,18,18,18,62,18,18,62,18,0,0,0,0,3,18,18,18,18,14,18,18,18,14,18,18,",
		"18,18,14,14,14,18,14,14,14,18,18,14,18,14,18,46,18,46,18,18,18,46,18,18,18,18,61,18,18,14,18,14,18,14,12,14,18,14,18,14,18,46,18,14,18,18,46,14,18,18,18,18,18,61,18,18,18,18,18,18,30,18,14,18,14,18,18,18,14,18,18,14,18,18,14,18,18,14,18,14,0,0,0,0,0,5,0,0,5,5,0,5,5,0,0,0,0,38,0,0,1,33,0,0,0,0,0,0,36,0,0,37,36,0,0,0,3,35,0,0,36,0,38,0,0,0,36,0,0,4,4,0,0,0,4,4,0,0,0,4,4,0,0,0,1,14,18,61,18,14,46,18,18,14,18,46,18,14,18,14,18,14,14,18,14,18,18,14,18,14,14,14,47,18,18,14,14,18,14,18,18,14,18,18,46,18,18,18,14,18,14,18,61,18,18,18,18,18,18,18,18,18,18,18,18,14,18,14,18,14,18,46,18,18,18,14,18,18,14,18,46,18,47,14,18,12,18,18,18,18,18,18,46,61,18,14,18,18,14,18,18,18,18,18,18,46,18,18,18,18,18,14,30,18,14,18,",
		"14,18,18,18,18,18,14,14,18,46,18,14,18,18,18,14,46,18,14,14,46,18,18,14,18,18,18,18,14,18,14,18,18,18,14,18,18,18,18,18,18,14,18,46,18,14,14,14,14,18,18,18,12,14,18,18,62,18,30,18,18,14,18,14,47,18,18,18,18,18,14,18,18,18,18,14,18,14,14,14,18,18,14,18,47,18,46,18,14,18,18,18,18,14,14,14,14,18,18,18,14,18,46,14,35,0,0,0,3,18,14,18,14,18,18,14,18,14,18,14,0,0,37,0,0,18,14,14,18,14,14,14,18,18,14,14,0,0,38,0,0,18,14,14,14,18,18,14,18,14,14,18,33,0,0,0,1,18,45,14,18,14,18,18,14,18,18,18,18,45,18,18,14,18,18,14,14,18,18,47,18,18,62,46,18,18,14,18,18,14,18,14,14,18,18,18,18,18,18,18,18,12,18,18,18,14,14,14,14,18,30,18,18,18,18,18,18,18,14,18,18,18,14,14,18,18,18,14,18,62,46,45,18,18,18,18,45,14,14,14,61,18,18,18,18,18,18,18,61,18,18,18,14,14,14,14,",
		"0,0,0,0,0,0,0,0,0,21,18,45,14,18,47,14,0,0,0,0,0,38,0,0,0,21,61,18,18,45,14,18,0,0,0,0,0,0,0,0,0,0,5,5,18,29,14,14,0,0,0,1,18,47,33,0,0,0,0,0,29,18,18,18,36,0,0,2,14,29,15,0,0,0,0,0,14,12,61,18,0,0,0,30,29,2,34,0,0,0,0,1,29,18,18,47,0,0,0,14,14,19,15,0,0,0,0,18,47,29,29,14,0,0,0,2,14,2,2,2,2,33,0,47,18,18,18,14,0,0,0,14,2,2,46,2,14,34,0,18,14,18,18,18,0,0,0,14,14,27,2,12,47,34,0,18,18,18,14,61,0,36,0,2,14,18,2,2,2,35,0,18,47,18,18,18,0,0,0,14,2,14,34,0,0,0,0,18,18,30,18,18,0,0,0,2,47,18,14,0,0,0,0,14,18,18,18,14,0,37,0,3,14,45,35,0,0,0,21,18,18,61,18,18,0,0,0,0,0,0,0,0,0,0,21,18,18,45,18,14,0,0,37,0,0,0,0,36,0,0,21,18,14,14,14,18,",
		"18,18,14,18,14,18,18,18,18,18,34,0,0,0,0,0,14,18,18,14,18,18,14,18,47,18,34,0,0,0,36,0,18,14,14,29,29,29,14,14,18,61,34,0,37,0,0,0,18,18,14,47,18,18,14,18,14,18,34,0,0,0,0,37,18,18,14,18,12,18,14,18,14,18,34,0,0,0,0,0,14,14,14,18,18,18,14,14,18,18,34,0,0,0,0,0,18,18,14,29,29,29,14,61,18,46,34,0,0,0,37,0,47,18,14,18,18,18,18,18,18,18,34,0,0,0,0,0,14,18,14,18,30,18,18,46,18,18,34,0,0,0,0,0,18,14,18,14,18,18,14,47,18,61,34,0,0,0,36,0,18,18,47,18,18,14,18,18,18,18,34,0,37,0,0,0,18,14,18,14,14,14,18,14,18,46,34,0,0,0,0,0,18,18,14,18,18,18,18,18,14,18,34,0,0,0,0,0,14,18,14,27,18,12,18,18,29,30,34,0,0,0,0,0,18,14,18,18,18,18,18,18,18,14,34,0,36,0,0,37,18,47,14,14,18,14,14,18,14,18,34,0,0,0,0,0,",
		"18,28,27,28,14,47,46,14,18,14,18,18,18,18,62,18,14,18,28,18,18,18,18,18,18,18,14,62,18,18,18,18,47,18,18,18,46,18,14,18,29,18,14,18,62,14,18,18,18,18,12,18,18,18,18,29,30,29,18,14,18,18,18,14,18,18,18,18,18,18,18,18,29,18,14,18,18,45,18,18,14,18,18,18,47,18,18,18,18,18,14,18,18,18,18,18,14,18,18,18,47,18,18,46,18,14,18,18,18,47,47,18,18,14,27,14,18,18,14,18,14,14,18,18,47,18,18,47,14,14,14,14,14,14,18,14,14,18,14,18,47,18,18,47,14,18,18,18,14,18,14,18,18,14,18,18,18,47,47,18,18,18,47,18,18,18,18,18,14,14,14,18,18,18,18,62,18,62,18,62,18,47,18,14,18,18,18,14,18,18,18,18,14,18,12,18,18,18,18,29,30,18,14,18,18,14,18,18,18,18,18,18,14,18,18,18,14,18,18,14,18,18,45,18,18,14,18,14,18,18,18,18,14,14,18,14,18,45,18,14,18,18,27,18,18,18,62,18,28,14,14,18,18,14,18,18,",
		"47,18,18,47,18,14,18,18,18,18,18,14,18,14,18,18,14,46,18,46,18,14,14,18,18,14,14,18,18,18,14,18,18,12,18,18,46,18,14,14,18,14,18,12,18,18,14,18,18,18,18,46,18,18,14,18,18,14,18,18,18,18,18,14,46,18,18,18,18,18,18,14,18,14,18,18,18,45,18,18,18,18,18,18,47,14,18,18,14,18,14,18,14,18,18,18,14,18,18,18,18,14,18,14,18,14,18,18,18,14,18,18,47,18,46,47,14,18,14,18,14,18,18,18,18,18,18,14,18,18,18,18,18,14,14,14,14,18,18,18,14,18,18,18,14,28,14,18,14,18,27,14,18,14,18,18,18,18,18,14,18,18,18,14,18,18,18,14,18,18,14,28,14,14,14,14,18,18,14,18,18,18,18,18,18,18,18,18,18,18,14,18,14,30,18,14,18,30,12,14,18,14,18,30,18,18,18,14,18,18,18,14,18,18,18,18,14,18,18,18,18,18,45,18,46,46,18,14,18,14,27,14,18,18,14,18,14,18,14,18,18,18,14,18,14,18,14,18,18,18,18,14,18,18,18,18,",
		"47,18,14,47,18,14,14,14,14,14,18,18,18,18,46,18,18,18,18,18,14,14,18,46,18,27,14,18,61,14,18,18,14,62,18,14,14,18,12,18,46,14,18,18,18,18,61,18,18,18,18,46,14,46,18,18,18,14,18,46,18,18,18,18,18,62,18,18,18,14,29,14,46,18,14,18,18,18,14,46,18,18,14,18,18,46,18,18,14,14,18,18,14,18,18,18,18,14,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,62,18,18,51,18,18,46,49,18,18,18,18,18,62,18,18,18,18,47,47,47,18,18,18,18,46,18,18,14,18,51,18,18,47,18,18,18,47,49,18,18,18,18,18,18,18,18,51,18,47,18,30,18,47,18,18,18,18,18,46,18,18,48,18,18,47,18,18,18,47,18,50,18,18,18,18,61,18,18,48,18,18,47,47,47,18,50,18,18,14,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,62,18,14,18,62,18,18,18,18,18,14,18,18,14,18,18,18,18,18,18,18,18,18,62,18,18,18,18,46,18,18,",
		"47,18,14,14,18,14,18,18,14,18,18,18,18,18,46,18,18,18,18,18,14,18,14,46,18,18,18,18,61,14,18,18,14,62,18,14,14,18,50,12,18,29,18,18,18,18,61,18,18,18,14,46,14,14,18,27,18,18,18,46,18,18,18,18,18,62,14,48,18,18,14,18,18,18,18,18,18,18,14,46,28,18,14,18,18,47,47,47,14,18,14,18,14,14,18,14,18,14,28,18,47,18,18,18,47,18,18,18,18,18,14,18,12,18,28,47,27,30,18,30,18,47,18,14,18,18,18,18,62,28,18,47,18,18,18,18,18,47,18,18,18,28,29,14,28,51,18,47,18,30,18,30,18,47,18,18,28,12,18,29,18,18,18,18,47,18,18,18,47,18,18,14,18,28,29,18,18,18,18,18,18,47,47,47,18,14,18,18,18,18,18,61,18,48,18,18,18,18,28,18,18,18,18,18,14,18,27,18,18,18,18,18,18,27,18,18,18,18,14,18,18,14,29,14,18,62,14,18,14,12,18,18,18,18,28,14,18,18,14,18,18,14,18,48,28,18,18,18,62,18,18,18,18,14,18,18,",
		"18,18,18,14,12,18,18,18,18,18,18,49,18,18,18,46,61,18,18,14,12,18,18,18,18,30,18,18,18,45,18,18,18,18,18,18,14,18,18,18,18,18,18,30,18,18,18,18,18,46,14,18,47,47,47,18,18,18,18,18,46,18,46,18,18,18,18,47,18,18,18,47,47,18,18,18,18,18,18,18,14,18,61,47,18,18,18,18,18,47,18,18,18,18,18,35,18,18,18,47,18,18,18,18,18,18,47,18,18,0,0,0,18,14,18,18,47,18,18,18,18,18,18,47,18,33,0,37,46,14,18,18,47,18,18,18,18,18,18,47,18,35,0,38,18,18,18,47,18,18,18,18,18,18,47,18,18,0,0,0,14,18,61,47,18,18,18,18,18,47,18,18,18,18,18,33,18,18,18,47,18,18,18,47,47,18,18,18,46,18,18,18,18,18,14,18,47,47,47,18,18,18,18,18,18,18,18,18,46,18,18,18,14,45,18,18,18,18,18,30,18,18,46,18,18,18,18,14,12,18,18,18,18,30,18,18,46,18,18,18,18,61,18,14,12,18,18,18,18,18,18,48,18,18,18,18,",
		"0,0,0,0,0,0,36,0,0,21,18,28,14,18,47,14,0,36,0,0,0,0,0,0,0,21,61,18,18,45,18,18,0,0,0,0,0,0,0,0,0,0,5,5,18,18,14,14,0,0,0,0,0,0,0,0,0,0,0,0,18,12,18,29,0,0,0,0,0,0,0,0,0,0,0,4,18,18,61,18,0,37,0,0,0,0,0,0,0,0,21,18,45,18,18,47,0,0,0,0,0,0,0,0,0,0,21,18,47,30,45,18,0,0,0,0,0,0,0,0,0,0,21,18,18,18,18,14,0,0,0,0,0,0,0,0,0,0,21,18,14,18,18,18,0,0,0,0,0,0,0,0,0,0,21,18,18,18,18,61,0,36,0,0,0,0,0,0,0,0,21,18,14,18,14,18,0,0,0,0,0,0,0,0,0,0,6,18,14,14,18,18,0,0,0,0,0,0,0,0,0,21,18,14,18,18,14,14,0,0,0,0,0,0,0,0,0,21,18,18,18,61,18,14,0,0,0,0,0,0,0,0,0,21,47,18,31,45,18,14,0,0,37,0,0,0,0,36,0,21,18,18,14,18,18,18,"
	}
	level = 1

	export_map()
	-- have a direction table that shows how to move 
	-- on x and y to get to the next tile in said direction
	-- it is always mapped to the buttons, so 0 is left, 1 is right
	-- 2 is up, 3 is down, 4 is neutral
	directionTable = {
		{-1, 0}, {1, 0}, {0, -1}, {0, 1}, {0, 0}
	}
	characters = {}
	--add_character(5,4)
	--add_character(12,4)
--	add_character(4,10)
--	add_character(10,10)

	-- create the state machine
	-- and the various update and draw
	-- functions for each state
	state = "menu"
	TREE_TILE = 14
	TREE_TILE_WATER = 15
	SHRINE_TILE = 30
	SPIRIT_TILE = 12
	MUSHROOM_ON_TILE = 29
	MUSHROOM_OFF_TILE = 28
	MUSHROOM_FLIP = 27

	-- store all he particles here
	particleCollection = {}
	mushroomCollection = {}
	unload_map()
	load_map(13)
	steps = 0
	stepsTaken = 0
	music(0)
end

function _update()
	if state == "menu" then
		update_menu()
	elseif state == "game" then
		update_game()
	elseif state == "won" then
		update_won()
	elseif state == "select" then
		update_select()
	end
end

function update_menu()
	-- just press a button to get
	-- into the game
	if btnp(5) then
		state ="game"
		unload_map()
		load_map(1)
	end
end

function update_game()
	-- let's say we won already
	local won = true
	-- check movement for each character
	for i=1,#characters do
		update_player(i)
		if (characters[i].reachedGoal != true) then won = false end
	end

	if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
		stepsTaken += 1
	end

	if btnp(4) then
		unload_map()
		load_map(level)
	end

	update_particles()

	if won and (#particleCollection == 0) then
		state = "won"
		steps += stepsTaken
	end
end

function update_won()
	if btnp(5) then
		if level == 12 then
			steps = 0
			state = "menu"
			level = 1
		else
			level += 1
			unload_map()
			load_map(level)
			state = "game"
		end
	end
	if btnp(4) then
		steps -= stepsTaken
		unload_map()
		load_map(level)
		state = "game"
	end

end

function update_particles()
	-- loop over each particle and 
	-- update it is
	for index=#particleCollection, 1, -1 do
		local particle = particleCollection[index]
		-- now we have the particleicle
		-- move it with speed inside sx and sy
	 	particle.x += particle.sx
		particle.y += particle.sy
		-- reduce the lifetime
		particle.lifetime -= 1
		-- handles particle types differently
		if particle.type == 1 then
			-- shrink the particle as it gets older
			local sizeTable = {0.5, 1, 1.5, 2}
			local sizeIndex = flr(particle.lifetime/2)+1
			particle.radius = sizeTable[sizeIndex]
		end


		if particle.lifetime <= 0 then
			del(particleCollection, particle)
		end

	end

end

function update_player(_index)
	local character = characters[_index]

	-- save pressed direction for character
	-- only count if the character is already stopped
	-- or only move if it is not in the goal position
	if (character.direction == 5) and (not character.reachedGoal) then
		if btnp(0) then character.direction = 1 end
		if btnp(1) then character.direction = 2 end
		if btnp(2) then character.direction = 3 end
		if btnp(3) then character.direction = 4 end
	end

	-- see if next tile in that direction is walkable
	local nextTile = mget(character.x + directionTable[character.direction][1], character.y + directionTable[character.direction][2])
	local newPosX, newPosY = character.x + directionTable[character.direction][1], character.y + directionTable[character.direction][2]
		
	local isNewTileEmpty = true
	-- if it is not empty void
	-- move the character there
	-- 0 is void, 2 is wall for now
	-- do not allow the step if ther eis another character there
	for chr in all(characters) do
		if chr != character then
			if (chr.x == newPosX) and (chr.y == newPosY) then
				isNewTileEmpty = false
			end
		end
	end
	-- also set isNewTileEmpty if there is a muhrooom there
	-- only want to count the mush that is on
	for mush in all(mushroomCollection) do
		if (mush.x == newPosX) and (mush.y == newPosY) and (mush.isOn) then
			isNewTileEmpty = false
		end
	end

	if (character.direction != 5) then
		sfx(0)
	end

	if (nextTile != 0) and (nextTile != TREE_TILE) and (nextTile != TREE_TILE_WATER) and (isNewTileEmpty) and (not character.reachedGoal) then
		local oldPosX, oldPosY = character.x, character.y
		-- if the player was on a normal tile, reset it to that (1)
		-- if the player was on a directional tile and has it's replace
		-- flag set, then fetch the directional tile that I need to replace
		-- this is what will preserve the arrow tiles instead of just replacing them with
		-- normal empty tiles
		-- local tileToReset = character.doReplaceOldTile and character.replaceTileId or 1
		-- if I have fetched the new reset tile, then turn off the flag for it
		-- if tileToReset != 1 then character.doReplaceOldTile = false end
		
		-- move the character
		character.x, character.y = newPosX, newPosY
		
		add_particle(character.x*8+4, character.y*8+4, 0, 0, 8, 7, 1, 1)
		-- check if new tile is redirectional
		if (nextTile > 47) and (nextTile < 52) then
			-- arrow tiles are 48,49,50,51
			-- if I substract 47 then I conver the
			-- tileId to the direction it represents
			character.direction = nextTile - 47

			-- set the flag so the character remembers to set it back
			-- character.doReplaceOldTile = true
			-- save what needs to be reset
			-- character.replaceTileId = nextTile
		end
		-- reset the tile the character was on
		-- mset(oldPosX, oldPosY, tileToReset)
		-- this is what sets the character
		-- mset(newPosX, newPosY, 4)

		-- we want to check if the player's next tile is a flip tile
		-- for mushromms, is so we want to inver them
		-- only allow the flip if the character on is stationary
		if (nextTile == MUSHROOM_FLIP) and (character.direction != 5) then
			for mush in all(mushroomCollection) do
				for i=0,8 do
					-- let's have two color pairs, one for mush goin down, one for mush going up
					local colorPairs = { {8,7}, {4,8}}
					-- if mush is on, then it is gonna go down,
					-- so we grab the second pair from colors,
					-- if it is off then it is going up, so we want
					-- the white-red
					local colorIndex = mush.isOn and 2 or 1
					add_particle(mush.x*8+4, mush.y*8+4, rnd({-0.5, 0.5})*rnd(), -rnd(), 15, rnd(colorPairs[colorIndex]), rnd({0.5,1})) 
				end
				local play = mush.isOn and sfx(4) or sfx(3)
				mush.isOn = not mush.isOn
			end
		end


		-- if the spirit is in the shrine
		if (nextTile == SHRINE_TILE) and (character.reachedGoal == false)  then
		sfx(1)
			character.reachedGoal = true
			character.direction = 5
			mset(newPosX, newPosY, SHRINE_TILE + 1)
			-- let's add more particle to it
			for i=0,15 do
				add_particle(character.x*8+4, character.y*8+4, rnd({-1, 1})*rnd(), -rnd(), 30, rnd({12,14}), rnd({0.5, 1})) 
			end
		end
	else
		-- if movement is not possible do to void(0), wall(2) 
		-- or another player(4) then stop movement
		character.direction = 5
	end

end

function _draw()
	if state == "menu" then
		draw_menu()
	elseif state == "game" then
		draw_game()
	elseif state == "won" then
		draw_won()
	elseif state == "select" then
		draw_select()
	end
end

function draw_menu()
	cls()
	draw_game()

	spr(68, 40, 20, 6, 3)
	local subt ="pesky parallel panic"
	printc(subt, 50, 7)
	local texts = {
		"spirits alose, help luna",
		"shepherd them back to their",
		"shrines",
		"⬅️⬇️⬆️➡️,❎start"
	}
	for t=1,#texts do
	  printc(texts[t], 58+t*8, 7, 12)
	end
end

function draw_game()
	cls(12)
	map()
	if (level == 1) and (state == "game") then
		local txt = "⬅️⬇️⬆️➡️"
		printc(txt, 88, 11, 3)
	end
	draw_particles()

	-- draw the mushroom
	for mush in all(mushroomCollection) do
		spr(mush.isOn and MUSHROOM_ON_TILE or MUSHROOM_OFF_TILE, mush.x*8, mush.y*8)
	end

	-- when drawing characters create a few circles that can
	-- wiggle around how they want
	for character in all(characters) do
		local sprite = (time()%0.5 > 0.25) and 12 or 13
		if (not character.reachedGoal) then
			spr(sprite, character.x*8, character.y*8)
		end
		--print("웃", character.x*8, character.y*8, 7)
	end
	if level == 12 then
		local title = "♥ 4 playing♥"
		local subtitle = "steps taken:"..steps

		for i=1,#title do
			print_outline(title[i], (61-#title*2)+i*4, 36+sin((time()+i)/20)*1.2, 1)
		end
		for i=1,#subtitle do
			print_outline(subtitle[i], (61-#subtitle*2)+i*4, 44+sin((time()+i)/20)*1.2, 1)
		end
	end
	if state == "game" then
		print_outline("c:restart", 2, 120, 7, 3)
	end
end

function draw_particles()
	-- we don't have to worry about deleting stuff
	-- so we can use for all
	for particle in all(particleCollection) do
		circfill(particle.x, particle.y, particle.radius, particle.color)
	end
end

function draw_won()
	cls()
	draw_game()
	local title = "spirits in place"
	printc(title, 42, 7, 12)
	local stepstook = "steps:"..stepsTaken
	printc(stepstook, 50, 7, 14)
	local instr = "c:retry,x:next"
	printc(instr, 70, 7, 1)
end

function printc(text, y, c, o)
	local len = print(text, 0, 200)
	if (not o) then
		print(text, 64-len/2, y, c)
	else
		print_outline(text, 64-len/2, y, c, o)
	end
end

function print_outline(_txt,_x,_y,_clr,_bclr)
    -- if we don't pass a background color set it to white
    if _bclr == nil then _bclr = 7 end

    -- draw the text with the outline color offsetted in each direction
    -- based from the original text position we want to draw.
    -- This will create a big blob of singular colors, which's outliens
    -- will perfectly match the printed text outline
    for x=-1,1 do
        for y=-1,1 do
            print(_txt, _x-x, _y-y, _bclr)
        end
    end

    -- draw the original text with the intended color in the middle
    -- of the blob, creating the outline effect
    print(_txt, _x, _y, _clr)
end






















__gfx__
000000003333333333333333333333300000000330000000000000030000000000000000000000000eeeeeeeeeeeeee000011000000000003311113333111133
000000000333333333333333333333330000000330000000000000030000000000000000000000000eeeeeeeeeeeeee0001771000001100031bbb31331bbb313
007007003333333333333333333333330000000330000000000000030000000000000000000000000eeeeeeeeeeeeee0017777100017710031b3b31331b3b313
000770003333333333333333333333330000000330000000000000030000000000000000000000000eeeeeeeeeeeeee0171177710171771031b3331331b33313
0007700033333333333333333333333300000003300000000000000300000000000000000000000000000000000eeee001171711001177711bbbbbb11bbbbbb1
007007003333333333333333333333330000000330000000000000030000000000000000000000000eeee0eeee0eeee000177771001717111112411111124111
000000003333333333333333333333330000000330000000000000030000000000000000000000000eeee0eeee0eeee000117711000177711112411131124113
000000003333333333333333333333330000000330000000333333330000000000000000000000000eeee0eeee0eeee0000111100001111131111113d555555d
000000003333333333333333333333333333333300000000000000000000000000000000000000000eeee0ee3333333300000000001111003313313333f33133
0000000033333333333333333333333300000000000000000000000000000000000000000000000000000000333111330000000001887710313115133fef1613
000000003333333333333333333333330000000000000000000000000000000000000000000000000eeee0ee3316661300000000187877813135551331366613
000000003333333333333333333333330000000000000000000000000000000000000000000000000eeee0ee31655561000000001888888131515113316c6c13
000000003333333333333333333333330000000000000000000000000000000000000000000000000eeee0ee3311611300011000189ff9813155551331666613
000000003333333333333333333333330000000000000000000000000000000000000000000000000eeee0ee3331613300187100001ff1003313513333136133
00000000333333333333333333333333000000000000000000000000000000000000000000000000000000003311111301788810011ff1103113311331133113
00000000333333333333333333333333000000003333333300000000000000000000000000000000000000003333333300111100011111103111111331111113
00000000333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
00000000333333333333333333333333033003300000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
00000000333333333333333333333333033333300000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
000000003333333333333333333333330333333000003300003300000000000000000000000000000000000000000000000000003333333333333333333f3333
00000000333333333333333333333333033333300040339009330400000000000000000000000000000000000000000000000000333333333333333333fef333
000000003333333333333333333333330d3333d0004422000022440000000000000000000000000000000000000000000000000033b333333333b33333bf3333
00000000d3333333333333333333333d00dddd00001111000011110000000000000000000000000000000000000000000000000033b3b33333b3b3b3333b33b3
000000000dddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
33333333333313333331333333333333000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
33133333333141333314113333311333000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
31411133331111133111141333144133000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
311144133144414114141133331441130000000000000000000000000000000000000000000000000000000000000000000000003387333333333b3333333333
14144413314411133114413333114141000000000000000000000000000000000000000000000000000000000000000000000000378883333333b3b333333333
3111113333111413331441333141111300000000000000000000000000000000000000000000000000000000000000000000000033ff33b33b33b33333333333
331413333333313333311333331141330000000000000000000000000000000000000000000000000000000000000000000000003333333333b3b33333333333
33313333333333333333333333331333000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
00000000000000000000000000000000007777777007777777007700007707777770777777700000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007777777707777777707700007707777770777777770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007700000007707700007700000000000000770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007702207707702207707702207700077000770220770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007702207707702207707702207702077020770220770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007700007707700007707700007702077020770000770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007702207707707777707702207702077020770220770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007702207707707777707702207700077000770220770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007700007707700007707700007700000000770000770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007707777707702207707777777707777770770777770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007707777007700007700777777007777770770777700000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007777777000777777000777777007700007700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007777777707777777707777777707700007700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000007707700007707700000007702207700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007702207707702207707700000007702207700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007702207707702207707777777007700007700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007700007707700007700777777707777777700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007702207707777777700000007707777777707770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007702207707777777702020207707700007700070000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007700007707700007700000007707702207707770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007707777707702207707777777707702207707000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007707777007700007700777777007700007707770000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccc33cc33cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc33cc33ccccccccccccccccccccccccccccccccccccccccc
ccccccccc333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc333333ccccccccccccccccccccccccccccccccccccccccc
ccccccccc333333ccccccccccccccccccccccccccccc33ccccccccccccccccccccccccccccccccccc333333ccccccccccccccccccccccccccccccccccccccccc
ccccccccc333333ccccccccccccccccccccccccccc4c339cccccccccccccccccccccccccccccccccc333333ccccccccccccccccccccccccccccccccccccccccc
cccccccccd3333dccccccccccccccccccccccccccc4422cccccccccccccccccccccccccccccccccccd3333dccccccccccccccccccccccccccccccccccccccccc
ccccccccccddddcccccccccccccccccccccccccccc1111ccccccccccccccccccccccccccccccccccccddddcccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc33cc
cccccccccccccccccccccccccccccccccccccccccc7777777cc7777777cc77cccc77c777777c7777777ccccccccccccccccccccccccccccccccccccccc4c339c
cccccccccccccccccccccccccccccccccccccccccc77777777c77777777c77cccc77c777777c77777777cccccccccccccccccccccccccccccccccccccc4422cc
cccccccccccccccccccccccccccccccccccccccccccccccc77ccccccc77c77cccc77cccccccccccccc77cccccccccccccccccccccccccccccccccccccc1111cc
cccccccccccccccccccccccccccccccccccccccccc77c22c77c77c22c77c77c22c77ccc77ccc77c22c77cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccc77c22c77c77c22c77c77c22c77c2c77c2c77c22c77cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccc77cccc77c77cccc77c77cccc77c2c77c2c77cccc77cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccc77c22c77c77c77777c77c22c77c2c77c2c77c22c77cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccc77c22c77c77c77777c77c22c77ccc77ccc77c22c77cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccc77cccc77c77cccc77c77cccc77cccccccc77cccc77cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccc77c77777c77c22c77c77777777c777777c77c77777cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccc77c7777cc77cccc77cc777777cc777777c77c7777ccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc7777777ccc777777ccc777777cc77cccc77cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc77777777c77777777c77777777c77cccc77cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc77c77cccc77c77ccccccc77c22c77cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc77c22c77c77c22c77c77ccccccc77c22c77cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc77c22c77c77c22c77c7777777cc77cccc77cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc77cccc77c77cccc77cc7777777c77777777cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc77c22c77c77777777ccccccc77c77777777c777cccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc77c22c77c77777777c2c2c2c77c77cccc77ccc7cccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc77cccc77c77cccc77ccccccc77c77c22c77c777cccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc77c77777c77c22c77c77777777c77c22c77c7cccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc77c7777cc77cccc77cc777777cc77cccc77c777cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c33cc33ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c333333ccccccccccccccccc777c777cc77c7c7c7c7ccccc777c777c777c777c7ccc7ccc777c7ccccccc777c777c77cc777cc77ccccccccccccccccccccccccc
c333333ccccccccccccccccc7c7c7ccc7ccc7c7c7c7ccccc7c7c7c7c7c7c7c7c7ccc7ccc7ccc7ccccccc7c7c7c7c7c7cc7cc7ccccccccccccccccccccccccccc
c333333ccccccccccccccccc777c77cc777c77cc777ccccc777c777c77cc777c7ccc7ccc77cc7ccccccc777c777c7c7cc7cc7ccccccccccccccccccccccccccc
cd3333dccccccccccccccccc7ccc7ccccc7c7c7ccc7ccccc7ccc7c7c7c7c7c7c7ccc7ccc7ccc7ccccccc7ccc7c7c7c7cc7cc7ccccccccccccccccccccccccccc
ccddddcccccccccccccccccc7ccc777c77cc7c7c777ccccc7ccc7c7c7c7c7c7c777c777c777c777ccccc7ccc7c7c7c7c777cc77ccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc33cc33c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc333333c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc333333c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc333333c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd3333dc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddddcc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
3333333333333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc33333333333333333333333333333333
33333333333333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc333333333333333333333333333333333
33333333333333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc333333333333333333333333333333333
33333333333333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc333333333333333333333333333333333
33333333338733333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc33333333333333333333f333333333333
33333333378883333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3333333333333333333fef33333333333
3333333333ff33b33cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3333333333333333333bf333333333333
33333333333333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc33333333333333333333b33b333333333
33333333333333333ccccccccccccccccccccccc3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333cccccccccccccccccccccc33333333333333333333333333333333333333333333333333333333333111133333333333333333333333333
33333333333333333cccccccccccccccccccccc33333333333333333333333333333333333333333333333333333333331bbb313333333333333333333333333
33333333333333333cccccccccccccccccccccc33333333333333333333333333333333333333333333333333333333331b3b313333333333333333333333333
33333333333333333cccccccccccccccccccccc33333333333333333333333333333333333333333333333333333333331b33313333333333333333333333333
33311333333333333cccccccccccccccccccccc3333333333333333333333333333333333333333333333333333333331bbbbbb1333333333333333333333333
33187133333333333cccccccccccccccccccccc33333333333333333333333333333333333333333333333333333333311124111333333333333333333333333
31788813333333333cccccccccccccccccccccc33333333333333333333333333333333333333333333333333333333311124111333333333333333333333333
33111133333333333cccccccccccccccccccccc33333333333333333333333333333333333333333333333333333333331111113333333333333333333333333
331111333333333333333333333333333333333333333333333333333333333333111133333333333311113333111133333333333333333333f3313333111133
31bbb3133333333333333333333333333333333333333333333333333333333331bbb3133333333331bbb31331bbb31333333333333333333fef161331bbb313
31b3b3133333333333333333333333333333333333333333333333333333333331b3b3133333333331b3b31331b3b31333333333333333333136661331b3b313
31b333133333333333333333333333333333333333333333333f33333333333331b333133333333331b3331331b333133333333333333333316c6c1331b33313
1bbbbbb1333333333333333333333333333333333333333333fef333333333331bbbbbb1333333331bbbbbb11bbbbbb13333333333333333316666131bbbbbb1
111241113333333333333333333333333333333333b3333333bf3333333333331112411133333333111241111112411133333333333333333313613311124111
111241113333333333333333333333333333333333b3b333333b33b3333333331112411133333333111241111112411133333333333333333113311311124111
31111113333333333333333333333333333333333333333333333333333333333111111333333333311111133111111333333333333333333111111331111113
33333333333333333333333333333333333333333333333333133133333333333333333333333333333333333311113333333333333333333333333333333333
333333333333333333333333333113333333333333333333313115133333333333333333333333333333333331bbb31333333333333333333333333333333333
333333333333333333333333331771333333333333333333313555133333333333333333333333333333333331b3b31333333333333333333333333333333333
333333333333333333333333317177133333333333333333315151133333333333333333333333333333333331b3331333333333338733333333333333333333
33333333333333333333333333117771333333333333333331555513333333333333333333333333333333331bbbbbb133333333378883333333333333333333
3333333333b33333333333333317171133333333333333333313513333333333333333333333333333333333111241113333333333ff33b333b3333333333333
3333333333b3b33333333333333177713333333333333333311331133333333333333333333333333333333311124111333333333333333333b3b33333333333
33333333333333333333333333311111333333333333333331111113333333333333333333333333333333333111111333333333333333333333333333333333
33333333333333333311113333333333333333333333333333333333333333333333333333333333331111333333333333111133333333333333333333333333
333333333333333331bbb3133333333333333333333333333333333333333333333333333333333331bbb3133333333331bbb313333333333333333333333333
333333333333333331b3b3133333333333333333333333333333333333333333333333333333333331b3b3133333333331b3b313333333333333333333333333
333f33333333333331b333133333333333873333333333333333333333333333333333333333333331b333133333333331b33313333333333333333333333333
33fef333333333331bbbbbb1333333333788833333333333333333333333333333333333333333331bbbbbb1333333331bbbbbb1333333333333333333333333
33bf333333333333111241113333333333ff33b33333333333b33333333333333333333333333333111241113333333311124111333333333333333333333333
333b33b3333333331112411133333333333333333333333333b3b333333333333333333333333333111241113333333311124111333333333333333333333333
33333333333333333111111333333333333333333333333333333333333333333333333333333333311111133333333331111113333333333333333333333333
33111133333333333311113333111133333333333333333333333333331111333333333333333333333333333333333333111133331111333311113333333333
31bbb3133333333331bbb3133188771333333333333333333333333331bbb3133333333333333333333333333333333331bbb31331bbb31331bbb31333333333
31b3b3133333333331b3b3131878778133333333333333333333333331b3b3133333333333333333333333333333333331b3b31331b3b31331b3b31333333333
31b333133333333331b333131888888133333333333f33333333333331b333133333333333873333333333333333333331b3331331b3331331b3331333333333
1bbbbbb1333333331bbbbbb1189ff9813333333333fef333333333331bbbbbb1333333333788833333333333333333331bbbbbb11bbbbbb11bbbbbb133333333
111241113333333311124111331ff1333333333333bf333333333333111241113333333333ff33b3333333333333333311124111111241111112411133333333
111241113333333311124111311ff11333333333333b33b333333333111241113333333333333333333333333333333311124111111241111112411133333333
31111113333333333111111331111113333333333333333333333333311111133333333333333333333333333333333331111113311111133111111333333333

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0024000000250000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000002500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515000000000000000000001515151500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
123d0500001515151515150612122f1200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c12050004121212121212120e12121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e121212122d2f120e120e0e12121f0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
122d120c12121e121212120e123d2d1200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f120e123d122d1212120e120e12121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e120e1d122f120e123d12120e0e0e1200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000004550055500855015550145501455014550185501e5401f540245302d52021520275102a500205002d5002e5003250032500325002e500265002650026500265002650032500265002e5003a5002e500
0008000012500175001e5001e5001a5001b500185001a5001d500195001d5001d5003850000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100001b0501c0501d0501f0502005023050250502c050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000240501e050170501105009050060500305003050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c033000030c033000030e633000030e0330000300003000030e03300003106330000300003000030c033000030c033000031163300003110330000300003000030e0330000310633000030000000000
01100000105301050010530105000e5300e5000e5300e50413505135001353013500105301050010500105000e530005000e53000500105300050010530005000050000500135301150010530005000050000500
0110000011530100001153010000155300e000155300e504135051350017530135001153010500105001050015530000001553000000175300000017530000000000000000135301150015530000000000000000
01100000105301000010530100000e5300e0000e5300e50413505135000e5301350010530105001050010500115300000011530000000e530000000e530000000000000000105301150010530000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000107301070010730107000e7300e7000e7300e70413705137001373013700107301070010700107000e730007000e73000700107300070010730007000070000700137301170010730007000070000700
0110000011730107001173010700157300e700157300e704137051370017730137001173010700107001070015730007001573000700177300070017730007000070000700137301170015730007000070000700
01100000107301070010730107000e7300e7000e7300e70413705137000e7301370010730107001070010700117300070011730007000e730007000e730007000070000700107301170010730007000070000700
__music__
01 0a140944
00 0b150944
02 0c160944

