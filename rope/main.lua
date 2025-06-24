--[[
    CS50 2D
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Released by Rovio in 2009, Angry Birds took the mobile gaming scene by storm back
    when it was still arguably in its infancy. Using the simple gameplay mechanic of
    slingshotting birds into fortresses of various materials housing targeted pigs,
    Angry Birds succeeded with its optimized formula for on-the-go gameplay. It's an
    excellent showcase of the ubiquitous Box2D physics library, the most widely used
    physics library of its kind, which is also open source. This "clone" of Angry Birds
    doesn't contain nearly the plethora of features as the original series of games
    it's based on but does use Box2D to showcase the fundamental setup of what the game
    looks like and how to use a subset of the physics library's features.

    Music credit:
    https://freesound.org/people/tyops/sounds/348166/

    Artwork credit:
    https://opengameart.org/content/physics-assets
]]

VIRTUAL_WIDTH,  VIRTUAL_HEIGHT = 640, 360
WINDOW_WIDTH,   WINDOW_HEIGHT  = 1280, 720

push = require "push"

if love.getVersion() > 11 then love.setDeprecationOutput(false) end

local METER            = 32
local ROPE_LENGTH_M    = 3
local BALL_RADIUS_PX   = 18
local BALL_DENSITY     = 4
local NUDGE_IMPULSE    = 120

local world
local anchorBody
local ballBody
local ropeJoint
local maxLen = ROPE_LENGTH_M * METER

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Revolute Joint Pendulum")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { vsync = true, resizable = true })
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

    love.physics.setMeter(METER)
    world = love.physics.newWorld(0, 9.81 * METER)

    local anchorX, anchorY = VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60
    anchorBody = love.physics.newBody(world, anchorX, anchorY, "static")

    local ballX, ballY = anchorX, anchorY + ROPE_LENGTH_M * METER
    ballBody  = love.physics.newBody(world, ballX, ballY, "dynamic")

    local ballShape = love.physics.newCircleShape(BALL_RADIUS_PX)
    love.physics.newFixture(ballBody, ballShape, BALL_DENSITY)

    ropeJoint = love.physics.newRopeJoint(
                    anchorBody, ballBody,
                    anchorX, anchorY,        -- world‑space rope point
                    ballBody:getX(), ballBody:getY(),
                    maxLen,
                    false)                   -- collideConnected
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end

    -- push the ball sideways with impulses
    if key == "left"  then ballBody:applyLinearImpulse(-NUDGE_IMPULSE, 0) end
    if key == "right" then ballBody:applyLinearImpulse( NUDGE_IMPULSE, 0) end
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    push.start()

    -- draw rope
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setLineWidth(3)
    love.graphics.line(anchorBody:getX(), anchorBody:getY(),
                       ballBody:getX(),   ballBody:getY())

    -- draw anchor
    love.graphics.setColor(0.9, 0.6, 0.2)
    love.graphics.circle("fill", anchorBody:getX(), anchorBody:getY(), 6)

    -- draw ball
    love.graphics.setColor(0.3, 0.7, 1)
    love.graphics.circle("fill", ballBody:getX(), ballBody:getY(), BALL_RADIUS_PX)

    -- instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("left/right = nudge", 10, 10)

    push.finish()
end

function push.resize(w, h) push.resize(w, h) end