local Step = require("Step")

local Pattern = {
  steps = nil,
  length = 16,
}
Pattern.__index = Pattern

function Pattern:new(length)
  local self = setmetatable({}, Pattern)
  self.length = length or 16
  local steps = {}
  for i = 1, self.length do
    steps[i] = Step:new()
  end
  self.steps = steps
  return self
end

function Pattern:getStep(ix)
  return self.steps[(ix % self.length) + 1]
end

return Pattern