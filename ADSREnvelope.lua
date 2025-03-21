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
  volumeScaling = 1,
  resetVolumeOnAttack = true,

  source = nil,

  state = NOT_STARTED,
  value = 0,
  volume = 0,
}
ADSREnvelope.__index = ADSREnvelope

function ADSREnvelope:create(source, volumeScaling, options)
  local envelope = setmetatable({}, ADSREnvelope)
  for k, v in pairs(options or {}) do
    envelope[k] = v
  end
  envelope.source = source
  envelope.volumeScaling = volumeScaling
  return envelope
end

function ADSREnvelope:clone()
  return ADSREnvelope:create(self)
end

function ADSREnvelope:updateVolume()
  self.source:setVolume(self.volume * self.volumeScaling)
end

function ADSREnvelope:update(dt)
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
      self.source:stop()
      self.volume = 0
      self.value = 0
      self.state = NOT_STARTED
    end
  end
  self:updateVolume()
end

function ADSREnvelope:triggerAttack()
  if self.resetVolumeOnAttack then
    self.volume = 0
    if self.attack == 0 then
      self.volume = 1
    end
  end
  self:updateVolume()
  self.source:stop()
  self.source:play()
  self.value = self.volume * self.attack
  self.state = ATTACKING
end

function ADSREnvelope:triggerRelease()
  self.value = (1 - (self.volume / self.sustain)) * self.release
  self.state = RELEASING
end

function ADSREnvelope:show()
  return "ADSREnvelope(" .. self.state .. ", " .. self.value ..  ")"
end

return ADSREnvelope