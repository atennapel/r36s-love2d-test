local Step = require("Step")

local Pattern = {
  enabled = true,
  steps = nil,
  length = 16,
  sample = nil,
}
Pattern.__index = Pattern

function Pattern:new(sample, length)
  local self = setmetatable({}, Pattern)
  self.sample = sample
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

function Pattern:play(ix)
  if self.enabled and self.sample ~= nil then
    self:getStep(ix):play(self.sample)
  end
end

return Pattern