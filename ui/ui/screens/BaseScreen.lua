local KeyboardScreen = require("ui/screens/KeyboardScreen")

local BaseScreen = {
  updateInBackground = false,
  drawInBackground = true,
  fullscreen = true,
}
BaseScreen.__index = BaseScreen

function BaseScreen.new()
  local self = setmetatable({}, BaseScreen)
  self.text = ""
  return self
end

function BaseScreen:keypressed(_, sc)
  if sc == "k" then
    self.screenManager:push(KeyboardScreen.new(self.text, function(text)
      self.screenManager:pop()
      self.text = text or self.text
    end))
  end
end

function BaseScreen:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(self.text, 10, 10)
end

return BaseScreen