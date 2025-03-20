local NOT_STARTED = 0
local ATTACKING = 1
local DECAYING = 2
local SUSTAINING = 3
local RELEASING = 4

local ADSREnvelope = {
  attack = 0,
  decay = 0,
  sustain = 1,
  release = 0,
  resetVolumeOnAttack = false,

  volume = 0,

  state = NOT_STARTED,
  value = 0,
  shouldStop = false,
}
ADSREnvelope.__index = ADSREnvelope

function ADSREnvelope:create(options)
  local envelope = {}
  for k, v in pairs(options or {}) do
    envelope[k] = v
  end
  setmetatable(envelope, ADSREnvelope)
  return envelope
end

function ADSREnvelope:clone()
  return ADSREnvelope:create(self)
end

function ADSREnvelope:update(dt)
  self.shouldStop = false
  if self.state == ATTACKING then
    self.value = self.value + dt
    self.volume = self.value / self.attack
    if self.value >= self.attack then
      self.volume = 1
      self.value = 0
      self.state = DECAYING
    end
  elseif self.state == DECAYING then
    self.value = self.value + dt
    self.volume = self.sustain + ((1 - (self.value / self.decay)) * (1 - self.sustain))
    if self.value >= self.decay then
      self.volume = self.sustain
      self.value = 0
      self.state = SUSTAINING
    end
  elseif self.state == SUSTAINING then
    self.value = self.value + dt
  elseif self.state == RELEASING then
    self.value = self.value + dt
    self.volume = (1 - (self.value / self.release)) * self.sustain
    if self.value >= self.release then
      self.volume = 0
      self.value = 0
      self.state = NOT_STARTED
      self.shouldStop = true
    end
  end
end

function ADSREnvelope:triggerAttack()
  if self.resetVolumeOnAttack then
    self.volume = 0
  end
  self.value = self.volume * self.attack
  self.state = ATTACKING
end

function ADSREnvelope:triggerRelease()
  self.value = (1 - (self.volume / self.sustain)) * self.release
  self.state = RELEASING
end

return ADSREnvelope