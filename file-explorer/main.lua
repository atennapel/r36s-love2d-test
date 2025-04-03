local curdir = ""
local items = nil
local curix = 0

function love.load()
  love.graphics.setNewFont("font.otf", 12)

  items = love.filesystem.getDirectoryItems(curdir)
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
    if items then
      local item = items[curix + 1]
      local path = curdir .. "/" .. item
      local info = love.filesystem.getInfo(path)
      if info then
        if info.type == "directory" then
          if curdir ~= "" then
            curdir = curdir .. "/" .. item
          else
            curdir = item
          end
          items = love.filesystem.getDirectoryItems(curdir)
          curix = 0
        elseif info.type == "file" then
          local audio = love.audio.newSource(path, "static")
          audio:play()
        end
      end
    end
  elseif sc == "lshift" then
    curdir = curdir .. "/.."
    items = love.filesystem.getDirectoryItems(curdir)
  end
end

function love.draw()
  love.graphics.print("curdir: " .. curdir, 10, 10)
  if items then
    for k, item in ipairs(items) do
      local i = k - 1
      local sel = "  "
      if curix == i then
        sel = "> "
      end
      love.graphics.print(sel .. i .. ": " .. item, 10, 22 + i * 12)
    end
  end
end
