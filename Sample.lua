local ADSREnvelope = require("ADSREnvelope")

local Sample = {
  url = nil,
  source = nil,
  envelope = nil,
  volume = 0.8,
  rootNote = 60,
  note = 60,
}
Sample.__index = Sample

function Sample:new(options)
  local object = setmetatable({}, Sample)
  for k, v in pairs(options or {}) do
    object[k] = v
  end
  local source = love.audio.newSource(object.url, "static")
  source:setVolume(object.volume)
  object.source = source
  object.envelope = ADSREnvelope:new(source, object.volume)
  return object
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
  self.envelope.volumeScaling = v
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