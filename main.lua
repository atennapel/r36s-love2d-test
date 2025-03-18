local SAMPLES = {
  kick = "kick.mp3",
  snare = "snare.mp3",
  hihat = "hihat.mp3",
  tom1 = "tom1.mp3",
  tom2 = "tom2.mp3",
  tom3 = "tom3.mp3",
  sine = "sine.wav",
  casio = "casio.ogg",
  piano = "piano.ogg",
}
local TET12 = 1.059463
local INSTRUMENT = "sine"

local sfx = {}
local text = ""

local function getPitchForNote(midiNote)
  return TET12 ^ (midiNote - 20 - 49)
end

local notes = {}
local playing = {}

local function loadSample(name, file)
  sfx[name] = love.audio.newSource("sfx/" .. file, "static")
  print("loaded sample " .. name .. " from " .. file)
end

function love.load()
  for name, file in pairs(SAMPLES) do
    loadSample(name, file)
  end

  notes.z = sfx[INSTRUMENT]:clone()
  notes.x = sfx[INSTRUMENT]:clone()
  notes.c = sfx[INSTRUMENT]:clone()
  notes.v = sfx[INSTRUMENT]:clone()
  notes.b = sfx[INSTRUMENT]:clone()
  notes.n = sfx[INSTRUMENT]:clone()
  notes.m = sfx[INSTRUMENT]:clone()
  notes[","] = sfx[INSTRUMENT]:clone()

  notes.z:setPitch(getPitchForNote(60))
  notes.x:setPitch(getPitchForNote(62))
  notes.c:setPitch(getPitchForNote(64))
  notes.v:setPitch(getPitchForNote(65))
  notes.b:setPitch(getPitchForNote(67))
  notes.n:setPitch(getPitchForNote(69))
  notes.m:setPitch(getPitchForNote(71))
  notes[","]:setPitch(getPitchForNote(72))

  playing.z = false
  playing.x = false
  playing.c = false
  playing.v = false
  playing.b = false
  playing.n = false
  playing.m = false
end

local function play(sample)
  sample:stop()
  sample:play()
end

function love.keypressed(key, scancode, isRepeat)
  if scancode == "w" then
    play(sfx.kick)
    text = "kick"
  elseif scancode == "a" then
    play(sfx.snare)
    text = "snare"
  elseif scancode == "s" then
    play(sfx.hihat)
    text = "hihat"
  elseif scancode == "d" then
    play(sfx.tom1)
    text = "tom1"
  elseif notes[scancode] ~= nil then
    if not playing[scancode] then
      playing[scancode] = true
      notes[scancode]:play()
      text = "sine " .. scancode
    end
  end
end

function love.keyreleased(key, scancode)
  if notes[scancode] ~= nil then
    if playing[scancode] then
      playing[scancode] = false
      notes[scancode]:stop()
    end
  end
end

function love.update(dt)
end

function love.draw()
  love.graphics.print(text, 10, 10)
end