local ADSREnvelope = require("ADSREnvelope")

local Sample = {
  url = nil,
  source = nil,
  envelope = nil,
  volume = 0.8,
  playing = false,
  rootNote = 60,
}
Sample.__index = Sample

function Sample:create(options)
  local object = {}
  for k, v in pairs(options or {}) do
    object[k] = v
  end
  setmetatable(object, Sample)
  object.source = love.audio.newSource(object.url, "static")
  object.envelope = ADSREnvelope:create()
  return object
end

function Sample:clone()
  local object = {}
  for k, v in pairs(self) do
    object[k] = v
  end
  setmetatable(object, Sample)
  object.source = self.source:clone()
  object.envelope = self.envelope:clone()
  return object
end

local TET12 = 1.059463
local function getPitchForNote(rootNote, midiNote)
  return TET12 ^ (midiNote - rootNote)
end

function Sample:setNote(midiNote)
  self.source:setPitch(getPitchForNote(self.rootNote, midiNote))
  return self
end

function Sample:on()
  if not self.playing then
    self.playing = true
    self.envelope:triggerAttack()
    self.source:play()
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