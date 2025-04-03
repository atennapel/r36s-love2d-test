love.filesystem.setIdentity("r36s-love2d-test-file-explorer")

local function createItem(path, name, isDir, parent, isGotoParent)
  return { path = path, name = name, isDir = isDir, parent = parent, isGotoParent = isGotoParent or false }
end

local function fullItem(item)
  if item.path == "" then
    return item.name
  else
    return item.path .. "/" .. item.name
  end
end

local function compItem(a, b)
  if a.isDir then
    if b.isDir then return a.name < b.name
    else return true
    end
  else
    if b.isDir then return false
    else return a.name < b.name
    end
  end
end

local function getItemsFromDir(parentItem)
  local path = fullItem(parentItem)
  local rawItems = love.filesystem.getDirectoryItems(path)
  local items = {}
  if not rawItems then return items end
  for i = 1, #rawItems do
    local name = rawItems[i]
    local info = love.filesystem.getInfo(path .. "/" .. name)
    if info then
      local isDir = info.type == "directory"
      items[i] = createItem(path, name, isDir, parentItem)
    end
  end
  table.sort(items, compItem)
  if parentItem.parent then
    table.insert(items, 1, createItem(path, "..", true, parentItem, true))
  end
  return items
end

local saveDir = love.filesystem.getSaveDirectory()
local curdir = createItem("", "samples", true, nil)
local items = {}
local curix = 0

function love.load()
  love.graphics.setNewFont("font.otf", 12)

  os.execute("mkdir \"" .. saveDir .. "\"")
  os.execute("mkdir \"" .. saveDir .. "/samples\"")

  items = getItemsFromDir(curdir)
end

function love.keypressed(_, sc, _)
  if sc == "w" then
    if curix > 0 then
      curix = curix - 1
    end
  elseif sc == "s" then
    if curix < #items - 1 then
      curix = curix + 1
    end
  end

  if sc == "z" then
    local item = items[curix + 1]
    local path = fullItem(item)
    if item.isGotoParent then
      curdir = curdir.parent
      items = getItemsFromDir(curdir)
      curix = 0
    elseif item.isDir then
      curdir = item
      items = getItemsFromDir(curdir)
      curix = 0
    else
      local audio = love.audio.newSource(path, "static")
      audio:play()
    end
  end
end

function love.draw()
  love.graphics.print("savedir: " .. saveDir, 10, 10)
  love.graphics.print("curdir: " .. fullItem(curdir), 10, 22)
  if #items == 0 then
    love.graphics.print("(empty)", 10, 34)
  else
    for k, item in ipairs(items) do
      local i = k - 1
      local sel = "  "
      if curix == i then sel = "> " end
      local dir = ""
      if item.isDir then dir = " (dir)" end
      love.graphics.print(sel .. i .. ": " .. item.name .. dir, 10, 34 + i * 12)
    end
  end
end
