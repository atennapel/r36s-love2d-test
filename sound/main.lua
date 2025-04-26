local KeyManager = require("KeyManager")
local PolySample = require("PolySample")

--local SOUND_FILE = "guitar_a.mp3"
--local ROOT_NOTE = 33
local SOUND_FILE = "piano-c4.wav"
local ROOT_NOTE = 60

local sample = nil

local selX = 0
local selY = 12
local transX = 0
local transY = 3

-- keys
local K_UP = "w"
local K_DOWN = "s"
local K_LEFT = "a"
local K_RIGHT = "d"
local K_A = "z"
local K_B = "lshift"
local K_START = "return"
local K_SELECT = "escape"
local KEYS = { K_UP, K_DOWN, K_LEFT, K_RIGHT, K_A, K_B, K_START, K_SELECT }
local KEY_COOLDOWN = 0.08

local keyManager = KeyManager.new(KEY_COOLDOWN, KEYS)

local placedNotes = {}
local gridNotes = {}

local function newPlacedNote(id, note, step, length)
  local self = {id = id, note = note, step = step, length = length}
  return self
end

local idCounter = 0
local function addPlacedNote(note, step, length_)
  local length = length_ or 1
  local id = idCounter
  idCounter = idCounter + 1
  placedNotes[id] = newPlacedNote(id, note, step, length)
  local steps = gridNotes[note]
  if steps == nil then
    steps = {}
    gridNotes[note] = steps
  end
  for i = step, step + length - 1 do
    steps[i] = id
  end
end

function love.load()
  love.graphics.setNewFont("font.otf", 12)
  sample = PolySample.new(SOUND_FILE)
  sample.rootNote = ROOT_NOTE

  keyManager:init(love)
end

local function getGridId(note, step)
  local a = gridNotes[note]
  if a == nil then return nil end
  return a[step]
end

function keyManager.keypressed(_, sc, _)
  if sc == "z" then
    local note = 60 + 15 - selY - transY
    local step = selX + transX
    local id = getGridId(note, step)
    if id == nil then
      addPlacedNote(note, step, 2)
    else
      local data = placedNotes[id]
      for i = data.step, data.step + data.length - 1 do
        gridNotes[note][i] = nil
      end
      placedNotes[id] = nil
    end
  end
end

function keyManager.keytrigger(sc, count)
  if count ~= 2 then -- ignore second key trigger to simulate repeat delay
    if sc == "s" then
      if selY < 15 then
        selY = selY + 1
      elseif transY < 48 then
        transY = transY + 1
      end
    elseif sc == "w" then
      if selY > 0 then
        selY = selY - 1
      elseif transY > -52 then
        transY = transY - 1
      end
    end
    if sc == "d" then
      if selX < 15 then
        selX = selX + 1
      elseif transX < 999 - 16 then
        transX = transX + 1
      end
    elseif sc == "a" then
      if selX > 0 then
        selX = selX - 1
      elseif transX > 0 then
        transX = transX - 1
      end
    end
  end
end

local TICK_SPEED = 0.25
local PATTERN_LENGTH = 16
local tick = TICK_SPEED
local step = -1
function love.update(dt)
  keyManager:update(dt)

  tick = tick + dt
  if tick >= TICK_SPEED then
    tick = tick - TICK_SPEED
    step = (step + 1) % PATTERN_LENGTH
    
    for note, steps in pairs(gridNotes) do
      local id = steps[step]
      if id then
        local data = placedNotes[id]
        local length = data.length
        local startStep = data.step
        if startStep == step then
          sample:off(note)
          sample:on(note)
        end
      end
    end
  end
end

local noteNames = {"C-", "C#", "D-", "D#", "E-", "F-", "F#", "G-", "G#", "A-", "A#", "B-"}
local noteWhite = {true, false, true, false, true, true, false, true, false, true, false, true}

local function midiNoteName(n)
  local note = (n % 12) + 1
  local octave = math.floor(n / 12) - 1
  return noteNames[note] .. octave
end

local function midiNoteIsWhite(n)
  return noteWhite[(n % 12) + 1]
end

local function drawBox(note, x, y)
  local placed_ = gridNotes[note]
  local placed = placed_ ~= nil and placed_[x - 1 + transX]
  local sel = x - 1 == selX and y - 1 == selY
  local selOrPlaced = sel or placed
  local ax = x * 24
  local ay = y * 24
  if step + 1 == x then
    love.graphics.setColor(0.25, 0.25, 0.25)
    love.graphics.rectangle("fill", ax, ay, 24, 24)
  end
  love.graphics.setColor(1, 1, 1)
  if (placed and not sel) then
    love.graphics.setColor(0.5, 0.5, 0.5)
  end
  local style = "line"
  if selOrPlaced then style = "fill" end
  love.graphics.rectangle(style, ax, ay, 24, 24)
  if selOrPlaced then
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(midiNoteName(note), ax + 1, ay + 5)
  end
end

function love.draw()
  for y = 0, 15 do
    local note = 60 + 15 - y - transY
    if midiNoteIsWhite(note) then
      love.graphics.setColor(0, 0, 0)
      love.graphics.rectangle("fill", 0, (y + 1) * 24, 24, 24)
      love.graphics.setColor(1, 1, 1)
    else
      love.graphics.setColor(1, 1, 1)
      love.graphics.rectangle("fill", 0, (y + 1) * 24, 24, 24)
      love.graphics.setColor(0, 0, 0)
    end
    love.graphics.print(midiNoteName(note), 1, (y + 1) * 24 + 5)
  end
  for x = 0, 15 do
    local xtext = 8
    if x + transX > 100 - 2 then
      xtext = 1
    elseif x + transX > 10 - 2 then
      xtext = 5
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(x + 1 + transX, (x + 1) * 24 + xtext, 5)
    for y = 0, 15 do
      drawBox(60 + 15 - y - transY, x + 1, y + 1)
    end
  end
end
