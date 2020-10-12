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

DEGREES_TO_RADIANS = 0.0174532925199432957
RADIANS_TO_DEGREES = 57.295779513082320876

push = require 'push'

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('kinematic')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- new Box2D "world" which will run all of our physics calculations
    world = love.physics.newWorld(0, 300)

    -- static ground and wall bodies
    groundBody = love.physics.newBody(world, 0, VIRTUAL_HEIGHT - 30, 'static')
    leftWallBody = love.physics.newBody(world, 0, 0, 'static')
    rightWallBody = love.physics.newBody(world, VIRTUAL_WIDTH, 0, 'static')

    -- edge shape Box2D provides, perfect for ground and walls
    edgeShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH, 0)
    wallShape = love.physics.newEdgeShape(0, 0, 0, VIRTUAL_HEIGHT)

    -- affix edge shape to our body
    groundFixture = love.physics.newFixture(groundBody, edgeShape)
    leftWallFixture = love.physics.newFixture(leftWallBody, wallShape)
    rightWallFixture = love.physics.newFixture(rightWallBody, wallShape)

    -- body to fall into the pit
    personBody = love.physics.newBody(world, math.random(VIRTUAL_WIDTH), 0, 'dynamic')
    personShape = love.physics.newRectangleShape(30, 30)
    personFixture = love.physics.newFixture(personBody, personShape, 20)

    -- table holding dynamic bodies (balls)
    dynamicBodies = {}
    dynamicFixtures = {}
    ballShape = love.physics.newCircleShape(5)

    for i = 1, 1000 do
        table.insert(dynamicBodies, {
            love.physics.newBody(world, 
                math.random(VIRTUAL_WIDTH), math.random(VIRTUAL_HEIGHT - 30), 'dynamic'),
            r = math.random(255) / 255,
            g = math.random(255) / 255,
            b = math.random(255) / 255
        })
        table.insert(dynamicFixtures, love.physics.newFixture(dynamicBodies[i][1], ballShape))
    end
end

function push.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'space' then
        personBody:setPosition(math.random(VIRTUAL_WIDTH), 0)
    end
end

function love.update(dt)
    
    -- update world, calculating collisions
    world:update(dt)
end

function love.draw()
    push:start()

    -- draw a line that represents our ground, calculated from ground body and edge shape
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(groundBody:getWorldPoints(edgeShape:getPoints()))

    -- render ball pit
    for i = 1, #dynamicBodies do
        love.graphics.setColor(
            dynamicBodies[i].r, dynamicBodies[i].g, dynamicBodies[i].b, 1
        )
        love.graphics.circle('fill', 
            dynamicBodies[i][1]:getX(),
            dynamicBodies[i][1]:getY(),
            ballShape:getRadius()
        )
    end

    -- render "person" falling in
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.polygon('fill', personBody:getWorldPoints(personShape:getPoints()))

    push:finish()
end