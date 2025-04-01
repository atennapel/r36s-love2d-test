require("util")

-- sizes
local SCREEN_WIDTH = 640
local SCREEN_HEIGHT = 480
local TILE_WIDTH = 32
local TILE_HEIGHT = 32
local WIDTH = math.floor(SCREEN_WIDTH / TILE_WIDTH)
local HEIGHT = math.floor(SCREEN_HEIGHT / TILE_HEIGHT)
local X_FONT = 11
local Y_FONT = 6
local TARGET_SIZE = 3
local SELECTION_WINDOW_WIDTH = 8
local SELECTION_WINDOW_HEIGHT = 6
local SELECTION_WINDOW_X = math.floor((WIDTH - SELECTION_WINDOW_WIDTH) / 2)
local SELECTION_WINDOW_Y = math.floor((HEIGHT - SELECTION_WINDOW_HEIGHT) / 2)

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
local KEY_COOLDOWN = 0.1

-- ui
local W_MAIN = 0
local W_SELECTION = 1

-- init
local map = {}
for x = 1, WIDTH do
  local submap = {}
  map[x] = submap
  for y = 1, HEIGHT do
    submap[y] = 0
  end
end
local function mapGet(x, y) return map[x + 1][y + 1] end
local function mapSet(x, y, v) map[x + 1][y + 1] = v end

local keys = {}
for i = 1, #KEYS do
  keys[KEYS[i]] = 0
end

local curX = math.floor(WIDTH / 2)
local curY = math.floor(HEIGHT / 2)


local curWindow = W_MAIN

function love.load()
  love.graphics.setNewFont("font.otf", 16)
end

local function toggle(x, y)
  local cur = mapGet(x, y)
  if cur == 0 then
    mapSet(x, y, 32)
  elseif cur == 126 then
    mapSet(x, y, 0)
  else
    mapSet(x, y, cur + 1)
  end
end

local function handleKey(sc)
  if curWindow == W_MAIN then
    if sc == K_UP then
      if curY > 0 then
        curY = curY - 1
      end
    elseif sc == K_DOWN then
      if curY < HEIGHT - 1 then
        curY = curY + 1
      end
    end
    if sc == K_LEFT then
      if curX > 0 then
        curX = curX - 1
      end
    elseif sc == K_RIGHT then
      if curX < WIDTH - 1 then
        curX = curX + 1
      end
    end

    if sc == K_A then
      toggle(curX, curY)
    end
  end
end

function love.keypressed(_, sc, _)
  if keys[sc] ~= nil then
    keys[sc] = 0
  end

  if sc == K_B then
    curWindow = (curWindow + 1) % 2
  end
end
local function updateKeys(dt)
  for sc, cooldown in pairs(keys) do
    if love.keyboard.isScancodeDown(sc) then
      local newcooldown = cooldown - dt
      if newcooldown <= 0 then
        keys[sc] = KEY_COOLDOWN
        handleKey(sc)
      else
        keys[sc] = newcooldown
      end
    end
  end
end

function love.update(dt)
  updateKeys(dt)
end

function love.draw()
  for y = 0, HEIGHT - 1 do
    for x = 0, WIDTH - 1 do
      local px = x * TILE_WIDTH
      local py = y * TILE_HEIGHT
      love.graphics.setColor(1, 1, 1)
      local tile = mapGet(x, y)
      if tile == 0 then
        love.graphics.rectangle("fill", px + (TILE_WIDTH / 2) - 1, py + (TILE_HEIGHT / 2) - 1, 2, 2)
      else
        love.graphics.print(string.char(tile), px + X_FONT, py + Y_FONT)
      end
      if curX == x and curY == y then
        love.graphics.line(px, py + TARGET_SIZE, px, py, px + TARGET_SIZE, py)
        love.graphics.line(px + TILE_WIDTH - 1, py + TARGET_SIZE, px + TILE_WIDTH - 1, py, px + TILE_WIDTH - 1 - TARGET_SIZE, py)
        love.graphics.line(px, py + TILE_HEIGHT - 1 - TARGET_SIZE, px, py + TILE_HEIGHT - 1, px + TARGET_SIZE, py + TILE_HEIGHT - 1)
        love.graphics.line(px + TILE_WIDTH - 1 - TARGET_SIZE, py + TILE_HEIGHT - 1, px + TILE_WIDTH - 1, py + TILE_HEIGHT - 1, px + TILE_WIDTH - 1, py + TILE_HEIGHT - 1 - TARGET_SIZE)
      end
    end
  end

  if curWindow == W_SELECTION then
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", SELECTION_WINDOW_X * TILE_WIDTH, SELECTION_WINDOW_Y * TILE_HEIGHT, SELECTION_WINDOW_WIDTH * TILE_WIDTH, SELECTION_WINDOW_HEIGHT * TILE_HEIGHT)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", SELECTION_WINDOW_X * TILE_WIDTH, SELECTION_WINDOW_Y * TILE_HEIGHT, SELECTION_WINDOW_WIDTH * TILE_WIDTH, SELECTION_WINDOW_HEIGHT * TILE_HEIGHT)
  end
end