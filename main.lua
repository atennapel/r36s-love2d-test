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

local bpm = 120
local sfx = {}
local text = ""
local stepBuffer = 0
local step = 0
local selectedStep = 0
local steps = {}
for i = 0, 7 do
  local innerSteps = {}
  steps[i] = innerSteps
  for j = 0, 15 do
    innerSteps[j] = false
  end
end
local patternInstruments = {}
for i = 0, 7 do
  patternInstruments[i] = nil
end
local sequencerJustStarted = false
local sequencerPlaying = false
local selectedPattern = 0

local function loadSample(name, file)
  sfx[name] = love.audio.newSource("sfx/" .. file, "static")
  print("loaded sample " .. name .. " from " .. file)
end

function love.load()
  love.graphics.setNewFont("font.otf", 12)

  for name, file in pairs(SAMPLES) do
    loadSample(name, file)
  end
end

local function play(sample)
  sample:stop()
  sample:play()
end

function love.keypressed(key, scancode, isRepeat)
  if scancode == "a" then
    selectedStep = (selectedStep - 1) % 16
  elseif scancode == "d" then
    selectedStep = (selectedStep + 1) % 16
  elseif scancode == "w" then
    selectedPattern = (selectedPattern - 1) % 8
  elseif scancode == "s" then
    selectedPattern = (selectedPattern + 1) % 8

  elseif scancode == "z" then
    steps[selectedPattern][selectedStep] = not steps[selectedPattern][selectedStep]
  elseif scancode == "lshift" then
    local current = patternInstruments[selectedPattern]
    if current == nil then
      patternInstruments[selectedPattern] = "kick"
    elseif current == "kick" then
      patternInstruments[selectedPattern] = "snare"
    elseif current == "snare" then
      patternInstruments[selectedPattern] = "hihat"
    elseif current == "hihat" then
      patternInstruments[selectedPattern] = "tom1"
    elseif current == "tom1" then
      patternInstruments[selectedPattern] = "tom2"
    elseif current == "tom2" then
      patternInstruments[selectedPattern] = "tom3"
    elseif current == "tom3" then
      patternInstruments[selectedPattern] = "sine"
    elseif current == "sine" then
      patternInstruments[selectedPattern] = "casio"
    elseif current == "casio" then
      patternInstruments[selectedPattern] = "piano"
    elseif current == "piano" then
      patternInstruments[selectedPattern] = nil
    end

  elseif scancode == "return" then
    if sequencerPlaying then
      sequencerPlaying = false
      step = 0
      stepBuffer = 0
    else
      sequencerJustStarted = true
      sequencerPlaying = true
    end
  end
end

local function playStep(step)
  for pattern = 0, 7 do
    if steps[pattern][step] then
      local instrument = patternInstruments[pattern]
      if instrument ~= nil then
        play(sfx[instrument])
      end
    end
  end
end

function love.update(dt)
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

local function drawPattern(patternIx, x, y)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(string.format("%X", patternIx), x + 8, y + 5)

  for i = 0, 15 do
    local mode = "line"
    local highlight = (sequencerPlaying and i == step) or steps[patternIx][i]
    if highlight then mode = "fill" end
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(mode, x + 28 + i * 28, y, 24, 24, 2, 2)
    if highlight then
      love.graphics.setColor(0, 0, 0)
    else
      love.graphics.setColor(1, 1, 1)
    end
    local label
    if patternIx == selectedPattern and i == selectedStep then
      label = string.format("[%X]", i)
    else
      label = string.format(" %X ", i)
    end
    love.graphics.print(label, x + 28 + i * 28 + 1, y + 5)
  end

  love.graphics.setColor(1, 1, 1)
  local instrument = patternInstruments[patternIx]
  love.graphics.print(instrument or "(no instrument)", x + 28 * 16 + 28, y + 5)
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(text, 10, 10)
  local seqText = "NOT PLAYING"
  if sequencerPlaying then seqText = "PLAYING" end
  love.graphics.print(seqText, 10, 20)

  for i = 0, 7 do
    drawPattern(i, 10, 50 + 30 * i)
  end
end
