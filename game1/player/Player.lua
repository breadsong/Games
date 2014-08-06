
-- A simple Player object for use in the Platformer game.
 
Player = {}
 
-- Constructor
function Player:new()
    -- define our parameters here
    local object = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    xSpeed = 0,
    ySpeed = 0,
    xSpeedMax = 800,
    ySpeedMax = 800,
    state = "",
    jumpSpeed = 0,
    runSpeed = 0,
    onFloor = false
    }
    setmetatable(object, { __index = Player })
    return object
end
 
-- Movement functions
function Player:jump()
    if self.onFloor then
        self.ySpeed = self.jumpSpeed
        self.onFloor = false
    end
end
 
function Player:moveRight()
    self.xSpeed = self.runSpeed
end
 
function Player:moveLeft()
    self.xSpeed = -1 * (self.runSpeed)
end
 
function Player:stop()
    self.xSpeed = 0
end
 
-- Do various things when the player hits a tile
function Player:collide(event)
    if event == "floor" then
        self.ySpeed = 0
        self.onFloor = true
    end
    if event == "ceiling" then
        self.ySpeed = 0
    end
end

--Update function
function Player:UPDATE_PLAYER(dt, gravity, map)
    -- check controls
    if love.keyboard.isDown("d") then
        p:moveRight()
        animation:flip(false, false)
    end
    if love.keyboard.isDown("a") then
        p:moveLeft()
        animation:flip(true, false)
    end
    if love.keyboard.isDown("w") then
        p:jump()
    end
 
    -- update the player's position and check for collisions
    self:updatepos(dt, gravity, map)

     
    -- update the sprite animation
    self:updateanim()
    --[[
    if (p.state == "stand") then
        animation:switch(1, 4, 200)
    end
    if (p.state == "moveRight") or (p.state == "moveLeft") then
        animation:switch(2, 4, 120)
    end
    if (p.state == "jump") or (p.state == "fall") then
        animation:reset()
        animation:switch(3, 1, 300)
    end
    --]]
    animation:update(dt)
end
 
-- update the player's position and check for collisions
function Player:updatepos(dt, gravity, map)
    local halfX = self.width / 2
    local halfY = self.height / 2
   
    -- apply gravity
    self.ySpeed = self.ySpeed + (gravity * dt)
   
    -- limit the player's speed
    self.xSpeed = math.clamp(self.xSpeed, -self.xSpeedMax, self.xSpeedMax)
    self.ySpeed = math.clamp(self.ySpeed, -self.ySpeedMax, self.ySpeedMax)

    -- calculate vertical position and adjust if needed
    local nextY = math.floor(self.y + (self.ySpeed * dt))

    if self.ySpeed < 0 then -- check upward
        if not(self:isColliding(map, self.x - halfX, nextY - halfY))
            and not(self:isColliding(map, self.x + halfX - 1, nextY - halfY)) then
            -- no collision, move normally
            self.y = nextY
            self.onFloor = false
        else
            -- collision, move to nearest tile border
            self.y = nextY + map.tileHeight - ((nextY - halfY) % map.tileHeight)
            self:collide("ceiling")
        end
    elseif self.ySpeed > 0 then -- check downward
        if not(self:isColliding(map, self.x - halfX, nextY + halfY))
            and not(self:isColliding(map, self.x + halfX - 1, nextY + halfY)) then
            -- no collision, move normally
            self.y = nextY
            self.onFloor = false
        else
            -- collision, move to nearest tile border
            self.y = nextY - ((nextY + halfY) % map.tileHeight)
            self:collide("floor")
        end
    end

    -- calculate horizontal position and adjust if needed
    local nextX = math.floor(self.x + (self.xSpeed * dt))
    if self.xSpeed > 0 then -- check right
        if not(self:isColliding(map, nextX + halfX, self.y - halfY))
            and not(self:isColliding(map, nextX + halfX, self.y + halfY - 1)) then
            -- no collision
            self.x = nextX
        else
            -- collision, move to nearest tile
            self.x = nextX - ((nextX + halfX) % map.tileWidth)
        end
    elseif self.xSpeed < 0 then -- check left
        if not(self:isColliding(map, nextX - halfX, self.y - halfY))
            and not(self:isColliding(map, nextX - halfX, self.y + halfY - 1)) then
            -- no collision
            self.x = nextX
        else
            -- collision, move to nearest tile
            self.x = nextX + map.tileWidth - ((nextX - halfX) % map.tileWidth)
        end
    end
   
    -- update the player's state
    self.state = self:getState()
end

-- update the sprite animation
function PLayer:updateanim()
    if (p.state == "stand") then
        animation:switch(1, 4, 200)
    end
    if (p.state == "moveRight") or (p.state == "moveLeft") then
        animation:switch(2, 4, 120)
    end
    if (p.state == "jump") or (p.state == "fall") then
        animation:reset()
        animation:switch(3, 1, 300)
    end
end


-- returns player's state as a string
function Player:getState()
    local myState = ""
    if self.onFloor then
        if self.xSpeed > 0 then
            myState = "moveRight"
        elseif self.xSpeed < 0 then
            myState = "moveLeft"
        else
            myState = "stand"
        end
    end
    if self.ySpeed < 0 then
        myState = "jump"
    elseif self.ySpeed > 0 then
        myState = "fall"
    end
    return myState
end


-- returns true if the coordinates given intersect a map tile
function Player:isColliding(map, x, y)
    -- get tile coordinates
    local layer = map.layers["Walls"]

    local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
   
    -- grab the tile at given point
    local tile = map("Walls")(tileX, tileY)
   
    -- return true if the point overlaps a solid tile
    return not(tile == nil)
end