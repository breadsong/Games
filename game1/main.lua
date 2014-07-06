require "player/Player"
require "player/SpriteAnimation"
require "camera"
local sti = require "sti"

function love.load()
    g = love.graphics
    width = g.getWidth()
    height = g.getHeight()
    g.setBackgroundColor(85, 85, 85)
    groundColor = {25, 200, 25}
    trunkColor = {139, 69, 19}

    -- Load map
    loader = require("AdvTiledLoader.Loader")
    loader.path = "maps/"
    map = loader.load("map01.tmx")
    map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)
 
    -- restrict the camera
    camera:setBounds(0, 0, map.width * map.tileWidth - width, map.height * map.tileHeight - height)
 
    -- Load player animation
    animation = SpriteAnimation:new("player/robosprites.png", 32, 32, 4, 4)
    animation:load(delay)

    -- instantiate our player and set initial values
    
    p = Player:new()
   
    p.x = 300
    p.y = 300
    p.width = 32
    p.height = 32
    p.jumpSpeed = -800
    p.runSpeed = 500
   
    gravity = 1800
    hasJumped = false
    delay = 120
    yFloor = 500
end
 
function love.update(dt)

    --map:update(dt)

    -- check controls
    if love.keyboard.isDown("right") then
        p:moveRight()
        animation:flip(false, false)
    end
    if love.keyboard.isDown("left") then
        p:moveLeft()
        animation:flip(true, false)
    end
    if love.keyboard.isDown("x") then
        p:jump()
    end
 
    -- update the player's position and check for collisions
    p:update(dt, gravity, map)

    --[[ stop the player when they hit the borders
    p.x = math.clamp(p.x, 0, width * 2 - p.width)
    if p.y < 0 then p.y = 0 end
    if p.y > yFloor - p.height then
        p:hitFloor(yFloor)
    end-
    --]]
 
    -- update the sprite animation
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
    animation:update(dt)

    -- restrict the camera
    camera:setBounds(0, 0, width, math.floor(height / 8))

    -- center the camera on the player
    camera:setPosition(math.floor(p.x - width / 2), math.floor(p.y - height / 2))
end
 
function love.draw()
    camera:set()
   
    -- round our x, y values
    local x, y = math.floor(p.x), math.floor(p.y)
   
    -- draw the map
    map:draw()
   
    -- draw the player
    animation:draw(x - p.width / 2, y - p.height / 2)
   
    camera:unset()
   
    -- debug information
    local tileX = math.floor(p.x / map.tileWidth)
    local tileY = math.floor(p.y / map.tileHeight)
   
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Player coordinates: ("..x..","..y..")", 5, 5)
    love.graphics.print("Current state: "..p.state, 5, 20)
    love.graphics.print("Current tile: ("..tileX..", "..tileY..")", 5, 35)
end


function love.resize(w, h)
    map:resize(w, h)
end

 
function love.keyreleased(key)
    if key == "escape" then
        love.event.push("quit")  -- actually causes the app to quit
    end
    if (key == "right") or (key == "left") then
        p:stop()
    end
    if (key == "x") then
        hasJumped = false
    end
end

function math.clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end