local Sample = require("Sample")
local Pattern = require("Pattern")
local Sequencer = require("Sequencer")

local SAMPLE_SOURCES = {
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

local keySpeed = 0.2
local prevkeys = {}
local keys = {}
local samples = {}
local selectedPattern = 0
local selectedStep = 0
local patterns = {}
for i = 0, 7 do
  patterns[i] = Pattern:new()
end
local sequencer = Sequencer:new()

local CONTROL_SEQUENCER = 0
local CONTROL_SETTINGS = 1
local selectedControl = CONTROL_SEQUENCER
local selectedOption = 0

function love.load()
  love.graphics.setNewFont("font.otf", 12)

  for name, file in pairs(SAMPLE_SOURCES) do
    samples[name] = Sample:new(name, "sfx/" .. file)
    print("loaded sample " .. name .. " from " .. file)
  end

  samples.sine.rootNote = 69
  samples.sine:setNote(60)
  samples.casio.rootNote = 69
  samples.casio:setNote(60)
  samples.piano.rootNote = 45
  samples.piano:setNote(60)
end

function love.keypressed(key, scancode, isRepeat)
  keys[scancode] = 0

  if scancode == "lshift" then
    local pattern = patterns[selectedPattern]
    local current = pattern.sample
    if current ~= nil then current:off() end
    if current == nil then
      pattern.sample = samples.kick
    elseif current.name == "kick" then
      pattern.sample = samples.snare
    elseif current.name == "snare" then
      pattern.sample = samples.hihat
    elseif current.name == "hihat" then
      pattern.sample = samples.tom1
    elseif current.name == "tom1" then
      pattern.sample = samples.tom2
    elseif current.name == "tom2" then
      pattern.sample = samples.tom3
    elseif current.name == "tom3" then
      pattern.sample = samples.sine
    elseif current.name == "sine" then
      pattern.sample = samples.casio
    elseif current.name == "casio" then
      pattern.sample = samples.piano
    elseif current.name == "piano" then
      pattern.sample = nil
    end
  elseif scancode == "escape" then
    selectedControl = (selectedControl + 1) % 2
  elseif scancode == "x" then
    local sample = patterns[selectedPattern].sample
    if sample ~= nil then
      if sample.envelope.attack > 0 then
        sample.envelope.attack = sample.envelope.attack - 0.1
      end
    end
  elseif scancode == "y" then
    local sample = patterns[selectedPattern].sample
    if sample ~= nil then
      if sample.envelope.attack < 10 then
        sample.envelope.attack = sample.envelope.attack + 0.1
      end
    end

  elseif scancode == "return" then
    if sequencer.playing then
      sequencer:stop()
      for _, sample in pairs(samples) do
        sample:off()
      end
    else
      sequencer:start()
    end
  end
end

function love.keyreleased(key, scancode)
  if scancode == "z" then
    patterns[selectedPattern]:getStep(selectedStep):flip()
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

  if selectedControl == CONTROL_SEQUENCER then
    if keyRepeat("a", keySpeed) then
      if selectedStep > 0 then
        if love.keyboard.isScancodeDown("z") then
          patterns[selectedPattern]:getStep(selectedStep):flip()
        end
        selectedStep = selectedStep - 1
      end
    elseif keyRepeat("d", keySpeed) then
      if selectedStep < 15 then
        if love.keyboard.isScancodeDown("z") then
          patterns[selectedPattern]:getStep(selectedStep):flip()
        end
        selectedStep = selectedStep + 1
      end
    end
    if keyRepeat("w", keySpeed) then
      if selectedPattern > 0 then
        if love.keyboard.isScancodeDown("z") then
          patterns[selectedPattern]:getStep(selectedStep):flip()
        end
        selectedPattern = selectedPattern - 1
      end
    elseif keyRepeat("s", keySpeed) then
      if selectedPattern < 7 then
        if love.keyboard.isScancodeDown("z") then
          patterns[selectedPattern]:getStep(selectedStep):flip()
        end
        selectedPattern = selectedPattern + 1
      end
    end
  elseif selectedControl == CONTROL_SETTINGS then
    if keyRepeat("w", keySpeed) then
      if selectedOption > 0 then
        selectedOption = selectedOption - 1
      end
    elseif keyRepeat("s", keySpeed) then
      if selectedOption < 3 then
        selectedOption = selectedOption + 1
      end
    end
    local step = patterns[selectedPattern]:getStep(selectedStep)
    if keyRepeat("a", keySpeed) then
      if selectedOption == 0 then
        step:flip()
      elseif selectedOption == 1 then
        if step.note > 0 then
          step.note = step.note - 1
        end
      elseif selectedOption == 2 then
        local up = math.floor(step.volume * 10)
        if up > 0 then
          step.volume = (up - 1) / 10
        end
      elseif selectedOption == 3 then
        step.sustain = not step.sustain
      end
    elseif keyRepeat("d", keySpeed) then
      if selectedOption == 0 then
        step:flip()
      elseif selectedOption == 1 then
        if step.note < 127 then
          step.note = step.note + 1
        end
      elseif selectedOption == 2 then
        local up = math.floor(step.volume * 10)
        if up < 10 then
          step.volume = (up + 1) / 10
        end
      elseif selectedOption == 3 then
        step.sustain = not step.sustain
      end
    end
  end

  if sequencer.bpm > 1 and keyRepeat("l", keySpeed) then
    sequencer.bpm = sequencer.bpm - 1
  elseif sequencer.bpm < 999 and keyRepeat("r", keySpeed) then
    sequencer.bpm = sequencer.bpm + 1
  end

  prevkeys = lprevkeys
end

function love.update(dt)
  handleInput(dt)

  for name, sample in pairs(samples) do
    sample:update(dt)
  end

  sequencer:update(dt)
  if sequencer.triggered then
    for pattern = 0, 7 do
      patterns[pattern]:play(sequencer.step)
    end
  end
end

local function boolstr(b)
  if b then
    return "1"
  else
    return "0"
  end
end

local function hexstr(n)
  return string.format("%X", n)
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
  love.graphics.print(hexstr(patternIx), x + 8, y + 5)

  for i = 0, 15 do
    local mode = "line"
    local cstep = patterns[patternIx]:getStep(i)
    local highlight = (sequencer.playing and i == sequencer.step) or cstep.enabled
    if highlight then mode = "fill" end
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(mode, x + 28 + i * 28, y, 24, 24, 2, 2)
    if cstep.sustain then
      love.graphics.rectangle("fill", x + 28 + i * 28 - 4, y + 11, 5, 5)
    end
    if highlight then
      love.graphics.setColor(0, 0, 0)
    else
      love.graphics.setColor(1, 1, 1)
    end
    local label
    if patternIx == selectedPattern and i == selectedStep then
      label = "[" .. hexstr(i) .. "]"
    else
      label = " " .. hexstr(i) ..  " "
    end
    love.graphics.print(label, x + 28 + i * 28 + 1, y + 5)
  end

  love.graphics.setColor(1, 1, 1)
  local sample = patterns[patternIx].sample
  local instrumentText = "(no instrument)"
  if sample ~= nil then
    instrumentText = sample.name .. " (" .. hexstr2(sample.note) .. ")"
  end
  love.graphics.print(instrumentText, x + 28 * 16 + 28, y + 5)
end

local function selection(show)
  if show then
    return "> "
  else
    return "  "
  end
end

local function drawStepOptions(patternIx, stepIx)
  local pattern = patterns[patternIx]
  local step = pattern:getStep(stepIx)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("  step " .. hexstr(patternIx) .. "-" .. hexstr(stepIx), 10, 300)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 0) .. "enabled = " .. boolstr(step.enabled), 10, 312)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 1) .. "note    = " .. hexstr2(step.note), 10, 324)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 2) .. "volume  = " .. step.volume, 10, 336)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 3) .. "sustain = " .. boolstr(step.sustain), 10, 350)
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  local seqText = "NOT PLAYING"
  if sequencer.playing then seqText = "PLAYING" end
  love.graphics.print(seqText .. " (bpm " .. sequencer.bpm .. ")", 10, 20)

  for i = 0, 7 do
    drawPattern(i, 10, 50 + 30 * i)
  end

  drawStepOptions(selectedPattern, selectedStep)
end