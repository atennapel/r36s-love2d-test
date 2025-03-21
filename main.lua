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

local prevkeys = {}
local keys = {}
local bpm = 120
local sfx = {}
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
local patternSustain = {}
for i = 0, 7 do
  patternSustain[i] = false
end
local sequencerJustStarted = false
local sequencerPlaying = false
local selectedPattern = 0

function love.load()
  love.graphics.setNewFont("font.otf", 12)

  for name, file in pairs(SAMPLES) do
    sfx[name] = Sample:create({ url = "sfx/" .. file })
    print("loaded sample " .. name .. " from " .. file)
  end

  sfx.sine.rootNote = 69
  sfx.sine:setNote(60)
  sfx.casio.rootNote = 69
  sfx.casio:setNote(60)
  sfx.piano.rootNote = 45
  sfx.piano:setNote(60)
end

function love.keypressed(key, scancode, isRepeat)
  keys[scancode] = 0

  if scancode == "z" then
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
  elseif scancode == "escape" then
    patternSustain[selectedPattern] = not patternSustain[selectedPattern]
  elseif scancode == "x" then
    local sample = sfx[patternInstruments[selectedPattern]]
    if sample.envelope.attack > 0 then
      sample.envelope.attack = sample.envelope.attack - 0.1
    end
  elseif scancode == "y" then
    local sample = sfx[patternInstruments[selectedPattern]]
    if sample.envelope.attack < 10 then
      sample.envelope.attack = sample.envelope.attack + 0.1
    end

  elseif scancode == "space" then
    local instrument = patternInstruments[selectedPattern]
    if instrument ~= nil then
      local sample = sfx[instrument]
      if sample.note < 127 then
        sample:setNote(sample.note + 1)
      end
    end
  elseif scancode == "b" then
    local instrument = patternInstruments[selectedPattern]
    if instrument ~= nil then
      local sample = sfx[instrument]
      if sample.note > 0 then
        sample:setNote(sample.note - 1)
      end
    end

  elseif scancode == "return" then
    if sequencerPlaying then
      sequencerPlaying = false
      step = 0
      stepBuffer = 0
      for _, sample in pairs(sfx) do
        sample:off()
      end
    else
      sequencerJustStarted = true
      sequencerPlaying = true
    end
  end
end

local function playStep(step)
  for pattern = 0, 7 do
    local instrument = patternInstruments[pattern]
    if instrument ~= nil then
      if steps[pattern][step] then
        sfx[instrument]:on()
      elseif not patternSustain[pattern] then
        sfx[instrument]:off()
      end
    end
  end
end

local function keyRepeat(scancode, interval)
  local value = keys[scancode]
  if value ~= nil then
    if value >= interval then
      keys[scancode] = value - interval
      return true
    elseif prevkeys[scancode] == nil then
      return true
    end
  end
  return false
end

local function handleInput(dt)
  local lprevkeys = {}
  for scancode, v in pairs(keys) do
    lprevkeys[scancode] = v
    if love.keyboard.isScancodeDown(scancode) then
      keys[scancode] = v + dt
    else
      keys[scancode] = nil
    end
  end

  if keyRepeat("a", 0.1) then
    if selectedStep > 0 then
      selectedStep = selectedStep - 1
    end
  elseif keyRepeat("d", 0.1) then
    if selectedStep < 15 then
      selectedStep = selectedStep + 1
    end
  end
  if keyRepeat("w", 0.1) then
    if selectedPattern > 0 then
      selectedPattern = selectedPattern - 1
    end
  elseif keyRepeat("s", 0.1) then
    if selectedPattern < 7 then
      selectedPattern = selectedPattern + 1
    end
  end

  if bpm > 1 and keyRepeat("l", 0.1) then
    bpm = bpm - 1
  elseif bpm < 999 and keyRepeat("r", 0.1) then
    bpm = bpm + 1
  end

  prevkeys = lprevkeys
end

function love.update(dt)
  handleInput(dt)

  for name, sample in pairs(sfx) do
    -- if name == "sine" then print("before", sample.envelope:show()) end
    sample:update(dt)
    -- if name == "sine" then print("after", sample.envelope:show()) end
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

local function hexstr2(n)
  if n < 16 then
    return string.format("0%X", n)
  else
    return string.format("%X", n)
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
  local instrumentText = "(no instrument)"
  local sustainText = ""
  if patternSustain[patternIx] then
    sustainText = " (s)"
  end
  if instrument ~= nil then
    instrumentText = instrument .. "(" .. hexstr2(sfx[instrument].note) .. ")"
  end
  love.graphics.print(instrumentText .. sustainText, x + 28 * 16 + 28, y + 5)
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  local seqText = "NOT PLAYING"
  if sequencerPlaying then seqText = "PLAYING" end
  love.graphics.print(seqText .. " (bpm " .. bpm .. ")", 10, 20)

  for i = 0, 7 do
    drawPattern(i, 10, 50 + 30 * i)
  end
end
