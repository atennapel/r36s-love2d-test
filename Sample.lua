local ADSREnvelope = require("ADSREnvelope")

local Sample = {
  name = nil,
  url = nil,
  source = nil,
  envelope = nil,
  gain = 0.8,
  volume = 1,
  rootNote = 60,
  note = 60,
}
Sample.__index = Sample

function Sample:new(name, url, options)
  local self = setmetatable({}, Sample)
  for k, v in pairs(options or {}) do
    self[k] = v
  end
  self.name = name
  self.url = url
  local source = love.audio.newSource(self.url, "static")
  source:setVolume(self.volume * self.gain)
  self.source = source
  self.envelope = ADSREnvelope:new(source, self.volume * self.gain)
  return self
end

function Sample:clone()
  local object = {}
  for k, v in pairs(self) do
    object[k] = v
  end
  setmetatable(object, Sample)
  local newSource = self.source:clone()
  object.source = newSource
  object.envelope = self.envelope:clone()
  object.envelope.source = newSource
  return object
end

local TET12 = 1.059463
local function getPitchForNote(rootNote, midiNote)
  return TET12 ^ (midiNote - rootNote)
end

function Sample:setNote(midiNote)
  self.note = midiNote
  self.source:setPitch(getPitchForNote(self.rootNote, midiNote))
end

function Sample:setVolume(v)
  self.volume = v
  self.envelope.volumeScaling = v * self.gain
end

function Sample:setGain(v)
  self.gain = v
  self.envelope.volumeScaling = self.volume * v
end

function Sample:on()
  self.envelope:triggerAttack()
end

function Sample:off()
  self.envelope:triggerRelease()
end

function Sample:update(dt)
  self.envelope:update(dt)
end

function Sample:show()
  return "Sample(" .. self.url .. ", " .. self.envelope:show() .. ")"
end

return Sample