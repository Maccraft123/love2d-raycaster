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
end

function love.update(dt)
	if love.keyboard.isDown("w")  then
		camera.x = camera.x + math.sin(camera.a)*4
		camera.y = camera.y + math.cos(camera.a)*4
	end
	if love.keyboard.isDown("s") then
		camera.x = camera.x - math.sin(camera.a)*4
		camera.y = camera.y - math.cos(camera.a)*4
	end
	if love.keyboard.isDown("d") then
		camera.a = camera.a + 0.05
	end
	if love.keyboard.isDown("a") then
		camera.a = camera.a - 0.05
	end
end

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

function between(sx, sy, ex, ey, tx, ty)
	l = math.abs(distance(sx, sy, tx, ty) + distance(tx, ty, ex, ey) - distance(sx, sy, ex, ey))
	if l < 0.2 then
		return true
	else
		return false
	end
end

function love.draw()
	for i=1,181,1 do -- for every ray
		for j=1,msx,1 do -- for every tile
			for k=1,msy,1 do -- ^
				if map[k][j] ~= 0 then
					sx		= s*(j-1) -- starting x coord of one of 4 lines
					sy		= s*(k-1) -- starting y coord of one of 4 lines
					ex		= sx + s  -- ending x coord of one of 4 lines
					ey		= sy
					angle		= camera.a+((i/2)-45)*math.pi/180 -- angle in degrees
					endX		= camera.x+(math.sin(angle)*300) -- x coord of point at end of ray
					endY		= camera.y+(math.cos(angle)*300) -- y coord of point at end of ray
					-- check collision between ray and one of 4 lines of tile
					r,iX, iY 	= checkLine(camera.x, camera.y, endX, endY, sx, sy, ex, ey) 
					if r == true then -- if colission detected
						if sX == nil then -- if no previous collision
							sX = iX
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
		
		if sX ~= nil then --if collision detected
			if ssX == nil or distance(sX, sY, camera.x, camera.y) < distance(ssX, ssY, camera.x, camera.y) then
				-- ^ if no collusion was detected on whole ray OR current collision is closest
				ssX = sX
				ssY = sY
			end
		end
		
		if ssX ~= nil then -- if any collision detected draw it with appropiotate shade of gray and size
			c	= 4/distance(ssX, ssY, camera.x, camera.y)
			if c > 0.01 then
				love.graphics.setColor(c,c,c)
				love.graphics.rectangle("fill", 5*i, 300, 5, -2000*c)
				love.graphics.rectangle("fill", 5*i, 300, 5, 2000*c)
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
