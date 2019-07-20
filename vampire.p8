pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

--------------------------------------------------------------------------------

-- Every object in this game is classed as an actor.

-- Lua uses a prototype system for objects, so an actor is defined here,
-- so that I can use it to create other objects later as subclasses.

actor={x=0, y=0, width=8, height=8, grav=0, spd=0, max_spd=2, acc=0, dcc=1, depth=0}

function actor:new(a)
	self.__index=self
	return setmetatable(a or {}, self)
end

-- While the following two methods don't do anything, they're important.
-- Subclasses of the actor object use these, so they get defined here first.
function actor:update() end
function actor:init() end

-- Most actors use this default draw function.
function actor:draw()
	-- Don't draw the actor if its invis property is set.
	if self.invis then return end
	-- Only draw the actor if it has a sprite set.
	if self.s then
		-- Set a colour palette if the actor uses one.
		if self.pal then
			self:set_pal()
		end
		-- Draw the sprite at the actor's location, flipping it if needed.
		spr(self.s, self.x, self.y, 1, 1, self.f)
		-- Reset the palette after drawing the object.
		pal()
	end
	-- Some actors use 'slaves' (see the function 'actor:use_slaves()')
	-- If this actor uses them, we draw those next.
	if self.slaves then
		for s in all(self.slaves) do
			s:draw()
		end
	end
end

-- Applies a 7-colour palette to the actor.
-- Different actors can use different colours from the colour palette.
-- This is why many sprites in the sprite sheet are coloured so oddly.
function actor:set_pal()
	for i=1,7 do
		pal(base_pal[i], self.pal[i])
	end
end

-- Determine whether the actor is touching the ground.
-- If 'fully' is true, then it will only return true if the actor
-- is entirely on the ground.
function actor:on_ground(fully)
	local a,b=is_solid(self.x, self.y+self.height+1), is_solid(self.x+self.width-1, self.y+self.height+1)
	if fully then return a and b else return a or b end
end

-- Performs the effects of gravity upon an actor.
function actor:gravity()
	-- The 'grav' property of an actor defines its vertical acceleration.
	-- A negative number means that the actor is travelling upwards.
	self.y+=self.grav
	-- The global property 'termianl_velocity' defines the fastest an
	-- actor can fall.
	-- This pervents an actor from clipping through the floor, for example.
	self.grav = min(self.grav,terminal_velocity)
	-- Some actors are 'flying'.
	-- These actors define their own maximum gravity and acceleration.
	if self.flying then
		self.grav+=self.grav_acc
		self.grav = mid(-self.max_grav, self.grav, self.max_grav)
	else
		self.grav+=grav_acc
	end
	-- Most actors are affected by the tragic concept of walls.
	if not self.ignore_walls then
		-- After an actor is moved due to gravity, it checks whether it ended
		-- up inside a wall.
		if self:is_in_wall() then
			if self.grav>0 then
				-- If the actor was moving downwards, it is placed above
				-- the tile it clipped inside.
				local feet_y = self.y+self.height
				feet_y = flr(feet_y/8)*8
				self.y=feet_y-self.height
			else
				-- If the actor was moving upwards, it is placed below.
				self.y = flr(self.y/8)*8+8
			end
			-- Either way, its gravity acceleration is reset to 0.
			self.grav = 0
		end
	end
end

-- Determines whether the actor is currently in a wall.
-- This method is universal, so works for objects of varying widths and heights.
function actor:is_in_wall()
	-- First, we define a set of x coordinates, 8 points apart.
	xs = {}
	for i=self.x, self.x+self.width-1, 8 do
		add(xs, i)
	end
	-- We also include a point at the far width of the object.
	add(xs, self.x+self.width-1)

	-- We do the same for the y points.
	ys = {}
	for i=self.y, self.y+self.height-1, 8 do
		add(ys, i)
	end
	add(ys, self.y+self.height-1)

	-- Once we have these points, we can check each pair of x and y.
	for i in all(xs) do
		for j in all(ys) do
			if is_solid(i, j) then
				return true
			end
		end
	end
	-- Since the points we defined are all 8 pixels apart, and the size of a
	-- single tile is 8 pixels, we can determine whether the actor is in a wall
	-- just by checking these points.
	return false
end

-- Move the actor based on its speed and accelration values.
function actor:momentum()
	-- Accelerate the actor by its 'acc' value.
	self.spd+=self.acc
	-- Then, slow the actor by moving its speed closer to 0, based on its
	-- deceleration. 'dcc' is deceleration because 'acc' is acceleration...
	self.spd=move_towards(0, self.spd, self.dcc)
	-- The speed has to be clamped between the max and min speeds.
	-- The in-built 'mid()' function does this on its own, which is helpful.
	self.spd=mid(-self.max_spd, self.spd, self.max_spd)
	-- Then the actor is actually moved by its 'spd'.
	self.x+=self.spd
	-- Like with gravity, some actors have to obey the mortal laws of walls.
	if not self.ignore_walls then
		-- After the actor is moved, the actor checks to see
		-- whether it is now in a wall.
		if self:is_in_wall() then
			-- The actor is moved to be exactly on a pixel.
			self.x=flr(self.x)
			-- Then the actor moves backwards until it is no longer in a wall.
			while self:is_in_wall() do
				if self.spd>0 then
					self.x-=1
				else
					self.x+=1
				end
			end
			-- Then the object has its speed set back to zero.
			self.spd=0
		end
	end
end

-- This function exists solely to reduce tokens used by calling the method
-- momentum(), then the method gravity().
function actor:momgrav()
	self:momentum()
	self:gravity()
end

-- The 'slaves' system used in this game allows for an actor to have slave
-- actors which act as an extention of the actor itself.
-- This is especially helpful for game objects which are larger than 8x8 pixels.
-- Calling this function initialises the use of slaves for an object.
function actor:use_slaves()
	self.slaves = {}
end

-- In order to update its slaves, an actor using slaves calls this method.
function actor:update_slaves()
	if not self.slaves then return end
	for s in all(self.slaves) do
		s:update()
	end
end

-- This method adds a slave to an actor using htem.
function actor:add_slave(a)
	if not self.slaves then return end
	add(self.slaves, a)
	a.master, a.pal = self, self.pal
end

-- This function sets a slave object's location to its master actor.
function actor:goto_master()
	if not self.master then return end
	self.x = self.master.x
	self.y = self.master.y
end

-- Checks whether the actor is far enough off screen to not be worth updating.
function actor:offscreen()
	return self.x<cam.x-self.width-32 or self.x>cam.x+128+32
end

-- Determines whether an actor is within the current bounds of the camera.
function actor:on_camera()
	return self.x+self.width>=cam.x and self.x<cam.x+128 and self.y+self.height>=cam.y and self.y<cam.y+112
end

-- Performs a quick check to see whether two actors' bounding boxes overlap.
-- This means we don't need to do exact pixel collision between all actors.
function actor:hitbox_overlaps(a)
	if self.x+self.width<a.x then return false end
	if a.x+a.width<self.x then return false end
	if self.y+self.height<a.y then return false end
	if a.y+a.height<self.y then return false end
	return true
end

-- Check whether two actors are touching, using exact pixel collision.
function actor:intersects(b, r)
	-- First, check the bounding boxes.
	if self:hitbox_overlaps(b) then
		-- If either object has no sprite set, we rely just on bounding boxes.
		if not self.s or not b.s then
			return true
		end
		-- We make use of PICO-8 draw functions to check for overlap.
		-- We clear an area in the corner of the screen and draw both sprites.
		rectfill(0,0,16,8,0)
		spr(self.s,0,0,1,1,self.f)
		spr(b.s,8,0,1,1,b.f)
		-- Based on the relative positions of the actors, we check the pixels
		x_dif,y_dif=b.x-self.x, b.y-self.y
		for x=max(0,x_dif),min(7,7+x_dif) do
			for y=max(0,y_dif),min(7,7+y_dif) do
				a_pix, b_pix=pget(x,y), pget(8+x-x_dif,y-y_dif)
				-- If both pixels are coloured at a certain location, we
				-- have an intersection.
				if a_pix!=0 and b_pix!=0 then
					return true
				end
			end
		end
	end
	-- If we didn't find a collision, and the object uses slaves, AND the
	-- recursive property 'r' is set, we check the slaves too.
	if b.slaves and r then
		for a in all(b.slaves) do
			if a.extends_hitbox and self:intersects(a, r) then return true end
		end
	end
	return false
end

-- This method is called when an actor is hit by the player's whip.
-- Some actors will re-implement this.
-- The default behaviour means that slave objects defer to their master on it.
function actor:hit(attacker)
	if self.master then
		self.master:hit(attacker)
	end
end

-- This method is mostly around from when there used to be multiple palettes
-- used for enemies, instead of one big one. It sets the palette for enemies.
function actor:use_pal()
	if self.pal_type == 1 then
		self.pal = enemy_pal
	end
end

-- This generates a particle actor used for the animation of something dying.
function actor:death_particle()
	add_actor(death_particle:new({x=self.x+rnd(self.width),y=self.y+rnd(self.height)}))
end

-- This method causes a boss (an actor which can display a healthbar) to
-- gain more health in later levels, based on the 'progression' variable.
function actor:level_up()
	if self.max_health then
		self.max_health+=progression
		self.health+=progression
	end
	return self
end

--------------------------------------------------------------------------------

-- The camera (or cam, to avoid the in-build function name) is a special actor.
-- It controls the viewpoint of the game.
-- Unlike most actors, this one *must* be updated last to prevent an unpleasant
-- shaking effect.

cam = actor:new({speed=0.5, always_update = true, x=896})

function cam:update()
	-- Only transition the screen on when the player is on the stairs.
	if player.stairs then
		self.speed=0.5
		local y_prev = self.y
		self:y_move()
		if self.y!=y_prev then
			-- 'blackout_time' causes the screen to go black as a transition.
			blackout_time=40
			self:jump_to()
			-- Whenever the camera moves between screens, the game sets a
			-- checkpoint (unless you're playing in hard mode).
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
	-- The camera needs to adhere to 'border' objects, which stop it from
	-- moving past the screen edges.
	for a in all(borders) do
		if (a.y>=cam.y and a.y<cam.y+112) a:cupdate()
		if (a.dead) del(borders, a)
	end
end

-- Sets the camera's goal position. Normally, this puts the player in the
-- centre of the screen.
function cam:set_goal()
	if self.special_goal then
		self.special_goal = false
	else
		self.goal_x = player.x-60
	end
end

-- Moves the camera straight to where it should be.
function cam:jump_to()
	self:set_goal()
	self.x=self.goal_x
end

-- Moves the camera between the two subscreens.
function cam:y_move()
	if player.y<=104 then
		self.y=0
	else
		self.y=112
	end
end

-- Use the camera object to call the 'camera()' function used for drawing.
function cam:set_position()
	camera(self.x, self.y-16)
	if not between_levels then
		clip(0,0,128,112)
		camera(self.x, self.y)
	end
end

--------------------------------------------------------------------------------

-- Obviously, the 'player' actor is the player's avatar in the game.
-- It's actually comprised of two actors, for the upper and lower body,
-- since it spans two sprites.

player = actor:new({s=0, height=14, dcc=0.5, max_spd=1, animation=0,
					stair_timer=0, whip_animation=0, whip_cooldown = 0,
					invul = 0, extra_invul=0, always_update = true,
					legs_s=0})

function player:update()
	self.prev_x, self.prev_y, self.pal = self.x, self.y, player_pal
	if self.health<=0 then
		self:death_particle()
	end
	if self.invul==0 and self.extra_invul>0 then
		self:flash_when_hit()
	end
	if self.invul==0 and self.extra_invul==0 then
		self.invis=false
	end
	-- The player behaves differently when it's on the stairs.
	if not self.stairs then
		if self.invul == 0 then
			if self.health>0 then
				-- Set the player's acceleration based on the arrow buttons.
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
				-- Jump with the Z button. Doesn't work on map screen.
				if self:on_ground() and zp and not between_levels then
					self.grav=-player_jump_height
				end
			end
			self:momgrav()
			-- When the player is still, reset its animation.
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

	if xp and self.whip_animation == 0 and self.whip_cooldown == 0 and self.health>0 and not between_levels then
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
	check_x, check_y, check_stairs, check_f, check_stair_dir = self.x, self.y, self.stairs, self.f, self.stair_dir
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
			if a.enemy and self:intersects(a, true) and player.health>0 then
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
		self.invul=12
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

			local xd, yd = abs(self.x-player.x), abs(self.y-player.y)
			if sqrt(xd*xd + yd*yd)<32 then
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
	if self.awake then
		if self.x<=cam.x and self.x>cam.x-8 then
			self.x = cam.x
		end
		self.x=min(self.x,cam.x+120)
	end
	-- self.x=max(self.x,176)
	self:update_slaves()
	if current_level==2 or current_level==6 then
		self:boss_health()
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

shooter = enemy:new({s=29, health=3, base_f=true, timer=0, death_sound=11})

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

axe_knight_legs = enemy:new({s=24,timer=0,pal_type=1})

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
	-- if self.x<=cam.x+1 then
	-- 	self.x = cam.x+1
	-- end
	self.x = max(self.x, cam.x+1)
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

summoner = enemy:new({s=229, health=6, max_health=6, width=16, height=16, timer=0, invis=true})

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
		self.y,self.invis=176+sin(p_timer)*3,false
		if self:die_when_dead() then
			self:hit_player()
		else
			final_boss = demon:new():init()
			add_actor(final_boss)
			play_music(24)
			--play_music(-1)
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

ending_stone = actor:new({s=58, always_update=true})

function ending_stone:update()
	local timer = e_timer+self.num/3
	if portal_failed then
		self.s=55
		self:gravity()
	else
		--self.x, self.y=move_towards(cam.x+60+sin(timer)*p_width,self.x,2),move_towards(cam.y+36+cos(timer)*p_width,self.y,8) --save tokens here (replace cam.x/y with absolute values)
		local w = p_width-3*sin(p_timer)
		self.x, self.y=cam.x+60+sin(timer)*w,cam.y+34+cos(timer)*w
	end
end

--------------------------------------------------------------------------------

platform = actor:new({width=16, height=3, s=48, speed = 0.005, xw=0, yw=0})

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

cam_border_right = actor:new()

function cam_border_right:init()
	add(borders, self)
end

function cam_border_right:cupdate()
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

function cam_border_left:cupdate()
	if self.x<=player.x then
		cam.x = max(cam.x, self.x)
	else
		self:kill()
	end
end

--------------------------------------------------------------------------------

boss_cam = cam_border_left:new()

function boss_cam:cupdate()
	if (player.x>=self.x) or self.active then
		cam.goal_x,cam.special_goal, self.active = self.x, true, true
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

chicken = actor:new({s=61, grav=-2, invis=true})

function chicken:init()
	self.y+=8
end

function chicken:update()
	if not self:is_in_wall() then
		self.invis = false
		self:gravity()
		if self:intersects(player, true) then
			player.health, self.dead = player_max_health, true
			sfx(2)
		end
	end
end

--------------------------------------------------------------------------------

breakable_block = actor:new({breaks=true, b_bit_s = 49})

function breakable_block:init()
	if(current_level==2)mset(self.x/8,self.y/8,64)
end

function breakable_block:break_me()
	--self.breaks = false
	mset(self.x/8, self.y/8, 0)
	self.dead = true
	for i=0,1 do
		for j=0,1 do
			add_actor(block_bit:new({s=self.b_bit_s, x=self.x+i*4, y=self.y+j*4, grav=-2+j, acc=(i-0.5)/8, f=i==j}))
		end
	end
	for a in all(borders) do
		if a.x==self.x then
			a.dead = true
		end
	end
	sfx(8)
end

--------------------------------------------------------------------------------

block_bit = actor:new({life=30, width=4, height=4, dcc=0, ignore_walls=true, always_update=true})

function block_bit:update()
	self:momgrav()
	self.life-=1
	if self.life<=0 then
		self.dead = true
	end
end

--------------------------------------------------------------------------------

heart_crystal = actor:new({s=57, invis=true, grav=-2})

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
	--and not player.stairs and player.x>cam.x+48
	if abs(self.y-player.y)<16then
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
			got_key = false
		end
		self.dead = true
	end
end

--------------------------------------------------------------------------------

levels =
{
	{data="000000001i?+??+??+??+??+Hh7wy?+3S?PERSC:2P?:3B?+1S?S?+1xh+1xh+1x:2h?:3AEARCS?+8:2?hy?w7?+2T?+1C?TC?+1AB?S?S?+1xh+1xh+1xh?+1C?+1CT?zQB?+5ywymy?+2zA+1DA+1D:jA?A+1?T?S?+1xh+1xh+1x:jh?ADA+1DAQA+2B?u+2:ju1+30+15lt+7?A+1B?+1T?NXUZNONON?t+6NONOMfvfvj+40j3J+6z?A+2?+42?xzBx?+2J+7NONO?L?L?0+5?3?+3zA+1?A+2B?+22?+1xA+1xB?+aNOM?L?L?+10?0+3B3zBzA+1:kA?A+3B?2ezAxA+1xA:kB?+aNO?L?L?+20+6s+5?s+4NONONO1+4?+9NOM8+3?+??+??+??+??+HA+5R?+1PA+4:2A?:3B?+3S?+3S?+1S?:2?+3zA+1QA+dR?+5PA+3?QAB?+1T?+3S?+1T?+1zANO1+cAER?+9PAE?A+1QAQB?+3T?+2z:jAQNONONOj+9?C?+8zB?+1C?1+40+15l1+6NONOh+1NONONO?+4BC?+1zB?/ef/?zAQABC?Oj+63j+3NONOy/A/?why/z/w:gNO:2N+5ADBzQAB/uv/zQA+1QA:jD?NONOABzB?3?+1zB/y/h+1y/P/6ywn/P/wMNO+5t+f?ONONOAQA+1B3zQ:nA/O/hywh+1nwhywNON+5J+f?NO?+1NOt+5NONONONONONONONO+5"},
	{next_start_x=4, next_start_y=58, start_x=16, start_y=82, map_string="the path splits here...", nl_1=3, nl_2=4, offset = -58, data="g5820e2835?+Q:2?+b:2?+4:3?+5:3?+7:e?+e:2?+F:0?+??+??+??+??+1:f?+Z;1?+??+??+M;0?+k:9?+??+A:9?+E:d?+Q;0?+??+??+T:0?+??+??+??+??+??+U:3?+e:2?+w:3?+w:2?+??+z:8?+??+A:9?+??+n;1?+c:9?+r:7?+??+F:h?+C;0?+??+??+??+??+??:4?+E:c?+??+??+h:0?+9:0?+??+E;a?+??+??+??+F"},
	{next_start_x=4, next_start_y=194, start_x=16, start_y=82, map_string="the path continues...", nl_1=5, map_marker={42,18,35}, data="11d20d122iA+5B?+1PA+kR?PA:iA+aE:2A0:3A+f:eR?PA+b:2A0A+6B?+1PA+bRPA+3RS?+3PA+7R?C?0A+bEAR?+3A+c0A+7B?+1PA+9R?+1PER?+1S?+4SPA+3R?+2C?0A+2R?PAEAR?+1C?+5PA+b0A+7R?+3PA+6R?+3C?+2T?+4T?+1PER?+3C?0AR?+4C?+3C?+7PA+5:fA+30PA+5R?+5PA+4R?+4C?+cC?+4C?0?+6C?:5?+2C?+8A+90?+1PAEAR?+4e?+2PER?+6C?ey?+9C?+4C?0?+6C?+3C?+1NONONO?PA+80?+3C?+5wx?+3C?+5zBCzxh7?+3zAB?+1C?+4C?0?+6C?+3C?+1:8MNO?+1x?+1P+1EARSPAE0?+3C?+4whxy?+2C?+3zA+2DAxh+1y?zA+4BC?+3zDA0?+1:4?+3:0?C?+2zDB?:pNOM?+1x?+3C?+1S?+1C0?+3C?+4h+1xy?+2C?+1zA+4NONONOt+2NONOADB?zA+30?+5zDB?zA+2B:pMNO?+1x?+3C?+1T?+1C0AB?+1C?+36h+1xh7?zDA+7MNOJ+6NOMA+80?+4NOt+105lt+2NOMB?x?+3C?+4C0A+2BCzB?+1NONOt+cNO?+8NOt+20k40t+2?+4MNOJ+23J+2?NOABx?+3:cC?+2zAD0A+3DA+3MNOJ+dM?+aMJ+32J+4?+4NO?+43?+3MA+1xABzADA+50t+8NO?+u2?+aM?+63?+1NOt+eJ+8M?+u2?+5o+5NO?+63?+1MJ+e?+2PA+7R?+2S?+1S?+1S?+2S?+1whyw:30?+52?+7PA+8R?+33?+5;i?+fPA+4R?+3S?+1T?+1S?+2S?+1mhnw0?+42?+9SPA+4RS?+53?+fy?+4A+3R?+4S?+4S?+2T?+2whn:90?+32?+aS?+1PA+1R?S?+63?+1;0?+cy?e?+2PAR;1?+2:g?e?+1T?+4S?+6my?:90?+22?+bS?+2S?+2S?+73?+dhyx?+3;1?+4wx?+7T?+60+e?+4T?+2T?+2T?+60+4?+ah+1x?+8wxy?+gx?x?+5x?x?+e:0?+7x?x?+bh+1xh7?+5whxy?+fzxBx?+5x?x?+i:6?+3x?x?+bh+1xh+1y?+36h+1xhy?+czA+1xAxB?+4x?x?+c0+4?+4x?x?+bNONOt+7NONO?+aNONOt+4NONO?x?x?0+2?+5:4?+3x?x?+5x?x?+bMNOJ+9NOMy?+2:5?+5wMNOJ+6NOMBx?x?x?x?+2zB?+4x?x?+5x?x?+bNO?+bNOhy?+66hNO?+8NOAxBx?x:0?x?+1zA+2B?:0?+1x?x?+5x?x?+bM?+dMhy?+6h+1M?+aM;bAxAxBx?x?zA+4B?+1x?x?+5x?x?+bNO?+bNOh+17?+46h+1NO?+8NOt+lNO?+2x?x?+bM?+dMh+2y?+2wh+2M?+aMJ+mMo+h"},
	{next_start_x=140, next_start_y=90, start_x=16, start_y=194, map_string="the path splits again...", nl_1=5, nl_2=6, offset = 50, map_marker={42,24,51}, data="85b30b532gB?3?+7S?+1S?+2S?+43?+5S?+4S?+cS?+1S?+2S?+3:e?+3S?+7S?+10A?+13?+6T?+1S?+2S?+53?+4S?+4T?+cT?+1S?+2S?+7S?+7S?+10AB?+13?+8S?+2T?+63?+3T?+lS?+2T?+7S?+7S?+10s+6NO?+4T?+b3;lKu?+e:l?Ku+2?+3S?+bT?+6:f?S?+10I+5NOMB?+efvfvf?+4:5?+9fvfvf?+3T?+kT?+10?+6NOAB?+1u;lu+2?+8L?L?+gL?L?+t0?+6s+3NOf+1vf?+8L?L?+gL?L?+t0?+6I+2NOM?+1L?+9L?L?+c:4?+3L?L?+3z:0AB?+m0?+aNO?+1L?+9L?L?+7:0?+8L?L?+2zA+3B?:8?+j0?+bM?+1L?+1:4?+7L?L?+6Ku+3?+4L?L?+1NOs+4N:pO?+e:m?+30?+aNO?+1L?+4:l?+4L?:5L?+4fvf+2vf?+4L?L?+1MNOI+2NOM?NO?+f0?+bM?+1L?+4Ku+2?L?L?+5L?+2L?+5L?L?+1NO?+4NO?M+1?NONOs+5NONO?0?+aNO?+1L?+3fvfvf?L?L?+5L?+2L?+5L?L?+1M?+6M?NO?MNOI+7NOM?0?+bMo+BNO?+4NOoM+1oNO?+9NOo0/6+S:26/0+6:3/6+e:26/0/6+7456/+J0/+66/+f0/6+1w236+2kl6+aw236/+v0/+66+9456/+30/01Mij0136+1w236+1w23w01Mij0136+1w236+1w23w236+7w236/+40/+66+9kl6/+30/gh/?/+2ghj01Mij01MijMgh/?/+2ghj01Mij01MijMij0136w201Mij0136/+10/+63w236+7w236/0?/+7gh/?/+2gh/?/+bgh/?/+2gh/?/+5ghj1Migh/?/+2ghj01/0/+6jMij0136w201Mij0/0?/+Gh/?/+9gh/0+6?/+3ghj1Migh/?/+2g/0?+T0+6?/+6h/?+70AB?+R0+6?+b:g?+30A+3B?+hw7?+1wy?+mzAB?0+6?+1e?+c0A+4B?+d:0?+1why?6:lh+17?+b:0?+7zQA+2B0+6?+1xy:0?+8e?+10A+6B?u+a?+1hNO?hNOy?+1u+3?+1u+6?+2zQA+3:lQA0+6?+1xh7?;l?+5wx?+10s+8f+1vf+1vf+1vf+1s+1NONONOs+3f+1vf?+1f+1vf+1vf?+1s+1050+2s+8?s+30+350s+3?0I+8o+aI+bo+eI+33I+aoI+83I+3o0"},
	{next_start_x=276, next_start_y=58, start_x=16, start_y=194, map_string="the castle is ahead.", nl_1=7, offset = -24, map_marker={55,15,21}, data="14a90a492tONONOA+9Rmh+1NONO:3NO?+62?PA+aR?+23?+4:2MNO?+6mh+1yh:2NONOM?+32?+1PA+6:2AN+1ONO?PA+6RS?+1wNONONOM?+52?+2A+8RS?+43?+3NOM?+8w7wN+1:3ONO?+22?+3SPA+5N?+1xn?+2S?PA+1R?T?+2wNONONO?+42?+3PA+6R?S?+53?+2MNO?+7:g?+1myNONO;b?+22?+4S?SPEA+2N?+1x?+3S?+2S?+7NONOM?+32?+5PAEA+2R?+1S?+63?+1NOM?+awMNONONONONONOS?S?CPA+1N?wx?+3T?+2S?+8NONONONONONO?+3SC?;1?S?+2S?+2;l?+3NONONO?+1NONONO;b?+3NONONO?+4x?S?T?C:1?SPN?wx7?+6T?6y?+4NONONONONONO?+4TC?+1S?+2T?+1NXUZNONONOM?+2NONONO?+2MNONO?+5x?S?+2C?S?NONONONOM?+4wy?+4wx?+6NO?+6C?+1S?+62wNONONONO?+3x:1?+2NXUZNONO?+6x?T?+2C?T?N+1ONONONOy?+2wh+1y?:0?+2mx?+fC?+1T?+52?6h+2NONO?+4x?+32?NONO?+7x?+4C?+2N?+4NOMy?+16hywy?+3;a?xy?+7e?+3zBC?+72?wh+2ywNO?+5x?+22?NONONO:8?+6x?+4C?+2N?+1NO?+1NOt+dNOM?+5x?+2zA+1DAB?+4NONOywh+2n:pM?+5x?+12?NONO6hN:pO?+5x?+1zA+1DABN+1?+7J+eNOy?e?+2x?NONOA:lA+2B?+4NONOh+3y:pM?67?+2x?2?+2NO7wNONO?+3:0?x?zA+2NONON?+dNO?+5NOMy?x?+1NONONONONOA+1B?NONONONOywyNOh+2y?+1x2?e?+2NOmhNO?+3zAxA+3NONON+1?+8NO?+bNONONONOt+I040+1t+bN?+nNONONOJ+J2J+eN/6+e:26+N:26/N:3ONOh+1n?+12:e?+3PA+aN/6+?6/+1N+1OMhn?+12?+5PA+6QA+1N/6+3456+xw236+aw236+1w236+1w2/NONOy?+12?+7SPA+6QN/6+3kl6+5w236+dw236+1w236+1wMij36+1w236+3wMij01Mij01Mi/N+1OMn?2?+8S?+1S?+1:fPA+2N/6w236+1w236+1wMij36+1w236+1w236+1wMij01Mij01M/?/+2j01Mij0101M/?/+2gh/?/+2gh/?+1NONONONONO?+5T?+1S?+5N/1Mij01Mij01M/?/+2j01Mij01Mij01M/?/+2gh/?/+2gh/?/+4gh/?/+2ghgh/?+cN+1ONONONOM?+8S?+5N/h/?/+2gh/?/+2gh/?/+4gh/?/+2gh/?/+2gh/?+BNONONONONONONO?+4S?+1NONON?+D:l?+56e?+6;i?+a0?+3NONONO?x?+5T?+2x?N+1?+Ae?NO?+1eywh:0xB?+7e?+6z0?+4NONO?+1x?+9x?AN?+w:l?NONONONO?xh+1nxA+2B?+4xy?+3zA+10?+5NOMB?x?+2e?+4:m?xzANAB?+me?+2;0?+1zANONONONONONONONOA+5B?:lxhn?ezA+20?+6NOABx?+2x?+4zxA+1NA+2B?+2zB?+6zB?+6xy?ezA+1NONONONONO?+1NONONOt+7k40+1A+30?+5NOMA+1xAB?x?+1e?zAxA+1Nt+70k40?+1zA+2B?+20+15lt+5MNO?+3NONO?+1NO?+1NOJ+62J+1zA+30?+6NOt+fNJ+82J+1?zA+5B?+1J+13J+5NO?+fNO?+42?+1zA+40?+7MJ+fN"},
	{next_start_x=140, next_start_y=170, start_x=16, start_y=66, map_string="the castle is ahead.", nl_1=7, offset = -16, map_marker={57,26,53}, data="156707562m/6/+p0+1?+8wh+10+3h+4n?+13?+20+3h+2n?+32?+20+1?mh0/+16+9w236+1w236+4456+1w236+1w/0+1?w7h7?+3wh+10:2?+10h+3n?+33?+10+3hn?+42?+3:90:90?+1w0/+16+8wMij01Mij36+3kl6wMij01M/0+1?mh+3y?+2wh0?+10h+1n?+2mh0+4?+10n?+42?+5:90?+1m0/+16+601M/?/+2gh/?/+2j36+4wM/?/+2gh/?+4whywhy?+2w0+3n?+5wh+30?+10?+10+b7?+10/+16+6gh/?/+9j01201M/?+bmh+37?+1w0+3;b?+7wh+20+1?0?+36h+4n?0+1y?+10/+101:22/+4?/+cghigh/?+7:0?+2w7?+2mh+1y?w0+7y?+3wh+10+3?+2wnwhn?+30+1y?+10/+1ghi/+4?+2e?+n6hy?+3why?+10+3:1wh+2n?+5m0+3?6hn6hn?+1:c?+20+1y?+10+1?+6B?+1x?+4e?+b0+1kc0+7?+1h+1y?0?0+1h+1n?+7;a?0:2?0+1hywywn?+50:20y?+10+8AB?x?+4x?+d2?0+4?x?+16hy?+10?+10hy?+4w0+4?0+ak40+2y?+10+8A+2xB?+2zx?+7e?+32?z0+2?+2x?6nwye?0?+10n?+5whywy0+3h+3n?+326h0+1y?6h:8h+10+51+40?zAxB?+2e?+1zxB?+12?+1A0+1?+1wyx?wewyx?0+1:3?0;b?+7wh+1y0+1:3?0h+1n?+42?wy:90wh7wy:90w0+5j+41+50?+1x?zAxAB2?ezA0+1?e6yxwyxwyx?0+450+1?+17?+1ywh0+1?0hn?+426h+27:90h+50+5?+4j+51+e0+9k40+5h73?+2wy6h7w0+55l0+l?+aj+e0+1wh+2n?+226h+10+3yw73?+1wh+1ywh0+3?x?3?+5x?0+Fwh+1n?+226ywh0?0+1ywh73?+1whywh0+3?x?+13?+3:e0/+46/+a0h7wh+5ywh+2y?+3mh+1ywh+10+1mhy?+226hnwn0?0+1hy?h73?+1wywh0+3?x?+23?+10/+56+6456/+10wywh+2y?mh+2n?+bmn:90?wy?+126h+2n?0?0+1y?+1my?3?wh7:aw0+3?x?+33?0+1?/j/x/6+7kl6/+10h+17whn?+2:gwn?+e:90:90?why26ywn?+1:a?0+1:3?0y?+20+8:2?0+3k40+4?+2x/36+3w23:f6+1w2/0wh+1y?+6:5?+40+2?+30+dk40+2?0y?+3wh7?mh+10?0+1n?2?+2x?+4x/j36+1wMij01Mi/0h+1n?+l0?0h+2n?+426h0+3y?+167why?+1wh0?0+1?2?+3x?+4x?/j01M/?/+2gh/?+10y?+n0?0hy?+52?mh0:2?0+1y:4?+1wywywy?+1w0+6?+2x?+4x?/+1h/+1?+70n?+i:4?+3w0+2y?+2:0?+22?+2w0?0+1y?+1mh+10+1y?+1w0+6?+2x?+4x?+7:d?+30?+10+5?+e6h0+2hn?+32?+3w0+3y?+2wh0+1y?+1h0?:3?x?0+1B?+1x?+4x?+b0?+2x?+1x?+3:0?+awh+10:3?0y?05l0+4?h0+3h7?6h0+2y:6?+1h0?+1x?0+1A?+1x?+1e?+1x?+b0?+2x?+1x?+dwhyw0?0y?+23?+5m0?0+9y?+1w0+1?x?0+1AB?x?+1xzBx?zB?+6zA0?+2x?+1x?+20+2?+10+a?0n?+33?+1wy?+10?x?+1x?+1x?0+1y?+1w0+1?x?0+1A+1BxzAxA+1xA+3B?+2zA+20?+2x?+1x?+3x?+3x?x?x?x?+10+2?w7?+23?my?+10?x?+1x?+1x?0+1n?6h0?+1x?0+11+m?+2x?+1x?+3x?+3x?x?x?x?+10+26h+1y?+23?m7?0+bk40+3?x?0+1j+m"},
	{start_x=16, start_y=50, offset = -28, map_marker={70,20,89}, data="g5820e283g/6+iw20/MNOMhn?26h+2yw:2MNONONONONO?+1NONONO?+h2?+fNONO?+a:2?/+66+a456+4wMih/NONOn?26nhnwyhNO:3NONO?+1NONONO?+1NO?+h2?+gMNONO?/+g36+1w236+1w23kl6+3wM/?+3NOM?26nwy?mywMNONO?+5;1?+5;1?+h2?+hNONO?/+hj01Mij01Mij36+1w01M/?+5NONOYVWO?+1whNOMy?+rYVWO?+6NONOYVWONONONONO?/+hgh/?/+2gh/?/+2j01Mih/?+7xh+273?+2h+1MNOy?+rx73?+6wM:2NOMh73?+2h+2NONO?/+rgh/?+axh+1nw73?+1:gmhNOMy?+rxh73?+46hNONOwh73?+1wh:0h+1NONO?+Dxhy?+1m73?+1hMNOhy?+p6xh+1e3?6ywywMNOM?wh73?+1mh+2NONONONO?+9u+e?+9xh+1:d7?+1h73?mNOMwhy?+ohxywNONONXUZNONONONONXUZNONONONONONONO?+6fvf+4vf+4vfNONONO?+3xywhyewh73?MNOw;0ywy?+d:7?+86hxywxywhn26NONONOw;1hn?2?+1mh+1y?+1;1?+2whNONO+6?L?+4L?+4L?+1NONOM?+3xh7wyxwNONONOMy+1why?+5:7?+fwhx7wxyhn26ywNONOywy?2?+3why?+5mhNON+6?L?+4L?+2e?L?+1x?+1NO?+3xhywhxhMNONONONONXUZ?+j6h+1xywxhy26hywMNOMyhn2?+5h+1y?+5whNO+6?L?+1e?+1L?+2x?L?+1x?NOM1+aNONONONOn?26hy?+gNONONONONONONONONONONONONO?:b?+2wy+1?+5whMN+6?L?+1x?+1Le?+1x?L?+1x?+1NOj+aMNONONOn?26ywhywy?+2why?+2wymhyMNONONONONONONONONONONONONONONONO?+5w;ahNO+68+vNONONO?+126hywhywhy?whywhymh+17whNONONONONONONONONONONONONONONONONONOYVWONON+6OMh+2n?+owh+1y+1?+226M:2N/6/+PNONOh73?+1mh+1ywNO:2N+1Ohn?+rmymy+1?26yNO/6+c45:26/0/6/+zNONOh73?+1wywhMNO+1My?+ty?wy26y+1MN:3/36+1w236+6kl6/0:3/36+1w236+5w36+1w236+gw/NONOh73?+1m7mhMN+1Oy?+tYVWONONONO/j01Mij36+1w0136+1w/0/j01Mij36+1w01Mj01Mij36+1w0136+1w236+3wMi/NONOh73?+1wywNO+1My?+v3?mhyNON?/gh/?/+2j01Mihj01M/0?/gh/?/+2j01Mih/?/+1gh/?/+2j01Mihj01Mij36+1wM/?NONONOh73?+1myMN+1Oy?+v73?w:0ywNO?/+6gh/?/+3gh/?0?/+6gh/?/+agh/?/+3gh/?/+2j01M/?+4NONONONXUZNO+1Mhy?+s;a?wh73mhyMN?+f0?/+vgh/?+4NONOh+1n?26NON+1Oh+1y?+9:7?+hYVWONONONO?+f0?+j0+15l0?+3:5?+aNONOn?26hMNO+1NONONXUZNO?+n3mhywNON?+f0B?+ixhn3?+gxhy?26h+1NONywywn?26NOM?+mh73mh;0hyNO?+f0A+1B?+gxy?+13?+fxn?26h+1NONOywhy?26hMNO?+b:7?+9wh+173mywMN9a?+39:oa9a?+39a0A+5B?+1zB?+8xnzBe3?+ex?26h+1NONO;iNnhn?2?ywNOM?+4ywy?+dwywhNONONOa9a9a9a9a9a9a9a91+aNO?+3:5?+3x70+4?+8NO1+dy+1?2?wywMNOywy6h+2ywhy?+66yhNONONONONON+1ONXUZNONONONONOj+bM?+7xyx?+2x?+8Mj+ehn26hy?wNOMhywh+1ywh7wh+2y?wywhywMNONONONONO?NX26h+7NO?o+Q"}
}

function _init()
	--almost all of the properties can be shoved in one long list. tokens!

	--hard_mode = false

	hurt_pal, player_pal,base_pal=string_to_array("2982928"),string_to_array("1d2f"),string_to_array("567fabd")

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

	terminal_velocity, grav_acc, player_jump_height, player.health, player_max_health, health_timer, boss_health, boss_max_health, got_stones, e_timer, e_stones, blackout_time, darker_pal, darkness, e_add, level_start_timer, level_end_timer, level_start, difficulty_menu, progression, between_levels, p_width, p_timer,map_markers, deaths,minutes, seconds = 4, 0.15, 2.5, 6, 6, 0, 0,0, 0, 0.25, {}, 0, {string_to_array("001521562443d52e"),string_to_array("0001101512250112"),string_to_array("0000000101110001")}, 0, 0.01,0, -20, true, true, 0, false, 0,0, {{41,24,195}}, 0,0,0
	--boss_max_health = 6

	--draw_bounding_boxes = false
	--old darkness: "000520562493152e"
	player:update()
end

function string_to_array(s)
	a = {}
	for i=1,#s+1 do
		add(a, char_to_int(char_at(s,i)))
	end
	return a
end

entity_dict = {zombie, bat, cam_border_right, cam_border_left, platform:new({yw=24}), platform:new({xw=24}), platform:new({yw=-24}), pendulum, chicken, breakable_block, shooter, shooter:new({base_f=false}), axe_knight, batboss, boss_cam, heart_crystal, stone_sealing, key, medusa_spawner, next_level_marker, next_level_marker:new({num2=true}), slime, slimeboss, lock, summoner, breakable_block:new({b_bit_s=33})}

function load_level(level, respawning)
	cls()
	--clear_level
	actors = {player, cam}
	-- for i=0,127 do
	-- 	for j=0,27 do
	-- 		mset(i,j,0)
	-- 	end
	-- end
	between_levels, p_width = level==1, 0
	if level==6 then
		back_entry=true
		levels[7].map_marker={69,30,105}
	elseif level== 4 then
		lower_route=true
		levels[5].map_marker={57,20,37}
	end
	current_level = level
	level = levels[level]
	s, start_x, start_y, next_start_x, next_start_y, next_level, nl_1, nl_2,level_offset, borders = level.data, level.start_x or next_start_x, level.start_y or next_start_y, level.next_start_x or next_start_x, level.next_start_y or next_start_y, level.next_level or 1, level.nl_1 or nl_1, level.nl_2 or nl_2, level.offset or 0, {}

	if current_level==7 and back_entry then
		start_x, start_y=540, 186
	elseif current_level==5 and lower_route then
		start_y=34
	end

	if (level.map_string) map_string = level.map_string
	enemy_pal, width, cursor, x, y, chain, add_val = string_to_array(sub(s,2,8)), two_char_to_int(sub(s,9,10)), 11, 0, 0, 0, 64
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
					entity:use_pal()
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
				if (current_level!=2) mset(x,y,prev_val)
				x+=1
			end
			cursor+=1
		else
			if (current_level!=2) mset(x,y,prev_val)
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

	if not respawning then
		player.x, player.y, player.acc, player.spd, player.grav, player.f = start_x, start_y, 0, 0, 0, false
		player:checkpoint()
		cam.special_goal = false
	else
		player.health=player_max_health
		player.x, player.y, player.stairs, player.f, player.stair_dir = check_x, check_y, check_stairs, check_f, check_stair_dir
		player.invul, player.invis, player.mom, player.grav, player.invis, cam.special_goal, player.s = 0, false, 0, 0, false, false, 1
	end
	player:update_slaves()

	cam:jump_to()
	cam:y_move()
	cam:update()
	if between_levels then
		cam.x=flr(player.x/136)*136
	end

	-- sort_actors()
	-- for a in all(actors) do
	-- 	a:update()
	-- end
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
	xp,zp=btn(5) and not pbx,btn(4) and not pbz
	pbx,pbz=btn(5),btn(4)
	if (not level_end) map_markers[progression+2]=nil
	p_timer=(p_timer+0.01)%1

	if death_time then
		death_time-=1
		if death_time<=0 then
			--respawning
			death_time=nil
			load_level(current_level, true)
			level_start=true
			deaths+=1
		end
	end

	if difficulty_menu then
		if btnp(3) or btnp(2) then
			hard_mode = not hard_mode
			sfx(2)
		end
		if zp or xp then
			difficulty_menu = false
			if hard_mode then
				player.health, player_max_health=4,4
			end
			load_level(2) --start in first level
			sfx(3)
			darkness, blackout_time=5, 20
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
		if level_end_timer<=80 then
			level_end_timer+=1
		else
			level_start, level_end, level_end_timer, got_level_item, darkness = true, false, 0, false, 5
			if not game_end then
				load_level(next_level)
			else
				map_string="you couldn't stop the demon"
				if (good_end) map_string="you sealed the demon away"
			end
		end
		darkness=level_end_timer/5
		if (not ending_sequence) return
	elseif game_end then
		darkness-=0.1
		if good_end then
			play_music(26)
		else
			play_music(25)
		end
		return
	end
	if level_start then
		if level_start_timer<=20 then
		 	level_start_timer+=1
			darkness=5-level_start_timer/5
		else
			level_start, level_start_timer, darkness = false, 0, 0
			play_music(level_music,0b11)
		end
		return
	end
	--end of the game
	if ending_sequence then
		-- if e_timer<0.01 and got_stones>0 then
		-- 	local es = ending_stone:new({x=player.x,y=player.y,num=got_stones})
		-- 	add(e_stones, es)
		-- 	add_actor(es)
		-- 	got_stones-=1
		-- end
		e_timer=(e_timer+e_add)%1
		if not stones_out then
			for i=1,got_stones do
				local es = ending_stone:new({num=i})
				add(e_stones, es)
				add_actor(es)
			end
			stones_out=true
		else
			p_width-=0.05
			if good_end then
				e_add+=0.000025
				p_width-=0.05
				if (p_width<24) final_boss.invis=not final_boss.invis
			else
				e_add-=0.000025
				if p_width<16 or portal_failed then
					final_boss.y-=2
					final_boss.s=210
					--final_boss.timer+=0.01
					final_boss:update_slaves()
					p_width+=2
					portal_failed=true
				end
			end
		end
		if p_width<=12 or p_width>128 then
			level_end, game_end=true,true
		end
		--return
	end
	--sort_actors
	del(actors, player)
	del(actors,cam)
	add_actor(player)
	add_actor(cam)
	for a in all(actors) do
		if a.always_update or (a.y>=cam.y and a.y<cam.y+112) then
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

function is_solid(x,y)
	--ignore tiles above the camera.
	return get_flag_at(x,max(y, cam.y),0)
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

--------------------------------------------------------------------------------

function _draw()
	--if darkness!=0 and prev_darkness==darkness and not game_end then return end
	--prev_darkness=darkness
	cls()
	if (darkness>=4) return
	if game_end and not level_end then
		draw_level_select_gui()
		centre_print("deaths: "..deaths, 72,7)
		local extra=""
		if seconds<10 then
			extra="0"
		end
		centre_print("time: "..minutes..":"..extra..flr(seconds), 82,7)
		if (hard_mode) centre_print("hard difficulty", 92,7)
		centre_print(got_stones.."/3  ", 116,7)
		spr(58,68,114)
	else
		if blackout_time<=0 then
			cam:set_position()
			map(0,0,0,0,128,32)

			if difficulty_menu then
				clip()
				camera()
				centre_print("normal",72,7)
				centre_print("hard",82,7)
				local xd, yd=0,0
				if (hard_mode) xd=4 yd=10
				spr(180,40+xd,72+yd)
				spr(181,79-xd,72+yd)
				-- print("mush101.itch.io", 68,122,5)
				centre_print("mush101.itch.io", 118,5)
				return
			end
			draw_portal()
			for a in all(actors) do
				a:draw()
			end
			--player:draw()
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

	if (darkness>=1) darker()
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
	--local p_m,num=nil,-1
	num=-1
	pal(3,0)
	for m in all(map_markers) do
		if num<progression or p_timer%0.2<0.1 then
			spr(m[3],m[1],m[2])
			spr(m[3]+1,m[1]+8,m[2])
		end
		num+=1
		-- m1,m2=m[1],m[2]
		-- if p_m and (num<progression or p_timer%0.2<0.1) then
		-- 	-- p1,p2=p_m[1],p_m[2]
		-- 	-- for i=0,1,0.2 do
		-- 	-- 	pset(p1+i*(m1-p1),p2+i*(m2-p2))
		-- 	-- end
		-- 	line(m1,m2,p_m[1],p_m[2])
		-- end
		-- num+=1
		-- --circfill(m1,m2,2,0)
		-- circfill(m1,m2,1,8)
		-- p_m=m
	end
	pal()
end

function centre_print(str, y, col)
	print(str,64-2*#str,y,col)
end

function darker()
	for i= 0x6000, 0x7fff do
		local two = peek(i)
		local second = two % 16
		local first = lshr(two - second, 4) % 16

		first, second = darker_pal[flr(darkness)][first+1], darker_pal[flr(darkness)][second+1]

		poke(i, shl(first,4) + second)
	end
end

__gfx__
0000660600006606000066060006606000ff660600006606000066060000000000aaaa00000000000000000000000000000bb00000dda0000000770000005505
0006666000066660000666600066660000ff66600006666000066660000000000aaaaaa0000bb000000000000000000000baab000dddaa000007777000055550
0066fff00066fff000666ff0066fff0000f6fff00066fff00066fff0000000000aaaaaa000bddb000000000000bbbb000baaaab0dddaada07707777000057770
0066fff00066fff000666ff0ff6fff0000f6fff00066fff00066fff0000000000aaafff000badb000bbbb0000baaaab00baaaab0dddaabaa7705777000557770
067766700677667006666660ff76670006f7667006776ff00677667000000000bdaaafa00baab00000aaab00baaaaaab0baaaab0dddaaaa00766557000665570
6f77777f06f77770066677700f77770006777770067ff770067f777000000000bbdaafab00abb00000aaadb0bdaaaadb0bdaadb0bdddaa000076660000666600
6ff7777f06fff7700667fff00777770006777770067777700677ffff00000000bbbbbbbb00ab000000bbddb0bddddddb0bddddb00bbddaa00066660000667777
0ff55500005ff50000555ff0055555000055550000555550005555ff00000000bababaaa00b000000000bb000bbbbbb000bbbb0000bbb0000066660000666657
0055550000555500005555000677550000755550000333333000000000000000babbbaddbabbbadd060550600006000600060006006666000066660000677600
0075570000077500007756606667755056775660033888888300000000000000baaabaadbaaabaad060550600050555500005555065555500067760000777700
06770770000777000077766066007750566006603883333338300000000000000baabaad0baabaad655555560560565600055656655575550007770007770770
66600660000660000667055555500770500005558330000038300000000000000bbbbbad0bbbbbad655555565666555500566555555577550007600066600760
56000660000660000660000000000670000000003000000003830000000000000adbabad0aadbbad656556565666555000566556555555500006700067000670
0550055500055500056600000000066000000000000000000383333000000000aaababaa0aaabbaa066556605665550005665566555500600006670006700667
0000000000000000005600000000056600000000000000000038888300000000aadbadba0aadb0ba005555000605550005055560555000000000000000000000
0000000000000000000500000000005500000000000000000003333000000000aaadbadb0aaadb0b006006000050500000505000055555500000000000000000
0500000007770000088000000000000000033000000000000333300000000000a000000a000a000000aaaaaabb00a000000bb000055000000000000000000000
5650000076660000899800000000000003388300000000333888830000000000aa0bb0aa00aa0000000aaaa0bbb0aa00000bb00056650000000666600aaaa000
0500000066650000899800000000000338833000000033888333300000000000aaabbaaa0aaabb000000aa000bbbaaa0a00bb00a56650000000600600a00a000
0000000066500000088000000000033883300000003388333000000000000000aaabbaaaaaabbb00bbbbbbb000bbbaaaaa0bb0aa05500000000600600a00a000
0000000000000000000000000000388330000000338833000000000000000000aa0bb0aa00bbbaaabbbbbbb0aaabbb00aaabbaaa00000000000600600a00a000
0000000000000000000000000333833000000000883300000000000000000000a00bb00a0bbbaaa00000aa000aaabb00aaabbaaa00000000000d00d009009000
0000000000000000000000003888300000000000030000000000000000000000000bb000bbb0aa00000aaaa000aa0000aa0bb0aa00000000000dddd009999000
0000000000000000000000008333000000000000000000000000000000000000000bb000bb00a00000aaaaaa000a0000a000000a000000000000000000000000
09900990077700000990000033000000000000003330000000000000006666000660000002202200009999000000000000000000000000000000000000000000
977897787eee00009aa900008833000000000330880000000000000006666660600600002882882009999990808080808080080000000007000666600aaaa000
97789778eee200009aa900003388300000333883330000000000000066776665600600002888e82099779994808080808880088000990970000622600a88a000
08800880ee200000099000000033833333888330000000000000000066776665066600002888882099779994888080808880888809449440000622600a88a000
0000000000000000000000000000388888333000000000000000000066666655000560600288820099999944080080808080088064444446000622600a88a000
0000000000000000000000000000033333000000000383333333300056666555000056560028200049999444080008808080080060444406000d22d009889000
0000000000000000000000000000000000000000000388888888830005555550000005600002000004444440000000000000000066000066000dddd009999000
00000000000000000000000000000000000000000003333333333000005555000000000000000000004444008888888888888880066666600000000000000000
0777777077277767000055555555000007705555555507700000000000000000777777770ddddddddddddd000055055507705555555507700000000056666665
7eeeeee80070007000000666666000007ee0066666600ee80000005500000000c717c717d555555555555550060005557ee0066666600ee80006500054444445
7eeeeee82202200200000000000000007ee0000000000ee8000000000000000071c171c1d5555555555555506506d0507ee0000000000ee85605555005555550
7eeeeee8822822280000060000600000000006000060000000005505550000001c1c1c1cd555555555555500d50d550600000608706000005566550000000000
7eeeee888888888855550000000055555555000000005555000000000000000011111111d5555555555550505005550d55550008700055555665555000000000
7eeeee880828082006660000000066600666000000006660005505550555000011111111d55555050505050006d0500506660e887ee066605666555000000000
7eee8888000000000000000000000000000000000000000000000000000000001111111105505050505050006d5506d0700008887ee000005665555000000000
0888888020002008060000000000006006000000000000605505550555055500111111110000000000000000d5550d5006888880088880605566550000000000
00000000000000000000000002000000077777700777777000000000000000007777777733300000000000000055055077377767774777670000000056666665
066605550555055506660660000000207eeeeee87eeeeee80555055505550000c717c71788833333333333300600055000700070007000704444444454444445
000000000000000000000000000000007eeeeee87eeeeee8000000000000000071c171c133388888888888836506d05033033003440440045555555505555550
060666055505550555066600002000007eeeeee00eeeeee800055505550555001c1c1c1c0003333333333330d50d5500b33b333b944944490004900000494400
000000000000000000000000000000007eeeee800eeeee88000000000000000011111111000000000000000050055500bbbbbbbb999999990004900000499400
066605550555055506660660000000007eeeee800eeeee88000005550555000011111111000000000000000006d050000b3b0b30094909400004900000449400
000000000000000000000000000000007eee88800888888800000000000000001111111100000000000000006d5506d000000000000000000004900000494400
0606660555055505550666000000000008800000000008800000000555000000111111110000000000000000d5550d503000300b400040090004900000449400
00000000566555500000000000000030303000303030000049944440499444403030003000000000003300000055055003000000040000000000000000494400
05550555565655500555000000033033000330330003300049494440094944000003303303333333338300000d00005000000030000000400000004400494400
00000000566555500000000000303030303030303030300049944440309440303030303008888888883000006506d00000000000000000000044445500449400
0005550555665500550555000030000330300003303000304499440030090003303000033333333333000000d50d550000300000004000000455550000494400
0000000056655550000000000303033003030330030303304994444003000330030303300000000000000000500d550000000000000000000504900000449400
055505555666555005550000003300330033003300330033499944400033003300000033000000000000000006d0500000000000000000000004900000449400
00000000566555500000000033003300330033003300330049944440330033000094400000000000000000000d55000000000000000000000004900000494400
00055505556655005505550000330003003300030033000344994400003300030499440000000000000000000000000000000000000000000004900000449400
07777770077777777777777030003300303000303000330003000300030003000770555555550770077777777777777007777770077777702020202000000000
76666665766666666666666500330033007330330033003300300300003003007660066666600665766666666666666576666660066666650202020200000000
7666666576666666666666653300330037a730303300330000033000000330007660000000000665766666666666666576666660066666652020202000000000
76666655766666666666665503303030307000730330303000033000000000000000060000600000066666666666665076666666666666550202020200000000
76666565766666666666656503000303030307a73000030000300300000000005555000660005555066666666666656076666666666665652020202000000000
76565655766666565656565500030303003700730303030000300030000000000666005656006660066666565656565076666656565656550202020200000000
75656555766565656565655500033000337a73003303300003000030000000000000056565600000066565656565655076656565656565552020202000000000
05555550055555555555555000000303003700030300000003000030000000000600555555550060000005555550000005555555555555500202020200000000
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
00005550000000500500005003000000000000000200002002000020000000004999400004999940000004999999994000000000004999999940000000000000
00057575000005750555555038300000000000000200002002000020000000499222999999222299940049222222229999940004999200000024000011111011
00575765000057555555555503000000000000000222222002222220000000922222222222222222299992222242222222299999222000000222900011111011
05765657000055755655556500000000000000000202202002022020000000922244422224444222222222244444444442222222200000002222940011111011
57657656000575655565565500000000000000000022220000222200000004922442444244242422442224444444424444224222000000222222294000000000
56656556000565655555555500000000000000000002200000022000000049224244442444422444242440004444444444444420000022222222229410111111
05555005000565500555555000000000000000002200000000000022004992244444444444444424444420f40242244224244200000222244222222910111111
00000000000055000055550000000000000000000000002222000000009222424424444444244444424222222444442242442200002222222222222910111111
00000000000000000001100000000000000110008888800088882000049224444244424444444442444424244240000004422000022222222222442900000000
00000000000000bb001100000001000000110000888820008882000009224244444444440000444444244244240f444204242000202020202222222911111000
000000bb00000baa017100000011000001710000888200008882000009224444442444440f420444000000444404040202420002200000002222222911111000
0000bbaa0000baaa01710000017100000171000088820000888200000924444444444444042204440f4442024204422204220002220f42022222222911111000
000baaaa0000baaa1761000017610000176100008882000088820000094244404444444442222244040202042442222222420002220402022222229400000000
00baaaaa000baaaa1761000016610011176100008888200088882000092444020442444442444444422222224424444444400000000442022244229010000000
0baaaaaa000baaaa1661001116651122166100118888820088888200090000020444442424244444444444444244424444042424040202044222229010000000
0baaaaaa00baaaaa166511221655222216651122282288002822880049f420222044444442224000444244244442444440424240444222224422229010000000
aaaaaaabaaaadb0022225561222225512222556100000088002200889f0000000044444442420f20444440400444444420000000444444440022229000000000
aaaaaadbaaaddb002222255122222211222225510000088800220888940f4444204424424220f420442400020424424220002220004444000022229400011111
aaaadddbdddddb00222222112222221022222211220008880088088890044220200444242422222244440f204242222200022200000000000002222900011111
dddddddbddddbb0022222210200221002222221022000888008808889442222222244444002442442440f4202220000000022200000002000002222900011111
ddddddbbddddbb0022022210222221002022221088800288008882889044044444444220f2022244442040200000000000222000020000000202442900000000
ddddbbbbdddbbb002002210022221000220221008888882800888828944040404404444044204242442044200000000002442002000000200002222900000001
bbbbbbb0bbbbb0002222210022221000222221000888882800088828494424442444242422222424220040200000222422222004000020002000222900000001
bbbbb000bbb000002222100022221000222210000088888200088882092444424424422442224242000044202224244442220000000000000000222900000001
00111100001111102222100022221000222210008888800088882000094242444244444442424420000020202242444422222220000000000222222900000000
01222210012222712222100020221000222210008888200088820000092224424424424222222200000222224024244222244222222222222222222911011111
01222221122222112221000022210000222100008882000088820000900002222244242200000000022242440444444422222222222222222222229411011111
12222171122221002021000022110000202100008882000088200000900000000222220000000000224444444400004222222222222244222224429011011111
122221111222271020210000111000002021000088820000882000009000000000000000000000022424244240f4204222222222222222222222229000000000
12117100122221102221000011000000222100008820000082000000490000000000000999900022424444404022204422999999992222222222222911111101
17101100012227102210000000000000221000008200000082000000049999900000099400499224999944240999949999440000049999999999222911111101
01100000001111101100000000000000110000002000000020000000000000499999900000004999400099999400000000000000000000000044999411111101
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
86868686868686868686868686868686868686868686868686864040405151515700605151515151570000004040406051515151574040000000000042000000404040404040404062430060626186868686868686868686868686868686868686868686400000000000000000000000cfdf000000000000000000000000efff
86868686868686868686868686868686868686868686868686864040405162000000000000565151570000004040406051515151574040000000004200000000404040404040404051474356516186868686868686868686868686868686868686868686400000000000000000000000cfdf000000000000000000000000efff
86868686868686868485868686868686868686868686868686864040406200000000004662000000000000004040405751515756514040000000420000000000404040404040404062604743566186868686868686868686868686868686868684858686400000000000000000000000cfdf000000000000000000000000efff
86868686868686869495868686868686a082838686a0828386864040406200000060515151470000000060624040405151514700604040004040404040544c404040404040404040404040404040838686a0828386868686868686868686868694958686400000000000000000000000cfdf0000a58788898a8b8c8d0000efff
8182838686a082838686a082838686a0b092938081b09293808140404040405444404040404045554040404040404060576051475640000000000000004240404040404040404040404040404040938081b092938081838686a082838686a08283a08283400000000000000000000000cfdf00ae969798999a9b9c9daf00efff
9192938081b092938081b092938081b000000090910000009091926100000042465140404051474300005657404040606200565700400000000000004200404040404040404040404040404040400090910000009091938081b092938081b09293b09293400000000000000000000000cfdf00bea6a7a8a9aaabacadbf00efff
00000090910000009192000000919200000000000000000000000061000042465157404040626047430000515740605151620000004000000000004200004040404040404040405140564040404000000000000000000090910000009091000000000000400000000000000000000000cfdf0000b6b7b8b9babbbcbd0000efff
00000000000000000000000000000000000000000000000000000061004200606246404040515151474300565161605760570060474000000000420000004040404040404040405762004062404000000000000000000000000000000000000000000000400000000000000000000000cfdf000000000000000000000000efff
00000000000000000000000000000000000000000000000000004040404040544440404040404060514743005661565151570040404040404040404040404040404040404040005651574060404000000000000000000000000000000000000000000000400000000000000000000000cfdf000000000000000000000000efff
000000000000000000464e0000000000000000000000000000000061516200424640404040404062605147430061006057000040404040404040404040404040404040404040470057006256404000000000000000004e00000000000000000000000060400000000000000000000000cfdf000000000000000000000000efff
65000000636500000060610000000063644040404040000000006361570042465140404040404040404141414040414040454141414140404140404041414140404040404040620000625647404000004651624e0000616062000000000000004e006051400000000000000000000000cfdf000000000000000000000000efff
646500636461624662516100000063646461000000616465006364616242466256404040404040404053535340615340535343535353535353534053535353534040404040405147465147564040004e605151610000615151514e000000000061515151400000000000000000000000cfdf000000000000000000000000efff
41414141717271727172717241414141416100000061414141414141414141414141414141414040400000004061004000000043000000000000000000000000004040404040414141414141404041415444404041414041404040414141414140404140400000000000000000000000cfdf000000000000000000000000efff
53535353535353535353535353535353536100000061535353535300535353535353535353404040400000404061404000404000430000000000000000000000004040404040535353535353404053534253535353535353535353535353535353535353400000000000000000000000cfdf000000000000000000000000efff
4086404051626100000000616051404086000000000000000000000000000000000000000000000000000000000000000040400000430000000000000073646474646464746464750000000000000042004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4086404051626100000000616051404086007e7e7e007e007e00000000007e7e7e007e007e00007e7e007e007e0000000040406500004300000000000000746464647464647576000000000000004200004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4086404056516100000000614756404086007e007e007e007e00000000007e7e7e007e007e007e0000007e007e0000000040406465000043000000000000736464646464750076000000000000420000004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4086404047566100000000615147404086007e7e00007e7e7e00000000007e007e007e007e00007e00007e7e7e0000000040404045554040400000000000007664747576000077000000000042000000004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4086404051626100000000616251404086007e007e0000007e00000000007e007e007e007e0000007e007e007e0000000040400000430000000000000000007773750076000000000040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4086404051516100000000616057404081007e7e7e007e7e7e00000000007e007e00007e7e007e7e00007e007e0000000040406500004300000000000000000000000076000000000000404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4080404062606100000000615746404091000000000000000000000000000000000000000000000000000000000000000040406464650043000000000000000000000077000000000000004040006100006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0090404062006100000000614662404000000000000000000000000000000000000000000000000000000000000000000040404040404040404000000000000000000000000000000000004040006100006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000404051626100000000615157404000000000000000000000007e007e0000000000000000000000000000000000000040400061006100610000000000000000000000000000000000004040006100006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000404051626100000000616047404000000000000000000000000000000000000000000000000000000000000000000040406561006165610000000000000000000000000000000000004040006100006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40404040626261000000006160514040400000000000000000007e0000007e00000000000000000000000000000000000040406461636164616500000000000000000000000000000000634040006100006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404054444040404040404555404040000000000000000000007e7e7e0000000000000000000000000000000000000040406461646164616465006365000000636500000000006364644040006100006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040000042000000565157565743565140000000000000000000000000000000000000000000000000000000000000000040404141414141414141414141000041414100004141414141414040006100006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040004200000000465746576057436040000000000000000000000000000000000000000000000000000000000000000048484848484848484848484848585848484858584848484848484848484848484848000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010a00002105021030210402103023040230302404024030210502103021040210302304023030240402403023050230301f0401f0301f0401f0301c0401c0302104021040210402104021040210302102221012
010a00002105021030210402103023040230302404024030210502103021040210302304023030240402403026050260302304023030290402903028040280302404024040240322402226040260302804028030
010a0000290502903024040240302b0402b0302d0402d0302b0502b0502b0502b0502b0402b0322b0222b0122c0502c03028040280302d0402d0302f0402f030300503004030032300322d0402d0302f0402f030
010a0000300503003030040300302f0402f0302d0402d0302c0402c0302804028030280402803028040280302905029030280402803026040260302404024030230502304023030230221f0401f0401f0321f022
010a0000150301503015020150101c0301c0301c0201c010180301803018020180101503015030150201501017030170301703017030170301703017020170101503015030150301503015030150301502015010
010a0000150301503015020150101c0301c0301c0201c010180301803018020180101503015030150201501017030170301703017030170301703017020170101c0301c0301c0301c0301c0301c0301c0201c010
010a00001d0301d0301d0201d0101c0301c0301c0201c010180301803018020180101703017030170201701015030150301502015010140301403014020140101103011030110201101010030100301001010020
010a0000180301803018020180101503015030150201501015030150301502015010100301003010020100101403014030140301403014030140301402014010100301003010020100100b0300b0300b0200b010
000600000925009250092500c2500f2501025011250112501125011250102500e2500c2500b2500b2500b25009250082500825008200082300820008220082000820008210006000060000600006000060000600
011000001a1251a1251c1351c1351d1451d1451f1551f1551a1551a1551c1551c1551d1551d1551f1551f15521155211551f1551f155211552115524155241551d1551d1551d1551d1551a1551a1451a1351a125
011000001a0351c0451e055210551a0551c0551e055210551f0551c05519055150551f0551c055190551505517055190551a0551c0551a0551c0551e055210551f05521055230552505526045260352602526015
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
01 2e324344
00 2f334344
00 30344344
02 31354344
02 36424344
04 37424344
04 38424344
