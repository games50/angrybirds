--[[
    GD50
    Angry Birds
    
    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

require 'src/Alien'
require 'src/AlienLaunchMarker'
require 'src/Background'
require 'src/constants'
require 'src/Level'
require 'src/Obstacle'
require 'src/StateMachine'
require 'src/Util'

require 'src/states/BaseState'
require 'src/states/PlayState'
require 'src/states/StartState'

gTextures = {
    -- backgrounds
    ['blue-desert'] = love.graphics.newImage('graphics/blue_desert.png'),
    ['blue-grass'] = love.graphics.newImage('graphics/blue_grass.png'),
    ['blue-land'] = love.graphics.newImage('graphics/blue_land.png'),
    ['blue-shroom'] = love.graphics.newImage('graphics/blue_shroom.png'),
    ['colored-land'] = love.graphics.newImage('graphics/colored_land.png'),
    ['colored-desert'] = love.graphics.newImage('graphics/colored_desert.png'),
    ['colored-grass'] = love.graphics.newImage('graphics/colored_grass.png'),
    ['colored-shroom'] = love.graphics.newImage('graphics/colored_shroom.png'),

    -- aliens
    ['aliens'] = love.graphics.newImage('graphics/aliens.png'),

    -- tiles
    ['tiles'] = love.graphics.newImage('graphics/tiles.png'),

    -- wooden obstacles
    ['wood'] = love.graphics.newImage('graphics/wood.png'),

    -- arrow for trajectory
    ['arrow'] = love.graphics.newImage('graphics/arrow.png')
}

gFrames = {
    ['aliens'] = GenerateQuads(gTextures['aliens'], 35, 35),
    ['tiles'] = GenerateQuads(gTextures['tiles'], 35, 35),

    ['wood'] = {
        love.graphics.newQuad(0, 0, 110, 35, gTextures['wood']:getDimensions()),
        love.graphics.newQuad(0, 35, 110, 35, gTextures['wood']:getDimensions()),
        love.graphics.newQuad(320, 180, 35, 110, gTextures['wood']:getDimensions()),
        love.graphics.newQuad(355, 355, 35, 110, gTextures['wood']:getDimensions())
    }
}

gSounds = {
    ['break1'] = love.audio.newSource('sounds/break1.wav'),
    ['break2'] = love.audio.newSource('sounds/break2.wav'),
    ['break3'] = love.audio.newSource('sounds/break3.mp3'),
    ['break4'] = love.audio.newSource('sounds/break4.wav'),
    ['break5'] = love.audio.newSource('sounds/break5.wav'),
    ['bounce'] = love.audio.newSource('sounds/bounce.wav'),
    ['kill'] = love.audio.newSource('sounds/kill.wav'),

    ['music'] = love.audio.newSource('sounds/music.wav')
}

gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
    ['huge'] = love.graphics.newFont('fonts/font.ttf', 64)
}

-- tweak circular alien quad
gFrames['aliens'][9]:setViewport(105.5, 35.5, 35, 34.2)