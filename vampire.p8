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
	-- if draw_bounding_boxes then
	-- 	rect(self.x,self.y, self.x+self.width-1, self.y+self.height-1,7)
	-- end
	if self.slaves then
		for s in all(self.slaves) do
			s:draw()
		end
	end
end

function actor:set_pal()
	-- local c={5,6,7,15,10}
	local c=string_to_array("567fa")
	for i=1,5 do
		pal(c[i], self.pal[i])
	end
	pal(14,0)
end

function actor:on_ground(fully)
	local a,b=is_solid(self.x, self.y+self.height+1), is_solid(self.x+self.width-1, self.y+self.height+1)
	if fully then return a and b else return a or b end
end

function actor:gravity()
	self.y+=self.grav
	self.grav = min(self.grav,terminal_velocity)
	if self.flying then
		self.grav+=self.grav_acc
		self.grav = mid(-self.max_grav, self.grav, self.max_grav)
	else
		self.grav+=grav_acc
	end
	if not self.ignore_walls then
		if self:is_in_wall() then
			if self.grav>0 then
				local feet_y = self.y+self.height
				feet_y = flr(feet_y/8)*8
				self.y=feet_y-self.height
			else
				self.y = flr(self.y/8)*8+8
			end
			-- self.grav = self.grav * -0.2
			-- if abs(self.grav)<1 then
			-- 	self.grav = 0
			-- end
			self.grav = 0
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

	-- if part == "ceil" then
	-- 	ys = {self.y}
	-- elseif part == "floor" then
	-- 	ys = {self.y+self.height-1}
	-- end

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

function actor:momgrav()
	self:momentum()
	self:gravity()
end

function actor:momentum()
	--accelerate
	self.spd+=self.acc
	--decelerate
	self.spd=move_towards(0, self.spd, self.dcc)
	-- if self.spd>self.max_spd then
	-- 	self.spd=self.max_spd
	-- elseif self.spd<-self.max_spd then
	-- 	self.spd=-self.max_spd
	-- end
	self.spd=mid(-self.max_spd, self.spd, self.max_spd)
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
		x_dif,y_dif=b.x-self.x, b.y-self.y
		for x=max(0,x_dif),min(7,7+x_dif) do
			for y=max(0,y_dif),min(7,7+y_dif) do
				a_pix, b_pix=pget(x,y), pget(8+x-x_dif,y-y_dif)
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
		self.pal = enemy_pal
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
					stair_timer=0, whip_animation=0, whip_cooldown = 0,
					invul = 0, extra_invul=0, always_update = true, depth=-2,
					legs_s=0})

function player:update()
	self.prev_x, self.prev_y = self.x, self.y
	-- if self.invul<=0 and self.extra_invul==0 then
	self.pal = player_pal
	-- end
	--movement inputs
	if self.health<=0 then
		self:death_particle()
	end
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
				if self.health>0 then
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
				end
			-- end
			self:momgrav()
			if abs(self.spd)<0.1 then
				self.animation = 1.9
			end
			if self:on_ground() and btn(2) then
				self:mount_stairs_up()
			elseif self:on_ground() and btn(3) and p_width==0 then
				self:mount_stairs_down()
			end
		else
			self:fly_when_hit()
			self:momgrav()
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
		if self.health>0 then
			if btn(2) and not btn(3) then
				self.stair_timer+=1
				self.f = self.stair_dir
			elseif (btn(3) and not btn(2) or btn(down)) and p_width==0 then
				self.stair_timer-=1
				self.f = not self.stair_dir
			elseif btn(up) then
				self.stair_timer+=1
				self.f = self.stair_dir
			end
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

	if btnp(5) and self.whip_animation == 0 and self.whip_cooldown == 0 and self.health>0 and not between_levels then
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
			self.whip_animation+=0.25
			if self.whip_animation<2 then
				--self.whip_animation+=whip_speed
			end
			if self.whip_animation>=4 then
				self.whip_cooldown = 10
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
		death_time=death_time or 90
		play_music(5)
		self.invis, self.spd, self.acc=true,0,0
	end

	self:update_slaves()
end

function player:checkpoint()
	check_x, check_y, check_stairs, check_f, check_stair_dir, check_s = self.x, self.y, self.stairs, self.f, self.stair_dir, self.s
end

function player:respawn()
	--blackout_time=40
	self.health=player_max_health
	self.x, self.y, self.stairs, self.f, self.stair_dir, self.s = check_x, check_y, check_stairs, check_f, check_stair_dir, check_s
	self.invul, self.invis, self.mom, self.grav, self.invis, cam.special_goal = 0, false, 0, 0, false, false
	-- cam:jump_to()
	-- cam:y_move()
	load_level(current_level, true)
	sort_actors()
	for a in all(actors) do
		a:update()
	end
	level_start=true
	deaths+=1
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
	if self.invul == 0 and self.extra_invul==0 and self.health>0 then
		sfx(12)
		self.health-=1
		self.invul, self.extra_invul=24, 24
		if not self.stairs then
			self.grav, self.acc=-1.5, 0
		end
		if attacker.x>self.x then
			self.spd, self.f=-0.5, false
		else
			self.spd, self.f=0.5, false
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
	if self:on_ground() then
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
		if not self.dontflip then
			if attacker.x>self.x then
				self.spd=-0.5
				self.f = false
			else
				self.spd=0.5
				self.f = true
			end
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
	boss_health,boss_max_health = self.health,self.max_health
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

	self:momgrav()

	if self.invul<=0 then
		if abs(self.spd)<=0 or not (self:on_ground(true) and self.grav>=0) then
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

zombie_legs = enemy:new({animation = 0, enemy=true, extends_hitbox=true})

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

-- running_zombie = zombie:new({s=14, leg_spd = 0.2, base_max_spd=1, health=1})
--
-- function running_zombie:use_pal()
-- 	self.pal = enemy_pal
-- end
--
-- function running_zombie:on_edge()
-- 	if self:on_ground() then
-- 		self.grav=-2
-- 	end
-- end

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

bat = enemy:new({s=26, flying=true, ignore_walls=true, max_grav=1, base_max_spd=1, hurt_sound=10, wing_timer=0})

function bat:init()
	-- self.f=true
	self:use_pal()
end

function bat:update()
	if self:offscreen() then return end
	if self.invul>0 then
		if not self:is_in_wall() then
			self.ignore_walls = false
		end
		self.flying = false
		self:fly_when_hit()
		self:momgrav()
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

				self:momgrav()
				self:hit_player()
				self:animate()
			end
			if distance_between(self.x,self.y,player.x,player.y)<32 then
				self.awake = true
			end
		end
	end
	if self.y<cam.y+4 then
		self.y=cam.y+4
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
		if self.x<=cam.x and self.x>cam.x-8 then
			self.x = cam.x
		end
		self.x=min(self.x,cam.x+120)
	end
	-- self.x=max(self.x,176)
	self:update_slaves()
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

batwing = enemy:new()

function batwing:update()
	self:goto_master()
	self.s, self.pal = self.master.wing_s, self.master.pal
	if self.f then
		self.x+=8
	else
		self.x-=8
	end
end

--------------------------------------------------------------------------------

shooter = enemy:new({s=29, health=3, base_f=true, timer=0, depth=-1, death_sound=11})

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
					local f=fireball:new({x=self.x, y=self.y+3, d=self.f})
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

fireball = actor:new({s=34, spd=1, height=4})

function fireball:update()
	self:animate()
	self:use_pal()
	if self:offscreen() then
		self.dead=true
	end
	if self.d then
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
	self.s, self.f = 84-self.s, self.d
end

--------------------------------------------------------------------------------

axe = fireball:new({s=41, timer=0, pal_type=1, spd=1, anim_dir=1})

-- function axe:update()
-- 	if self.invul<=0 then
-- 		if self:die_when_dead() then
-- 			self:animate()
-- 			self:use_pal()
-- 			if self:offscreen() then
-- 				self.dead = true
-- 			end
-- 			if self.di==nil then
-- 				self.di=self.f
-- 			end
-- 			if self.di then
-- 				self.x-=self.spd
-- 			else
-- 				self.x+=self.spd
-- 			end
-- 			if self:hit_player() then
-- 				self.dead = true
-- 			end
-- 		end
-- 	else
-- 		self:fly_when_hit()
-- 		self:gravity()
-- 	end
-- end

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
	self:use_pal()
end

--------------------------------------------------------------------------------

axe_knight=enemy:new({s=8, height=16, health=5, max_health=5, base_max_spd=0.5, goal=32, throw_timer=0, hand_timer=0, death_sound=11})

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
					self.f,self.acc=true, -0.02
				else
					self.f,self.acc=false, 0.02
				end

				local dist = abs(self.x-player.x)
				if dist<self.goal then
					self.acc*=-1
				end

				if self.hand_timer>0 then
					self.hand_timer-=1
					if self.hand_timer==11 then
						local f=axe:new({x=self.x, y=self.y+3, d=self.f})
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

axe_knight_legs = enemy:new({s=24,timer=0})

function axe_knight_legs:update()
	self:goto_master()
	self.y+=8
	self.f, self.invis, self.pal = self.master.f, self.master.invis, self.master.pal
	self.timer+=abs(self.master.spd)
	if self.timer>4 then
		self.timer,self.s=0,49-self.s
	end
end

--------------------------------------------------------------------------------

axe_knight_hand = enemy:new()

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

medusa = enemy:new({s=13, timer=0, ignore_walls=true, hurt_sound=10, always_update=true})

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
		self:momgrav()
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

slime = enemy:new({s=11, hurt_sound=10, health=3, jiggle=1})

function slime:update()
	if (not self:on_camera()) return
	self.s=11
	if self.invul>0 then
		self:fly_when_hit()
		self:momgrav()
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
			self:momgrav()
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
	slime.update(self)
	if self.x<=cam.x+1 then
		self.x = cam.x+1
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
	self.s, self.pal, self.invis, self.master.dontflip = self.master.s+16, self.master.pal, self.master.invis, true
	self.y+=8
	self:update_slaves()
end

--------------------------------------------------------------------------------

summoner = enemy:new({s=229, health=6, max_health=6, width=16, height=16, timer=0})

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
		self:gravity()
		self.health=0
	else
		self.y=176+sin(p_timer)*3
		if self:die_when_dead() then
			self:hit_player()
		else
			final_boss = demon:new():init()
			add_actor(final_boss)
		end
	end
	self.f=false
	self:update_slaves()
end

--------------------------------------------------------------------------------

demon = enemy:new({s=210, health=9, max_health=9, timer=0, width=16, height=24, x=400, y=128})

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
		if not self.invis and not death_time then
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
	self.y=140+max(-0.5, sin(self.timer))*30
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
		self.x, self.y=move_towards(cam.x+60+sin(timer)*e_rad,self.x,2),move_towards(cam.y+36+cos(timer)*e_rad,self.y,2) --save tokens here (replace cam.x/y with absolute values)
	else
		self.s=55
		self:gravity()
	end
end

--------------------------------------------------------------------------------

platform = actor:new({width=16, height=3, s=48, speed = 0.005, xw=0, yw=0, depth=-5})

function platform:init()
	self.origin_x, self.origin_y, self.position = self.x, self.y, 0
	self:use_slaves()
	self:add_slave(mirror:new())
end

function platform:update()
	self.supporting_player = false
	if player.x>self.x-8 and player.x<self.x+self.width then
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
	if (self.key_rule and player.y>self.y+16) return
	if self.x+8>=player.x then
		cam.x = min(cam.x, self.x-120)
	else
		self:kill()
	end
end

function cam_border_right:kill()
	if self:on_camera() and abs(self.x-player.x)<16 then
		self.dead=true
	end
end

--------------------------------------------------------------------------------

cam_border_left = cam_border_right:new()

function cam_border_left:update()
	if self.x<=player.x then
		cam.x = max(cam.x, self.x)
	else
		self:kill()
	end
end

--------------------------------------------------------------------------------

boss_cam = cam_border_left:new()

function boss_cam:update()
	if player.x>=self.x then
		cam.goal_x,cam.special_goal = self.x, true
		if not level_end and not death_time then
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
			player.health, self.dead = player_max_health, true
			sfx(2)
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

block_bit = actor:new({s=49, life=30, width=4, height=4, dcc=0, ignore_walls=true, always_update=true})

function block_bit:update()
	self:momgrav()
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
		if cam.x>self.x-80 or self.anyway then
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

stone_sealing = heart_crystal:new({s=58, anyway=true})

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
	got_key, got_level_item = true, true
end

--------------------------------------------------------------------------------

next_level_marker=actor:new()

function next_level_marker:update()
	if (not self:on_camera()) return
	self.lv=nl_1
	if self.num2 then
		self.lv=nl_2
	end
	if abs(self.y-player.y)<16 then
		map_markers[progression+2] = levels[self.lv].map_marker
	end
	if self:intersects(player) then
		next_level, level_end = self.lv, true
		progression+=1
	end
end

--------------------------------------------------------------------------------

lock=actor:new()

function lock:update()
	if self:intersects(player) then
		if got_key then
			mset(31,25,0)
			mset(31,26,0)
			sfx(45)
			for a in all(actors) do
				if (a.x<280) a.key_rule=true
			end
		end
		self.dead = true
	end
end

--------------------------------------------------------------------------------

levels =
{
	{data="05820e1i?+??+??+??+??+Hh7wy?+3S?PERSC:2P?:3B?+1S?S?+1xh+1xh+1x:2h?:3AEARCS?+8:2?hy?w7?+2T?+1C?TC?+1AB?S?S?+1xh+1xh+1xh?+1C?+1CT?zQB?+5ywymy?+2zA+1DA+1D:jA?A+1?T?S?+1xh+1xh+1x:jh?ADA+1DAQA+2B?u+2:ju1+30+15lt+7?A+1B?+1T?NXUONONON?t+6NXUOMfvfvj+40J3J+6z?A+2?+42?xzBx?+2J+72JNO?L?L?+20+3?3?+3zA+1?A+2B?+22?+1xA+1xB?+2e?+42?NOM?L?L1+30+3B3zBzA+1:kA?A+3B?2ezAxA+1xA:kB?+1x?+1e?2?NONO?L?Lj+20+6s+5?s+4NONONO1+4?ONONONONONOM8+3?+??+??+??+??+HA+5R?+1PA+4:2A?:3B?+3S?+3S?+1S?:2?+3zA+1QA+dR?+5PA+3?QAB?+1T?+3S?+1T?+1zANO1+cAER?+9PAE?A+1QAQB?+3T?+2z:jAQNONONOj+9?C?+8zB?+1C?1+40+15l1+6NONOh+1NON:gON:2O?+4BC?+1zB?/ef/?zAQABC?Oj+63j+3NONOy/A/?why/z/wNON+5ADBzQAB/uv/zQA+1QA:jD?NONOABzB?3?+1zB/y/h+1y/P/6ywn/P/wMNO+5t+f?ONONOAQA+1B3zQ:nA/O/hywh+1nwhywNON+5J+f?NO?+1NOt+5NONONONONONONONO+5"},
	{next_start_x=4, next_start_y=58, start_x=16, start_y=82, map_string="the path splits here...", nl_1=3, nl_2=4, offset = -58, data="g5820e35/6/+p0+2h+3n?wh+4n?+10+2wh+3n:20+1?+42?+20:20+4:30+1y3?w:3yx/6+5:e6+e:26/0/6/+p0+2hy?+6mh:0hn?+10+2wh+3n0+1?+32?+30+7h73mhx/6/+l0/6+7456/+f0+2y?+46y?+60+2nwhnmh0+1?+22?+40+7yw73mx/6+h456/+10/6+7kl6+5w236+1w236/+10+2y?+2wh+27?+3wy0+2h+27?w0+1?0+4kc0/+e36+1w236+b:fkl6/+10/1236+1w236+1w236+1wMij01Mij01/0+4k40+45l0+6wnwh7m0?+2;1?+320/+fj01Mij0136+1w236+1w23w23/0/hij01Mij01Mij01M/?/+2gh/?/+2gh/?x?+226h0+2h73?+1mn0+2wy?mn?0?+52?0+f?/gh/?/+2ghj01Mij01MijMij/0?/+2gh/?/+2gh/?/+2gh/?+bx?+126;0hn0+2yw73?+1hn0wh+1y?+2:90?+42?+10+8h0m0+3?/+8gh/?/+2gh/?+50?+qx?2?wy60+2h+273?mhxwnwn?w7:90?+32?+20+8ny?0y0+1?+f:d?+50?+p0+4k40+5wh73?mx;0mh+1n?0+i?mhn0w0+1?+l0?+86e?+fxhy?260+5ywh73?x?wn?+10+i7?n?ym0+1?+7e?+bw0B?+2zB?+2wx?+3zA0+4?+3zx:0n?26h0+71+20+110+151+30+110+21+20+6y?+1ym70+1?+16hye?+1xwy?+6e?wh0AB?zAxy6yhx?+2zA+1x?+2xAB?zAxy26ym0+7j+20xj0j+13j+60j+40+5h76h7m0+1?ewh+1x?+1xh+2e?+4xh+201+3NONONONO1+4x?+2x1+f0+2?+20x?0+1?+13?+c0+41+50+11+1k40+11+1010+21+40+110+1j+gx?+2xj+e0+3?+10+1x0+2?+23?+b0+4j+50+1j+12j+i0/6:36/0+1hyx?+3xwh0+1:2/6/+10+u:30+1?+13?+6PA+1QA+2QA+1R?+62?0:20/+i6/+10+1hyx?+3xwh0/+16/+10+wB?+13?+6QA+2QA+1RS?+62?+1:80/+j6/+10+1mhx?+3x7m0/+16/+10+wAB?+13?+5PA+4R?S?+52?+2:90/+j6/+10+17mx?+3xh70/+16/+10+x5l0+2?+5SAQRS;1?+1T?+42?+3:90/+j6/+10+1hyx?:7?+2xyh0/+16w/0+w?+13?+8TPR?S?+40/+r36/0+1h+1x?+3xw:hn0/+11M/0+wB;0?+13?+bS?+50/+qj0/0+1ywx?+3xn60/+1h/?0+wA+1B?3?+aT?+60+1?x?+1x?/+jg/0+1y?x?+3x6y0+1?+10+D?+g0+1?x?+1x?+k0+1hyx?+3xhn0+1?+10+w?x?x?x?+c:4?+40+1?x?+1x?+k0+1hyx?+2:c?xw70+1?+10+wBx?xBx?+h0+1?x?+1x?+j0+2y+1x?+3xwh0+2?0+wAxzx:0AxB?+6:0?+8z0+1?x?+1x?+j0+2k40+55l0+2?0+wAxAxAxAB?zB?+2zB?+1;a?+2zA+10+1?x?+1x?+i0+1?+12?+2mhnmn3mh0+y1+a?+11+2?+11+50+1?x?+1x?+i0+1?2?+36n6nwn3w0+m8+mo+18+2o+18+v"},
	{next_start_x=4, next_start_y=194, start_x=16, start_y=82, map_string="the path continues...", nl_1=5, map_marker={60,13}, data="11d2062iA+5B?+1PA+kR?PA:iA+aE:2A0:3A+f:eR?PA+b:2A0A+6B?+1PA+bRPA+3RS?+3PA+7R?C?0A+bEAR?+3A+c0A+7B?+1PA+9R?+1PER?+1S?+4SPA+3R?+2C?0A+2R?PAEAR?+1C?+5PA+b0A+7R?+3PA+6R?+3C?+2T?+4T?+1PER?+3C?0AR?+4C?+3C?+7PA+5:fA+30PA+5R?+5PA+4R?+4C?+cC?+4C?0?+6C?:5?+2C?+8A+90?+1PAEAR?+4e?+2PER?+6C?ey?+9C?+4C?0?+6C?+3C?+1NONONO?PA+80?+3C?+5wx?+3C?+5zBCzxh7?+3zAB?+1C?+4C?0?+6C?+3C?+1:8MNO?+1x?+1P+1EARSPAE0?+3C?+4whxy?+2C?+3zA+2DAxh+1y?zA+4BC?+3zDA0?+1:4?+3:0?C?+2zDB?:9NOM?+1x?+3C?+1S?+1C0?+3C?+4h+1xy?+2C?+1zA+4NONONOt+2NONOADB?zA+30?+5zDB?zA+2B:9MNO?+1x?+3C?+1T?+1C0AB?+1C?+36h+1xh7?zDA+7MNOJ+6NOMA+80?+4NOt+105lt+2NOMB?x?+3C?+4C0A+2BCzB?+1NONOt+cNO?+8NOt+20k40t+2?+4MNOJ+23J+2?NOABx?+3:cC?+2zAD0A+3DA+3MNOJ+dM?+aMJ+32J+4?+4NO?+43?+3MA+1xABzADA+50t+8NO?+u2?+aM?+63?+1NOt+eJ+8M?+u2?+5o+5NO?+63?+1MJ+e?+2PA+7R?+2S?+1S?+1S?+2S?+1whyw:30?+52?+7PA+8R?+33?+5;i?+fPA+4R?+3S?+1T?+1S?+2S?+1mhnw0?+42?+9SPA+4RS?+53?+fy?+4A+3R?+4S?+4S?+2T?+2whn:90?+32?+aS?+1PA+1R?S?+63?+1;0?+cy?e?+2PAR;1?+2:g?e?+1T?+4S?+6my?:90?+22?+bS?+2S?+2S?+73?+dhyx?+3;1?+4wx?+7T?+60+e?+4T?+2T?+2T?+60+4?+ah+1x?+8wxy?+gx?x?+5x?x?+e:0?+7x?x?+bh+1xh7?+5whxy?+fzxBx?+5x?x?+i:6?+3x?x?+bh+1xh+1y?+36h+1xhy?+czA+1xAxB?+4x?x?+c0+4?+4x?x?+bNONOt+7NONO?+aNONOt+4NONO?x?x?0+2?+5:4?+3x?x?+5x?x?+bMNOJ+9NOMy?+2:5?+5wMNOJ+6NOMBx?x?x?x?+2zB?+4x?x?+5x?x?+bNO?+bNOhy?+66hNO?+8NOAxBx?x:0?x?+1zA+2B?:0?+1x?x?+5x?x?+bM?+dMhy?+6h+1M?+aM;bAxAxBx?x?zA+4B?+1x?x?+5x?x?+bNO?+bNOh+17?+46h+1NO?+8NOt+lNO?+2x?x?+bM?+dMh+2y?+2wh+2M?+aMJ+mMo+h"},
	{next_start_x=140, next_start_y=90, start_x=16, start_y=194, map_string="great ruins border the path...", nl_1=8, nl_2=6, offset = 50, map_marker={49,27}, data="82940a2jB?3?+7S?+1S?+2S?+43?+5S?+4S?+cS?+1S?+1S?+2S?+3:e?+3S?+7S?+10A?+13?+6T?+1S?+2S?+53?+4S?+4T?+cT?+1S?+1S?+2S?+7S?+7S?+10AB?+13?+8S?+2T?+63?+3T?+lS?+1S?+2T?+7S?+7S?+10s+6NO?+4T?+b3;lKu?+e:l?Ku+2?+3S?+1T?+bT?+6:f?S?+10I+5NOMB?+efvfvf?+4:5?+9fvfvf?+3T?+nT?+10?+6NOAB?+1u;lu+2?+8L?L?+gL?L?+w0?+6s+3NOf+1vf?+8L?L?+gL?L?+5zB?+o0?+3NO?I+2NOM?+1L?+9L?L?+c:4?+3L?L?+4:0zA+1B?:0?+m0?+aNO?+1L?+9L?L?+7:0?+8L?L?+3zA+5B?:8?+j0?+5NO?+3M?+1L?+1:4?+7L?L?+6Ku+3?+4L?L?+1NONOs+3NON:9O?+e:m?+30?+aNO?+1L?+4:l?+4L?:5L?+4fvf+2vf?+4L?L?+1MNOI+5NOM?NO?+f0?+1NO?+7M?+1L?+4Ku+2?L?L?+5L?+2L?+5L?L?+1NO?+7NO?M+1?NONOs+5NONO?0?+aNO?+1L?+3fvfvf?L?L?+5L?+2L?+5L?L?+1M?+9M?NO?MNOI+7NOM?0?+bMo+BNO?+7NOoM+1oNO?+9NOo0/6+S:26/0+3:3/6+k:26/0/6+7456/+J0/+36/+l0/6+1w236+2kl6+aw236/+v0/+36+c456/+60/01Mij0136+1w236+1w23w01Mij0136+1w236+1w23w236+7w236/+40/+36+ckl6/+60/gh/?/+2ghj01Mij01MijMgh/?/+2ghj01Mij01MijMij0136w201Mij0136/+10/+36w23w236+7w236/+30?/+7gh/?/+2gh/?/+bgh/?/+2gh/?/+5ghj1Migh/?/+2ghj01/0/+31MijMij0136w201Mij0136/0?/+Gh/?/+9gh/0/+3h/?/+5ghj1Migh/?/+2ghj1/0?+T0+3?/+9h/?/+9h/0AB?+R0+3?+e:g?+60A+3B?+hw7?+1wy?+mzAB?0+3?+4e?+f0A+4B?+d:0?+1why?6:lh+17?+b:0?+7zQA+2B0+3?+4xy:0?+6:0?+1e?+40A+6B?u+a?+1hNO?hNOy?+1u+3?+1u+6?+2zQA+3:lQA0+3?+4xh7?;l?+5wx?+40s+8f+1vf+1vf+1vf+1s+1NONONOs+3f+1vf?+1f+1vf+1vf?+1s+1050+2s+5?+3s+30+350s+3?+30I+8o+aI+bo+eI+33I+7o+3I+83I+3o+30"},
	{next_start_x=276, next_start_y=58, start_x=16, start_y=82, map_string="the castle is ahead.", nl_1=7, offset = -24, map_marker={69,22}, data="12940a2dA+tR?+23?+4:2MNO?+6mh+1yh:2NONOM?+32?+1PA+6:2ANA+bRS?PA+bRS?+43?+3NOM?+8w7wN+1:3ONO?+22?+3SPA+5NPA+9R?S?+1SPA+8R?S?+53?+2MNO?+7:g?+1myNONO;b?+22?+4S?SPEA+2N?SPA+6R?+1S?+1S?SPA+1EA+2R?+1S?+63?+1NOM?+awMNONONONONONOS?S?CPA+1N?S?+1PAEARS?+2S?+1T?S?;1?SC?;1?S?+2S?+2;l?+3NONONO?+1NONONO;b?+3NONONO?+4x?S?T?C:1?SPN?T?+3C?+1S?+2S?+3T?+1TC?+1S?+2T?+1NOUZNONONOM?+2NONONO?+2MNONO?+5x?S?+2C?S?N?+5C?+1S?+2T?+7C?+1S?+62wNONONONO?+3x:1?+2NOUZNONO?+6x?T?+2C?T?N?+5C?+1S?+4zA+1B?+2C?+1T?+52?6h+2NONO?+4x?+32?NONO?+7x?+4C?+2N?zAB?+1C?+1T?zB?zA+5BC?+72?wh+2ywNO?+5x?+22?NONONO?+6x?+4C?+2NzA+2B?C?+1zA+4QA+5DAB?+4NONOywh+2n:9M?+5x?+12?NONO6hNO?+5x?+1zA+1DABN+1A+1QA+2DA+3QA+4NONOA:lA+2B?+4NONOh+3y:9M?67?+2x?2?+2NO7wNONO?+3:0?x?zA+2NONONA+fNONONONOA+1B?NONONONOywyNOh+2y?+1x2?e?+2NOmhNO?+3zAxA+3NONON+1t+X040+1t+bNJ+X2J+eN/6+M:26/N:3ONOh+1n?+12:e?+3PA+aN/6/+NN+1OMhn?+12?+5PA+6QA+1N/6+4456+gw236+aw236+1w236+1w2/NONOy?+12?+7SPA+6QN/6+4kl6+5w236+1w236+1wMij36+1w236+3wMij01Mij01Mi/N+1OMn?2?+8S?+1S?+1:fPA+2N/6+1w236+1w236+1wMij01Mij01M/?/+2j01Mij0101M/?/+2gh/?/+2gh/?+1NONONONONO?+5T?+1S?+5N/01Mij01Mij01M/?/+2gh/?/+2gh/?/+4gh/?/+2ghgh/?+cN+1ONONONOM?+8S?+5N/gh/?/+2gh/?/+2gh/?+BNONONONONONONO?+4S?+1NONON?+n:l?+e;i?+a0?+3NONONO?x?+5T?+2x?N+1?+mNO?+5:0?+hz0?+4NONO?+1x?+9x?ANAB?+e:l?NONONONO?+kzA+10?+5NOMB?x?+2e?+4:m?xzANA+2B?+8;0?+3NONONONONONONONO?+7:l?+4zA+20?+6NOABx?+2x?+4zxA+1NA+4B?+9NONONONONO?+1NONONOt+7k40+1A+30?+5NOMA+1xAB?x?+1e?zAxA+1NA+50+15lt+5MNO?+3NONO?+1NO?+1NOJ+62J+1zA+30?+6NOt+fNA+5BJ+13J+5NO?+fNO?+42?+1zA+40?+7MJ+fN"},
	{next_start_x=140, next_start_y=170, start_x=16, start_y=66, map_string="the castle is ahead.", nl_1=7, offset = -16, map_marker={62,32}, data="11d2062m/6/+p0+1?+8wh+10+3h+4n?+13?+20+3h+2n?+32?+20+1?mh0/+16+9w236+1w236+4456+1w236+1w/0+1?w7h7?+3wh+10:2?+10h+3n?+33?+10+3hn?+42?+3:90:90?+1w0/+16+8wMij01Mij36+3kl6wMij01M/0+1?mh+3y?+2wh0?+10h+1n?+2mh0+4?+10n?+42?+5:90?+1m0/+16+601M/?/+2gh/?/+2j36+4wM/?/+2gh/?+4whywhy?+2w0+3n?+5wh+30?+10?+10+b7?+10/+16+6gh/?/+9j01201M/?+bmh+37?+1w0+3;b?+7wh+20+1?0?+36h+4n?0+1y?+10/+101:22/+4?/+cghigh/?+7:0?+2w7?+2mh+1y?w0+7y?+3wh+10+3?+2wnwhn?+30+1y?+10/+1ghi/+4?+2e?+n6hy?+3why?+10+3:1wh+2n?+5m0+3?6hn6hn?+1:c?+20+1y?+10+1?+6B?+1x?+4e?+b0+1kc0+7?+1h+1y?0?0+1h+1n?+7;a?0:2?0+1hywywn?+50:20y?+10+8AB?x?+4x?+d2?0+4?x?+16hy?+10?+10hy?+4w0+4?0+ak40+2y?+10+8A+2xB?+2zx?+7e?+32?z0+2?+2x?6nwye?0?+10n?+5whywy0+3h+3n?+326h0+1y?6h:8h+10+51+40?zAxB?+2e?+1zxB?+12?+1A0+1?+1wyx?wewyx?0+1:3?0;b?+7wh+1y0+1:3?0h+1n?+42?wy:90wh7wy:90w0+5j+41+50?+1x?zAxAB2?ezA0+1?e6yxwyxwyx?0+450+1?+17?+1ywh0+1?0hn?+426h+27:90h+50+5?+4j+51+e0+9k40+5h73?+2wy6h7w0+55l0+l?+aj+e0+1wh+2n?+226h+10+3yw73?+1wh+1ywh0+3?x?3?+5x?0+Fwh+1n?+226ywh0?0+1ywh73?+1whywh0+3?x?+13?+3:e0/+46/+a0h7wh+5ywh+2y?+3mh+1ywh+10+1mhy?+226hnwn0?0+1hy?h73?+1wywh0+3?x?+23?+10/+56+6456/+10wywh+2y?mh+2n?+bmn:90?wy?+126h+2n?0?0+1y?+1my?3?wh7:aw0+3?x?+33?0+1?/j/x/6+7kl6/+10h+17whn?+2:gwn?+e:90:90?why26ywn?+1:a?0+1:3?0y?+20+8:2?0+3k40+4?+2x/36+3w23:f6+1w2/0wh+1y?+6:5?+40+2?+30+dk40+2?0y?+3wh7?mh+10?0+1n?2?+2x?+4x/j36+1wMij01Mi/0h+1n?+l0?0h+2n?+426h0+3y?+167why?+1wh0?0+1?2?+3x?+4x?/j01M/?/+2gh/?+10y?+n0?0hy?+52?mh0:2?0+1y:4?+1wywywy?+1w0+6?+2x?+4x?/+1h/+1?+70n?+i:4?+3w0+2y?+2:0?+22?+2w0?0+1y?+1mh+10+1y?+1w0+6?+2x?+4x?+5:d?+50?+10+5?+e6h0+2hn?+32?+3w0+3y?+2wh0+1y?+1h0?:3?x?0+1B?+1x?+4x?+b0?+2x?+1x?+3:0?+awh+10:3?0y?05l0+4?h0+3h7?6h0+2y:6?+1h0?+1x?0+1A?+1x?+1e?+1x?+b0?+2x?+1x?+dwhyw0?0y?+23?+5m0?0+9y?+1w0+1?x?0+1AB?x?+1xzBx?zB?+6zA0?+2x?+1x?+20+2?+10+a?0n?+33?+1wy?+10?x?+1x?+1x?0+1y?+1w0+1?x?0+1A+1BxzAxA+1xA+3B?+2zA+20?+2x?+1x?+3x?+3x?x?x?x?+10+2?w7?+23?my?+10?x?+1x?+1x?0+1n?6h0?+1x?0+11+m?+2x?+1x?+3x?+3x?x?x?x?+10+26h+1y?+23?m7?0+bk40+3?x?0+1j+m"},
	{start_x=16, start_y=50, offset = -28, map_marker={84,22}, data="g5820e40/6+iw20/MNOMhn?26h+2ywM:2NONONONONO?+1NONONO?+h2?+fNONO?+5NONONONOhywh+2NONONO:2N/+76+a456+4wMih/NONOn?26nhnwyhN:3ONONO?+1NONONO?+1NO?+h2?+gMNONO?+5NONONOmhyh+1n?+1NONONO/+736+1w236+1w23kl6+3wM/?+3NOM?26nwy?mywMNONO?+5;1?+5;1?+h2?+hNONO?+7NONO?+1wh+1y?+2;1hNONON/+7j01Mij01Mij36+1w01M/?+5NONOYVWO?+1whNOMy?+rYVWO?+6NONOYVWONONONONO?+5NONONO?+1mn?+3whNONO+7?/gh/?/+2gh/?/+2j01Mih/?+7xh+273?+2h+1MNOy?+rx73?+6wM:2NOMh73?+2h+2NONO?+3NONONO?+9mhNON+7?/+bgh/?+axh+1nw73?+1:gmhNOMy?+rxh73?+46hNONOwh73?+1wh:0h+1NONO?+1NONOh;1n?+bwMNO+7?+oxhy?+1m73?+1hMNOhy?+p6xh+1e3?6ywywMNOM?wh73?+1mh+2NONONONOhy?+bNONON+7u+e?+9xh+1:d7?+1h73?mNOMwhy?+ohxywNONONXUZNONONONONXUZNONONONONOhn?+dNONO+7fvf+4vf+4vfNONONO?+3xywhyewh73?MNOw;0ywy?+d:7?+86hxywxywhn26NONONOwhn?2?+3mh+1y;1?+96NOYVWONONONON+7?L?+4L?+4L?+1NONOM?+3xh7wyxwNONONOMy+1why?+5:7?+fwhx7wxyhn26ywNONOywy?2?+5why?+9hMNOy3?+1wh+1MNO+7?L?+4L?+2e?L?+1x?+1NO?+3xhywhxhMNONONONONXUZ?+j6h+1xywxhy26hywMNOMyhn2?+7h+1y?+76hNOyw73?+1h+1NON+7?L?+1e?+1L?+2x?L?+1x?NOM1+aNONONONOn?26hy?+gNONONONONONONONONONONONONO?:b?+4wy+1?+6h+2MNOyw73?wh+1NO+7?L?+1x?+1Le?+1x?L?+1x?+1NOj+aMNONONOn?26ywhywy?+2why?+2wymhyMNONONONONONONONONONONONONONONONONO?:b?+46h+2NOywh+173?mh+1N+78+vNONONO?+126hywhywhy?whywhymh+17whNONONONONONONONONONONONONONONONONONONONONONONONOywh+173?mh+8OMh+2n?+owh+1y+1?+226M:2N/6+?6/+3NONOh73?+1mh+1ywNO:2N+1Ohn?+rmymy+1?26yNO/6+c45:26/0/6/+PN;iONOh73?+1wywhMNO+1My?+ty?wy26y+1MN:3/36+1w236+6kl6/0:3/36+1w236+5w36+1w236+pw236+3w/NONOh73?+1m7mhMN+1Oy?+tYVWONONONO/j01Mij36+1w0136+1w/0/j01Mij36+1w01Mj01Mij36+1w0136+1w236+5w236+3wMij36+1wMi/NONOh73?+1wywNO+1My?+v3?mhyNON?/gh/?/+2j01Mihj01M/0?/gh/?/+2j01Mih/?/+1gh/?/+2j01Mihj01Mij36+1w01Mij36+1wM/?/+2j01M/?NONONOh73?+1myMN+1Oy?+v73?w:0ywNO?/+6gh/?/+3gh/?0?/+6gh/?/+agh/?/+3gh/?/+2j01Mgh/?/+2j01M/?/+4gh/?+4NONONONXUZNO+1Mhy?+s;a?wh73mhyMN?+f0?/+vgh/?/+6gh/?+bNONOh+1n?26NON+1Oh+1y?+9:7?+hYVWONONONO?+f0?+TNONOn?26hMNO+1NONONXUZNO?+n3mhywNON?+f0B?+Txhy?26h+1NONywywn?26NOM?+mh73mh;0hyNO?+f0A+1B?+Rxn?26h+1NONOywhy?26hMNO?+b:7?+9wh+173mywMN9a?+39:oa9a?+39a0A+5B?+1zB?+czB?+bzB?+gx?26h+1NONONnhn?2?ywNOM?+4ywy?+dwywhNONONOa9a9a9a9a9a9a9a91+aNO?+3:5?+50+4?+3:5?+50+4?+3:5?+5NO1+dy+1?2?wywMNOywy6h+2ywhy?+66yhNONONONONON+1ONXUZNONONONONOj+bM?+9x?+2x?+9x?+2x?+9Mj+ehn26hy?wNOMhywh+1ywh7wh+2y?wywhywMNONONONONO?NX26h+7NO?o+?o+4"},
	{next_start_x=276, next_start_y=90, start_x=16, start_y=192, offset = 41, map_marker={69,22}, nl_1=7, map_string="the castle is ahead.", data="81d50c31ONO?+13?+3NONONONONONONONONONONONONONONONONONONO?+23?+3NONONONONO?:e?+fN+eO:8M?+23?+7PA+2NONONONOA+6R?+g3?+tO+eN:9O?+33?+7SPA+1NONONOA+3RS?S?+i3?+6:g?+lN+eO:9M?+43?+6S?PA+1NONOA+2R?+1S?T?+j3?+n:f?+3O+eNONONONONONO?+2T?+1SPMNOMARS?+2S?+m3?+qN+eONONONONONO?+6S?NONOS?S?+2T?+iNONONONONONO?+jO+eNONONONONO?+7T?+1NO?T?S?+ox?S?+1S?x?+lN+d?wh+1NONONO?+gT?+7:0?+gx?S?+1T?x?+lO+d?+1mh+1NONOM?+Gx?T?+3x?+h:m?+3N+d?+2wh+1NONO?+c:0?+6NXUZNONO?+ex?+5x?+lO+d?+3mNONOM?+6:0?+4;l?+82?NONOM?+2NONO?+7x?+5x?+7NONONONONONONO+e?+5NONO?+aNONO?+3:l?2?+2NONO?+2MNOM?+2NONO?x?+5x?NONO?+2MNONONONONONON+e?+6NONONONONONO?+1x?+1x?+1NONO?+2MNOM?+2NONO?+2MNOM?x?NONO?x?MNOM?+2NONONONONONONO+eo+?o+wONOywh+2y?+5S?S?+1SPA+aR?+Y:2N?NOMy?wh+27?+4T?S?+1S?PA+7RS?+ZM?ONOywhnwywy?+5S?+1T?+1S?+1PA+1RS?S?+O:i?+aN?NOMh7wywh+1y?+5T?+4S?+2S?+1T?S?+ZM?ONOhywh7mh+17?+4:0?+5T?+2S?+3T?+ZN?NONOh7wy+2wy?:l?+dT?+??+2M?ONONOYVWONONONONONO?+??+bN?h+1ywhy?3?wywNONONO?+??+cM?ywhywh7?3?myMNONO?+x:0?+HN?nwhy6h+1y?3?wNONO?+hzB?+bzAB?+kNO?+2:4?+4NO?+aM?6hywh+37?3mMNOM?+gzANO?+9zANONO?+e;0?+2NOM?+7MNO?+9N?why?wywhNONONONO?+5zB?:l?+6;lzANOM?+7zA:lA+1MNONO?+fNONO?+7NONO?+6:0?+1M?ONONONONONONONOM?+4NONONO?+1NONONONO?+3NOYVWONONONONONO?+3:5?+5NONONOM?+7MNONONO?+5N?NONONONONONONONOo+4MNONOMo+1MNONONOMo+3MNO?3?+1NONONONOMo+9MNONONOo+7NONONONOYVWONO?"}
}

function _init()
	--almost all of the properties can be shoved in one long list. tokens!

	--hard_mode = false

	hurt_pal, player_pal =string_to_array("2987a"),string_to_array("1d2f")

	--player.y=82
	player:use_slaves()
	player:add_slave(player_legs)
	--player:use_pal()
	--player:update_slaves()
	--player_sword:use_slaves()
	--player:add_slave(player_sword)
	--player_sword:add_slave(player_sword_tip)

	player.whip = whip:new()
	player:add_slave(player.whip)
	player.whip:setup(10)

	--next_start_x, next_start_y = 4, 58

	terminal_velocity, grav_acc, player_jump_height, player.health, player_max_health, health_timer, boss_health, boss_max_health = 4, 0.15, 2.5, 6, 6, 0, 0,0
	--boss_max_health = 6

	--draw_bounding_boxes = false
	got_stones, e_timer, e_stones, e_rad, blackout_time, darker_pal, darkness = 0, 0, {}, 20,  0, string_to_array("001121562493d52e"), 0
	--old darkness: "000520562493152e"
	level_start_timer, level_end_timer, level_start, difficulty_menu, progression, between_levels, p_width, p_timer,map_markers, deaths,minutes, seconds = 0, -20, true, true, 0, false, 0,0, {{38,17}}, 0,0,0

	player:update()
end

function string_to_array(s)
	a = {}
	for i=1,#s+1 do
		add(a, char_to_int(char_at(s,i)))
	end
	return a
end

function clear_level()
	actors = {player, cam}
	for i=0,127 do
		for j=0,27 do
			mset(i,j,0)
		end
	end
end

entity_dict = {zombie, bat, cam_border_right, cam_border_left, platform:new({yw=24}), platform:new({xw=24}), platform:new({yw=-24}), pendulum, chicken, breakable_block, shooter, shooter:new({base_f=false}), axe_knight, batboss, boss_cam, heart_crystal, stone_sealing, key, medusa_spawner, next_level_marker, next_level_marker:new({num2=true}), slime, slimeboss, lock, summoner}

function load_level(level, respawning)
	cls()
	clear_level()
	--do i need these?
	-- centre_print("loading...", 61, 7)
	-- centre_print("level "..level, 55, 7)
	between_levels, p_width = level==1, 0
	if level==6 then
		back_entry=true
	end
	current_level = level
	level = levels[level]
	s = level.data
	-- there's a way of doing default value using 'x or nil', or something.
	-- if level.start_x then
	-- 	start_x, start_y = level.start_x, level.start_y
	-- else
	-- 	start_x, start_y = next_start_x, next_start_y
	-- end
	start_x, start_y = level.start_x or next_start_x, level.start_y or next_start_y
	next_start_x, next_start_y = level.next_start_x or next_start_x, level.next_start_y or next_start_y
	-- if level.next_start_x then
	-- 	next_start_x, next_start_y = level.next_start_x, level.next_start_y
	-- end
	next_level = level.next_level or 1
	-- if level.next_level then
	-- 	next_level = level.next_level
	-- else
	-- 	next_level = 1
	-- end
	-- if level.nl_1 then
	nl_1, nl_2 = level.nl_1 or nl_1, level.nl_2 or nl_2
	-- end
	-- if level.offset then
		level_offset = level.offset or 0
	-- end

	if current_level==7 and back_entry then
		start_x, start_y=540, 186
	end

	if not respawning then
		player.x, player.y, player.acc, player.spd, player.grav, player.f = start_x, start_y, 0, 0, 0, false
		player:checkpoint()
		cam.special_goal = false
		player:update_slaves()
	end

	cam:jump_to()
	cam:y_move()
	cam:update()
	if between_levels then
		cam.x=flr(player.x/136)*136
	end

	if (level.map_string) map_string = level.map_string
	enemy_pal, width, cursor, x, y, chain, add_val = string_to_array(sub(s,2,6)), two_char_to_int(sub(s,7,8)), 9, 0, 0, 0, 64
	while cursor<#s or chain!=0 do
		if chain<=0 then
			char=sub(s,cursor,cursor)
			if char=="/" then
				add_val=192-add_val
			elseif char==":" or char==";" then
				num=sub(s,cursor+1,cursor+1)
				if char==":" or hard_mode then
					entity = entity_dict[char_to_int(num)+1]:new():level_up()
					entity.x,entity.y=x*8, y*8
					entity:init()
					add_actor(entity)
				end
				cursor+=1
			elseif char=="+" then
				num=sub(s,cursor+1,cursor+1)
				chain=char_to_int(num)
				cursor+=1
			else
				prev_val = char_to_int(char)+add_val
				mset(x,y,prev_val)
				x+=1
			end
			cursor+=1
		else
			mset(x,y,prev_val)
			chain-=1
			x+=1
		end
		if x>=width then
			x=0
			y+=1
		end
	end

	level_music = char_to_int(sub(s,1,1))
	if between_levels then
		play_music(level_music)
	else
		play_music(-1)
	end

	-- local s=summoner:new({x=56, y=80})
	-- s:init()
	-- add_actor(s)
end

function char_to_int(c)
	for i=0,63 do
		if char_at("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!?",i+1) == c then
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
	if (not level_end) map_markers[progression+2]=nil
	p_timer=(p_timer+0.01)%1

	if death_time then
		death_time-=1
		if death_time<=0 then
			death_time=nil
			player:respawn()
		end
	end

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
			load_level(2) --start in first level
			sfx(3)
			darkness=5
		end
		return
	end
	if not game_end then
		seconds+=1/60
		if seconds>=60 then
			minutes+=1
			seconds=0
		end
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
			if not game_end then
				load_level(next_level)
			else
				map_string="you couldn't stop the demon"
				if (good_end) map_string="the end"
			end
		end
		darkness=level_end_timer/5
		if (not ending_sequence) return
	elseif game_end then
		darkness-=0.1
		return
	end
	if level_start then
		if level_start_timer<=20 then
		 	level_start_timer+=1
			darkness=5-level_start_timer/5
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
			p_width-=0.25 --might want to half this and the following
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
			level_end, game_end=true,true
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
	local xd, yd = abs(x1-x2), abs(y1-y2)
	return sqrt(xd*xd + yd*yd)
end

--------------------------------------------------------------------------------

function _draw()
	if darkness!=0 and prev_darkness==darkness and not game_end then return end
	prev_darkness=darkness
	cls()
	if game_end and not level_end then
		draw_level_select_gui()
		centre_print("deaths: "..deaths, 72,7)
		local extra=""
		if seconds<10 then
			extra="0"
		end
		centre_print("time: "..minutes..":"..extra..flr(seconds), 82,7)
	else
		if blackout_time<=0 then
			cam:set_position()
			map(0,0,0,0,128,32)

			if (difficulty_menu) draw_basic_menu() return
			draw_portal()
			for a in all(actors) do
				a:draw()
			end
			player:draw()
			map(0,0,0,0,128,32,0b1000)
			camera()
			clip()
		end

		if between_levels then
			draw_level_select_gui()
		else
			draw_hud()
		end
	end

	for i=1,darkness do
		darker()
	end
end

function draw_portal()
	if (p_width<=0) return
	camera()
	local w = p_width-3*sin(p_timer)
	circfill(63,36,w+1,1)
	circfill(63,36,w,0)
	-- rectfill(63-p_width,0,64+p_width,95,0)
	-- for i=0,16 do
	-- 	for j=0,95 do
	-- 		if sin(p_timer+j/128)*8+8>i then
	-- 			pset(i+p_width+64,j,0)
	-- 			pset(63-p_width-i,95-j,0)
	-- 		end
	-- 	end
	-- end
	cam:set_position()
end

function draw_hud()
	line(0,112,127,112,5)
	print("player", 1, 114, 7)
	print("enemy", 108, 114)
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

function draw_basic_menu()
	clip()
	centre_print("normal",72,7)
	centre_print("hard",82,7)
	local xd, yd=0,0
	if (hard_mode) xd=4 yd=10
	spr(180,40+xd,72+yd)
	spr(181,79-xd,72+yd)
	-- print("mush101.itch.io", 68,122,5)
	centre_print("mush101.itch.io", 118,5)
end

function draw_level_select_gui()
	--draw border
	local cols = {0,8,0}
	if not game_end then
		for i = 1,3 do
			rect(i-1,63+i,128-i,128-i,cols[i])
		end
	end
	--draw map
	rectfill(0,0,127,63,0)
	sspr(56,96,64,32,32,8)
	--string
	centre_print(map_string,50,7)
	local p_m,num=nil,-1
	for m in all(map_markers) do
		m1,m2=m[1],m[2]
		if p_m and (num<progression or p_timer%0.2<0.1) then
			-- p1,p2=p_m[1],p_m[2]
			-- for i=0,1,0.2 do
			-- 	pset(p1+i*(m1-p1),p2+i*(m2-p2))
			-- end
			line(m1,m2,p_m[1],p_m[2])
		end
		num+=1
		--circfill(m1,m2,2,0)
		circfill(m1,m2,1,8)
		p_m=m
	end
end

function centre_print(str, y, col)
	print(str,64-2*#str,y,col)
end

function darker()
	for i= 0x6000, 0x7fff do
		local two = peek(i)
		local second = two % 16
		local first = lshr(two - second, 4) % 16

		first, second = darker_pal[first+1], darker_pal[second+1]

		poke(i, shl(first,4) + second)
	end
end

__gfx__
0000660600006606000066060006606000ff660600006606000066060000000000aaaa00000000000000000000000000000770000066a0000000770000005505
0006666000066660000666600066660000ff66600006666000066660000000000aaaaaa0000770000000000000000000007aa7000666aa000007777000055550
0066fff00066fff000666ff0066fff0000f6fff00066fff00066fff0000000000aaaaaa000766700000000000077770007aaaa70666aa6a07707777000057770
0066fff00066fff000666ff0ff6fff0000f6fff00066fff00066fff0000000000aaaeee0007a67000777700007aaaa7007aaaa70666aa7aa7705777000557770
067766700677667006666660ff76670006f7667006776ff0067766700000000076aaaea007aa700000aaa7007aaaaaa707aaaa70666aaaa00766557000665570
6f77777f06f77770066677700f77770006777770067ff770067f777000000000776aaea700a7700000aaa67076aaaa67076aa6707666aa000076660000666600
6ff7777f06fff7700667fff00777770006777770067777700677ffff000000007777777700a7000000776670766666670766667007766aa00066660000667777
0ff55500005ff50000555ff0055555000055550000555550005555ff000000007a7a7aaa00700000000077000777777000777700007770000066660000666657
00555500005555000055550006775500007555500000000000555000004440007a777a667a777a66060550600006000600060006006666000066660000677600
00755700000775000077566066677550567756600000000005677500049aa4007aaa7aa67aaa7aa6060550600050555500005555065555500067760000777700
0677077000077700007776606600775056600660000000005666675049999a4007aa7aa607aa7aa6655555560560565600055656655575550007770007770770
6660066000066000066705555550077050000555000000005666665049999940077777a6077777a6655555565666555500566555555577550007600066600760
56000660000660000660000000000670000000000000000056666650499999400a67a7a60aa677a6656556565666555000566556555555500006700067000670
0550055500055500056600000000066000000000000000000566650004999400aaa7a7aa0aaa77aa066556605665550005665566555500600006670006700667
0000000000000000005600000000056600000000000000000055500000444000aa67a67a0aa6707a005555000605550005055560555000000000000000000000
0000000000000000000500000000005500000000000000000000000000000000aaa67a670aaa6707006006000050500000505000055555500000000000000000
0500000005000000088000000000000000000000006670000000000000000000a000000a000a000000aaaaaa7700a00000077000055000000000000000000000
5650000059500000899800000000000000000000066677000000000000800000aa0770aa00aa0000000aaaa07770aa000007700056650000000666600aaaa000
0500000005000000899800000000000000000000666776700000000008880000aaa77aaa0aaa77000000aa000777aaa0a007700a56650000000600600a00a000
0000000000000000088000000000000000000000666775770000000000800000aaa77aaaaaa777007777777000777aaaaa0770aa05500000000600600a00a000
0000000000000000000000000000000000000000666777700000000000000000aa0770aa00777aaa77777770aaa77700aaa77aaa00000000000600600a00a000
0000000000000000000000000000000000000000566677000000000000000000a007700a0777aaa00000aa000aaa7700aaa77aaa00000000000d00d009009000
0000000000000000000000000000000000000000055667700000000000000000000770007770aa00000aaaa000aa0000aa0770aa00000000000dddd009999000
0000000000000000000000000000000000000000005550000000000000000000000770007700a00000aaaaaa000a0000a000000a000000000000000000000000
09900990077700000990000002202200022022000220220002202200005665000660000002202200004994000000000000000000000000000000000000000000
977897787eee00009aa900002ee288202882ee20288288202882882006666660600600002882882009999990808080808080080000000007000666600aaaa000
97789778eee200009aa900002ee8882028eeee2028888e202888882056776665600600002888e82049779994808080808880088000990970000622600a88a000
08800880ee200000099000002e8888202eeee820288eee202888882066776665066600002888882099779994888080808880888809449440000622600a88a000
0000000000000000000000002e8888202eee88202eeeee2028888e2066666655000560600288820099999944080080808080088064444446000622600a88a000
0000000000000000000000000288820002e8820002eee200028ee20056666555000056560028200049999444080008808080080060444406000d22d009889000
0000000000000000000000000028200000282000002e2000002e200005555550000005600002000004444440000000000000000066000066000dddd009999000
00000000000000000000000000020000000200000002000000020000005555000000000000000000004444008888888888888880066666600000000000000000
0777777077277767000055555555000007705555555507700000000000000000777777770ddddddddddddd000055055507705555555507700000000056666665
7eeeeee80070007000000666666000007ee0066666600ee80000005500000000c717c717d555555555555550060005557ee0066666600ee80006500054444445
7eeeeee82202200200000000000000007ee0000000000ee8000000000000000071c171c1d5555555555555506506d0507ee0000000000ee85605555005555550
7eeeeee8822822280000060000600000000006000060000000005505550000001c1c1c1cd555555555555500d50d550600000608706000005566550000000000
7eeeee888888888855550000000055555555000000005555000000000000000011111111d5555555555550505005550d55550008700055555665555000000000
7eeeee880828082006660000000066600666000000006660005505550555000011111111d55555050505050006d0500506660e887ee066605666555000000000
7eee8888000000000000000000000000000000000000000000000000000000001111111105505050505050006d5506d0700008887ee000005665555000000000
0888888020002008060000000000006006000000000000605505550555055500111111110000000000000000d5550d5006888880088880605566550000000000
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
07777770077777777777777030003300303000303000330003000300030003000770555555550770077777777777777007777770077777700000000000000000
76666665766666666666666500330033007330330033003300300300003003007660066666600665766666666666666576666660066666650000000000000000
7666666576666666666666653300330037a730303300330000033000000330007660000000000665766666666666666576666660066666650000000000000000
76666655766666666666665503303030307000730330303000033000000000000000060000600000066666666666665076666666666666550000000000000000
76666565766666666666656503000303030307a73000030000300300000000005555000660005555066666666666656076666666666665650000000000000000
76565655766666565656565500030303003700730303030000300030000000000666005656006660066666565656565076666656565656550000000000000000
75656555766565656565655500033000337a73003303300003000030000000000000056565600000066565656565655076656565656565550000000000000000
05555550055555555555555000000303003700030300000003000030000000000600555555550060000005555550000005555555555555500000000000000000
22222222222222222220022222222222222227777772222222222222000000000000000000000000000000000000000000000000000000000000006666000000
22222222222222222207002222222222222222226777722222222222000000000000000000000000000000000000000000000000000000000000665555660000
22222222222222222077030222222222222222222277772222222222777777777777777777777777777777777777777777777777770000000006555660555000
22222222222222220730733022222222222222222227777222222222111111111111111111111111111111111111111111111111117700000005555660555000
02222222220222207777373702222222222222222226777222222222111111111111111111111111111111111111111111111111111170000005566666605000
30222022207022073773033030222222222222222222777722222222000000001111111111111111111111111111111111111111111117000005566666605000
33020702073000773333303033022222222222222222777722222222088888880000000000000011d000001d0000d00001d00000111111700005500660005000
33307330733307733333300333302222222222222222777722222222d0880008808888888088800d008880d08888008880d08880111111170005555660555000
00070337033077333300330070030222222222222222777771111111d0880d08800880008008880008880d08800880088800880d111111170005555660555000
00733030000773330033000300330022222222222226777771111111d0880d088008800000088880888800880d08800888808801111111170005555660555000
00003003007000000000030000030302722222222227777771111111d0880d0880088880dd088088808800880d088008808888011111111700e5555000555800
00000030000003300030000000003330672222222277777207111111d0880008800880001d088008008800880d08800880088801111111700e33355555558a80
0000000000000000330000000000030027722222677777720711111d00880330800880dd000880d0d08800880d08800880d08801111111706666666666666666
000000000000000000000000000000332277777777777722711111d03088033300088000800880ddd088008800880d0880d08801111111176565565556565656
00000000000000000000000000000030222777777777722271111d03308800033088888880888011d08880088880d08880d08880111111175555555555555555
0000000000000000000000000000007322222777777222221111d03330880d000000000000000000000000000000000000d00000000011115050050500050505
2222222222222222505050507000000770000007000000007111d033308800880d03333330d0033330033333333033330dd03333333011170000000000000000
2222222222222222605050506000000660000006000000007111d03308888880ddd033330dd033003303003300300330d1dd0330003011170000000000000000
2222222222222222606050507067660770676607000000775711d0330000000d11d0300301d033000000d0330d000330111d0330000011750000000000000000
2222222222222222606060507077770770777707000077110711d03330ddddd11d03300330dd03330dddd0330ddd0330111d033330dd11700000000000000000
2222222002022220606060607007070770707007000711117111d033301111d0000333333000d0333011d033011d0330111d0330001111170000700000070000
22222207307022076060606070777607706777070071111d7111dd03330000033003300330030d003301d033011d03301d000330dd0011170007170000717000
22222077073000776000006070776007700677070711111d71111dd0333333330d033003300330003301d033011d033000300330003011170071117777111700
22220773733307736066606067000076670000767111111d711111dd03333330d03330033300333330dd033330d0333333303333333011170711111111111170
2220773300000000606060600677776000007700007700005711111dd000000dd0000000000d00000d1d000000d0000000000000000011750571117777111750
22077333055505556060606000067000000076700767000005711111ddddddd1ddddddddddddddddd11ddddddddddddddddddddddddd17500057175555717500
20773030000000006066606000777700000076677667000000571111111111111111111111111111111111111111111111111111111175000005750000575000
07730330550555056000006000067000000076700767000000057711111111111111111111111111111111111111111111111111117750000000500000050000
73303000000000006060606000777700000077000077000000005577777777777777777777777777777777777777777777777777775500000000000000000000
30373000055505556060606007600670000000000000000000000055555555555555555555555555555555555555555555555555550000000000000000000000
73730000000000006060606007000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03000000550555056060606076000067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005550000000500500005000000000000000000000000000000000f90004999999400004999940000004999999994000000000004999999940000000000000
00057575000005750555555000000000000000000000000000000000949999404444999999222299940049222222229999940004999400022224000011111011
0057576500005755555555550000000000000000008000000000080094440402044422222222222229999222f222222222299999444000222222900011111011
05765657000055755655556500000000000000000088000000008800490000020444f222222f222222222222222222222222222f400000222222940011111011
5765765600057565556556550000000000000000008880000008880009f420f220444ff222222222222222222222222222f22ff4000002222222294000000000
56656556000565655555555500000000000000000008880000888000904400000044444f22222222222222222222222222222440000022222222229410111111
055550050005655005555550000000000000000000008800008800009000f4442004444422222222222f2222222222222222f440000222244222222910111111
00000000000055000055550000000000000000000000000000000000940f440420044244f2222f22222222222222222222224400022222222222222910111111
0000000000000000000110000000000000011000888880008888200094000000004044444222222222222222222222222fff4000022222222222442900000000
0000000000000077001100000001000000110000888820008882000049440440440444444f22200000000000022ffffff4444000202020202222222911111000
00000077000007aa0171000000110000017100008882000088820000090442442444444444ff02244444444220f4442444440002200000002222222911111000
000077aa00007aaa0171000001710000017100008882000088820000094444444444200044440000000000000024244244400022220f42022222222911111000
0007aaaa00007aaa1761000017610000176100008882000088820000094244444442000002440f44444442442022244444000222220402022222229400000000
007aaaaa0007aaaa17610000166100111761000088882000888820000944444242000000002404044f4422402044444240000000000442022244229010000000
07aaaaaa0007aaaa1661001116651122166100118888820088888200094442000000002000240000000000000024424404242424040402044222229010000000
07aaaaaa007aaaaa1665112216552222166511222822880028228800494400000000000002444444424424242444444042424240440000044422229010000000
aaaaaaa7aaaa67002222556122222551222255610000008800220088944002000002000002444442242242222424000000000000444444440022229000000000
aaaaaa67aaa667002222255122222211222225510000088800220888942000000000000004000022400000000000200000222220004444000022229400011111
aaaa666766666700222222112222221022222211220008880088088894000000020000002440f400000000200000000002222200000000000002222900011111
66666667666677002222221020022100222222102200088800880888940000000000000024404400000000000002220002222200000002000002222900011111
66666677666677002202221022222100202222108880028800888288942002000000200044404020022222222222200022222000020000000202442900000000
66667777666777002002210022221000220221008888882800888828942200000000000024004420222224222222200224422002000000200002222900000001
7777777077777000222221002222100022222100088888280008882849422000020002244000402042244224442200222222200f000020002000222900000001
77777000777000002222100022221000222210000088888200088882094422000000224400000420404444442444002222220000000000000000222900000001
00111100001111102222100022221000222210008888800088882000094442222222444000204020440424444444022222222220000000000222222900000000
01222210012222712222100020221000222210008888200088820000094244444444240000424444444444444444422222442222222222222222222911011111
01222221122222112221000022210000222100008882000088820000922444244244400004222442444000000044442222222222222222222222229411011111
1222217112222100202100002211000020210000888200008820000094222244444000002222422444440f420444244222222222222244222224429011011111
12222111122227102021000011100000202100008882000088200000094222222000000222422242244204020442424222222222222222222222229000000000
12117100122221102221000011000000222100008820000082000000092224220000022999942422424444444424224422999999992222222222222911111101
17101100012227102210000000000000221000008200000082000000924999900002299400499422999942422999999999440000049999999999222911111101
01100000001111101100000000000000110000002000000020000000499400499999900000004999400099999400000000000000000000000044999411111101
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f90004999999400004999940000004999999994000000000004999999940000000000000000000000000000000000000
00000000000000000000000000000000949999404444999999222299940049222222229999940004999400022224000000000000000000000000000000000000
0000000000000000000000000000000094440402044422222222222229999222f222222222299999444000222222900000000000000000000000000000000000
000000000000000000000000000000004900000204449222222f2222222222222222222222222229400000222222940000000000000000000000000000000000
0000000000000000000000000000000009f420922044499222222222222222222000222222f22994000002222222294000000000000000000000000000000000
000000000000000000000000000000009044000000444449222222222222222220f4022222222440000022222222229400000000000000000000000000000000
000000000000000000000000000000009000f4442004444422222222222f22220000202222229440000222244222222900000000000000000000000000000000
00000000000000000000000000000000940f44042004424492222f22222222200000002222224400022222222222222900000000000000000000000000000000
0000000000000000000000000000000094000000004044444222222222222220f402222229994000022222222222442900000000000000000000000000000000
00000000000000000000000000000000494404404404444449222220000000004409999994444000202020202222222900000000000000000000000000000000
000000000000000000000000000000000904424424444444449990000f4200000004442444440002200000002222222900000000000000000000000000000000
0000000000000000000000000000000009444444444420004444000004420f442024244244400022220f42022222222900000000000000000000000000000000
00000000000000000000000000000000094244444442000002440f44000000402022244444000222220402022222229400000000000000000000000000000000
000000000000000000000000000000000944444242000000002404040f4420000044444240000000000442022244229000000000000000000000000000000000
00000000000000000000000000000000094442000000002000240000044220224424424404242424040402044222229000000000000000000000000000000000
00000000000000000000000000000000494400000000000002444444000000242444444042424240440000044422229000000000000000000000000000000000
00000000000000000000000000000000944002000002000002444442242242222424000000000000444444440022229000000000000000000000000000000000
00000000000000000000000000000000942000000000000004000022400000000000200000222220004444000022229400000000000000000000000000000000
0000000000000000000000000000000094000000020000002440f400000000200000000002222200000000000002222900000000000000000000000000000000
00000000000000000000000000000000940000000000000024404400000000000002220002222200000002000002222900000000000000000000000000000000
00000000000000000000000000000000942002000000200044404020022222222222200022222000020000000202442900000000000000000000000000000000
00000000000000000000000000000000942200000000000024004420222224222222200224422002000000200002222900000000000000000000000000000000
00000000000000000000000000000000494220000200022440004020422442244422002222222009000020002000222900000000000000000000000000000000
00000000000000000000000000000000094422000000224400000420404444442444002222220000000000000000222900000000000000000000000000000000
00000000000000000000000000000000094442222222444000204020440424444444022222222220000000000222222900000000000000000000000000000000
00000000000000000000000000000000094244444444240000424444444444444444422222442222222222222222222900000000000000000000000000000000
00000000000000000000000000000000922444244244400004222442444000000044442222222222222222222222229400000000000000000000000000000000
0000000000000000000000000000000094222244444000002222422444440f420444244222222222222244222224429000000000000000000000000000000000
00000000000000000000000000000000094222222000000222422242244204020442424222222222222222222222229000000000000000000000000000000000
00000000000000000000000000000000092224220000022999942422424444444424224422999999992222222222222900000000000000000000000000000000
00000000000000000000000000000000924999900002299400499422999942422999999999440000049999999999222900000000000000000000000000000000
00000000000000000000000000000000499400499999900000004999400099999400000000000000000000000044999400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777070707770000007707770077077707000777000007000777077700770000007707070777077700000777070707770000077707770707077707770000000
00070070707000000070007070700007007000700000007000070070007000000070707070700070700000070070707000000070700700707070007070000000
00070077707700000070007770777007007000770000007000070077007770000070707070770077000000070077707700000077000700707077007700000000
00070070707000000070007070007007007000700000007000070070000070000070707770700070700000070070707000000070700700777070007070000000
00070070707770000007707070770007007770777000007770777077707700000077000700777070700000070070707770000070707770070077707070070000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888880
08000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080
08000030000000000000000000000000000000000003300000000000000000000000000000000000000330000000000000000000000330000000000000000080
08030330000000000000000000000000000000000030030000000000000000000000000000000000003003000000000000000000003003000000000000000080
08030033000000000000000000000000000000000030003000000000000000000000000000000000003000300000000000000000003000300000000000000080
08003300000000000000000000000000000000000300003000000000000000000000000000000000030000300000000000000000030000300000000000000080
08030003000000000000000000000000000000000300003000000000000000000000000000000000030000300000000000000000030000300000000000000080
08000030303000303030000000000000000000000300030000000000000000000000000000000000030003000000000000000000030003000000000000000080
08033033000330330003300000000000000000000030030000000000000000000000000000000000003003000000000000000000003003000000000000000080
08073030303030303030300000000000000000000003300000000000000000000000000000000000000330000000000000000000000330000000000000000080
08000073303000033030003000000000000000000000000000000000000000000000000000000000000330000000000000000000000000000000000000000080
080307a7030303300303033000000000000000000000000000000000000000000000000000000000003003000000000000000000000000000000000000000080
08070073003300330033003300000000000000000000000000000000000000000000000000000000003000300000000000000000000000000000000000000080
080a7300330033003300330000000000000000000000000000000000000000000000000000000000030000300000000000000000000000000000000000000080
08070003003300030033000300000000000000000000000000000000000000000000000000000000030000300000000000000000000000000000000000000080
08000030303000303030003030300030303000303030000000000000000000000000000000000000030003000000000000000000000000000000003030300080
08033033000330330073303300033033007330330003300000000000000000000000000000000000003003000000000000000000000000000003303300033080
080030303030303037a730303030303037a730303030300000000000000000000000000000000000000330000000000000000000000000000030303030303080
08000003303000033070007330300003307000733030003000000000000000000000000000000000000000000000000000000000000000000030000330300080
0803033003030330030307a703030330030307a70303033000000000000000000000000000000000000000000000000000000000000000000303033003030080
08030033003300330037007300330033003700730033003300000000000000000000000000000000000000000000000000000000000000000033003300330080
0800330033003300337a730033003300337a73003300330000000000000000000000000000000000000000000000000000000000000000003300330033003080
08030003003300030037000300330003003700030033000300000000000000000000000000000000000000000000000000000000000000000033000300330080
08077767772777677727776777277767772777670777777007777770555507700777777077277767772777677727776777277767772777677727776777277080
08000070007000700070007000700070007000707eeeeee87eeeeee866600ee87eeeeee800700070007000700070007000700070007000700070007000700080
08022002220220022202200222022002220220027eeeeee87eeeeee800000ee87eeeeee822022002220220022202200222022002220220022202200222022080
08082228822822288228222882282228822822287eeeeee87eeeeee8006000000eeeeee882282228822822288228222882282228822822288228222882282080
08088888888888888888888888888888888888887eeeee887eeeee88000055550eeeee8888888888888888888888888888888888888888888888888888888080
08080820082808200828082008280820082808207eeeee887eeeee88000066600eeeee8808280820082808200828082008280820082808200828082008280080
08000000000000000000000000000000000000007eee88887eee8888000000000888888800000000000000000000000000000000000000000000000000000080
08002008200020082000200820002008200020080888888008888880000000600000088020002008200020082000200820002008200020082000200820002080
08077770020000000200000002000000020000000200000002000000020000005555000002000000020000000200000002000000077777777777777007777080
08066665000000200000002000000020000000200000002000000020000000206660000000000020000000200000002000000020766666666666666576666080
08066665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000766666666666666576666080
08066655002000000020000000200000002000000020000000200000002000000060000000200000002000000020000000200000766666666666665576666080
08066565000000000000000000000000000000000000000000000000000000000000555500000000000000000000000000000000766666666666656576666080
08065655000000000000000000000000000000000000000000000000000000000000666000000000000000000000000000000000766666565656565576666080
08056555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000766565656565655576656080
08055550000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000055555555555555005555080
08077777777777700777777777777770303000303030000000000030303000000000000055550000000000000000000000000030303000005050505000000080
08066666666666657666666666666665000330330003300000033033000330000000000066600000000000000000000000033033000330006050505005550080
0806666666666665766666666666666530303030303030000030303030303000000000000000000000000000000000000030dd3d303030006060505000000080
080666666666665576666666666666553030000330300030003000033030003000000000006000000000000000000000003dddd3303000306060605055055080
08066666666665657666666666666565030303300303033003030330030303300000000000005555000000000000000003ddfff0030303306060606000000080
08066656565656557666665656565655003300330033003300330033003300330000000000006660000000000000000000ddfff3003300336060606005550080
0805656565656555766565656565655533003300330033003300330033003300000000000000000000000000000000003d22dd20330033006000006000000080
0805555555555550055555555555555000330003003300030033000300330003000000000000006000000000000000000df22223003300036066606055055080
0807777007777777777777700777777777777770303000303030003030300030303000303030000055550000000000303dfff220303000306060606000000080
080666657666666666666665766666666666666500033033007330330003303300033033000330006660000000033033001ff133000330336060606005550080
08066665766666666666666576666666666666653030303037a73030303030303030303030303000000000000030303037111130303030306066606000000080
08066655766666666666665576666666666666553030000330700073303000033030000330300030006000000030000330722173303000036000006055055080
080665657666666666666565766666666666656503030330030307a70303033003030330030303300000555503030330030222a7030303306060606000000080
080656557666665656565655766666565656565500330033003700730033003300330033003300330000666000330033003dd073003300336060606005550080
080565557665656565656555766565656565655533003300337a73003300330033003300330033000000000033003300337dd300330033006060606000000080
08055550055555555555555005555555555555500033000300370003003300030033000300330003000000600033000300311103003300036060606055055080
08077777777777700000000000000000077777777777777077477767774777677747776777477767774777677747776707777777777777700777777777777080
08066666666666650000000000000000766666666666666500700070007000700070007000700070007000700070007076666666666666657666666666666080
08066666666666650000000000000000766666666666666544044004440440044404400444044004440440044404400476666666666666657666666666666080
08066666666666550000000000000000766666666666665594494449944944499449444994494449944944499449444976666666666666557666666666666080
08066666666665650000000000000000766666666666656599999999999999999999999999999999999999999999999976666666666665657666666666666080
08000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080
08888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888880
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010206030700000900000103070009000000010101000008010101010108090000000000000000000101010101080801010100000000000307010101010000
0000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf0000a58788898a8b8c8d0000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf00ae969798999a9b9c9daf00efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf00bea6a7a8a9aaabacadbf00efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf0000b6b7b8b9babbbcbd0000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01100000211502114021122211121f1501d1501c1501a1501f1501f1401f1221f1121c1501a15018150171501d1501d1401d1321d11217150181501a1501d1501c1501c1501c1421c1321c1221c1120000000000
011000001d1501d1401d1221d11217150181501a1501d1501c1501c1401c1221c112131501515017150181501a1501a1401a1321a112131501515017150181501515015150151421513215122151120000000000
01100000211502114021122211121f1501d1501c1501a1501f1501f1401f1221f1121c1501a15018150171501d1501d1401d1321d11217150181501a1501d1501c1501c1501c1421c1321c1221c1120000000000
011000001d1501d1401d1221d11217150181501a1501d1501c1501c1401c1221c112131501515017150181501a1501a1401a1321a112131501515017150181501515015150151421513215122151120000000000
010e00001f0501f0301f0501f030210502205022040220321f0501f0301f0501f0302105022050220402203221050210401d0501d0301d0501d0301a0501f0501f0501f0501f0501f0421f0321f0221f0121f000
010e00001f0501f0301f0501f030210502205022040220321f0501f0301f0501f0302105022050220402203224050240402105021040270502704026040260502604026030260222601225050250402605026040
010e000027050270302705027030290502b0502b0402b03029050290502905029050290402903029022290122a0502a0302a0502a0302b0502d0502d0402d0302e0502e0502e0502e0502b0402b0302d0402d030
010e00002e0502e0302e0502e0302d0502b0502b0402a0502a0402a0302605026030260502603026050260302705027040260502604024050220502204022030210502105021040210301d0501d0501d0401d030
010e00001302015020160201a0201302015020160201a0201302015020160201a0201302015020160201a020130200e0201302016020130200e02013020160201302015020160201a0201302015020160201a020
010e00001302015020160201a0201302015020160201a0201302015020160201a0201302015020160201a0201802015020180201b0201802015020180201b0201a020160201a0201d0201a020160201a0201d020
010e00001b020160201b020160201b020160201b020160201d0201a0201d020210201d0201a0201d020210201e0201a0201e0201a0201e0201a0201e0201a0201f0201a0201f020210201f0201a0201f02021020
010e00001b020160201b0201f0201d0201a0201d020210201f0201b0201f02022020210201d020210202402022020210201f0201e0201b0201a0201802016020150201102015020110200e020110201502011020
0003000015540125300d5201c5001c550225402a53000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
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
01 21234344
00 22234344
00 24254344
00 24254344
01 25294344
00 262a4344
00 272b4344
02 282c4344
