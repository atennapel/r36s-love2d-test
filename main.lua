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
local selectedPart = 0
local selectedPattern = 0
local selectedStep = 0
local parts = {}
local patterns = {}
for i = 0, 7 do
  patterns[i] = Pattern:new()
end
parts[0] = patterns
local sequencer = Sequencer:new()

local CONTROL_SEQUENCER = 0
local CONTROL_SETTINGS = 1
local selectedControl = CONTROL_SEQUENCER
local selectedOption = 0
local selectedSample = nil
local playingSample = nil

function love.load()
  love.graphics.setNewFont("font.otf", 12)

  for name, file in pairs(SAMPLE_SOURCES) do
    samples[name] = Sample:new(name, "sfx/" .. file)
    print("loaded sample " .. name .. " from " .. file)
  end

  selectedSample = samples.kick

  samples.sine.rootNote = 69
  samples.sine:setNote(60)
  samples.casio.rootNote = 69
  samples.casio:setNote(60)
  samples.piano.rootNote = 45
  samples.piano:setNote(60)
end

function love.keypressed(key, scancode, isRepeat)
  keys[scancode] = 0

  if scancode == "escape" or scancode == "lshift" then
    selectedControl = (selectedControl + 1) % 2

  elseif scancode == "l" then
    if selectedPart > 0 then
      selectedPart = selectedPart - 1
      patterns = parts[selectedPart]
    end
  elseif scancode == "r" then
    if selectedPart < 15 then
      selectedPart = selectedPart + 1
      if parts[selectedPart] == nil then
        patterns = {}
        for i = 0, 7 do
          patterns[i] = Pattern:new()
        end
        parts[selectedPart] = patterns
      end
      patterns = parts[selectedPart]
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
  elseif scancode == "b" then
    local sample = parts[selectedPart][selectedPattern].sample
    if sample ~= nil then
      playingSample = sample
      sample:on()
    end
  end
end

function love.keyreleased(key, scancode)
  if scancode == "z" then
    patterns[selectedPattern]:getStep(selectedStep):flip()
  elseif scancode == "b" then
    if playingSample ~= nil then
      playingSample:off()
      playingSample = nil
    end
  end
end


local function nextSample(current)
  if current == nil then
    return samples.kick
  elseif current.name == "kick" then
    return samples.snare
  elseif current.name == "snare" then
    return samples.hihat
  elseif current.name == "hihat" then
    return samples.tom1
  elseif current.name == "tom1" then
    return samples.tom2
  elseif current.name == "tom2" then
    return samples.tom3
  elseif current.name == "tom3" then
    return samples.sine
  elseif current.name == "sine" then
    return samples.casio
  elseif current.name == "casio" then
    return samples.piano
  elseif current.name == "piano" then
    return nil
  end
end

local function previousSample(current)
  if current == nil then
    return samples.piano
  elseif current.name == "kick" then
    return nil
  elseif current.name == "snare" then
    return samples.kick
  elseif current.name == "hihat" then
    return samples.snare
  elseif current.name == "tom1" then
    return samples.hihat
  elseif current.name == "tom2" then
    return samples.tom1
  elseif current.name == "tom3" then
    return samples.tom2
  elseif current.name == "sine" then
    return samples.tom3
  elseif current.name == "casio" then
    return samples.sine
  elseif current.name == "piano" then
    return samples.casio
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
      if selectedOption < 13 then
        selectedOption = selectedOption + 1
      end
    end
    local pattern = patterns[selectedPattern]
    local step = pattern:getStep(selectedStep)
    local envelope = selectedSample.envelope
    if keyRepeat("a", keySpeed) then
      if selectedOption == 0 then
        pattern.enabled = not pattern.enabled
      elseif selectedOption == 1 then
        pattern.sample = previousSample(pattern.sample)

      elseif selectedOption == 2 then
        step:flip()
      elseif selectedOption == 3 then
        if step.note > 0 then
          step.note = step.note - 1
        end
      elseif selectedOption == 4 then
        local up = math.floor(step.volume * 10)
        if up > 0 then
          step.volume = (up - 1) / 10
        end
      elseif selectedOption == 5 then
        step.sustain = not step.sustain

      elseif selectedOption == 6 then
        selectedSample = previousSample(selectedSample)
        if selectedSample == nil then
          selectedSample = previousSample(selectedSample)
        end
      elseif selectedOption == 7 then
        local up = math.floor(selectedSample.gain * 10)
        if up > 0 then
          selectedSample:setGain((up - 1) / 10)
        end
      elseif selectedOption == 8 then
        if selectedSample.rootNote > 0 then
          selectedSample.rootNote = selectedSample.rootNote - 1
        end
      elseif selectedOption == 9 then
        local up = math.floor(envelope.attack * 10)
        if up > 0 then
          envelope.attack = (up - 1) / 10
        end
      elseif selectedOption == 10 then
        local up = math.floor(envelope.decay * 10)
        if up > 0 then
          envelope.decay = (up - 1) / 10
        end
      elseif selectedOption == 11 then
        local up = math.floor(envelope.sustain * 10)
        if up > 0 then
          envelope.sustain = (up - 1) / 10
        end
      elseif selectedOption == 12 then
        local up = math.floor(envelope.release * 10)
        if up > 0 then
          envelope.release = (up - 1) / 10
        end
      elseif selectedOption == 13 then
        envelope.resetVolumeOnAttack = not envelope.resetVolumeOnAttack
      end
    elseif keyRepeat("d", keySpeed) then
      if selectedOption == 0 then
        pattern.enabled = not pattern.enabled
      elseif selectedOption == 1 then
        pattern.sample = nextSample(pattern.sample)

      elseif selectedOption == 2 then
        step:flip()
      elseif selectedOption == 3 then
        if step.note < 127 then
          step.note = step.note + 1
        end
      elseif selectedOption == 4 then
        local up = math.floor(step.volume * 10)
        if up < 10 then
          step.volume = (up + 1) / 10
        end
      elseif selectedOption == 5 then
        step.sustain = not step.sustain

      elseif selectedOption == 6 then
        selectedSample = nextSample(selectedSample)
        if selectedSample == nil then
          selectedSample = nextSample(selectedSample)
        end
      elseif selectedOption == 7 then
        local up = math.floor(selectedSample.gain * 10)
        if up < 10 then
          selectedSample:setGain((up + 1) / 10)
        end
      elseif selectedOption == 8 then
        if selectedSample.rootNote < 127 then
          selectedSample.rootNote = selectedSample.rootNote + 1
        end
      elseif selectedOption == 9 then
        local up = math.floor(envelope.attack * 10)
        if up < 600 then
          envelope.attack = (up + 1) / 10
        end
      elseif selectedOption == 10 then
        local up = math.floor(envelope.decay * 10)
        if up < 600 then
          envelope.decay = (up + 1) / 10
        end
      elseif selectedOption == 11 then
        local up = math.floor(envelope.sustain * 10)
        if up < 10 then
          envelope.sustain = (up + 1) / 10
        end
      elseif selectedOption == 12 then
        local up = math.floor(envelope.release * 10)
        if up < 600 then
          envelope.release = (up + 1) / 10
        end
      elseif selectedOption == 13 then
        envelope.resetVolumeOnAttack = not envelope.resetVolumeOnAttack
      end
    end
  end

  if sequencer.bpm > 1 and keyRepeat("x", keySpeed) then
    sequencer.bpm = sequencer.bpm - 1
  elseif sequencer.bpm < 999 and keyRepeat("y", keySpeed) then
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
  local sampleText = "(no sample)"
  if sample ~= nil then
    local volume = string.format("%.2f", sample.source:getVolume())
    sampleText = sample.name .. " (" .. hexstr2(sample.note) .. ") (" .. volume .. ")"
  end
  love.graphics.print(sampleText, x + 28 * 16 + 28, y + 5)
end

local function selection(show)
  if show then
    return "> "
  else
    return "  "
  end
end

local function drawStepOptions(patternIx, stepIx)
  love.graphics.setColor(1, 1, 1)

  -- pattern settings
  local pattern = patterns[patternIx]
  local sample = pattern.sample
  love.graphics.print("  pattern " .. hexstr(patternIx), 10, 300)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 0) .. "enabled = " .. boolstr(pattern.enabled), 10, 312)
  local sampleText = "(no sample)"
  if sample ~= nil then
    sampleText = pattern.sample.name
  end
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 1) .. "sample  = " .. sampleText, 10, 324)

  -- step settings
  local step = pattern:getStep(stepIx)
  love.graphics.print("  step " .. hexstr(stepIx), 10, 348)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 2) .. "enabled = " .. boolstr(step.enabled), 10, 360)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 3) .. "note    = " .. hexstr2(step.note), 10, 372)
  local volume = string.format("%.2f", step.volume)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 4) .. "volume  = " .. volume, 10, 384)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 5) .. "sustain = " .. boolstr(step.sustain), 10, 396)

  -- sample settings
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 6) .. "sample " .. selectedSample.name, 200, 300)
  local sampleVolume = string.format("%.2f", selectedSample.gain)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 7) .. "volume       = " .. sampleVolume, 200, 312)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 8) .. "root note    = " .. hexstr2(selectedSample.rootNote), 200, 324)
  local attack = string.format("%.2f", selectedSample.envelope.attack)
  local decay = string.format("%.2f", selectedSample.envelope.decay)
  local sustain = string.format("%.2f", selectedSample.envelope.sustain)
  local release = string.format("%.2f", selectedSample.envelope.release)
  local resetVolumeOnAttack = boolstr(selectedSample.envelope.resetVolumeOnAttack)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 9) .. "attack       = " .. attack, 200, 336)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 10) .. "decay        = " .. decay, 200, 348)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 11) .. "sustain      = " .. sustain, 200, 360)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 12) .. "release      = " .. release, 200, 372)
  love.graphics.print(selection(selectedControl == CONTROL_SETTINGS and selectedOption == 13) .. "reset volume = " .. resetVolumeOnAttack, 200, 384)
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  local seqText = "stopped"
  if sequencer.playing then seqText = "playing" end
  love.graphics.print("part " .. hexstr(selectedPart) .. ", " .. seqText .. " (bpm " .. sequencer.bpm .. ")", 10, 20)

  for i = 0, 7 do
    drawPattern(i, 10, 50 + 30 * i)
  end

  drawStepOptions(selectedPattern, selectedStep)
end