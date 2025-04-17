local PopupScreen = {
  updateInBackground = false,
  drawInBackground = true,

  width = 400,
  height = 300,
  border = true,
  centered = true,
}
PopupScreen.__index = PopupScreen

function PopupScreen.new()
  local self = setmetatable({}, PopupScreen)
  return self
end

function PopupScreen:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("popup", 10, 10)
end

return PopupScreen