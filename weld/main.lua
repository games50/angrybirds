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

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Weld Joint Demo')
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { vsync = true, resizable = true })
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

    love.physics.setMeter(32)
    world = love.physics.newWorld(0, 9.81 * 32)

    groundBody  = love.physics.newBody(world, 0, VIRTUAL_HEIGHT - 30, "static")
    groundShape = love.physics.newEdgeShape(-1000, 0, 1000, 0)
    love.physics.newFixture(groundBody, groundShape)

    local headW, headH = 80, 20
    local handleW, handleH = 20, 100
    local startX, startY = VIRTUAL_WIDTH / 2, 80

    headBody = love.physics.newBody(world, startX, startY, "dynamic")
    headShape= love.physics.newRectangleShape(headW, headH)
    love.physics.newFixture(headBody, headShape, 2)

    handleBody  = love.physics.newBody(world, startX, startY + headH / 2 + handleH / 2,
                                      "dynamic")
    handleShape = love.physics.newRectangleShape(handleW, handleH)
    love.physics.newFixture(handleBody, handleShape, 1)

    weld = love.physics.newWeldJoint(
              headBody, handleBody,
              startX, startY + headH / 2,
              false)

    PUSH_FORCE = 4000
end

function love.keypressed(k)
    if k == "escape" then love.event.quit() end
    if k == "left"  then headBody:applyForce(-PUSH_FORCE, 0) end
    if k == "right" then headBody:applyForce( PUSH_FORCE, 0) end
    if k == "b" and weld then
        weld:destroy()
        weld = nil
    end
end

function love.update(dt) world:update(dt) end

function love.draw()
    push.start()

    -- ground
    love.graphics.setColor(0.5, 0.4, 0.3)
    love.graphics.setLineWidth(3)
    love.graphics.line(groundBody:getWorldPoints(groundShape:getPoints()))

    -- head and handle
    love.graphics.setColor(0.3, 0.8, 1)
    love.graphics.polygon("fill", headBody:getWorldPoints(headShape:getPoints()))
    love.graphics.setColor(0.2, 0.6, 0.9)
    love.graphics.polygon("fill", handleBody:getWorldPoints(handleShape:getPoints()))

    -- anchor dot
    if weld then
        local ax, ay = weld:getAnchors()
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.circle("fill", ax, ay, 4)
    end

    love.graphics.setColor(1, 1, 1)
    local txt = weld and "B = break weld\nleft/right = push" or "Weld broken!"
    love.graphics.print(txt, 10, 10)

    push.finish()
end

function push.resize(w, h) push.resize(w, h) end