local Sample = require("Sample")

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

local INSTRUMENT = "sine"
local ATTACK = 0.1
local DECAY = 0.1
local SUSTAIN = 0.8
local RELEASE = 0.1 -- any value lower than 0.019 will cause clicks

local bpm = 120
local sfx = {}
local text = ""
local stepBuffer = 0
local step = 0
local selectedStep = 0
local steps = {}
for i = 1,16 do
  steps[i] = false
end
local stepInstruments = {}
for i = 1,16 do
  stepInstruments[i] = nil
end
local sequencerJustStarted = false
local sequencerPlaying = false

local notes = {}

local function loadSample(name, file)
  sfx[name] = love.audio.newSource("sfx/" .. file, "static")
  print("loaded sample " .. name .. " from " .. file)
end

function love.load()
  for name, file in pairs(SAMPLES) do
    loadSample(name, file)
  end

  local baseNote = Sample:create({ url = "sfx/" .. SAMPLES[INSTRUMENT] })
  baseNote.rootNote = 69
  baseNote.envelope.attack = ATTACK
  baseNote.envelope.decay = DECAY
  baseNote.envelope.sustain = SUSTAIN
  baseNote.envelope.release = RELEASE
  baseNote.volume = 0.8

  notes.z = baseNote:clone():setNote(60)
  notes.x = baseNote:clone():setNote(62)
  notes.c = baseNote:clone():setNote(64)
  notes.v = baseNote:clone():setNote(65)
  notes.b = baseNote:clone():setNote(67)
  notes.n = baseNote:clone():setNote(69)
  notes.m = baseNote:clone():setNote(71)
  notes[","] = baseNote:clone():setNote(72)
end

local function play(sample)
  sample:stop()
  sample:play()
end

function love.keypressed(key, scancode, isRepeat)
  if scancode == "w" then
    steps[selectedStep] = not steps[selectedStep]
  elseif scancode == "a" then
    selectedStep = (selectedStep - 1) % 16
  elseif scancode == "s" then
    local current = stepInstruments[selectedStep]
    if current == nil then
      stepInstruments[selectedStep] = "kick"
    elseif current == "kick" then
      stepInstruments[selectedStep] = "snare"
    elseif current == "snare" then
      stepInstruments[selectedStep] = "hihat"
    elseif current == "hihat" then
      stepInstruments[selectedStep] = "tom1"
    elseif current == "tom1" then
      stepInstruments[selectedStep] = "tom2"
    elseif current == "tom2" then
      stepInstruments[selectedStep] = "tom3"
    elseif current == "tom3" then
      stepInstruments[selectedStep] = "sine"
    elseif current == "sine" then
      stepInstruments[selectedStep] = "casio"
    elseif current == "casio" then
      stepInstruments[selectedStep] = "piano"
    elseif current == "piano" then
      stepInstruments[selectedStep] = nil
    end
  elseif scancode == "d" then
    selectedStep = (selectedStep + 1) % 16
  elseif scancode == "return" then
    if sequencerPlaying then
      sequencerPlaying = false
      step = 0
      stepBuffer = 0
    else
      sequencerJustStarted = true
      sequencerPlaying = true
    end
  elseif notes[scancode] ~= nil then
    notes[scancode]:on()
    text = INSTRUMENT .. " " .. scancode
  end
end

function love.keyreleased(key, scancode)
  if notes[scancode] ~= nil then
    notes[scancode]:off()
  end
end

function playStep(step)
  if steps[step] then
    local instrument = stepInstruments[step]
    if instrument ~= nil then
      play(sfx[instrument])
    end
  end
end

function love.update(dt)
  for _, sample in pairs(notes) do
    sample:update(dt)
  end

  if sequencerPlaying then
    if sequencerJustStarted then
      playStep(step)
    end
    sequencerJustStarted = false
    stepBuffer = stepBuffer + dt
    local target = (60 / bpm) / 4
    if stepBuffer >= target then
      stepBuffer = stepBuffer - target
      step = (step + 1) % 16
      playStep(step)
    end
  end
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(text, 10, 10)
  local seqText = "NOT PLAYING"
  if sequencerPlaying then seqText = "PLAYING" end
  love.graphics.print(seqText, 10, 20)
  love.graphics.print("^", 10 + selectedStep * 28 + 7, 95)
  love.graphics.print(stepInstruments[selectedStep] or "(no instrument)", 10, 105)

  for i = 0, 15 do
    local mode = "line"
    local highlight = (sequencerPlaying and i == step) or steps[i]
    if highlight then mode = "fill" end
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(mode, 10 + i * 28, 70, 24, 24, 2, 2)
    if highlight then
      love.graphics.setColor(0, 0, 0)
    else
      love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print(string.format("%X", i), 10 + i * 28 + 8, 75)
  end
end
