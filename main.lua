function love.load()
	map		= {}
	map[1]		= {1, 1, 1, 1, 1, 1, 1, 1}
	map[2]		= {1, 0, 0, 1, 0, 0, 0, 1}
	map[3]		= {1, 0, 0, 1, 0, 1, 1, 1}
	map[4]		= {1, 0, 0, 0, 0, 0, 0, 1}
	map[5]		= {1, 1, 0, 1, 0, 0, 0, 0}
	map[6]		= {1, 0, 0, 0, 0, 1, 0, 1}
	map[7]		= {1, 0, 0, 0, 0, 1, 0, 1}
	map[8]		= {1, 1, 1, 1, 1, 1, 1, 1}

	msx		= 8	-- width of map
	msy		= 8	-- height of map

	s		= 50	-- size of each tile, don't change

	camera		= {}
	camera.x	= 430	-- starting x coordinate of camera
	camera.y	= 230	-- starting y coordinate of camera
	camera.a	= 5	-- starting camera angle

	raysfinal	= 100
	rays		= 10
	fov		= 90
end

function love.update(dt)
	if love.keyboard.isDown("w")  then
		camera.x = camera.x + math.sin(camera.a)*200*dt	-- move in direction of camera
		camera.y = camera.y + math.cos(camera.a)*200*dt	-- multiplied by delta time because fps differs
	end
	if love.keyboard.isDown("s") then
		camera.x = camera.x - math.sin(camera.a)*200*dt
		camera.y = camera.y - math.cos(camera.a)*200*dt
	end
	if love.keyboard.isDown("d") then
		camera.a = camera.a + 4*dt
	end
	if love.keyboard.isDown("a") then
		camera.a = camera.a - 4*dt
	end
	if rays + 1 < raysfinal then
		rays	= rays + 100*dt
	end
end

-- this function checks if 2 lines collide and gives x and y of collision
function checkLine(OsX, OsY, OeX, OeY, TsX, TsY, TeX, TeY)
	a1	= OeY - OsY
	b1	= OsX - OeX
	c1	= a1 * OsX + b1 * OsY

	a2	= TeY - TsY
	b2	= TsX - TeX
	c2	= a2 * TsX + b2 * TsY

	d	= a1 * b2 - a2 * b1

	if d == 0 then
		return false, false, false
	else
		x = (b2 * c1 - b1 * c2)/d
		y = (a1 * c2 - a2 * c1)/d
		if between(OsX, OsY, OeX, OeY, x, y) then
			if between(TsX, TsY, TeX, TeY, x, y) then
				return true, x,y
			else
				return false, false, false
			end
		else
			return false, false, false
		end
	end
end

function distance(sx, sy, ex, ey)
	return math.sqrt((sx - ex)^2 + (sy - ey)^2)
end

-- https://www.arduino.cc/reference/en/language/functions/math/map/
function remap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function between(sx, sy, ex, ey, tx, ty)
	l = math.abs(distance(sx, sy, tx, ty) + distance(tx, ty, ex, ey) - distance(sx, sy, ex, ey))
	if l < 0.01 then
		return true
	else
		return false
	end
end

-- code for reflections
function reflect(x, y, camerax, cameray, direction)
	if direction == "vertical" then
		diffy	= cameray - y
		endX	= camerax
		endY	= cameray - diffy
	else
		diffx	= camerax - x
		endX	= camerax - diffx
		endY	= cameray
	end

	for j=1,msx,1 do
		for k=1,msy,1 do
			if map[k][j] ~= 0 then
				sx		= s*(j-1)
				sy		= s*(k-1)
				ex		= sx + s
				ey		= sy
				r, iX, iY	= checkLine(x, y, endX, endY, sx, sy, ex, ey)
				if r then 
					if sX == nil then
						sX = iX
						sY = iY
					else
						if distance(iX, iY, x, y) < distance(sX, sY, x, y) then
							sX = iX
							sY = iY
						end
					end
				end

				ex		= sx
				ey		= sy + s
				r, iX, iY	= checkLine(x, y, endX, endY, sx, sy, ex, ey)
				if r then
					if sX == nil then
						sX = iX
						sY = iY
					else
						if distance(iX, iY, x, y) < distance(sX, sY, x, y) then
							sX = iX
							sY = iY
						end
					end
				end
				sx		= sx + s
				ex		= sx
				ey		= sy + s
				r, iX, iY	= checkLine(x, y, endX, endY, sx, sy, ex, ey)
				if r then
					if sX == nil then
						sX = iX
						sY = iY
					else
						if distance(iX, iY, x, y) < distance(sX, sY, x, y) then
							sX = iX
							sY = iY
						end
					end
				end
				sy		= sy + s
				ex		= sx - s
				ey		= sy
				r, iX, iY	= checkLine(x, y, endX, endY, sx, sy, ex, ey)
				if r then
					if sX == nil then
						sX = iX
						sY = iY
					else
						if distance(iX, iY, x, y) < distance(sX, sY, x, y) then
							sX = iX
							sY = iY
						end
					end
				end
			end
		end
	end
	if sX ~= nil then
		result	= 1/distance(x, y, sX, sY)
		love.graphics.print(tostring(sY), 50, 10)
		return result
	else
		return 0
	end
end

function love.draw()
	for i=0,rays,1 do -- for every ray
		for j=1,msx,1 do -- for every tile
			for k=1,msy,1 do -- ^
				if map[k][j] ~= 0 then
					sx		= s*(j-1) -- starting x coord of one of 4 lines making a tile
					sy		= s*(k-1) -- starting y coord of one of 4 lines
					ex		= sx + s  -- ending x coord of one of 4 lines
					ey		= sy      -- ending y coord of one of 4 lines
					angle		= camera.a+remap(i, 0, rays, fov/-2, fov/2)*(math.pi/180) -- angle of this ray in radians
					endX		= camera.x+(math.sin(angle)*300) -- x coord of point at end of ray
					endY		= camera.y+(math.cos(angle)*300) -- y coord of point at end of ray
					-- check collision between ray and one of 4 lines of tile
					r,iX, iY 	= checkLine(camera.x, camera.y, endX, endY, sx, sy, ex, ey) 
					if r then -- if colission detected save the x and y of collision
						if sX == nil then -- if no previous collision
							sX = iX -- save the collision data
							sY = iY
						else	-- if current collision is closer than previous
							if distance(iX, iY, camera.x, camera.y) < distance(sX, sY, camera.x, camera.y) then
								sX = iX
								sY = iY
							end
						end
					end
					-- repeat 3 more times with different parts
					ex		= sx
					ey		= sy + s
					r,iX,iY		= checkLine(camera.x, camera.y, endX, endY, sx, sy, ex, ey)
					if r == true then
						if sX == nil then
							sX = iX
							sY = iY
						else
							if distance(iX, iY, camera.x, camera.y) < distance(sX, sY, camera.x, camera.y) then
								sX = iX
								sY = iY
							end
						end
					end
					
					sx		= sx + s
					ex		= sx  
					ey		= sy + s
					r,iX,iY		= checkLine(camera.x, camera.y, endX, endY, sx, sy, ex, ey)
					if r == true then
						if sX == nil then
							sX = iX
							sY = iY
						else
							if distance(iX, iY, camera.x, camera.y) < distance(sX, sY, camera.x, camera.y) then
								sX = iX
								sY = iY
							end
						end
					end
	
					sy		= sy + s
					ex		= sx - s
					ey		= sy
					r,iX,iY		= checkLine(camera.x, camera.y, endX, endY, sx, sy, ex, ey)
					if r == true then
						if sX == nil then
							sX = iX
							sY = iY
						else
							if distance(iX, iY, camera.x, camera.y) < distance(sX, sY, camera.x, camera.y) then
								sX = iX
								sY = iY
							end
						end
					end

				end
			end
		end
		
		if sX ~= nil then --if collision detected on this iteration
			if ssX == nil or distance(sX, sY, camera.x, camera.y) < distance(ssX, ssY, camera.x, camera.y) then
				-- ^ if no collusion was detected on whole ray OR current collision is closest
				ssX = sX
				ssY = sY
			end
		end
		
		if ssX ~= nil then -- if any collision detected draw it with appropiotate shade of gray and size
			c	= 4/distance(ssX, ssY, camera.x, camera.y)
			if c > 0.01 then -- don't calculate stuff that you won't see anyway
				love.graphics.setColor(c, c, c) -- set appropioate shade of gray
				love.graphics.rectangle("fill", remap(i, 0, rays, 0, 800), 300, 800/rays, -2000*c) -- draw upper rectangle
				love.graphics.rectangle("fill", remap(i, 0, rays, 0, 800), 300, 800/rays, 2000*c) -- draw lower rectangle
				love.graphics.setColor(1, 1, 1) -- reset color to white
			end
			if ssX < 205 and ssX > 195 then --reflection code ∨
				love.graphics.rectangle("fill", 1, 1, 10, 10)
				d = reflect(ssX, ssY, camera.x, camera.y, "horizontal")
				love.graphics.setColor(1, 1, 1)
				love.graphics.rectangle("fill", remap(i, 0, rays, 0, 800), 0, 5, 2000*d)
				love.graphics.rectangle("fill", remap(i, 0, rays, 0, 800), 0, 5, 2000*d)
				love.graphics.setColor(1, 1, 1)
			end
		end
		-- remove all collisions
		ssX, ssY, sX, sY = nil
	end
	-- debug data
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print("X: "..tostring(camera.x), 10, 20)
	love.graphics.print("Y: "..tostring(camera.y), 10, 30)
end
