local ADSREnvelope = require("ADSREnvelope")

local Sample = {
  url = nil,
  source = nil,
  envelope = nil,
  volume = 0.8,
  playing = false,
}
Sample.__index = Sample

function Sample:create(options)
  local object = {}
  for k, v in pairs(options or {}) do
    object[k] = v
  end
  setmetatable(object, Sample)
  object.source = love.audio.newSource(object.url, "static")
  object.envelope = ADSREnvelope:new({
    attack = object.attack,
    decay = object.decay,
    sustain = object.sustain,
    release = object.release,
    resetVolumeOnAttack = object.resetVolumeOnAttack,
  })
  return object
end

function Sample:clone()
  local object = {}
  for k, v in pairs(self) do
    if k ~= "source" then
      object[k] = v
    end
  end
  setmetatable(object, Sample)
  object.source = self.source:clone()
  return object
end

function Sample:on()
  if not self.playing then
    self.playing = true
    self.envelope:triggerAttack()
  end
end

function Sample:off()
  if self.playing then
    self.playing = false
    self.envelope:triggerRelease()
  end
end

function Sample:update(dt)
  self.envelope:update(dt)
  if self.envelope.shouldStop then
    self.source:stop()
  else
    self.source:setVolume(self.volume * self.envelope.volume)
  end
end

return Sample