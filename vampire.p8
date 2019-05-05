pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

--------------------------------------------------------------------------------
actor={x=0, y=0, width=8, height=8, grav=0, spd=0, max_spd=2, acc=0, dcc=1, depth=0}

function actor:new(a)
	self.__index=self
	return setmetatable(a or {}, self)
end

function actor:update() end

function actor:init() end

function actor:draw()
	if self.invis then return end
	if self.s then
		if self.pal then
			self:set_pal()
		end
		spr(self.s, self.x, self.y, 1, 1, self.f)
		pal()
	end
	if draw_bounding_boxes then
		rect(self.x,self.y, self.x+self.width-1, self.y+self.height-1,7)
	end
	if self.slaves then
		for s in all(self.slaves) do
			s:draw()
		end
	end
end

function actor:set_pal()
	pal(5, self.pal[1])
	pal(6, self.pal[2])
	pal(7, self.pal[3])
	pal(15, self.pal[4])
end

function actor:on_ground()
	return is_solid(self.x, self.y+self.height+1)
		or is_solid(self.x+self.width-1, self.y+self.height+1)
end

function actor:fully_on_ground()
	return is_solid(self.x, self.y+self.height+1)
		and is_solid(self.x+self.width-1, self.y+self.height+1)
end

function actor:clip_above_block()
	local feet_y = self.y+self.height
	feet_y = flr(feet_y/8)*8
	self.y=feet_y-self.height
end

function actor:clip_below_block()
	self.y = flr(self.y/8)*8+8
end

function actor:gravity()
	self.y+=self.grav
	if self.grav>terminal_velocity then
		self.grav = terminal_velocity
	end
	if self.flying then
		self.grav+=self.grav_acc
		self.grav = mid(-self.max_grav, self.grav, self.max_grav)
	else
		self.grav+=grav_acc
	end
	if not self.ignore_walls then
		if self:is_in_wall() then
			if self.grav>0 then
				self:clip_above_block()
			else
				self:clip_below_block()
			end
			self.grav = self.grav * -0.2
			if abs(self.grav)<1 then
				self.grav = 0
			end
		end
	end
end

function actor:is_in_wall(part)
	xs = {}
	for i=self.x, self.x+self.width-1, 8 do
		add(xs, i)
	end
	add(xs, self.x+self.width-1)
	ys = {}
	for i=self.y, self.y+self.height-1, 8 do
		add(ys, i)
	end
	add(ys, self.y+self.height-1)

	if part == "ceil" then
		ys = {self.y}
	elseif part == "floor" then
		ys = {self.y+self.height-1}
	end

	for i in all(xs) do
		for j in all(ys) do
			if is_solid(i, j) then
				return true
			end
		end
		if is_solid(i, self.y+self.height-1) then
			return true
		end
	end
	return false
end

function actor:momentum()
	--accelerate
	self.spd+=self.acc
	--decelerate
	self.spd=move_towards(0, self.spd, self.dcc)
	if self.spd>self.max_spd then
		self.spd=self.max_spd
	elseif self.spd<-self.max_spd then
		self.spd=-self.max_spd
	end
	self.x+=self.spd
	--when this moves us into a wall:
	if not self.ignore_walls then
		if self:is_in_wall() then
			--position exactly on pixel.
			self.x=flr(self.x)
			--move out of the wall.
			while self:is_in_wall() do
				if self.spd>0 then
					self.x-=1
				else
					self.x+=1
				end
			end
			self.spd=0
		end
	end
end

function actor:use_slaves()
	self.slaves = {}
end

function actor:update_slaves()
	if not self.slaves then return end
	for s in all(self.slaves) do
		s:update()
	end
end

function actor:add_slave(a)
	if not self.slaves then return end
	add(self.slaves, a)
	a.master = self
end

function actor:goto_master()
	if not self.master then return end
	self.x = self.master.x
	self.y = self.master.y
end

function actor:offscreen()
	return self.x<cam.x-self.width-32 or self.x>cam.x+128+32
end

function actor:on_camera()
	return self.x+self.width>=cam.x and self.x<cam.x+128 and self.y+self.height>=cam.y and self.y<cam.y+112
end

function actor:hitbox_overlaps(a)
	--convert to or.
	if self.x+self.width<a.x then return false end
	if a.x+a.width<self.x then return false end
	if self.y+self.height<a.y then return false end
	if a.y+a.height<self.y then return false end
	return true
end

--checks exact pixel collisions (potentially recursive on slaves)
function actor:intersects(b, r)
	--must pass simple test first.
	if self:hitbox_overlaps(b) then
		--hitbox only collision.
		if not self.s or not b.s then
			return true
		end
		--scratchpad area
		rectfill(0,0,16,8,0)
		--draw both sprites to screen
		spr(self.s,0,0,1,1,self.f)
		spr(b.s,8,0,1,1,b.f)
		--calculate differences.
		x_dif=b.x-self.x
		y_dif=b.y-self.y
		for x=max(0,x_dif),min(7,7+x_dif) do
			for y=max(0,y_dif),min(7,7+y_dif) do
				a_pix=pget(x,y)
				b_pix=pget(8+x-x_dif,y-y_dif)
				--if two pixels overlap...
				if a_pix!=0 and b_pix!=0 then
					return true
				end
			end
		end
		if b.slaves and r then
			for a in all(b.slaves) do
				if a.extends_hitbox and self:intersects(a, r) then return true end
			end
		end
	end
	return false
end

function actor:hit(attacker)
	if self.master then
		self.master:hit(attacker)
	end
end

function actor:use_pal()
	if self.pal_type == 1 then
		self.pal = enemy_pal_1
	elseif self.pal_type == 2 then
		self.pal = enemy_pal_2
	elseif self.pal_type == 0 then
		self.pal = hurt_pal
	end
end

function actor:death_particle()
	add_actor(death_particle:new({x=self.x+rnd(self.width),y=self.y+rnd(self.height)}))
end

function actor:level_up()
	if self.max_health then
		self.max_health+=progression
		self.health+=progression
	end
	return self
end

--------------------------------------------------------------------------------

cam = actor:new({speed=0.5, always_update = true, depth=-19})

function cam:update()
	if player.stairs then
		self.speed=0.5
		--only transition screen on stairs.
		local y_prev = self.y
		self:y_move()
		if self.y!=y_prev then
			blackout_time=40
			self:jump_to()
			if not hard_mode then
				player:checkpoint()
			end
		end
	else
		self.speed=2
	end
	self:set_goal()
	self.x = move_towards(self.goal_x, self.x, self.speed)
	if self.x<=0 then
		self.x=0
	end
end

function cam:set_goal()
	if self.special_goal then
		self.special_goal = false
	else
		self.goal_x = player.x-60
	end
end

function cam:jump_to()
	self:set_goal()
	self.x=self.goal_x
end

function cam:y_move()
	if player.y<=104 then
		self.y=0
	else
		self.y=112
	end
end

function cam:set_position()
	camera(self.x, self.y-16)
	if not between_levels then
		clip(0,0,128,112)
		camera(self.x, self.y)
	end
end

--------------------------------------------------------------------------------

player = actor:new({s=0, height=14, dcc=0.5, max_spd=1, animation=0,
					stairs=false, stair_timer=0, whip_animation=0, whip_cooldown = 0,
					invul = 0, extra_invul=0, always_update = true, depth=-2,
					legs_s=0})

function player:update()
	self.prev_x, self.prev_y = self.x, self.y
	-- if self.invul<=0 and self.extra_invul==0 then
	self.pal = player_pal
	-- end
	--movement inputs
	if self.invul==0 and self.extra_invul>0 then
		self:flash_when_hit()
	end
	if self.invul==0 and self.extra_invul==0 then
		self.invis=false
	end
	if not self.stairs then
		--move on the ground
		if self.invul == 0 then
			--crouching is dummied out
			-- if btn(3) and (self:on_ground() or self.ducking) and false then
			-- 	-- if not self.ducking then
			-- 	-- 	self.y+=2
			-- 	-- end
			-- 	-- self.ducking = true
			-- 	-- -- self.spd=0
			-- 	-- self.acc=0
			-- else
				self.ducking = false
				if btn(1) and not btn(0) then
					self.acc=1
					if self.whip_animation==0 then
						self.f = false
					end
				elseif btn(0) and not btn(1) then
					self.acc=-1
					if self.whip_animation==0 then
						self.f = true
					end
				else
					self.acc=0
				end
			-- end

			-- if self.ducking then
			-- 	self.height=12
			-- else
				self.height=14
				if self:is_in_wall() then
					self.y-=2
				end
				if self:on_ground() and btnp(4) and not between_levels then
					self.grav=-player_jump_height
				end
			-- end
			self:momentum()
			self:gravity()
			if abs(self.spd)<0.1 then
				self.animation = 1.9
			end
			if self:on_ground() and btn(2) then
				self:mount_stairs_up()
			elseif self:on_ground() and btn(3) then
				self:mount_stairs_down()
			end
		else
			self:fly_when_hit()
			self:momentum()
			self:gravity()
		end
	end
	--stairs behaviour
	if self.stairs then
		if self.invul>0 then
			self:flash_when_hit()
		end
		-- self.ducking = false
		self.spd=0
		local up, down = 1, 0
		if self.stair_dir then
			up, down = 0, 1
		end
		if btn(2) and not btn(3) then
			self.stair_timer+=1
			self.f = self.stair_dir
		elseif btn(3) and not btn(2) or btn(down) then
			self.stair_timer-=1
			self.f = not self.stair_dir
		elseif btn(up) then
			self.stair_timer+=1
			self.f = self.stair_dir
		end
		if self.stair_timer>=6 then
			self.stair_timer=0
			self.y-=2
			if self.f then
				self.x-=2
			else
				self.x+=2
			end
			self.animation+=1
			--code duplication.
			if self.y%4==0 then
				sfx(5)
			else
				sfx(6)
			end
		elseif self.stair_timer<=-6 then
			self.stair_timer=0
			self.y+=2
			if self.f then
				self.x-=2
			else
				self.x+=2
			end
			self.animation+=1
			if self.y%4==0 then
				sfx(5)
			else
				sfx(7)
			end
		end
		self:dismount_stairs()
	end

	if btnp(5) and self.whip_animation == 0 and self.whip_cooldown == 0 and not between_levels then
		self.whip_animation = 0.1
		sfx(4)
	end

	if self:on_ground() then
		self.animation += abs(self.spd)/10
	end
	self.animation = self.animation%4
	self.s = flr(self.animation)
	if self.s == 3 then
		self.s = 1
	end

	self.legs_s = self.s

	if self.whip_cooldown>0 then
		self.whip_cooldown-=1
		self.s = 6
		if self.whip_cooldown<=0 then
			self.whip_animation = 0
		end
	else
		if self.whip_animation>0 then
			self.whip_animation+=whip_speed
			if self.whip_animation<2 then
				--self.whip_animation+=whip_speed
			end
			if self.whip_animation>=4 then
				self.whip_cooldown = whip_cooldown
				self.s = 6
			else
				self.s = 3 + flr(self.whip_animation)
			end
		end
	end

	--move between screens when the player moves off on stairs.
	if self.stairs then
		if self.y<-8 then
			self.y += 224
			self.x += level_offset*8
			cam:jump_to()
		elseif self.y>224-8 then
			self.y-=224
			self.x -= level_offset*8
			cam:jump_to()
		end
	end

	if self.x<cam.x then
		self.x = cam.x
	end

	if not self.stairs and self.y>=cam.y+104 then
		self.health=0
	end

	if self.health<=0 and self.invul==0 then
		self:respawn()
	end

	self:update_slaves()
end

function player:checkpoint()
	self.check_x, self.check_y, self.check_stairs, self.check_f, self.check_stair_dir = self.x, self.y, self.stairs, self.f, self.stair_dir
end

function player:respawn()
	--blackout_time=40
	play_music(5)
	self.health=player_max_health
	self.x, self.y, self.stairs, self.f, self.stair_dir = self.check_x, self.check_y, self.check_stairs, self.check_f, self.check_stair_dir
	self.invul, self.invis, self.mom, self.grav, self.invis = 0, false, 0, 0, false
	cam.special_goal = false
	cam:jump_to()
	cam:y_move()
	load_level(current_level, true)
	level_start=true
	darkness=4
end

function player:on_ground()
	for a in all(actors) do
		if a.supporting_player then
			return true
		end
	end
	return actor.on_ground(self)
end

function player:mount_stairs_down()
	local tile_x, tile_y = flr((self.x+4)/8), flr((self.y+16)/8)
	for add=-1,1 do
		pos_x = tile_x+add
		local is_stairs = get_flag(pos_x, tile_y, 1)
		local facing_left = get_flag(pos_x, tile_y, 2)
		if is_stairs and not (facing_left and add==-1) and not (not facing_left and add==1) then
			self.stairs = true
			self.x = pos_x*8
			self.y = tile_y*8-14
			if facing_left then
				self.x-=2
			else
				self.x+=2
			end
			self.animation = 1
			self.stair_dir = facing_left
			self.f = not facing_left
			self.stair_timer=-10
		end
	end
end

function player:mount_stairs_up()
	local tile_x, tile_y = flr((self.x+4)/8), flr((self.y+10)/8)
	for add=-1,1 do
		pos_x = tile_x+add
		local is_stairs = get_flag(pos_x, tile_y, 1)
		local facing_left = get_flag(pos_x, tile_y, 2)
		if is_stairs and not (facing_left and add==1) and not (not facing_left and add==-1) then
			self.stairs = true
			self.x = pos_x*8
			self.y = tile_y*8-6
			if facing_left then
				self.x+=6
			else
				self.x-=6
			end
			self.animation = 1
			self.stair_dir = facing_left
			self.f = facing_left
			self.stair_timer=10
		end
	end
end

function player:dismount_stairs()
	if self.y%8 != 2 then return end
	if self.y>=208 then return end
	if self.y<0 then return end
	local pos_x, pos_y = self.x+4, self.y+8
	if self.stair_dir == self.f then
		if not self.stair_dir then
			pos_x+=8
		else
			pos_x-=8
		end
	else
		pos_y+=8
	end
	if not get_flag_at(pos_x, pos_y, 1) then
		self.stairs = false
	end
end

player_legs = actor:new({s=16, height=6, extends_hitbox=true})

function player_legs:update()
	self:goto_master()
	self.pal= self.master.pal
	self.y+=8
	self.f = self.master.f
	self.s = 16 + self.master.legs_s%2
	if self.s == 16 and self.master.stairs then
		self.s +=2
		if self.master.f != self.master.stair_dir then
			self.s +=1
		end
	end
	-- if not self.master:on_ground() and not self.master.stairs or self.master.ducking then
	if not self.master:on_ground() and not self.master.stairs then
		self.s = 20
	end
end

function player:hit(attacker)
	if self.invul == 0 and self.extra_invul==0 then
		sfx(12)
		self.health-=1
		self.invul=24
		self.extra_invul=24
		if not self.stairs then
			self.grav=-1.5
			self.acc=0
		end
		if attacker.x>self.x then
			self.spd=-0.5
			self.f = false
		else
			self.spd=0.5
			self.f = true
		end
	end
end

function player:fly_when_hit()
	if self.spd>0 then
		self.spd = self.max_spd
	else
		self.spd = -self.max_spd
	end
	self:flash_when_hit()
end

function player:flash_when_hit()
	if self.invul>0 then
		self.invul-=1
		self.pal = hurt_pal
	else
		self.extra_invul-=1
	end
	self.invis = not self.invis
end

--------------------------------------------------------------------------------

whip = actor:new({s=32, dir=0, dist=2, dir_change=0, width=3, height=3})

function whip:update()
	self.prev_x=self.x
	self.prev_y=self.y
	if self.master == player then
		self:goto_master()
		local x_dist = -4
		local y_dist = 3
		if player.s == 4 then
			x_dist = -1
			y_dist = -1
		elseif player.s == 5 then
			x_dist = 3
		elseif player.s == 6 then
			x_dist = 4
			y_dist = 6
		end
		self.dir = 0.5 - player.whip_animation/8
		self.dir_change = 0.0625 - player.whip_animation/64
		if player.whip_cooldown>0 then
			self.dir_change = 0
			self.dir = 0
		end
		if player.f then
			self.dir = -(self.dir-0.25)+0.25
			self.dir_change = -self.dir_change
			x_dist=-x_dist
		end
		self.x+=3+x_dist
		self.y+=y_dist
		self.invis = player.whip_animation<=0
	else
		self.dir_change = self.master.dir_change
		self.dir = self.master.dir + self.dir_change
		self.dist = self.master.dist
		self.invis = self.master.invis
		self:goto_master()
		self.x += self.dist*cos(self.dir)
		self.y += self.dist*sin(self.dir)
	end
	if not self.invis then
		for a in all(actors) do
			if a.enemy and self:intersects(a, true) then
				a:hit(player)
			elseif a.breaks and self:intersects(a) then
				a:break_me()
			end
		end
	end
	self:update_slaves()
end

function whip:setup(length)
	self.length = length
	if length>0 then
		self:use_slaves()
		local next_whip = whip:new()
		next_whip:setup(length-1)
		self:add_slave(next_whip)
	end
end

--------------------------------------------------------------------------------

enemy = actor:new({enemy = true, health = 1, pal_type = 1, dcc=0, base_max_spd=0.25, f=true, invul=0})

function enemy:fly_when_hit()
	if self:fully_on_ground() then
		self.invul-=0.5
		if self.health>0 then
			self.invul-=0.5
		end
		self.max_spd=self.base_max_spd
	else
		self.max_spd=1
		if self.spd>0 then
			self.spd = self.max_spd
		else
			self.spd = -self.max_spd
		end
	end
	self.pal = hurt_pal
	self.invis = not self.invis
	if self.health<=0 then
		self:death_particle()
	end
end

function enemy:hit(attacker)
	if self.health<=0 then
		return
	end
	if self.invul == 0 then
		self.health-=1
		self.invul=8
		self.grav=-1.5
		self.acc=0
		if attacker.x>self.x then
			self.spd=-0.5
			self.f = false
		else
			self.spd=0.5
			self.f = true
		end
		if self.health<=0 and self.death_sound then
			sfx(self.death_sound)
		elseif self.hurt_sound then
			sfx(self.hurt_sound)
		end
	end
end

function enemy:die_when_dead()
	if self.health<=0 then
		self.dead=true
	end
	return not self.dead
end

--was an enemy function
function actor:hit_player(anyway)
	if anyway or (self.invul == 0 and self.health>0) then
		if self:intersects(player, true) then
			player:hit(self)
			return true
		end
		if self.slaves then
			for a in all(self.slaves) do
				a:hit_player(true)
			end
		end
	end
end

function enemy:boss_health()
	boss_health = self.health
	boss_max_health = self.max_health
end

--------------------------------------------------------------------------------

zombie = enemy:new({s=15, height=14, leg_spd = 0.05, death_sound=9})

function zombie:init()
	self:use_slaves()
	self:add_slave(zombie_legs:new())
	self:use_pal()
	self.y+=2
	self.f=true
	self:update_slaves()
end

--this code needs rewriting
function zombie:update()
	if self:offscreen() then
		self:update_slaves()
		return
	end
	--self.f = self.x>player.x
	if self.invul>0 then
		self:fly_when_hit()
	else
		if self:die_when_dead() then
			self.invis = false
			self.max_spd=self.base_max_spd
			self.acc=0.1
			if self.f then
				self.acc=-0.1
			end
			self:use_pal()
		end
	end

	self:momentum()
	self:gravity()

	if self.invul<=0 then
		if abs(self.spd)<=0 or not (self:fully_on_ground() and self.grav>=0) then
			--self.grav=-player_jump_height
			self:on_edge()
		end
		self:hit_player()
	end

	self:update_slaves()
end

function zombie:on_edge()
	self.f = not self.f
	self.spd = -self.spd
end

zombie_legs = enemy:new({s=31, animation = 0, enemy=true, extends_hitbox=true})

function zombie_legs:update()
	self:goto_master()
	self.y+=8
	self.f = self.master.f
	self.animation += self.master.leg_spd
	self.animation = self.animation%2
	self.s = 30+self.animation
	self.pal = self.master.pal
end

--------------------------------------------------------------------------------

running_zombie = zombie:new({s=14, leg_spd = 0.2, base_max_spd=1, health=1})

function running_zombie:use_pal()
	self.pal = enemy_pal_2
end

function running_zombie:on_edge()
	if self:on_ground() then
		self.grav=-2
	end
end

--------------------------------------------------------------------------------

death_particle = actor:new({size=3, always_update = true})

function death_particle:update()
	self.y-=0.5
	self.size-=0.4
	if self.size<=0 then
		self.dead=true
	end
end

function death_particle:draw()
	circfill(self.x,self.y,self.size,7)
end

--------------------------------------------------------------------------------

bat = enemy:new({s=26, flying=true, ignore_walls=true, max_grav=1, pal_type=1, base_max_spd=1, hurt_sound=10})

function bat:init()
	self.f=true
	self.awake = false
	self:use_pal()
	self.wing_timer=0
end

function bat:update()
	if self:offscreen() then return end
	if self.invul>0 then
		if not self:is_in_wall() then
			self.ignore_walls = false
		end
		self.flying = false
		self:fly_when_hit()
		self:momentum()
		self:gravity()
		self:animate()
	else
		self.ignore_walls = true
		self.flying = true
		self.invis = false
		self:use_pal()
		if self:die_when_dead() then
			if self.awake then
				self.f = self.x>player.x

				if self.f then
					self.acc = -0.05
				else
					self.acc = 0.05
				end

				if self.y>player.y then
					self.grav_acc = -0.05
				else
					self.grav_acc = 0.05
				end

				self:momentum()
				self:gravity()
				self:hit_player()
				self:animate()
			end
			if distance_between(self.x,self.y,player.x,player.y)<32 then
				self.awake = true
			end
		end
	end
end

function bat:animate()
	self.wing_timer=(self.wing_timer+0.2)%2
	self.s = 27+self.wing_timer
end

--------------------------------------------------------------------------------

batboss = bat:new({health=6, s=194, death_sound=13, max_health=6})

function batboss:update()
	bat.update(self)
	self:animate()
	self:boss_health()
	if self.awake then
		if self.x<=cam.x then
			self.x = cam.x
		elseif self.x>=cam.x+120 then
			self.x = cam.x+120
		end
	end
end

function batboss:init()
	self:use_pal()
	self.wing_timer=0
	self:use_slaves()
	self:add_slave(batwing:new())
	self:add_slave(batwing:new({f=false}))
	self:update_slaves()
end

function batboss:animate()
	self.wing_timer=(self.wing_timer+0.1)%2
	self.wing_s = 192+self.wing_timer
	self:update_slaves()
end

--------------------------------------------------------------------------------

batwing = enemy:new({s=192})

function batwing:update()
	self:goto_master()
	self.s = self.master.wing_s
	self.pal = self.master.pal
	if self.f then
		self.x+=8
	else
		self.x-=8
	end
end

--------------------------------------------------------------------------------

shooter = enemy:new({s=29, pal_type=1, health=3, base_f=true, timer=0, depth=-1, death_sound=11})

function shooter:update()
	if self.invul>0 then
		self:fly_when_hit()
	else
		self:use_pal()
		if self:die_when_dead() then
			self:hit_player()
			if not self:offscreen() then
				self.timer+=1
				if self.timer>120 then
					local f=fireball:new({x=self.x, y=self.y+3, f=self.f})
					add_actor(f)
					f:update()
					self.timer=0
				end
			end
		end
	end
	self.f=self.base_f
end

--------------------------------------------------------------------------------

fireball = actor:new({s=34, pal_type=0, spd=1, height=4})

function fireball:update()
	self:animate()
	self:use_pal()
	if self:offscreen() then
		self.dead=true
	end
	if self.f then
		self.x-=self.spd
	else
		self.x+=self.spd
	end
	if self:intersects(player, true) then
		player:hit(self)
		self.dead=true
	end
end

function fireball:animate()
	self.s = 84-self.s
end

--------------------------------------------------------------------------------

axe = enemy:new({s=41, pal_type=2, timer=0, spd=1, anim_dir=1})

function axe:update()
	if self.invul<=0 then
		if self:die_when_dead() then
			self:animate()
			self:use_pal()
			if self:offscreen() then
				self.dead = true
			end
			if self.di==nil then
				self.di=self.f
			end
			if self.di then
				self.x-=self.spd
			else
				self.x+=self.spd
			end
			if self:hit_player() then
				self.dead = true
			end
		end
	else
		self:fly_when_hit()
		self:gravity()
	end
end

function axe:animate()
	self.timer+=1
	if self.timer>6 then
		self.s += self.anim_dir
		if self.s==44 or self.s==40 then
			self.f = not self.f
			self.anim_dir*=-1
		end
		self.timer=0
	end
end

--------------------------------------------------------------------------------

axe_knight=enemy:new({s=8, height=16, pal_type=2, health=5, max_health=5, base_max_spd=0.5, goal=32, throw_timer=0, hand_timer=0, death_sound=11})

function axe_knight:init()
	self:use_slaves()
	self:add_slave(axe_knight_legs:new())
	self:add_slave(axe_knight_hand:new())
	self:update_slaves()
end

function axe_knight:update()
	if self:on_camera() then
		if self.invul<=0 then
			if self:die_when_dead() then
				self.invis=false
				self:use_pal()

				self.max_spd=self.base_max_spd

				if self.x>player.x then
					self.f=true
					self.acc=-0.02
				else
					self.f=false
					self.acc=0.02
				end

				local dist = abs(self.x-player.x)
				if dist<self.goal then
					self.acc*=-1
				end

				if self.hand_timer>0 then
					self.hand_timer-=1
					if self.hand_timer==11 then
						local f=axe:new({x=self.x, y=self.y+3, f=self.f})
						add_actor(f)
						f:update()
						self.throw_timer=60
					end
				else

					if self.throw_timer==0 then
						self.hand_timer=15
					end

					self.throw_timer=max(0, self.throw_timer-rnd(2))
				end

				self:hit_player()
			end
		else
			self:fly_when_hit()
		end
		self:momentum()
		--self:gravity()
		self:update_slaves()
	end
	if current_level==3 then
		self:boss_health()
	end
end

--------------------------------------------------------------------------------

axe_knight_legs = enemy:new({s=24, timer=0})

function axe_knight_legs:update()
	self:goto_master()
	self.y+=8
	self.f, self.invis, self.pal = self.master.f, self.master.invis, self.master.pal
	self.timer+=abs(self.master.spd)
	if self.timer>4 then
		self.timer=0
		self.s = 49-self.s
	end
end

--------------------------------------------------------------------------------

axe_knight_hand = enemy:new({s=9})

function axe_knight_hand:update()
	self:goto_master()
	self.f, self.invis, self.pal = self.master.f, self.master.invis, self.master.pal
	local offset=6
	if self.f then offset*=-1 end
	self.x+=offset
	if self.master.hand_timer>10 then
		self.s=9
	elseif self.master.hand_timer>0 then
		self.s=10
		self.y+=1
	else
		self.invis=true
	end
end

--------------------------------------------------------------------------------

medusa = enemy:new({s=13, pal_type=2, timer=0, ignore_walls=true, hurt_sound=10})

function medusa:init()
	self.x=cam.x+127
	self.c_y = max(player.y+rnd(16)-8, cam.y+16)
	self.y=self.c_y
	if rnd(10)<5 then
		self.timer=0.5
	end
end

function medusa:update()
	if self:offscreen() then
		self.dead = true
	end
	if self.invul>0 then
		self:fly_when_hit()
		self:momentum()
		self:gravity()
	else
		self:use_pal()
		if self:die_when_dead() then
			self:hit_player()
		end
		self.x-=1
		self.timer=(self.timer+0.01)%1
		self.y=self.c_y+sin(self.timer)*12
	end
end

--------------------------------------------------------------------------------

medusa_spawner = actor:new({timer=60})

function medusa_spawner:update()
	if player.x<self.x and player.x>self.x-256 then
		self.timer+=1
		if self.timer>=90 then
			self.timer=0
			local m=medusa:new()
			m:init()
			add_actor(m)
		end
	end
end

--------------------------------------------------------------------------------

slime = enemy:new({s=11, pal_type=2, hurt_sound=10, health=3, jiggle=1})

function slime:update()
	self.s=11
	if self:offscreen() then return true end
	if self.invul>0 then
		self:fly_when_hit()
		self:momentum()
		self:gravity()
	else
		self.invis = false
		self:use_pal()
		self.max_spd=2
		if self:die_when_dead() then
			if self:on_ground() then
				self.spd = 0
				self.jiggle-=0.1
				if self.jiggle<=-2 or rnd(100)<5 then
					self.grav, self.spd, self.jiggle = self.jiggle, self.jiggle/2, 0
					if (player.x>self.x) self.spd*=-1
					if (rnd(9)<2) self.spd*=-1
				end
			else
				self.s=12
			end
			self:momentum()
			self:gravity()
			self:hit_player()
		end
	end
end

--------------------------------------------------------------------------------

slimeboss = slime:new({health=6, s=208, death_sound=13, max_health=6, height=16, width=16})

function slimeboss:init(extra)
	self:use_slaves()
	self:add_slave(mirror:new():flip())
	self:add_slave(slimebelly:new():init(extra))
	self:boss_health()
end

function slimeboss:update()
	if not slime.update(self) then
		if self.x<=cam.x then --code duplication with batboss?
			self.x = cam.x
		elseif self.x>=cam.x+120 then
			self.x = cam.x+120
		end
	end
	self.s+=197
	self.f=false
	self:update_slaves()
	self:boss_health()
end

slimebelly = enemy:new({extends_hitbox=true})

function slimebelly:init(extra)
	self:use_slaves()
	self:add_slave(mirror:new())
	if (extra) self:add_slave(slimebelly:new():init())
	return self
end

function slimebelly:update()
	self:goto_master()
	self.s, self.pal, self.invis = self.master.s+16, self.master.pal, self.master.invis
	self.y+=8
	self:update_slaves()
end

--------------------------------------------------------------------------------

summoner = enemy:new({s=229, health=8, max_health=8, width=16, height=16, timer=0})

function summoner:init()
	slimeboss.init(self)
end

function summoner:update()
	self:boss_health()
	if (self:offscreen()) return
	p_width=8
	self.timer+=1
	if self.timer>20 then
		self.timer, self.s = 0, 459-self.s
	end
	if self.invul>0 then
		self:fly_when_hit()
		self.health=0
	else
		if self:die_when_dead() then
			self:hit_player()
		else
			final_boss = demon:new({x=self.x, y=self.y-64}):init()
			add_actor(final_boss)
		end
	end
	self.f=false
	self:update_slaves()
end

--------------------------------------------------------------------------------

demon = enemy:new({s=210, health=3, max_health=3, timer=0, width=16, height=24})

function demon:init()
	slimeboss.init(self, true)
	self:add_slave(demon_hand:new())
	self:add_slave(demon_hand:new({f=false}))
	return self
end

function demon:update()
	self:boss_health()
	if (self:offscreen()) return
	if self.health<=0 then
		self.timer, self.s=move_towards(0.25,self.timer,0.01),212
		self:move()
		play_music(-1)
		if self.timer==0.25 then
			ending_sequence=true
			if (got_stones>=3) good_end=true
		end
	elseif self.invul>0 then
		self.invul-=1
		self.invis=not self.invis
	else
		p_width=min(p_width+0.5, 46)
		self.invis = p_width<46
		if not self.invis then
			self.timer=(self.timer+0.008)%1
			self.s=210+self.timer*2
			play_music(1)
			self:move()
			self:hit_player()
		end
	end
	self.f=false
	self:update_slaves()
end

function demon:move()
	if (ending_sequence) return
	self.y=40+max(-0.5, sin(self.timer))*30
end

demon_hand = enemy:new({s=240})

function demon_hand:update()
	local m=-1
	if (self.f) m=1
	local timer = self.master.timer*2+0.4*m
	self:goto_master()
	self.x += m*(cos(timer)*-15+16)+4
	self.y += cos(timer)*8+20
end

--------------------------------------------------------------------------------

ending_stone = actor:new({s=58, ignore_walls=true})

function ending_stone:update()
	local timer = e_timer+self.num/3
	if e_rad<35 then
		self.x=move_towards(cam.x+60+sin(timer)*e_rad,self.x,2)
		self.y=move_towards(cam.y+40+cos(timer)*e_rad,self.y,2)
	else
		self.s=55
		self:gravity()
	end
end

--------------------------------------------------------------------------------

platform = actor:new({width=16, height=3, s=48, speed = 0.005, xw=0, yw=0, pal_type=0, depth=-5})

function platform:init()
	self.origin_x, self.origin_y, position = self.x, self.y, 0
	self:use_slaves()
	self:add_slave(mirror:new())
	self:use_pal()
end

function platform:update()
	self.supporting_player = false
	if player.x>=self.x-8 and player.x<self.x+self.width then
		if player.y + player.height >= self.y and player.prev_y + player.height <=self.y+self.height then
			player.y, player.grav = self.y-14, 0
			self.supporting_player = true
		end
	end

	local prev_x, prev_y = self.x, self.y

	self:move()

	if self.supporting_player then
		plr_prev_x, plr_prev_y = player.x, player.y
		player.x+=self.x-prev_x
		player.y+=self.y-prev_y
		if player:is_in_wall() then
			player.x, player.y = plr_prev_x, plr_prev_y
		end
		player:update_slaves()
	end

	self:update_slaves()

end

function platform:draw()
	local prev_x = self.x
	if self.supporting_player then
		self.x=player.x-flr(player.x-self.x)
		self:update_slaves()
	end
	actor.draw(self)
	self.x = prev_x
	self:update_slaves()
end

function platform:move()
	self.position = (self.position+self.speed) % 1
	self.x, self.y = self.origin_x + self.xw * sin(self.position), self.origin_y + self.yw * sin(self.position)
end

--------------------------------------------------------------------------------

-- fall_platform = platform:new({pal_type=2, always_update=true, timer=0, flicker_timer=0, falling_timer=0})
--
-- function fall_platform:move()
-- 	self.change_x = 0
-- 	self.change_y = 0
-- 	self.flicker_timer = max(self.flicker_timer-1, 0)
-- 	self.invis = self.flicker_timer%2!=0
-- 	if self.supporting_player then
-- 		self.falling_timer+=1
-- 		if self.falling_timer>=10 then
-- 			self.falling = true
-- 		end
-- 		self.timer = 0
-- 	else
-- 		self.timer+=1
-- 		self.falling_timer=0
-- 	end
-- 	if self.falling then
-- 		self:gravity()
-- 		if self.timer>60 then
-- 			self.falling, self.flicker_timer = false, 20
-- 			self.x, self.y = self.origin_x, self.origin_y
-- 		end
-- 	end
-- end

--------------------------------------------------------------------------------

pendulum = platform:new({xw=0, yw=0, speed = 0.003})

function pendulum:init()
	platform.init(self)
	self.length = self.y-self:get_top()
end

function pendulum:move()
	self.position = (self.position+self.speed) % 1
	local p = sin(self.position)/15
	self.x, self.y = self.origin_x + self.length * sin(p), self:get_top() + self.length * cos(p)
end

function pendulum:draw()

	for i=-1,1 do
		line(self.origin_x+8+i, self:get_top(), self.x+8+i, self.y+8, 6-abs(i))
	end

	for i=0,1 do
		circfill(self.x+8, self.y+6, 10-i*3, 9+i)
	end
end

function pendulum:get_top()
	return self.y-self.y%112
end

--------------------------------------------------------------------------------

cam_border_right = actor:new({depth=-20})

function cam_border_right:update()
	if self.x+8>=player.x then
		cam.x = min(cam.x, self.x-120)
	end
end

--------------------------------------------------------------------------------

cam_border_left = actor:new({depth=-20})

function cam_border_left:update()
	if self.x<=player.x then
		cam.x = max(cam.x, self.x)
	end
	if self:on_camera() and player.x<self.x and self.x-player.x<16 then
		self.dead=true
	end
end

boss_cam = actor:new({depth=-20})

function boss_cam:update()
	if player.x>=self.x then
		cam.goal_x = self.x
		cam.special_goal = true
		if not level_end then
			play_music(6)
		end
	end
end

--------------------------------------------------------------------------------

mirror = actor:new({extends_hitbox=true})

function mirror:update()
	self:goto_master()
	self.x+=8
	self.s, self.pal, self.invis = self.master.s, self.master.pal, self.master.invis --code duplication? slimebelly?
end

function mirror:flip()
	self.f=true
	return self
end

--------------------------------------------------------------------------------

chicken = actor:new({s=61, depth=-10, grav=-2})

function chicken:init()
	self.y+=8
end

function chicken:update()
	if self:is_in_wall() then
		self.invis = true
	else
		self.invis = false
		self:gravity()
		if self:intersects(player, true) then
			player.health = player_max_health
			sfx(2)
			self.dead = true
		end
	end
end

--------------------------------------------------------------------------------

breakable_block = actor:new({breaks=true})

function breakable_block:break_me()
	self.breaks = false
	mset(self.x/8, self.y/8, 0)
	self.dead = true
	for i=0,1 do
		for j=0,1 do
			add_actor(block_bit:new({x=self.x+i*4, y=self.y+j*4, grav=-2+j, acc=(i-0.5)/8, f=i==j}))
		end
	end
	for a in all(actors) do
		if a.x==self.x and a.depth==-20 then
			a.dead = true
		end
	end
	sfx(8)
end

--------------------------------------------------------------------------------

block_bit = actor:new({s=49, life=30, width=4, height=4, dcc=0, ignore_walls=true})

function block_bit:update()
	self:gravity()
	self:momentum()
	self.life-=1
	if self.life<=0 then
		self.dead = true
	end
end

--------------------------------------------------------------------------------

heart_crystal = actor:new({s=57, invis=true, grav=-2, depth=-10})

function heart_crystal:init()
	self.x-=36
end

function heart_crystal:update()
	if not self:on_camera() then return end
	if self.invis then
		if cam.x>self.x-80 then
			self.invis = false
			for a in all(actors) do
				if a.enemy and a:on_camera() then
					self.invis = true
				end
			end
			if not self.invis then
				self:be_chicken()
			end
		end
	else
		self:gravity()
		if self.grav<0 then
			self:death_particle()
		end
		if self:intersects(player,true) then
			self.dead = true
			self:collect()
		end
	end
end

function heart_crystal:collect()
	sfx(3)
	health_go_up = true
	level_end = true
	play_music(-1)
end

function heart_crystal:be_chicken() end

--------------------------------------------------------------------------------

stone_sealing = heart_crystal:new({s=58})

function stone_sealing:collect()
	sfx(3)
	got_stones+=1
	got_level_item = true
end

function stone_sealing:be_chicken()
	if got_level_item then
		self.dead = true
		add_actor(chicken:new({x=self.x, y=self.y}))
	end
end

--------------------------------------------------------------------------------

key = stone_sealing:new({s=56})

function key:collect()
	sfx(3)
	got_key=true
	got_level_item = true
end

--------------------------------------------------------------------------------

next_level_marker=actor:new()

function next_level_marker:update()
	if self.num2 then
		self.lv=nl_2
	else
		self.lv=nl_1
	end
	if self:intersects(player) then
		next_level, level_end = self.lv, true
		progression+=1
	end
end

--------------------------------------------------------------------------------

levels =
{
	{music=0, data="1i23232jjjkk2j|5vzv5vzv5vxb0h0710125vw31m5v1j181l1m169j5v955vw11m5v1m5vw1110hw1110hw1118h5v9418141l161m5vw8dv0h125v10075vw21n5vw1165v1n165vw114155v1m5v1m5vw1110hw1110hw1110h5vw1165vw1161n5v131k155vw51210120m125vw21314w11714w117945v14w15v1n5v1m5vw1110hw1110hw1118h5v141714w117141k14w2155v0uw28u01w300w1050l0tw75v14w1155vw11n5v1h1r1o1i1h1i1h1i1h5v0tw61h1r1o1i1g0f0v0f0v0jw4001d031dw6135v14w25vw4025v111315115vw21dw7021d1h1i5v1f5v1f5vw200w35v035vw31314w15v14w2155vw2025vw11114w111155vw20e5vw4025v1h1i1g5v1f5v1f01w300w3150313151314w1945v14w3155v020e13141114w11114955vw1115vw10e5v025v1h1i1h1i5v1f5v1f0jw200w60sw55v0sw41h1i1h1i1h1i01w45v1i1h1i1h1i1h1i1h1i1h1i1g08w35vzv5vzv5vxb14w51l5vw11j14w4945v00wf5v00wf14w31l5vw51j14w35v00wf5v00wf14181l5vw91j14185v00wf5v00wf5v165vw813155vw1165v00wf5v00wf15165vw113155v2e2f5v13141k1415165v00wf5v00wf141715131k14152u2v131k14w11k14975v00wf5v00wf0twf5v00wf5v00wf1dwf5v00wf5v00wf"},
	{music=8, next_start_x=4, next_start_y=58, start_x=16, start_y=82, map_string="the path splits here...", nl_1=3, nl_2=4, offset = -58, data="352233e20f1099d00323289197h04c00a|26wp00w20hw30n5v100hw40n5vw100w2100hw30n80005vw4025vw2008000w3800012035v10921126w5a626wda60026wp00w20h125vw60m0h8h0n5vw100w2100hw30n00w15vw3025vw300w70h07030m0h1126wl0026w7242526wf00w2125vw406125vw600w20n100h0n0m0h00w15vw2025vw400w7121007030m1126wh242526w10026w72k2l26w530222326w130222326w100w2125vw2100hw2075vw3101200w20hw2075v1000w15v00w40k0400we2326w130222326wbak2l26w10021222326w130222326w130222326w1303g2i2j20213g5v2j202100w40k0400w4050l00w6100n100h070m005vw2lv5vw20200wf2j20213g5v2j20212326w130222326w1302223302223002h2i2j20213g2i2j20213g2i2j20213g5vw22g2h5vw22g2h5v115vw202060h00w20h07035vw10m0n00w210125v0m0n5v005vw5025v00wf5v2g2h5vw22g2h2j20213g5v2j20213g2i2j3g2i2j005vw22g2h5vw22g2h5vw22g2h5vwb115vw10206gh0n00w2121007035vw10h0n00100hw1125vw2805vw4025vw100w80h000m00w35vw82g2h5vw22g2h5vw5005vwq115v025v10120600w20hw207035v0m0h11100n100n5v1007805vw3025vw200w80n125v001200w15vwfdv5vw4005vwp00w40k0400w5100h07035v0m11gm0hw10n5v00wi5v0m0h0n001000w15vwl005vw8060e5vwf110h125v020600w512100h07035v115v100n5vw100wi075v0n5v120m00w15vw70e5vwb1000155vw213155vw210115vw3131400w45vw313118n5v02060h00w701w200w10100w10501w300w10100w201w200w6125vw1120m0700w15vw1060h120e5vw11110125vw60e5v100h0014155v1314111206120h115vw21314w1115vw21114155v131411120206120m00w70jw200110j000jw1030jw6000jw400w50h07060h070m00w15v0e100hw1115vw1110hw20e5vw4110hw20001w31h1i1h1i1h1i1h1i01w4115vw21101wf00w25vw200115v00w15vw1035vwc00w401w500w101w10k0400w101w1000100w201w400w10100w10jwg115vw2110jwe00w35vw100w11100w25vw2035vwb00w40jw500w10jw1020jwi0026a600w10h12115vw311100h00w1a62600wu80005vw1035vw61j14w11k14w21k14w11l5vw6025v008000wh26w100w10h12115vw311100h00w126w100x0155vw1035vw61k14w21k14w11l1m5vw6025vw18000wi26w100w10m0h115vw311070m00w126w100x014155vw1035vw51j14w41l5v1m5vw5025vw28000wi26w100w1070m115vw3110h0700w126w100x1050l00w25vw51m141k1l1mlv5v1n5vw4025vw38000wi26w100w10h12115vdv5vw111120h00w1263000x05vw1035vw81n1j1l5v1m5vw400wr232600w10hw1115vw311108n00w1213g00x015lv5v035vwb1m5vw500wq2j2000w11210115vw3110n0600w12h5v00x014w1155v035vwa1n5vw600w15v115vw1115vwj2g00w1125v115vw311061200w15vw100x75vwg00w15v115vw1115vwk00w10h12115vw3110h0n00w15vw100x05v115v115v115vwcdv5vw300w15v115vw1115vwk00w10h12115vw2dv11100700w15vw100x015115v1115115vwh00w15v115vw1115vwj00w212w1115vw311100h00w25v00x0141113119411155vw6dv5vw71300w15v115vw1115vwj00w20k0400w5050l00w25v00x014111411141114155v13155vw213155vw1lv5vw11314w100w15v115vw1115vwi00w15vw1025vw20m0h0n0m0n030m0h00x201wa5vw101w25vw101w500w15v115vw1115vwi00w15v025vw3060n060n100n031000wm08wm0ow108w20ow108wv"},
	{music=1, next_start_x=4, next_start_y=194, start_x=16, start_y=82, map_string="the path continues...", nl_1=5, data="2ii23e2f540c3i901g91064500b|14w5155vw11j14wk1l5v1j149414w91894009414we9l5v1j14wb940014w6155vw11j14wb1l1j14w31l1m5vw31j14w71l5v165v0014wb18141l5vw314wc0014w7155vw11j14w91l5vw11j181l5vw11m5vw41m1j14w31l5vw2165v0014w21l5v1j1418141l5vw1165vw51j14wb0014w71l5vw31j14w61l5vw3165vw21n5vw41n5vw11j181l5vw3165v00141l5vw4165vw3165vw71j14w59414w2001j14w51l5vw51j14w41l5vw4165vwc165vw4165v005vw6165vdv5vw1165vw814w9005vw11j1418141l5vw40e5vw21j181l5vw6165v0e125vw9165vw4165v005vw6165vw3165vw11h1i1h1i1h1i5v1j14w8005vw3165vw510115vw3165vw513151613110h075vw31314155vw1165vw4165v005vw6165vw3165vw11g1h1i5vw1115vw11jw118141l1m1j1418005vw3165vw4100h11125vw2165vw31314w21714110hw1125v1314w415165vw3131714005vw1dv5vw2dv165vw21317155v1h1i1g5vw1115vw3165vw11m5vw116005vw3165vw40hw111125vw2165vw11314w41h1i1h1i1h1i0tw21h1i1h1i1417155v1314w3005vw51317155v1314w2151g1h1i5vw1115vw3165vw11n5vw1160014155vw1165vw3060hw1110h075v131714w71g1h1i1dw61h1i1g14w8005vw41h1i0tw100050l0tw21h1i1g155v115vw3165vw4160014w2151613155vw11h1i1h1i0twc1h1i5vw81h1i0tw2000k04000tw25vw41g1h1i1dw2031dw25v1h1i1415115vw3965vw21314170014w31714w31g1h1i1dwd1g5vwa1g1dw3021dw45vw41h1i5vw4035vw31g14w111141513141714w5000tw81h1i5vwu025vw4005vw41g5vw6035vw11h1i0twe1dw81g5vwu025vw5000ow41h1i5vw6035vw11g1dwe5vw21j14w71l5vw21m5vw11m5vw11m5vw9805vw5025vw71j14w81l5vw3035vw5lv5vwe1j14w41l5vw31m5vw11n5vw11m5vw9005vw4025vw91m1j14w41l1m5vw5035vwf125vw414w31l5vw41m5vw41m5vw9805vw3025vwa1m5vw11j14w11l5v1m5vw6035vw1lv5vwb125v0e5vw21j141llv5vw1dv0e5vw11n5vw41m5vw9805vw2025vwb1m5vw21m5vw21m5vw7035vwd0h12115vw3lv5vw310115vw71n5vw600we5vw41n5vw21n5vw21n5vw600w45vwa0hw1115vw81011125vwg115v115vw5115v115vwedv5vw6115v115vwb0hw1110h075vw5100h11125vwf131115115vw5115v115vwidv5vw2115v115vwb0hw1110hw1125vw3060hw1110h125vwc1314w1111411155vw4115v115vwc00w45vw4115v115vwb1h1i1h1i0tw71h1i1h1i5vwa1h1i1h1i0tw41h1i1h1i5v115v115v00w25vw5dv5vw2115v115vw5115v115vwb1g1h1i1dw91h1i1g125vw2dv5vw4101g1h1i1dw61h1i1g15115v115vwd115v115vw5115v115vwb1h1i5vwb1h1i0h125vw6060h1h1i5vw81h1i141115115vw1dv5vw8dv5v115v115vw5115v115vwb1g5vwd1g0h125vw60hw11g5vwa1gh4111411155vwc115v115vw5115v115vwb1h1i5vwb1h1i0hw1075vw4060hw11h1i5vw81h1i0twl5vw4115v115vwb1g5vwd1g0hw2125vw2100hw21g5vwa1g1dwl0owj"},
	{music=8, next_start_x=140, next_start_y=90, start_x=16, start_y=194, map_string="the path splits again...", nl_1=2, nl_2=2, offset = 50, data="2jellf5l4000849ml5232g0l000ll|155v035vw71m5vw11m5vw21m5vw4035vw51m5vw41m5vwb1mw15vw41m5vw7dv5vw21m5vw71m5vw100145vw1035vw61n5vw11m5vw21m5vw5035vw41m5vw41n5vwb1m1n5vw41m5vwb1m5vw71m5vw10014155vw1035vw81m5vw21n5vw6035vw31n5vwh1m5vw51m5vwb1m5vw71m5vw1000sw61h1i5vw41n5vwb03he0u5vwd1e8u0uw15vw11n5vw51n5vwb1n5vw6dv1m5vw1001cw51h1i1g155vwe0f0v0f0v0f5vw3dv5vw70f0v0f0v0f5vwu1n5vw1005vw61h1i14155vw10ugu0uw15vw81f5v1f5vwe1f5v1f5vx2005vw60sw31h1i0fw10v0f5vw81f5v1f5vwe1f5v1f5vx2005vw31h1i5v1cw21h1i1g5vw11f5vw91f5v1f5vwbdv5vw11f5v1f5vw5dv5vw3dv5vwm005vwa1h1i5vw11f5vw91f5v1f5vw7dv5vw51f5v1f5vwddv5vwj005vw51h1i5vw31g5vw11f5vdv5vw71f5v1f5vw61e0uw35vw21f5v1f5vw21h1i1h1i0sw31h1i1h9i5vwfdv5vw2005vwa1h1i5vw11f5vw4dv5vw31f5v9f5vw40f0v0fw20v0f5vw21f5v1f5vw21g1h1i1cw51h1i1g5vw11h1i5vwf005vw11h1i5vw71g5vw11f5vw20uw45vw11f5v1f5vw51f5vw21f5vw31f5v1f5vw21h1i5vw71h1i5vw11gw15vw11h1i1h1i0sw31h1i1h1i5vw1005vwa1h1i5vw11f5vw20f0v0f0v0f5vw11f5v1f5vw51f5vw21f5vw31f5v1f5vw21g5vw91g5vw11h1i5vw11g1h1i1cw51h1i1g5vw1005vwb1g0ox41h1i5vw71h1i0ow11gw10ow11h1i5vw71h1i0ow10026xma600w3a626wja60026w7242526xd00w326wl0026w130222326w22k2l26wa30222326wv00w326wc242526w60020213g2i2j20212326w130222326w13022233020213g2i2j20212326w130222326w130222330222326w730222326w400w326wc2k2l26w6002g2h5vw22g2h2j20213g2i2j20213g2i2j3g2g2h5vw22g2h2j20213g2i2j20213g2i2j3g2i2j20212326302220213g2i2j20212326w100w32630222330222326w730222326w3005vw72g2h5vw22g2h5vwb2g2h5vw22g2h5vw52g2h2j213g2i2g2h5vw22g2h2j202100w3213g2i2j3g2i2j20212326302220213g2i2j20212326005vxa2h5vw92g2h00w32h5vw52g2h2j213g2i2g2h5vw22g2h2j21005vxm1300w35vw92h5vw92h0014155vxi1314w100w35vwedv5vw50014w3155vwh10075vw110125vwl1314w21k00w35vw40e5vwf0014w4155vwbdv5vw2100h125v068h0h075vwbdv5vw513141k14w300w35vw41112dv5vw5dv5v0e5vw40014w6155v0uwa5vw10h1h1i5v0h1h1i125vw10uw35vw10uw65vw2131k14w39k1400w35vw4110h075vlv5vw410115vw4000sw80fw10v0fw10v0fw10v0fw10sw11h1i1h1i1h1i0sw30fw10v0f5vw10fw10v0fw10v0f5vw10sw1000500w20sw55vw30sw300w305000sw35vw3001cw80owa1cwb0owe1cw3031cw70ow31cw8031cw30ow300"},
	{music=1, next_start_x=276, next_start_y=58, start_x=16, start_y=82, map_string="the castle drawbridge is ahead", nl_1=2, offset = -24, data="2d2223g11l011l9923efl0lm0l|14wt1l5vw2035vw49g1h1i5vw90m0hw29h1i1g5vw3025vw11j14w6941h14wb1l1m5v1j14wb1l1m5vw4035vw31h1i1g5vwa100hw19g1h1i5vw2025vw31m1j14w51h1j14w91l5v1m5vw11m1j14w81l5v1m5vw5035vw21g1h1i5vw7dv5vw20hw11h1i5vw2025vw41m5v1m1j1814w21h5v1m1j14w61l5vw11m5vw11m5v1m1j14w11814w21l5vw11m5vw6035vw11h1i1g5vwb0m0h1g1h1i1h1i1h1i1h1i1h1i1m5v1m5v161j14w11h5v1m5vw11j1418141l1m5vw21m5vw11n5v1m5vlv1m165vlv1m5vw21m5vw2lv5vw21h1i1h1i1h1i5vw11h1i1h1i1h1i5vw3lv101h1i1h1i5vw4115v1m5v1n5v16dv1m1j1h5v1n5vw3165vw11m5vw21m5vw31n5vw11n165vw11m5vw21n5vw11h1i1o1i1h1i1h1i1h1i1g5vw21h1i1h1i1h1i5vw31h1i1h1i5vw5115v1m5vw2165v1m5v1h5vw5165vw11m5vw21n5vw7165vw11m5vw602101h1i1h1i1h1i1h1i5vw311dv5vw11h1i1o1i1h1i1h1i5vw6115v1n5vw2165v1n5v1h5vw5165vw11m5vw41314w1155vw2165vw11n5vw5025v060hw21h1i1h1i5vw4115vw3025v1h1i1h1i5vw7115vw4165vw21h5v1314155vw1165vw11n5v13155v1314w515165vw7025v100hw212101h1i5vw5115vw2025v1h1i1h1i1h1i5vw6115vw4165vw21h1314w2155v165vw11314w41k14w19414w21714155vw41h1i1h1i12100hw39g5vw5115vw1025v1h1i1h1i060h1h1i5vw5115vw11314w11714151hw114w11k14w21714w31k14w41h1i1h1i14w3155vw41h1i1h1i0hw3129g5v06075vw2115v025vw21h1i07101h1i1h1i5vw4115v1314w21h1i1h1i1h14wf1h1i1h1i1h1i1h1i14w1155v1h1i1h1i1h1i1h1i1210121h1i0hw2125vw111025v0e5vw21h1i0m0h1h1i5vw313141114w31h1i1h1i1hw10txr000400w10twb1h1dxr021dwe1h26xga61h9i1h1i0hw10n5vw102dv5vw21j14wa1h26xh1hw11i1g0h0n5vw1025vw51j14w61k14w11h26w4242526wg30222326wa30222326w130222326w130221h1i1h1i125vw1025vw71m1j14w61k1h26w42k2l26w530222326w130222326w1303g2i2j2326w130222326w3303g2i2j20213g2i2j20213g2i1hw11i1g0n5v025vw81m5vw11m5vw19j14w21h26w130222326w130222326w1303g2i2j20213g2i2j20213g5vw22j20213g2i2j202120213g5vw22g2h5vw22g2h5vw11h1i1h1i1h1i1h1i1h1i5vw51n5vw11m5vw51h20213g2i2j20213g2i2j20213g5vw22g2h5vw22g2h5vw42g2h5vw22g2h2g2h5vwc1hw11i1h1i1h1i1h1i1g5vw81m5vw51h2g2h5vw22g2h5vw22g2h5vx51h1i1h1i1h1i1h1i1h1i1h1i1h1i5vw41m5vw11h1i1h1i1h5vwmdv5vwp005vw31h1i1h1i1h1i5v115vw51n5vw2115v1hw15vwm1h1i5vw5dv5vwg13005vw41h1i1h1i5vw1115vw9115v141h14155vwedv1h1i1h1i1h1i1h1i5vwk1314w1005vw51h1i1g155v115vw20e5vw4dv1113141h14w2155vw8lv5vw21h1i1h1i1h1i1h1i1h1i1h1i1h1i1h1i5vw7dv5vw31314w2005vw61h1i1415115vw2115vw4131114w11h14w4155vw91h1i1h1i1h1i1h1i1h1i5vw11h1i1h1i1h1i0tw70k0400w114w3005vw51h1i1g14w11114155v115vw10e5v13141114w11h14w500w1050l0tw51g1h1i5vw31h1i1h1i5vw11h1i5vw11h1i1dw6021dw11314w3005vw61h1i0twf1h14w5151dw1031dw51h1i5vwf1h1i5vw4025vw11314w4005vw71g1dwf1h"}
}

function _init()
	--almost all of the properties can be shoved in one long list. tokens!

	--hard_mode = false

	enemy_pal_1, enemy_pal_2, hurt_pal, player_pal = {5,8,2,15},{2,14,8,0},{8,9,7,7},{1,13,2,15}

	whip_length, whip_speed, whip_cooldown = 10, 0.25, 10

	--player.y=82
	player:use_slaves()
	player:add_slave(player_legs)
	player:use_pal()
	--player:update_slaves()
	--player_sword:use_slaves()
	--player:add_slave(player_sword)
	--player_sword:add_slave(player_sword_tip)

	player.whip = whip:new()
	player:add_slave(player.whip)
	player.whip:setup(whip_length)

	--next_start_x, next_start_y = 4, 58

	terminal_velocity, grav_acc, player_jump_height, player.health, player_max_health, health_timer = 4, 0.15, 2.5, 6, 6, 0

	-- boss_health, boss_max_health = 2
	-- boss_max_health = 6

	--draw_bounding_boxes = false

	blackout_time, current_level = 0,2
	got_key, got_stones, e_timer, e_stones, e_rad = false, 3, 0, {}, 20

	--i might be able to shorten this, token-wise
	darker_pal, darkness = {0,0,0,5,2,0,5,6,2,4,9,3,1,5,2,14}, 0

	level_start_timer, level_end_timer = 0, -20
	level_start, difficulty_menu, progression, between_levels = true, true, 0, false

	p_width, p_timer=46,0

	player:update()
end

function clear_level()
	actors = {player, cam}
	for i=0,127 do
		for j=0,27 do
			mset(i,j,0)
		end
	end
end

entity_dict = {zombie, bat, cam_border_right, cam_border_left, platform:new({yw=24}), platform:new({xw=24}), platform:new({yw=-24}), pendulum, chicken, breakable_block, shooter, shooter:new({base_f=false}), axe_knight, batboss, boss_cam, heart_crystal, stone_sealing, key, medusa_spawner, next_level_marker, next_level_marker:new({num2=true}), slime, slimeboss, slimeboss}

function load_level(level, respawning)
	cls()
	clear_level()
	centre_print("loading...", 61, 7)
	centre_print("level "..level, 55, 7)
	between_levels = level==1
	current_level = level
	level = levels[level]
	s = level.data
	if level.start_x then
		start_x, start_y = level.start_x, level.start_y
	else
		start_x, start_y = next_start_x, next_start_y
	end
	if level.next_start_x then
		next_start_x, next_start_y = level.next_start_x, level.next_start_y
	end
	if level.next_level then
		next_level = level.next_level
	else
		next_level = 1
	end
	if level.nl_1 then
		nl_1, nl_2 = level.nl_1, level.nl_2
	end
	if level.offset then
		level_offset = level.offset
	end

	if not respawning then
		player.x, player.y, player.acc, player.spd, player.grav, player.f = start_x, start_y, 0, 0, 0, false
		player:checkpoint()
		cam.special_goal = false
		cam:jump_to()
		cam:y_move()
		cam:update()
		player:update_slaves()
		if between_levels then
			cam.x=flr(player.x/136)*136
		end
	end

	if (level.map_string) map_string = level.map_string
	width = two_char_to_int(sub(s,1,2))
	cursor = 3
	x, y = 0, 0
	got_entities = false
	entity_list = {}
	chain = 0
	while cursor<#s or chain!=0 do
		if not got_entities then
			char = sub(s,cursor, cursor)
			if char == "|" then
				got_entities = true
			else
				num = char_to_int(char) + 1
				add(entity_list, entity_dict[num]:new():level_up())
			end
			cursor+=1
		else
			if chain<=0 then
				local first = sub(s,cursor,cursor)
				local second = sub(s,cursor+1,cursor+1)
				local it_is_chain = false
				local mult = 0
				for a in all({"w","x","y","z"}) do
					if a == first then
						it_is_chain = true
						break
					else
						mult+=32
					end
				end
				if it_is_chain then
					chain = mult+char_to_int(second)-1
				else
					tile = two_char_to_int(sub(s,cursor, cursor+1))
				end
				cursor+=2
			else
				chain-=1
			end
			local en, hard = false, false
			if tile>=512 then
				tile -= 512
				en, hard = true, true
			elseif tile>=256 then
				tile -= 256
				en = true
			end
			if en then
				ent = entity_list[1]
				del(entity_list, ent)
				if not hard or hard_mode then
					ent.x, ent.y = x*8, y*8
					ent:init()
					add_actor(ent)
				end
			end
			mset(x,y,tile+64)
			x+=1
			if x>=width then
				x=0
				y+=1
			end
		end
	end

	if level.music then
		level_music = level.music
		if between_levels then
			play_music(level_music)
		else
			play_music(-1)
		end
	end

	local s=summoner:new({x=56, y=80})
	s:init()
	add_actor(s)
end

function char_to_int(c)
	for i=0,31 do
		if char_at("0123456789abcdefghijklmnopqrstuv",i+1) == c then
			return i
		end
	end
end

function two_char_to_int(string)
	local num1, num2 = char_to_int(char_at(string,1)), char_to_int(char_at(string,2))
	return num2+num1*32
end

function char_at(s,i)
	return sub(s,i,i)
end

--------------------------------------------------------------------------------

function _update60()
	p_timer=(p_timer+0.01)%1

	if difficulty_menu then
		if btnp(3) or btnp(2) then
			hard_mode = not hard_mode
			sfx(2)
		end
		if btnp(4) or btnp(5) then
			difficulty_menu = false
			if hard_mode then
				player.health, player_max_health=4,4
			end
			load_level(current_level)
			sfx(3)
			darkness=4
		end
		return
	end
	if blackout_time>0 then
		blackout_time-=1
		return
	end
	if health_go_up then
		if health_timer>=10 then
			if player.health>=player_max_health then
				health_go_up = false
				player_max_health+=1
				sfx(1)
			else
				sfx(0)
			end
			player.health+=1
			health_timer=0
		end
		health_timer+=1
		return
	end
	if level_end then
		if level_end_timer<=40 then
			level_end_timer+=1
		else
			level_start, level_end, level_end_timer, got_level_item= true, false, 0, false
			load_level(next_level)
		end
		darkness=level_end_timer/5
		if (not ending_sequence) return
	end
	if level_start then
		if level_start_timer<=20 then
		 	level_start_timer+=1
			darkness=4-level_start_timer/5
		else
			level_start, level_start_timer, darkness = false, 0, 0
			play_music(level_music)
		end
		return
	end
	--end of the game
	if ending_sequence then
		if e_timer<0.01 and got_stones>0 then
			local es = ending_stone:new({x=player.x,y=player.y,num=got_stones})
			add(e_stones, es)
			add_actor(es)
			got_stones-=1
		end
		-- for a in all(e_stones) do
		-- 	a:update()
		-- end
		e_timer=(e_timer+0.01)%1
		if got_stones==0 then
			p_width-=0.25
			if good_end then
				e_rad-=0.15
				for i in all(e_stones) do
					i:death_particle()
				end
				--p_width-=0.15
			else
				e_rad+=0.15
				if e_rad>40 then
					final_boss.y-=2
					final_boss.s=210
					final_boss.timer+=0.01
					final_boss:update_slaves()
					p_width+=2
				end
			end
		end
		if e_rad<=2 or e_rad>60 then
			level_end=true
		end
		--return
	end
	sort_actors()
	for a in all(actors) do
		if (a.y>=cam.y and a.y<cam.y+112) or a.always_update then
			a:update()
			if a.enemy and a.health<=0 and not a:on_camera() then
				a.dead = true
			end
			if a.dead then
				del(actors, a)
			end
		end
	end
	--all of the below can probably be removed
	-- if film_reel then
	-- 	film_offset += film_speed
	-- 	film_speed += film_acc
	-- 	if film_speed<0 then
	-- 		film_speed = 0
	-- 	end
	-- 	if film_speed>128 then
	-- 		film_speed = 128
	-- 	end
	-- 	film_offset = film_offset % 128
	-- end
	--cpu_usage = stat(1)
end

function play_music(num)
	if playing_music!=num then
		music(num)
		playing_music=num
	end
end

function add_actor(a)
	add(actors, a)
end

function sort_actors()
	new_actors = {}
	while #actors>0 do
		local best
		for a in all(actors) do
			if not best then
				best = a
			else
				if a.depth>best.depth then
					best = a
				end
			end
		end
		add(new_actors, best)
		del(actors, best)
	end
	actors = new_actors
end

function is_solid(x,y)
	--ignore tiles above the camera.
	if y<cam.y then
		y=cam.y
	end
	return get_flag_at(x,y,0)
end

function get_flag_at(x,y,flag)
	x/=8
	y/=8
	return get_flag(x,y,flag)
end

function get_flag(x,y,flag)
	return fget(mget(x,y),flag)
end

function move_towards(goal, current, speed)
	if goal+speed<current then
		return current-speed
	elseif goal-speed>current then
		return current+speed
	else
		return goal
	end
end

--beware of floating point overflow!
function distance_between(x1,y1,x2,y2)
	xd, yd = abs(x1-x2), abs(y1-y2)
	return sqrt(xd*xd + yd*yd)
end

--probably won't use this
-- function start_film_reel()
-- 	film_reel = true
-- 	film_offset = 120
-- 	film_speed = 16
-- 	film_acc = -0.1
-- end

--------------------------------------------------------------------------------

function _draw()
	cls()

	if difficulty_menu then
		draw_basic_menu()
		return
	end

	-- if level_end_timer>20 then
	-- 	print("end of demo",64-22,60,7)
	-- 	print("thank you for playing!",20,102,12)
	-- 	return
	-- end
	if blackout_time<=0 then
		cam:set_position()
		map(0,0,0,0,128,32)
		draw_portal()
		for a in all(actors) do
			a:draw()
		end
		player:draw()
		map(0,0,0,0,128,32,0b1000)
		camera()
		clip()
	end

	--this bit can go.
	-- if film_reel then
	--
	-- 	int_offset = flr(film_offset)
	--
	-- 	if int_offset<112 then
	-- 		memcpy(0x4300, 0x6000, int_offset*64)
	-- 		memcpy(0x6000, 0x6000 + int_offset*64, (128-int_offset)*64)
	-- 		memcpy(0x6000 + (128-int_offset)*64, 0x4300, int_offset*64)
	-- 	else
	-- 		val = 128 - int_offset
	-- 		memcpy(0x6000+64*val, 0x6000, (128 - val)*64)
	-- 		rectfill(0,0,127,val-1,0)
	-- 	end
	--
	-- else
		if between_levels then
			draw_level_select_gui()
		else
			draw_hud()
		end
	-- end
	for i=1,darkness do
		darker()
	end
end

function draw_portal()
	if (p_width<=0) return
	camera()
	rectfill(63-p_width,0,64+p_width,95,0)
	for i=0,16 do
		for j=0,95 do
			if sin(p_timer+j/128)*8+8>i then
				pset(i+p_width+64,j,0)
				pset(63-p_width-i,95-j,0)
			end
		end
	end
	cam:set_position()
end

function draw_hud()
	--rectfill(0,112,127,127,0)
	line(0,112,127,112,5)
	print("player", 1, 114, 7)
	print("enemy", 108, 114, 7)
	for i=0,player_max_health-1 do
		spr(47, i*5, 120)
	end
	for i=0,player.health-1 do
		spr(63, i*5, 120)
	end
	for i=0,boss_max_health-1 do
		spr(46, 120-i*5, 120)
	end
	for i=0,boss_health-1 do
		spr(62, 120-i*5, 120)
	end
	--draw_stat()
	local s = {}
	if got_key then
		s = {56}
	end
	for i=1,got_stones do
		add(s,58)
	end
	local cursor=65-5*#s
	for i in all(s) do
		spr(i, cursor, 114)
		cursor+=10
	end
end

--replace this with something nicer.
function draw_basic_menu()
	centre_print("demon castle", 24,7)
	centre_print("demo version",30,12)
	centre_print("please select difficulty",48,7)
	s = "> normal  "
	if hard_mode then
		s="normal"
	end
	centre_print(s,64,7)
	s = "hard  "
	if hard_mode then
		s="> hard    "
	end
	centre_print(s,70,7)

	centre_print("use the arrow keys", 96, 7)
	centre_print("and the [z] and [x] keys", 102, 7)
end

function draw_level_select_gui()
	--draw border
	local cols = {0,8,0}
	for i = 1,3 do
		rect(i-1,63+i,128-i,128-i,cols[i])
	end
	--draw map
	rectfill(0,0,127,63,0)
	sspr(56,96,64,32,32,8)
	rect(30,6,97,41,7)
	--string
	centre_print(map_string,50,7)
end

function centre_print(str, y, col)
	print(str,64-2*#str,y,col)
end

--can remove this
-- function draw_stat()
-- 	middle_text = "actors: " .. #actors
-- 	print(middle_text,64-2*#middle_text, 115)
-- 	middle_text = ""..cpu_usage*100 .. "%"
-- 	for i=#middle_text,8 do
-- 		middle_text = " "..middle_text
-- 	end
-- 	middle_text = "cpu:"..middle_text
-- 	x = 64-2*#middle_text
-- 	print(middle_text,x, 121)
-- 	col = 3
-- 	if cpu_usage>1 then col=8 end
-- 	line(x,127,x+cpu_usage*(4*#middle_text),127,col)
-- end

function darker()
	for i= 0x6000, 0x7fff do
		local two = peek(i)
		local second = two % 16
		local first = lshr(two - second, 4) % 16

		first = darker_pal[first+1]
		second = darker_pal[second+1]

		poke(i, shl(first,4) + second)
	end
end

__gfx__
0000660600006606000066060006606000ff66060000660600006606000000000066660000000000000000000000000000055000005570000000770000005505
0006666000066660000666600066660000ff66600006666000066660000000000666666000055000000000000000000000566500055577000007777000055550
0066fff00066fff000666ff0066fff0000f6fff00066fff00066fff0000000000666666000577500000000000055550005666650555775707707777000057770
0066fff00066fff000666ff0ff6fff0000f6fff00066fff00066fff0000000000666fff000567500055550000566665005666650555776777705777000557770
067766700677667006666660ff76670006f7667006776ff0067766700000000057666f6005665000006665005666666505666650555777700766557000665570
6f77777f06f77770066677700f77770006777770067ff770067f77700000000055766f6500655000006667505766667505766750655577000076660000666600
6ff7777f06fff7700667fff00777770006777770067777700677ffff000000005555555500650000005577505777777505777750066557700066660000667777
0ff55500005ff50000555ff0055555000055550000555550005555ff000000005656566600500000000055000555555000555500006660000066660000666657
00555500005555000055550006775500007555500000000000000000000000005655567756555677060550600006000600060006006666000066660000677600
00755700000775000077566066677550567756600000000000000000000000005666566756665667060550600050555500005555065555500067760000777700
06770770000777000077766066007750566006600000000000000000000000000566566705665667655555560560565600055656655575550007770007770770
66600660000660000667055555500770500005550000000000000000000000000555556705555567655555565666555500566555555577550007600066600760
56000660000660000660000000000670000000000000000000000000000000000675656706675567656556565666555000566556555555500006700067000670
05500555000555000566000000000660000000000000000000000000000000006665656606665566066556605665550005665566555500600006670006700667
00000000000000000056000000000566000000000000000000000000000000006675675606675056005555000605550005055560555000000000000000000000
00000000000000000005000000000055000000000000000000000000000000006667567506667505006006000050500000505000055555500000000000000000
05000000050000000550000000000000000000000066700000000000000000006000000600060000006666665500600000055000055000000000000000000000
5650000059500000566500000000000000000000066677000000000000000000660550660066000000066660555066000005500056650000000666600aaaa000
0500000005000000566500000000000000000000666776700000000000000000666556660666550000006600055566606005500656650000000600600a00a000
0000000000000000055000000000000000000000666775770000000000000000666556666665550055555550005556666605506605500000000600600a00a000
0000000000000000000000000000000000000000666777700000000000000000660550660055566655555550666555006665566600000000000600600a00a000
0000000000000000000000000000000000000000566677000000000000000000600550060555666000006600066655006665566600000000000d00d009009000
0000000000000000000000000000000000000000055667700000000000000000000550005550660000066660006600006605506600000000000dddd009999000
00000000000000000000000000000000000000000055500000000000000000000005500055006000006666660006000060000006000000000000000000000000
06600660077700000660000002202200022022000220220002202200005550000660000002202200004440000000000000000000000000000000000000000000
677567757eee0000677600002ee288202882ee202882882028828820056775006006000028828820049aa400808080808080080000000007000666600aaaa000
67756775eee20000677600002ee8882028eeee2028888e202888882056666750600600002888e82049999a40808080808880088000990970000622600a88a000
05500550ee200000066000002e8888202eeee820288eee202888882056666650066600002888882049999940888080808880888809449440000622600a88a000
0000000000000000000000002e8888202eee88202eeeee2028888e2056666650000560600288820049999940080080808080088064444446000622600a88a000
0000000000000000000000000288820002e8820002eee200028ee20005666500000056560028200004999400080008808080080060444406000d22d009889000
0000000000000000000000000028200000282000002e2000002e200000555000000005600002000000444000000000000000000066000066000dddd009999000
00000000000000000000000000020000000200000002000000020000000000000000000000000000000000008888888888888880066666600000000000000000
07777770772777670000555555550000077055555555077000000000000000007777777700550555005505550055055507705555555507700000000056666665
7eeeeee80070007000000666666000007ee0066666600ee80000005500000000c717c7170600055506000555060005557ee0066666600ee80006500054444445
7eeeeee82202200200000000000000007ee0000000000ee8000000000000000071c171c16506d0506506d0506506d0507ee0000000000ee85605555005555550
7eeeeee8822822280000060000600000000006000060000000005505550000001c1c1c1cd50d5506d50d5506d50d550600000608706000005566550000000000
7eeeee8888888888555500000000555555550000000055550000000000000000111111115005550d5005550d5005550d55550008700055555665555000000000
7eeeee88082808200666000000006660066600000000666000550555055500001111111106d0500506d0500506d0500506660e887ee066605666555000000000
7eee888800000000000000000000000000000000000000000000000000000000111111116d5506d06d5506d06d5506d0700008887ee000005665555000000000
088888802000200806000000000000600600000000000060550555055505550011111111d5550d50d5550d50d5550d5006888880088880605566550000000000
00000000000000000000000002000000077777700777777000000000000000007777777700550555005505550055055077377767774777670000000056666665
066605550555055506660660000000207eeeeee87eeeeee80555055505550000c717c71706000555060005550600055000700070007000704444444454444445
000000000000000000000000000000007eeeeee87eeeeee8000000000000000071c171c10d06d0506506d0506506d05033033003440440045555555505555550
060666055505550555066600002000007eeeeee00eeeeee800055505550555001c1c1c1c050d5506d50d5506d50d5500b33b333b944944490004900000494400
000000000000000000000000000000007eeeee800eeeee880000000000000000111111110005550d5005550d50055500bbbbbbbb999999990004900000499400
066605550555055506660660000000007eeeee800eeeee8800000555055500001111111106d0500506d0500506d050000b3b0b30094909400004900000449400
000000000000000000000000000000007eee8880088888880000000000000000111111110d5506d06d5506d06d5506d000000000000000000004900000494400
06066605550555055506660000000000088000000000088000000005550000001111111105550d50d5550d50d5550d503000300b400040090004900000449400
0000000056655550000000000000003030300030303000004994444049944440303000300055055500550d550055055003000000040000000000000000494400
05550555565655500555000000033033000330330003300049494440094944000003303306000555060005550d00005000000030000000400000004400494400
0000000056655550000000000030303030303030303030004994444030944030303030300d06d0506506d0506506d00000000000000000000044445500449400
000555055566550055055500003000033030000330300030449944003009000330300003000d5506d50dd506d50d550000300000004000000455550000494400
0000000056655550000000000303033003030330030303304994444003000330030303300005550d500d550d500d550000000000000000000504900000449400
0555055556665550055500000033003300330033003300334999444000330033000000330000550506d0550506d0500000000000000000000004900000449400
000000005665555000000000330033003300330033003300499444403300330000944000000005000d5505000d55000000000000000000000004900000494400
00055505556655005505550000330003003300030033000344994400003300030499440000000000005000000000000000000000000000000004900000449400
07777770077777777777777030003300303000303000330003000300030003000770555555550770077777777777777000000000000000000000000000000000
76666665766666666666666500330033007330330033003300300300003003007660066666600665766666666666666500000000000000000000000000000000
7666666576666666666666653300330037a730303300330000033000000330007660000000000665766666666666666500000000000000000000000000000000
76666655766666666666665503303030307000730330303000033000000000000000060000600000066666666666665000000000000000000000000000000000
76666565766666666666656503000303030307a73000030000300300000000005555000660005555066666666666656000000000000000000000000000000000
76565655766666565656565500030303003700730303030000300030000000000666005656006660066666565656565000000000000000000000000000000000
75656555766565656565655500033000337a73003303300003000030000000000000056565600000066565656565655000000000000000000000000000000000
05555550055555555555555000000303003700030300000003000030000000000600555555550060000005555550000000000000000000000000000000000000
22222222222222222220022222222222222227777772222222222222000000000000000000000000000000000000000000000000000000000000006666000000
22222222222222222207002222222222222222226777722222222222000000000000000000000000000000000000000000000000000000000000665555660000
22222222222222222077030222222222222222222277772222222222000000000000000000000000000000000000000000000000000000000006555660555000
22222222222222220730733022222222222222222227777222222222000000000000000000000000000000000000000000000000000000000005555660555000
02222222220222207777373702222222222222222226777222222222000000000000000000000000000000000000000000000000000000000005566666605000
30222022207022073773033030222222222222222222777722222222000000000000000000000000000000000000000000000000000000000005566666605000
33020702073000773333303033022222222222222222777722222222000000000000000000000000000000000000000000000000000000000005500660005000
33307330733307733333300333302222222222222222777722222222000000000000000000000000000000000000000000000000000000000005555660555000
00070337033077333300330070030222222222222222777700000000000000000000000000000000000000000000000000000000000000000005555660555000
00733030000773330033000300330022222222222226777700000000000000000000000000000000000000000000000000000000000000000005555660555000
000030030070000000000300000303027222222222277777000000000000000000000000000000000000000000000000000000000000000000e5555000555800
00000030000003300030000000003330672222222277777200000000000000000000000000000000000000000000000000000000000000000e33355555558a80
00000000000000003300000000000300277222226777777200000000000000000000000000000000000000000000000000000000000000006666666666666666
00000000000000000000000000000033227777777777772200000000000000000000000000000000000000000000000000000000000000006565565556565656
00000000000000000000000000000030222777777777722200000000000000000000000000000000000000000000000000000000000000005555555555555555
00000000000000000000000000000073222227777772222200000000000000000000000000000000000000000000000000000000000000005050050500050505
22222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222220020222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222207307022070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222077073000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22220773733307730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22207733000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22077333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20773030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07730330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
73303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
73730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005550000000500500005000000000000000000000000000000000000000000000007000000700000000000000000000700000000000070000000000000000
00057575000005750555555000000000000000000000000000000000000070000000052700005270000000007000000005270000000000527000000000000000
00575765000057555555555500000000000000000000000000000000000527000000527770052727000700052700000052727000700005272700000000000000
05765657000055755655556500000000000000000000000000000000005272700005222727522772705270527270000522272705270052227270000000000000
57657656000575655565565500000000000000000000000000000000052227270052222222722227272727222727005222222252727522222227000500000000
56656556000565655555555500000000000000000000000000000000522222227522222222272222222272222222752222222222222222222222705200000000
05555005000565500555555000000000000000000000000000000000222222222222222222222222222222222222222222222222222222222222272200000000
0000000000005500005555000000000000000000000000000000000022222222822222222223333333333333333d333332222222222222222222222200000000
000000000000000000011000000000000001100000000000000000002222222888222222223333353333333533dddd3353222255555555555555522200000000
000000000000005500110000000100000011000000000000000000002222223eee22222223333333333b33333466664333222555555555555555555500000000
00000055000005660171000000110000017100000000000000000000223252ee5e226d6d33333533333333344260662444225555161616161111155100000000
00005566000056660171000001710000017100000000000000000000383ee35e8532266d333b33333333334222222222222255511d6666661111111100000000
0005666600005666176100001761000017610000000000000000000022222222222222223b3333333b5333dd222222222225551111ddddd11111111100000000
00566666000566661761000016610011176100000000000000000000222222262225222243333353333333d6222222222255511122d060d22211155100000000
056666660005666616610011166511221661001100000000000000002222226d222252222333333333333422222222222555511222d66d622221111100000000
056666660056666616651122165522221665112200000000000000002222226622225522244433b335334222222222222555112222d0d0d22222111100000000
666666656666750022225561222225512222556100000088002200882222224622222555522244444444222225522d6d4d4d4d422ddddddd2222111100000000
666666756667750022222551222222112222255100000888002208882222444344422255555522222222222555226dd64d4d4d422ddd0ddd2222111100000000
66667775777775002222221122222210222222112200088800880888224444444444222555555555555555555226d62255111152222222222222111100000000
777777757777550022222210200221002222221022000888008808882244444444f44222250555555555555056ddd22555111152222222222222115500000000
7777775577775500220222102222210020222210888002880088828823444f344444442222655555555555222222225555111155222222222225111100000000
7777555577755500200221002222100022022100888888280088882824444444444444422d622626262222222222555551111155555522225555111100000000
555555505555500022222100222210002222210008888828000888282244f44444443444d6d22d66662222222225555511111115555555555555111100000000
5555500055500000222210002222100022221000008888820008888222244444444444f4462222ddd55555555555555111111111505555555551111100000000
00111100001111102222100022221000222210008888800088882000522224443f3444444d6ddd0665555ddd5555551111111111111555551111111100000000
01222210012222712222100020221000222210008888200088820000555222244444444346dd65d6d55226062222511111551111111111111111111100000000
012222211222221122210000222100002221000088820000888200001555222224444f44222225d6052222222222511111111111111111111111111100000000
122221711222210020210000221100002021000088820000888200001155522222244442222255d6622222622225511111111111111111111111111100000000
122221111222271020210000111000002021000088820000888200001115555222222222222555dd6226d6d6d655511111111111111551111111551100000000
121171001222211022210000110000002221000088882000888820005111555552222222225552d0626d6ddd6d55111111115511111111111111111100000000
171011000122271022100000000000002210000088888200888882001111115555555555555552222dd222222551111111111111111111111111111100000000
01100000001111101100000000000000110000002822880028228800115511115555555555522222222222225511111111111111111111115511111100000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010206030700000901010103070009000000010101000008010101010108090000000000000000000101010101080801010100000000000307010100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8686868686868686868686868686404000000000000000004040404040404045554040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868485868686404000000000000000000061626051515147435756516100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686869495868686404000000000000000000061516260626051474357516100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686868686404000000000000000000061515151626051624743606100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8280818283868686868686a08283404000000000000040404040405444404040404040404000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9290919293a182808182a1b09240404000000000000000616260624246514040404040404000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000919290919240404040404000000000000000615162424662604000006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000506151620000000000000000616242466260514000006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000506151620000000000404045554040404040404000006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6465000000000000000000506151620000000000006147436057515140404000006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040455500000000405444404040404040400000006151474346626040006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5161474300000000004240404040404040400000006162604743605140006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5161514743636465426340404040404040404040404555404040404040006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414140404040404045554040404040006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686864040516200000000000000430000000000006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686864040516200000000000000004300000000006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686864040515162000000000000000043000000006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686864040515162000000000000000000430000006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686864040516200000000000000000000004300006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868485864040515162000000004045554040404040406100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686869495864040516200000000000000430000000000006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686864040515162000000000000004300000000006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686864040515147000000000000000043000000006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686864040404051514700004045554040404040406100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686868640404051515700000000430000000000006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686868686404051620000000000004300000000006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686868686404051620000000000000043000000006100006100006100004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8686868686868686868686868686404051620000000000004040404040404555404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000171501715019150191501a1501a1501e1501e15023150231501e1501e1501a1501a150191501915017150171501714017140171301713217122171150010000100001000010000100001000010000100
0106000017550195501e5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001a5501e550235500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001362016630166301663015620146102362024630266222862229612000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000f75000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001175000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000d75000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000024630216401d6401a63019630176201760019600166001560015600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c1201d1201e1301f1301f1301f1301d1201b1201a1202460024600246002460024600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000400002423025230262302723028220282202822228222262322523224232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001c6301c6301c6302b6302b6302b6300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001133010330113301232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000216302364023640180001f6302164021640180001d6201f6301f6300c0001a6101c6201c6200000014630146201462314613146130000000000000000000000000000000000000000000000000000000
011400100253000500055300050004530005000553000500025300253205530005000453000500055300050000500005000050000500005000050000500004000040000500005000050000500005000050000500
010e00101a020190201702015020190201702015020130201e0201c0201a020190201c0201a020190201702000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000019020170201502013020170201502013020120201c0201a020170201a020190201702015020170201a020190201702015020190201702015020130201e0201c0201a020190201c0201a0201902017020
010e001019020170201502013020170201502013020120201002013020170201a0201902017020150201702000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e0010190201702015020130201602013020120200e020190201602013020120201a02019020170201502000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00001a1401a1301a1201a1201c1401c1301c1201c12019140191301714015140151401513015120151121a1401a1301a1201a1201c1401c1301c1201c1201e1401e130261402314023130231202312023112
010e00002514025120251402512025140251202514025120251402314023130231202114021130231402313025140251302512025120251202512025120251202512025122251222512225112251122511225112
010e0000231402313023120231201f1401f1301f1201f12021140211301f1401e1401e1301e1201e1201e1121f1401f1301f1201f1201c1401c1301c1201c1201e1401e1301c1401b1401b1301b1201b1201b112
010e00001c1401c1301c1201c1201a1401a1301a1201a120191401913019120191201614016130161201612017140171201714017120161401612017140171301712017120171201712017110171101711217112
011000001f0401e0401d0401c0401b0401b0401b0301b032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01160020181301a1301b1301f130181301a1301b1301f1301d1301a130161301a1301d1301a130161301a1301b1301813014130181301b13018130141301813016130181301a1301b1301d1301a130161301a130
011600001f0501f0501f0501f0501f0501f0501f0501f0501a0501a0501a0501a0501a0501a0501a0501a0501b0501b0501b0501b0501b0501b0501b0501b0501d0501d0501d0501d0501d0501d0501d0501d050
010e00001c0401e0401f0402104023040230302302023020230202302021040210301f0401f0301c0401c0301e0401e0301e0201a0401a0301a02017040170301702017020170201702217022170221702217022
010e00001c0401e0401f0402104023040230302302023020230202302021040210301f0401f0301c0401c0301e0401e0301e02026040260302602023040230302302023020230202302223022230222302223022
010e0000240402604028040240402104021030210202102021020210201e0401e0302104021030210202102026040260302602024040240302402023040230302302023020230202302223022230222302223022
010e0000210401f0401e0401b04017040170301702017020170201702017040170301b0401b0301b0201b0201c0401c0301c0201b0401b0301b0201c0401c0301c0201c0201c0201c0221c0221c0221c0221c022
010e0000100401003010020100200b0400b0300b0200b0200b0200b0201204012030120201202012020120200e0400e0300e0200e0200e0200e0200b0200f0401204015040170401504013040120401203012020
010e0000180401803018020180201504015030150201502015020150201204012030120201202012020120200e0400e0300e0200e0200e0200e0200b0200f0401204015040170401504013040120401203012020
010e00001504015030150201502012040120301202012020120201202012020120200f0400f0300f0200f0201004010030100200b0400b0300b02004040040300402004020040200402004022040220402204022
__music__
03 0e424344
01 130f4344
00 14104344
00 15114344
02 16124344
04 17424344
01 18594344
02 18194344
01 1a1e4344
00 1b1e4344
00 1c1f4344
02 1d204344
