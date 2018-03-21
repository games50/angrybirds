--[[
    GD50
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BACKGROUND_TYPES = {
    'colored-land', 'blue-desert', 'blue-grass', 'blue-land', 
    'blue-shroom', 'colored-desert', 'colored-grass', 'colored-shroom'
}

Background = Class{}

function Background:init()
    self.background = BACKGROUND_TYPES[math.random(#BACKGROUND_TYPES)]
    self.width = gTextures[self.background]:getWidth()
    self.xOffset = 0
end

function Background:update(dt)
    if love.keyboard.isDown('left') then
        self.xOffset = self.xOffset + BACKGROUND_SCROLL_X_SPEED * dt
    elseif love.keyboard.isDown('right') then
        self.xOffset = self.xOffset - BACKGROUND_SCROLL_X_SPEED * dt
    end

    self.xOffset = self.xOffset % self.width
end

function Background:render()
    love.graphics.draw(gTextures[self.background], self.xOffset, -128)
    love.graphics.draw(gTextures[self.background], self.xOffset + self.width, -128)
    love.graphics.draw(gTextures[self.background], self.xOffset - self.width, -128)
end