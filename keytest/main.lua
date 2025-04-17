local gamepad = nil

local keytext = ""
local joytext = ""
local joyaxis = ""
local joyhat = ""
local gamepadtext = ""
local gamepadaxis = ""

local function boolstr(b)
  if b then return "true" else return "false" end
end

function love.load()
  love.graphics.setNewFont("font.otf", 12)

  local joysticks = love.joystick.getJoysticks()
  gamepad = joysticks[1]
end

function love.keypressed(k, s, r)
  keytext = "keypressed " .. k .. ", " .. s .. ", " .. boolstr(r)
end

function love.keyreleased(k, s)
  keytext = "keyrelease " .. k .. ", " .. s
end

function love.joystickpressed(j, b)
  joytext = "joystickpressed " .. j:getName() .. ", " .. b
end

function love.joystickreleased(j, b)
  joytext = "joystickrelease " .. j:getName() .. ", " .. b
end

function love.joystickaxis(j, a, v)
  joyaxis = "joystickaxis " .. j:getName() .. ", " .. a .. ", " .. v
end

function love.joystickhat(j, h, d)
  joyhat = "joystickhat " .. j:getName() .. ", " .. h .. ", " .. d
end

function love.gamepadpressed(j, b)
  gamepadtext = "gamepadpressed " .. j:getName() .. ", " .. b
end

function love.gamepadreleased(j, b)
  gamepadtext = "gamepadrelease " .. j:getName() .. ", " .. b
end

function love.gamepadaxis(j, a, v)
  gamepadaxis = "gamepadaxis " .. j:getName() .. ", " .. a .. ", " .. v
end

function love.draw()
  love.graphics.print(keytext, 10, 10)
  love.graphics.print(joytext, 10, 22)
  love.graphics.print(joyaxis, 10, 34)
  love.graphics.print(joyhat, 10, 46)
  love.graphics.print(gamepadtext, 10, 58)
  love.graphics.print(gamepadaxis, 10, 70)
end
