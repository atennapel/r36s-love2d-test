local Step = {
  enabled = false,
  note = 60,
  volume = 1,
  sustain = false,
}
Step.__index = Step

function Step:new()
  local self = setmetatable({}, Step)
  return self
end

function Step:flip()
  self.enabled = not self.enabled
end

function Step:play(sample)
  if self.enabled then
    sample:setVolume(self.volume)
    sample:setNote(self.note)
    if not self.sustain then
      sample:on()
    end
  else
    sample:off()
  end
end

return Step