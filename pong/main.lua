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

VIRTUAL_WIDTH,  VIRTUAL_HEIGHT  = 640, 360
WINDOW_WIDTH,   WINDOW_HEIGHT   = 1280, 720

PADDLE_W, PADDLE_H  = 6, 42
BALL_RADIUS         = 4
PADDLE_SPEED        = 160          -- px/s
SERVE_SPEED         = 140          -- initial ball speed

push = require "push"

-- LÖVE 12 deprecation bypass
local major = love.getVersion()
if major > 11 then love.setDeprecationOutput(false) end

local keysDown = {}
local serveDirection = nil -- 'left' or 'right', nil for random at start
local ballSpeed = SERVE_SPEED
local gameState = 'start' -- 'start', 'serve', 'play', 'done'
local winner = nil

function love.keypressed(k)
    if k == 'escape' then
        love.event.quit()
    end

    keysDown[k] = true
    if (k == 'return' or k == 'enter') and (gameState == 'start' or gameState == 'serve') then
        gameState = 'play'
        serveBall()
    elseif (k == 'r') and gameState == 'done' then
        lScore, rScore = 0, 0
        winner = nil
        gameState = 'start'
        serveDirection = nil
        ballSpeed = SERVE_SPEED
        serveBall()
    end
end

function love.keyreleased(k) keysDown[k] = false end
function held(k) return keysDown[k] end
function clamp(val, min, max) return math.max(min, math.min(max, val)) end

local world, ballBody, ballShape, ballFix
local lPadBody, rPadBody, padShape
local lScore, rScore = 0, 0

function love.load()
    love.window.setTitle("Pong (Box2D demo)")
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { vsync = true, resizable = true })
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })
    math.randomseed(os.time())

    love.physics.setMeter(32)            -- 1 m = 32 px
    world = love.physics.newWorld(0, 0)  -- no gravity; top‑down plane

    -- static top and bottom walls (edge shapes)
    local top    = love.physics.newBody(world, 0, 0, "static")
    local bottom = love.physics.newBody(world, 0, VIRTUAL_HEIGHT, "static")
    local edgeT  = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH, 0)
    local edgeB  = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH, 0)
    edgeTFix     = love.physics.newFixture(top,    edgeT)
    edgeBFix     = love.physics.newFixture(bottom, edgeB)

    -- increase speed over time, but disallow angular influence
    edgeTFix:setRestitution(1.01)
    edgeTFix:setFriction(0)
    edgeBFix:setRestitution(1.01)
    edgeBFix:setFriction(0)

    -- paddles (kinematic)
    padShape  = love.physics.newRectangleShape(PADDLE_W, PADDLE_H)
    lPadBody  = love.physics.newBody(world, 20, VIRTUAL_HEIGHT / 2, "kinematic")
    rPadBody  = love.physics.newBody(world, VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT / 2, "kinematic")
    lPadFix   = love.physics.newFixture(lPadBody, padShape)
    rPadFix   = love.physics.newFixture(rPadBody, padShape)
    
    -- paddles increase speed over time and influence angle on ball
    lPadFix:setFriction(0.9)
    lPadFix:setRestitution(1.01)
    rPadFix:setFriction(0.9)
    rPadFix:setRestitution(1.01)

    -- ball (dynamic)
    ballShape = love.physics.newCircleShape(BALL_RADIUS)
    ballBody  = love.physics.newBody(world, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, "dynamic")
    ballFix   = love.physics.newFixture(ballBody, ballShape, 1)
    
    -- ball preserves speed and angle but has friction to be manipulated by paddles
    ballFix:setRestitution(1)
    ballFix:setFriction(0.6)
    ballBody:setLinearDamping(0)

    serveDirection = nil
    ballSpeed = SERVE_SPEED
    gameState = 'start'
    winner = nil
    serveBall()
end

function serveBall()
    -- reset ball to center
    ballBody:setPosition(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2)
    ballBody:setLinearVelocity(0, 0)
    
    -- precompute next angle based on winner or random at start
    local angle
    if serveDirection == 'left' then
        angle = math.rad(math.random(150, 210))
    elseif serveDirection == 'right' then
        angle = math.rad(math.random(-30, 30))
    else
        -- random at start
        if math.random() < 0.5 then
            angle = math.rad(math.random(-30, 30))
            serveDirection = 'right'
        else
            angle = math.rad(math.random(150, 210))
            serveDirection = 'left'
        end
    end
    ballBody:setLinearVelocity(
        math.cos(angle) * ballSpeed, math.sin(angle) * ballSpeed)
end

function love.update(dt)
    if gameState == 'play' then
        -- paddle controls
        local vyL = 0
        if held("w")   then vyL = vyL - PADDLE_SPEED end
        if held("s")   then vyL = vyL + PADDLE_SPEED end
        lPadBody:setLinearVelocity(0, vyL)

        local vyR = 0
        if held("up")   then vyR = vyR - PADDLE_SPEED end
        if held("down") then vyR = vyR + PADDLE_SPEED end
        rPadBody:setLinearVelocity(0, vyR)

        world:update(dt)

        -- clamp paddles within screen
        local halfPad = PADDLE_H / 2
        lPadBody:setY(clamp(lPadBody:getY(), halfPad, VIRTUAL_HEIGHT - halfPad))
        rPadBody:setY(clamp(rPadBody:getY(), halfPad, VIRTUAL_HEIGHT - halfPad))

        -- scoring: check if ball passed paddles
        local bx = ballBody:getX()
        if bx < 0 then
            rScore = rScore + 1
            if rScore >= 10 then
                winner = 2
                gameState = 'done'
            else
                serveDirection = 'right' -- serve toward player who just scored (Player 2)
                ballSpeed = ballSpeed * 1.08 -- speed up
                gameState = 'serve'
                serveBall()
            end
        elseif bx > VIRTUAL_WIDTH then
            lScore = lScore + 1
            if lScore >= 10 then
                winner = 1
                gameState = 'done'
            else
                serveDirection = 'left' -- serve toward player who just scored (Player 1)
                ballSpeed = ballSpeed * 1.08
                gameState = 'serve'
                serveBall()
            end
        end
    else
        -- freeze paddles and ball
        lPadBody:setLinearVelocity(0, 0)
        rPadBody:setLinearVelocity(0, 0)
        ballBody:setLinearVelocity(0, 0)
    end
end

function love.draw()
    push.start()

    -- center line
    love.graphics.setColor(1, 1, 1, 0.2)
    for y = 0, VIRTUAL_HEIGHT, 15 do
        love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 1, y, 2, 10)
    end

    -- paddles
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("fill", lPadBody:getWorldPoints(padShape:getPoints()))
    love.graphics.polygon("fill", rPadBody:getWorldPoints(padShape:getPoints()))

    -- ball
    love.graphics.circle("fill", ballBody:getX(), ballBody:getY(), BALL_RADIUS)

    -- score
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(lScore .. "   " .. rScore, 0, 10, VIRTUAL_WIDTH, "center")

    -- instructions and win message
    love.graphics.setFont(love.graphics.newFont(16))
    if gameState == 'start' then
        love.graphics.printf("Press Enter to serve!", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, "center")
    elseif gameState == 'serve' then
        love.graphics.printf("Press Enter to serve!", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, "center")
    elseif gameState == 'done' then
        love.graphics.setFont(love.graphics.newFont(32))
        love.graphics.printf("Player " .. winner .. " wins!", 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.printf("Press R to restart", 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, "center")
    end

    push.finish()
end