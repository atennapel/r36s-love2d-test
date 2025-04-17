local ScreenManager = {
  width = 640,
  height = 480,
}
ScreenManager.__index = ScreenManager

function ScreenManager.new()
  local self = setmetatable({}, ScreenManager)
  self.stack = {}
  return self
end

function ScreenManager:push(screen)
  screen.screenManager = self
  table.insert(self.stack, screen)
end

function ScreenManager:pop()
  return table.remove(self.stack)
end

function ScreenManager:keypressed(key, scancode, isRepeat)
  local stack = self.stack
  local size = #stack
  if size == 0 then return end
  local screen = stack[size]
  if screen.keypressed then
    screen:keypressed(key, scancode, isRepeat)
  end
end

function ScreenManager:keyreleased(key, scancode)
  local stack = self.stack
  local size = #stack
  if size == 0 then return end
  local screen = stack[size]
  if screen.keyreleased then
    screen:keyreleased(key, scancode)
  end
end

function ScreenManager:update(dt)
  local stack = self.stack
  local size = #stack
  if size == 0 then return end
  for i = 1, size do
    local screen = stack[i]
    if screen.update and (i == size or screen.updateInBackground) then
      screen:update(dt)
    end
  end
end

function ScreenManager:drawScreen(screen)
  love.graphics.push()
  if screen.fullscreen then
    screen:draw()
  else
    if screen.border then
      love.graphics.setColor(1, 1, 1)
      local w, h = screen.width, screen.height
      local x, y = screen.x, screen.y
      if screen.centered then
        x = (self.width - w) / 2
        y = (self.height - h) / 2
      end
      love.graphics.translate(x, y)
      if screen.border then
        love.graphics.rectangle("line", 0, 0, w, h)
      end
      screen:draw()
    end
  end
  love.graphics.pop()
end

function ScreenManager:draw()
  local stack = self.stack
  local size = #stack
  if size == 0 then return end
  local top = stack[size]
  if top.fullscreen then
    self:drawScreen(top)
  else
    for i = 1, size do
      local screen = stack[i]
      if i == size or screen.drawInBackground then
        self:drawScreen(screen)
      end
    end
  end
end

return ScreenManager