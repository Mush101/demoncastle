pico-8 cartridge // http://www.pico-8.com
version 16
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
	end
	if b.slaves and r then
		for a in all(b.slaves) do
			if a.extends_hitbox and self:intersects(a, r) then return true end
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

--------------------------------------------------------------------------------

cam = actor:new({speed=0.5, always_update = true, depth=-19})

function cam:update()
	if player.stairs then
		self.speed=0.5
		--only transition screen on stairs.
		local y_prev = self.y
		self:y_move()
		if self.y!=y_prev then
			blackout_time=20
			self:jump_to()
			player:checkpoint()
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
	self.x = self.goal_x
end

function cam:y_move()
	if player.y<=104 then
		self.y=0
	else
		self.y=112
	end
end

function cam:set_position()
	camera(self.x, self.y)
end

--------------------------------------------------------------------------------

player = actor:new({s=0, height=14, dcc=0.5, max_spd=1, animation=0,
					stairs=false, stair_timer=0, stair_dir=false,
					ducking=false, whip_animation=0, whip_cooldown = 0,
					invul = 0, extra_invul=0, always_update = true, depth=-2})

function player:update()
	self.prev_x, self.prev_y = self.x, self.y
	-- if self.invul<=0 and self.extra_invul==0 then
	self.pal = player_pal
	-- end
	--movement inputs
	if self.invul==0 and self.extra_invul>0 then
		self:flash_when_hit()
	end
	if not self.stairs then
		--move on the ground
		if self.invul == 0 then
			--crouching
			if btn(3) and (self:on_ground() or self.ducking) then
				if not self.ducking then
					self.y+=2
				end
				self.ducking = true
				-- self.spd=0
				self.acc=0
			else
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
			end

			if self.ducking then
				self.height=12
			else
				self.height=14
				if self:is_in_wall() then
					self.y-=2
				end
				if self:on_ground() and btnp(4) then
					self.grav=-player_jump_height
				end
			end
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
		self.ducking = false
		self.spd=0
		if btn(2) and not btn(3) then
			self.stair_timer+=1
			self.f = self.stair_dir
		elseif btn(3) and not btn(2) then
			self.stair_timer-=1
			self.f = not self.stair_dir
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

	if btnp(5) and self.whip_animation == 0 and self.whip_cooldown == 0 then
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
	self.walk_s = self.s

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
	blackout_time=40
	self.health=player_max_health
	self.x, self.y, self.stairs, self.f, self.stair_dir = self.check_x, self.check_y, self.check_stairs, self.check_f, self.check_stair_dir
	self.invul, self.invis, self.mom, self.grav, self.invis = 0, false, 0, 0, false
	cam.special_goal = false
	cam:jump_to()
	cam:y_move()
	clear_level()
	load_level(current_level)
end

function player:on_ground()
	for a in all(actors) do
		if a.supporting_player then
			return true
		end
	end
	return actor.on_ground(self)
end

--todo: unneeded?
function player:fully_on_ground()
	return actor.fully_on_ground(self)
end

function player:mount_stairs_down()
	local pos_x=self.x+6
	if self.f then
		pos_x-=4
	end
	local pos_y=self.y+16
	local is_stairs = get_flag_at(pos_x, pos_y, 1)
	local facing_left = get_flag_at(pos_x, pos_y, 2)
	if is_stairs then
		self.stairs = true
		self.x = flr(pos_x/8)*8+2
		if facing_left then
			self.x-=4
		end
		self.y = flr(pos_y/8)*8-14
		self.animation = 1
		self.stair_dir = facing_left
		self.f = not facing_left
		self.stair_timer=-10
	end
end

function player:mount_stairs_up()
	local pos_x = self.x+8
	if self.f then
		pos_x = self.x
	end
	local pos_y = self.y+8
	local is_stairs = get_flag_at(pos_x, pos_y, 1)
	local facing_left = get_flag_at(pos_x, pos_y, 2)
	if is_stairs and ((facing_left and pos_x%8>=4) or (not facing_left and pos_x%8<4)) then
		self.stairs = true
		self.x = flr(pos_x/8)*8
		self.y = flr(pos_y/8)*8-6
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
	self.s = 16 + self.master.walk_s%2
	if self.s == 16 and self.master.stairs then
		self.s +=2
		if self.master.f != self.master.stair_dir then
			self.s +=1
		end
	end
	if not self.master:on_ground() and not self.master.stairs or self.master.ducking then
		self.s = 20
	end
end

function player:hit(attacker)
	if self.invul == 0 and self.extra_invul==0 then
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
			if a.enemy and self:intersects(a) then
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

function enemy:hit_player()
	if self.invul == 0 and self:intersects(player, true) then
		player:hit(self)
		return true
	end
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
	if self.invul<=0 then
		self:hit_player()
	end
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

batboss = bat:new({health=6, s=194})

function batboss:update()
	bat.update(self)
	self:animate()
	boss_health = self.health
	boss_max_health = 6
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

axe_knight=enemy:new({s=8, height=16, pal_type=2, health=5, base_max_spd=0.5, goal=32, throw_timer=0, hand_timer=0, death_sound=11})

function axe_knight:init()
	self:use_slaves()
	self:add_slave(axe_knight_legs:new())
	self:add_slave(axe_knight_hand:new())
	self:update_slaves()
end

function axe_knight:update()
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

platform = actor:new({width=16, height=3, s=48, speed = 0.005, xw=0, yw=-16, pal_type=0, depth=-5})

function platform:init()
	self.origin_x, self.origin_y = self.x, self.y
	self.position=0
	self:use_slaves()
	self:add_slave(mirror:new())
	self:use_pal()
end

function platform:update()
	self.supporting_player = false
	if player.x>=self.x-8 and player.x<self.x+self.width then
		if player.y + player.height >= self.y and player.prev_y + player.height <=self.y+self.height then
			player.y = self.y-14
			player.grav = 0
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

function platform:move()
	self.position = (self.position+self.speed) % 1
	self.x = self.origin_x + self.xw * sin(self.position)
	self.y = self.origin_y + self.yw * sin(self.position)
end

--------------------------------------------------------------------------------

fall_platform = platform:new({pal_type=2, always_update=true, timer=0, flicker_timer=0, falling_timer=0})

function fall_platform:move()
	self.change_x = 0
	self.change_y = 0
	self.flicker_timer = max(self.flicker_timer-1, 0)
	self.invis = self.flicker_timer%2!=0
	if self.supporting_player then
		self.falling_timer+=1
		if self.falling_timer>=10 then
			self.falling = true
		end
		self.timer = 0
	else
		self.timer+=1
		self.falling_timer=0
	end
	if self.falling then
		self:gravity()
		if self.timer>60 then
			self.falling, self.flicker_timer = false, 20
			self.x, self.y = self.origin_x, self.origin_y
		end
	end
end

--------------------------------------------------------------------------------

pendulum = platform:new({xw=0, yw=0, speed = 0.003})

function pendulum:init()
	platform.init(self)
	self.length = self.y-self:get_top()
end

function pendulum:move()
	self.position = (self.position+self.speed) % 1
	local p = sin(self.position)/15
	self.x = self.origin_x + self.length * sin(p)
	self.y = self:get_top() + self.length * cos(p)
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
	if self.x+8>player.x then
		cam.x = min(cam.x, self.x-120)
	end
end

--------------------------------------------------------------------------------

cam_border_left = actor:new({depth=-20})

function cam_border_left:update()
	if self.x<player.x then
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
	end
end

--------------------------------------------------------------------------------

mirror = actor:new()

function mirror:update()
	self:goto_master()
	self.x+=8
	self.s = self.master.s
	self.pal = self.master.pal
	self.invis = self.master.invis
end

--------------------------------------------------------------------------------

chicken = actor:new({s=61, depth=-10})

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

function heart_crystal:update()
	if self.invis then
		if self:on_camera() then
			self.invis = false
			for a in all(actors) do
				if a.enemy and a:on_camera() then
					self.invis = true
				end
			end
		end
		if not self.invis then
			self.x-=36
			self:be_chicken()
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

village_level = "352233e20f1099d0323289197h04c00b|26wp00w20hw30n5v100hw40n5vw100w2100hw30n80005vw4025vw2008000w3800012035v10921126w5a626wda60026wp00w20h125vw60m0h8h0n5vw100w2100hw30n00w15vw3025vw300w70h07030m0h1126wl0026w7242526wf00w2125vw406125vw600w20n100h0n0m0h00w15vw2025vw400w7121007030m1126wh242526w10026w72k2l26w530222326w130222326w100w2125vw2100hw2075vw3101200w20hw2075v1000w15v00w40k0400we2326w130222326wbak2l26w10021222326w130222326w130222326w1303g2i2j20213g5v2j202100w40k0400w4050l00w6100n100h070m005vw2lv5vw20200wf2j20213g5v2j20212326w130222326w1302223302223002h2i2j20213g2i2j20213g2i2j20213g5vw22g2h5vw22g2h5v115vw202060h00w20h07035vw10m0n00w210125v0m0n5v005vw5025v00wf5v2g2h5vw22g2h2j20213g5v2j20213g2i2j3g2i2j005vw22g2h5vw22g2h5vw22g2h5vwb115vw10206gh0n00w2121007035vw10h0n00100hw1125vw2805vw4025vw100w80h000m00w35vw82g2h5vw22g2h5vw5005vwq115v025v10120600w20hw207035v0m0h11100n100n5v1007805vw3025vw200w80n125v001200w15vwfdv5vw4005vwp00w40k0400w5100h07035v0m110m0hw10n5v00wi5v0m0h0n001000w15vwl005vw806115vwf110h125v020600w512100h07035v115v100n5vw100wi075v0n5v120m00w15vwk1000155vw213155vw210115vw3131400w45vw313118n5v02060h00w701w200w10100w10501w300w10100w201w200w6125vw1120m0700w15vw1060h12115vw11110125vw6115v100h0014155v1314111206120h115vw21314w1115vw21114155v131411120206120m00w70jw200110j000jw1030jw6000jw400w50h07060h070m00w15v11100hw1115vw1110hw2115vw4110hw20001w31h1i1h1i1h1i1h1i01w4115vw21101wf00w25vw200115v00w15vw1035vwc00w401w500w101w10k0400w101w1000100w201w400w10100w10jwg115vw2110jwe00w35vw100w11100w25vw2035vwb00w40jw500w10jw1020jwi0026a600w10h12115vw311100h00w1a62600wu80005vw1035vw61j14w11k14w21k14w11l5vw6025v008000wh26w100w10h12115vw311100h00w126w100x0155vw1035vw61k14w21k14w11l1m5vw6025vw18000wi26w100w10m0h115vw311070m00w126w100x014155vw1035vw51j14w41l5v1m5vw5025vw28000wi26w100w1070m115vw3110h0700w126w100x1050l00w25vw51m141k1l1mlv5v1n5vw4025vw38000wi26w100w10h12115vdv5vw111120h00w1263000x05vw1035vw81n1j1l5v1m5vw400wr232600w10hw1115vw311108n00w1213g00x015lv5v035vwb1m5vw500wq2j2000w11210115vw3110n0600w12h5v00x014w1155v035vwa1n5vw600w15v115vw1115vwj2g00w1125v115vw311061200w15vw100x75vwg00w15v115vw1115vwk00w10h12115vw3110h0n00w15vw100x05v115v115v115vwcdv5vw300w15v115vw1115vwk00w10h12115vw2dv11100700w15vw100x015115v1115115vwh00w15v115vw1115vwj00w212w1115vw311100h00w25v00x0141113119411155vw6lv5vw71300w15v115vw1115vwj00w20k0400w5050l00w25v00x0h4111411141114155v13155vw213155vw41314w100w15v115vw1115vwi00w15vw1025vw20m0h0n0m0n030m0h00x201wa5vw101w25vw101w500w15v115vw1115vwi00w15v025vw3060n060n100n031000wm08wm0ow108w20ow108wv"

function _init()
	hard_mode = false

	enemy_pal_1 = {5,8,2,15}
	--enemy_pal_2 = {3,13,11,15}
	--enemy_pal_2 = {5,6,9,0}
	enemy_pal_2 = {2,14,8,0}
	hurt_pal = {8,9,7,7}
	player_pal = {1,13,2,15}

	whip_length=10
	whip_speed=0.25
	whip_cooldown=10
	actors = {}

	player:use_slaves()
	add_actor(player)
	player:add_slave(player_legs)
	--player_sword:use_slaves()
	--player:add_slave(player_sword)
	--player_sword:add_slave(player_sword_tip)

	player.whip = whip:new()
	player:add_slave(player.whip)
	player.whip:setup(whip_length)

	player:checkpoint()

	--temp
	-- local zom = bat:new({x=184+8, y=16-8})
	-- zom:init()
	-- add_actor(zom)
	--
	-- local pla = fall_platform:new({x=61*8, y=20*8})
	-- pla:init()
	-- add_actor(pla)
	-- local pla = fall_platform:new({x=64*8, y=20*8})
	-- pla:init()
	-- add_actor(pla)
	-- local pla = fall_platform:new({x=67*8, y=20*8})
	-- pla:init()
	-- add_actor(pla)
	--
	-- local pla = platform:new({x=70*8, y=22*8, yw=24})
	-- pla:init()
	-- add_actor(pla)
	--
	-- local pla = pendulum:new({x=8*8, y=19*8})
	-- pla:init()
	-- add_actor(pla)

	add_actor(cam)

	terminal_velocity=4
	grav_acc = 0.15
	player_jump_height=2.5

	player.health = 6
	player_max_health = 6

	boss_health = 2
	boss_max_health = 6

	draw_bounding_boxes = false

	blackout_time = 0
	--start_film_reel()
	current_level = village_level
	clear_level()
	load_level(current_level)
	level_offset = -58

	health_timer=0
	got_key, got_stones = false, 0
end

function clear_level()
	actors = {player, cam}
	for i=0,127 do
		for j=0,27 do
			mset(i,j,0)
		end
	end
end

entity_dict = {zombie, bat, cam_border_right, cam_border_left, platform:new({yw=24}), platform:new({xw=24}), fall_platform, pendulum, chicken, breakable_block, shooter, shooter:new({base_f=false}), axe_knight, batboss, boss_cam, heart_crystal, stone_sealing, key}

function load_level(s)
	cls()
	load_string = "loading..."
	print(load_string, 64-2*#load_string, 61, 7)
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
				add(entity_list, entity_dict[num]:new())
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
	sort_actors()
	for a in all(actors) do
		if (a.y>=cam.y and a.y<cam.y+112) or a.always_update then
			a:update()
			if a.dead then
				del(actors, a)
			end
		end
	end
	if film_reel then
		film_offset += film_speed
		film_speed += film_acc
		if film_speed<0 then
			film_speed = 0
		end
		if film_speed>128 then
			film_speed = 128
		end
		film_offset = film_offset % 128
	end
	cpu_usage = stat(1)
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
	xd = abs(x1-x2)
	yd = abs(y1-y2)
	return sqrt(xd*xd + yd*yd)
end

function start_film_reel()
	film_reel = true
	film_offset = 120
	film_speed = 16
	film_acc = -0.1
end

--------------------------------------------------------------------------------

function _draw()
	cls()
	if blackout_time<=0 then
		clip(0,0,128,112)
		cam:set_position()
		map(0,0,0,0,128,32)
		for a in all(actors) do
			a:draw()
		end
		player:draw()
		camera()
		clip()
	end

	if film_reel then

		-- for i=0, film_offset do
		-- 	memcpy(0x8000-(1+i)*64, 0x6000+(film_offset-i)*64, 64)
		-- end
		--
		-- --rectfill(0, 112-film_offset, 127, 126-film_offset, 0)
		--
		-- for i=0x6000,0x8000-64 * (film_offset+16), 64 do
		-- 	memcpy(i, i+64*film_offset, 64)
		-- end

		int_offset = flr(film_offset)

		if int_offset<112 then
			memcpy(0x4300, 0x6000, int_offset*64)
			memcpy(0x6000, 0x6000 + int_offset*64, (128-int_offset)*64)
			memcpy(0x6000 + (128-int_offset)*64, 0x4300, int_offset*64)
		else
			val = 128 - int_offset
			memcpy(0x6000+64*val, 0x6000, (128 - val)*64)
			rectfill(0,0,127,val-1,0)
		end

	else
		draw_hud()
	end
end

function draw_hud()
	rectfill(0,112,127,127,0)
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
		spr(i, cursor, 117)
		cursor+=10
	end
end

function draw_stat()
	middle_text = "actors: " .. #actors
	print(middle_text,64-2*#middle_text, 115)
	middle_text = ""..cpu_usage*100 .. "%"
	for i=#middle_text,8 do
		middle_text = " "..middle_text
	end
	middle_text = "cpu:"..middle_text
	x = 64-2*#middle_text
	print(middle_text,x, 121)
	col = 3
	if cpu_usage>1 then col=8 end
	line(x,127,x+cpu_usage*(4*#middle_text),127,col)
end

__gfx__
0000660600006606000066060006606000ff66060000660600006606000000000066660000000000000000000000000000055000006670000000770000005505
0006666000066660000666600066660000ff66600006666000066660000000000666666000055000000000000000000000577500066677000007777000055550
0066fff00066fff000666ff0066fff0000f6fff00066fff00066fff0000000000666666000577500000000000055550005777750666776707707777000057770
0066fff00066fff000666ff0ff6fff0000f6fff00066fff00066fff0000000000666fff000567500055550000577775005777750666775777705777000557770
067766700677667006666660ff76670006f7667006776ff0067766700000000057666f6005665000006665005777777505777750666777700766557000665570
6f77777f06f77770066677700f77770006777770067ff770067f77700000000055766f6500655000006667505677776505677650566677000076660000666600
6ff7777f06fff7700667fff00777770006777770067777700677ffff000000005555555500650000005577505666666505666650055667700066660000667777
0ff55500005ff50000555ff0055555000055550000555550005555ff000000005656566600500000000055000555555000555500005550000066660000666657
00555500005555000055550006775500007555500000000000000000000000005655567756555677060550600006000600060006006666000066660000677600
00755700000775000077566066677550567756600000000000000000000000005666566756665667060550600050555500005555065555500067760000777700
06770770000777000077766066007750566006600000000000000000000000000566566705665667655555560560565600055656655575550007770007770770
66600660000660000667055555500770500005550000000000000000000000000555556705555567655555565666555500566555555577550007600066600760
56000660000660000660000000000670000000000000000000000000000000000675656706675567656556565666555000566556555555500006700067000670
05500555000555000566000000000660000000000000000000000000000000006665656606665566066556605665550005665566555500600006670006700667
00000000000000000056000000000566000000000000000000000000000000006675675606675056005555000605550005055560555000000000000000000000
00000000000000000005000000000055000000000000000000000000000000006667567506667505006006000050500000505000055555500000000000000000
05000000050000000550000000000000000000000000000000000000000000006000000600060000006666665500600000055000055000000000000000000000
5650000059500000566500000000000000000000000000000000000000000000660550660066000000066660555066000005500056650000000666600aaaa000
0500000005000000566500000000000000000000000000000000000000000000666556660666550000006600055566606005500656650000000600600a00a000
0000000000000000055000000000000000000000000000000000000000000000666556666665550055555550005556666605506605500000000600600a00a000
0000000000000000000000000000000000000000000000000000000000000000660550660055566655555550666555006665566600000000000600600a00a000
0000000000000000000000000000000000000000000000000000000000000000600550060555666000006600066655006665566600000000000d00d009009000
0000000000000000000000000000000000000000000000000000000000000000000550005550660000066660006600006605506600000000000dddd009999000
00000000000000000000000000000000000000000000000000000000000000000005500055006000006666660006000060000006000000000000000000000000
0660066007770000066000000220220002202200022022000220220000aaaa000660000002202200004440000000000000000000000000000000000000000000
677567757eee0000677600002ee288202882ee2028828820288288200aa00aa06006000028828820049aa400808080808080080000000007000666600aaaa000
67756775eee20000677600002ee8882028eeee2028888e20288888200aa00aa0600600002888e82049999a40808080808880088000990970000622600a88a000
05500550ee200000066000002e8888202eeee820288eee202888882000aaaa00066600002888882049999940888080808880888809449440000622600a88a000
0000000000000000000000002e8888202eee88202eeeee2028888e20000aa000000560600288820049999940080080808080088064444446000622600a88a000
0000000000000000000000000288820002e8820002eee200028ee200000aaa00000056560028200004999400080008808080080060444406000d22d009889000
0000000000000000000000000028200000282000002e2000002e2000000aa000000005600002000000444000000000000000000066000066000dddd009999000
00000000000000000000000000020000000200000002000000020000000aaa000000000000000000000000008888888888888880066666600000000000000000
07777770772777670000555555550000077055555555077000000000000000007777777700550555005505550055055500000000000000000000000000000000
7eeeeee80070007000000666666000007ee0066666600ee80000005500000000c717c71706000555060005550600055500000000000000000000000005022000
7eeeeee82202200200000000000000007ee0000000000ee8000000000000000071c171c16506d0506506d0506506d05000000000000000000000000000222200
7eeeeee8822822280000060000600000000006087060000000005505550000001c1c1c1cd50d5506d50d5506d50d550600000000000000000000000050222200
7eeeee8888888888555500000000555555550008700055550000000000000000111111115005550d5005550d5005550d00000000000000000000000000222200
7eeeee8808280820066600000000666006660e887ee0666000550555055500001111111106d0500506d0500506d0500500000000000000000000000002222220
7eee8888000000000000000000000000700008887ee000000000000000000000111111116d5506d06d5506d06d5506d000000000000000000000000002222220
088888802000200806000000000000600688888008888060550555055505550011111111d5550d50d5550d50d5550d5000000000000000000000000002222220
00000000000000000000000002000000077777700777777000000000000000007777777700550555005505550055055000000000000000000000000002222220
066605550555055506660660000000207eeeeee87eeeeee80555055505550000c717c71706000555060005550600055000000000000000000000000002222220
000000000000000000000000000000007eeeeee87eeeeee8000000000000000071c171c10d06d0506506d0506506d05000000000000000000000000002222220
060666055505550555066600002000007eeeeee00eeeeee800055505550555001c1c1c1c050d5506d50d5506d50d550000000000000000000000000002222220
000000000000000000000000000000007eeeee800eeeee880000000000000000111111110005550d5005550d5005550000000000000000000000000002222220
066605550555055506660660000000007eeeee800eeeee8800000555055500001111111106d0500506d0500506d0500000000000000000000000000002222220
000000000000000000000000000000007eee8880088888880000000000000000111111110d5506d06d5506d06d5506d000000000000000000000000002222220
06066605550555055506660000000000088000000000088000000005550000001111111105550d50d5550d50d5550d5000000000000000000000000002222220
0000000056655550000000000000003030300030303000000000000000000000000000000055055500550d550055055000000000000000000000000000000000
05550555565655500555000000033033000330330003300000000000000000000000000006000555060005550d00005000000000000000000000000000000000
0000000056655550000000000030303030303030303030000000000000000000000000000d06d0506506d0506506d00000000000000000000000000000000000
000555055566550055055500003000033030000330300030000000000000000000000000000d5506d50dd506d50d550000000000000000000000000000000000
0000000056655550000000000303033003030330030303300000000000000000000000000005550d500d550d500d550000000000000000000000000000000000
0555055556665550055500000033003300330033003300330000000000000000000000000000550506d0550506d0500000000000000000000000000000000000
000000005665555000000000330033003300330033003300000000000000000000000000000005000d5505000d55000000000000000000000000000000000000
00055505556655005505550000330003003300030033000300000000000000000000000000000000005000000000000000000000000000000000000000000000
07777770077777777777777030003300303000303000330003000300030003000000000000000000000000000000000000000000000000000000000000000000
76666665766666666666666500330033007330330033003300300300003003000000000000000000000000000000000000000000000000000000000000000000
7666666576666666666666653300330037a730303300330000033000000330000000000000000000000000000000000000000000000000000000000000000000
76666655766666666666665503303030307000730330303000033000000000000000000000000000000000000000000000000000000000000000000000000000
76666565766666666666656503000303030307a73000030000300300000000000000000000000000000000000000000000000000000000000000000000000000
76565655766666565656565500030303003700730303030000300030000000000000000000000000000000000000000000000000000000000000000000000000
75656555766565656565655500033000337a73003303300003000030000000000000000000000000000000000000000000000000000000000000000000000000
05555550055555555555555000000303003700030300000003000030000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222220022222222222222227777772222222222222000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222207002222222222222222226777722222222222000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222077030222222222222222222277772222222222000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222220730733022222222222222222227777222222222000000000000000000000000000000000000000000000000000000000000000000000000
02222222220222207777373702222222222222222226777222222222000000000000000000000000000000000000000000000000000000000000000000000000
30222022207022073773033030222222222222222222777722222222000000000000000000000000000000000000000000000000000000000000000000000000
33020702073000773333303033022222222222222222777722222222000000000000000000000000000000000000000000000000000000000000000000000000
33307330733307733333300333302222222222222222777722222222000000000000000000000000000000000000000000000000000000000000000000000000
00070337033077333300330070030222222222222222777700000000000000000000000000000000000000000000000000000000000000000000000000000000
00733030000773330033000300330022222222222226777700000000000000000000000000000000000000000000000000000000000000000000000000000000
00003003007000000000030000030302722222222227777700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000030000003300030000000003330672222222277777200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003300000000000300277222226777777200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000033227777777777772200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000030222777777777722200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000073222227777772222200000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000000000000000000000000000000000000000000000000000000002222222888222222223333353333333533dddd3353222255555555555555522200000000
000000000000000000000000000000000000000000000000000000002222223eee22222223333333333b33333466664333222555555555555555555500000000
00000000000000000000000000000000000000000000000000000000223252ee5e226d6d33333533333333344260662444225555161616161111155100000000
00000000000000000000000000000000000000000000000000000000383ee35e8532266d333b33333333334222222222222255511d6666661111111100000000
0000000000000000000000000000000000000000000000000000000022222222222222223b3333333b5333dd222222222225551111ddddd11111111100000000
00000000000000000000000000000000000000000000000000000000222222262225222243333353333333d6222222222255511122d060d22211155100000000
000000000000000000000000000000000000000000000000000000002222226d222252222333333333333422222222222555511222d66d622221111100000000
000000000000000000000000000000000000000000000000000000002222226622225522244433b335334222222222222555112222d0d0d22222111100000000
000000000000000000000000000000000000000000000000000000002222224622222555522244444444222225522d6d4d4d4d422ddddddd2222111100000000
000000000000000000000000000000000000000000000000000000002222444344422255555522222222222555226dd64d4d4d422ddd0ddd2222111100000000
00000000000000000000000000000000000000000000000000000000224444444444222555555555555555555226d62255111152222222222222111100000000
000000000000000000000000000000000000000000000000000000002244444444f44222250555555555555056ddd22555111152222222222222115500000000
0000000000000000000000000000000000000000000000000000000023444f344444442222655555555555222222225555111155222222222225111100000000
0000000000000000000000000000000000000000000000000000000024444444444444422d622626262222222222555551111155555522225555111100000000
000000000000000000000000000000000000000000000000000000002244f44444443444d6d22d66662222222225555511111115555555555555111100000000
0000000000000000000000000000000000000000000000000000000022244444444444f4462222ddd55555555555555111111111505555555551111100000000
00000000000000000000000000000000000000000000000000000000522224443f3444444d6ddd0665555ddd5555551111111111111555551111111100000000
00000000000000000000000000000000000000000000000000000000555222244444444346dd65d6d55226062222511111551111111111111111111100000000
000000000000000000000000000000000000000000000000000000001555222224444f44222225d6052222222222511111111111111111111111111100000000
000000000000000000000000000000000000000000000000000000001155522222244442222255d6622222622225511111111111111111111111111100000000
000000000000000000000000000000000000000000000000000000001115555222222222222555dd6226d6d6d655511111111111111551111111551100000000
000000000000000000000000000000000000000000000000000000005111555552222222225552d0626d6ddd6d55111111115511111111111111111100000000
000000000000000000000000000000000000000000000000000000001111115555555555555552222dd222222551111111111111111111111111111100000000
00000000000000000000000000000000000000000000000000000000115511115555555555522222222222225511111111111111111111115511111100000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010206030700000101010100000000000000000101000000010101000000000000000000000000000101010000000001010100000000000000000000000000
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
000200000f72000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001172000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000d72000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000024630216401d6401a63019630176201760019600166001560015600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c1201d1201e1301f1301f1301f1301d1201b1201a1202460024600246002460024600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000400002423025230262302723028220282202822228222262322523224232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001c6301c6301c6302b6302b6302b6300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
