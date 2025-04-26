local PolySample = {}
PolySample.__index = PolySample

function PolySample.new(file)
  local self = setmetatable({}, PolySample)
  self.soundData = love.sound.newSoundData(file)
  self.rootNote = 60
  self.sources = {}
  self.playing = {}
  return self
end

function PolySample:getPitchForNote(midiNote)
  return 1.059463 ^ (midiNote - self.rootNote)
end

function PolySample:onOff(note, on)
  local source = self.sources[note]
  if on and source == nil then
    source = love.audio.newSource(self.soundData)
    source:setPitch(self:getPitchForNote(note))
    self.sources[note] = source
  end
  if source ~= nil then
    if on then
      source:play()
    else
      source:stop()
    end
    self.playing[note] = on
  end
end

function PolySample:on(note)
  self:onOff(note, true)
end

function PolySample:off(note)
  self:onOff(note, false)
end

function PolySample:offAllInOctave(octave)
  for note = 0, 11 do
    self:off(note + (octave + 1) * 12)
  end
end

function PolySample:playingNotes()
  local notes = {}
  for note, on in pairs(self.playing) do
    if on then
      table.insert(notes, note)
    end
  end
  table.sort(notes)
  return notes
end

return PolySample