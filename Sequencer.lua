local Sequencer = {
  bpm = 120,
  length = 16,
  playing = false,
  justStarted = false,

  stepBuffer = 0,
  step = 0,
  triggered = false,
}
Sequencer.__index = Sequencer

function Sequencer:new()
  local self = setmetatable({}, Sequencer)
  return self
end

function Sequencer:update(dt)
  self.triggered = false
  if self.playing then
    if self.justStarted then
      self.triggered = true
    end
    self.justStarted = false
    self.stepBuffer = self.stepBuffer + dt
    local target = (60 / self.bpm) / 4
    if self.stepBuffer >= target then
      self.stepBuffer = self.stepBuffer - target
      self.step = (self.step + 1) % self.length
      self.triggered = true
    end
  end
end

function Sequencer:start()
  self.playing = true
  self.justStarted = true
end

function Sequencer:stop()
  self.step = 0
  self.stepBuffer = 0
  self.playing = false
end

return Sequencer