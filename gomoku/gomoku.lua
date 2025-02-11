-- globals --
-------------

alpha_map = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}

-- updated in every _update()
frame = 0

game_state = 1 -- 1 running, 2 over
turn = 1 -- 1 black, 2 white

board = {
	size_x, size_y,
	draw_x, draw_y,
	chess_stat = {}, -- 0 empty, 1 black, 2 white,
	                 -- 3 highlighted black, 4 highlighted white
	cursor = {
		x, y,
		state = 0, -- 0 small, 1 large
		blink_freq = 20, -- blink every blink_freq frames
		last_frame = 0, -- updated when upd_position(), reset state each move
		-- update state
		upd_state = function(this)
			if (frame - this.last_frame) % this.blink_freq == 0 then
				this.state = (this.state + 1) % 2 -- 2 kinds of states
			end
		end,
		upd_position = function(this, sx, sy, dx, dy)
			local x = this.x + dx
			local y = this.y + dy
			this.x = (x >= 1 and x <= sx) and x or this.x
			this.y = (y >= 1 and y <= sy) and y or this.y
			if dx ~= 0 or dy ~= 0 then
				this.state = 0
				this.last_frame = frame
			end
		end
	},
	count = function(this, x, y, dx, dy, hi)
		if dx == 0 and dy == 0 then return 0 end

		local cur_player = this.chess_stat[x][y]
		local nx = x
		local ny = y -- next x/y
		local ret = 0

		while true do
			nx += dx
			ny += dy
			if     nx < 1 or nx > this.size_x
				or ny < 1 or ny > this.size_y
				or this.chess_stat[nx][ny] ~= cur_player
			then
				break
			end
			ret += 1
			-- set highlight
			if hi then this.chess_stat[nx][ny] += 2 end
		end

		-- count the other direction
		nx = x
		ny = y
		dx = -dx
		dy = -dy
		while true do
			nx += dx
			ny += dy
			if     nx < 1 or nx > this.size_x
				or ny < 1 or ny > this.size_y
				or this.chess_stat[nx][ny] ~= cur_player
			then
				break
			end
			ret += 1
			if hi then this.chess_stat[nx][ny] += 2 end
		end

		if hi then this.chess_stat[x][y] += 2 end
		return ret + 1
	end,
	place = function(this)
		local x = this.cursor.x
		local y = this.cursor.y
		if this.chess_stat[x][y] ~= 0 then
			return -1 -- chess piece exists, can't place
		end
		this.chess_stat[x][y] = turn

		-- row
		if this.count(this, x, y, 1, 0, false) >= 5 then
			this.count(this, x, y, 1, 0, true)
			return 1
		end
		-- column
		if this.count(this, x, y, 0, 1, false) >= 5 then
			this.count(this, x, y, 0, 1, true)
			return 1
		end
		-- main diagonal
		if this.count(this, x, y, 1, 1, false) >= 5 then
			this.count(this, x, y, 1, 1, true)
			return 1
		end
		-- side diagonal
		if this.count(this, x, y, 1, -1, false) >= 5 then
			this.count(this, x, y, 1, -1, true)
			return 1
		end
		turn = 3-turn -- switch turn
		return 0 -- game continue
	end,
	init = function(this)
		this.size_x = 12
		this.size_y = 12
		this.draw_x = 0
		this.draw_y = 0
		this.cursor.x = 1
		this.cursor.y = 1
		-- init chess_stat
		for i = 1, this.size_x do
			this.chess_stat[i] = {}
			for j = 1, this.size_y do
				this.chess_stat[i][j] = 0
			end
		end
	end,
	update = function(this)
		this.cursor.upd_state(this.cursor)
		-- if left or right is pressed, use the logic of btnp()
		-- if left and right are both pressed, don't move
		local dx = -1 * (btn(0) and 1 or 0) + 1 * (btn(1) and 1 or 0)
		local dy = -1 * (btn(2) and 1 or 0) + 1 * (btn(3) and 1 or 0)
		if dx ~= 0 then dx = (btnp(0) or btnp(1)) and dx or 0 end
		if dy ~= 0 then dy = (btnp(2) or btnp(3)) and dy or 0 end
		this.cursor.upd_position(this.cursor, this.size_x, this.size_y, dx, dy)
		-- button o: place chess piece
		if (btnp(4)) then
			local res = this.place(this)
			if res == 1 then
				game_state = 2
			end
		end
	end,
	draw = function(this)
		local i, j
		-- draw the board with chess
		for i = 1, this.size_x do
			print(tostr(i), 2 + this.draw_x + i*8, 2 + this.draw_y + 1*(i%2), 6+(i%2))
			print(alpha_map[i], 4 + this.draw_x, 2 + this.draw_y + i*8, 7-(i%2))
			for j = 1, this.size_y do
				local s = this.chess_stat[i][j]
				-- map [1, 2..bx-1, bx] to [0, 1, 2]
				local small_i = (i + this.size_x-4) \ (this.size_x-2) + (s <= 2 and s or s-2) * 3
				local small_j = (j + this.size_y-4) \ (this.size_y-2)
				local spr_id = small_j*16 + small_i
				spr(spr_id, this.draw_x + i*8, this.draw_y + j*8)
				if (s > 2) then
					circ(this.draw_x + i*8 + 4, this.draw_y + j*8 + 4, 3, 9)
				end
			end
		end
		-- draw cursor
		if game_state == 1 then
			spr(9 + this.cursor.state*2, this.draw_x + this.cursor.x*8, this.draw_y + this.cursor.y*8, 2, 2)
		end
	end
}

info = {
	turn_hint = {
		text = "player:",
		draw_x, draw_y,
		icon_r, -- radius
		icon_ox, icon_oy, -- offset x/y
		init = function(this)
			this.draw_x = 8 + 4
			this.draw_y = board.draw_y + (board.size_y+1)*8
			this.icon_r = 5
			this.icon_ox = 4*(#this.text-1) \ 2
			this.icon_oy = 6 + 2 + this.icon_r
		end,
		draw = function(this)
			-- turn hint text
			print(this.text, this.draw_x, this.draw_y, 6)
			-- turn icon (black/white chess piece)
			circfill(this.draw_x + this.icon_ox, this.draw_y + this.icon_oy, this.icon_r, turn == 1 and 0 or 7)
		end
	},
	reset_hint = {
		text = "(press ❎ to\nreset game)",
		draw_x, draw_y,
		init = function(this)
			this.draw_x = info.turn_hint.draw_x + 4*(#info.turn_hint.text + 4)
			this.draw_y = info.turn_hint.draw_y + 6\2

		end,
		draw = function(this)
			print(this.text, this.draw_x, this.draw_y, 6)
		end
	},
	over_hint = {
		win_text = "\^w\^twin!",
		next_text = "press 🅾️\nto restart..",
		draw_x, draw_y,
		init = function(this)
			this.draw_x = info.turn_hint.draw_x + 4*(#info.turn_hint.text + 1)
			this.draw_y = info.turn_hint.draw_y + 6
		end,
		draw = function(this)
			local tx = print(this.win_text, this.draw_x, this.draw_y, 9)
			print(this.next_text, tx + 2, this.draw_y, 6)
		end
	},
	init = function(this)
		this.turn_hint.init(this.turn_hint)
		this.reset_hint.init(this.reset_hint)
		this.over_hint.init(this.over_hint)
	end,
	draw = function(this)
		this.turn_hint.draw(this.turn_hint)
		if game_state == 1 then
			this.reset_hint.draw(this.reset_hint)
		elseif game_state == 2 then
			this.over_hint.draw(this.over_hint)
		end
	end
}

-- life cycle function --
-------------------------

function _init()
	-- set indigo as transparent color and unset black
	palt(0, false)
	palt(13)

	board.init(board)
	info.init(info)
end

function _update()
	-- update global variables
	frame = flr(time() * 30 + 0.5)

	if game_state == 1 then
		if btnp(5) then -- press button x to reset
			board.init(board)
			info.init(info) -- ?unnecessary
		end
		board.update(board)
	elseif game_state == 2 then
		if btnp(4) then -- press button o to restart
			board.init(board)
			info.init(info) -- ?unnecessary
			game_state = 1
		end
	end
end

function _draw()
	cls(13)
	frame = flr(time() * 30 + 0.5)

	board.draw(board)
	info.draw(info)
end
