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

require 'src/Dependencies'

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Angry 50')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end
    }
    gStateMachine:change('start')

    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    love.keyboard.keysPressed = {}
    love.mouse.keysPressed = {}
    love.mouse.keysReleased = {}

    paused = false
end

function push.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'p' then
        paused = not paused
    end

    love.keyboard.keysPressed[key] = true
end

function love.mousepressed(x, y, key)
    love.mouse.keysPressed[key] = true
end

function love.mousereleased(x, y, key)
    love.mouse.keysReleased[key] = true 
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.mouse.wasPressed(key)
    return love.mouse.keysPressed[key]
end

function love.mouse.wasReleased(key)
    return love.mouse.keysReleased[key]
end

function love.update(dt)
    if not paused then
        gStateMachine:update(dt)

        love.keyboard.keysPressed = {}
        love.mouse.keysPressed = {}
        love.mouse.keysReleased = {}
    end
end

function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()
end