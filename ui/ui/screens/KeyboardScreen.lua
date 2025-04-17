local KeyboardScreen = {
  updateInBackground = false,
  drawInBackground = false,

  width = 192,
  height = 100,
  border = true,
  centered = true,
}
KeyboardScreen.__index = KeyboardScreen

local MAX_VISIBLE_TEXT = 23
local CHARS = {
  "1234567890-=",
  "qwertyuiop[]",
  "asdfghjkl;'\\",
  "zxcvbnm,./` ",
}
local SHIFTED_CHARS = {
  "!@#$%^&*()_+",
  "QWERTYUIOP{}",
  "ASDFGHJKL:\"|",
  "ZXCVBNM<>?~ ",
}

function KeyboardScreen.new(text, callback)
  local self = setmetatable({}, KeyboardScreen)
  self.text = text or ""
  self.callback = callback
  self.selectedX = 0
  self.selectedY = 0
  self.shifted = false
  return self
end

function KeyboardScreen:getChars()
  if self.shifted then return SHIFTED_CHARS else return CHARS end
end

function KeyboardScreen:keypressed(_, sc)
  if sc == "a" then
    if self.selectedX > 0 then
      self.selectedX = self.selectedX - 1
    end
  elseif sc == "d" then
    if self.selectedX < 11 then
      self.selectedX = self.selectedX + 1
    end
  end
  if sc == "w" then
    if self.selectedY > 0 then
      self.selectedY = self.selectedY - 1
    end
  elseif sc == "s" then
    if self.selectedY < 3 then
      self.selectedY = self.selectedY + 1
    end
  end
  if sc == "z" then
    local x = self.selectedX + 1
    local char = self:getChars()[self.selectedY + 1]:sub(x, x)
    self.text = self.text .. char
  end
  if sc == "lshift" then
    if #self.text > 0 then
      self.text = self.text:sub(1, #self.text - 1)
    end
  end
  if sc == "space" then
    self.text = self.text .. " "
  end
  if sc == "b" then
    self.shifted = not self.shifted
  end
  if sc == "return" then
    self.callback(self.text)
  elseif sc == "escape" then
    self.callback(nil)
  end
end

function KeyboardScreen:update(dt)
end

function KeyboardScreen:draw()
  love.graphics.setColor(1, 1, 1)
  
  local text = self.text
  local ltext = #text
  if ltext >= MAX_VISIBLE_TEXT then
    text = text:sub(ltext - MAX_VISIBLE_TEXT, ltext)
  end
  love.graphics.print(text, 10, 10)

  love.graphics.push()
  love.graphics.translate(0, 32)
  for i = 1, 4 do
    local row = self:getChars()[i]
    for j = 1, 12 do
      local char = row:sub(j, j)
      love.graphics.print(char, (j - 1) * 16 + 5, (i - 1) * 16 + 1)
    end
  end
  love.graphics.rectangle("line", self.selectedX * 16, self.selectedY * 16, 16, 16)
  love.graphics.pop()
end

return KeyboardScreen