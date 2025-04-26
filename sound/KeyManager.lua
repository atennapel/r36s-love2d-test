local KeyManager = {}
KeyManager.__index = KeyManager

local function initState()
  return {cooldown = 0, count = 0}
end

function KeyManager.new(delay, usedScancodes)
  local self = setmetatable({}, KeyManager)
  self.delay = delay or 0.05
  local keys = {}
  for i = 1, #usedScancodes do
    keys[usedScancodes[i]] = initState()
  end
  self.keys = keys
  self.keypressed = function() end
  self.keyreleased = function() end
  self.keytrigger = function() end
  return self
end

function KeyManager:superKeypressed(k, sc, r)
  if self.keys[sc] ~= nil then
    self.keys[sc] = initState()
  end
  self.keypressed(k, sc, r)
end

function KeyManager:init(love)
  love.keypressed = function(k, sc, r)
    self:superKeypressed(k, sc, r)
  end
  love.keyreleased = function(k, sc)
    self.keyreleased(k, sc)
  end
end

function KeyManager:update(dt)
  for sc, state in pairs(self.keys) do
    if love.keyboard.isScancodeDown(sc) then
      local cooldown = state.cooldown
      local newcooldown = cooldown - dt
      if newcooldown <= 0 then
        state.cooldown = self.delay
        local newcount = state.count + 1
        state.count = newcount
        self.keytrigger(sc, newcount)
      else
        state.cooldown = newcooldown
      end
    end
  end
end

return KeyManager