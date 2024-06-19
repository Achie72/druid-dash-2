pico-8 cartridge // http://www.pico-8.com
version 42
__lua__


-- level completion
-- drawing stuff (tiles)

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

	-- have a direction table that shows how to move 
	-- on x and y to get to the next tile in said direction
	-- it is always mapped to the buttons, so 0 is left, 1 is right
	-- 2 is up, 3 is down, 4 is neutral
	directionTable = {
		{-1, 0}, {1, 0}, {0, -1}, {0, 1}, {0, 0}
	}
	characters = {}
	add_character(4,4)
	add_character(10,4)
	add_character(4,10)
	add_character(10,10)

	-- create the state machine
	-- and the various update and draw
	-- functions for each state
	state = "menu"
	TREE_TILE = 14
	SHRINE_TILE = 30

	-- store all he particles here
	particleCollection = {}
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

	update_particles()

	if won then
		state = "won"
	end
end

function update_won()
	if btnp(5) then
		_init()
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
		
	local noSpiritOnTile = true
	-- if it is not empty void
	-- move the character there
	-- 0 is void, 2 is wall for now
	-- do not allow the step if ther eis another character there
	for chr in all(characters) do
		if chr != character then
			if (chr.x == newPosX) and (chr.y == newPosY) then
				noSpiritOnTile = false
			end
		end
	end


	if (nextTile != 0) and (nextTile != TREE_TILE) and (noSpiritOnTile) and (not character.reachedGoal) then
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

		-- if the spirit is in the shrine
		if (nextTile == SHRINE_TILE) and (character.reachedGoal == false)  then
			character.reachedGoal = true
			character.direction = 5
			-- let's add more particle to it
			for i=0,15 do
				add_particle(character.x*8+4, character.y*8+4, rnd({-0.2, 0.2}), -rnd(), 30, 14, rnd({0.5, 1})) 
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
	print(state, 0, 120, 8)
end

function draw_menu()
	cls()
	print("menu", 64, 64, 7)
end

function draw_game()
	cls(12)
	map()

	draw_particles()

	-- when drawing characters create a few circles that can
	-- wiggle around how they want
	for character in all(characters) do
		local sprite = (time()%0.5 > 0.25) and 12 or 13
		local offset = character.reachedGoal and -3 or 0 
		spr(sprite, character.x*8+offset, character.y*8+offset)
		--print("웃", character.x*8, character.y*8, 7)
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
	print("won", 64, 64, 7)
end























__gfx__
000000000333333333333333333333300000000000000000000000000000000000000000000000000eeeeeeeeeeeeee000011000000000003311113333111133
000000003333333333333333333333330007700000000000000000000000000000000000000000000eeeeeeeeeeeeee0001771000001100031bbb31331bbb313
007007003333333333333333333333330007700000000000000000000000000000000000000000000eeeeeeeeeeeeee0017777100017710031b3b31331b3b313
000770003333333333333333333333330007700000000000000000000000000000000000000000000eeeeeeeeeeeeee0171177710171771031b3331331b33313
0007700033333333333333333333333300777700000000000000000000000000000000000000000000000000000eeee001171711001177711bbbbbb11bbbbbb1
007007003333333333333333333333330077770000000000000000000000000000000000000000000eeee0eeee0eeee000177771001717113112411331124113
000000003333333333333333333333330077770000000000000000000000000000000000000000000eeee0eeee0eeee000017710000177713312413333124133
000000003333333333333333333333330000000000000000000000000000000000000000000000000eeee0eeee0eeee0000011000000111033333333dddddddd
000000003333333333333333333333330000000000000000000000000000000000000000000000000eeee0eeee0eeee000000000000000003333333300000000
0000000033333333333333333333333300000000000000000000000000000000000000000000000000000000000eeee000000000000000003111111300000000
000000003333333333333333333333330000000000000000000000000000000000000000000000000eeee0eeee0eeee000000000000000001655556100000000
000000003333333333333333333333330000000000000000000000000000000000000000000000000eeee0eeee0eeee000000000000000001666666100000000
000000003333333333333333333333330000000000000000000000000000000000000000000000000eeee0eeee0eeee000000000000000003166661300000000
000000003333333333333333333333330000000000000000000000000000000000000000000000000eeee0eeee0eeee000000000000000003316613300000000
00000000333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000000000003316613300000000
00000000333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000000000003166661300000000
00000000333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
00000000333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
00000000333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
000000003333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000003333333333333333333f3333
00000000333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333fef333
0000000033333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000033b333333333b33333bf3333
00000000d3333333333333333333333d00000000000000000000000000000000000000000000000000000000000000000000000033b3b33333b3b3b3333b33b3
000000000dddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
000d00000000d000000dd000000dd000000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
00d0000000000d0000dddd00000dd000000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
0dddddd00dddddd00d0dd0d0000dd0000000000000000000000000000000000000000000000000000000000000000000000000003387333333333b3333333333
0dddddd00dddddd0000dd0000d0dd0d0000000000000000000000000000000000000000000000000000000000000000000000000378883333333b3b333333333
00d0000000000d00000dd00000dddd0000000000000000000000000000000000000000000000000000000000000000000000000033ff33b33b33b33333333333
000d00000000d000000dd000000dd0000000000000000000000000000000000000000000000000000000000000000000000000003333333333b3b33333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333333333333333333333
__map__
020e020e0e0e023d0202020e0e020e0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e02021e022d0e020e2d0e2f023d2e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
022f02020e02020e0e0e02020e02130e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e110202020202020e02020202021e0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d0e0e022d020202020e022d0202130e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
110e2e02020e022e0e2f0202022f020e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e120e12121212121202022e020e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e12120e0e120e020e3d12120e12120e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e120e12120202120e0e0e12120e1200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e120e021e02122d0e1212120e0e2d0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12110e12120e120e1212121e120e0e1200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
122d12121212123d0e2d12120e12131200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212122d12121213020e0e0e02120e1200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12121212120e12120202022f0202130e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d120e3e1212122d120e121212123e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
121212120e12121212121212120e121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000