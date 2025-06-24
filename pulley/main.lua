--[[
    CS50 2D - Angry Birds (Pulley Demo, Interactive)
    Author: Colton Ogden (adapted for interactivity)
]]

VIRTUAL_WIDTH  = 640
VIRTUAL_HEIGHT = 360
WINDOW_WIDTH   = 1280
WINDOW_HEIGHT  = 720

push = require 'push'

if love.getVersion() > 11 then love.setDeprecationOutput(false) end

local world
local boxA, boxB, shapeA, shapeB
local pulley
local FORCE = 4000

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('pulley')
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, vsync = true, resizable = true
    })
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    world = love.physics.newWorld(0, 300)

    local boxW, boxH = 40, 40
    local densityA, densityB = 2, 1
    local startY = VIRTUAL_HEIGHT / 2

    -- left (heavier) box
    boxA = love.physics.newBody(world, VIRTUAL_WIDTH / 2 - 120, startY, 'dynamic')
    shapeA = love.physics.newRectangleShape(boxW, boxH)
    love.physics.newFixture(boxA, shapeA, densityA)

    -- right (lighter) box
    boxB = love.physics.newBody(world, VIRTUAL_WIDTH / 2 + 120, startY - 60, 'dynamic')
    shapeB = love.physics.newRectangleShape(boxW, boxH)
    love.physics.newFixture(boxB, shapeB, densityB)

    -- pulley joint
    local gx1, gy1 = boxA:getX(), 60
    local gx2, gy2 = boxB:getX(), 60
    pulley = love.physics.newPulleyJoint(
        boxA, boxB,
        gx1, gy1, gx2, gy2,
        boxA:getX(), boxA:getY(),
        boxB:getX(), boxB:getY(),
        1.0, false)
end

function love.update(dt)
    if love.keyboard.isDown('w') then
        boxA:applyForce(0, -FORCE)
    elseif love.keyboard.isDown('s') then
        boxA:applyForce(0, FORCE)
    end
    if love.keyboard.isDown('up') then
        boxB:applyForce(0, -FORCE)
    elseif love.keyboard.isDown('down') then
        boxB:applyForce(0, FORCE)
    end
    world:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit() end
end

function push.resize(w, h) push.resize(w, h) end

function love.draw()
    push.start()
    love.graphics.setLineWidth(2)

    -- ropes
    local g1x, g1y, g2x, g2y = pulley:getGroundAnchors()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.line(g1x, g1y, boxA:getX(), boxA:getY())
    love.graphics.line(g2x, g2y, boxB:getX(), boxB:getY())

    -- boxes
    love.graphics.setColor(0.3, 0.6, 1.0, 1)
    love.graphics.polygon('fill', boxA:getWorldPoints(shapeA:getPoints()))
    love.graphics.setColor(1.0, 0.6, 0.3, 1)
    love.graphics.polygon('fill', boxB:getWorldPoints(shapeB:getPoints()))

    -- ceiling pulleys
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.circle('fill', g1x, g1y, 6)
    love.graphics.circle('fill', g2x, g2y, 6)

    -- instructions
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf('W/S: move left box\nUp/Down: move right box', 0, 10, VIRTUAL_WIDTH, 'center')
    push.finish()
end