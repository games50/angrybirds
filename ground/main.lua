--[[
    GD50
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

VIRTUAL_WIDTH = 640
VIRTUAL_HEIGHT = 360

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

push = require 'push'

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('ground')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- new Box2D "world" which will run all of our physics calculations
    world = love.physics.newWorld(0, 300)

    -- body that stores velocity and position and all fixtures
    boxBody = love.physics.newBody(world, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 'dynamic')

    -- shape that we will attach using a fixture to our body for collision detection
    boxShape = love.physics.newRectangleShape(10, 10)

    -- fixture that attaches a shape to our body
    boxFixture = love.physics.newFixture(boxBody, boxShape)
    boxFixture:setRestitution(0.5)

    -- static ground body
    groundBody = love.physics.newBody(world, 0, VIRTUAL_HEIGHT - 30, 'static')

    -- edge shape Box2D provides, perfect for ground
    edgeShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH, 0)

    -- affix edge shape to our body
    groundFixture = love.physics.newFixture(groundBody, edgeShape)
end

function push.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    
    -- update world, calculating collisions
    world:update(dt)
end

function love.draw()
    push:start()
    
    -- draw a polygon shape by getting the world points for our body, using the box shape's
    -- definition as a reference
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.polygon('fill', boxBody:getWorldPoints(boxShape:getPoints()))

    -- draw a line that represents our ground, calculated from ground body and edge shape
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(groundBody:getWorldPoints(edgeShape:getPoints()))

    push:finish()
end