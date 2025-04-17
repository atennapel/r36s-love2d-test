local ScreenManager = require("ui/ScreenManager")
local BaseScreen = require("ui/screens/BaseScreen")

local screenManager = ScreenManager.new()

function love.load()
  love.graphics.setNewFont("font.otf", 12)

  screenManager:push(BaseScreen.new())
end

function love.keypressed(k, s, r)
  screenManager:keypressed(k, s, r)
end

function love.keyreleased(k, s)
  screenManager:keyreleased(k, s)
end

function love.update(dt)
  screenManager:update(dt)
end

function love.draw()
  screenManager:draw()
end