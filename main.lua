function love.load()
	map		= {{}, {}, {}}
	map[1]		= {1, 1, 1, 1, 1, 1, 1, 1}
	map[2]		= {1, 0, 0, 1, 0, 0, 0, 1}
	map[3]		= {1, 0, 0, 1, 0, 1, 1, 1}
	map[4]		= {1, 0, 0, 0, 0, 0, 0, 1}
	map[5]		= {1, 1, 0, 1, 0, 0, 0, 0}
	map[6]		= {1, 0, 0, 0, 0, 1, 0, 1}
	map[7]		= {1, 0, 0, 0, 0, 1, 0, 1}
	map[8]		= {1, 1, 1, 1, 1, 1, 1, 1}

	msx		= 8
	msy		= 8

	s		= 50

	camera		= {}
	camera.x	= 400
	camera.y	= 300
	camera.a	= 0
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
	return math.floor(math.sqrt((sx - ex)^2 + (sy - ey)^2)+0.5)
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
	for i=1,181,1 do
		for j=1,msx,1 do
			for k=1,msy,1 do
				if map[k][j] == 1 then
					sx		= 100+s*(j-1)
					sy		= 100+s*(k-1)
					ex		= sx + s
					ey		= sy
					angle		= camera.a+((i/2)-45)*math.pi/180
					endX		= camera.x+(math.sin(angle)*300)
					endY		= camera.y+(math.cos(angle)*300)
					r,iX, iY 	= checkLine(camera.x, camera.y, endX, endY, sx, sy, ex, ey)
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
		if sX ~= nil then
			if ssX == nil or distance(sX, sY, camera.x, camera.y) < distance(ssX, ssY, camera.x, camera.y) then
				ssX = sX
				ssY = sY
			end
		end
		
		if ssX ~= nil then
			c	= 4/distance(ssX, ssY, camera.x, camera.y)
			love.graphics.setColor(c,c,c)
			love.graphics.rectangle("fill", 5*i, 300, 5, -2000*c)
			love.graphics.rectangle("fill", 5*i, 300, 5, 2000*c)
			love.graphics.setColor(255, 255, 255)
		end
		
		ssX, ssY, sX, sY = nil
	end
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print("X: "..tostring(camera.x), 10, 20)
	love.graphics.print("Y: "..tostring(camera.y), 10, 30)
end
